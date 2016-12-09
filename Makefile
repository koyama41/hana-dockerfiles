REPOSITORY=svn+ssh://svn-akari-rid2@svn.trans-nt.com/repos/trunk
CHECKOUTDIR=akari-rid2-trunk
SRCDIR=$(CHECKOUTDIR)/src
COMTAINER_AUTHOR=hana
HANA_COMPONENTS=hanad hanapeerd hanaroute hanansupdate
SSHD_COMPONENTS=sshd
EXT_COMPONENTS=unbound
SCRIPTDIR=$(CHECKOUTDIR)/scripts/starbed
DOCKER_COMPOSE_SCRIPTS=\
	$(SCRIPTDIR)/docker-compose-start.sh \
	$(SCRIPTDIR)/docker-compose-stop.sh \
	$(SCRIPTDIR)/docker-compose-restart.sh \
	$(SCRIPTDIR)/docker-compose-ps.sh
VMS_DIR=$(HOME)/HANA-docker-vms

DOCKER=/usr/bin/docker
DOCKER_COMPOSE=/usr/local/bin/docker-compose

.PHONY: all build clean buildclean distclean

all: build
	@for component in $(HANA_COMPONENTS); do \
	  dir=$${component}-container; \
	  cp $(SRCDIR)/$$component/obj/$$component $$dir; \
	done
	@cp ~/.ssh/id_rsa.pub $(SSHD_COMPONENTS)-container/authorized_keys
	$(DOCKER_COMPOSE) build

build: $(CHECKOUTDIR)
	(cd $(SRCDIR); make all)

$(CHECKOUTDIR):
	svn co $(REPOSITORY) $(CHECKOUTDIR)

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

buildclean: clean
	(cd $(SRCDIR); make clean)

distclean: clean
	rm -rf $(CHECKOUTDIR)

install: all
	sh $(SCRIPTDIR)/create-docker-compose-ymls.sh
	cp $(DOCKER_COMPOSE_SCRIPTS) $(VMS_DIR)

uninstall:
	rm -rf $(VMS_DIR)
