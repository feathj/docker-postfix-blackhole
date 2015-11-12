#!/bin/bash

# supervisor config
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true
loglevel=critical

[program:dovecot]
command=/usr/sbin/dovecot -c /etc/dovecot/dovecot.conf -F

[program:rsyslog]
command=/usr/sbin/rsyslogd

[program:postfix]
directory=/etc/postfix
command=/usr/sbin/postfix -c /etc/postfix start
EOF

# generate self signed certificate and enable TLS
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

# sasl login using dovecot
 postconf -e smtpd_sasl_auth_enable=yes
 postconf -e smtpd_sasl_type=dovecot
 postconf -e smtpd_sasl_path=private/auth
 postconf -e smtpd_sasl_security_options=noanonymous
 postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination
cat > /etc/dovecot/dovecot.conf <<EOF
disable_plaintext_auth = yes
mail_privileged_group = mail
mail_location = mbox:~/mail:INBOX=/var/mail/%u
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

# config postfix for blackhole
postconf -e relayhost=
postconf -e relay_transport=relay
postconf -e relay_domains=static:ALL
postconf -e smtpd_end_of_data_restrictions="check_client_access static:discard"
postconf -e smtp_dns_support_level=disabled
postconf -e disable_dns_lookups=yes
postconf -e in_flow_delay=0
postconf -e smtpd_error_sleep_time=0
postconf -e smtpd_client_connection_count_limit=0