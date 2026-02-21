# Proxmox Backup Server Client - Dockerized

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

- [Features](#Features)
- [Quickstart](#Quickstart)
- [Configuration](#Configuration)
- [FAQ](#FAQ)
- [Troubleshooting](#Troubleshooting)
- [Contributing](#Contributing)
- [License](#License)

## Features

* **Containerized PBS Client** - Runs Proxmox Backup Server client in a Docker container.
* **Automated Backup Scheduling** - Fully configurable via `CRON_SCHEDULE` and optional `CRON_BACKUP_ONLY`.
* **Secure Backups** - Supports encrypted backups with `PBS_ENCRYPTION_PASSWORD` or unencrypted mode if needed.
* **API Key Support** - Use `PBS_API_KEY_NAME` / `PBS_API_KEY_SECRET` instead of PBS username/password.
* **Namespace Support** - Target specific PBS datastore namespaces with `PBS_DATASTORE_NS`.
* **Customizable Backup Options** - Append extra PBS CLI options via `PBS_BACKUP_CMD_APPEND_EXTRA_OPTS` and restore options via `PBS_RESTORE_CMD_APPEND_EXTRA_OPTS`.
* **Healthchecks.io Integration** - Optional monitoring via self-hosted or central Healthchecks.io.
* **Email Notifications** - Optional success/failure notifications via SMTP configuration.
* **Timezone Configurable** - Set container timezone with `TZ`.
* **S6-based Supervision** - Long-running container managed with s6, optional mail service, and clean logging.

## Quickstart

### Prerequisites

* You are running a platform which supports Docker and you have Docker installed on your system. i.e. a Linux machine or cloud VM. You can download it from [here](https://www.docker.com/get-started).
* You understand how to bind mount / volume mount in docker.


### Using the DockerHub provided image

> [!WARNING]  
> It is possible, but highly discouraged for you to make unencrypted backups by setting `UNENCRYPTED=1` in your ``.env`` file. This will bypass the automatic key generation process but **this is a bad idea** as the backed-up data will be stored in plaintext. This means that the owner of the PBS backup server you are backing up to will have full access to explore the backed-up content.

> [!NOTE]  
> If you use the central Healthchecks.io instance you must the ``.env`` variable ``HEALTHCHECKS_SELF_HOSTED=false`` or checks will not work.


* Run the image with the provided docker-compose file after amending it and the ``.env`` file where needed.
  * If allowing the container to conduct an auto setup, don't set a  ``PBS_ENCRYPTION_PASSWORD`` value yet as the container first run will autogenerate one for you.
  * Supply your desired ``master-public.pem``, ``master-private.pem`` and ``encryption-key.json`` files with a matching ``PBS_ENCRYPTION_PASSWORD`` or allow the container to automatically generate these for you on first run.
  * The required permissions in your PBS server instance for an API key will be "DatastoreBackup" and "DatastoreReader" on the appropriate path. Or you can supply a username and password combination which has these permissions - this is not recommended!
  * bind mount the folders or volumes you wish to backup into the container's ``/backups`` directiory.
* **If you do allow automatic generation, passwords will be echoed to the container logs only once during first run!** Ensure you do not restart the container before saving these values.
* Backup the ``master-public.pem``, ``master-private.pem`` and ``encryption-key.json`` files and passwords to a separate storage system accessible even if the machine / system being backed up or restored becomes inaccessible.
* Populate the environment file with the correct ``PBS_ENCRYPTION_PASSWORD`` value from the container logs or from your provided ``pem`` /  ``encryption-key.json`` files.
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

The following environment variables can be configured to customize the behavior of the Docker container:

| Variable Name                         | Default Docker Compose Value           | Valid Values                 | Description                                                          |
| ------------------------------------- | -------------------------------------- | ---------------------------- | -------------------------------------------------------------------- |
| **PBS_ENCRYPTION_PASSWORD**           | `123456789abcdefghijklmn`              | A string                     | Required: Password for encrypting backups.                           |
| **PBS_ENDPOINT**                      | `pbs.mydomain.com`                     | Valid hostname or IP         | Required: PBS server endpoint.                                       |
| **PBS_DATASTORE**                     | `test-datastore`                       | Any valid PBS datastore name | Required: Target datastore on the PBS server.                        |
| **CRON_SCHEDULE**                     | `0 */4 * * *`                          | Any valid cron expression    | Required: Schedule for automatic backups.                            |
| **CRON_BACKUP_ONLY**                  | `0`                                    | `0` or `1`                   | Optional: `1` to skip backup on startup, `0` to run immediately.     |
| **UNENCRYPTED**                       | `0`                                    | `0` or `1`                   | Optional: `1` to allow unencrypted backups (not recommended).        |
| **PBS_API_KEY_NAME**                  | `username@pam!test`                    | Valid PBS API key name       | Optional: API key name; preferred over PBS_USER/PBS_PASSWORD.        |
| **PBS_API_KEY_SECRET**                | `4054356a-f1a6-441e-86fc-e338367db185` | Valid PBS API key secret     | Optional: Secret for PBS_API_KEY_NAME.                               |
| **PBS_USER**                          | *(empty)*                              | PBS username                 | Optional: Only required if API key is not set.                       |
| **PBS_PASSWORD**                      | *(empty)*                              | PBS password                 | Optional: Only required if API key is not set.                       |
| **PBS_FINGERPRINT**                   | *(empty)*                              | SHA1 fingerprint             | Optional: Required if using a self-signed SSL certificate.           |
| **PBS_DATASTORE_NS**                  | `test`                                 | Any string                   | Optional: Namespace within datastore.                                |
| **PBS_BACKUP_CMD_APPEND_EXTRA_OPTS**  | *(empty)*                              | Any valid PBS CLI option     | Optional: Extra options appended to `proxmox-backup-client backup`.  |
| **PBS_RESTORE_CMD_APPEND_EXTRA_OPTS** | *(empty)*                              | Any valid PBS CLI option     | Optional: Extra options appended to `proxmox-backup-client restore`. |
| **HEALTHCHECKSUUID**                  | `aa7b0de3-2c17-4fce-b051-388a5415e656` | Valid UUID                   | Optional: Healthchecks.io UUID for monitoring.                       |
| **HEALTHCHECKSHOSTNAME**              | `https://healthchecks.mydomain.com`    | Valid URL                    | Optional: Healthchecks.io host.                                      |
| **HEALTHCHECKS_SELF_HOSTED**          | `true`                                 | `true` or `false`            | Optional: Whether Healthchecks.io is self-hosted.                    |
| **HEALTHCHECKS_PING_ENDPOINT_DIR**    | *(empty / ping default)*               | Any string                   | Optional: Subdirectory for ping endpoint; defaults to `ping`.        |
| **TZ**                                | `Etc/UTC`                              | Any valid timezone string    | Container timezone.                                                  |
| **SMTP_HOST**                         | `smtp.mydomain.com`                    | Valid SMTP hostname          | Optional: SMTP server to use for email notifications.                       |
| **SMTP_PORT**                         | `587`                                  | Valid port number            | Optional: SMTP server port.                                                 |
| **SMTP_USER**                         | `backup@mydomain.com`                  | Valid email/user             | Optional: SMTP server username.                                             |
| **SMTP_PASSWORD**                     | `supersecret`                          | Valid password               | Optional: SMTP server password.                                             |
| **SMTP_FROM**                         | `backup@mydomain.com`                  | Valid email                  | Optional: From address for notifications.                            |
| **SMTP_TO**                           | `admin@mydomain.com`                   | Valid email                  | Optional: Recipient of notifications.                                |
| **SMTP_TLS**                          | `true`                                 | `true` or `false`            | Optional: Use TLS for SMTP.                                          |
| **SMTP_STARTTLS**                     | `false`                                 | `true` or `false`            | Optional: Use STARTTLS for SMTP.                                     |
| **EMAIL_ON_SUCCESS**                  | `0`                                    | `0` or `1`                   | Optional: Send email if backup succeeds.                             |
| **EMAIL_ON_FAILURE**                  | `1`                                    | `0` or `1`                   | Optional: Send email if backup fails.                                |

## FAQ

### I'm using the central Healthchecks.io instance and checks are not working

If you use the central Healthchecks.io instance you must the ``.env`` variable ``HEALTHCHECKS_SELF_HOSTED=false`` or checks will not work due to the additional URL subdirectory (``/ping``) used by self hosted instances.

### Error: Function not implemented (os error 38)

It appears that some Synology NAS platforms are missing support for the ``getrandom`` system call used during key creation which will block the container from starting. 

To bypass this issue you can manually create some keys or run the container on another platform to generate keys with a random password then transfer these (``encryption-key.json``  ``master-private.pem``  ``master-public.pem``) to the Synology docker container's ``/root/.config/proxmox-backup/`` bind mount.

See also:
- https://github.com/Aterfax/pbs-client-docker/issues/8
- https://forum.proxmox.com/threads/backup-client-encryption-not-working-inside-docker-container.139054/

> [!WARNING]  
> It is possible, but highly discouraged for you to bypass this issue by taking unencrypted backups. You can do this by setting `UNENCRYPTED=1` in your ``.env`` file and this will bypass the automatic key generation process.
>
>**This is a bad idea** as the backed-up data will be stored in plaintext. This means that the owner of the PBS backup server you are backing up to will have full access to explore the backed-up content.
<br><br>

### The PBS client is skipping mount points when doing backups

This is caused by the default behaviour of the PBS client to not traverse mountpoints and your choice in backup directory targets, e.g. mounting a folder in a subdirectory within ``/backup/myfolder``, e.g. ``/backup/myfolder/folder_to_backup`` rather than a directory within ``/backup/`` as ``/backup/folder_to_backup``.

You can either:

* Mount your folder targets within ``/backup/`` only.
* Use the ``PBS_BACKUP_CMD_APPEND_EXTRA_OPTS`` environment variable to set ``--include-dev`` arguments as per documentation here: https://pbs.proxmox.com/docs/backup-client.html#creating-backups
<br><br>

### How can I exclude a subdirectory within one of my backup folders?

If we have a structure as below when mounted in the container:

```
/backup/myfolder/folder_to_backup
/backup/myfolder/folder_to_ignore
```

You would be able to exclude the second path in your docker compose file by mounting an empty Docker volume over the top of that path (rendering it empty inside the docker container) as below:

```
volumes:
  - /my_host_path/:/backup/myfolder/:ro
  - /backup/myfolder/folder_to_ignore # This mounts an empty Docker volume over the top of this path.
```  
<br>

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

