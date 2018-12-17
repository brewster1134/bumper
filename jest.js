module.exports = {
  reporters: [
    ['./node_modules/jest-html-reporter', {
      outputPath: './.tmp/demo/test-results.html',
      includeFailureMsg: true,
      styleOverridePath: 'demo/styles/jest-html-reporter.css'
    }]
  ]
}
