# John Eargle (mailto: jeargle at gmail.com)
# 2016
# test

using Urnitol

ebin1 = EventBin("bin1")
ebin2 = EventBin("bin2")

prob1 = ProbArray([ebin1, ebin2])
prob2 = ProbArray([ebin1, ebin2, ebin2, ebin2])

ball1 = Ball("black", 2)
ball2 = Ball("white", 3)

urn1 = Urn("urnie")
urn2 = Urn("bert", [ball1, ball2])

println(urn1)
println(urn2)

println("prob1")
for x = 1:10
    println(choose_event(prob1))
end

println("prob2")
for x = 1:10
    println(choose_event(prob2))
end
