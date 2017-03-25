# Make our SSL certs

include params.mak

PROGDIR	= /usr/local/tlscerts
VARDIR	= /var/secure/tlscerts


#======================================================================
define CONFIG_PY =
# tlscerts config
# NOTE: This file is used both as a Python file and a bash config
# file, which means that there should be no space around the =.
#
#
TLSCERTS_S3FOLDER="$(SETUP_TLSCERTS_S3FOLDER)"
TLSCERTS_S3FOLDER_LATEST="$(SETUP_TLSCERTS_S3FOLDER)/latest"
TLSCERTS_KMSKEYID="$(SETUP_TLSCERTS_KMSKEYID)"
TLSCERTS_VARDIR="$(VARDIR)"
TLSCERTS_RENEWALDAYS=$(SETUP_TLSCERTS_RENEWALDAYS)
TLSCERTS_DOMAINS="$(SETUP_TLSCERTS_HOSTNAMES)"
endef
export CONFIG_PY
#======================================================================

#======================================================================
define LETSENCRYPT_CONFIG_SH =
# config.sh file for letsencrypt.sh
# See config.sh.default for all of the options
#
BASEDIR=$(VARDIR)/new
CHALLENGETYPE="dns-01"
# AWS only accepts 2048 bit keys (the default is 4096)
KEYSIZE="2048"
HOOK=$(PROGDIR)/hook
endef
export LETSENCRYPT_CONFIG_SH
#======================================================================


.PHONY : all
all : config.py letsencrypt-config.sh

config.py : makefile
	echo "$$CONFIG_PY" > $@

letsencrypt-config.sh : makefile
	echo "$$LETSENCRYPT_CONFIG_SH" > $@


.PHONY : install_common
install_common : all
	mkdir -p $(PROGDIR)
	chown 0:0 $(PROGDIR)
	chmod 550 $(PROGDIR)

	mkdir -p ${VARDIR}
	chown 0:apache ${VARDIR}
	chmod 550 ${VARDIR}

	cp -f config.py $(PROGDIR)
	chown 0:0 $(PROGDIR)/config.py
	chmod 550 $(PROGDIR)/config.py
	

.PHONY : install_client
install_client : install_common
	cp -f tlscerts-initserver /usr/local/initserver.d
	chown 0:0 /usr/local/initserver.d/tlscerts-initserver
	chmod 550 /usr/local/initserver.d/tlscerts-initserver

	cp -f update-certs $(PROGDIR)
	chown 0:0 $(PROGDIR)/update-certs
	chmod 550 $(PROGDIR)/update-certs

	cp -f cron-update-certs /etc/cron.d/tlscerts-update-certs
	chown 0:0 /etc/cron.d/tlscerts-update-certs
	chmod 640 /etc/cron.d/tlscerts-update-certs


.PHONY : install_manager
install_manager : letsencrypt-config.sh install_common install_client

	mkdir -p $(VARDIR)/new
	chown 0:0 $(VARDIR)/new
	chmod 700 $(VARDIR)/new

	cp -f renew-certs $(PROGDIR)
	chown 0:0 $(PROGDIR)/renew-certs
	chmod 550 $(PROGDIR)/renew-certs

	cp -f gen-certs $(PROGDIR)
	chown 0:0 $(PROGDIR)/gen-certs
	chmod 550 $(PROGDIR)/gen-certs

	cp -f letsencrypt.sh $(PROGDIR)
	chown 0:0 $(PROGDIR)/letsencrypt.sh
	chmod 550 $(PROGDIR)/letsencrypt.sh

	cp -f hook $(PROGDIR)
	chown 0:0 $(PROGDIR)/hook
	chmod 550 $(PROGDIR)/hook

	cp -f letsencrypt-config.sh $(PROGDIR)
	chown 0:0 $(PROGDIR)/letsencrypt-config.sh
	chmod 550 $(PROGDIR)/letsencrypt-config.sh
	
	cp -f cron-renew-certs /etc/cron.d/tlscerts-renew-certs
	chown 0:0 /etc/cron.d/tlscerts-renew-certs
	chmod 640 /etc/cron.d/tlscerts-renew-certs


.PHONY : certs
certs : domains.txt
	./letsencrypt.sh --cron --challenge dns-01 --hook ./hook --config ./config.sh

.PHONY : cron
cron : certs
	-rm -fr certs

.PHONY : clean
clean :
	-rm -f config.py
	-rm -f letsencrypt-config.sh
	-rm -f domains.txt
	-rm -fr certs
	-rm -f *.pem
