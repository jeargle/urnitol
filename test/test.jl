# John Eargle (mailto: jeargle at gmail.com)
# test
#
# To build sysimage boom.so from uveldt/test:
#   using PackageCompiler
#   create_sysimage([:CSVFiles, :DataFrames, :DataStructures, :Printf, :YAML], sysimage_path="../boom.so", precompile_execution_file="so_builder.jl")
#
# To run from uveldt/test:
#   julia --project=.. -J../boom.so test.jl


using urnitol

using DataStructures
using Printf

function print_test_header(title)
    println("\n")
    println("***")
    println("*** ", title)
    println("***")
    println()
end

function test_urn()
    print_test_header("Urn")

    urn1 = Urn("urnie")
    urn2 = Urn("bert", SortedDict("black" => 2, "white" => 3))
    urn3 = Urn("sesame", SortedDict("black" => 20, "white" => 30))

    println(urn1)
    println(urn2)
    println(urn3)
    println()

    println("*** balls")
    balls1 = SortedDict("black" => 3, "white" => 2)
    balls2 = SortedDict("black" => 4, "white" => 5)

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
    print_test_header("EventBin")

    urn1 = Urn("urnie", SortedDict("black" => 0, "white" => 0))
    urn2 = Urn("sesame", SortedDict("black" => 20, "white" => 30))
    ebin1 = EventBin("bin1", [urn1], [])
    ebin2 = EventBin("bin2", [urn2], [Action("move", [urn1], "", nothing)])

    println("*** pull")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    for i in 1:10
        urn = select_urn(ebin2.urns, even)
        pull(ebin2, urn)
        @printf "%s\n" repr(urn2)
        println("ebin2: ", ebin2.balls)
    end
    println()

    println("*** pull and act")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    @printf "%s\n" repr(urn1)
    for i in 1:10
        urn = select_urn(ebin2.urns, even)
        pull(ebin2, urn)
        act(ebin2, urn)
        @printf "%s\n" repr(urn2)
        # println("ebin2: ", ebin2.balls)
        @printf "%s\n" repr(urn1)
    end
    println()
end

function test_urnsimulator1()
    print_test_header("UrnSimulator 1")

    urn1 = Urn("snuffy", SortedDict("black" => 30, "white" => 30))
    urn2 = Urn("bird", SortedDict("black" => 0, "white" => 0))
    ebin1 = EventBin("bin3",
                     [urn1, urn2],
                     [Action("move", [urn2], "", "black"),
                      Action("discard", Array{Urn, 1}(), "", "white")],
                     proportional)

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    num_steps = 20
    @printf "%s\n" repr(us1)
    for i in 1:num_steps
        step_sim(us1)
        @printf "%s\n" repr(us1)
    end
end

function test_urnsimulator2()
    print_test_header("UrnSimulator 2")

    urn1 = Urn("snuffy", SortedDict("black" => 10, "white" => 0))
    urn2 = Urn("bird", SortedDict("black" =>0, "white" => 10))
    ebin1 = EventBin("bin1",
                     [urn1, urn2],
                     [Action("move", [urn1], "", "white"),
                      Action("move", [urn2], "", "black")])

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    num_steps = 30
    run_sim(us1, num_steps)
end

function test_urnsimulator3()
    print_test_header("UrnSimulator 3")

    sim, num_steps = setup_sim("urns1.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end

function test_urnsimulator4()
    print_test_header("UrnSimulator 4")

    sim, num_steps = setup_sim("urns2.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end

function test_urnsimulator5()
    print_test_header("UrnSimulator 5")

    sim, num_steps = setup_sim("urns3.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end

function test_urnsimulator6()
    print_test_header("UrnSimulator 6")

    sim, num_steps = setup_sim("urns4.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end

function test_ehrenfest()
    print_test_header("Ehrenfest")

    sim, num_steps = setup_sim("ehrenfest.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end

function main()
    test_urn()
    test_eventbin()
    test_urnsimulator1()
    test_urnsimulator2()
    test_urnsimulator3()
    test_urnsimulator4()
    test_urnsimulator5()
    test_urnsimulator6()
    test_ehrenfest()
end

main()
