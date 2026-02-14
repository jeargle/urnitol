# John Eargle (mailto: jeargle at gmail.com)
# test
#
# To run from uveldt/test:
#   julia --project=.. -J ../boom.so test.jl


using DataStructures
using Plots
using Printf
using Test

using urnitol


function print_test_header(title)
    println("\n")
    println("***")
    println("*** ", title)
    println("***")
    println()
end

function test_urn()
    print_test_header("Urn")

    println("*** balls")
    balls1 = SortedDict("black" => 3, "white" => 2)
    balls2 = SortedDict("black" => 4, "white" => 5)

    println("  balls1: ", balls1)
    @test balls1["black"] == 3
    @test balls1["white"] == 2
    println("  balls2: ", balls2)
    @test balls2["black"] == 4
    @test balls2["white"] == 5
    println()

    println("*** move_balls")
    move_balls(balls1, balls2)
    println("  balls1: ", balls1)
    @test balls1["black"] == 0
    @test balls1["white"] == 0
    println("  balls2: ", balls2)
    @test balls2["black"] == 7
    @test balls2["white"] == 7
    println()

    println("*** Urns")
    urn1 = Urn("urnie")
    urn2 = Urn("bert", SortedDict("black" => 2, "white" => 3))
    urn3 = Urn("sesame", SortedDict("black" => 20, "white" => 30))

    println(urn1)
    @test urn1.name == "urnie"
    @test length(urn1.balls) == 0
    println(urn2)
    @test urn2.name == "bert"
    @test urn2.balls["black"] == 2
    @test urn2.balls["white"] == 3
    println(urn3)
    @test urn3.name == "sesame"
    @test urn3.balls["black"] == 20
    @test urn3.balls["white"] == 30
    println()
end

function test_pull()
    print_test_header("Pull")

    println("*** Urns")
    urn1 = Urn("bert", SortedDict("black" => 2, "white" => 3))
    urn2 = Urn("sesame", SortedDict("black" => 20, "white" => 30))

    println("*** choose 3 balls")
    pull1 = Pull("pull", [urn1])
    println(urn1)
    ball = pull_balls(pull1, urn1)
    println(ball)
    ball = pull_balls(pull1, urn1)
    println(ball)
    ball = pull_balls(pull1, urn1)
    println(ball)
    println(urn1)
    @test sum(values(urn1.balls)) == 2
    println()

    println("*** choose 3x3 balls")
    pull2 = Pull("pull", [urn2], num_pulls=3)
    println(pull2)
    balls = pull_balls(pull2, urn2)
    println(balls)
    @test sum(values(balls)) == 3
    balls = pull_balls(pull2, urn2)
    println(balls)
    @test sum(values(balls)) == 3
    balls = pull_balls(pull2, urn2)
    println(balls)
    @test sum(values(balls)) == 3
    println(urn2)
    @test sum(values(urn2.balls)) == 41
    println()
end

function test_eventbin()
    print_test_header("EventBin")

    urn1 = Urn("urnie", SortedDict("black" => 0, "white" => 0))
    urn2 = Urn("sesame", SortedDict("black" => 20, "white" => 30))

    println("*** EventBins")
    ebin1 = EventBin("bin1", [urn1], [], [])
    ebin2 = EventBin("bin2", [urn2], [Pull("pull", [urn2])], [Action("move", [urn1], "", nothing)])

    @test ebin1.name == "bin1"
    @test ebin2.name == "bin2"

    println("*** pull")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    @test sum(values(ebin2.urns[1].balls)) == 50
    for i in 1:10
        urn = select_urn(ebin2.urns, even)
        pull_balls(ebin2, ebin2.pulls[1], urn)
        @printf "%s\n" repr(urn2)
        println("ebin2: ", ebin2.balls)
    end
    @test sum(values(ebin2.urns[1].balls)) == 40
    println()

    println("*** pull and act")
    @printf "%s\n" repr(urn2)
    println("ebin2: ", ebin2.balls)
    @printf "%s\n" repr(urn1)
    @test sum(values(ebin1.urns[1].balls)) == 0
    # First Action here will move all 10 balls in ebin2 into ebin1.
    for i in 1:10
        urn = select_urn(ebin2.urns, even)
        pull_balls(ebin2, ebin2.pulls[1], urn)
        act(ebin2, urn)
        @printf "%s\n" repr(urn2)
        # println("ebin2: ", ebin2.balls)
        @printf "%s\n" repr(urn1)
    end
    @test sum(values(ebin1.urns[1].balls)) == 20
    @test sum(values(ebin2.urns[1].balls)) == 30
    println()
end

function test_urnsimulator1()
    print_test_header("UrnSimulator 1")

    urn1 = Urn("snuffy", SortedDict("black" => 30, "white" => 30))
    urn2 = Urn("bird", SortedDict("black" => 0, "white" => 0))
    ebin1 = EventBin("bin3",
                     [urn1, urn2],
                     [Pull("pull", [urn1, urn2])],
                     [Action("move", [urn2], "", "black"),
                      Action("discard", Array{Urn, 1}(), "", "white")],
                     source_odds=proportional)

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    num_steps = 20
    @printf "%s\n" repr(us1)
    @test us1.urns[1] == urn1
    @test us1.urns[2] == urn2
    @test us1.events[1] == ebin1
    @test us1.step_count == 0
    @test us1.ball_classes == Set(["black", "white"])

    for i in 1:num_steps
        step_sim(us1)
        @printf "%s\n" repr(us1)
    end
    @test us1.step_count == 20
    @test us1.ball_classes == Set(["black", "white"])
    @test 10 <= urn1.balls["black"] <= 30
    @test 10 <= urn1.balls["white"] <= 30
    @test 0 <= urn2.balls["black"] <= 20
    @test urn2.balls["white"] == 0
    @test urn1.balls["black"] + urn2.balls["black"] == 30
end

function test_urnsimulator2()
    print_test_header("UrnSimulator 2")

    urn1 = Urn("snuffy", SortedDict("black" => 10, "white" => 0))
    urn2 = Urn("bird", SortedDict("black" => 0, "white" => 10))
    ebin1 = EventBin("bin1",
                     [urn1, urn2],
                     [Pull("pull", "all")],
                     [Action("move", [urn1], "", "white"),
                      Action("move", [urn2], "", "black")])

    us1 = UrnSimulator([urn1, urn2], [ebin1])
    @test us1.step_count == 0

    num_steps = 30
    run_sim(us1, num_steps)
    @test us1.step_count == 30
    @test urn1.balls["black"] + urn2.balls["black"] == 10
    @test urn1.balls["white"] + urn2.balls["white"] == 10
end

# Similar to test_urnsimulator1().
function test_urnsimulator3()
    print_test_header("UrnSimulator 3")

    sim, num_steps = setup_sim("urns/urns1.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    @test sim.ball_classes == Set(["black", "white"])
    @test sim.step_count == 0

    run_sim(sim, num_steps)
    write_trajectory_file("urns1.csv", sim.trajectory)
    @test sim.step_count == 20
    @test 10 <= sim.urns[1].balls["black"] <= 30
    @test 10 <= sim.urns[1].balls["white"] <= 30
    @test 0 <= sim.urns[2].balls["black"] <= 20
    @test sim.urns[2].balls["white"] == 0
    @test sim.urns[1].balls["black"] + sim.urns[2].balls["black"] == 30
end

function test_urnsimulator4()
    print_test_header("UrnSimulator 4")

    sim, num_steps = setup_sim("urns/urns2.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    @test sim.ball_classes == Set(["black", "white"])
    @test sim.step_count == 0

    run_sim(sim, num_steps)
    write_trajectory_file("urns2.csv", sim.trajectory)
    @test sim.step_count == 100
    @test sim.urns[1].balls["black"] <= 22
    @test sim.urns[1].balls["white"] <= 7
end

function test_urnsimulator5()
    print_test_header("UrnSimulator 5")

    sim, num_steps = setup_sim("urns/urns3.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    @test sim.ball_classes == Set(["black", "white"])
    @test sim.step_count == 0

    run_sim(sim, num_steps)
    write_trajectory_file("urns3.csv", sim.trajectory)
    @test sim.step_count == 150
    @test 0 <= sim.urns[1].balls["black"] <= 30
    @test 0 <= sim.urns[1].balls["white"] <= 30
    @test 0 <= sim.urns[2].balls["black"] <= 30
    @test 0 <= sim.urns[2].balls["white"] <= 30
    @test sim.urns[1].balls["black"] + sim.urns[2].balls["black"] == 30
    @test sim.urns[1].balls["white"] + sim.urns[2].balls["white"] == 30
end

function test_urnsimulator6()
    print_test_header("UrnSimulator 6")

    sim, num_steps = setup_sim("urns/urns4.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    @test sim.ball_classes == Set(["black", "white"])
    @test sim.step_count == 0

    run_sim(sim, num_steps)
    write_trajectory_file("urns4.csv", sim.trajectory)
    @test sim.step_count == 20
    @test 10 <= sim.urns[1].balls["black"] <= 30
    @test 10 <= sim.urns[1].balls["white"] <= 40
    @test 0 <= sim.urns[2].balls["black"] <= 20
    @test 0 <= sim.urns[2].balls["white"] <= 40
    @test sim.urns[1].balls["black"] + sim.urns[2].balls["black"] == 30
    @test 30 <= sim.urns[1].balls["white"] + sim.urns[2].balls["white"] <= 50
end

function test_ehrenfest()
    print_test_header("Ehrenfest")

    sim, num_steps = setup_sim("urns/ehrenfest.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    @test sim.ball_classes == Set(["white"])
    @test sim.step_count == 0

    run_sim(sim, num_steps)
    write_trajectory_file("ehrenfest.csv", sim.trajectory)
    @test sim.step_count == 100
    @test sim.urns[1].balls["white"] + sim.urns[2].balls["white"] == 30
end

function test_plot_trajectory1()
    print_test_header("Plot trajectory 1")

    sim, num_steps = setup_sim("urns/urns3.yml")
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
    p = plot_trajectory(sim.trajectory)
    @test p[1][:title] == "Urn contents"
    @test isa(p, Plots.Plot)

    savefig(p, "urns3.svg")
    @test isfile("urns3.svg")

    println("all values plotted")
end

function main()
    test_urn()
    test_pull()
    # test_eventbin()
    # test_urnsimulator1()
    # test_urnsimulator2()
    # test_urnsimulator3()
    # test_urnsimulator4()
    # test_urnsimulator5()
    # test_urnsimulator6()
    # test_ehrenfest()
    # test_plot_trajectory1()
end

main()
