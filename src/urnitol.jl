# John Eargle (mailto: jeargle at gmail.com)
# urnitol

module urnitol

using CSV
using DataFrames
using DataStructures
using Plots
using Printf
using YAML

# utils
@enum Odds even proportional
export Odds, even, proportional

# Urn
include("urn.jl")
export Urn, Pull
export PullType, pt_pull, pt_create
# export pull_balls

# Event
include("event.jl")
export Action, EventBin, ProbArray
export get_urns, select_urn, move_balls, copy_balls, discard_balls, double_balls
export create, choose_event
# export pull_balls, act

# Simulation
include("simulation.jl")
export UrnSimulator
export pull_balls, act, log_pulls, log_urns, step_sim, run_sim, setup_sim
export read_trajectory_file, write_trajectory_file

# Plotting
include("plotting.jl")
export plot_trajectory

end
