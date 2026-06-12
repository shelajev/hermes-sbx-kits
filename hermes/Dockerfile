FROM docker/sandbox-templates:shell-docker

ARG HERMES_VERSION=latest
ARG HERMES_EXTRAS=anthropic,cli,mcp,web

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      ffmpeg \
      git \
      openssh-client \
      procps && \
    rm -rf /var/lib/apt/lists/*

USER agent
ENV HERMES_HOME=/home/agent/.hermes
ENV PATH=/home/agent/.local/bin:${PATH}
ENV UV_LINK_MODE=copy
ENV UV_NO_CONFIG=1
ENV PYTHONUNBUFFERED=1

COPY --chown=agent:agent scripts/install-hermes.sh /tmp/install-hermes.sh
RUN HERMES_VERSION="${HERMES_VERSION}" \
    HERMES_EXTRAS="${HERMES_EXTRAS}" \
    /tmp/install-hermes.sh && \
    rm -f /tmp/install-hermes.sh

WORKDIR /workspace
CMD ["hermes"]
