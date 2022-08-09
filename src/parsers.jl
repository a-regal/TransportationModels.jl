using Distances

include("types/types.jl")

function parse_vrp(fp::String)

    f = open(fp)
    text = readlines(f)
    close(f)

    k = 0
    capacity = 0
    instance_size = 0

    data_parse_flag = false
    parsing_demand = false
    parsing_edge_weights = false
    parsing_coords = false

    coords = []
    demand = []
    cost = []

    for line in text
        if occursin("NAME : ", line)
            k += parse(Int, match(r"k\d+", line).match[2:end])
        elseif occursin("DIMENSION", line)
            instance_size += parse(Int, match(r"\d+", line).match)
        elseif occursin("CAPACITY", line)
            capacity += parse(Int, match(r"\d+", line).match)
        elseif occursin("NODE_COORD_SECTION", line)
            data_parse_flag = true
            parsing_coords = true
            parsing_edge_weights = false
            parsing_demand = false
            continue
        elseif occursin("EDGE_WEIGHT_SECTION", line)
            data_parse_flag = true
            parsing_coords = false
            parsing_edge_weights = true
            parsing_demand = false
            continue
        elseif occursin("DEMAND_SECTION", line)
            data_parse_flag = true
            parsing_coords = false
            parsing_edge_weights = false
            parsing_demand = true
            continue
        elseif occursin("DEPOT_SECTION", line)
            data_parse_flag = false

        elseif occursin("EOF", line)
            break
        end

        if data_parse_flag
            if parsing_coords
                data = parse.(Float64, split(line))
                push!(coords, data)
            elseif parsing_edge_weights
                data = parse.(Float64, split(line))
                push!(cost, data)
            elseif parsing_demand
                data = parse.(Int, split(line))
                push!(demand, data)
            end
        end
    end

    if size(coords)[end] == 0
        println("Sorry not implemented")
    else
        coords = permutedims(hcat(coords...))[:,2:end];
        demand = permutedims(hcat(demand...))[:,2];
        cost = pairwise(Euclidean(), coords, dims=1)

        return CVRPInstance(cost, demand, capacity, k)
    end
end
