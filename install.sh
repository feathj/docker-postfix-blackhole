#!/bin/bash

## Postfix pipe to disk ###############################################
postconf -F '*/*/chroot = n'
mkdir -p /mail
chmod 777 /mail
echo 'fs_mail unix - n n - - pipe flags=F user=docker argv=tee /mail/${queue_id}_${recipient}.txt' \
>> /etc/postfix/master.cf
postconf -e default_transport=fs_mail
postconf -e smtpd_peername_lookup=no

### Supervisor ########################################################
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true
loglevel=critical

[program:dovecot]
command=/usr/sbin/dovecot -c /etc/dovecot/dovecot.conf -F

[program:rsyslog]
command=/usr/sbin/rsyslogd

[program:nginx]
command=/usr/sbin/nginx -g "daemon off";

[program:postfix]
directory=/etc/postfix
command=/usr/sbin/postfix -c /etc/postfix start

[program:log]
command=tail -f /var/log/mail.log
redirect_stderr=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
auto_start=true
autorestart=true
EOF

### TLS ###############################################################
mkdir -p /etc/postfix/certs
openssl req \
  -subj '/CN=mail.blackhole.local/O=Postfix Blackhole/C=US' \
  -new \
  -newkey rsa:2048 \
  -sha256 \
  -days 365 \
  -nodes \
  -x509 \
  -keyout /etc/postfix/certs/server.key \
  -out /etc/postfix/certs/server.crt
chmod 400 /etc/postfix/certs/*

postconf -e smtpd_use_tls=yes
#postconf -e smtpd_enforce_tls=yes
postconf -e smtpd_tls_cert_file="/etc/postfix/certs/server.crt"
postconf -e smtpd_tls_key_file="/etc/postfix/certs/server.key"

## SASL Login #########################################################
postconf -e smtpd_sasl_auth_enable=yes
postconf -e smtpd_sasl_type=dovecot
postconf -e smtpd_sasl_path=private/auth
postconf -e smtpd_sasl_security_options=noanonymous
postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination
cat > /etc/dovecot/dovecot.conf <<EOF
disable_plaintext_auth = yes
mail_privileged_group = mail
userdb {
  driver = static
  args = uid=500 gid=500 home=/home/%u
}
passdb {
  driver = static
  args = password=password
}
service auth {
  unix_listener /var/spool/postfix/private/auth {
    group = postfix
    mode = 0660
    user = postfix
  }
}
EOF

## nginx config ########################################################
cat > /etc/nginx/nginx.conf <<EOF
user docker;
events {
  worker_connections 1024;
}
http {
  server {
    listen 80;
    root /mail;
    location / {
      fancyindex on;
    }
  }
}
EOF