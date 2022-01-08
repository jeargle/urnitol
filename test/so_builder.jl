# To build sysimage boom.so from uveldt/test:
#   using PackageCompiler
#   create_sysimage([:CSV, :DataFrames, :DataStructures, :Printf, :YAML], sysimage_path="../boom.so", precompile_execution_file="so_builder.jl")

using CSV
using DataFrames
using DataStructures
using Printf
using YAML

df1 = DataFrame(Name=["John", "Bill", "Maria"],
                Age=[43,22,81],
                Salary=[132000, 45000, 60000])

CSV.write("blah.csv", df1)
df2 = DataFrame(CSV.File("blah.csv"))

str1 = "test string"

sdict1 = SortedDict{AbstractString, Int64}()

println()
@printf "PackageCompiler so Builder\n"
@printf "  str1: %s\n" str1


ball_dict1 = SortedDict()
ball_dict2 = SortedDict{AbstractString, Int64}()
setup = YAML.load(open("urns/urns1.yml"))
if haskey(setup, "urns")
    for urn_info in setup["urns"]
        name = urn_info["name"]
        @printf "  urn: %s\n" name
        if haskey(urn_info, "balls")
            for ball_info in urn_info["balls"]
                class = ball_info["class"]
                num = ball_info["num"]
                ball_dict1[class] = num
                ball_dict2[class] = num
                @printf "    balls: %s %d\n" class num
            end
        end
    end
end

@printf "  ball_dict1: %s\n" ball_dict1
@printf "  ball_dict2: %s\n" ball_dict2
