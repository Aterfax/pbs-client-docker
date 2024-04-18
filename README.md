# Proxmox Backup Server: Client Docker

[![Build and Publish Docker Image](https://github.com/Aterfax/pbs-client-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Aterfax/pbs-client-docker/actions/workflows/docker-publish.yml)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/aterfax/pbs-client/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/aterfax/pbs-client)

## **tl;dr?**

**Q:** What does this Docker image do? 

**A:** It lets you run the Proxmox Backup Server client and backup things from any directory mounted within ``/backups`` inside the container.

## Longer summary

This container is still a work in progress but the main feature (cronjob'd backups) now works. 

Reading and using the ``docker-compose\docker-compose.yml`` and example ``.env.example`` file should be illustrative on how to use this container. 

There are also various helper scripts available when using the shell inside the container 
which can be seen here: https://github.com/Aterfax/pbs-client-docker/tree/main/docker/src/helper_scripts

For more in depth instructions, see: [Using-the-DockerHub-provided-image](#Using-the-DockerHub-provided-image)

## Table of Contents

- [Quickstart](#Quickstart)
- [Configuration](#Configuration)
- [FAQ](#FAQ)
- [Troubleshooting](#Troubleshooting)
- [Contributing](#Contributing)
- [License](#License)

## Quickstart

### Prerequisites

* You are running a platform which supports Docker and you have Docker installed on your system. i.e. a Linux machine or cloud VM. You can download it from [here](https://www.docker.com/get-started).
* You understand how to bind mount / volume mount in docker.


### Using the DockerHub provided image

* Run the image with the provided docker-compose file after amending it and the ``.env`` file where needed.
  * i.e. bind mount the folders or volumes you wish to backup into the continer's ``/backups`` directiory.
  * Supply your desired ``master-public.pem``, ``master-private.pem`` and ``encryption-key.json`` files or allow the container to automatically generate them on first run.
* **If you do allow automatic generation, passwords will be echoed to the container logs only once during first run!**
* Backup the ``master-public.pem``, ``master-private.pem`` and ``encryption-key.json`` files and passwords.
* Populate the environment file with the correct ``PBS_ENCRYPTION_PASSWORD`` value from the container logs or from your provided ``pem`` files.
* Restart the container and check the logs to confirm a successful backup.
  * You can start a backup with the ``backupnow`` command from inside the container, i.e. ``docker exec -it pbs-client backupnow``
* Review the other helper scripts [from here](https://github.com/Aterfax/pbs-client-docker/tree/main/docker/src/helper_scripts) which are also available from the container terminal.


### Using a self built image

* Navigate to the ``docker`` subdirectory and run the command ``docker build -t $USER/pbs-client .``
* Take a note of the final line of this command's output e.g. :

        => => naming to docker.io/myusername/pbs-client

* Amend the [docker-compose/docker-compose.yml](docker-compose/docker-compose.yml) image line to: 
  
        image: myusername/pbs-client

* You can now follow the instructions as per the [Using the DockerHub provided image](#Using-the-DockerHub-provided-image) section.


## Configuration

### Common post installation configuration actions

To be filled in.

### Table of available container environment variables

To be filled in.

The following environment variables can be configured to customize the behavior of the Docker container:

| Variable Name      | Default Docker Compose Value | Valid Values           | Description                                                                                                           |
|--------------------|------------------------------|------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Variable Name      | Default Docker Compose Value | Valid Values           | Description                                                                                                           |



## FAQ

## Troubleshooting

If you encounter issues, check the [Troubleshooting section](TROUBLESHOOTING.md)  for solutions to common problems.

If this section is lacking steps to resolve your issue please take a look in the Github discussions to see if someone else has already resolved your issue or 
please start a thread.

If you have a problem or feature request and you know this related directly to the code implemented by this repo please file an issue detailing the nature of the problem or feature and any steps for implementation within a pull request.

## Contributing

If you'd like to contribute to this project, follow these steps:

* Fork the repository.
* Create a new branch for your feature: git checkout -b feature-name.
* Make your changes and commit them e.g. : git commit -m "Add feature".
* Push to the branch: git push origin feature-name.
* Create a pull request explaining your changes.

## License

This project is licensed under the [GNU General Public License v3 (GPL-3)](https://www.tldrlegal.com/license/gnu-general-public-license-v3-gpl-3).

In short: You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.
