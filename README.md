# clamavscan - RESTFul Virus Scanner Service

![ClamAV Logo](http://www.clamav.net/assets/clamav-trademark.png)

## About
This is a highly available and scaleable RESTFul virus scanner dockerized to be able to deploy and operate it in different PaaS environments. 

Dockerized open source antivirus daemon (clamav) combined with a open source RESTFul Spring service to use it via a [REST](https://en.wikipedia.org/wiki/Representational_state_transfer) interface in a decoupled container.

## Description
To be able to push the service in one container to PaaS environments we combined the projects [clamav-rest](https://github.com/solita/clamav-rest) and [mkodockx/docker-clamav](https://hub.docker.com/r/mkodockx/docker-clamav/) to get this docker container which runs a RESTFul spring service calling the clamd to scan POSTed files on interface /scan. ClamAV daemon as a Docker image. It *builds* with a current virus database and *runs* `freshclam` in the background constantly updating the virus signature database.


## Usage / Push to hub.docker.com

	mvn clean install -DskipTests
    docker build -t msarcher/clamavscan .
    docker push msarcher/clamavscan:latest

## Run local and test

    docker run -d -p8080:8080 msarcher/clamavscan
    sh ./testi.sh 

## Run in openshift
Import the YML files located in the "openshift" folder to your OpenShift Cluster.

## License
The used projects are licensed under MIT and GNU

* https://github.com/solita/clamav-rest/blob/master/LICENSE
* https://github.com/mko-x/docker-clamav/blob/master/LICENSE

## File size
This clamav RESTFul service is configured to handle files up to a size of 100MB per default. If you wish to upload bigger files you need to juggle with different parameters but be warned that this could cause a instable or crashing service and is not recommeded if you dont know what you are doing:
* StreamMaxLength in clamd.conf
* clamd.maxfilesize andc camd.maxrequestsize parameter for clamav-rest-*.jar
* java memory heap size (e.g. -Xmx2048m)

## More Info
Inspired by work of 

* [dinkel](https://github.com/dinkel)
* [mko-x](https://github.com/mko-x)
* [solita](https://github.com/solita)
