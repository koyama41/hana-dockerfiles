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
DOCKER_COMPOSE_SCRIPTS=\
	$(SCRIPTDIR)/docker-compose-start.sh \
	$(SCRIPTDIR)/docker-compose-stop.sh \
	$(SCRIPTDIR)/docker-compose-restart.sh \
	$(SCRIPTDIR)/docker-compose-oping.sh \
	$(SCRIPTDIR)/docker-compose-ps.sh \
	$(SCRIPTDIR)/activate-vm.sh \
	$(SCRIPTDIR)/start-vms.sh
HANA_SCRIPTS=\
	$(SCRIPTDIR)/send-hanad-conf.sh \
	$(SCRIPTDIR)/send-hanapeerd-conf.sh
VMS_DIR=$(HOME)/HANA-docker-vms

DOCKER=/usr/bin/docker
DOCKER_COMPOSE=/usr/local/bin/docker-compose

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

distclean: clean
	rm -rf $(CHECKOUTDIR) $(HHH_V11N_SERVER_TAR)

install: all
	mkdir -p $(VMS_DIR)
	sh $(SCRIPTDIR)/create-docker-compose-ymls.sh
	cp $(DOCKER_COMPOSE_SCRIPTS) $(VMS_DIR)
	$(SRCDIR)/hana-config.rb -o $(VMS_DIR) $(SCRIPTDIR)/hana-config.yml.erb
	cp $(HANA_SCRIPTS) $(VMS_DIR)

uninstall:
	rm -rf $(VMS_DIR)
