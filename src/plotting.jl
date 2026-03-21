# John Eargle (mailto: jeargle at gmail.com)
# urnitol.plotting

"""
    plot_trajectory(trajectory; column_names=nothing)

Create a plot of Urns contents over time.

# Arguments
- `trajectory::DataFrame`: record of Urns and balls for each step of an simulation.
- `column_names::Union{Array{String, 1}, Nothing}`: array of column names to plot.

# Returns
- plot object
"""
function plot_trajectory(trajectory::DataFrame; column_names::Union{Array{String, 1}, Nothing}=nothing)
    if column_names == nothing
        column_names = [n for n in names(trajectory) if length(split(n, ".")) == 2]
    else
        # Check for column_names that aren't in trajectory.
        trajectory_column_names = names(trajectory)
        missing_column_names = [cn for cn in column_names if !(cn in trajectory_column_names)]

        if length(missing_column_names) > 0
            # Sum existing columns to create the missing columns.
            sum_column_names = Dict(name => [tcn
                                             for tcn in trajectory_column_names
                                             if occursin(name, tcn)]
                                    for name in missing_column_names)
            sum_column_maps = [[Symbol(sum_column) for sum_column in sum_columns] => ByRow(+) => Symbol(sum_column_name)
                               for (sum_column_name, sum_columns) in sum_column_names
                               if length(sum_columns) > 0]
            select_args = [[trajectory]; propertynames(trajectory); sum_column_maps]
            # Build new DataFrame that includes the missing columns.
            trajectory = select(select_args...)
        end
    end

    x = trajectory.step
    ys = [trajectory[!, Symbol(cn)] for cn in column_names]

    p = plot(x, ys, label=permutedims(column_names), title="Urn contents", xlabel="Step", ylabel="Ball count")

    return p
end
