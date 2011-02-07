#________________________________________
# Macros
#

#
# Absolute path to the build directory
# Absolute path to the local install hierarchy
# Absolute path to the package archive
# Absolute path to the tools directory
#

BUILD_DIR=$(IF_SANDBOX)/build
LOCAL_DIR=$(IF_SANDBOX)/local
PACKAGES_DIR=$(IF_SANDBOX)/packages
TOOLS_DIR=$(IF_SANDBOX)/tools

#
# Package information tool
# Archive extraction tool
#

PKGINFO				= $(TOOLS_DIR)/pkginfo
EXTRACT				= $(TOOLS_DIR)/extract

#
# Package properties
#

APACHE_BUILD_DIR		= $(BUILD_DIR)/$(shell $(PKGINFO) --pkgspec httpd)
APACHE_BASE_DIR			= $(LOCAL_DIR)/apache2
APACHE_PKG			= $(shell $(PKGINFO) --path httpd)
APACHE_VERSION			= $(shell $(PKGINFO) --version httpd)

PERL_BUILD_DIR			= $(BUILD_DIR)/$(shell $(PKGINFO) --pkgspec perl)
PERL_PKG			= $(shell $(PKGINFO) --path perl)
PERL_VERSION			= $(shell $(PKGINFO) --version perl)

LIBEVENT_PKG			= $(shell $(PKGINFO) --path libevent)
LIBEVENT_PKGSPEC		= $(shell $(PKGINFO) --pkgspec libevent)
LIBEVENT_VERSION		= $(shell $(PKGINFO) --version libevent)

MEMCACHED_PKG			= $(shell $(PKGINFO) --path memcached)
MEMCACHED_PKGSPEC		= $(shell $(PKGINFO) --pkgspec memcached)
MEMCACHED_VERSION		= $(shell $(PKGINFO) --version memcached)

MOD_PERL_BUILD_DIR		= $(BUILD_DIR)/$(shell $(PKGINFO) --pkgspec mod_perl)
MOD_PERL_PKG			= $(shell $(PKGINFO) --path mod_perl)
MOD_PERL_VERSION		= $(shell $(PKGINFO) --version mod_perl)

XAPIAN_PKG			= $(shell $(PKGINFO) --path xapian-core)
XAPIAN_PKGSPEC			= $(shell $(PKGINFO) --pkgspec xapian-core)
XAPIAN_VERSION			= $(shell $(PKGINFO) --version xapian-core)

#
# Sandbox binary path
# Sandbox library path
# Sandbox Perl path
#

BIN_DIR=$(LOCAL_DIR)/bin
LIB_DIR=$(LOCAL_DIR)/lib
PERL_BIN=$(BIN_DIR)/perl

#
# Apache build arguments
#

APACHE_BUILD_ARGUMENTS=--prefix=$(APACHE_BASE_DIR) \
			--enable-mods-shared=all \
			--enable-proxy=shared
                       # --enable-authn_file=shared \
                       # --enable-authz_host=shared \
                       # --enable-auth_basic=shared \
                       # --enable-dumpio=shared \
                       # --enable-include=shared \
                       # --enable-filter=shared \
                       # --enable-env=shared \
                       # --enable-logio=shared \
                       # --enable-expires=shared \
                       # --enable-headers=shared \
                       # --enable-setenvif=shared \
                       # --enable-version=shared \
                       # --enable-proxy=shared \
                       # --enable-proxy_http=shared \
                       # --enable-mime=shared \
                       # --enable-status=shared \
                       # --enable-asis=shared \
                       # --enable-info=shared \
                       # --enable-cgi=shared \
                       # --enable-alias=shared \
                       # --enable-apreq=shared \
                       # --enable-rewrite=shared

#
# Perl module specifications
#

PERL_MODULES= \
	version-0.7701 \
	Module-Build-0.34 \
	Compress-Raw-Zlib-2.020 \
	IO-Compress-2.020 \
	DBI-1.609 \
	DBD-mysql-4.012 \
	URI-1.38 \
	Apache-DBI-1.07 \
	Digest-SHA-5.47 \
	Sub-Uplevel-0.2002 \
	HTML-Strip-1.06 \
	HTML-Tagset-3.20 \
	HTML-Parser-3.61 \
	Parse-RecDescent-1.96.0 \
	ExtUtils-XSBuilder-0.28 \
	libwww-perl-5.830 \
	XML-Parser-Lite-Tree-0.08 \
	HTML-Template-2.9 \
	JSON-2.15 \
	JSON-Any-1.21 \
	Memcached-libmemcached-0.2501 \
	Devel-Symdump-2.08 \
	Test-Exception-0.27 \
	Test-Class-0.31 \
	Math-BigInt-FastCalc-0.19 \
	Net-Twitter-Lite-0.06000 \
	WWW-Shorten-2.03 \
	Net-SSLeay-1.35 \
	IO-Socket-SSL-1.31 \
	Digest-SHA1-2.12 \
	Digest-HMAC-1.01 \
	Class-Accessor-0.34 \
	Class-Data-Inheritable-0.08 \
	UNIVERSAL-require-0.13 \
	Net-OAuth-0.19 \
	Text-Unaccent-1.07


#________________________________________
# Targets
#

all: checkenv apache perl mod_perl xapian memcached perlmods xapian-perl apreq2 mod_macro

checkenv:
	@if test "$$IF_SANDBOX" = ''; then \
	  printf "Set IF_SANDBOX before continuing, for example:\n\n\texport IF_SANDBOX=`pwd`\n\n"; \
	  false; \
	fi

perl $(PERL_BIN):
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(PERL_PKG) ; \
	cd $(PERL_BUILD_DIR) ; \
	./Configure -des -Accflags='-fPIC' -Dprefix=$(LOCAL_DIR) ; \
	make ; \
	make install

apache $(APACHE_BASE_DIR):
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(APACHE_PKG) ; \
	cd $(APACHE_BUILD_DIR) ;\
	 ./configure $(APACHE_BUILD_ARGUMENTS) ; make ; make install

mod_perl: $(PERL_BIN) $(APACHE_BASE_DIR)
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(MOD_PERL_PKG) ; \
	cd $(MOD_PERL_BUILD_DIR) ; \
	$(PERL_BIN) Makefile.PL MP_AP_PREFIX=$(APACHE_BASE_DIR); \
	make && make test ; \
	make install

clean:
	rm -rf $(LOCAL_DIR)/*
	rm -rf $(BUILD_DIR)/*

# need a rule to build perl mods
perlmods: perl
	-for d in $(PERL_MODULES); do (cd $(BUILD_DIR) ; tar xvfz $(IF_SANDBOX)/packages/perl/$$d.tar.gz ; cd $$d ; $(PERL_BIN) Makefile.PL PREFIX=$(LOCAL_DIR); make; make test; make install ); done

xapian:
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(XAPIAN_PKG) ; \
	cd $(BUILD_DIR)/$(XAPIAN_PKGSPEC) ; \
	./configure --prefix=$(LOCAL_DIR) ; make ; make install

libevent:
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(LIBEVENT_PKG) ; \
	cd $(BUILD_DIR)/$(LIBEVENT_PKGSPEC) ; \
	./configure --prefix=$(LOCAL_DIR) ; make ; make install

memcached: libevent
	cd $(BUILD_DIR) ; \
	$(EXTRACT) $(MEMCACHED_PKG) ; \
	cd $(BUILD_DIR)/$(MEMCACHED_PKGSPEC) ; \
	./configure --prefix=$(LOCAL_DIR) ; make ; make install

# TODO - parameterise these version numbers so they're
# not hardcoded here:
xapian-perl: xapian $(PERL_BIN)
	cd $(BUILD_DIR); tar xvfz $(IF_SANDBOX)/packages/perl/Search-Xapian-1.0.16.0.tar.gz ; cd Search-Xapian-1.0.16.0 ; $(PERL_BIN) Makefile.PL PREFIX=$(LOCAL_DIR) XAPIAN_CONFIG=$(LOCAL_DIR)/bin/xapian-config ; make ; make install

apreq2: $(APACHE_BASE_DIR)
	PATH=$(LOCAL_DIR)/bin:$(PATH) ; cd $(BUILD_DIR); tar xvfz $(IF_SANDBOX)/packages/perl/libapreq2-2.12.tar.gz ; cd libapreq2-2.12 ; ./configure --enable-perl-glue --with-apache2-apxs=$(LOCAL_DIR)/apache2/bin/apxs --prefix=$(LOCAL_DIR) ; make ; make install

mod_macro: $(APACHE_BASE_DIR)
	PATH=$(LOCAL_DIR)/bin:$(PATH) ; cd $(BUILD_DIR); tar xvfz $(IF_SANDBOX)/packages/mod_macro-1.1.9.tar.gz ; cd mod_macro-1.1.9 ; $(LOCAL_DIR)/apache2/bin/apxs -c -i mod_macro.c
