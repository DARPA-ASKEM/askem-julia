#!/usr/bin/env -S julia --threads=4 --startup=no --color yes
EXCLUDED_FROM_LOCAL = ["Oceananigans", "libevent_jll", "OpenSSL_jll","PMIx_jll", "prrte_jll"]

NEEDED_VERSION = v"1.10"
if VERSION < NEEDED_VERSION
    throw("Currently running Julia $VERSION but the ASKEM environment requires $NEEDED_VERSION")
end

import Pkg
Pkg.activate(".")
Pkg.instantiate()

import PackageCompiler 

target = !(length(ARGS) == 0) ? lowercase(ARGS[1]) : "local"
cpu_target = target == "local" ? "native" : "generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)"

sysimage_dir = "/"
env_dir = if target == "local"
    env_dir = homedir() * "/.julia/environments/askem/"
    sysimage_dir = env_dir
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
    Pkg.activate(env_dir)
    env_dir
end

status_buffer = IOBuffer()
Pkg.status(io=status_buffer); seekstart(status_buffer)
pkg_pattern = r"] (\S+) "
package_names = [
    string(match(pkg_pattern, line)[1]) 
    for line in eachline(status_buffer) 
    if match(pkg_pattern, line) !== nothing
]
if target == "local"
    local_only = EXCLUDED_FROM_LOCAL |> filter ∘ !in
    original_size = length(package_names)
    package_names = local_only(package_names)
    new_size = length(package_names)
    @info "Excluding $(original_size - new_size) packages"
end

@info "Compiling for cpu_target=$cpu_target"

PackageCompiler.create_sysimage(package_names; precompile_execution_file="precompile.jl", sysimage_path=sysimage_dir*"ASKEM-Sysimage.so", cpu_target=cpu_target)
if target == "local"
    @info """
        To use the basic (slower) mode, simply run:
        ```
        julia # enter the Julia Repl
        julia> ] activate @askem
        ```
    
        If you wish to start using the sysimage (optimized/faster) mode:
        ```
        julia --project="@askem" --startup=no --color yes -J$(env_dir)ASKEM-Sysimage.so
        ```
    """
end
