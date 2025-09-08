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

wallyInstall:	wally.toml
	wally install
	rojo sourcemap defaultTests.project.json --output sourcemap.json

wally.lock:	wallyInstall

./Packages:	wallyInstall
	wally-package-types --sourcemap sourcemap.json $@

./DevPackages:	wallyInstall
	wally-package-types --sourcemap sourcemap.json $@


BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(notdir $(SOURCES)))

$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml build/

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)

$(BUILD_SOURCES):	MV_SOURCES


$(PACKAGE_NAME):	$(BUILD_SOURCES)	$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)

NPM_ROOT = $(shell npm root)
MOONWAVE_CMD = build

$(NPM_ROOT)/.bin/moonwave:
	npm i moonwave@latest


$(BUILD_DIR)/html: $(NPM_ROOT)/.bin/moonwave moonwave.toml $(SOURCES)
	$(NPM_ROOT)/.bin/moonwave $(MOONWAVE_CMD) --out-dir $@

docs: $(BUILD_DIR)/html

docs-dev:
	make "MOONWAVE_CMD=dev" docs


lint:
	selene src/ tests/

$(RBXM_BUILD):	library.project.json	$(SOURCES)	./Packages
	rojo build library.project.json --output $@

package:	clean-package	clean-build	$(PACKAGE_NAME)

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
	$(RM) $(ALL_TESTS)

clean-build:
	$(RM) $(BUILD_DIR)/*

clean-package:
	$(RM) $(PACKAGE_NAME) 

clean:	clean-tests	clean-build	clean-rbxm	clean-package
