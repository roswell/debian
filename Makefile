VERSION ?= 21.10.14.111
PACKAGE ?= roswell

pack: prepare
	cd $(PACKAGE)-$(VERSION); debuild -uc -us

prepare: \
	$(PACKAGE)-$(VERSION)/debian/changelog \
	$(PACKAGE)-$(VERSION)/debian/rules \
	$(PACKAGE)-$(VERSION)/debian/control \
	$(PACKAGE)-$(VERSION)/debian/copyright \
	$(PACKAGE)-$(VERSION)/debian/compat

$(PACKAGE)-$(VERSION)/debian/changelog: $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/copyright: copyright $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/control: control $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/rules: rules $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@
$(PACKAGE)-$(VERSION)/debian/compat: compat $(PACKAGE)-$(VERSION)/ChangeLog
	cp $< $@

$(PACKAGE)_$(VERSION).orig.tar.gz:
	curl --no-progress-bar --retry 10 -o $@ \
	-L https://github.com/roswell/roswell/archive/refs/tags/v$(VERSION).tar.gz

$(PACKAGE)-$(VERSION)/ChangeLog: $(PACKAGE)_$(VERSION).orig.tar.gz
	tar xf $<
	rm -rf $(PACKAGE)-$(VERSION)/debian # start from scratch
	find $(PACKAGE)-$(VERSION) -type f -exec touch {} +
	mkdir -p $(PACKAGE)-$(VERSION)/debian
	sed -i -e 's/run-prove/echo/g' $(PACKAGE)-$(VERSION)/Makefile.am

clean:
	rm -rf $(PACKAGE)*
