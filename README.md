# TransportationModels.jl

Welcome to TransportationModels. This package is a collection of implementations
of common Transportation/Logistics models (aka a Model Zoo), from econometrics to optimization in a 
simplified, tested set of functions. This includes classical models from the literature
such as the Travelling Salesman Problem, P-Median facility location and the Vehicle Routing Problem.

Further expansion into the set of models (as well as the complexity/niche nature of them) will come 
over time. All optimization based models use the [HiGHS solver](https://github.com/jump-dev/HiGHS.jl), the fastest open-source software available.
Features such as custom solvers will be thought of as the project evolves, but in the early stages commercial
dependencies are avoided to satify a broader public.
