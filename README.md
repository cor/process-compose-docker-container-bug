## ARCHIVED

This repo was meant to reproduce https://github.com/F1bonacc1/process-compose/issues/176, and is no longer relevant

## How to reproduce

Use a Linux machine, (preferably NixOS)


**Terminal 1**:
```
nix run
```

**Terminal 2**:
```
docker ps
```

You will see:
```
CorBook-NixOS /home/cor/dev/process-compose-bug $ docker ps
CONTAINER ID   IMAGE                     COMMAND                  CREATED         STATUS         PORTS
01699bc1c124   timescaledb:2.14.1-pg16   "docker-entrypoint.s…"   7 minutes ago   Up 7 minutes   0.0.0.0:5432->5432/tcp, : ::5432->5432/tcp
```

Now, quit `process-compose` by pressing `F10` in **Terminal 1**

In **Terminal 2**, run

```
docker ps
```
You will see that the container is still running, whereas the expected result is that the container gets killed.


## Postgres container logs

The postgres container logs are checked into this repo and can be found at `./postgres.log`



