module.exports = {
  reporters: [
    ['{{reporterPath}}', {
      outputPath: '{{testReportPath}}',
      includeFailureMsg: true,
      styleOverridePath: '{{testCssPath}}'
    }]
  ]
}
