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

SOURCES = \
	src/init.luau

TEST_SOURCES = \
	tests/test.client.luau


$(BUILD_DIR): 
	mkdir $@


wallyInstall:	wally.toml
	wally install
	rojo sourcemap defaultTests.project.json --output sourcemap.json

wally.lock:	wallyInstall

./Packages:	wallyInstall
	-wally-package-types --sourcemap sourcemap.json $@

./DevPackages:	wallyInstall
	-wally-package-types --sourcemap sourcemap.json $@


BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(notdir $(SOURCES)))

$(BUILD_DIR)/wally.toml:	$(BUILD_DIR)	wally.toml
	$(CP) wally.toml build/

MV_SOURCES:	$(BUILD_DIR)	$(SOURCES)
	$(CP) src/* $(BUILD_DIR)

$(BUILD_SOURCES):	MV_SOURCES


$(PACKAGE_NAME):		$(BUILD_DIR)/wally.toml
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_DIR)


# build .zip package
package:	clean-build	$(PACKAGE_NAME)

# publish library
publish:	clean-build	$(BUILD_DIR)/wally.toml	$(BUILD_SOURCES)
	wally publish --project-path $(BUILD_DIR)


$(RBXM_BUILD):	library.project.json	$(SOURCES)	./Packages
	rojo build library.project.json --output $@

rbxm:	$(RBXM_BUILD)



tests.rbxl:	./Packages	tests.project.json	$(SOURCES)	$(TEST_SOURCES)
	rojo build tests.project.json --output $@


tests:	\
	tests.rbxl


# build sourcemap
sourcemap.json:	./Packages	tests.project.json
	rojo sourcemap tests.project.json --output $@

# Re gen sourcemap
sourcemap:	sourcemap.json


NPM_ROOT = $(shell npm root)
MOONWAVE_CMD = build

# check moonwave install
$(NPM_ROOT)/.bin/moonwave:
	npm i moonwave@latest

$(BUILD_DIR)/html:	$(NPM_ROOT)/.bin/moonwave moonwave.toml	$(SOURCES)
	$(NPM_ROOT)/.bin/moonwave $(MOONWAVE_CMD) --out-dir $@



# Build docs
docs:	$(BUILD_DIR)/html

# Watch docs
docs-dev:
	make "MOONWAVE_CMD=dev" docs



lint:
	selene src/ tests/

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
