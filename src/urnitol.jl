# John Eargle (mailto: jeargle at gmail.com)
# 2016
# Urnitol

module Urnitol

export Ball, Urn

type Ball
    color::String
end

type Urn
    name::String
    balls::Array{Ball, 1}
    Urn(name::String) = new(name, Ball[])
    Urn(name::String, balls) = new(name, balls)
end

end
