wget -c https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz -O - | tar -xz

cd spark-3.0.1-bin-hadoop3.2/

./bin/docker-image-tool.sh -r ${IMAGENAME} -p ./kubernetes/dockerfiles/spark/bindings/python/Dockerfile build

printenv pwd
