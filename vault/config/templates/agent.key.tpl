{{ with secret "consul-ca/issue/consulcerts" (printf "common_name=%s" (env "COMMON_NAME")) "ttl=7d" "alt_names=localhost,active.vault.service.consul,active.vault.service.devopsdev.consul,vault.service.consul,vault.service.devopsdev.consul,server.devopsdev.consul" "ip_sans=127.0.0.1" }}
{{ .Data.private_key }}
{{ end }}
