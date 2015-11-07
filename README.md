Postfix Blackhole
==================
A simple postfix blackhole container.

Running
========
`docker run -it -p 25:25 feathj/postfix-blackhole`

Note that `VIRTUAL_HOST` environment variable can be added if run with dinghy client
`docker run -it -p 25:25 -e VIRTUAL_HOST=postfix-blackhole.docker feathj/postfix-blackhole`

USER ??
=======


Inspired heavily by
===================
https://github.com/catatnight/docker-postfix
https://github.com/simap/smtpblackhole