module.exports = {
  reporters: [
  	['./node_modules/jest-html-reporter', {
  		outputPath: './.tmp/test-report.html',
      includeFailureMsg: true,
      theme: 'lightTheme'
  	}]
  ]
}
