# Standard ASKEM Julia Environment
This repo specifies packages developed or used by the ASKEM program. Additionally,
this environment can be installed on a local machine or Docker and provides optional hosting for
IJulia and Pluto.

## Installation
### Local
```
./install.jl
```

### Docker
```
docker build . -f docker/Dockerfile -t askem-julia:latest

```


## Usage

### Local

To use the basic (slower) mode, simply run:
```
julia # enter the Julia Repl
julia> ] activate @askem
```

If you wish to start using the sysimage (optimized/faster) mode:
```
julia --project="@askem" --startup=no --color yes -J{$HOME}/.julia/environments/askem/ASKEM-Sysimage.so
```

### Docker 

```
docker run -p 8888:8888 askem-julia
```

## Changes
Any PR to `main` must change the `version` in `Project.toml`.
If `x.y.z` is our version scheme, then do one of the following
- Increase `x` if you update or remove
- Increase `y` if you add a package
- Increase `z` if there's some other change not related to `Project.toml` or `Manifest.toml`
