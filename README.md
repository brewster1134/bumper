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
  * _title:_ The name of your app _[default: `Bumper`]_
  * _engines:_ Array of engines (in order of priority) to render your markup - [supported engines](https://github.com/tj/consolidate.js#supported-template-engines)
    * _css:_ _[default: `['sass', 'css']`]_
    * _html:_ _[default: `['pug', 'html']`]_
    * _js:_ _[default: `['coffee', 'js']`]_
* *env:*
  * _host:_ The host for your app _[default: `localhost`]_
  * _port:_ The port for your app _[default: `8383`]_
* *libs:* Optional object to pass into your library demo. e.g. If you want to pass `Hello World` into your `foo` library demo as a variable called `title`, `libs: { foo: { title: 'Hello World' }}`

### Run
`yarn start`

### To-Do
* libs  q
  * scrape `libs` for `package.json`'s and install their dependencies: `yarn install --cwd [CWD]`
  * init new webpack compiler for each lib: `webpack [--config webpack.config.js]``
  * each lib able to shim dependencies
