# John Eargle (mailto: jeargle at gmail.com)
# 2016
# test

using Urnitol

ball1 = Ball("black", 2)
ball2 = Ball("white", 3)

urn1 = Urn("urnie")
urn2 = Urn("bert", [ball1, ball2])

println(urn1)
println(urn2)
