Postfix Blackhole
==================
Postfix blackhole docker image.  Useful for for integration testing applications that send messages via SMTP.  Messages sent to blackhole will not actually be delivered, but recorded to filesystem for verification.

Features
---------
* Listening service is actual configured instance of postfix which facilitates accurate testing of application SMTP machinery
* TLS support via STARTTLS using a self signed certificate
* Login support via dovecot for any user, password is `password`
* Emails are written to exposed `/messages/mail`
  * Note that postfix requires non-privileged user to write mail files, so `docker` uid=1000 is used
* Embedded nginx server with fancyindex enabled for browsing submitted emails

Running
-------
`$ docker run -it -p 25:25 -p 80:80 feathj/postfix-blackhole`

Note that `VIRTUAL_HOST` environment variable can be added if run with dinghy client
`$ docker run -it -p 25:25 -p 80:80 -e VIRTUAL_HOST=postfix-blackhole.docker feathj/postfix-blackhole`

Or from docker-compose.yml:
```
postfix:
  image: feathj/postfix-blackhole
  ports:
    - "25:25"
    - "80:80"
  environment:
    VIRTUAL_HOST: "postfix.docker"
```

Related Repos
-------------
[docker-postfix](https://github.com/catatnight/docker-postfix)  
[smtpblackhole](https://github.com/simap/smtpblackhole)
