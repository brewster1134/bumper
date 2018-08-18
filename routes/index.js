var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Bumper' });
});

router.get('/silo/*', function(req, res, next) {
  var libs = req.params['0'].split('/');
  res.render('silo', { title: 'Bumper:Silo', libs: libs });
});

module.exports = router;
