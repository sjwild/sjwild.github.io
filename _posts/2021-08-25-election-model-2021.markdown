---
layout: post
title:  "Estimating Canadian vote intention with Julia and Turing, part II"
date:   2021-08-25 06:00:00 -0400
categories: blog
---

In this post I'm going to cover state space model I am using to estimate latent vote intention for the 2021 Canadian election. This model builds on the model in my last post, but it makes some extentions:
* It goes beyond the date of the 2019 election  
* It estimates the "margin of error" of each poll beyond the reported margin of error
* It includes more than one party

Full credit goes to [Peter Ellis](http://freerangestats.info/elections/nz-2017/combined.html), who made his code public. I've adapted it slightly to work here. Below I will break it down into sections and explain how each piece works.

# Extending it beyond the 2019 election
The first step is to extend the model so that we can forecast beyond the 2019 election. To do this, we're going to use the 2015-2019 period to estimate the house effects, and then we're going to use those house effects to estimate the post-2019 period. This is done with the following lines:

```julia
    # empty containers
    ξ = Matrix{T}(undef, (N_days, N_parties))
    
    ...

    ξ[1, :] = start_election
    ξ[election_2019, :] = end_election    
    

```

With these lines, we are establishing an empty container to hold our values. For the values on the first day and on the date of the 2019 election, we will input the final vote proportions rather than estimate them. We know these values, so we will make use of them.

In the code chunk below, we run a series of for loops for each party to set up our random walk. We use the values from the previous day, plus some random error, as the value for the next day. Because we have two periods, we do two separate loops, one for the period between the 2015 and 2019 elections, and the other for the post-2019 period.


```julia

# for loops to fill in random walk priors
    for t in 2:(election_2019 - 1)
        for j in 1:N_parties
            ξ[t,j] = ξ[t-1, j] + Ω[j, t-1]
        end
    end

    for tt in (election_2019 + 1):(N_days)
        for j in 1:N_parties
            ξ[tt,j] = ξ[tt - 1, j] + Ω[j, tt - 2]
        end
    end   

    ...

    for j in 1:N_parties
        end_election[j] ~ Normal(ξ[election_2019 - 1, j], 0.001)
    end

    return ξ

```

# Increasing the margin of error
The reported margin of error for each poll is generally too small. If we use it without accounting for other factors that might affect the margin of error, our estimates will be overly percise. So we need to adjust for other sources of error. I see four possible sources of error, three of which we need to estimate. 
* The sampling error
* A party-specific error
* A pollster-specific error (per party)
* A mode-specific error (per party)

I combine the four sources of error with the following lines of code:

```julia

    # empty container
    σ = Matrix{T}(undef, (N_polls, N_parties))
    
    ...

    # sigmas for party and pollster-by-party effects    
    σ_party ~ filldist(Exponential(1/20), N_parties)
    σ_pollster ~ filldist(Exponential(1/20), N_pollsters, N_parties)
    σ_mode ~ filldist(Exponential(1/20), N_modes, N_parties)


    
    # for loops to run model
    for i in 1:N_polls
        for j in 1:N_parties
            σ[i, j] = sqrt(σ_party[j]^2 + σ_pollster[pollster_id[i], j]^2 + σ_mode[mode_id[i], j]^2 + y_moe[i, j]^2)
            
            ...

        end
    end 

    ...

```

# Including more than one party
Finally, we extend the model to include more than one party. Because the vote intention per party is linked to the vote intention of the others, we need to account for it. A gain in vote share for one party means that at least one other party's share must decrease.

To account for the correlated changes in vote share, we need both a party-specific change and a correlation matrix that lets us link changes per party.

```julia
    
    # Omega and Rho for non-centered parameterization
    ω ~ filldist(truncated(Normal(0, 0.005), 0, Inf), N_parties)
    Ρ ~ LKJ(N_parties, 2.0)

    # House effects
    δ ~ filldist(Normal(0, 0.05), N_pollsters, N_parties)
    
    # Transform parameters
    ρ ~ filldist(MvNormal(zeros(N_parties), Ρ), N_days-2)

    Ω = diagm(ω) * ρ
```


# Putting it all together
Here is the code for the model itself. The full script, including the code to scrape the polls from Wikipedia, is [here](https://github.com/sjwild/sjwild.github.io/raw/main/assets/2021-08-25state-space-model-2021-election.jl).

```julia

# define model
@model function state_space_elections(
    y::Matrix, 
    y_moe::Matrix, 
    start_election::Vector, 
    end_election::Vector, 
    poll_date::Vector{Int}, 
    poll_id::Vector{Int}, 
    N_days::Int, 
    N_polls::Int,
    N_modes::Int,
    election_2019::Int,
    N_pollsters::Int, 
    N_parties::Int,
    pollster_id::Vector{Int}, 
    mode_id::Vector{Int},
    ::Type{T} = Float64) where {T}


    # empty containers
    ξ = Matrix{T}(undef, (N_days, N_parties))
    σ = Matrix{T}(undef, (N_polls, N_parties))
    μ = Matrix{T}(undef, (N_polls, N_parties))
    

    # Omega and Rho for non-centered parameterization
    ω ~ filldist(truncated(Normal(0, 0.005), 0, Inf), N_parties)
    Ρ ~ LKJ(N_parties, 2.0)

    # House effects
    δ ~ filldist(Normal(0, 0.05), N_pollsters, N_parties)
    

    # sigmas for party and pollster-by-party effects    
    σ_party ~ filldist(Exponential(1/20), N_parties)
    σ_pollster ~ filldist(Exponential(1/20), N_pollsters, N_parties)
    σ_mode ~ filldist(Exponential(1/20), N_modes, N_parties)


    # Transform parameters
    ρ ~ filldist(MvNormal(zeros(N_parties), Ρ), N_days-2)

    Ω = diagm(ω) * ρ


    ξ[1, :] = start_election
    ξ[election_2019, :] = end_election    
    
    # for loops to fill in random walk priors
    for t in 2:(election_2019 - 1)
        for j in 1:N_parties
            ξ[t,j] = ξ[t-1, j] + Ω[j, t-1]
        end
    end

    for tt in (election_2019 + 1):(N_days)
        for j in 1:N_parties
            ξ[tt,j] = ξ[tt - 1, j] + Ω[j, tt - 2]
        end
    end   

    # for loops to run model
    for i in 1:N_polls
        for j in 1:N_parties
            σ[i, j] = sqrt(σ_party[j]^2 + σ_pollster[pollster_id[i], j]^2 + σ_mode[mode_id[i], j]^2 + y_moe[i, j]^2)
            μ[i, j] = ξ[poll_date[i], j] + δ[pollster_id[i], j]
            y[i, j] ~ Normal(μ[i, j], σ[i, j])
        end
    end 

    for j in 1:N_parties
        end_election[j] ~ Normal(ξ[election_2019 - 1, j], 0.001)
    end

    return ξ
    #return ξ, σ, μ

end

```