#!/usr/local/bin/julia

# John Eargle (mailto: jeargle at gmail.com)
# urnsim

using urnitol

using ArgParse
using DataStructures
using Printf


"""
    simulate(filename)

Simulate a system specified by a config file.

# Arguments
- `filename`: YAML config file
"""
function simulate(filename)
    sim, num_steps = setup_sim(filename)
    @printf "sim: %s\n" repr(sim)
    @printf "num_steps: %d\n" num_steps
    run_sim(sim, num_steps)
end


"""
    main()

Entrypoint for urnitol simulation script.
"""
function main()
    aps = ArgParseSettings()
    @add_arg_table! aps begin
        "configfile"
            help = "YAML system configuration file"
            required = true
    end

    parsed_args = parse_args(ARGS, aps)

    simulate(parsed_args["configfile"])
end

main()
