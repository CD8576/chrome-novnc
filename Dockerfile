
FROM alpine:3.19.1

LABEL AboutImage "Alpine_Chromium_NoVNC"

LABEL Maintainer "Apurv Vyavahare <apurvvyavahare@gmail.com>"

#VNC Server Password
ENV	VNC_PASS="CHANGE_IT" \
#VNC Server Title(w/o spaces)
	VNC_TITLE="Chromium" \
#VNC Resolution(720p is preferable)
	VNC_RESOLUTION="1280x720" \
#VNC Shared Mode
	VNC_SHARED=true \
#Local Display Server Port
	DISPLAY=:0 \
#NoVNC Port
	NOVNC_PORT=$PORT \
	PORT=8080 \
#Heroku No-Sleep Mode
	NO_SLEEP=false \
#Locale
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US.UTF-8 \
	LC_ALL=C.UTF-8 \
	TZ="Asia/Kolkata"
#program:VNC
command=bash -c 'sed -i "s/\$DESKTOP/$VNC_TITLE/g" /opt/novnc/index.html && if [ "$VNC_SHARED" = "false" ]; then x11vnc -storepasswd $VNC_PASS /config/.xpass && x11vnc -usepw -rfbport 5900 -rfbauth /config/.xpass -geometry $VNC_RESOLUTION -forever -alwaysshared -permitfiletransfer -noxrecord -noxfixes -noxdamage -dpms -bg -desktop $VNC_TITLE; else x11vnc -storepasswd $VNC_PASS /config/.xpass && x11vnc -usepw -rfbport 5900 -rfbauth /config/.xpass -geometry $VNC_RESOLUTION -forever -shared -alwaysshared -permitfiletransfer -bg -desktop $VNC_TITLE; fi' /
startsecs=0 /
autorestart=unexpected /
stderr_logfile=/var/log/x11vnc.stderr.log /
priority=3 /


COPY assets/ /

RUN	apk update && \
	apk add --no-cache tzdata ca-certificates supervisor curl wget openssl bash python3 py3-requests sed unzip xvfb x11vnc websockify openbox chromium nss alsa-lib font-noto font-noto-cjk && \
# noVNC SSL certificate
	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key -out /etc/ssl/novnc.cert > /dev/null 2>&1 && \
# TimeZone
	cp /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
# Wipe Temp Files
	apk del build-base curl wget unzip tzdata openssl && \
	rm -rf /var/cache/apk/* /tmp/*
ENTRYPOINT ["supervisord", "-l", "/var/log/supervisord.log", "-c"]

CMD ["/config/supervisord.conf"]
