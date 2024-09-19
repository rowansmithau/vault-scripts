# A config file for running Vault behind HAProxy in layer 4 TCP mode.

## Port 8200 uses TLS, port 8300 also uses TLS and also uses a chroot listener on Vault. Port 80 uses plain text specifically for serving CRL/OCSP/CA functions in the `rshl` namespace. All other requested URI's are denied when sent over port 80.

```
global
    uid                         80
    gid                         80
    chroot                      /var/haproxy
    daemon
    stats                       socket /var/run/haproxy.socket group proxy mode 775 level admin
    nbthread                    1
    hard-stop-after             60s
    no strict-limits
    tune.ssl.ocsp-update.mindelay 300
    tune.ssl.ocsp-update.maxdelay 3600
    httpclient.resolvers.prefer   ipv4
    tune.ssl.default-dh-param   4096
    spread-checks               2
    tune.bufsize                16384
    tune.lua.maxmem             0
    log                         192.168.50.10:1515 local0 info # write log output via UDP socket to Splunk
    lua-prepend-path            /tmp/haproxy/lua/?.lua
    ssl-default-bind-options prefer-client-ciphers ssl-min-ver TLSv1.2
    ssl-default-bind-ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256
    ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256

defaults
    log     global
    option redispatch -1
    timeout client 600s
    timeout connect 600s
    timeout server 600s
    retries 3
    default-server init-addr libc,last
    # WARNING: pass through options below this line
    option forwardfor

# Resolver: wsrv-1 for domain specific requests
resolvers 61b530baaf8c23.13809389
    nameserver 192.168.50.50:53 192.168.50.50:53
    resolve_retries 3
    timeout resolve 1s
    timeout retry 1s

### FRONTENDS
  
# Frontend: fe-prometheus-metrics-455 ()
frontend fe-prometheus-metrics-455
    http-response set-header Strict-Transport-Security "max-age=15768000"
    bind 192.168.50.24:455 name 192.168.50.24:455 ssl prefer-client-ciphers ssl-min-ver TLSv1.2 ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256 ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256 alpn h2,http/1.1 crt-list /tmp/haproxy/ssl/617d1b9aae0d30.17056204.certlist
    mode http
    option http-keep-alive
    maxconn 10

    # logging options
    # WARNING: pass through options below this line
    http-request use-service prometheus-exporter if { path /metrics }
        stats enable
        stats uri /stats
        stats refresh 10s

# Frontend: fe-vault-orilla-8200 ()
frontend fe-vault-orilla-8200
    bind 192.168.50.24:8200 name 192.168.50.24:8200
    mode tcp
    default_backend pool-be-vault-orilla-8200

    # logging options
    option tcplog

# Frontend: fe-vault-orilla-80 ()
frontend fe-vault-orilla-80
    bind 192.168.50.24:80 name 192.168.50.24:80
    mode http
    option http-keep-alive
    default_backend pool-be-vault-orilla-80
    option forwardfor

    # logging options
    option httplog
    # ACL: PKI paths - int - ca
    acl acl_66ea21488db452.17374612 path -i /v1/rshl/pki_int/ca
    # ACL: PKI paths - int - crl
    acl acl_66ea21402d6862.20590599 path -i /v1/rshl/pki_int/crl
    # ACL: PKI paths - int - ocsp
    acl acl_66ea21102bf8c4.45771186 path -i /v1/rshl/pki_int/ocsp
    # ACL: PKI paths - root - ca
    acl acl_66ea217a5ff3c1.84627827 path -i /v1/rshl/pki_root/ca
    # ACL: PKI paths - root - crl
    acl acl_66ea21726a3d68.26967969 path -i /v1/rshl/pki_root/crl
    # ACL: PKI paths - root - ocsp
    acl acl_66ea2167a96a34.38999502 path -i /v1/rshl/pki_root/ocsp

    # ACTION: deny non PKI paths
    http-request deny if !acl_66ea21488db452.17374612 !acl_66ea21402d6862.20590599 !acl_66ea21102bf8c4.45771186 !acl_66ea217a5ff3c1.84627827 !acl_66ea21726a3d68.26967969 !acl_66ea2167a96a34.38999502
    # WARNING: pass through options below this line
    http-request capture path len 128

# Frontend: fe-vault-orilla-8300 ()
frontend fe-vault-orilla-8300
    bind 192.168.50.24:8300 name 192.168.50.24:8300
    mode tcp
    default_backend pool-be-vault-orilla-8300

    # logging options
    option tcplog

### BACKENDS

# Backend: pool-be-vault-orilla-8200 ()
backend pool-be-vault-orilla-8200
    # health check: hc-vault-tls
    option httpchk
    http-check send meth HEAD uri /v1/sys/health?perfstandbyok=true&standbyok=true ver HTTP/1.0
    mode tcp
    balance roundrobin
    # stickiness
    stick-table type ip size 50k expire 30m
    stick on src
    server be-vault-orilla-8200 vault-active.orilla.cc:8200 check inter 10s check-ssl  verify none send-proxy-v2 check-send-proxy

# Backend: pool-be-vault-orilla-80 ()
backend pool-be-vault-orilla-80
    # health check: hc-vault-plain-text
    option httpchk
    http-check send meth HEAD uri /v1/sys/health?perfstandbyok=true&standbyok=true ver HTTP/1.0
    mode http
    balance roundrobin
    # stickiness
    stick-table type ip size 50k expire 30m
    stick on src
    http-reuse safe
    option forwardfor
    server be-vault-orilla-80 vault-active.orilla.cc:80 check inter 10s  send-proxy-v2 check-send-proxy

# Backend: pool-be-vault-orilla-8300 ()
backend pool-be-vault-orilla-8300
    # health checking is DISABLED
    mode tcp
    balance roundrobin
    # stickiness
    stick-table type ip size 50k expire 30m
    stick on src
    server be-vault-orilla-8300 vault-active.orilla.cc:8300 send-proxy-v2 check-send-proxy

listen local_statistics
    bind            127.0.0.1:8822
    mode            http
    stats uri       /haproxy?stats
    stats realm     HAProxy\ statistics
    stats admin     if TRUE
    # WARNING: pass through options below this line
    stats admin if TRUE

listen  remote_statistics
    bind            192.168.50.24:445
    mode            http
    stats uri       /haproxy?stats
    stats hide-version
    # WARNING: pass through options below this line
    stats admin if TRUE

frontend prometheus_exporter
   bind *:8404
   mode http
   http-request use-service prometheus-exporter if { path /metrics }

```
