# John Eargle (mailto: jeargle at gmail.com)
# test

using urnitol

using DataStructures
using Printf

function test_urn()
    println("\n")
    println("***")
    println("*** Urn")
    println("***")
    println()

    urn1 = Urn("urnie")
    urn2 = Urn("bert", OrderedDict("black" => 2, "white" => 3))
    urn3 = Urn("sesame", OrderedDict("black" => 20, "white" => 30))

    println(urn1)
    println(urn2)
    println(urn3)
    println()

    println("*** balls")
    balls1 = OrderedDict("black" => 3, "white" => 2)
    balls2 = OrderedDict("black" => 4, "white" => 5)

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
    println("\n")
    println("***")
    println("*** EventBin")
    println("***")
    println()

    urn1 = Urn("urnie")
    urn2 = Urn("sesame", OrderedDict("black" => 20, "white" => 30))
    ebin1 = EventBin("bin1", OrderedDict("black" => 0), [urn1], [])
    ebin2 = EventBin("bin2", OrderedDict("black" => 0, "white" => 0),
                     [urn2], [("move", urn1, nothing)])


    println("*** pull")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    for i in 1:10
        pull(ebin2)
        @printf "%s\n" repr(urn2)
        println("ebin2: ", ebin2.balls)
    end
    println()

    println("*** pull and act")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    @printf "%s\n" repr(urn1)
    for i in 1:10
        pull(ebin2)
        act(ebin2)
        @printf "%s\n" repr(urn2)
        # println("ebin2: ", ebin2.balls)
        @printf "%s\n" repr(urn1)
    end
    println()
end

function test_urnsimulator1()
    println("\n")
    println("***")
    println("*** UrnSimulator 1")
    println("***")
    println()

    urn1 = Urn("snuffy", OrderedDict("black" => 30, "white" => 30))
    urn2 = Urn("bird", OrderedDict("black" => 0, "white" => 0))
    ebin1 = EventBin("bin3",
                     OrderedDict("black" => 0, "white" => 0),
                     [urn1],
                     [("move", urn2, "black"),
                      ("discard", nothing, "white")])

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    numsteps = 20
    @printf "%s\n" repr(us1)
    for i in 1:numsteps
        step_sim(us1)
        @printf "%s\n" repr(us1)
    end
end

function test_urnsimulator2()
    println("\n")
    println("*** UrnSimulator 2")
    println("***")
    println()

    urn1 = Urn("snuffy", OrderedDict("black" => 10, "white" => 0))
    urn2 = Urn("bird", OrderedDict("black" =>0, "white" => 10))
    ebin1 = EventBin("bin1",
                     OrderedDict("black" => 0, "white" => 0),
                     [urn1, urn2],
                     [("move", urn1, "white"),
                      ("move", urn2, "black")])

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    numsteps = 30
    @printf "%s\n" repr(us1)
    for i in 1:numsteps
        step_sim(us1)
        @printf "%s\n" repr(us1)
    end
end


function main()
    test_urn()
    test_eventbin()
    test_urnsimulator1()
    test_urnsimulator2()
end

main()
