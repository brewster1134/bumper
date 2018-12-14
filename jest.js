module.exports = {
  reporters: [
    ['./node_modules/jest-html-reporter', {
      outputPath: './.tmp/test-results.html',
      includeFailureMsg: true,
      theme: 'lightTheme'
    }]
  ]
}
