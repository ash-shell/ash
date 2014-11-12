# ash

A framework to manage + build command-line tools in any language

# Why should you care?

Building command line tools in most languages is an extremely tedious and somewhat enigmatic task.  There are tools available for some languages, but for the languages that don't have a streamlined process you're out of luck.

Ash leverages one of the best feature of Bash: it's ease of interfacing with different programming languages.  Using this, ash allows us to build command-line tools in any language.

# Installation

TBD

# Initializing a repo with ash

Just run `ash self:init` in the repo you wish to initialize, and you'll see that an `ash_modules.json` and a `.ash_modules` folder have been created.

These files are used to manage the local modules.

# Installing Modules

Following our previous example, to install the example module we've just created run `ash self:add git://github.com/brandonromano/example_module.git 1.0.0`.

This will add v1.0.0 of the module to our local `ash_modules.json`.

If you want to install this globally, you can run `ash self:add git://github.com/brandonromano/example_module.git 1.0.0 global`

You can also do wildcards in the version number, just like `1.0.*`.  If you don't want to specify a version number at all you can use `*.*.*` and it will always reach for the most recent version.

After adding the modules, you actually will have to install them using `ash self:install`, which will by default go and try to install local modules.

If you would like to install global modules, run `ash self:install global`.

# Using Modules

After either creating or installing a module, we should now be able to use them.

Let's say that we've just installed a module called `coolmodule`.

We can run the `index` task by simply calling `ash coolmodule`.

To run additional tasks in the module, we can call them using `ash coolmodule:taskname`.

If there's a task with parameters, we can call them using `ash coolmodule:taskname param1 param2 param3`

# Building Modules

To create a module, just add a folder to the `modules` directory.  The name of the folder should be the name of the `name` value in your modules `ash_module.json` file.

## ash_module.json

In that folder, you must put a `ash_module.json` file, which defines a bunch of things necessary for a module.

Here's an example of what this file would look like:

```json
{
    "name": "ex",
    "version": "1.0.0",
    "description": "Just an example module",
    "author": "Brandon Romano",
    "language": "python",
    "main": "bootstrap.py",
    "git_repo_url": "git://github.com/brandonromano/example_module.git"
}
```

### name

The name of the module.  This is the name that is used when adding a module pulled from a repo.  In the event of a collision, the user will be prompted to give the module a name.

### version

The version of this module.

This is used to manage updates to modules.

### description

A quick description of the module.

### author

The author of the module.

### language

The language this module is written in.

### main

The entry point for this module.

### git_repo_url

The repo that this module is hosted on.

## Making your module public

After creating your module, you'd likely want to release it to the world.

Well, that's a pretty easy task, as all you have to do is initialize a git repo in your module directory + push it up to a repository.

Users will now be able to install your module, as discussed in the next section.

# License

ash is licensed under [MIT](license.md)

