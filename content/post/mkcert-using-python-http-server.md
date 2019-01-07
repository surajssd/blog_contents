+++
author = "Suraj Deshmukh"
title = "HTTPS during development using 'mkcert'"
description = "Use https even during your development"
date = "2018-08-14T01:00:51+05:30"
categories = ["certs", "https", "security", "notes"]
tags = ["development", "https", "certificates", "secure"]
+++

It's always a hassle creating certificates and lot of technical jargons involved. This can be simplified, using [mkcert](https://github.com/FiloSottile/mkcert). Install by following one of the steps mentioned in the [docs](https://github.com/FiloSottile/mkcert#installation).

Once installed just run:

```bash
$ mkcert -install
Created a new local CA at "/home/hummer/.local/share/mkcert" 💥
[sudo] password for hummer: 
The local CA is now installed in the system trust store! ⚡
The local CA is now installed in the Firefox and/or Chrome/Chromium trust store (requires browser restart)! 🦊
```

This has installed the local CA. Now all you need to do is create a new certificate.

```bash
$ mkcert 127.0.0.1 localhost
Using the local CA at "/home/hummer/.local/share/mkcert" ✨

Created a new certificate valid for the following names 📜
 - "127.0.0.1"
 - "localhost"

The certificate is at "./127.0.0.1+1.pem" and the key at "./127.0.0.1+1-key.pem" ✅
```

Now is the time to test it, so to test it I am running a Python's [SimpleHTTPServer](https://docs.python.org/2/library/simplehttpserver.html) using following code(by default if you run `python -m SimpleHTTPServer` it runs on `HTTP`).

```python
$ cat simple-https-server.py
import BaseHTTPServer, SimpleHTTPServer
import ssl

httpd = BaseHTTPServer.HTTPServer(('localhost', 4443), SimpleHTTPServer.SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket, certfile='./127.0.0.1+1.pem', keyfile='127.0.0.1+1-key.pem', server_side=True)
httpd.serve_forever()
```

This code is taken from [here](https://gist.github.com/dergachev/7028596) with just modification to the `certfile` and `keyfile` file names.

Now just run this file as:

```bash
$ python2 simple-https-server.py
127.0.0.1 - - [14/Aug/2018 11:02:29] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [14/Aug/2018 11:02:29] code 404, message File not found
127.0.0.1 - - [14/Aug/2018 11:02:29] "GET /favicon.ico HTTP/1.1" 404 -
127.0.0.1 - - [14/Aug/2018 11:03:55] "GET / HTTP/1.1" 200 -
127.0.0.1 - - [14/Aug/2018 11:03:58] "GET /simple-https-server.py HTTP/1.1" 200 -
```

Now if you have browser running already restart it and goto [https://localhost:4443/](https://localhost:4443/). And voila your local `HTTPS` server is running.

Similarly you can create more certificates with wildcard domain and use those certificates with your applications.

Huge 👍 to the developer of [mkcert](https://github.com/FiloSottile/mkcert).
