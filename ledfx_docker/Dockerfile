FROM ghcr.io/astral-sh/uv:python3.12-bookworm@sha256:36e32fef1746d2e82b80f59c0a9a72ba0d96244cb55a80107d7f918c08954454 AS build
# Pin to a specific version of uv

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=0
ARG TARGETARCH
WORKDIR /app
RUN --mount=type=cache,id=apt-cache-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-lib-${TARGETARCH},target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y cmake gcc portaudio19-dev --no-install-recommends
    # && rm -rf /var/lib/apt/lists/*
COPY uv.lock pyproject.toml /app/
RUN --mount=type=cache,id=uv-cache-${TARGETARCH},target=/root/.cache/uv \
    uv sync --no-install-project --no-editable
COPY . /app
RUN --mount=type=cache,id=uv-cache-${TARGETARCH},target=/root/.cache/uv \
    uv sync --no-editable --extra hue

FROM python:3.12-slim AS runner
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy UV_PYTHON_DOWNLOADS=0
ARG TARGETARCH
RUN --mount=type=cache,id=apt-cache-${TARGETARCH},target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=apt-lib-${TARGETARCH},target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y libportaudio2 pulseaudio --no-install-recommends && rm -rf /var/lib/apt/lists/*
ENV HOME="/root"
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PULSE_SERVER="unix:$HOME/.config/pulse/pulseaudio.socket"
ENV PULSE_COOKIE="$HOME/.config/pulse/cookie"
RUN usermod -aG audio,pulse,pulse-access root \
  && chown -R root:root "$HOME"
WORKDIR "$HOME"
COPY ./ledfx_docker/pulse /etc/pulse
COPY --chmod=755 ./ledfx_docker/start.sh $HOME/start.sh
COPY --from=build /app/.venv /app/.venv
ENV IS_RELEASE=True
EXPOSE 8888/tcp
ENTRYPOINT ["/$HOME/start.sh"]
LABEL org.opencontainers.image.source="https://github.com/LedFx/LedFx"
LABEL org.opencontainers.image.description="LedFx makes your LEDs dance to audio"
#build with "docker build -f ledfx_docker/Dockerfile -t ledfx ."
