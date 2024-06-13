FROM hexpm/elixir:1.15.4-erlang-24.3.4.13-debian-bullseye-20230612 AS builder

ENV DB_TYPE=postgresql
ENV DISABLE_MAINNET_SYNC=false
ENV DISABLE_TESTNET_SYNC=true
ENV DISABLE_SEPOLIA_SYNC=true
ENV RPC_API_HOST=http://localhost:9944
ENV TESTNET_RPC_API_HOST=http://localhost:9944
ENV SEPOLIA_RPC_API_HOST=http://localhost:9944
ENV DATABASE_URL=ecto://madaraexplorer_user:madaraexplorerlambda@postgres_container:5432/madaraexplorer_dev
ENV DB_NAME=madaraexplorer_dev
ENV DB_USER=madaraexplorer_user
ENV DB_PASS=madaraexplorerlambda
ENV DB_HOST=localhost
ENV SECRET_KEY_BASE=CSoyxe6b5xblTs9MJQnAochifCsJAsRduNystDUCkAsuSVIYE9heBsplWfkiJdkT
ENV ENABLE_GATEWAY_DATA=true
ENV ENABLE_MAINNET_SYNC=true
ENV ENABLE_TESTNET_SYNC=false
ENV ENABLE_TESTNET2_SYNC=false
ENV PHX_HOST=localhost
ENV MIX_ENV=prod

WORKDIR /explorer
COPY . .

RUN apt update && apt install -y git

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get 
RUN mix assets.deploy
RUN mix phx.digest
RUN mix compile
RUN mix release
RUN mix phx.gen.release

FROM elixir:1.15.4-otp-24

ENV DB_TYPE=postgresql
ENV DISABLE_MAINNET_SYNC=true
ENV DISABLE_TESTNET_SYNC=true
ENV DISABLE_SEPOLIA_SYNC=true
ENV RPC_API_HOST=http://localhost:9944
ENV TESTNET_RPC_API_HOST=http://localhost:9944
ENV SEPOLIA_RPC_API_HOST=http://localhost:9944
ENV DATABASE_URL=ecto://madaraexplorer_user:madaraexplorerlambda@postgres_container:5432/madaraexplorer_dev
ENV DB_NAME=madaraexplorer_dev
ENV DB_USER=madaraexplorer_user
ENV DB_PASS=madaraexplorerlambda
ENV DB_HOST=localhost
ENV SECRET_KEY_BASE=CSoyxe6b5xblTs9MJQnAochifCsJAsRduNystDUCkAsuSVIYE9heBsplWfkiJdkT
ENV ENABLE_GATEWAY_DATA=true
ENV ENABLE_MAINNET_SYNC=false
ENV ENABLE_TESTNET_SYNC=false
ENV ENABLE_TESTNET2_SYNC=false
ENV PHX_HOST=localhost
ENV MIX_ENV=prod

WORKDIR /explorer

COPY --from=builder /explorer/_build/$MIX_ENV/rel/starknet_explorer .

EXPOSE 4000

CMD ["sh", "-c", "/explorer/bin/starknet_explorer eval 'StarknetExplorer.Release.migrate' && /explorer/bin/starknet_explorer start"]
