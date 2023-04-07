#!/bin/sh

# configs
AUUID=37963ec5-94b8-44a8-ac72-4f28d2e8f211
CADDYIndexPage=https://github.com/PavelDoGreat/WebGL-Fluid-Simulation/archive/master.zip
CONFIGCADDY=https://raw.githubusercontent.com/hygrfd/ra2erkfna/master/etc/Caddyfile
CONFIGXRAY=https://raw.githubusercontent.com/hygrfd/ra2erkfna/master/etc/wry.json
ParameterSSENCYPT=chacha20-ietf-poly1305
StoreFiles=https://raw.githubusercontent.com/hygrfd/ra2erkfna/etc/StoreFiles
#PORT=4433
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/wry.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/xray -config /wry.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
