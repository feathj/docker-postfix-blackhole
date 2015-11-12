Postfix Blackhole
==================
A simple postfix blackhole image.  Useful for integration testing applications
without actually sending smtp messages.

Includes optional support for TLS via STARTTLS using a self signed certificate.
Also includes login support via dovecot for any user, password is: `password`.

Running
========
`$ docker run -it -p 25:25 feathj/postfix-blackhole`

Note that `VIRTUAL_HOST` environment variable can be added if run with dinghy client
`$ docker run -it -p 25:25 -e VIRTUAL_HOST=postfix-blackhole.docker feathj/postfix-blackhole`

Or from docker-compose.yml:
```
postfix:
  image: feathj/postfix-blackhole
  ports:
    - "25:25"
  environment:
    VIRTUAL_HOST: "postfix.docker"
```

Inspired heavily by
===================
[docker-postfix](https://github.com/catatnight/docker-postfix)  
[smtpblackhole](https://github.com/simap/smtpblackhole)
