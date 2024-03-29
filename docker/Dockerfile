#
# Proxmox Backup Solution Client Dockerfile.
#
#
FROM ghcr.io/linuxserver/baseimage-debian:bookworm

LABEL maintainer="Aterfax"

# Get initial required packages
RUN apt-get update && apt-get install -y wget cron expect

# Get the Proxmox signing keys and add to trust store
RUN curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg https://enterprise.proxmox.com/debian/proxmox-release-bookworm.gpg && \
echo "deb http://download.proxmox.com/debian/pbs-client bookworm main" > /etc/apt/sources.list.d/pbs-client.list

# Run updates, installs and clean up to minimise image size
RUN apt-get update && \
apt-get install -y proxmox-backup-client && \
apt-get autoclean && \
apt-get autoremove && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/apt/archives

# This is the mount point to put your volumes / bind mounts.
RUN mkdir /backups

#COPY ./src/s6-services/env-test /etc/s6-overlay/s6-rc.d/env-test
#RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/env-test

COPY ./src/expect_scripts/client_key /etc/s6-overlay/s6-rc.d/key_setup/client_key
COPY ./src/expect_scripts/client_master_key /etc/s6-overlay/s6-rc.d/key_setup/client_master_key
COPY ./src/s6-services/key_setup /etc/s6-overlay/s6-rc.d/key_setup
COPY ./src/s6-services/key_setup /etc/s6-overlay/s6-rc.d/key_setup
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/key_setup

COPY ./src/s6-services/setup_check /etc/s6-overlay/s6-rc.d/setup_check
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/setup_check

COPY ./src/s6-services/backup /etc/s6-overlay/s6-rc.d/backup
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/backup

COPY ./src/s6-services/cron-backup /etc/s6-overlay/s6-rc.d/cron-backup
RUN touch etc/s6-overlay/s6-rc.d/user/contents.d/cron-backup

COPY ./src/helper_scripts/* /usr/local/sbin/
RUN chmod +x /usr/local/sbin/*

COPY ./src/branding.txt /etc/s6-overlay/s6-rc.d/init-adduser/branding