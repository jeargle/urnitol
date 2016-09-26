# John Eargle (mailto: jeargle at gmail.com)
# 2016
# Urnitol

module Urnitol

export Ball, Urn

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

end
