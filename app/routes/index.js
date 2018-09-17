var express = require('express');
var router = express.Router();
var debug = require('debug')
var log = debug('app:log')
var async = require('async');

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



router.get('/startflow', function(req,res) {
    
    res.render('incomingOrder', {"incomingOrder" : incomingOrder}); 
});


router.get('/newdeliveryrequest', function(req,res) {
    
    res.render(''); 
});



module.exports = router;
