# ubuntu4mercury
   
Ubuntu Docker image with fresh Mercury compilers

## Building the Docker image

    git clone --depth=1 https://github.com/fabnicol/ubuntu4mercury.git
    cd ubuntu4mercury
    sudo docker build --squash --file Dockerfile --tag unbuntu:mercury .

## Contents

The docker image has two Mercury compilers.   
The default compiler is the ROTD of Jan. 9, 2022, built with all grades.   
The development compiler is built from git source, with only the most 
useful C grades (configured with --disable-most-grades).   
Both compilers can build themselves and somewhat newer versions.   

The image contains a reasonable set of development libraries and tools,
including a build toolchain, gdb and vim.
Emacs is built from development git source with tagging support for
Mercury using `etags`.  
Details are given on how to use `etags` for Mercury in the man page
(`man etags`).

Mercury compilers and emacs have been built within the Docker image in
the course of its building process.

## Invocation

`mmc / mmake`: for ROTD versions.   
`mmc-dev / mmake-dev`: for Mercury git source versions.   


