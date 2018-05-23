# HemoShear Data Science Study Group


## Installing software



### Install `brew` (Mac only)

`brew` is a package manager for OS X. Press Command + Spacebar and type `terminal` to open a command prompt, and paste the following line:  

```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

### Install `git` 


`git` is a version control system. This is a great tool that allows us to collaborate on projects. If you installed `brew` on a Mac, you should also have git. If you are on a PC, install git for Windows.



### Clone this git repository

After you have installed git, it is a good idea to make a new directory for your work. Start out somewhere like `/Documents` and make a new directory from there:

```
mkdir DataScience
cd Documents
```

After you are in a new directory, `clone` the repository. `clone` is the git command for retrieving an entire copy of a repository from a remote source. 

```
git clone https://github.com/taylo5jm/hsds
```

You can do `ls` now to see that there is a directory called `hsds`. This is the git repository that you just cloned. We can change directories to `hsds`.

```
cd hsds
```

In this directory, there is a `Dockerfile`, which is a set of instructions for building our custom RStudio computing environment. To install our curstom RStudio Server version, we can build a Docker image with the `Dockerfile` in our repository. In the line below, `docker build` is telling the machine to run the `build` command in `docker`. `-t` is an option that is short for *tag*, so `-t hs-rstudio` will tag the image as `hs-rstudio`, a name we can recognize and possibly remember. The `.` at the end tells `docker` to look in our current directory.     

```
docker build -t hs-rstudio .
```

The image can take up to 30 minutes to build. After this process is complete, you can run RStudio with the following line:  

```
docker run -d -p 8787:8787 hs-rstudio
```

You should see a long string of random numbers and letters. If not, something is wrong. At this point, you can go to localhost:8787 in your browser and sign in to RStudio with the username and password `rstudio`.

You can make files in this new container, but when the container is stopped, any data will cease to exist. You can map a *volume* to a container with the `-v` option. `-v /Users/justin/Documents/data:/data` will expose any data in `/Users/justin/Documents/data` on my machine to `/data` in the container. 

```
docker run -d -p 8787:8787 -v /Users/justin/Documents/data:/data hs-rstudio
```






