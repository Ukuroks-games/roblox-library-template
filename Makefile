LIBNAME = yourLibName

PACKAGE_NAME = $(LIBNAME)lib.zip

ifeq ($(OS),Windows_NT)
	CP = xcopy /y /-y /s /e
	MV = move /y /-y
	RM = del /q /s
else
	CP = cp -rf
	MV = mv -f
	RM = rm -rf
endif

BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

SOURCES = src/yourlib.luau

TEST_SOURCES = tests/test.client.luau

$(BUILD_DIR): 
	mkdir $@

./Packages: wally.toml
	wally install
	


configure:	clean-build $(BUILD_DIR)	wally.toml	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)
	$(CP) wally.toml build/

$(PACKAGE_NAME):	configure	$(SOURCES)
	wally package --output $@ --project-path $(BUILD_DIR)

package: $(PACKAGE_NAME)
	

publish: configure	$(SOURCES)
	wally publish --project-path $(BUILD_DIR)

lint:
	selene src/ tests/

$(RBXM_BUILD):	library.project.json	$(SOURCES)	./Packages
	rojo build library.project.json --output $@

rbxm: clean-rbxm $(RBXM_BUILD)

tests.rbxl:	./Packages	tests.project.json	$(SOURCES)	$(TEST_SOURCES)
	rojo build tests.project.json --output $@

tests:	clean-tests	tests.rbxl

sourcemap.json:	./Packages	tests.project.json
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap:	clean-sourcemap	sourcemap.json


clean-sourcemap: 
	$(RM) sourcemap.json

clean-rbxm:
	$(RM) $(RBXM_BUILD)

clean-tests:
	$(RM) tests.rbxl

clean-build:
	$(RM) $(BUILD_DIR)

clean:	clean-tests	clean-build	clean-rbxm	clean-sourcemap
	$(RM) $(PACKAGE_NAME) ./Packages
