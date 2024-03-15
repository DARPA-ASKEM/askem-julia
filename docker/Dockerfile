FROM julia:1.10

RUN apt update && \
    apt install -y clang jupyter libevent-core-2.1-7 libevent-pthreads-2.1-7 && \
    apt clean -y

ENV JULIA_DEPOT_PATH=/usr/local/julia
ENV JULIA_PROJECT=/
ENV JULIA_CPU_TARGET="native;tigerlake"

WORKDIR /
COPY Project.toml Manifest.toml install.jl precompile.jl .
RUN ./install.jl docker && \
    julia -e 'using Pkg; using IJulia; IJulia.installkernel("Julia ASKEM"; julia=`julia --project=/ --threads=4`)'
RUN julia --project=/ -e 'using Decapodes' # Force no precompile

EXPOSE 8888
EXPOSE 1234

# CMD julia --threads=4 -e 'using Pkg; Pkg.activate("/"); using Pluto; Pluto.run(;host="0.0.0.0", port=1234, launch_browser=true)'
CMD jupyter notebook --ip 0.0.0.0 --allow-root --no-browser
