## Overview

This project is very much a work in progress, but may be
of benefit to someone.

The project creates the infrastructure necessary to create
and maintain a letsencrypt certificate on a collection of
servers.

The certificate and associated files are stored in an S3 bucket of your choice,
encrypted with a KMS key. It is assumed that you have created
the bucket and key, and have configured a key policy that
grants IAM users or roles the necessary rights to encrypt and decrypt
objects stored in the bucket.

Certificate validation is done using the dns-01 method,
in which challenge responses are stored as DNS TXT records.
It is assumed your domain is managed by Route 53, and that
the EC2 role for the server that manages certificates
has the right to update resource records for the zone.

One server acts as the certificate manager. A cron job
on the server runs once a day. When the certificate is due
to expire within 14 days, the job requests a new
certificate, with a new key pair, and uploads the certificate,
ca chain, and private keys file to S3.

Any number of other servers may be clients. A cron job
on the clients also runs once a day, an hour after the
manager job. When the job detects that any certificate
files have been updated on S3, it downloads the files and
restarts apache. By default, certificates are stored
in directory `/var/secure/tlscerts`. You'll need to
define your apache conf files accordingly.

Before installing the software, you must create file
`params.mak`, to define parameters for your own environment.
Do this by making a copy of `params.mak.template`.
See the comments therein.

To install the software on a manager server, do:

    make install_manager

To install the software on client servers, do:

    make install_client

The certificate creation script uses the excellent
lukas2511 letsencrypt.sh script, which is available at github:


    https://github.com/lukas2511/letsencrypt.sh

For your convenience, a copy of the `letsencrypt.sh` file
is included in this repository. The copy herein may be
out of date, but it works.
