#!/bin/bash -ux

apt-get update -y || true
apt-get upgrade -y || true
apt-get dist-upgrade -y || true

