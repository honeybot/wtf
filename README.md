# WTF
WTF is a Web Tailoring Framework built on top of Nginx/OpenResty.

## Quick Start
Before install WTF you need `OpenResty`, `lua-rocks` and `git` installed.
For Debian-based distro run:
```Shell
$ sudo apt-get update
$ sudo apt-get install openresty luarocks git
```
1. Install core framework with `luarocks`:
```Shell
$ luarocks install wtf
```
2. Install [demo package](https://github.com/honeybot/wtf-demo) containing action, plugin and solver:
```Shell
$ luarocks install wtf-demo
```
3. Clone demo policy repo to directory containing OpenResty configuration (i.e. `/etc/openresty`)
```Shell
$ cd /etc/openresty
$ sudo git clone https://github.com/honeybot/wtf-demo-policy
```
4. Set up WTF for your `nginx.conf`:
```Nginx
http {
    ...
    include wtf-demo-policy/nginx/bootstrap.conf;
    ...
    server {
        ...
        location / {
          set $wtf_policies "demo";
          include wtf-demo-policy/nginx/policy/proxy.conf;
          ...
        }
      ...
    }
    ...
}
```
5. Restart OpenResty and test your deployment:
```Shell
$ sudo service openresty restart
$ curl -s http://localhost:8080/ > /dev/null && tail -n 5 /usr/local/openresty/nginx/logs/error.log
```
You should see log records from WTF:
```
2018/02/16 13:38:20 [error] 88091#15451556: *7 [lua] log.lua:14: act(): First says: "Hello, world! This is direct action"., client: 127.0.0.1, server: localhost, request: "GET / HTTP/1.1", host: "localhost:8080"
2018/02/16 13:38:20 [error] 88091#15451556: *7 [lua] log.lua:14: act(): Second says: "Hello, world! This is direct action"., client: 127.0.0.1, server: localhost, request: "GET / HTTP/1.1", host: "localhost:8080"
2018/02/16 13:38:20 [error] 88091#15451556: *7 [lua] log.lua:14: act(): First says: "Hello, world! This action was postponed"., client: 127.0.0.1, server: localhost, request: "GET / HTTP/1.1", host: "localhost:8080"
2018/02/16 13:38:20 [error] 88091#15451556: *7 [lua] log.lua:14: act(): Second says: "Hello, world! This action was postponed"., client: 127.0.0.1, server: localhost, request: "GET / HTTP/1.1", host: "localhost:8080"
2018/02/16 13:38:20 [error] 88091#15451556: *7 [lua] log.lua:14: act(): First says: "Hello, world! This is a  solver". Second says: "Hello, world! This is a  solver"., client: 127.0.0.1, server: localhost, request: "GET / HTTP/1.1", host: "localhost:8080"
```

