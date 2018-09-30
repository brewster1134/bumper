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

# via git... (suggested for bumper developers only)
git clone git@github.com:brewster1134/bumper.git
cd bumper
git checkout express
yarn
```

### Run Server
```shell
bumper

# to see all the options...
bumper help
```

### Configure
You can optionally define a custom configuration by editing `config.yaml`
* *app:*
  * _title:_ The name of your app _[default: `Bumper`]_
  * _engines:_ Array of engines (in order of priority) to render your markup - [supported engines](https://github.com/tj/consolidate.js#supported-template-engines)
    * _css:_ _[default: `['sass', 'css']`]_
    * _html:_ _[default: `['pug', 'html']`]_
    * _js:_ _[default: `['coffee', 'js']`]_
* *env:*
  * _host:_ The host for your app _[default: `localhost`]_
  * _port:_ The port for your app _[default: `8383`]_
* *libs:* Optional object to pass into your library demo. e.g. If you want to pass `Hello World` into your `foo` library demo as a variable called `title`, `libs: { foo: { title: 'Hello World' }}`

### Environment Variables
* _BUMPER_HOST_ If set, will take precedence over settings in `config.yaml`
* _BUMPER_PORT_ If set, will take precedence over settings in `config.yaml`

## BUMPER DEVELOPMENT

## LIBRARY DEVELOPMENT
```shell
# create a new library
bumper lib new [LIB_NAME]

# add dependencies to your library
bumper lib depend [LIB_NAME] [NPM_PACKAGE(S)]
```
