FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    i3 \
    dmenu \
    xterm \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    firefox-esr \
    vim \
    tmux \
    fonts-dejavu \
    ca-certificates \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

EXPOSE 6080

CMD bash -c "\
Xvfb :1 -screen 0 1280x800x16 & \
export DISPLAY=:1 && \
i3 & \
x11vnc -display :1 -nopw -listen 0.0.0.0 -xkb -forever -shared & \
websockify --web=/usr/share/novnc/ 6080 localhost:5900"