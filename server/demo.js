// DEPENDENCIES
const express = require('express');
const fs= require('fs');
const path = require('path');
const webpack = require('webpack');
const webpackMiddleware = require('webpack-dev-middleware');
const yaml = require('js-yaml');

// USER CONFIGURATION
const configCustom = yaml.safeLoad(fs.readFileSync('config.yaml'));
const configDefaults = {
  port: parseInt(process.env.BUMPER_PORT) || 3000,
  title: 'Bumper',
  viewEngine: 'pug'
};
const config = Object.assign(configDefaults, configCustom);

// SERVER
const demo = express();
const webpackConfig = require('../webpack.config');
const webpackCompiler = webpack(webpackConfig);
demo.use(webpackMiddleware(webpackCompiler));
demo.set('views', path.join('server', 'views'));
demo.set('view engine', config.viewEngine);


// SERVER ROUTING
demo.get('/', (req, res) => res.render('index', { title: config.title }));

demo.listen(config.port, () => console.log('Bumper Demo running at http://localhost:' + config.port));