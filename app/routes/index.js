var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
//    var db = req.db;
   // db.driver.collectionNames(function(e,names){
//    res.json(names);
  //})
});


/* GET hello world page. */
router.get('/helloworld', function(req, res) {
  res.render('helloworld', { title: 'Hello, World!' });
});

/* GET Mongo routes list. */
router.get('/routes', function(req, res) {
    var db = req.db;
    var collection = db.get('routes');
    collection.find({},function(e,docs){
        res.render('routes', {
            "routes" : docs
        });
    });
});

module.exports = router;
