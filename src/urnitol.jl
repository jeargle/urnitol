# John Eargle (mailto: jeargle at gmail.com)
# 2016-2018
# urnitol

module urnitol

export Urn, EventBin, ProbArray, UrnSimulator, move_balls, discard_balls, pull_ball, pull, act, step_sim, choose_event


"""
Urn for holding balls.
"""
type Urn
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    Urn(name::AbstractString) = new(name, Dict())
    Urn(name::AbstractString, balls) = new(name, balls)
end


"""
Temporary holding bin for balls that have been removed from Urns.
"""
type EventBin
    name::AbstractString
    balls::Dict{AbstractString, Int64}
    pulls::Array{Urn, 1}
    # actions: Array of action commands of the form
    #   ("action_to_perform", Urn, "ball_class")
    actions::Array{Tuple{AbstractString, Union{Urn, Void}, Any}, 1}
    EventBin(name::AbstractString, balls, pulls, actions) = new(name, balls, pulls, actions)
end


"""
    move_balls(balls1, balls2, class)

Move balls from one collection into another.

# Arguments
- balls1: collection of balls to move
- balls2: collection to receive balls
- class: single class of ball to move; nothing uses all classes
"""
function move_balls(balls1::Dict, balls2::Dict; class=nothing)
    if class == nothing
        classes = keys(balls1)
    else
        classes = [class]
    end

    for i in classes
        if get(balls2, i, nothing) == nothing
            balls2[i] = 0
        end
        balls2[i] += balls1[i]
        balls1[i] = 0
    end
end


"""
    discard_balls(balls, discard, class)

Move balls from one collection to a discard bin.

# Arguments
- balls1: collection of balls to move
- discard: collection to receive balls
- class: single class of ball to move; nothing uses all classes
"""
function discard_balls(balls::Dict; discard=nothing, class=nothing)

    if discard == nothing
        if class == nothing
            classes = keys(balls)
        else
            classes = [class]
        end

        for i in classes
            balls[i] = 0
        end
    else
        move_balls(balls, discard, class=class)
    end
end


"""
    pull_ball(urn)

Pull a ball out of an Urn.
"""
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


"""
    pull(bin)

Pull balls from Urns and move them into an EventBin.
"""
function pull(bin::EventBin)
    for i in bin.pulls
        balls = pull_ball(i)
        move_balls(balls, bin.balls)
    end
end


"""
    act(bin)

Perform actions on all balls in an EventBin.
Actions are performed in Array order.  Possible actions are: move,
discard, and double.  Actions can be applied to all balls or to
specific classes.  After all actions are performed, there should be
no balls left in the EventBin.
"""
function act(bin::EventBin)
    println("act")
    for (command, urn, class) in bin.actions
        println("  ", command)
        if command == "move"
            move_balls(bin.balls, urn.balls, class=class)
        elseif command == "discard"
            if urn == nothing
                discard_balls(bin.balls, class=class)
            else
                discard_balls(bin.balls, discard=urn.balls, class=class)
            end
        elseif command == "double"
        end
    end
end


"""
"""
type UrnSimulator
    urns::Array{Urn, 1}
    events::Array{EventBin, 1}
end


"""
    pull(sim)

Pull balls for all EventBins in an UrnSimulator.
"""
function pull(sim::UrnSimulator)
    for event in sim.events
        pull(event)
    end
end


"""
    act(sim)

Process actions for all EventBins in an UrnSimulator.
"""
function act(sim::UrnSimulator)
    for event in sim.events
        act(event)
    end
end


"""
    step_sim(sim)

Calculate one timestep of an UrnSimulator.
"""
function step_sim(sim::UrnSimulator)
    pull(sim)
    act(sim)
end


"""
"""
type ProbArray
    event_weights::Array{EventBin, 1}
end


"""
    choose_event(prob)
"""
function choose_event(prob)
    return rand(prob.event_weights)
end


end
