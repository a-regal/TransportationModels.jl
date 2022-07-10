using JuMP, HiGHS

function p_median(p::Int, d::Array{Float64,1}, c::Array{Float64,2})
    model = Model(HiGHS.Optimizer);
    
    I, J = size(c);
    
    @variable(model, 0 <= x[i in 1:I, j in 1:J] <= 1);
    @variable(model, y[i in 1:I], Bin);
    
    @objective(model, Min, sum(sum(d[j]*c[i,j]*x[i,j] for j in 1:J) for i in 1:I));
    
    @constraint(model, [j in 1:J], sum(x[i,j] for i in 1:I) == 1);
    @constraint(model, [i in 1:I, j in 1:J], x[i,j] <= y[i]);
    @constraint(model, sum(y[i] for i in 1:I) == p);
    
    optimize!(model)
    
    x_sol = JuMP.value.(x)
    y_sol = JuMP.value.(y)
    obj = objective_value(model)
    
    return x_sol, y_sol, obj
end

function set_cover(c::Array{Float32,2}, threshold::Int)

    a = convert(Array{Float32, 2}, transpose(c).<= threshold);
    model = Model(HiGHS.Optimizer);
    
    I, J = size(a);
    
    @variable(model, x[j in 1:J], Bin);
    
    @objective(model, Min, sum(x));
    
    @constraint(model, [i in 1:I], sum(a[i,j] * x[j] for j in 1:J) >= 1);
    
    optimize!(model)
    
    x_sol = JuMP.value.(x)
    obj = objective_value(model)
    
    return x_sol, obj
end
