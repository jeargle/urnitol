# John Eargle (mailto: jeargle at gmail.com)
# 2016-2017
# Urnitol

module Urnitol

export EventBin, ProbArray, Urn, move_balls, pull_ball, pull, choose_event


type Urn
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    Urn(name::AbstractString) = new(name, Dict())
    Urn(name::AbstractString, balls) = new(name, balls)
end

type EventBin
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    pulls::Array{Urn, 1}
    actions::Array{Tuple{AbstractString, Urn, AbstractString}, 1}
    EventBin(name::AbstractString, balls, pulls, actions) = new(name, balls, pulls, actions)
end

function move_balls(balls1::Dict, balls2::Dict)
    for i in keys(balls1)
        if get(balls2, i, null) == null
            balls2[i] = 0
        end
        balls2[i] += balls1[i]
        balls1[i] = 0
    end
end

function pull_ball(urn::Urn)
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

function pull(bin::EventBin)
    for i in bin.pulls
        balls = pull_ball(i)
        move_balls(balls, bin.balls)
    end
end

type ProbArray
    event_weights::Array{EventBin, 1}
end


function choose_event(prob)
    return rand(prob.event_weights)
end


end
