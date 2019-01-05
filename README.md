# Bumper
###### Protect Your Front End
**Bumper** provides a platform for managing your front end library, with a live demo, and a command line interface, that both document, build, test, and release your libraries

##### Demo
* Run a single library, or any combination of libraries to see how they interact
* Interactively change library settings on-the-fly
* Display api documentation for developers
* Display style-guide details for designers
* See test results in the browser alongside each library demo

##### CLI
* Test your libraries with continuous integration support

##### Both
* Build production-ready assets with all, or select libraries
* Release semantic versions of all or individual libraries

---
#### Dependencies
* [node](nodejs.org)
* [yarn](yarnpkg.com)

---
#### Quick Usage
* [Install Bumper](#install)
* [Create Libraries](#libraries)
* [Run Bumper Commands](#commands)

---
#### Install
* Create a new directory for your Bumper libraries

```shell
# install Bumper
yarn add bumper -D
# create the initial framework
bumper init
# create a library
bumper lib --create
# run the demo
bumper demo
```

---
#### Libraries
A Bumper library is simply a collection of files in the given format

###### Supported File Formats
* **js:** coffee, js
* **css:** sass, scss, css
* **html:** see [consolidatejs](github.com/tj/consolidate.js#supported-template-engines)
* **docs:** md

###### Directory Structure
* The `demo` folder contains custom scripts & styles to customize the demo site
* The `lib` folder contains separate folders for each library
* Each library must contain a script file that matches the directory name
* Any optional library files must be named according to the example below...

```shell
├── demo
│   ├── demo.js
│   ├── demo.css
├── lib
│   ├── [LIBNAME]
│   │   ├── [LIBNAME]_demo.html   # markup to demo the library
│   │   ├── [LIBNAME]_demo.css    # styles for the library demo
│   │   ├── [LIBNAME]_demo.js     # scripts to initialize the library
│   │   ├── [LIBNAME]_docs.docs   # api & style-guide documentation
│   │   ├── [LIBNAME]_test.html   # markup to run the tests against
│   │   ├── [LIBNAME]_test.js     # test suite for the library
│   │   ├── [LIBNAME].css         # styles bundled with & required for the library
│   │   ├── [LIBNAME].js          # actual library script
│   │   ├── package.json          # package.json for this library only
│   │   ├── README.md             # readme for this library only
├── package.json                  # package.json for the entire library collection
└── README.md                     # readme for the entire library collection
```

---
##### Commands
> run `bumper help` to see available commands & options
run `bumper [COMMAND] help` to see available options

---
#### Environment Variables
Command line options can be set as environment variables in the format of `[NAME]_[COMMAND]_[OPTION]`
* Array elements should be separated by a comma (,)
* Object keys & values should be separated by a colon (:), and key:value pairs should be separated by a comma (,)
> e.g. `BUMPER_NAME`, `BUMPER_DEMO_HOST`
> e.g. `BUMPER_ARRAY=foo,bar`
> e.g. `BUMPER_OBJECT=foo:bar,bar:baz`

---
#### Configuration
Command line options, and [Globals](#globals), can be defined in a `config.yaml`/`config.json` file at the root of your libraries directory

___
#### Globals
Custom values can be passed to your library demo files, to allow customizing copy, styles, or settings. By default, Bumper use the `{{mustache}}` style interpolation

###### Config file
* Key/value pairs can be added to the `demo` section of your config file under a key called `globals`
* Key/value pairs directly under `globals` will be added to _all_ your libraries
* Key/value pairs for a specific library, can be added to a key named after the library
* Keys with the same name, values specific to a library will take precedence

```yaml
demo:
  globals:
    foo: global
    lib1:
      foo: lib    # this value will overwrite `global`
```

Additionally, you can overwrite _all_ values from the config file by passing globals via the command line

```shell
bumper demo --globals foo:cli # this value will overwrite `lib`
```

---
---
## TODO:
* **USE THE ABOVE DOCUMENTATION AS A TODO LIST!!!**
* BUMPER
  * create workspace for demo and cli?
  * jest testing
  * ci (travis)
  * badges support (badgen)
  * documentation generator?
* DEMO
  * separate documentation for developers and designers
  * shorthand route for showing all libs (lib/* or lib/all)
  * cdn (bumper.js?foo:1.2.3,bar:latest)
  * make it prettier
* BUMPER PACKAGE
  * browserslist
* FEATURES
  * semantic versioning (entire project vs individual libs)
  * generate & assign permanent identifiers for labeling objects (the idea is for a designer to label e.g. a button with #A1 that represents a particular style)
  * view diff between versions
* PACKAGES
  * atrackt
  * old bumper stuff
* CLI
  * bumper init (create skeleton for package)
  * bumper build (single asset, or individual libs)
  * bumper lib new (create new blank lib)
  * bumper lib depend (add dependencies to lib) - will it work with workspaces?
  * bumper version new (release a new semantic version)
  * bumper version list (list existing semantic versions)
  * support white space in --globals keys & values
