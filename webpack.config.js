const path = require('path');
const Write = require('write-file-webpack-plugin');
const Extract = require('mini-css-extract-plugin');

module.exports = [
  {
    name: 'server js',
    mode: 'development',
    entry: path.resolve(__dirname, 'server', 'src', 'scripts', 'demo.coffee'),
    output: {
      path: path.resolve(__dirname, 'server', '.dist', 'scripts'),
      filename: 'demo.js'
    },
    plugins: [
      new Write()
    ],
    module: {
      rules: [
        {
          test: /\.coffee$/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: ['babel-preset-env']
              }
            },
            { loader: 'coffee-loader' }
          ]
        }
      ]    
    }
  },
  {
    name: 'server css',
    mode: 'development',
    entry: path.resolve(__dirname, 'server', 'src', 'styles', 'demo.sass'),
    output: {
      path: path.resolve(__dirname, 'server', '.dist', 'styles'),
      filename: '[name].css'
    },
    plugins: [
      new Write(),
      new Extract({
        filename: 'demo.css'
      })
    ],
    module: {
      rules: [
        {
          test: /\.sass/,
          use: [
            { loader: Extract.loader },
            { loader: 'css-loader' },
            { loader: 'sass-loader' }
          ]
        }
      ]    
    }
  }
]
