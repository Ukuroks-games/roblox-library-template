# Roblox project template

Just template of project for roblox game for vscode.

## Usage

It using makefile for build wally package and some another things. 

`make` will load depends from `wally.toml` automatically if it needed. If you using [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp/) it will automatically load/update packages.

You can use this commands(They also have vscode tasks).

To creating package:
```sh
make package
```

To publish:
```sh
make publish
```

To build rbxm:
```sh
make rbxm
```

To build tests:
```sh
make tests
```

To generate sourcemap:
```sh
make sourcemap
```

### Configuring

You should replace "yourLibName" to name if your library in `Makefile`, `wally.toml`, `moonwave.toml` and `projects/library.project.json`

Open `Makefile` and set `SOURCES`, `TEST_SOURCES`, `GENERATE_SOURCEMAP`, `ALL_TESTS` values and another deps. The rest is already configured and does not need to be changed.

## Projects

In folder `projects`. You don't need to copy them to project root, just use `make` for build everything

`tests.project.json` - project with unit tests

`library.project.json` - project for build rbxm
