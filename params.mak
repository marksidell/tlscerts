# Edit this file or define corresponding
# environment variables.
# Then run sudo make install_[client|manager].

# The root domain name.
# Replace this with your domain.
#
SETUP_TLSCERTS_DOMAIN ?= mydomain.com

# Add more hostnames here.
# You can register multiple names per cert.
#
SETUP_TLSCERTS_HOSTNAMES ?= $(SETUP_TLSCERTS_DOMAIN)  www.$(SETUP_TLSCERTS_DOMAIN)

# The S3 bucket/folder where certs are stored.
# Replace my-bucket with the name of an S3 bucket you own.
#
SETUP_TLSCERTS_S3FOLDER ?= my-bucket/certs/$(SETUP_TLSCERTS_DOMAIN)

# The ID of the KMS key used to encrypt TLS certs.
# Replace this with your own KMS key.
# 
SETUP_TLSCERTS_KMSKEYID ?= xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# How many days before expiry to renew our certs
SETUP_TLSCERTS_RENEWALDAYS ?= 14

# A linux group given read access to the certs directory
SETUP_TLSCERTS_VARDIRGROUP ?= apache
