VERSION ?= 21.10.14.111
PACKAGE ?= roswell

pack: prepare
	cd $(PACKAGE)-$(VERSION); debuild -uc -us

prepare: \
	$(PACKAGE)-$(VERSION)/debian/changelog \
	$(PACKAGE)-$(VERSION)/debian/rules \
	$(PACKAGE)-$(VERSION)/debian/control \
	$(PACKAGE)-$(VERSION)/debian/copyright \
	$(PACKAGE)-$(VERSION)/debian/compat \
	$(PACKAGE)-$(VERSION)/debian/watch \
	$(PACKAGE)-$(VERSION)/debian/README.source

$(PACKAGE)-$(VERSION)/debian/changelog: changelog $(PACKAGE)-$(VERSION)/ChangeLog
	if [ 'x$(VERSION)' = x99.99.99.99 ]; then \
		echo "roswell (99.99.99.99-1) unstable; urgency=low" > $@; \
		echo "" >> $@; \
		echo "  * master Release." >> $@; \
		echo "" >> $@; \
		echo " -- n <tmp@example.com> " $(shell date -R) >> $@; \
		echo "" >> $@; \
	else \
		touch $@; \
	fi
	cat $< >> $@

$(PACKAGE)-$(VERSION)/debian/copyright: copyright $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/control: control $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/rules: rules $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/compat: compat $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/watch: watch $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/README.source: $(PACKAGE)-$(VERSION)/README.md
	cp $< $@

$(PACKAGE)_$(VERSION).orig.tar.gz:
	if [ 'x$(VERSION)' != x99.99.99.99 ]; then \
		curl --no-progress-bar --retry 10 -o $@ \
		-L https://github.com/roswell/$(PACKAGE)/archive/refs/tags/v$(VERSION).tar.gz; \
	else \
		curl --no-progress-bar --retry 10 \
		-L -O http://github.com/roswell/$(PACKAGE)/archive/master.tar.gz; \
		tar xf master.tar.gz; \
		rm master.tar.gz; \
		rm -rf $(PACKAGE)-$(VERSION)/debian # start from scratch \
		mv $(PACKAGE)-master $(PACKAGE)-$(VERSION); \
		tar czf $@ $(PACKAGE)-$(VERSION); \
	fi

$(PACKAGE)-$(VERSION)/README.md $(PACKAGE)-$(VERSION)/ChangeLog: $(PACKAGE)_$(VERSION).orig.tar.gz
	tar xf $<
	rm -rf $(PACKAGE)-$(VERSION)/debian # start from scratch
	find $(PACKAGE)-$(VERSION) -type f -exec touch {} +
	mkdir -p $(PACKAGE)-$(VERSION)/debian
	sed -i -e 's/run-prove/echo/g' $(PACKAGE)-$(VERSION)/Makefile.am

lint:
	lintian -EviIL +pedantic $(PACKAGE)_$(VERSION)-*.changes
lintian:
	lintian -EvIL +pedantic $(PACKAGE)_$(VERSION)-*.changes

clean:
	rm -rf $(PACKAGE)*

d-run:
	docker run -v $(shell pwd):/tmp2 -ti sid /bin/bash

d-build:
	docker build . -t sid
d-cp:
	cp /tmp2/* /tmp
