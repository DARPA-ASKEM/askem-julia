import DataFrames
_precomp_df = DataFrames.DataFrame(A=1:2:1000, B=repeat(1:10, inner=50), C=1:500)
first(_precomp_df, 6)

import Decapodes
_precomp_poise = Decapodes.@decapode begin
  P::Form0
  q::Form1
  (R, μ̃ )::Constant

  # Laplacian of q for the viscous effect
  Δq == Δ(q)
  # Gradient of P for the pressure driving force
  ∇P == d(P)

  # Definition of the time derivative of q
  ∂ₜ(q) == q̇

  # The core equation
  q̇ == μ̃  * ∂q(Δq) + ∇P + R * q
end
_precomp_poise = Decapodes.expand_operators(_precomp_poise)

import AlgebraicPetri
_precomp_birth_petri = AlgebraicPetri.Open(AlgebraicPetri.PetriNet(1, 1=>(1,1)));
_precomp_predation_petri = AlgebraicPetri.Open(AlgebraicPetri.PetriNet(2, (1,2)=>(2,2)));
_precomp_death_petri = AlgebraicPetri.Open(AlgebraicPetri.PetriNet(1, 1=>()));
_precomp_lotka_volterra = AlgebraicPetri.@relation (wolves, rabbits) begin
  birth(rabbits)
  predation(rabbits, wolves)
  death(wolves)
end
_precomp_lv_dict = Dict(:birth=>_precomp_birth_petri, :predation=>_precomp_predation_petri, :death=>_precomp_death_petri);
_precomp_lotka_petri = AlgebraicPetri.apex(AlgebraicPetri.oapply(_precomp_lotka_volterra, _precomp_lv_dict))

import OrdinaryDiffEq
_precomp_u0 = [100, 10];
_precomp_p = [.3, .015, .7];
_precomp_prob = OrdinaryDiffEq.ODEProblem(AlgebraicPetri.vectorfield(_precomp_lotka_petri),_precomp_u0,(0.0,100.0),_precomp_p);
_precomp_sol = OrdinaryDiffEq.solve(_precomp_prob,OrdinaryDiffEq.Tsit5(),abstol=1e-8);


import Oceananigans
_precomp_topology = (Oceananigans.Flat, Oceananigans.Flat, Oceananigans.Bounded)
_precomp_grid = Oceananigans.RectilinearGrid(size=128, z=(-0.5, 0.5), topology=_precomp_topology)
_precomp_closure = Oceananigans.ScalarDiffusivity(κ=1)
_precomp_ocean_model = Oceananigans.NonhydrostaticModel(; grid=_precomp_grid, closure=_precomp_closure, tracers=:T)
_precomp_width = 0.1
_precomp_initial_temperature(z) = exp(-z^2 / (2_precomp_width^2))
Oceananigans.set!(_precomp_ocean_model, T=_precomp_initial_temperature)
_precomp_min_Δz = Oceananigans.minimum_zspacing(_precomp_ocean_model.grid)
_precomp_diffusion_time_scale = _precomp_min_Δz^2 / _precomp_ocean_model.closure.κ.T
_precomp_simulation = Oceananigans.Simulation(_precomp_ocean_model, Δt = 0.1 * _precomp_diffusion_time_scale, stop_iteration = 1000)
Oceananigans.run!(_precomp_simulation )


