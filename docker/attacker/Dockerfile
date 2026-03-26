FROM debian:bookworm

RUN apt update && apt install -y \
    nmap \
    gobuster \
    ffuf \
    netcat-openbsd \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    tmux \
    vim \
    build-essential \
    gdb \
    john \
    hydra \
    hashcat \
    sqlmap \
    dnsutils \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]