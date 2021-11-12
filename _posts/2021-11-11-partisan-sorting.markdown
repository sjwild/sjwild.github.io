---
layout: post
title:  "Using Julia as a GIS to see who lives around you"
date:   2021-11-11 21:00:00 -0400
categories: blog
---

# Partisan sorting
About a month and a half ago, we had an election in Canada (you can see my election forecast [here](https://sjwild.github.io/election-forecast/)). After some time went by, I tried to see if I could find the official results by polling division. I couldn't. But I did find the 2019 election results. As we're in November, which is apparently 30 days of maps, I thought I would make a map.

The inspiration for this post is [a paper](https://www.nature.com/articles/s41562-021-01066-z) by Brown and Enos (2021), in which they look at the partisan sorting of 180 million US voters. Canada doesn't have quite the same level of granularity. To my knowledge, Canada doesn't have public voter files with your party registration (assuming you registered). But we do have electoral results by polling division, which gets us pretty close. 

There are roughly 70,000 polling divisions representing about 18 million voters, or less than 300 voters per district. Using this data, we can get an idea of the partisan sorting in Canadian cities.


## Creating the dataset
To plot partisan sorting, we're going to start by downloading the data, loading it, and renaming the variables we need. We'll need to download several zipfiles. While we could create a function to do this, I always forget how to do it in Julia, so I am going to write it out each time as a way of trying to cement it in my brain

```Julia
using ArchGDAL
using GeoArrays
using Shapefile
using Proj4
using Plots, StatsPlots, Measures
using CSV, DataFrames
using HTTP
using GeoDataFrames; const GD = GeoDataFrames
using GeoFormatTypes
using ZipFile



# download 2019 election results for Elections Canada website
mkdir("csvs")
url = "https://www.elections.ca/res/rep/off/ovr2019app/51/data_donnees/pollresults_resultatsbureauCanada.zip"
download(url, "csvs/polls.zip")


# Unzip file
pollszip = ZipFile.Reader("csvs/polls.zip")
for f in pollszip.files
    println("Filename: $(f.name)")
    fp = "csvs/$(f.name)"
    write(fp, read(f))
end

close(pollszip)


# Create a list of variables to subset
vars = ["Electoral_District_Number_Numéro_de_circonscription",
        "Electoral_District_Name_English_Nom_de_circonscription_Anglais",
        "Polling_Station_Number_Numéro_du_bureau_de_scrutin",
        "Polling_Station_Name_Nom_du_bureau_de_scrutin",
        "Political_Affiliation_Name_English_Appartenance_politique_Anglais",
        "Elected_Candidate_Indicator_Indicateur_du_candidat_élu",
        "Candidate_Poll_Votes_Count_Votes_du_candidat_pour_le_bureau"]


# read in files and create dataframe
csv_files = readdir("csvs", join = true)
csv_files = csv_files[Base.contains.(csv_files, ".csv")]

df = CSV.read(csv_files[1], DataFrame; normalizenames = true)[:, vars]
for i in 2:length(csv_files)
     append!(df, CSV.read(csv_files[i], DataFrame; normalizenames = true)[:, vars])
end


# Rename columns
rename!(df, Dict(:Electoral_District_Number_Numéro_de_circonscription => :District_number,
                 :Electoral_District_Name_English_Nom_de_circonscription_Anglais => :District_name,
                 :Polling_Station_Number_Numéro_du_bureau_de_scrutin => :Poll_number,
                 :Polling_Station_Name_Nom_du_bureau_de_scrutin => :Poll_name,
                 :Political_Affiliation_Name_English_Appartenance_politique_Anglais => :Party,
                 :Elected_Candidate_Indicator_Indicateur_du_candidat_élu => :Elected,
                 :Candidate_Poll_Votes_Count_Votes_du_candidat_pour_le_bureau => :Votes))
```

Once that's completed, we are going to create a new variable called `Poll_ID`. We will need this variable later to combine it with a shapefile of polling division boundaries. This will let us join each poll to the correct polling division, and therefore give us a map of partisan sorting.

We are also going to include a variable called `Most_votes`, which will let us select the party with the most votes. And speaking of parties, we are going to clean up the list of parties so that there are 6: Liberal, Conservative, NDP, Bloc Quebecios, Green, and Other. We will add a seventh option later.

```Julia
# create variable combining district number and poll number
df.Poll_ID = Vector{String}(undef, size(df, 1))
for i in 1:size(df, 1)
    df.Poll_ID[i] = join([df.District_number[i], " -", df.Poll_number[i]])
end


df.Party[in(["Liberal", "Conservative", "NDP-New Democratic Party",
             "Bloc Québécois", "Green Party"]).(df.Party) .== false] .= "Other"
```

We should have a data frame of approximately 480 thousand rows. However, each polling division has multiple rows because the original file contained one row per candidate per poll per division. So before we can proceed, we need to summarize the data. We will group the dataframe by `Poll_ID`, find out which party received the greatest vote per division, and flag that row with a "Y" indicating that the party receive the most votes.

```Julia
# summarize votes and get % vote
df.Most_votes = repeat(["N"], size(df, 1))


# group by Poll_ID, the find the row in each group that contains the most votes.
df_gr = groupby(df, :Poll_ID)
for i in 1:length(df_gr)
    df_gr[i].Most_votes[argmax(df_gr[i].Votes)] = "Y"
end


# Get the total votes made per divion, then covert votes per party into a percent
df_gr = combine(df_gr, :Votes => sum => :TotalVotes)
df = leftjoin(df, df_gr, on = :Poll_ID)
df.Vote_percent = df.Votes ./ df.TotalVotes * 100


# Subset data to include only parties that received most votes
df = df[df.Most_votes .== "Y", :]


# get size
size(df)
```

We are now down to 75 thousand rows. Whew!


## Working with shapefiles
Next, We are going to have to work with several shapefiles. This will let us map the vote percent per division.

As with the CSV file, we'll start by downloading a zip file.

```Julia
# Download file. Start by making a directory to hold it
mkdir("shapefiles")
pdurl = "https://ftp.maps.canada.ca/pub/elections_elections/Electoral-districts_Circonscription-electorale/Elections_Canada_2019/polling_divisions_boundaries_2019.shp.zip"
download(pdurl, "shapefiles/pollingdivisions.zip")
pdzip = ZipFile.Reader("shapefiles/pollingdivisions.zip")
for f in pdzip.files
    println("Filename: $(f.name)")
    fp = "shapefiles/$(f.name)"
    write(fp, read(f))
end

close(pdzip)


# Load shapefile in a GeoDataFrame using GeoDataFrames.jl
pds = GD.read("shapefiles/PD_CA_2019_EN.shp")


# create vector to hold district ID and poll ID
# Note that these have different names than in the CSV!
pds.Poll_ID = Vector{String}(undef, size(pds, 1))
for i in 1:size(pds, 1)
    pds.Poll_ID[i] = join([pds.FEDNUM[i], " - ", pds.PDNUM[i]])
end
```

At this point, the file itself isn't so easy to use. Unfortunately, it is organized by constituency, not city, so that makes it difficult to map one to the other. Thankfully, we can use another shapefile to find out if the centroids of the polling division fall within a municipal boundary.

There are probably other ways to link these files and figure out what cities they are in. But the point of this exercise was to learn how to use Julia as geographic information system. So maybe I overcomplicated it by being overly verbose or by using methods I shouldn't have.

We are going to use the Statistics Canada census boundary file for population centres. Population centres are any area with a population of at least 1,000 and a density of at least 400 people per square km.

```Julia
# Don't need to create shapefiles directory, as we already have one
pcurl = "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpc_000b16a_e.zip"
download(pcurl, "shapefiles/popcentres.zip")
pczip = ZipFile.Reader("shapefiles/popcentres.zip")
for f in pczip.files
    println("Filename: $(f.name)")
    fp = "shapefiles/$(f.name)"
    write(fp, read(f))
end

close(pczip)


popcentres = GD.read("shapefiles/lpc_000b16a_e.shp")
```

Before doing the next step, I took a few minutes to review the documentation on the shapefiles. Thankfully, all three shapefiles we will use feature the same projection, so we don't need to convert them. In Julia I haven't found an easy way to see the projection yet. In R, one could use `st_crs(shpfl)$proj4string)` or something similar if load the shapefile as an `sf` object.

Because the shapefiles both use the same projection, we can use the `GeoDataFrames`'s `within` function to see if the centroids of a given polling division fall within a municpal boundary. In this case, I chose to use the centroids because it sped up the computations. To be more complete, we could use the full boundary and `GeoDataFrames.overlaps` as well. But it's a blog post, so simple we shall go. 

The code below is not the most efficient way of doing this search. It wastes time looping through observations even if the polling division has already been assigned to a population centre. But it only takes about 10 minutes on my laptop. 

Note the use of the `Threads.@threads` macro. This is one way julia can take advantage of multiple cores to speed up operations. You can use the `Threads.@threads` macro in front of a for loop. More details about `Threads.@threads` are available [here](https://docs.julialang.org/en/v1/manual/multi-threading/).

```Julia
# Create a column identifying if the polling division is rural
pds.PCPUID = repeat(["Rural"], size(pds, 1))
pds.Centroids = GD.centroid(pds.geom)

Threads.@threads for i in 1:size(pds, 1)
    for j in 1:size(popcentres, 1)
        if GD.within(pds.Centroids[i], popcentres.geom[j])
            pds.PCPUID[i] = popcentres.PCPUID[j]
        end
    end
end

pds = leftjoin(pds, popcentres[:, [:PCPUID, :PCNAME, :PRNAME]], on = :PCPUID)
```

The next step is to assign a province name for those polling division that exist outside a population centre. Then I will combine all three of the datasets--the poll results, the polling division boundaries, and the names of cities and provinces for each polling division--and convert the province names into the 2-digit province code. 

```Julia
# Download provinces shapefile and open
prurl = "https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpr_000b16a_e.zip"
download(prurl, "shapefiles/provinces.zip")
przip = ZipFile.Reader("shapefiles/provinces.zip")
for f in przip.files
    println("Filename: $(f.name)")
    fp = "shapefiles/$(f.name)"
    write(fp, read(f))
end

close(przip)

provinces = GD.read("shapefiles/lpr_000b16a_e.shp")

# assign province names to empty observations
Threads.@threads for i in 1:size(pds, 1)
    if pds.PCPUID[i] == "Rural"
        for j in 1:size(provinces, 1)
            if GD.within(pds.Centroids[i], provinces.geom[j])
                pds.PRNAME[i] = coalesce(pds.PRNAME[i], provinces.PRNAME[j])
            end
        end
    end
end


# join files together and drop missing observations
# In this case, it is due to the centroids being outside
# province boudaries.
df = innerjoin(df, pds[:, [:Poll_ID, :PCNAME, :PRNAME, :geom]], on = :Poll_ID)
dropmissing!(df, :PRNAME)


# create new variable of province codes
prname = unique(df.PRNAME)
prshort = ["NL", "PE", "NS", "NB", "QC", "ON",
           "MB", "SK", "AB", "BC", "YT", "NT",
           "NU"]

df.PRSHORT = Vector{String}(undef, size(df, 1))
for p in 1:length(prname)
    df.PRSHORT[df.PRNAME .== prname[p]] .= prshort[p]
end


# fill in PCNAME in case we want just rural areas
for i in 1:size(df, 1)
    if ismissing(df.PCNAME[i])
        df.PCNAME[i] = coalesce(df.PCNAME[i], join(["Rural ", df.PRSHORT[i]]))
    end
end
```

Our dataset is almost ready to use. The final thing we are going to do is assign a value of "0" to the `Vote_percent` variable if there were 0 votes in the polling division. There are 504 division with 0 votes. 

```Julia
size(df[df.TotalVotes .== 0])


# Assign 0 to :Vote_percent and assign "NA" as party for mapping
df.Vote_percent[df.TotalVotes .== 0] .= 0
df.Party[df.TotalVotes .== 0] .= "NA"
```

## Plotting partisan sorting
Now that we have my dataset, we can plot images showing partisan sorting by city or province. Because we will make several plots, we should create a function. In this case, the function below is probably too large and should be broken down into a bunch of smaller functions. But for now, it works.

This function will take the dataframe we have produced, along with a city name or province code (either of which must be exact here), along with the location of the legend and an indicator for whether we are making a city or provincial map. In turn, it will subset the data and produce the map. It will loop through the number of parties that won in at least one polling division, and colour-code the division by party and vote percent. Darker colours mean a higher vote percentage.

In the function below, you should note that we first plot the polling divisions without a legend. We finish by plotting the first observation for each party and adding a legend. This gives us a legend for our plot so we can see which colours are associated with which party. When I tried it the other way (legend first), I could not get the legend to display correctly.

Unfortunately, the party colours are not colourblind friendly. Liberals are red, Green is green, both the Conservatives and Bloc Québécois use shades of blue. I've tried to stick to their colours below. Suggestions for a colourblind palette that works for the party colours is welcome.

```Julia
function plot_pd(df::DataFrame, city_pr, legend_loc = :bottomright; city = true)

	if city == true
		tmp = df[df.PCNAME .== city_pr, :]
	elseif city == false
		tmp = df[df.PRSHORT .== city_pr, :]
	end

	tmp = tmp[isnan.(tmp.Vote_percent) .== false, :]
	tmp_parties = unique(tmp.Party)
	colours = [:reds, :blues, :Oranges_3, :YlGnBu_3,
	           :Greens_3, :Purples_3, cgrad(:Greys_3, rev = true)]
	parties = ["Liberal", "Conservative", "NDP-New Democratic Party",
	           "Bloc Québécois", "Green Party", "Other", "NA"]

	plt = plot(grid = false, axis = false, ticks = nothing,
	           colorbar = false, size = (2400, 2400),
			   title = "Partisan sorting: $city_pr",
			   titlefontsize = 48,
			   titleposition = :left,
			   foreground_color_legend = nothing)
	for i in 1:length(tmp_parties)
		zfc = colours[parties .== tmp_parties[i]][1]
		plot!(plt, tmp.geom[tmp.Party .== tmp_parties[i]][2:end], fill = zfc,
	          fill_z = tmp.Vote_percent[tmp.Party .== tmp_parties[i]][2:end]',
			  label = nothing, clims = (0, 100))
		plot!(plt, tmp.geom[tmp.Party .== tmp_parties[i]][1], fill = zfc,
	          fill_z = tmp.Vote_percent[tmp.Party .== tmp_parties[i]][1]',
			  label = tmp_parties[i], legend = legend_loc,
			  legendfontsize = 26, clims = (0, 100))
	end

	return plt

end
```

Now it is time to produce some images. Let's start with the centre of the universe (otherwise known as Toronto), Montreal, Vancouver, BC, and Manitoba. You will see there are some white areas. These are areas where there is no polling division, either because it is an industrial area, park, uninhabited, or it was dropped from the dataset when I was cleaning it.

```Julia
# plot some cities and provinces
toronto = plot_pd(df, "Toronto");
montreal = plot_pd(df, "Montréal");
vancouver = plot_pd(df, "Vancouver", :bottomleft);
bc = plot_pd(df, "BC", :topright; city = false);
mb = plot_pd(df, "MB"; city = false);

# add annotations and save
annotate!(toronto, 7.263e6, 8.905e5, StatsPlots.text("Source: Elections Canada. Analysis by sjwild.github.io\nNovember 11, 2021",  
          :right, 20, :grey));
annotate!(montreal, 7.661e6, 1.2145e6, StatsPlots.text("Source: Elections Canada. Analysis by sjwild.github.io\nNovember 11, 2021",  
          :right, 20, :grey));
annotate!(vancouver, 4.0585e6, 1.965e6, StatsPlots.text("Source: Elections Canada. Analysis by sjwild.github.io\nNovember 11, 2021",  
          :right, 20, :grey));
plot!(vancouver, bottom_margin = 7mm);
annotate!(mb, 6.575e6, 1.425e6, StatsPlots.text("Source: Elections Canada. Analysis by sjwild.github.io\nNovember 11, 2021",  
          :right, 20, :grey));
annotate!(bc, 5.15e6, 1.63e6, StatsPlots.text("Source: Elections Canada. Analysis by sjwild.github.io\nNovember 11, 2021",  
          :right, 20, :grey));
plot!(bc, bottom_margin = 20mm);

savefig(toronto, "Toronto.png")
savefig(montreal, "Montreal.png")
savefig(vancouver, "Vancouver.png")
savefig(bc, "BC.png")
savefig(mb, "MB.png")
```

## What these images (kind of) tell us
Similar to the results of Brown and Enos (2021), a large proportion of Canadian voters live in nieghbourhoods with like-minded voters. 

Generally, we see the left-most Canadian political parties (the NDP and Liberals) winning polling divisions in downtown areas, with suburbs being more likely to vote to the right (that is, more conservative). This pattern holds for most of the cities. It nicely aligns with the findings of _Why Cities Lose: The Deep Roots of the Urban-Rural Political Divide_ by Jonathan A. Rodden. 

I've picked a few cities to look at, along with two provinces. For the cities, the same pattern tends to hold. 

### Toronto  
Let's start by looking at Toronto.

<img src="https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/Toronto.png" alt="Map of Toronto, Canada, showing vote by polling district. The color gradient moves from NDP (orange) in downtown, to Liberal (red), to Conservative (blue) in the suburbs" width="800" height="800" />

As you can see, the NDP won some polling divisions in downtown Toronto. As we move out to the suburbs, we can see more polling districts voting conservative.

### Montreal
Montreal is similar. We can see the NDP winning in the urban cores. As we move out to the suburbs, we can see more polling districts voting for the Bloc Québécois.

<img src="https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/Montreal.png" alt="Map of Montreal, Canada, showing vote by polling district. The color gradient moves from NDP (orange) in downtown, to Liberal (red), to Conservative (blue) in the suburbs" width="800" height="800" />

### Vancouver
Same effect in Vancouver. In Vancouver, though, we can see a light grey patch, where Jody Wilson-Raybould ran as an independent candidate.

<img src="https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/Vancouver.png" alt="Map of Vancouver, Canada, showing vote by polling district. The color gradient moves from NDP (orange) in downtown, to Liberal (red), to Conservative (blue) in the suburbs. A grey section in downtown shows polling divisions that voted for Jody Wilson-Raybould, who ran as an independent" width="800" height="800" />

### British Columbia
In British Columbia, we can see strong support for the NDP in the north-western part of the province, while the interior tends to vote Conservative. The south-western part of the province, which contains the city of Vancouver, tend to vote NDP, Green, or Liberal.

<img src="https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/BC.png" alt="A map of British Columbia showing NDP (orange) support in the north-west, Conservative (blue) support in the interior, and NDP (orange), Green (green), and Liberal (red) support in the south" width="800" height="800" />

### Manitoba
In Manitoba, we can see strong support for the NDP in the northern rural part of the province, while the southern rural area votes Conservative. Winnipeg, which isn't shown, votes NDP in the urban core, then votes Liberal as you move out to the suburbs, then Conservative in the suburbs.

<img src="https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/MB.png" alt="A map of Manitoba. It shows NDP (orange) support in the north and Conservative (bule) support in the south" width="800" height="800" />


## Resources
* Final script [here](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-11-11-partisan-sorting/Canada_polls.jl)
* Polling division boundary [shapefile](https://ftp.maps.canada.ca/pub/elections_elections/Electoral-districts_Circonscription-electorale/Elections_Canada_2019/polling_divisions_boundaries_2019.shp.zip)
* Final [2019 vote results](https://www.elections.ca/res/rep/off/ovr2019app/51/data_donnees/pollresults_resultatsbureauCanada.zip)
* Population centre boundary [shapefile](https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpc_000b16a_e.zip)
* Provincial boundary [shapefile](https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/2016/lpr_000b16a_e.zip)
* [_Why Cities Lose: The Deep Roots of the Urban-Rural Political Divide_](https://www.amazon.ca/Why-Cities-Lose-Urban-Rural-Political-ebook/dp/B07J53T55S)
