FROM julia:1.9

RUN apt update && \
    apt install -y clang jupyter libevent-core-2.1-7 libevent-pthreads-2.1-7 && \
    apt clean -y

ENV JULIA_DEPOT_PATH=/usr/local/julia
ENV JULIA_PROJECT=/

WORKDIR /
COPY Project.toml Manifest.toml /
RUN julia -e 'using Pkg; Pkg.instantiate()'
COPY install.jl precompile.jl /
RUN ./install.jl docker && \
    julia -e 'using Pkg; using IJulia; IJulia.installkernel("Julia ASKEM"; julia=`julia --project=/ --threads=4 -J/ASKEM-Sysimage.so`)' && \
    rm -rf /usr/local/julia/compiled

EXPOSE 8888
EXPOSE 1234

# CMD julia -JASKEM-Sysimage.so --threads=4 -e 'using Pkg; Pkg.activate("/"); using Pluto; Pluto.run(;host="0.0.0.0", port=1234, launch_browser=true)'
CMD jupyter notebook --ip 0.0.0.0 --allow-root --no-browser
