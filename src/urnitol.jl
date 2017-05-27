# John Eargle (mailto: jeargle at gmail.com)
# 2016-2017
# Urnitol

module Urnitol

export EventBin, ProbArray, Urn, pull_ball, choose_event


type Urn
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    Urn(name::AbstractString) = new(name, Dict())
    Urn(name::AbstractString, balls) = new(name, balls)
end

type EventBin
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    EventBin(name::AbstractString, balls) = new(name, balls)
end

function pull_ball(urn)
    total_balls = sum(values(urn.balls))
    ball_idx = rand(1:total_balls)
    ball_count = 0
    chosen_balls = Dict()
    for i in keys(urn.balls)
        ball_count += urn.balls[i]
        if ball_count >= ball_idx
            urn.balls[i] -= 1
            chosen_balls[i] = 1
            break
        end
    end
    
    return chosen_balls
end

type ProbArray
    event_weights::Array{EventBin, 1}
end


function choose_event(prob)
    return rand(prob.event_weights)
end


end
