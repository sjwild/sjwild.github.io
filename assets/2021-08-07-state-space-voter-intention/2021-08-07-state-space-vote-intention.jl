
using Plots, StatsPlots
using DataFrames, CSV
using Turing, ReverseDiff, Memoization
using LinearAlgebra
using RDatasets
using Dates
using Random
using Measures


# Helper functions
function calc_moe(x, ss)
    return  sqrt(x * (1-x) / ss)

end

function extract_params(chn::Chains, param::String)

    tmp = chn |> DataFrame
    tmp = tmp[:, startswith.(names(tmp), param)]
    ll = [quantile(tmp[:,i], 0.025) for i in 1:size(tmp, 2)]
    m = [quantile(tmp[:,i], 0.5) for i in 1:size(tmp, 2)]
    uu = [quantile(tmp[:,i], 0.975) for i in 1:size(tmp, 2)]

    return ll, m, uu
end


# load data
df = RDatasets.dataset("pscl", "AustralianElectionPolling")


# Set dates
dateformat = DateFormat("y-m-d")
Election2004 = Date("2004-10-09")
Election2007 = Date("2007-11-24")
N_days = Dates.value(Election2007 - Election2004) + 1
df.NumDays = df.EndDate .- Election2004
df.NumDays = Dates.value.(df.NumDays) .+ 1
xi_days = Election2004 .+ Dates.Day.(1:N_days) .- Dates.Day(1)


# Prep poll numbers and pollster index
df.ALPProp = df.ALP ./ 100
df.Poll_ID = [1:size(df, 1);]

pollster_dict = Dict(key => idx for (idx, key) in enumerate(unique(df.Org)))
df.pollster_id = [pollster_dict[i] for i in df.Org]
reverse_pollster = Dict(value => key for (key, value) in pollster_dict)


# Define model
@model function state_space(y, y_moe, start_election, end_election,
                            poll_date, poll_id, N_days, N_pollsters, pollster_id, ::Type{T} = Float64) where {T}

    # priors
    ξ = Vector{T}(undef, N_days)
    z_ξ ~ filldist(Normal(0, 1), (N_days-2))
    δ ~ filldist(Normal(0, 0.05), N_pollsters)
    σ ~ Exponential(1/5)
    

    # random walk for latent voting intention
    ξ[1] = start_election
    ξ[N_days] = end_election

    for i in 2:(N_days - 1)
        ξ[i] = ξ[i-1] + σ * z_ξ[i-1]
    end


    # Measurement model
    y .~ Normal.(ξ[poll_date[poll_id]] .+ δ[pollster_id], y_moe[poll_id])
    end_election ~ Normal(ξ[N_days - 1], 0.001)

    return ξ

end


# input data
N_polls = size(df, 1)
N_pollsters = length(unique(df.pollster_id))
y_moe = calc_moe.(df.ALPProp, df.SampleSize)
y = df.ALPProp
start_election = .3764
end_election = .4338
poll_date = df.NumDays
poll_id = df.Poll_ID
pollster_id = df.pollster_id


# Iterations
n_adapt = 500
n_iter = 500
n_chains = 4


# Run model
Random.seed!(74324)
Turing.setadbackend(:reversediff)
Turing.setrdcache(true)
model = state_space(y, y_moe, start_election, end_election, 
                    poll_date, poll_id, N_polls, N_days, N_pollsters, pollster_id)
chns = sample(model, NUTS(n_adapt, .8; max_depth = 12), MCMCThreads(), n_iter, n_chains)



# Extract house effects and plot
δ_ll, δ_m, δ_uu = extract_params(chns, "δ")
pollster_lab = [reverse_pollster[i] for i in 1:length(unique(df.Org))]


scatter((δ_m, pollster_lab), xerror = (δ_m - δ_ll, δ_uu - δ_m), legend = false, mc = :black, msc = :black,
        left_margin = 10mm, bottom_margin = 15mm, size = (750, 500))
vline!([0], lc = :orange, linestyle = :dot)
title!("House effects, ALP: 2004-2007")
annotate!(0.045, -0.3, StatsPlots.text("Source: pscl R package. Analysis by sjwild.github.io", :lower, :right, 8, :grey))
xlabel!("Percent")
xticks!([-0.02, -0.01, 0, 0.01, 0.02, 0.03, 0.04], ["-2", "-1", "0", "1", "2", "3", "4"])

savefig("ALP_house_effects_2004_2007.png")



# generate latent voting intention and plot
ξ_gq = generated_quantities(model, chns)
rs = n_iter * n_chains
ξ = Matrix{Float64}(undef, (rs, N_days))

for i in 1:rs
    tmp = collect(ξ_gq[i])
    for j in 1:N_days
        ξ[i, j] = tmp[j]
    end
end

ξ_ll = [quantile(ξ[:,i], 0.025) for i in 1:size(ξ, 2)]
ξ_m = [quantile(ξ[:,i], 0.5) for i in 1:size(ξ, 2)]
ξ_uu = [quantile(ξ[:,i], 0.975) for i in 1:size(ξ, 2)]

scatter(df.EndDate, df.ALPProp, group = df.Org, legend = :topleft, size = (750, 500),
        left_margin = 10mm, bottom_margin = 10mm, ylabel = "Vote intention (%)")
plot!(xi_days, ξ_m, ribbon = (ξ_m- ξ_ll, ξ_uu - ξ_m), label = nothing, 
      fc = :grey, lc = :black, lw = 2)
title!("Latent voting intentions, ALP: 2004-2007")
annotate!(xi_days[end], .27, StatsPlots.text("Source: pscl R package. Analysis by sjwild.github.io", :lower, :right, 8, :grey))
xlabel!("Date")
yticks!([0.35, 0.4, 0.45, 0.5, 0.55, 0.6], ["35", "40", "45", "50", "55", "60"])

savefig("ALP_vote_intention_2004_2007.png")

# Canadian Elections
election_day_2015 = Date(2015, 10, 19)
election_day_2019 = Date(2019, 10, 21)
can_polls = CSV.read("can_polls.csv", DataFrame; missingstring ="NA")
can_polls = dropmissing(can_polls, [:BQ, :GPC])
can_polls[:, :Other] = [1 - sum(can_polls[i,[:LPC, :CPC, :NDP, :BQ, :GPC]]) for i in 1:size(can_polls, 1)]
can_polls = can_polls[can_polls.Other .> 0.0000, :]
can_polls.poll_id = [1:size(can_polls,1);]

# Pollster IDs
pollster_dict_can = Dict(key => idx for (idx, key) in enumerate(unique(can_polls.Polling_firm)))
can_polls.pollster_id = [pollster_dict_can[i] for i in can_polls.Polling_firm]
reverse_pollster_can = Dict(value => key for (key, value) in pollster_dict_can)

# Dates
can_polls.poll_date = election_day_2015 .+ Dates.Day.(can_polls.NumDays)
xi_days_can = election_day_2015 .+ Dates.Day.(1:N_days_can) .- Dates.Day(1)



N_days_can = Dates.value(election_day_2019 - election_day_2015) + 1
N_polls_can = size(can_polls, 1)
N_pollsters_can = length(unique(can_polls.pollster_id))
y_moe_can = calc_moe.(can_polls.LPC, can_polls.SampleSize)
y_can = can_polls.LPC
start_election_can = 0.395
end_election_can = 0.331
poll_date_can = can_polls.NumDays
poll_id_can = can_polls.poll_id
pollster_id_can = can_polls.pollster_id


# Run model
model_can = state_space(y_can, y_moe_can, start_election_can, end_election_can, 
                        poll_date_can, poll_id_can, N_polls_can, N_days_can, N_pollsters_can, pollster_id_can)
chns_can = sample(model_can, NUTS(n_adapt, .8; max_depth = 12), MCMCThreads(), n_iter, n_chains)

ξ_gq_can = generated_quantities(model_can, chns_can)
ξ_can = Matrix{Float64}(undef, (rs, N_days_can))

for i in 1:rs
    tmp = collect(ξ_gq_can[i])
    for j in 1:N_days_can
        ξ_can[i, j] = tmp[j]
    end
end

ξ_ll_can = [quantile(ξ_can[:,i], 0.025) for i in 1:size(ξ_can, 2)]
ξ_m_can = [quantile(ξ_can[:,i], 0.5) for i in 1:size(ξ_can, 2)]
ξ_uu_can = [quantile(ξ_can[:,i], 0.975) for i in 1:size(ξ_can, 2)]

scatter(can_polls.poll_date, can_polls.LPC, legend = false, mc = :red, size = (750, 500),
        left_margin = 10mm, bottom_margin = 10mm, ylabel = "Vote intention (%)")
plot!(xi_days_can, ξ_m_can, ribbon = (ξ_m_can - ξ_ll_can, ξ_uu_can - ξ_m_can), label = nothing, 
      fc = :red, lc = :red, lw = 2)
title!("Latent voting intentions, LPC: 2015-2019")
annotate!(xi_days_can[end], .195, StatsPlots.text("Source: Polls scraped from Wikipedia. Analysis by sjwild.github.io", :lower, :right, 8, :grey))
xlabel!("Date")
yticks!([.25, .3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6], ["25", "30", "35", "40", "45", "50", "55", "60"])


savefig("LPC_vote_intention_2015_2019.png")


δ_ll_can, δ_m_can, δ_uu_can = extract_params(chns_can, "δ")
pollster_lab_can = [reverse_pollster_can[i] for i in 1:length(unique(can_polls.Polling_firm))]


scatter((δ_m_can, pollster_lab_can), xerror = (δ_m_can - δ_ll_can, δ_uu_can - δ_m_can), 
        legend = false, mc = :black, msc = :black,
        left_margin = 10mm, bottom_margin = 15mm, size = (750, 500))
vline!([0], lc = :orange, linestyle = :dot)
title!("House effects, Liberal Party of Canada: 2015-2019")
annotate!(0.075, -2.25, StatsPlots.text("Source: Polls scraped from Wikipedia. Analysis by sjwild.github.io", :lower, :right, 8, :grey))
xlabel!("Percent")
xticks!([-0.075, -0.05, -0.025, 0, 0.025, 0.05, 0.075], ["-7.5", "-5", "-2.5", "0", "2.5", "5", "7.5"])

savefig("LPC_house_effects_2015_2019.png")