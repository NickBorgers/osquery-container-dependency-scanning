# osquery Container Dependency Scanning
This repo contains queries for a blog post I'm working on about finding vulnerable dependencies (with a known signature) in running processes inside of container images. This is [a capability which was recently added to `osquery`](https://github.com/osquery/osquery/pull/7920).

## Run this
This repo should be clone-and-run provided you have:
* Cloned this to a Linux host (doesn't work with Docker Desktop)
* Docker
* GNU Make

Specifically: you should be able to clone and then run `make` and see the output in Current Output.

## Current Output (with duplicates)

The [query in this file works just fine](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.sql), but has duplicates as you can see below.

A duplicate is a repeated combination of the 3-tuple of `container_image`, `executable` and `dependency`. 

There should only be single entry below for:
`<blank`, `/usr/sbin/sshd`, `/usr/lib64/libcrypto.so.3.0.8`
But instead there are 4.
```
+-------------------------------------+-----------------------------------+----------------------------------------------------------------------------+
| container_image                     | executable                        | dependency                                                                 |
+-------------------------------------+-----------------------------------+----------------------------------------------------------------------------+
|                                     | /usr/lib/systemd/systemd          | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/sshd                    | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/sshd                    | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/sshd                    | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/sshd                    | /usr/lib64/libcrypto.so.3.0.8                                              |
| clojure:temurin-17-lein-2.9.8-jammy | /usr/bin/openssl                  | /usr/bin/openssl                                                           |
| clojure:temurin-17-lein-2.9.8-jammy | /usr/bin/openssl                  | /usr/lib/x86_64-linux-gnu/libcrypto.so.3                                   |
|                                     | /usr/lib/systemd/systemd-userwork | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-userwork | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-userwork | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/sudo                     | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-journald | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/udevadm                  | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-oomd     | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-resolved | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-userdbd  | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/auditd                  | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd          | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd          | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/lib/systemd/systemd-logind   | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/abrtd                   | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/abrt-dump-journal-core   | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/abrt-dump-journal-oops   | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/abrt-dump-journal-xorg   | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/python3.11               | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/bin/python3.11               | /usr/lib64/python3.11/lib-dynload/_hashlib.cpython-311-x86_64-linux-gnu.so |
|                                     | /usr/sbin/NetworkManager          | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/NetworkManager          | /usr/lib64/libssh.so.4.9.4                                                 |
|                                     | /usr/sbin/sshd                    | /usr/lib64/libcrypto.so.3.0.8                                              |
|                                     | /usr/sbin/gssproxy                | /usr/lib64/libcrypto.so.3.0.8                                              |
+-------------------------------------+-----------------------------------+----------------------------------------------------------------------------+
```

I have tried several attempts at solving this:
* [DISTINCT](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.distinct.sql)
* [GROUP BY](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.groupby.sql)
However these queries are invalid because they violate a constraint for the `yara` table.

So, I tried wrapping them (on suggestion of a colleague) creating:
* [Wrapped but no de-duplication (this works as expected and generates duplicates)](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.wrapped.base.sql)
* [Wrapped with DISTINCT - this fails](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.wrapped.distinct.sql)
* [Wrapped with GROUP BY - this fails](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.wrapped.groupby.sql)
* [Wrapped with LIMIT - this works as expected and generates duplicates](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.wrapped.limit.sql)
* [Wrapped with ORDER BY - this fails](https://github.com/NickBorgers/osquery-container-dependency-scanning/blob/master/find_openssl_vulnerability.fancy.wrapped.orderby.sql)

It seems particularly weird that `ORDER BY` breaks the query and `LIMIT `does not as they're in [the same part of the processing (outside the wrapped query) per this SQLite documentation](https://www.sqlite.org/lang_select.html).
