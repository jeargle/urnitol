# John Eargle (mailto: jeargle at gmail.com)
# urnitol.plotting

"""
    plot_trajectory(trajectory)

Create a plot of Urns contents over time.

# Arguments
- `trajectory::DataFrame`: record of Urns and balls for each step of an simulation.

# Returns
- plot object
"""
function plot_trajectory(trajectory::DataFrame)
    column_names = [n for n in names(trajectory) if length(split(n, ".")) == 2]
    x = trajectory.step
    ys = [trajectory[!, Symbol(cn)] for cn in column_names]

    p = plot(x, ys, label=permutedims(column_names), title="Urn contents", xlabel="Step", ylabel="Ball count")

    return p
end
