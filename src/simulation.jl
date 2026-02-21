# John Eargle (mailto: jeargle at gmail.com)
# urnitol.simulation

"""
Simulator that steps through a sequence of actions involving pulling
balls from Urns and then placing them in Urns or discarding them.
"""
mutable struct UrnSimulator
    urns::Array{Urn, 1}
    events::Array{EventBin, 1}
    step_count::Int64
    source_urns::Dict
    ball_classes::Set{String}   # all ball class names
    trajectory::DataFrame
    step_log::Dict   # scratch space for next row of trajectory

    function UrnSimulator(urns::Array{Urn, 1}, events::Array{EventBin, 1}, step_count::Int64=0)
        # Normalize ball classes across Urns
        ball_classes = Set{String}()
        for urn in urns
            for (class, count) in urn.balls
                push!(ball_classes, class)
            end
        end

        for urn in urns
            for class in ball_classes
                if !(class in keys(urn.balls))
                    urn.balls[class] = 0
                end
            end
        end

        # Build empty trajectory
        header = OrderedDict()
        header[:step] = Int[]

        for class in ball_classes
            header[Symbol(class)] = Int[]
        end

        for urn in urns
            for class in ball_classes
                col_name = urn.name * '.' * class
                header[Symbol(col_name)] = Int[]
            end
        end
        trajectory = DataFrame(header)

        new(urns, events, step_count, Dict(), ball_classes, trajectory)
    end
end

function Base.show(io::IO, sim::UrnSimulator)
    print(io, "step " * string(sim.step_count) * "\n" * join(["  " * repr(urn) for urn in sim.urns], '\n'))
end


"""
    pull_balls(sim::UrnSimulator)

Pull balls for all EventBins in an UrnSimulator.

# Arguments
- `sim::UrnSimulator`: UrnSimulator that will perform the pull.
"""
function pull_balls(sim::UrnSimulator)
    for event in sim.events
        urns = event.source_urns

        urn = select_urn(urns, event.source_odds)
        sim.source_urns[event] = urn
        for pull in event.pulls
            pull_balls(event, pull, urn)
        end
    end
end


"""
    act(sim::UrnSimulator)

Process actions for all EventBins in an UrnSimulator.

# Arguments
- `sim::UrnSimulator`: UrnSimulator that will perform the act.
"""
function act(sim::UrnSimulator)
    for event in sim.events
        act(event, sim.source_urns[event])
    end
end


"""
    log_pulls(sim::UrnSimulator)

Record ball pulls to trajectory.

# Arguments
- `sim::UrnSimulator`: UrnSimulator to record.
"""
function log_pulls(sim::UrnSimulator)
    sim.step_log = Dict()
    sim.step_log[:step] = sim.step_count

    for class in sim.ball_classes
        sim.step_log[Symbol(class)] = 0
    end

    for bin in sim.events
        for class in keys(bin.balls)
            sim.step_log[Symbol(class)] += bin.balls[class]
        end
    end
end


"""
    log_urns(sim::UrnSimulator)

Record current urn states to trajectory.

# Arguments
- `sim::UrnSimulator`: UrnSimulator to record.
"""
function log_urns(sim::UrnSimulator)
    for urn in sim.urns
        for class in sim.ball_classes
            col_name = urn.name * '.' * class
            sim.step_log[Symbol(col_name)] = urn.balls[class]
        end
    end

    push!(sim.trajectory, sim.step_log)
end


"""
    step_sim(sim::UrnSimulator)

Calculate one timestep of an UrnSimulator.

# Arguments
- `sim::UrnSimulator`: UrnSimulator that will be stepped forward.
"""
function step_sim(sim::UrnSimulator)
    sim.step_count += 1
    pull_balls(sim)
    log_pulls(sim)
    act(sim)
    log_urns(sim)
end


"""
    run_sim(sim::UrnSimulator, num_steps)

Calculate multiple timesteps of an UrnSimulator.

# Arguments
- `sim::UrnSimulator`: UrnSimulator that will be stepped forward.
- `num_steps`: number of steps to run.
"""
function run_sim(sim::UrnSimulator, num_steps)
    @printf "%s\n" repr(sim)
    for i in 1:num_steps
        step_sim(sim)
        @printf "%s\n" repr(sim)
    end
end


"""
    setup_sim(filename)

Create an UrnSimulator from a YAML setup file.

# Arguments
- `filename`: name of YAML setup file.
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
    string_to_pull_type = Dict("pull"=>pt_pull, "create"=>pt_create)
    bins = Array{EventBin, 1}()
    if haskey(setup, "event_bins")
        for bin_info in setup["event_bins"]
            name = bin_info["name"]

            source_urns = Array{Urn, 1}()
            if bin_info["source_urns"] isa Array
                for urn_name in bin_info["source_urns"]
                    push!(source_urns, name_to_urn[urn_name])
                end
            elseif bin_info["source_urns"] == "all"
                for urn in urns
                    push!(source_urns, urn)
                end
            else
                urn_name = bin_info["source_urns"]
                push!(source_urns, name_to_urn[urn_name])
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

            pulls = []
            if haskey(bin_info, "pulls")
                bin_info_pulls = bin_info["pulls"]
            else
                bin_info_pulls = []
            end

            for pull_info in bin_info_pulls
                pull_type = string_to_pull_type[pull_info["type"]]
                source_classes = Array{String, 1}()

                if haskey(pull_info, "source_classes")
                    for class_name in pull_info["source_classes"]
                        push!(source_classes, class_name)
                    end
                end

                pull_source_odds = even
                if haskey(pull_info, "source_odds")
                    if pull_info["source_odds"] == "even"
                        pull_source_odds = even
                    elseif pull_info["source_odds"] == "proportional"
                        pull_source_odds = proportional
                    else
                        throw(DomainError(pull_info["source_odds"], "source_odds must be either \"even\" or \"proportional\""))
                    end
                end

                if length(source_classes) > 0
                    pull = Pull(pull_type, source_classes, source_odds=pull_source_odds)
                else
                    pull = Pull(pull_type, source_odds=pull_source_odds)
                end

                push!(pulls, pull)
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

            bin = EventBin(name, source_urns, pulls, actions, source_odds=source_odds)
            push!(bins, bin)
        end
    end

    return (UrnSimulator(urns, bins), num_steps)
end


"""
    read_trajectory_file(filename)

Read a CSV file containing information for each step of a simulation.

# Arguments
- `filename`: name of CSV input file.

# Returns
- `DataFrame`: record of Urns and balls for each step of an simulation.
"""
function read_trajectory_file(filename)
    return DataFrame(CSV.File(filename))
end


"""
    write_trajectory_file(filename, trajectory::DataFrame)

Write a CSV file containing information for each step of a simulation.

# Arguments
- `filename`: name of CSV output file.
- `trajectory::DataFrame`: DataFrame with simulation step data.
"""
function write_trajectory_file(filename, trajectory::DataFrame)
    CSV.write(filename, trajectory)
end
