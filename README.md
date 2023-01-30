# Kaniko issue with ownership and .dockerignore

There seems to be a small difference in how Docker handles things compared to Kaniko when it comes to the `--chown` switch together with `.dockerignore`.

As you can see in the `.dockerignore`, I ignore everything except certain files. One path not being ignored is `!/my-directory/**`. If I change this to just `!/my-directory/`, everything works as expected and I get the same results in both builds.


## Building with Docker

```
docker build --tag kaniko-issue .
```

As you can see by the `ls`, the directory `my-directory` is owned by `node`.

## Building with Kaniko

```
docker run --rm -v $(pwd):/workspace gcr.io/kaniko-project/executor:v1.9.1-debug --context=/workspace --no-push
```

As you can see by the `ls`, the directory `my-directory` is owned by `root`.
