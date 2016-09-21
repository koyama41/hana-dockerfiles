REPOSITORY=svn+ssh://svn-akari-rid2@svn.trans-nt.com/repos/trunk
CHECKOUTDIR=akari-rid2-trunk
SRCDIR=$(CHECKOUTDIR)/src
COMPONENTS=hanad hanapeerd hanaroute
CONTAINER_AUTHOR=koyama

.PHONY: all build clean buildclean distclean

all: build
	@for component in $(COMPONENTS); do \
	  dir=$${component}-container; \
	  container=$(CONTAINER_AUTHOR)/$$dir; \
	  cp $(SRCDIR)/$$component/obj/$$component $$dir; \
	  docker build -t $$container $$dir; \
	done

build: $(CHECKOUTDIR)
	(cd $(SRCDIR); make all)

$(CHECKOUTDIR):
	svn co $(REPOSITORY) $(CHECKOUTDIR)

keep-images:
	@for component in $(COMPONENTS); do \
	  container=$(CONTAINER_AUTHOR)/$${component}-container; \
	  docker tag $$container $$container:`date +%Y.%m.%d.%H%M`; \
	done

clean:
	IMAGES=`docker ps -a -q`; if [ "$$IMAGES" != "" ]; then docker rm $$IMAGES; fi
	for component in $(COMPONENTS); do \
	  dir=$${component}-container; \
	  rm -f $$dir/$$component; \
	done

buildclean: clean
	(cd $(SRCDIR); make clean)

distclean: clean
	rm -rf $(CHECKOUTDIR)
