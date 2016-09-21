SRCDIR=akari-rid2-trunk/src
COMPONENTS=hanad hanapeerd hanaroute
CONTAINER_AUTHOR=koyama

.PHONY: all clean distclean

all: 
	(cd $(SRCDIR); make all)
	@for component in $(COMPONENTS); do \
	  dir=$${component}-container; \
	  container=$(CONTAINER_AUTHOR)/$$dir; \
	  cp $(SRCDIR)/$$component/obj/$$component $$dir; \
	  docker build -t $$container $$dir; \
	done

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

distclean: clean
	(cd $(SRCDIR); make all)
