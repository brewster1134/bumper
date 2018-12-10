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
* *data:* Optional object to pass into your library demo. e.g. If you want to pass `Hello World` into your `foo` library demo as a variable called `title`, `data: { foo: { title: 'Hello World' }}`
* *demo:*
  * _host:_ The host for your demo _[default: `localhost`]_
  * _port:_ The port for your demo _[default: `8383`]_
  * _tests:_ Enables test results in the demo _[default: `false`]_
  * _engines:_ Array of engines (in order of priority) to render your markup - [supported engines](https://github.com/tj/consolidate.js#supported-template-engines)
    * _css:_ _[default: `['sass', 'css']`]_
    * _html:_ _[default: `['pug', 'html']`]_
    * _js:_ _[default: `['coffee', 'js']`]_

You can also pass command specific data to each library
* *demo:*
  * *data:*
    * *key: value*
* *test:*
  * *data:*
    * *key: value*

### Environment Variables
* _BUMPER_HOST_ If set, will take precedence over settings in `config.yaml`
* _BUMPER_PORT_ If set, will take precedence over settings in `config.yaml`

## BUMPER DEVELOPMENT

# TODO:
* CLI
  * bumper lib new
  * bumper lib depend
  * bumper version new
  * bumper version list
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
