"use strict";
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var debug = require('debug')
var log = debug('app:log')


// bind log to console for debugging
log.log = console.info.bind(console);
debug.log = console.info.bind(console);

// to connect to MongoDB
var mongo = require('mongodb');
var monk = require('monk');
var db = monk('router01:27028/GreenCarrotRutasDB');


// to connect to Azure SQL
//var Connection = require('tedious').Connection;
//var Request = require('tedious').Request;


// to connect to Cassandra
const cassandra = require('dse-driver');
var async = require('async');
const client = new cassandra.Client({contactPoints: ['127.0.0.1:9042','127.0.0.1:9142','127.0.0.1:9242'],keyspace: 'greencarrotinventoryreplicationstrategy'});
//const client = new cassandra.Client({contactPoints: ['110.10.0.9','110.10.0.10','110.10.0.11'],keyspace: 'greencarrotinventoryreplicationstrategy'});

console.log('Connected to cluster with %d host(s): %j', client.hosts.length, client.hosts.keys());
console.log('Keyspaces: %j', Object.keys(client.metadata.keyspaces));




client.on('log', function(level, className, message, furtherInfo) {
  console.log('log event: %s -- %s', level, message);
});

client.connect()
  .then(function () {
    console.log('Connected to cluster with %d host(s): %j', client.hosts.length, client.hosts.keys());
    console.log('Keyspaces: %j', Object.keys(client.metadata.keyspaces));
  })
  .catch(function (err) {
    console.error('There was an error when connecting', err);
    return client.shutdown();
  });


client.connect(function (err) {
  assert.ifError(err);
});

console.log('Connected to cluster with %d host(s): %j', client.hosts.length, client.hosts.keys());
console.log('Keyspaces: %j', Object.keys(client.metadata.keyspaces));

const state = client.getState();
for (let host of state.getConnectedHosts()) {
  console.log('Host %s: open connections = %d; in flight queries = %d',
    host.address, state.getOpenConnections(host), state.getInFlightQueries(host));
}

var indexRouter = require('./routes/index');
var routesRouter = require('./routes/routes');
var execFlowRouter = require('./routes/startflow');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');


app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


// Make our Mongo DB accessible to our router
app.use(function(req,res,next){
    req.db = db;
    next();
});


// Make our Cassandra DB accessible to our router
app.use(function(req,res,next){
    req.client = client;
    next();
});

// Create connection to SQL database
/*var config = 
   {
     userName: 'alvivar', // update me
     password: '5QDuF8jtZFcCe6i5', // update me
     server: 'alvivar2.database.windows.net', // update me
     options: 
        {
           database: 'GreenCarrot' //update me
           , encrypt: true
        }
   }
var connection = new Connection(config);

// Attempt to connect and execute queries if connection goes through
connection.on('connect', function(err) 
   {
     if (err) 
       {
          console.log(err)
       }
    else
       {
           queryDatabase()
       }
   }
 );
*/
app.use('/', indexRouter);
app.use('/routes', routesRouter);
app.use('/startflow', execFlowRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});




//// Poll for new orders in Cassandra
var lastLen = 0;
var datalen = 0;

for(;;){
    
    
client.connect()
  .then(function () {
    console.log('Connected to cluster with %d host(s): %j', client.hosts.length, client.hosts.keys());
    console.log('Keyspaces: %j', Object.keys(client.metadata.keyspaces));
  })
  .catch(function (err) {
    console.error('There was an error when connecting', err);
    return client.shutdown();
  });

 /*   if(client.connected)
        console.log("Polling for any new orders ....");
    else
        console.warn("Client is not connected yet ...");
   */ 
    // listen to cassandra - unfortunately there was no event listening implemented in datastax cassandra driver - so the dirty way!
    client.execute("SELECT COUNT(*) FROM items_ordered_to_deliver_to_consumers WHERE partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47",
        function(err, result) {
        if(!err && result){
            datalen = result.rows.length;
            console.log("Current orders: %d", datalen);
        }
        else {
            console.log("Something is wrong ... ");
            console.error(err);
        }
    });
    
    lastLen=datalen;
        
    var incomingOrder = 0
    if(datalen > lastLen){
        // pull new order
        client.execute("SELECT  * FROM items_ordered_to_deliver_to_consumers WHERE  partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 ORDER BY ordertime DESC LIMIT 1", 
            function (err, result) {
                if (!err){
                    incomingOrder=result.rows[0];
                    console.log("New incoming order detected: ");
                    console.log(incomingOrder);
                }
        });                              
            // based on client's pick up location, insert route plan in MongoDB
    }
}







 client.shutdown();


module.exports = app;
