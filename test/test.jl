# John Eargle (mailto: jeargle at gmail.com)
# 2016-2017
# test

using Urnitol


function test_urn()
    println("***")
    println("*** Urn")
    println("***")

    urn1 = Urn("urnie")
    urn2 = Urn("bert", Dict("black" => 2, "white" => 3))
    urn3 = Urn("sesame", Dict("black" => 20, "white" => 30))

    println(urn1)
    println(urn2)
    println(urn3)
    println()

    println("*** balls")
    balls1 = Dict("black" => 3, "white" => 2)
    balls2 = Dict("black" => 4, "white" => 5)

    println("  balls1: ", balls1)
    println("  balls2: ", balls2)
    println()

    println("*** move_balls")
    move_balls(balls1, balls2)
    println("  balls1: ", balls1)
    println("  balls2: ", balls2)
    println()

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
end

function test_eventbin()
    println("***")
    println("*** EventBin")
    println("***")

    urn1 = Urn("urnie")
    urn2 = Urn("sesame", Dict("black" => 20, "white" => 30))
    ebin1 = EventBin("bin1", Dict("black" => 0), [urn1], [])
    ebin2 = EventBin("bin2", Dict("black" => 0, "white" => 0),
                     [urn2], [("move", urn1, nothing)])


    println("*** pull")
    println("urn2: ", urn2.balls)
    println("ebin2: ", ebin2.balls)
    for i in 1:10
        pull(ebin2)
        println("urn2: ", urn2.balls)
        println("ebin2: ", ebin2.balls)
    end
    println()

    println("*** pull and act")
    println("urn2: ", urn2.balls)
    println("ebin2: ", ebin2.balls)
    println("urn1: ", urn1.balls)
    for i in 1:10
        pull(ebin2)
        act(ebin2)
        println("urn2: ", urn2.balls)
        # println("ebin2: ", ebin2.balls)
        println("urn1: ", urn1.balls)
    end
    println()
end

function test_urnsimulator()
    println("***")
    println("*** UrnSimulator")
    println("***")

    urn1 = Urn("snuffy", Dict("black" => 30, "white" => 30))
    urn2 = Urn("bird", Dict("black" => 0, "white" => 0))
    ebin1 = EventBin("bin3",
                     Dict("black" => 0, "white" => 0),
                     [urn1],
                     [("move", urn2, "black"),
                      ("discard", nothing, "white")])

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    numsteps = 20
    println("urn1: ", urn1.balls)
    println("urn2: ", urn2.balls)
    for i in 1:numsteps
        step_sim(us1)
        println("urn1: ", urn1.balls)
        println("urn2: ", urn2.balls)
    end
end

function main()
    test_urn()
    test_eventbin()
    test_urnsimulator()
end

main()
