# John Eargle (mailto: jeargle at gmail.com)
# urnitol

module urnitol

export Urn, Odds, Action, even, proportional, EventBin, ProbArray, UrnSimulator, select_urn, move_balls, discard_balls, pull_ball, pull, act, step_sim, run_sim, choose_event, read_trajectory_file, write_trajectory_file, setup_sim

using CSV
using DataFrames
using DataStructures
using Printf
using YAML


"""
Urn for holding balls.
"""
struct Urn
    name::AbstractString
    balls::SortedDict{AbstractString, Int64}
    Urn(name::AbstractString, balls=SortedDict{AbstractString, Int64}()) = new(name, balls)
end

function Base.show(io::IO, urn::Urn)
    print(io, string(urn.name * " -- " * join([k * ": " * string(v) for (k, v) in urn.balls], ", ")))
end


@enum Odds even proportional


"""
Action to take on previously pulled balls.
"""
struct Action
    command::AbstractString
    target_urns::Array{Urn, 1}
    target_string::AbstractString
    class::Union{AbstractString, Nothing}
    target_odds::Odds
    Action(command::AbstractString,
           target_urns::Array{Urn, 1},
           target_string::AbstractString="",
           class::Union{AbstractString, Nothing}=nothing,
           target_odds=even) = new(command, target_urns, target_string, class, target_odds)
end


"""
Temporary holding bin for balls that have been removed from Urns.
"""
struct EventBin
    name::AbstractString
    balls::SortedDict{AbstractString, Int64}
    urns::Array{Urn, 1}
    actions::Array{Action, 1}
    source_odds::Odds
    function EventBin(name::AbstractString, urns, actions, source_odds=even)
        # Normalize ball classes across Urns
        classes = Set{AbstractString}()
        for urn in urns
            for (class, count) in urn.balls
                push!(classes, class)
            end
        end

        balls = SortedDict{AbstractString, Int64}()
        for class in classes
            if !(class in keys(balls))
                balls[class] = 0
            end
        end

        new(name, balls, urns, actions, source_odds)
    end
end


"""
    get_urns(action, source_urn)

Fetch an array of Urns from an Action.

# Arguments
- action: Action from which Urn list is fetched
- bin: EventBin with Array of source Urns
- source_urn: Urn from which a ball was pulled

# Returns
- Array of Urns
"""
function get_urns(action::Action, bin::EventBin, source_urn::Urn)
    if length(action.target_urns) > 0
        urns = action.target_urns
    elseif action.target_string == "all"
        urns = bin.urns
    elseif action.target_string == "source"
        urns = [source_urn]
    elseif action.target_string == "not source"
        urns = [urn for urn in bin.urns if urn != source_urn]
    else
        urns = Array{Urn, 1}()
    end

    return urns
end


"""
    select_urn(urns, odds)

Select an Urn from an array of Urns.

# Arguments
- urns: Array of Urns to choose from
- odds: Odds to use in selection

# Returns
- selected Urn or nothing if urns Array is empty
"""
function select_urn(urns::Array{Urn, 1}, odds::Odds)
    selected_urn = nothing
    if length(urns) == 0
        selected_urn = nothing
    elseif odds == even
        urn_idx = rand(1:length(urns))
        selected_urn = urns[urn_idx]
    elseif odds == proportional
        total_balls = sum([sum(values(urn.balls)) for urn in urns])
        ball_idx = rand(1:total_balls)
        running_ball_count = 0
        for urn in urns
            running_ball_count += sum(values(urn.balls))
            if running_ball_count >= ball_idx
                selected_urn = urn
                break
            end
        end
    end

    return selected_urn
end


"""
    move_balls(balls1, balls2, class)

Move balls from one collection into another.

# Arguments
- balls1: collection of balls to move
- balls2: collection to receive balls
- class: single class of ball to move; nothing uses all classes
"""
function move_balls(balls1::SortedDict, balls2::SortedDict; class=nothing)
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
function discard_balls(balls::SortedDict; discard=nothing, class=nothing)

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
    double_balls(balls1, balls2, class)

Double and move balls from one collection into another.

# Arguments
- balls1: collection of balls to double
- balls2: collection to receive balls
- class: single class of ball to double; nothing uses all classes
"""
function double_balls(balls1::SortedDict, balls2::SortedDict; class=nothing)
    if class == nothing
        classes = keys(balls1)
    else
        classes = [class]
    end

    for i in classes
        if get(balls2, i, nothing) == nothing
            balls2[i] = 0
        end
        balls2[i] += balls1[i] * 2
        balls1[i] = 0
    end
end


"""
    pull_ball(urn)

Pull a ball out of an Urn.

# Arguments
- urn: Urn from which to pull a ball

# Returns
- SortedDict of chosen balls
"""
function pull_ball(urn::Urn)
    chosen_balls = SortedDict()
    total_balls = sum(values(urn.balls))
    if total_balls > 0
        ball_idx = rand(1:total_balls)
        ball_count = 0
        for i in keys(urn.balls)
            ball_count += urn.balls[i]
            if ball_count >= ball_idx
                urn.balls[i] -= 1
                chosen_balls[i] = 1
                break
            end
        end
    end

    return chosen_balls
end


"""
    pull(bin)

Pull balls from Urns and move them into an EventBin.
The probability that an Urn is chosen is proportional to the number of
balls in the Urn.

# Arguments
- bin: EventBin that will pull balls from its Urns
"""
function pull(bin::EventBin, urn::Urn)
    balls = pull_ball(urn)
    @printf "    pull %s %s\n" urn.name repr(balls)
    move_balls(balls, bin.balls)
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
function act(bin::EventBin, source_urn::Urn)
    for action in bin.actions
        urns = get_urns(action, bin, source_urn)
        urn = select_urn(urns, action.target_odds)
        # @printf "    action %s\n" action.command
        # @printf "      urn %s\n" repr(urn)
        if action.command == "move"
            if action.class != nothing && bin.balls[action.class] > 0
                @printf "    move %s %s\n" action.class repr(bin.balls[action.class])
            end
            move_balls(bin.balls, urn.balls, class=action.class)
        elseif action.command == "discard"
            if action.class != nothing && bin.balls[action.class] > 0
                @printf "    discard %s %s\n" action.class repr(bin.balls[action.class])
            end
            if urn == nothing
                discard_balls(bin.balls, class=action.class)
            else
                discard_balls(bin.balls, discard=urn.balls, class=action.class)
            end
        elseif action.command == "double"
            if action.class != nothing && bin.balls[action.class] > 0
                @printf "    double %s %s\n" action.class repr(bin.balls[action.class])
            end
            double_balls(bin.balls, urn.balls, class=action.class)
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
    source_urns::Dict
    trajectory::DataFrame
    function UrnSimulator(urns::Array{Urn, 1}, events::Array{EventBin, 1}, step_count::Int64=0)
        # Normalize ball classes across Urns
        classes = Set{AbstractString}()
        for urn in urns
            for (class, count) in urn.balls
                push!(classes, class)
            end
        end

        for urn in urns
            for class in classes
                if !(class in keys(urn.balls))
                    urn.balls[class] = 0
                end
            end
        end

        # Build empty trajectory
        header = Dict()
        header[:step] = Int[]
        header[:command] = String[]
        for urn in urns
            for class in classes
                col_name = urn.name * '.' * class
                header[Symbol(col_name)] = Int[]
            end
        end
        trajectory = DataFrame(header)
        # How to add a row to trajectory
        # push!(y, Dict(Symbol("step")=>4, Symbol("name")=>"David"))

        new(urns, events, step_count, Dict(), trajectory)
    end
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
        urn = select_urn(event.urns, event.source_odds)
        sim.source_urns[event] = urn
        pull(event, urn)
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
        act(event, sim.source_urns[event])
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
    run_sim(sim, num_steps)

Calculate multiple timesteps of an UrnSimulator.

# Arguments
- sim: UrnSimulator that will be stepped forward
"""
function run_sim(sim::UrnSimulator, num_steps)
    @printf "%s\n" repr(sim)
    for i in 1:num_steps
        step_sim(sim)
        @printf "%s\n" repr(sim)
    end
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


"""
    read_trajectory_file(filename)

Read a CSV file containing information for each step of a simulation.

# Arguments
- filename: name of CSV input file
"""
function read_trajectory_file(filename)
    return DataFrame(CSV.File(filename))
end


"""
    write_trajectory_file(filename, trajectory)

Write a CSV file containing information for each step of a simulation.

# Arguments
- filename: name of CSV output file
- trajectory: DataFrame with simulation step data
"""
function write_trajectory_file(filename, trajectory)
    CSV.write(filename, trajectory)
end


"""
    setup_sim(filename)

Create an UrnSimulator from a YAML setup file.

# Arguments
- filename: name of YAML setup file
"""
function setup_sim(filename)
    setup = YAML.load(open(filename))

    num_steps = 0
    if haskey(setup, "num_steps")
        num_steps = setup["num_steps"]
    end

    # build Urns
    urns = Array{Urn, 1}()
    name_to_urn = Dict()
    if haskey(setup, "urns")
        for urn_info in setup["urns"]
            name = urn_info["name"]

            balls = SortedDict()
            if haskey(urn_info, "balls")
                for ball_info in urn_info["balls"]
                    ball_num = 0
                    if haskey(ball_info, "num")
                        ball_num = ball_info["num"]
                    end
                    balls[ball_info["class"]] = ball_num
                end
            end

            urn = Urn(name, balls)
            push!(urns, urn)
            name_to_urn[name] = urn
        end
    end

    # build EventBins
    bins = Array{EventBin, 1}()
    if haskey(setup, "event_bins")
        for bin_info in setup["event_bins"]
            name = bin_info["name"]

            bin_urns = []
            if bin_info["source_urns"] isa Array
                for urn_name in bin_info["source_urns"]
                    push!(bin_urns, name_to_urn[urn_name])
                end
            elseif bin_info["source_urns"] == "all"
                for urn in urns
                    push!(bin_urns, urn)
                end
            else
                urn_name = bin_info["source_urns"]
                push!(bin_urns, name_to_urn[urn_name])
            end

            source_odds = even
            if haskey(bin_info, "source_odds")
                if bin_info["source_odds"] == "even"
                    source_odds = even
                elseif bin_info["source_odds"] == "proportional"
                    source_odds = proportional
                else
                    throw(DomainError(bin_info["source_odds"], "source_odds must be either \"even\" or \"proportional\""))
                end
            end

            actions = []
            for action_info in bin_info["actions"]
                action_type = action_info["type"]

                target_urns = Array{Urn, 1}()
                target_string = ""
                if haskey(action_info, "target_urns")
                    if action_info["target_urns"] isa Array
                        for urn_name in action_info["target_urns"]
                            push!(target_urns, name_to_urn[urn_name])
                        end
                    elseif action_info["target_urns"] == "all"
                        for urn in urns
                            push!(target_urns, urn)
                        end
                    elseif action_info["target_urns"] == "source"
                        target_string = "source"
                    elseif action_info["target_urns"] == "not source"
                        target_string = "not source"
                    else
                        urn_name = action_info["target_urns"]
                        push!(target_urns, name_to_urn[urn_name])
                    end
                end

                ball_class = nothing
                if haskey(action_info, "class")
                    ball_class = action_info["class"]
                end

                target_odds = even
                if haskey(action_info, "target_odds")
                    if action_info["target_odds"] == "even"
                        target_odds = even
                    elseif action_info["target_odds"] == "proportional"
                        target_odds = proportional
                    else
                        throw(DomainError(action_info["target_odds"], "target_odds must be either \"even\" or \"proportional\""))
                    end
                end

                action = Action(action_type, target_urns, target_string, ball_class, target_odds)
                push!(actions, action)
            end

            bin = EventBin(name, bin_urns, actions, source_odds)
            push!(bins, bin)
        end
    end

    return (UrnSimulator(urns, bins), num_steps)
end


end
