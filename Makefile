REPOSITORY=svn+ssh://svn-akari-rid2@svn.trans-nt.com/repos/trunk
CHECKOUTDIR=akari-rid2-trunk
HHH_V11N_SERVER_TAR=hhh_v11n_server-3.4.tar.gz
SRCDIR=$(CHECKOUTDIR)/src
COMTAINER_AUTHOR=hana
HANA_COMPONENTS=hanad hanapeerd hanaroute hanansupdate
SSHD_COMPONENTS=sshd
HANAVIS_SERVER_CONTAINER=hanavis-server-container
EXT_COMPONENTS=unbound
SCRIPTDIR=$(CHECKOUTDIR)/scripts/starbed
VMS_DIR=$(HOME)/HANA-docker-vms

DOCKER=/usr/bin/docker
DOCKER_COMPOSE=/usr/local/bin/docker-compose

DOCKER_IMAGES_BASE=docker-images-base.tar.xz
DOCKER_IMAGES_HANA=docker-images-hana.tar.xz

BASE_IMAGE_NAMES=ubuntu:14.04 mysql \
	koyama41/ubuntu14.04-dnsutils \
	koyama41/ubuntu14.04-unbound \
	koyama41/ubuntu14.04-bind9 \
	koyama41/ubuntu14.04-sshd-netadmin \
	koyama41/ubuntu14.04-python-httpd

HANA_IMAGE_NAMES=$(BASE_IMAGE_NAMES) \
	hana/hanad-container \
	hana/hanapeerd-container \
	hana/hanaroute-container \
	hana/hanansupdate-container \
	hana/sshd-container \
	hana/unbound-container \
	hana/dns-server-container \
	hana/hanavis-mysql-container \
	hana/hanavis-httpd-container \
	hana/hanavis-server-container

.PHONY: all build clean buildclean distclean

all: build
	@for component in $(HANA_COMPONENTS); do \
	  dir=$${component}-container; \
	  cp -f $(SRCDIR)/$$component/obj/$$component $$dir; \
	done
	@cp -f $(SRCDIR)/ncmodoki/obj/ncmodoki $(SSHD_COMPONENTS)-container
	@cp -f $(SCRIPTDIR)/mping.sh $(SSHD_COMPONENTS)-container/mping.sh
	@cp -f ~/.ssh/id_rsa.pub $(SSHD_COMPONENTS)-container/authorized_keys
	@cp -f $(HHH_V11N_SERVER_TAR) $(HANAVIS_SERVER_CONTAINER)/
	$(DOCKER_COMPOSE) build

build: $(CHECKOUTDIR) $(HHH_V11N_SERVER_TAR)
	(cd $(SRCDIR); make all)

$(CHECKOUTDIR):
	svn co $(REPOSITORY) $(CHECKOUTDIR)

$(HHH_V11N_SERVER_TAR):
	@if [ -r ../$(HHH_V11N_SERVER_TAR) ]; then \
	    echo ''; \
	    echo 'NOTE: $(HHH_V11N_SERVER_TAR) is missing:'; \
	    echo '      but ../$(HHH_V11N_SERVER_TAR) is found: use it'; \
	    echo ''; \
	    ln -s ../$(HHH_V11N_SERVER_TAR) .; \
	    sleep 1; \
	 else \
	    echo ''; \
	    echo WARNING: $(HHH_V11N_SERVER_TAR) must be prepared in this directory manually.; \
	    echo ''; \
	    exit 1; \
	 fi

save-images: $(DOCKER_IMAGES_BASE) $(DOCKER_IMAGES_HANA)

$(DOCKER_IMAGES_BASE): all
	$(DOCKER) save $(BASE_IMAGE_NAMES) | xz -9 > $(DOCKER_IMAGES_BASE)
$(DOCKER_IMAGES_HANA): all
	$(DOCKER) save $(HANA_IMAGE_NAMES) | xz -9 > $(DOCKER_IMAGES_HANA)

keep-images:
	@for component in $(HANA_COMPONENTS) $(SSHD_COMPONENT) $(EXT_COMPONENTS); do \
	  container=$(CONTAINER_AUTHOR)/$${component}-container; \
	  $(DOCKER) tag $$container $$container:`date +%Y.%m.%d.%H%M`; \
	done

clean:
	IMAGES=`$(DOCKER) ps -a -q`; if [ "$$IMAGES" != "" ]; then $(DOCKER) rm $$IMAGES; fi
	for component in $(HANA_COMPONENTS); do \
	  dir=$${component}-container; \
	  rm -f $$dir/$$component; \
	done
	rm -f $(SSHD_COMPONENTS)-container/authorized_keys
	rm -f $(SSHD_COMPONENTS)-container/mping.sh
	rm -f $(SSHD_COMPONENTS)-container/ncmodoki
	rm -f $(HANAVIS_SERVER_CONTAINER)/$(HHH_V11N_SERVER_TAR)

buildclean: clean
	(cd $(SRCDIR); make clean)

imageclean:
	docker rmi -f $(HANA_IMAGE_NAMES) || exit 0

distclean: clean
	rm -rf $(CHECKOUTDIR) $(HHH_V11N_SERVER_TAR)
	rm -rf $(DOCKER_IMAGES_BASE) $(DOCKER_IMAGES_HANA)

install:
	mkdir -p $(VMS_DIR)
	(cd $(SCRIPTDIR); $(MAKE) install)
	sh $(SCRIPTDIR)/create-docker-compose-ymls.sh

uninstall:
	rm -rf $(VMS_DIR)
