# BUMPER
##### Protect Your Front End

### Dependencies
* node
* yarn

### Install
`yarn`

### Configure
You can optionally define a custom configuration by editting `config.yaml`
* *app:*
  * _title:_ The name of your app
  * _viewEngine:_ The view engine to render your markup - [supported engines](https://github.com/tj/consolidate.js#supported-template-engines)
* *env:*
  * _host:_ The host for your app
  * _port:_ The port for your app

### Run
`yarn start`

### To-Do
* support additional view engine (https://github.com/tj/consolidate.js)
* libs
  * scrape `libs` for `package.json`'s and install their dependencies: `yarn install --cwd [CWD]`
  * init new webpack compiler for each lib: `webpack [--config webpack.config.js]``
  * each lib able to shim dependencies
