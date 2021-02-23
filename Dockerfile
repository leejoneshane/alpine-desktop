FROM alpine

# basic system - 202M
RUN apk add --no-cache \
        sudo lxdm s6 setxkbmap udev vino \
        xf86-input-evdev xf86-input-keyboard xf86-input-mouse kbd \
        xfce4 dbus-x11 xinit xorg-server xvfb x11vnc xrdp \
    && xrdp-keygen xrdp auto \ 
    && sed -i '/TerminalServerUsers/d' /etc/xrdp/sesman.ini \
    && sed -i '/TerminalServerAdmins/d' /etc/xrdp/sesman.ini \
    && adduser -D foo \
    && echo "setxkbmap us" >> /home/foo/.xinitrc \
    && echo "exec startxfce4" >> /home/foo/.xinitrc \
    && chown foo:foo /home/foo/.xinitrc \
    && echo foo:bar | chpasswd \
    && echo 'foo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# add noVNC - 98M
RUN apk add --no-cache git procps python3 py3-numpy \
    && git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC \
    && git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify \
    && cp /root/noVNC/vnc.html /root/noVNC/index.html \
    && rm -rf /root/noVNC/.git \
    && rm -rf /root/noVNC/utils/websockify/.git \
    && apk del git

# add some packages - 316M
RUN echo @edge https://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories \ 
    && apk add --no-cache --force-broken-world \
        faenza-icon-theme xfce4-clipman-plugin xfce4-screenshooter xfce4-notifyd pulseaudio pavucontrol \
        wqy-zenhei@edge xfce4-pulseaudio-plugin@edge xfce4-statusnotifier-plugin@edge \
        firefox

USER root
COPY etc/ /etc/
EXPOSE 80 5900 3389
CMD ["s6-svscan", "/etc/s6"]