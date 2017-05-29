# John Eargle (mailto: jeargle at gmail.com)
# 2016-2017
# test

using Urnitol


urn1 = Urn("urnie")
urn2 = Urn("bert", Dict("black" => 2, "white" => 3))
urn3 = Urn("sesame", Dict("black" => 20, "white" => 30))

println("*** urns")
println(urn1)
println(urn2)
println(urn3)
println()

balls1 = Dict("black" => 3, "white" => 2)
balls2 = Dict("black" => 4, "white" => 5)

println("*** balls")
println("  balls1: ", balls1)
println("  balls2: ", balls2)
println()

move_balls(balls1, balls2)
println("*** move_balls")
println("  balls1: ", balls1)
println("  balls2: ", balls2)
println()

ebin1 = EventBin("bin1", Dict("black" => 0), [urn1], [])
ebin2 = EventBin("bin2", Dict("black" => 0, "white" => 0), [urn3], [("move", urn1, nothing)])

# prob1 = ProbArray([ebin1, ebin2])
# prob2 = ProbArray([ebin1, ebin2, ebin2, ebin2])

# println("*** prob1")
# for x = 1:10
#     println(choose_event(prob1))
# end

# println("*** prob2")
# for x = 1:10
#     println(choose_event(prob2))
# end
# println()

println("*** choose 3 balls")
println(urn2)
ball = pull_ball(urn2)
println(ball)
ball = pull_ball(urn2)
println(ball)
ball = pull_ball(urn2)
println(ball)
println(urn2)
println()

println("*** pull")
println("urn3: ", urn3.balls)
println("ebin2: ", ebin2.balls)
for i in 1:10
    pull(ebin2)
    println("urn3: ", urn3.balls)
    println("ebin2: ", ebin2.balls)
end
println()

println("*** pull and act")
println("urn3: ", urn3.balls)
println("ebin2: ", ebin2.balls)
println("urn1: ", urn1.balls)
for i in 1:10
    pull(ebin2)
    act(ebin2)
    println("urn3: ", urn3.balls)
    # println("ebin2: ", ebin2.balls)
    println("urn1: ", urn1.balls)
end
println()

