# John Eargle (mailto: jeargle at gmail.com)
# urnitol

module urnitol

export Urn, EventBin, ProbArray, UrnSimulator, move_balls, discard_balls, pull_ball, pull, act, step_sim, choose_event

using DataStructures
using YAML


"""
Urn for holding balls.
"""
struct Urn
    name::AbstractString
    balls::OrderedDict{AbstractString, Int64}
    Urn(name::AbstractString) = new(name, OrderedDict{AbstractString, Int64}())
    Urn(name::AbstractString, balls) = new(name, balls)
end

function Base.show(io::IO, urn::Urn)
    print(io, string(urn.name * " -- " * join([k * ": " * string(v) for (k, v) in urn.balls], ", ")))
end


"""
Temporary holding bin for balls that have been removed from Urns.
"""
struct EventBin
    name::AbstractString
    balls::OrderedDict{AbstractString, Int64}
    urns::Array{Urn, 1}
    # actions: Array of action commands of the form
    #   ("action_to_perform", Urn, "ball_class")
    actions::Array{Tuple{AbstractString, Union{Urn, Nothing}, Any}, 1}
    EventBin(name::AbstractString, balls, urns, actions) = new(name, balls, urns, actions)
end


"""
    move_balls(balls1, balls2, class)

Move balls from one collection into another.

# Arguments
- balls1: collection of balls to move
- balls2: collection to receive balls
- class: single class of ball to move; nothing uses all classes
"""
function move_balls(balls1::OrderedDict, balls2::OrderedDict; class=nothing)
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
function discard_balls(balls::OrderedDict; discard=nothing, class=nothing)

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

# Arguments
- urn: Urn from which to pull a ball
"""
function pull_ball(urn::Urn)
    total_balls = sum(values(urn.balls))
    ball_idx = rand(1:total_balls)
    ball_count = 0
    chosen_balls = OrderedDict()
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

# Arguments
- bin: EventBin that will pull balls from its Urns
"""
function pull(bin::EventBin)
    total_balls = sum([sum(values(urn.balls)) for urn in bin.urns])
    ball_idx = rand(1:total_balls)
    running_ball_count = 0
    for urn in bin.urns
        running_ball_count += sum(values(urn.balls))
        if running_ball_count >= ball_idx
            balls = pull_ball(urn)
            move_balls(balls, bin.balls)
            break
        end
    end
end


"""
    act(bin)

Perform actions on all balls in an EventBin.
Actions are performed in Array order.  Possible actions are: move,
discard, and double.  Actions can be applied to all balls or to
specific classes.  After all actions are performed, there should be
no balls left in the EventBin.

# Arguments
- bin: EventBin that will perform its actions
"""
function act(bin::EventBin)
    println("act EventBin")
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
Simulator that steps through a sequence of actions involving pulling
balls from Urns and then placing them in Urns or discarding them.
"""
mutable struct UrnSimulator
    urns::Array{Urn, 1}
    events::Array{EventBin, 1}
    step_count::Int64
    UrnSimulator(urns::Array{Urn, 1}, events::Array{EventBin, 1}) = new(urns, events, 0)
    UrnSimulator(urns::Array{Urn, 1}, events::Array{EventBin, 1}, step_count::Int64) = new(urns, events, step_count)
end

function Base.show(io::IO, sim::UrnSimulator)
    print(io, "step " * string(sim.step_count) * "\n" * join(["  " * repr(urn) for urn in sim.urns], '\n'))
end


"""
    pull(sim)

Pull balls for all EventBins in an UrnSimulator.

# Arguments
- sim: UrnSimulator that will perform the pull
"""
function pull(sim::UrnSimulator)
    for event in sim.events
        pull(event)
    end
end


"""
    act(sim)

Process actions for all EventBins in an UrnSimulator.

# Arguments
- sim: UrnSimulator that will perform the act
"""
function act(sim::UrnSimulator)
    for event in sim.events
        act(event)
    end
end


"""
    step_sim(sim)

Calculate one timestep of an UrnSimulator.

# Arguments
- sim: UrnSimulator that will be stepped forward
"""
function step_sim(sim::UrnSimulator)
    sim.step_count += 1
    pull(sim)
    act(sim)
end


"""
"""
struct ProbArray
    event_weights::Array{EventBin, 1}
end


"""
    choose_event(prob)

# Arguments
- prob: probability distribution
"""
function choose_event(prob)
    return rand(prob.event_weights)
end


end
