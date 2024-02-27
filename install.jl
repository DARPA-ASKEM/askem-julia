#!/usr/bin/env -S julia --threads=4 --startup=no --color yes
NEEDED_VERSION = v"1.10"
if VERSION < NEEDED_VERSION
    throw("Currently running Julia $VERSION but the ASKEM environment requires $NEEDED_VERSION")
end

import Pkg
Pkg.Registry.add(Pkg.RegistrySpec(url="https://github.com/mimiframework/MimiRegistry.git"))
Pkg.activate(".")
Pkg.instantiate()

target = !(length(ARGS) == 0) ? lowercase(ARGS[1]) : "local"

env_dir = 
  if target == "local"
    env_dir = homedir() * "/.julia/environments/askem/"
    if !isdir(env_dir)
        mkpath(env_dir)
    else
        @warn "An ASKEM environment is already installed.\n Would you like to overwrite your current ASKEM environment? [yes/no]"
        if lowercase(readline()) != "yes"
            @info "Canceling install..."
            exit()
        end
        @warn "Overwriting ASKEM environment...."
    end
    cp("Project.toml", env_dir * "Project.toml"; force=true) 
    cp("Manifest.toml", env_dir * "Manifest.toml"; force=true) 
    env_dir
  else
    "/"
end


Pkg.activate(env_dir)
Pkg.instantiate()
Pkg.precompile()

import PrecompileTools: @compile_workload, @recompile_invalidations
@recompile_invalidations begin 
    using Decapodes
end

@compile_workload begin
    include("./precompile.jl")
end


if target == "local"
    @info """
        Run either
        ```
        julia # enter the Julia Repl
        julia> ] activate @askem
        ```
        or
        ```
        julia --project="@askem" --startup=no --color yes
        ```
    """
end
