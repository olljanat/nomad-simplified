docker build . -t hashistack:dev-v1

export CONSUL_ENCRYPT=SNepif34REAPlO8mr6y3oSwtfbgIA83c6Cw0KIFFluY=
export SERVER1="192.168.8.119"
export SERVER2="192.168.8.120"
export SERVER3="192.168.8.121"
export HOST_IP=192.168.8.121

docker compose up -d
