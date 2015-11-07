#!/bin/bash

# supervisor config
cat > /etc/supervisor/conf.d/supervisord.conf <<EOF
[supervisord]
nodaemon=true
[program:postfix]
command=/opt/postfix.sh
# [program:rsyslog]
# command=/usr/sbin/rsyslogd -n -c3
EOF

# postfix script for supervisor
cat >> /opt/postfix.sh <<EOF
#!/bin/bash
service postfix start
tail -f /var/log/mail.log
EOF
chmod +x /opt/postfix.sh

# config postfix for blackhole
postconf -e relayhost=
postconf -e myhostname=mail.blackhole.local
postconf -e relay_transport=relay
postconf -e relay_domains=static:ALL
postconf -e smtp_end_of_data_restrictions="check_client_access static:discard"