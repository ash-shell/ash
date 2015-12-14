# Ash

Ash is a modular Bash framework written with ease of use + reusability in mind.

# Why should you care?

Building command line tools in Bash is an extremely tedious and somewhat enigmatic task.  There's quite a bit of boilerplate code you're going to have to write if you want your script to do more than just one thing, which will only clutter your script.

Ash helps you get rid of all of your boilerplate, and allows you dive right into the code by letting you call functions straight from the command line.

# Installation

#

Run this line right here, and you should be good to go:

```
curl https://raw.githubusercontent.com/ash-shell/ash/master/install.sh | sh
```

# Creating modules

TODO

# Using Modules

TODO

# Installing Modules

TODO

# The .ashrc File

The `.ashrc` file is a file loaded in by the Ash core which you can use in configuring your modules.  The `.ashrc` file is located in your home directory `~/.ashrc` (you're going to have to create this file yourself).

This file is optional in terms of the Ash core, but may be required for some modules that require an `.ashrc` configuration.

It's worth noting that this is the *first* thing that is loaded in Ash, so module writers don't have to worry about a users `.ashrc` causing any variable/function collisions with their modules, as everything in your module is loaded after and will take priority.

# License

Ash is licensed under [MIT](LICENSE.md)
