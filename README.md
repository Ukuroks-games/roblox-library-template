# Roblox project template

Just template of project for roblox game for vscode.

You should replace "yourlib" to name if your library in `Makefile` and `wally.toml`

## Usage

It using makefile for build wally package and some another things. 

Make will load depends from `wally.toml` automatically if it needed.

You can use this commands with vscode tasks.

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

or you can run vscode tasks.

## Projects

`tests.project.json` - project with unit tests

`library.project.json` - project for build rbxm
