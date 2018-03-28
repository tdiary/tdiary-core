# Docker image for tdiary development

## how to build

```
% docker build -t tdiary-devel misc/docker-devel
```

## how to run

```
% docker run --name tdiary-devel -v $(pwd):/usr/src/app -p 9292:9292 -it --rm tdiary-devel:latest
```
