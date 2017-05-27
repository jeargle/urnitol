# John Eargle (mailto: jeargle at gmail.com)
# 2016-2017
# test

using Urnitol

ebin1 = EventBin("bin1", Dict("black" => 0))
ebin2 = EventBin("bin2", Dict("white" => 0))

prob1 = ProbArray([ebin1, ebin2])
prob2 = ProbArray([ebin1, ebin2, ebin2, ebin2])

urn1 = Urn("urnie")
urn2 = Urn("bert", Dict("black" => 2, "white" => 3))

println(urn1)
println(urn2)

println("*** prob1")
for x = 1:10
    println(choose_event(prob1))
end

println("*** prob2")
for x = 1:10
    println(choose_event(prob2))
end

println("*** choose 3 balls")
println(urn2)
ball = pull_ball(urn2)
println(ball)
ball = pull_ball(urn2)
println(ball)
ball = pull_ball(urn2)
println(ball)
println(urn2)
