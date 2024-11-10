{{ with secret "consul-ca/issue/nomad" "ttl=7d" }}
{{ .Data.private_key }}
{{ end }}