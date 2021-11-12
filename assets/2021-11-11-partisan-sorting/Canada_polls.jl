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


# download election results
mkdir("csvs")
url = "https://www.elections.ca/res/rep/off/ovr2019app/51/data_donnees/pollresults_resultatsbureauCanada.zip"
download(url, "csvs/polls.zip")
pollszip = ZipFile.Reader("csvs/polls.zip")
for f in pollszip.files
	println("Filename: $(f.name)")
	fp = "csvs/$(f.name)"
	#open(f.name, "w")
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


# Rename variables
rename!(df, Dict(:Electoral_District_Number_Numéro_de_circonscription => :District_number,
                 :Electoral_District_Name_English_Nom_de_circonscription_Anglais => :District_name,
				 :Polling_Station_Number_Numéro_du_bureau_de_scrutin => :Poll_number,
				 :Polling_Station_Name_Nom_du_bureau_de_scrutin => :Poll_name,
                 :Political_Affiliation_Name_English_Appartenance_politique_Anglais => :Party,
                 :Elected_Candidate_Indicator_Indicateur_du_candidat_élu => :Elected,
                 :Candidate_Poll_Votes_Count_Votes_du_candidat_pour_le_bureau => :Votes))

df.Poll_ID = Vector{String}(undef, size(df, 1))
for i in 1:size(df, 1)
	df.Poll_ID[i] = join([df.District_number[i], " -", df.Poll_number[i]])
end

df.Party[in(["Liberal", "Conservative", "NDP-New Democratic Party",
	           "Bloc Québécois", "Green Party"]).(df.Party) .== false] .= "Other"


# summarize votes and get % vote
df.Most_votes = repeat(["N"], size(df, 1))


df_gr = groupby(df, :Poll_ID)
for i in 1:length(df_gr)
	df_gr[i].Most_votes[argmax(df_gr[i].Votes)] = "Y"
end

df_gr = combine(df_gr, :Votes => sum => :TotalVotes)
df = leftjoin(df, df_gr, on = :Poll_ID)
df.Vote_percent = df.Votes ./ df.TotalVotes * 100


df = df[df.Most_votes .== "Y", :]

# download and open shapefile of polling station locations
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


pds = GD.read("shapefiles/PD_CA_2019_EN.shp")
pds.Poll_ID = Vector{String}(undef, size(pds, 1))
for i in 1:size(pds, 1)
	pds.Poll_ID[i] = join([pds.FEDNUM[i], " - ", pds.PDNUM[i]])
end

#df = innerjoin(df, pds[:, [:Poll_ID, :geom]], on = :Poll_ID)



# download popcentres and open
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



# find locations for polling divisions.
pds.PCPUID = repeat(["Rural"], size(pds, 1))
pds.Centroids = GD.centroid(pds.geom)

@time Threads.@threads for i in 1:size(pds, 1)
    for j in 1:size(popcentres, 1)
        if GD.within(pds.Centroids[i], popcentres.geom[j])
            pds.PCPUID[i] = popcentres.PCPUID[j]
		end
	end
end


pds = leftjoin(pds, popcentres[:, [:PCPUID, :PCNAME, :PRNAME]], on = :PCPUID)



#Input province if PCNAME is "Rural"
@time Threads.@threads for i in 1:size(pds, 1)
	if pds.PCPUID[i] == "Rural"
		for j in 1:size(provinces, 1)
			if GD.within(pds.Centroids[i], provinces.geom[j])
				pds.PRNAME[i] = coalesce(pds.PRNAME[i], provinces.PRNAME[j])
			end
		end
	end
end


# join files together and drop missing observations
# In this case, it is due to the centroids being outside provnce 
# boudaries.
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


# There are 504 polling divisions with 0 votes.
# Assign 0 to :Vote_percent and assign "NA" as party for mapping
df.Vote_percent[df.TotalVotes .== 0] .= 0
df.Party[df.TotalVotes .== 0] .= "NA"



# build function to plot
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








