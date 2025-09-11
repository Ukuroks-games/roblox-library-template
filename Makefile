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

##### CONFIG #############

# build directory. you can change it to `/tmp` or `%Temp%`
BUILD_DIR = build

RBXM_BUILD = $(LIBNAME)lib.rbxm

SOURCES = \
	src/init.luau	\
	src/module/init.luau

TEST_SOURCES = \
	tests/test.client.luau

ROJO_PROJECTS=projects

GENERATE_SOURCEMAP = tests

############

FULL_GENERATE_SOURCEMAP = $(ROJO_PROJECTS)/$(GENERATE_SOURCEMAP).project.json


$(BUILD_DIR): 
	mkdir $@


BUILD_SRC_DIR=$(BUILD_DIR)/src
$(BUILD_SRC_DIR): $(BUILD_DIR)
	mkdir $@

wally.lock	./Packages	./DevPackages	./ServerPackages &:	wally.toml
	wally install

$(BUILD_DIR)/%Dir:	./% $(BUILD_DIR)	.WAIT	sourcemap.json
	touch $@
	-wally-package-types --sourcemap sourcemap.json $<

PackagesDir = $(BUILD_DIR)/PackagesDir
DevPackagesDir = $(BUILD_DIR)/DevPackagesDir
ServerPackagesDir = $(BUILD_DIR)/ServerPackagesDir


BUILD_SOURCES = $(addprefix $(BUILD_DIR)/, $(SOURCES))

$(BUILD_SRC_DIR)/wally.toml:	wally.toml	|	$(BUILD_SRC_DIR)
	$(CP) wally.toml $(BUILD_SRC_DIR)

$(BUILD_SRC_DIR)/%.luau:	src/%.luau	|	$(BUILD_SRC_DIR)
	mkdir -p $(BUILD_DIR)/$(dir $<)
	$(CP) $< $@

$(PACKAGE_NAME):		$(BUILD_SRC_DIR)/wally.toml	$(BUILD_SOURCES)
	echo $(BUILD_SOURCES)
	wally package --output $(PACKAGE_NAME) --project-path $(BUILD_SRC_DIR)


# build .zip package
package:	$(PACKAGE_NAME)

# publish library
publish:	$(BUILD_SRC_DIR)/wally.toml	$(BUILD_SOURCES)
	wally publish --project-path $(BUILD_SRC_DIR)


# copy project to root for rojo
%.project.json: projects/%.project.json
	make "GENERATE_SOURCEMAP=$*" $@


$(RBXM_BUILD):	library.project.json	$(SOURCES)	$(PackagesDir)
	rojo build $< --output $@

# Build rbxm library
rbxm:	$(RBXM_BUILD)


$(GENERATE_SOURCEMAP).project.json:	$(FULL_GENERATE_SOURCEMAP)
	$(CP) $< $@

tests.rbxl:	$(PackagesDir)	$(DevPackagesDir)	tests.project.json	$(SOURCES)	$(TEST_SOURCES)
	rojo build tests.project.json --output $@

ALL_TESTS = \
	tests.rbxl

tests:	$(ALL_TESTS)


# build sourcemap
sourcemap.json:	$(PackagesDir)	tests.project.json
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
docs-dev:	clean-docs
	make "MOONWAVE_CMD=dev" docs


SELENE_FLAGS=

lint:
	selene $(SELENE_FLAGS) src/ tests/


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

clean-docs:
	$(RM) $(BUILD_DIR)/html

clean-src:
	$(RM) $(BUILD_SRC_DIR)

clean:	clean-tests	clean-rbxm	clean-package	clean-docs	clean-src


.PHONY:	\
	lint	\
	clean	\
	clean-sourcemap	\
	clean-package	\
	clean-rbxm	\
	clean-tests	\
	clean-build	\
	docs	\
	docs-dev	\
	sourcemap	\
	rbxm	\
	wallyInstall	\
	publish	\
	package	\
	%(BUILD_DIR)/%Dir

