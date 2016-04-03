# Ash

[![GitHub release](https://img.shields.io/github/release/ash-shell/ash.svg)](https://github.com/ash-shell/ash)

Ash is a modular Bash framework written with ease of use + reusability in mind.

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

# Why should you care?

Building command line tools in Bash is an extremely tedious and somewhat enigmatic task.  There's quite a bit of boilerplate code you're going to have to write if you want your script to do more than just one thing, which will only clutter your script.  In addition, your scripts will likely never be able to reference good code you've written from old scripts.

Ash helps you get rid of all of your boilerplate by letting you call functions directly from the command line, while also providing a modular approach to scripting which will allow you to share code between scripts.

You are able to build a module independently that functions as a CLI or as a library (or any combination of the two), and easily share your module with the world.

# Installation

Installing Ash is really straightforward.  Here I offer both a [manual install approach](#manually-recommended), and also a [simple one-liner](#via-script) you can paste in your terminal and get started immediately.

The manual approach is recommended, as you will be more familiar with how Ash is set up.  You should probably also never be running scripts from the output of a curl -- but I've still supplied a one-liner as I know a lot of people want a one-liner to get started.

> It's worth noting that nothing malicious is happening in the one-liner, but you totally shouldn't get in the habit of running `curl https://... | sh` as someone could hypothetially do bad things!

### Manually (recommended)

First, clone down this repo into a place you'd like to keep Ash.  We need to add the `--recursive` flag, as Ash has some submodules.

```
git clone --recursive https://github.com/ash-shell/ash.git
```

After you've got the repo cloned down, symlink the `ash` file (located at the root of this repo) to somewhere in your $PATH:

```bash
cd /usr/local/bin # <-- This can be anything in your $PATH
ln -s /path/to/ash/repo/ash .
```

You should now be good to go!

### via Script

The script runs [this file](https://raw.githubusercontent.com/ash-shell/ash/master/install.sh).  I recommended reading it!  There's a possibility this script won't work you, as I do make an assumption that `/usr/local/bin` is in your $PATH.  In the event you don't have `/usr/local/bin` in your path, install Ash manually.

After you've read the install script, run this line right here, and you should be good to go:

```bash
curl https://raw.githubusercontent.com/ash-shell/ash/master/install.sh | sh
```

# Modules

Modules are the fundamental building blocks of Ash.  They allow you to build out custom CLI's and libraries that can be used in any other Ash module.

> In this section I will be building a hypothetical module called `Wrecker` to illustrate usage

## Module Structure

A module looks something like this:

```
├── ash_config.yaml
├── callable.sh
├── classes
│   └── WreckerClass.sh
|   └── ...
└── lib
|   └── wrecker_library_file.sh
|   └── ...
└── test.sh
```

> Feel free to add any folders or files you want to this -- this is simply the base structure that Ash uses.  You can't break anything by adding new folders or files.  You'll see I've even done this myself in [ash-make](https://github.com/ash-shell/ash-make).

#### ash_config.yaml

This is the only required file in an Ash module.  This file tells Ash that your project is an Ash module.

Here is an example `ash_config.yaml` file:

```yaml
name: Wrecker
package: github.com/ash-shell/wrecker
default_alias: wrecker
callable_prefix: Wrecker
test_prefix: Wrecker
```

**`name`**: This is the human readable name of your module.  This value is used by other modules who might want to output the name of the current module.  This field is **required**.

**`package`**: This is the unique identifier to your project.  I strongly suggest keeping this the same as your git project url, or at minimum scoped under a domain you own to prevent any collisions with other ash modules.  This field is **required**.

**`default_alias`**: This is the default alias of your project.  When you install a module, it has to be aliased so it can reasonably be called by ash from the command line.  This value should be something short and sweet, and you don't need to worry about collisions with other packages (the user will be asked to come up with a new alias in the event there is a collision).  This field is **required**.

**`callable_prefix`**: This field specifies the function prefix that Ash looks for in the callable file when calling upon a module (more detail in [the section below](#callable-modules)).  This field is only required for modules that provide a callable file.

**`test_prefix`**: This field specifies the function prefix that [Test](https://github.com/ash-shell/test) looks for in the `test.sh` file when running tests.  This field is only required when you want to add tests to your module.

#### callable.sh

This file is only required if you want your library to be callable.  The contents of this file are explained in [this section](#callable-modules).

#### classes/

This directory is where you would place your modules classes.  Only class files at the root of this directory will be usable.  This is an optional folder.

The README of [ash-shell/obj](https://github.com/ash-shell/obj) goes into full detail of how this all works.

> TLDR: Ash has native Bash object support

#### lib/

This is another optional directory.  If you want your module to provide a functional based library, this is where you would place those files.

Other packages will be able to import all of the root files in the `lib` directory via:

```bash
Ash__import "your/modules/package/name"
```

You can nest folders inside of `lib` for structure, but you'll need to manage importing those files yourself as `Ash__import` won't import them.

Files in the `lib` directory are auto loaded for you in the callable portions of your module, so you don't have to import your own module.

#### test.sh

This is the file in which you can write unit tests for your modules.

The README of [ash-shell/test](https://github.com/ash-shell/test) goes into full detail of how this all works.

## Callable Modules

You can build your module to be directly callable from the command line.

The first thing you will need to do in your module is add `callable_prefix` to your [ash_config.yaml](#ash_configyaml) file.

```yaml
callable_prefix: Wrecker
```

Now you can create a `callable.sh` file and add it to the root of your module.

> One of the most important things to understand about callable files is that they are just bash files.  They provide immediate access all variables set in the [ash file](/ash), and import all of the [core module libraries](/core_modules).

Your newly created callable file will look something like this:

```bash
#!/bin/bash

Wrecker__callable_echo(){
    echo "Hello Echo"
}

Wrecker__callable_main(){
    echo "Hello"
    normal_bash_function
}

normal_bash_function(){
    echo "World"
}
```

#### Callable Functions

Callable functions are functions that can be called directly from the command line.

If your module is installed and aliased as `wrecker`, you can call the callable functions from the command line.

To call the `Wrecker__callable_echo`, simply call this in the command line:

```bash
ash wrecker:echo
```

To call `Wrecker__callable_main`, simply call this in the command line:

```bash
ash wrecker:main
```

`main` is actually a magical name for a callable, as you can simply call the main callable like this:

```bash
ash wrecker
```

## Library Modules

Library modules are modules who provide either a `lib` and/or `classes` directory.  Modules can be both callable and library modules at the same time.

#### Ash__import

`Ash__import` is how modules load in other modules `lib/` files.  You pass this function the package name of another module to import it.

Example usage:

```bash
Ash__import "github.com/ash-shell/slugify"
```

#### Obj__import

> This is technically an [ash-shell/obj](https://github.com/ash-shell/obj) function, so check out that projects README to get a deeper understanding.

`Obj__import` is how modules load in other modules `class/` files.  You pass this function the package name of another module, and also an alias for that module.

```bash
Obj__import "github.com/ash-shell/wrecker" "wrecker"
```

# The .ashrc File

The `.ashrc` file is a file loaded in by the Ash core which you can use in configuring your modules.  The `.ashrc` file is located in your home directory `~/.ashrc` (you're going to have to create this file yourself).

This file is optional in terms of the Ash core, but may be required for some modules that require an `.ashrc` configuration.

It's worth noting that this is the *first* thing that is loaded in Ash, so module writers don't have to worry about a users `.ashrc` causing any variable/function collisions with their modules, as everything in your module is loaded after and will take priority.

# License

[MIT](LICENSE.md)
