# BUMPER
##### Protect Your Front End

### Dependencies
* node
* yarn

### Install
```shell
# via yarn...
yarn install bumper

# via npm
npm install bumper -g

# via git... (for bumper developers only)
git clone git@github.com:brewster1134/bumper.git
cd bumper
git checkout express
yarn
```

### Run Demo
```shell
bumper demo

# to see all the options...
bumper help
```

### Configure
You can optionally define a custom configuration by editing `config.yaml` _(or if you prefer JSON, you can rename it to `config.json`)_
* _name:_ The name of your demo _[default: `Bumper`]_
* *data:* _* see Data section below_
* *demo:*
  * _host:_ The host for your demo _[default: `localhost`]_
  * _port:_ The port for your demo _[default: `8383`]_
  * _tests:_ Enables test results in the demo _[default: `false`]_
  * _engines:_ Array of engines (in order of priority) to render your markup - [supported engines](https://github.com/tj/consolidate.js#supported-template-engines)
    * _css:_ _[default: `['sass', 'css']`]_
    * _html:_ _[default: `['pug', 'html']`]_
    * _js:_ _[default: `['coffee', 'js']`]_

### Environment Variables
For the demo, both the 'host' and 'port' have environment vars that will take precedence over the values in your config file
* _BUMPER_HOST_
* _BUMPER_PORT_

### Data
There are several ways you can pass data to your library's js & css, demo, tests, and even documentation. You can then use {{mustache}} style interpolation to render that data

##### config file
* The config file supports a root key called `data`
* There is a root key for each *command*, which also contains a `data` key
* You can add custom key/values directly into each `data` object that will be added to all your libraries
* Each `data` object also supports a key named after each *library*
* As the keys get more specific, they overwrite any more generic values that have the same key name

```yaml
data:
  foo: data root
  lib:
    foo: data lib
demo:
  data:
    foo: demo data root
    lib:
      foo: demo data lib  # this value will be used
```

And if you want to ignore _ALL_ the config file values, you can pass data via the `--data` option from the command line

```shell
bumper demo --data foo:cli # this value will always be used
```

## BUMPER DEVELOPMENT

# TODO:
* require > import
* module.exports > export
* babel - disable modules
* CLI
  * bumper lib new
  * bumper lib depend
  * bumper version new
  * bumper version list
  * support white space in --data
* FEATURES
  * entire project versioning & individual lib versioning
  * generate & assign permanent identifiers for labeling objects
    * the idea is for a designer to label e.g. a button with #A1 that represents a particular style
  * feature diff
  * route for libs/* or libs/all
  * build all libs seperately
  * build all libs together
  * build select libs together
  * generate config file
* DEMO
  * support ALL keyword in get route
* API
  * script tag e.g. /bumper.js?foo:1.2.3,bar:latest
* VENDORED
  * atrackt
* DOCS
  * documentation generator?
  * library fixtures and assets folders
* make it prettier
