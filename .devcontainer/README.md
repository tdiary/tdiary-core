# Docker image for tdiary development

## how to build

```
% docker build -t tdiary-devel .devcontainer
```

## how to run

```
% docker run -v $(pwd):/workspace -p 9292:9292 -it --rm tdiary-devel
```

or debugging `contrib` in the parent directory:

```
% docker run -v $(pwd):/usr/src/app -v $(pwd)/../contrib:/usr/src/contrib -p 9292:9292 -it --rm tdiary-devel
```
