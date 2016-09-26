# John Eargle (mailto: jeargle at gmail.com)
# 2016
# Urnitol

module Urnitol

export EventBin, ProbArray, Ball, Urn, choose_event


type Ball
    color::AbstractString
    count::Int
end

type Urn
    name::AbstractString
    balls::Array{Ball, 1}
    Urn(name::AbstractString) = new(name, Ball[])
    Urn(name::AbstractString, balls) = new(name, balls)
end

type EventBin
    name::AbstractString
    balls::Array{Tuple{Ball, Urn}, 1}
    EventBin(name::AbstractString) = new(name, Tuple{Ball, Urn}[])
end

type ProbArray
    event_weights::Array{EventBin, 1}
end


function choose_event(prob)
    return rand(prob.event_weights)
end


end
