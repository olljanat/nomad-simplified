{{ with secret "consul-ca/issue/consulcerts" (printf "common_name=%s" (env "COMMON_NAME")) "ttl=7d" }}
{{ .Data.issuing_ca }}
{{ end }}