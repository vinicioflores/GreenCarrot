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
var db = monk('localhost:27028/GreenCarrotRutasDB');


// to connect to Azure SQL
//var Connection = require('tedious').Connection;
//var Request = require('tedious').Request;


// to connect to Cassandra
var cassandra = require('cassandra-driver');
var async = require('async');
var client = new cassandra.Client({contactPoints: ['localhost'],protocolOptions: { port: 9042 }, keyspace: 'GreenCarrotInventoryReplicationStrategy'});

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

module.exports = app;
