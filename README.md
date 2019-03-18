<!--- topics: api build demo deploy documentation frontend release styleguide test -->
![github: release](https://badgen.net/github/release/brewster1134/bumper)
![github: status](https://badgen.net/github/status/brewster1134/bumper)
![github: open prs](https://badgen.net/github/open-prs/brewster1134/bumper)
![npm: version](https://badgen.net/npm/v/bumper)
[![travis](https://travis-ci.com/brewster1134/bumper.svg?branch=express)](https://travis-ci.com/brewster1134/bumper)
[![codecov](https://codecov.io/gh/brewster1134/bumper/branch/express/graph/badge.svg)](https://codecov.io/gh/brewster1134/bumper)

---
# Bumper
![logo](https://github.com/brewster1134/bumper/blob/express/demo/images/favicon/apple-icon.png?raw=true)
###### Protect Your Frontend

---
**Bumper** provides a framework for managing your front end library, with a live demo and command line interface, that can both document, build, test, and release your libraries
### Features
* Build production-ready assets with all, or select libraries
* Release semantic versions of all, or select libraries

##### Demo
* Run a single library, or any combination of libraries to see how they operate together
* Interactively change settings on-the-fly
* Display api documentation for developers
* Display style-guide details for designers
* See test results in the browser alongside each library demo

##### CLI
* Test your libraries with continuous integration support

---
### Requirements
* [node](nodejs.org) >= 8.x
* [yarn](yarnpkg.com)

---
### Usage
```shell
# install Bumper
yarn global add bumper
# create the project
bumper init
# create a library
bumper lib create --name foo
# run the demo, or other commands
bumper demo
```
    
---
### Details

**Project:** A Bumper project will mainly be your Bumper libraries, but can also have scripts and styles to customize the demo  
**Library:** A Bumper library is a collection of files as defined below

##### Supported File Formats
* **js:** coffee, js
* **css:** sass, scss, css
* **html:** _see [consolidatejs](github.com/tj/consolidate.js#supported-template-engines)_
* **configuration:** yaml, json
* **documentation:** md

##### Directory Structure
* The `demo` directory contains custom scripts & styles to customize the demo site
* The `lib` directory contains separate directories for each library
* Each library must contain a script file that matches the directory name
* Any optional library files must be named according to the example below...

```shell
# project structure
├── demo
│   ├── demo.js
│   ├── demo.css
├── libs
│   ├── [LIBNAME] # library structure
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
├── config.yaml                   # custom configuration
├── package.json                  # package.json for the entire library collection
└── README.md                     # readme for the entire library collection
```

---
### Options
##### Command Line
run `bumper help` to see available commands & options  
run `bumper [COMMAND] help` to see available command options
* Object keys & values should be separated by a colon _(:)_, and key:value pairs should be separated by a space
> e.g. `--object foo:bar bar:baz`

##### Environment Variables
Options can be set as environment variables in the format of `[NAME]_[COMMAND]_[OPTION]`
> e.g. `BUMPER_NAME`, `BUMPER_DEMO_HOST`

* Array elements should be separated by a comma _(,)_
> e.g. `BUMPER_ARRAY=foo,bar`
* Object keys & values should be separated by a colon _(:)_, and key:value pairs should be separated by a comma (,)
> e.g. `BUMPER_OBJECT=foo:bar,bar:baz`

##### Config File
Options can be defined in a `config.yaml`/`config.json` file at the root of your project directory

---
### Demo Globals
Custom values can be passed to your library demo files, to allow customizing copy, styles, or settings  
By default, Bumper use the `{{mustache}}` style interpolation

##### Config file
* Key/value pairs can be added to the `demo` section of your config file under a key called `globals`
* Key/value pairs directly under `globals` will be added to _all_ your libraries
* Key/value pairs for a specific library, can be added to a key named after the library
* Keys with the same name, values specific to a library will take precedence

```yaml
demo:
  globals:
    foo: global   # will be added to all library globals
    [LIBNAME]:
      key: val    # will only be added to this library globals
      foo: lib    # will take precedence over `foo: global`
```

---
### Development
```shell
# show code coverage report
yarn coverage

# run unit tests and show code coverage
yarn test

# watch files and run tests on changes
yarn watch
```

---
---
---
## TODO:
* **USE THE ABOVE DOCUMENTATION AS A TODO LIST!!!**
* BUGS
  * address coerce running twice https://github.com/yargs/yargs/issues/923#issuecomment-458301555
  * coverage caching [974](https://github.com/istanbuljs/nyc/issues/974)
* BUMPER
  * nconf ?
  * postcss
  * semantic versioning (entire project vs individual libs)
  * view diff between versions
  * generate documentation & host `/docs` on github pages
  * [markdown styleguide generator](https://github.com/emiloberg/markdown-styleguide-generator)
  * source maps
  * [mocha-multi-reporters](https://www.npmjs.com/package/mocha-multi-reporters)
  * [shields](https://shields.io/category/coverage) or [badgen](https://badgen.net)
  * sourcegraph.com
* BUMPER PROJECT
  * browserslist
  * atrackt
  * old bumper stuff
  * multiple project support?
* CLI
  * bumper build (single asset, or individual libs)
  * bumper deploy (build assets, docs, prod demo)
  * bumper init (create skeleton for project)
  * bumper lib new (create new blank lib)
  * bumper lib depend (add dependencies to lib) - will it work with workspaces?
  * bumper version new (release a new semantic version)
  * bumper version list (list existing semantic versions)
  * support white space in --globals keys & values
* CI
  * code coverage
  * lint
  * generate & deploy bumper development docs to github pages
  * build/release version to npm & github
  * deploy to heroku/?
* DEMO
  * share lib/commands for demo/routes
  * interpolate
  * shorthand route for showing all libs (lib/* or lib/all)
  * support tests in develop mode (broken due to css extracted and needing window object to load)
  * demo design
  * separate documentation for developers and designers
  * generate & assign permanent identifiers for labeling objects (the idea is for a designer to label e.g. a button with #A1 that represents a particular style)
  * cdn (bumper.js?foo:1.2.3,bar:latest)
  * puppeteer
  * [david](https://david-dm.org)
* FUTURE
  * replace webpack (parcel, browserify, rollup)
  * replace travis (circle, gitlab, codefresh, buildkite, bitrise)
  * replace coveralls (code climate, codecov)
  