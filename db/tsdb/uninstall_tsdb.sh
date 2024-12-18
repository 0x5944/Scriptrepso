#!/bin/bash
sudo service postgresql stop

sudo apt-get --purge remove timescaledb-2-postgresql-*

sudo rm -rf /var/lib/postgresql/*

sudo rm -rf /etc/postgresql/*

sudo apt-get --purge remove postgresql*

sudo apt-get autoremove
sudo apt-get clean

