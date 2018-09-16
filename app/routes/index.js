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



router.get('/startflow', function(req,res) {
    var lastLen = 0;
    var datalen = 0;
    var client = req.client;
    for(;;){
        // listen to cassandra - unfortunately there was no event listening implemented in datastax cassandra driver - so the dirty way!
           client.execute("SELECT COUNT(*) FROM items_ordered_to_deliver_to_consumers", function (err, result) {
               if (!err){
                   datalen = result.rows.length;
               }
           });
        lastLen=datalen;
        
        if(datalen > lastLen){
            // pull new order
            client.execute("SELECT * FROM items_ordered_to_deliver_to_consumers WHERE ordertime = MAX(ordertime)", function (err, result) {
               if (!err){
                   datalen = result.rows.length;
               }
           });               
                       
            // based on client's pick up location, insert route plan in MongoDB
        }
    }
    res.render(''); 
});


router.get('/newdeliveryrequest', function(req,res) {
    
    res.render(''); 
});



module.exports = router;
