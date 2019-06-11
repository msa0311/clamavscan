# clamav - RESTFul Virus Scanner Service

![ClamAV Logo](http://www.clamav.net/assets/clamav-trademark.png)

## About
Dockerized open source antivirus daemons and a open source RESTFul Spring service to use it via a [REST](https://en.wikipedia.org/wiki/Representational_state_transfer) proxy like [@solita](https://github.com/solita) made [clamav-rest](https://github.com/solita/clamav-rest).

## Description
To be able to push the service to cloudfoundry we combined the projects [clamav-rest](https://github.com/solita/clamav-rest) and [mkodockx/docker-clamav](https://hub.docker.com/r/mkodockx/docker-clamav/) to get this docker container which runs a RESTFul spring service calling the clamd to scan POSTed files on interface /scan. ClamAV daemon as a Docker image. It *builds* with a current virus database and *runs* `freshclam` in the background constantly updating the virus signature database.


## Usage / Push to hub.docker.com

	mvn clean install -DskipTests
    docker build -t msarcher/docker-clamav-cf .
    docker push msarcher/docker-clamav-cf:latest

## Run local and test

    docker run -d -p8080:8080 msarcher/docker-clamav-cf
    sh ./testi.sh 

## Run in cloudfoundry

	cf target -o MyOrg -s MySpace
    cf push -f manifest.yml --hostname clamav-<CURRENT-ENV> --docker-image msarcher/docker-clamav-cf

## account hub.docker.com (TODO)
Currently the global docker registry is used to push and pull the image. We should move the docker image to ABI MSI nexus and pull it from there during the deployment.

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
