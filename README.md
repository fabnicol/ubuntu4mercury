# ubuntu4mercury

Ubuntu Docker image with fresh compilers for the
[Mercury](https://github.com/Mercury-Language/mercury) language.  

## Pulling the image from Docker hub

    sudo docker pull fabnicol/ubuntu4mercury:latest
## Testing the Docker image

    sudo docker run -it fabnicol/gentoo4mercury:latest
     
*Building the mercury-csv library on GH*   
     
    git clone --depth=1 https://github.com/juliensf/mercury-json.git  
    cd mercury-json  
    make install  
    make runtests 
    (--> ALL TESTS PASSED)
      
*Test with a real json file*    
   
    cd samples  
    make
    wget https://support.oneskyapp.com/hc/en-us/article_attachments/202761727/example_2.json 
    ./pretty example_1.json
    (--> your pretty json file)
    exit
    
Below is a quick Docker how-to for newcomers to this technology. You may skip this if you are fluent enough.    
      
If you need to enter your container later:  
   
    sudo docker container ls -a  
    (* note your CONTAINER_ID *)  
     
Later use:    
  
    sudo docker start CONTAINER_ID
    sudo docker exec -it CONTAINER_ID
    (* perform your tasks *)
    exit
        
Stop your given started container:   
 
    sudo docker container stop CONTAINER_ID
    
or:    
   
Stop all your started containers:     
  
    sudo docker stop $(sudo docker ps -aq)
   
Remove all your Docker containers (full clean-up):     
   
    sudo docker rm $(sudo docker ps -aq)

Remove all Docker images:    
   
    sudo docker rmi $(sudo docker images -q)

## Alternative way (GitHub Releases)

You may prefer to download a compressed image from the Release section.
The workflow unrolls along these lines:   
    
    if wget https://github.com/fabnicol/ubuntu4mercury/releases/download/release-master/ubuntu4mercury.tar.gz
    then 
        if gunzip ubuntu4mercury.tar.gz
        then
            if sudo docker load -i ubuntu4mercury.tar
            then
                echo "Image loaded."
            else
                echo "Could not load Docker image."
            fi
        else
            echo "Could not decompress image tarball."
        fi
     else
        echo "Could not download image from GitHub Releases."
     fi
    
Please read further if you want to build the image from scratch.   

## Versioning

Version of the Mercury ROTD compiler (see above for CONTAINER_ID, the default is gentoo:mercury in this case):   

    sudo docker run CONTAINER_ID mmc --version
    
Git revision hash of the Mercury development compiler:  

    sudo docker run CONTAINER_ID cat GIT_HEAD
          
## Building the Docker image

    git clone --depth=1 https://github.com/fabnicol/ubuntu4mercury.git
    cd ubuntu4mercury
    sudo ./build.sh
    
or:

    sudo ./build_latest.sh

for the latest builds.   
 
Export the environment variable COMPRESS=true to add compressed versions
of the Docker tarball image and checksums.  

Builds are available in the Release section of this repository.   

For some time after the date of the ROTD mentioned in the generated Dockerfile,
it is possible to try and build the compiler from git source at a given
revision. For this, check official Mercury repository commits. For example, 
for the rotd of Jan. 9, 2022, the corresponding revision 06f81f1cf0d339a
can be safely changed to 40ddd73098ae (Jan. 10, 2022). Then change the values
of fields `rotd-date` (resp. `m-rev`) in the configuration file **.config.in** as 
indicated in the comments of this file.   

Alternatively, you can use the script **build.sh** with arguments as follows:

    # change the git source revision to be built:
    sudo ./build.sh REVISION
    # change the date of the ROTD to be built AND the git source revision:
    sudo ./build.sh YYYY-MM-DD REVISION

Examples:

    sudo ./build.sh 4183b8d62f
    sudo ./build.sh 2022-01-10 4183b8d62f

Command line arguments always override field values in **.config.in**.  
The date should be subsequent to 2022-01-09 and the revision to 06f81f1cf0d.
Please note that the further from these references, the higher the risk of a
build failure.  
In the two-argument case, if the build succeeds, the git source
revision indicated as the second argument has been built using the ROTD 
compiler dated as the first argument.   

Git revisions can be: revision hashes or HEAD.   
HEAD^, HEAD^^, HEAD~n are unsupported.   
Non-hash revisions (like HEAD) will be replaced by hashes in the build process.   

## Contents

The docker image has two Mercury compilers.
* If `./build.sh` is used, the default compiler is the ROTD indicated in field 
**rotd-date** of the configuration file **.config.in**, built with all grades.  
The development compiler is built from git source, with only the most
useful C grades (configured with **--disable-most-grades**).  
The default revision is specified by the field **m-rev** in **.config.in**.  
Both compilers can build themselves and somewhat newer versions.
* If `./build_latest.sh` is used, the latest ROTD to date will be built.  

The image contains a reasonable set of development libraries and tools,
including a build toolchain, gdb and vim.
Emacs is built from development git source with tagging support for
Mercury using `etags`.
Details are given on how to use `etags` for Mercury in the man page
(`man etags`).

Mercury compilers and emacs have been built within the Docker image in
the course of its building process. A ROTD is built within the Docker 
container and used as a bootstrap compiler to build to development source.

## Invocation

[do this once and for all if you downloaded the compressed image from github]   
`# xz -d ubuntu4mercury.tar.xz && docker load -i ubuntu4mercury.tar`

`# docker run -it ubuntu:mercury [ or: fabnicol/ubuntu4mercury:latest if you pulled]`   
`ubuntu:mercury # mmc / mmake`: for ROTD versions.   
`ubuntu:mercury # mmc-dev / mmake-dev`: for Mercury git source versions.   
`ubuntu:mercury # emacs` : to launch Emacs from within the running container.  

To launch mmc (ROTD) in container from your host computer, run:   

    # docker run -it [your image name] mmc [arguments]

Replace `mmc` (resp. `mmake`) with `mmc-dev` (resp. `mmake-dev`) for the git
source development version.   

To launch Emacs in the container from your host computer, run:  

    # docker run -it [your image name] /usr/local/emacs-DEV/bin/emacs

Emacs should run just as well (in non-GUI mode) as on your host and `mmc / mmake` 
will be in the PATH of the guest shell. 
To write a file on your guest from your host, add option `-v` as follows:  

    # docker run -it [your image name] \
        -v/path/to/host_shared_directory:/path/to/guest_mount_directory \
           /usr/local/emacs-DEV/bin/emacs

Below is what Emacs looks like, with 
[metal-mercury-mode](https://github.com/fabnicol/metal-mercury-mode.git), `helm-xref`/`etags`,
`imenu-list`, `imenu-list-minor-mode` and `helm-imenu` (in clockwise order):  

![emacs](doc/emacs.jpg)
  
  
