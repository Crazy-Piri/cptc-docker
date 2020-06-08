== build the docker (from this folder)
docker build -t cptc -f cptc.Dockerfile .
docker build --pull --no-cache -t cptc -f cptc.Dockerfile .

== from your local path
docker run --rm -v ${PWD}:/src/ -it cptc 

== erase all docker
docker system prune -a -f
# cptc-docker
