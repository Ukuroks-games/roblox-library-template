LIBNAME = yourlib

PACKAGE_NAME = $(LIBNAME).zip

CP = cp -rf
MV = mv -f

./build: 
	mkdir build
	
configure: ./build wally.toml src/*
	$(CP) src/* build/
	$(MV) build/$(LIBNAME).lua build/init.lua
	$(CP) wally.toml build/

package: configure
	wally package --output $(PACKAGE_NAME) --project-path build

publish: configure
	wally publish

sourcemap:
	rojo sourcemap tests.project.json --output sourcemap.json

lint:
	selene DevPackages/ src/ tests/

clean: 
	rm -rf build $(PACKAGE_NAME)
