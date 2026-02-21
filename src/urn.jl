# John Eargle (mailto: jeargle at gmail.com)
# urnitol.urn

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


@enum PullType pt_pull pt_create

"""
Action to take during the pull phase.
"""
struct Pull
    pull_type::PullType
    source_classes::Array{AbstractString, 1}
    source_odds::Odds
    num_pulls::Int64  # number of pulls

    Pull(pull_type::PullType;
         source_odds=even,
         num_pulls=1) = new(pull_type, [], source_odds, num_pulls)

    Pull(pull_type::PullType,
         source_classes::Array{AbstractString, 1};
         source_odds=even) = new(pull_type, source_classes, source_odds, length(source_classes))
end


"""
    pull_balls(pull::Pull, urn::Urn)

Pull a ball out of an Urn.

# Arguments
- `pull::Pull`: Pull to make from the Urn
- `urn::Urn`: Urn from which to pull a ball

# Returns
- `SortedDict`: chosen balls
"""
function pull_balls(pull::Pull, urn::Urn)
    chosen_balls = SortedDict()
    total_balls = sum(values(urn.balls))

    for i in 1:pull.num_pulls
        if total_balls > 0
            ball_idx = rand(1:total_balls)
            ball_count = 0
            for j in keys(urn.balls)
                ball_count += urn.balls[j]
                if ball_count >= ball_idx
                    urn.balls[j] -= 1
                    total_balls -= 1

                    if haskey(chosen_balls, j)
                        chosen_balls[j] += 1
                    else
                        chosen_balls[j] = 1
                    end

                    break
                end
            end
        end
    end

    return chosen_balls
end
