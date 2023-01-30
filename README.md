# Kaniko issue with ownership and .dockerignore

There seems to be a small difference in how Docker handles things compared to Kaniko when it comes to the `--chown` switch together with `.dockerignore`.

As you can see in the `.dockerignore`, I ignore everything except certain files. One path not being ignored is `!/my-directory/**`. If I change this to just `!/my-directory/`, everything works as expected and I get the same results in both builds.


## Building with Docker

```
docker build --no-cache --tag kaniko-issue .
```

As you can see by the `ls`, the directory `my-directory` is owned by `www-data`:

```
➜ docker build --no-cache --tag kaniko-issue .
Sending build context to Docker daemon   5.12kB
Step 1/5 : FROM ubuntu
 ---> 6b7dfa7e8fdb
Step 2/5 : RUN mkdir /opt/my-stuff
 ---> Running in c3a08a5cb1c1
Removing intermediate container c3a08a5cb1c1
 ---> 1d47f1103445
Step 3/5 : WORKDIR /opt/my-stuff
 ---> Running in 5c39fc4ec8d2
Removing intermediate container 5c39fc4ec8d2
 ---> 2579d1fbe4be
Step 4/5 : COPY --chown=www-data . .
 ---> 1f4efb518741
Step 5/5 : RUN ls -la
 ---> Running in d30d4e8bd1b4
total 16
drwxr-xr-x 1 root     root     4096 Jan 30 17:18 .
drwxr-xr-x 1 root     root     4096 Jan 30 17:18 ..
drwxr-xr-x 2 www-data www-data 4096 Jan 30 17:18 my-directory
-rw-rw-r-- 1 www-data www-data    6 Jan 30 16:32 my-file.txt
Removing intermediate container d30d4e8bd1b4
 ---> b9c3e1adaca4
Successfully built b9c3e1adaca4
Successfully tagged kaniko-issue:latest
```

## Building with Kaniko

```
docker run --rm -v $(pwd):/workspace gcr.io/kaniko-project/executor:v1.9.1-debug --context=/workspace --no-push
```

As you can see by the `ls`, the directory `my-directory` is owned by `root`:

```
➜ docker run --rm -v $(pwd):/workspace gcr.io/kaniko-project/executor:v1.9.1-debug --context=/workspace --no-push
INFO[0000] Using dockerignore file: /workspace/.dockerignore 
INFO[0000] Retrieving image manifest ubuntu             
INFO[0000] Retrieving image ubuntu from registry index.docker.io 
INFO[0001] Built cross stage deps: map[]                
INFO[0001] Retrieving image manifest ubuntu             
INFO[0001] Returning cached image manifest              
INFO[0001] Executing 0 build triggers                   
INFO[0001] Building stage 'ubuntu' [idx: '0', base-idx: '-1'] 
INFO[0001] Unpacking rootfs as cmd RUN mkdir /opt/my-stuff requires it. 
INFO[0002] RUN mkdir /opt/my-stuff                      
INFO[0002] Initializing snapshotter ...                 
INFO[0002] Taking snapshot of full filesystem...        
INFO[0002] Cmd: /bin/sh                                 
INFO[0002] Args: [-c mkdir /opt/my-stuff]               
INFO[0002] Running: [/bin/sh -c mkdir /opt/my-stuff]    
INFO[0002] Taking snapshot of full filesystem...        
INFO[0002] WORKDIR /opt/my-stuff                        
INFO[0002] Cmd: workdir                                 
INFO[0002] Changed working directory to /opt/my-stuff   
INFO[0002] No files changed in this command, skipping snapshotting. 
INFO[0002] COPY --chown=www-data . .                    
INFO[0002] Taking snapshot of files...                  
INFO[0002] RUN ls -la                                   
INFO[0002] Cmd: /bin/sh                                 
INFO[0002] Args: [-c ls -la]                            
INFO[0002] Running: [/bin/sh -c ls -la]                 
total 16
drwxrwxr-x 3 www-data www-data 4096 Jan 30 17:07 .
drwxr-xr-x 3 root     root     4096 Jan 30 17:07 ..
drwxr-xr-x 2 root     root     4096 Jan 30 17:07 my-directory
-rw-rw-r-- 1 www-data www-data    6 Jan 30 17:07 my-file.txt
INFO[0002] Taking snapshot of full filesystem...        
INFO[0002] No files were changed, appending empty layer to config. No layer added to image. 
INFO[0002] Skipping push to container registry due to --no-push flag 
```
