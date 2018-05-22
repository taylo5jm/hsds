# Week 1

```
mkdir DataScience
cd DataScience
```

```
git clone https://github.com/taylo5jm/hsds
cd hsds
```

```
docker build -t hemoshear-rstudio .
```


```
docker run -d -p 8787:8787 hemoshear-rstudio
```

Navigate to localhost:8787 and use rstudio as your username and password.

Now, we may want to look at data inside of the container that exists on our local machine. Let's download data on the leading causes of death from opendata.gov:

```
curl -o leading-causes-of-death.csv https://data.cdc.gov/api/views/bi63-dtpu/rows.csv?accessType=DOWNLOAD
```



