using JuMP, HiGHS

function two_index_vehicle_flow_cvrp(cost::Array{Float64,2}, demand::Array{Int,1}, capacity::Int; K=1, solver_options=Dict("presolve"=>"on"))

        m = Model(HiGHS.Optimizer)

        for (option, value) in solver_options
            set_optimizer_attribute(m, option, value)
        end

        I,J = size(cost);

        @variable(m, x[i in 1:I, j in 1:J], Bin)
        @variable(m, demand[i] ≤ u[i in 2:I] ≤ capacity)

        @objective(m, Min, sum(sum(cost[i,j]*x[i,j] for i in 1:I) for j in 1:J))

        #Clients can only be visited once
        @constraint(m, [j in 2:J], sum(x[i,j] for i in 1:I) == 1)
        @constraint(m, [i in 2:I], sum(x[i,j] for j in 1:J) == 1)
        
        #Number of vehicles leaving depot == number of vehicles arriving at depot
        @constraint(m, sum(x[i,1] for i in 2:I) == K)
        @constraint(m, sum(x[1,j] for j in 2:J) == K)
        
        #MTZ constraints
        for i in 2:I, j in 2:I
            if i ≂̸ j && demand[i] + demand[j] ≤ capacity
                @constraint(m, u[i] - u[j] + capacity * (x[i,j]) ≤ capacity - demand[j])
            end
        end

        optimize!(m)

        x_sol = JuMP.value.(x)
        u_sol = JuMP.value.(u)

        return x_sol, u_sol
end

function three_index_vehicle_flow_cvrp(cost::Array{Float64,2}, demand::Array{Int,1}, capacity::Int; K=1, solver_options=Dict("presolve"=>"on"))

    m = Model(HiGHS.Optimizer)

    for (option, value) in solver_options
        set_optimizer_attribute(m, option, value)
    end

    I,J = size(cost);

    #Add optimization variables for all edges and vehicles
    @variable(m, x[i in 1:I, j in 1:J, k in 1:K], Bin)
    @variable(m, y[i in 1:I, k in 1:K], Bin)
    @variable(m, demand[i] ≤ u[i in 2:I, k in 1:K] ≤ capacity)

    @objective(m, Min, sum(sum(c[i,j] * sum(x[i,j,k] for k in 1:K) for j in 1:J) for i in 1:I))

    @constraint(m, [i in 2:I], sum(y[i,k] for k in 1:K) == K)
    @constraint(m, sum(y[1,k] for k in 1:K) == K)

    @constraint(m, [i in 1:I, k in 1:K], sum(x[i,j,k] for j in 1:J) == y[i,k])
    @constraint(m, [i in 1:I, k in 1:K], sum(x[j,i,k] for j in 1:J) == y[i,k])

    @constraint(m, [k in 1:K], sum(demand[i] * y[i,k] for i in 1:I) ≤ C)

    #MTZ constraints
    for i in 2:I, j in 2:I, k in 1:K
        if i ≂̸ j && demand[i] + demand[j] ≤ capacity
            @constraint(m, u[i,k] - u[j,k] + capacity * (x[i,j,k]) ≤ capacity - demand[j])
        end
    end
    
    optimize!(m)

    x_sol = JuMP.value.(x)
    y_sol = JuMP.value.(y)
    u_sol = JuMP.value.(u)

    return x_sol, y_sol, u_sol

end

function commodity_flow_vrp(cost::Array{Float64,2}, demand::Array{Int,1}, capacity::Int; K=1, solver_options=Dict("presolve"=>"on"))

    m = Model(HiGHS.Optimizer)

    for (option, value) in solver_options
        set_optimizer_attribute(m, option, value)
    end

    #Add the copy of the depot node
    cost = [cost; cost[1,:]]

    #I and J consider the extended graph with n+1 nodes
    I,J = size(cost);

    #Optimization variables
    @variable(m, x[i in 1:I, j in 1:J], Bin)
    @variable(m, y[i in 1:I, j in 1:J] ≥ 0)

    #Objective function
    @objective(m, Min, sum(sum(c[i,j] * x[i,j] for j in 1:J) for i in 1:I))

    @constraint(m, [i in 2:I-1], sum(y[j,i] - y[i,j] for j in 1:J) == 2*demand[i])

    @constraint(m, sum(y[1,j] for j in 2:J-1) == sum(d[2:J-1]))
    @constraint(m, sum(y[j,1] for j in 2:J-1) == K*capacity - sum(d[2:J-1]))
    @constraint(m, sum(y[I,j] for j in 2:J-1) == K*capacity)
    @constraint(m, [i in 1:I, j in 1:J], y[i,j] + y[j,i] == capacity * x[i,j])

    @constraint(m, [i in 2:I-1], sum(x[i,j] + x[j,i] for j in 1:J) == 2)

    optimize!(m)

    x_sol = JuMP.value.(x)
    y_sol = JuMP.value.(y)

    return x_sol, y_sol

end
