using Plots, StatsPlots
using CSV, DataFrames
using Dates
using Measures

# Get data on COVID-19 cases
url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
download(url, "covid19.csv")
df = CSV.read("covid19.csv", DataFrame; normalizenames = true)

# Load info about provinces
all_provinces = df[:, :Province_State]
provinces = ["British Columbia", "Alberta", "Saskatchewan", "Manitoba", "Ontario", "Quebec",
             "New Brunswick", "Nova Scotia", "Prince Edward Island", "Newfoundland and Labrador",
             "Nunavut", "Northwest Territories", "Yukon"]
population = [5_142_404, 4_417_006, 1_179_618, 1_378_818, 14_723_497,
              8_572_054, 781_024, 977_043, 159_249, 522_994, 38_966,
              45_201, 41_980]

# Total number of days
num_days = size(df, 2) - 4

# Create dataframe with Canada-only data
df_canada = copy(df[df.Country_Region .== "Canada", :])
df_provinces = df_canada[df_canada.Province_State .== provinces[1], :]
for i in 2:length(provinces)
    append!(df_provinces, df_canada[df_canada.Province_State .== provinces[i], :])
end

# parse Dates
names_dates = names(df_provinces[:, 5:end])
date_format = Dates.DateFormat("m/d/Y")
names_dates = replace.(names_dates, "_" => "/")
names_dates = chop.(names_dates, head = 1, tail = 0)
names_dates = parse.(Date, names_dates, date_format) .+ Year(2000)


# Matrix of cases
cases = Matrix{Float64}(df_provinces[:, 5:end])
cases = diff(cases, dims = 2)


# Plot cases by day
p = plot(size = (1200, 800), ylabel = "Cases per 100,000", 
         left_margin = 10mm, bottom_margin = 22mm, 
         xrotation = 45, tickfontsize = 12, guidefontsize = 14, 
         legend = :topleft, titlefontsize = 18)
for i in 1:length(provinces)
   p = plot!(p, names_dates[2:end], Vector(cases[i, 1:end]), label = provinces[i], lw = 2)
end	
title!(p, "Covid cases by province: Rolling 7-day average", titlelocation = :left)
annotate!(p, names_dates[end], -1600, 
          StatsPlots.text("Source: JHU CSSE COVID-19 Data. Analysis by sjwild.github.io\nSeptember 19, 2021", :lower, :right, 8, :grey))

png(p, "static_cases_by_province")


# calculate the 7-day rolling average, then divide by province population
cases_7day = Matrix{Float64}(undef, (length(provinces), length(names_dates) - 7))
for i in 1:length(provinces)
    for j in 8:size(cases, 2)
        cases_7day[i, j-6] = sum(cases[i, (j-6):j]) / 7
        cases_7day[i, j-6] = cases_7day[i, j-6] / population[i] * 100_000
    end
end

dates_7day = names_dates[8:end]


# Plot showing 7 day rolling average
p_7day = plot(size = (1200, 800),
              ylabel = "Cases per 100,000", left_margin = 10mm, bottom_margin = 22mm,
              xrotation = 45, tickfontsize = 12, guidefontsize = 14, legend = :topleft,
              titlefontsize = 18)
title!(p_7day, "Covid cases by province: Rolling 7-day average", titlelocation = :left)
for i in 1:length(provinces)
    p_7day = plot!(p_7day, dates_7day, Vector(cases_7day[i, 1:end]), label = provinces[i], lw = 4)
end	
annotate!(p_7day, dates_7day[end], -19, 
          StatsPlots.text("Source: JHU CSSE COVID-19 Data. Analysis by sjwild.github.io\nSeptember 19, 2021", :lower, :right, 8, :grey))

png(p_7day, "seven_day_rolling_average_by_province")



# animation
T = length(dates_7day)
anim = @animate for t in 1:T

    p_anim = plot(size = (1200, 800),
              ylabel = "Cases per 100,000", left_margin = 10mm, 
              bottom_margin = 22mm, right_margin = 2mm,
              xrotation = 45, tickfontsize = 12, guidefontsize = 14, legend = :topleft,
              titlefontsize = 18, ylims = (0, 65), 
              xlims = (dates_7day[1], dates_7day[end] + Day(15)))
    title!(p_anim, "Covid cases by province: Rolling 7-day average", titlelocation = :left)
    for i in 1:length(provinces)
        p_anim = plot!(p_anim, dates_7day[1:t], Vector(cases_7day[i, 1:t]), label = provinces[i], lw = 4)
    end	
    annotate!(p_anim, dates_7day[end], -17, 
              StatsPlots.text("Source: JHU CSSE COVID-19 Data. Analysis by sjwild.github.io\nSeptember 19, 2021", :lower, :right, 8, :grey))

end

gif(anim, "time_lapse.gif", fps = 20)
