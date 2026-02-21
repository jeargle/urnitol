# John Eargle (mailto: jeargle at gmail.com)
# urnitol.event

"""
Action to take on previously pulled balls.
"""
struct Action
    command::String
    target_urns::Array{Urn, 1}
    target_string::String
    class::Union{String, Nothing}
    target_odds::Odds

    Action(command::String,
           target_urns::Array{Urn, 1},
           target_string::String="",
           class::Union{String, Nothing}=nothing,
           target_odds=even) = new(command, target_urns, target_string, class, target_odds)
end


"""
Temporary holding bin for balls that have been removed from Urns.
"""
struct EventBin
    name::String
    balls::SortedDict{String, Int64}
    source_urns::Array{Urn, 1}
    pulls::Array{Pull, 1}
    actions::Array{Action, 1}
    source_odds::Odds
    classes::Array{String, 1}

    function EventBin(name::String, source_urns, pulls, actions; source_odds=even, classes=[])
        # Normalize ball classes across Urns
        temp_classes = Set{String}()

        for class in classes
            push!(temp_classes, class)
        end

        for urn in source_urns
            for (class, count) in urn.balls
                push!(temp_classes, class)
            end
        end

        balls = SortedDict{String, Int64}()
        for class in temp_classes
            if !(class in keys(balls))
                balls[class] = 0
            end
        end

        new(name, balls, source_urns, pulls, actions, source_odds, classes)
    end
end


"""
    get_urns(action::Action, bin::EventBin, source_urn::Urn)

Fetch an array of Urns from an Action.

# Arguments
- `action::Action`: Action from which Urn list is fetched
- `bin::EventBin`: EventBin with Array of source Urns
- `source_urn::Urn`: Urn from which a ball was pulled

# Returns
- `Array{Urn, 1}`: Array of Urns.
"""
function get_urns(action::Action, bin::EventBin, source_urn::Urn)
    if length(action.target_urns) > 0
        urns = action.target_urns
    elseif action.target_string == "all"
        urns = bin.source_urns
    elseif action.target_string == "source"
        urns = [source_urn]
    elseif action.target_string == "not source"
        urns = [urn for urn in bin.source_urns if urn != source_urn]
    else
        urns = Array{Urn, 1}()
    end

    return urns
end


"""
    select_urn(urns::Array{Urn, 1}, odds::Odds)

Select an Urn from an array of Urns.

# Arguments
- `urns::Array{Urn, 1}`: Array of Urns to choose from.
- `odds::Odds`: Odds to use in selection.

# Returns
- `Union{Urn, Nothing}`: selected Urn or nothing if urns Array is empty.
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
    move_balls(balls1::SortedDict, balls2::SortedDict, class)

Move balls from one collection into another.

# Arguments
- `balls1::SortedDict`: collection of balls to move.
- `balls2::SortedDict`: collection to receive balls.
- `class`: single class of ball to move; nothing uses all classes.
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
    copy_balls(balls1::SortedDict, balls2::SortedDict, class)

Copy balls from one collection into another.

# Arguments
- `balls1::SortedDict`: collection of balls to copy.
- `balls2::SortedDict`: collection to receive balls.
- `class`: single class of ball to move; nothing uses all classes.
"""
function copy_balls(balls1::SortedDict, balls2::SortedDict; class=nothing)
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
    end
end


"""
    discard_balls(balls::SortedDict, discard, class)

Move balls from one collection to a discard bin.

# Arguments
- `balls1::SortedDict`: collection of balls to move.
- `discard`: collection to receive balls.
- `class`: single class of ball to move; nothing uses all classes.
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
    double_balls(balls1::SortedDict, balls2::SortedDict, class)

Double and move balls from one collection into another.

# Arguments
- `balls1::SortedDict`: collection of balls to double.
- `balls2::SortedDict`: collection to receive balls.
- `class`: single class of ball to double; nothing uses all classes.
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
    pull_balls(bin::EventBin, pull::Pull, urn::Urn)

Pull balls from an Urn and move them into an EventBin.
The probability that an Urn is chosen is proportional to the number of
balls in the Urn.

# Arguments
- `bin::EventBin`: EventBin that will pull balls from its Urns.
- `pull::Pull`: Pull to make from the Urn
- `urn::Urn`: Urn that balls are pulled from.
"""
function pull_balls(bin::EventBin, pull::Pull, urn::Urn)
    balls = []

    if pull.pull_type == pt_pull
        balls = pull_balls(pull, urn)
        @printf "    pull %s %s\n" urn.name repr(balls)
    elseif pull.pull_type == pt_create
        balls = create_balls(pull)
        @printf "    create %s\n" repr(balls)
    end

    move_balls(balls, bin.balls)
end


"""
    act(bin::EventBin, source_urn::Urn)

Perform actions on all balls in an EventBin.
Actions are performed in Array order.  Possible actions are: move,
discard, and double.  Actions can be applied to all balls or to
specific classes.  After all actions are performed, there should be
no balls left in the EventBin.

# Arguments
- `bin::EventBin`: EventBin that will perform its actions.
- `source_urn::Urn`: Urn that balls were pulled from.
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
        elseif action.command == "copy"
            if action.class != nothing && bin.balls[action.class] > 0
                @printf "    copy %s %s\n" action.class repr(bin.balls[action.class])
            end
            copy_balls(bin.balls, urn.balls, class=action.class)
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
"""
struct ProbArray
    event_weights::Array{EventBin, 1}
end


"""
    choose_event(prob)

# Arguments
- `prob`: probability distribution
"""
function choose_event(prob)
    return rand(prob.event_weights)
end
