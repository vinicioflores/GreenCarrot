CREATE KEYSPACE GreenCarrotInventoryReplicationStrategy
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3};

USE greencarrotinventoryreplicationstrategy;


// damaged good, stolen, returned ...
CREATE TABLE movements_types (
	movementid      uuid      PRIMARY KEY,
	movname 		text,
	description 	text
);


INSERT INTO movements_types (movementid,movname,description)
VALUES    (uuid(), 'Delivery', 'Delivery of a product to consumer client'),
		  (uuid(), 'Acquisition', 'Incorporation of new product to inventory by a provider/seller');


INSERT INTO movements_types (movementid,movname,description)
VALUES  (uuid(), 'Acquisition', 'Incorporation of new product to inventory by a provider/seller');

// from web site, phone call, face to face, bill's signature, et c ...
CREATE TABLE confirmation_methods (
	methodid    	uuid,
	name 		    text,
	description     text,
	PRIMARY KEY      (methodid, name)
)
WITH CLUSTERING ORDER BY (name DESC);

INSERT INTO confirmation_methods(methodid,name,description)
VALUES (uuid(), 'Manual bill signature', 'Signed the recept by hand');

CREATE TABLE product_families (
	familyid 	    uuid,
	familyname        text,
	products  		  set<text>,
	PRIMARY KEY    (familyid, familyname)
)
WITH CLUSTERING ORDER BY (familyname ASC);


CREATE TABLE items_movements (
	movementid 	     	uuid,
	productid        	uuid,
	productname 	     text,
	producttype 	    text,   //familyname
	truck 			    uuid,
	routename   	     text, // reference to the existing route in Mongo where this article can be bought by a customer
	stopName		    text,   // name of the stop within the route in which the article was provided or delivered - this ties to MongoDB 
	latitude		    float, 
	longitude 		     float,  // Cassandra does not support geolocation data types ... will store X/Y for further search in Mongo ...
	updatetime  	    timestamp,
	movement_type         uuid,
	damaged_article        boolean,
	stolen_article        boolean,
	stakeholder_involved      text,   // a consumer name or a provider name - person
	receipt_or_sale_confirmed_by_stakeholder       boolean,   // the confirmation that article was sold to us by the provider - or - delivered to customer
	receipt_or_sale_confirmation_method       uuid,
	cost               	decimal,
		
	PRIMARY KEY (receipt_or_sale_confirmed_by_stakeholder, updatetime)	
) WITH CLUSTERING ORDER BY (updatetime DESC);


 INSERT INTO items_movements(movementid,productid,productname,producttype,truck,routename,stopName,latitude,longitude,updatetime,movement_type,damaged_article,stolen_article,stakeholder_involved,    receipt_or_sale_confirmed_by_stakeholder,receipt_or_sale_confirmation_method, cost)
 VALUES(uuid(), 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47, 'Botas rojas vaqueras', 'Clothes', 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47, 'Estudiantes', 'UCR',34.4,-23.3,dateof(now()),bb0aacfb-e040-4e18-a2ae-3ca9995f76a1,false,false,'viniciof',true, 4275bae2-308e-4aea-9a57-d4517a9dc868, 35000.0);



 INSERT INTO items_movements(movementid,productid,productname,producttype,truck,routename,stopName,latitude,longitude,updatetime,movement_type,damaged_article,stolen_article,stakeholder_involved,    receipt_or_sale_confirmed_by_stakeholder,receipt_or_sale_confirmation_method, cost)
 VALUES(uuid(), 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47, 'Botas rojas sexys', 'Clothes', 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47, 'Estudiantes', 'UCR',34.4,-23.3,dateof(now()),bb0aacfb-e040-4e18-a2ae-3ca9995f76a1,false,false,'alvivar',true, 4275bae2-308e-4aea-9a57-d4517a9dc868, 35000.0);




// this table will behave as a summary/catalog being directly impacted by the items movements in table above (master-details design pattern)
CREATE TABLE inventory_per_truck_existence_counter (
	truck 	uuid,
	productid 	uuid,
	productname text,
	producttype text,
	existence_no  counter, //amount of existences of the article within the truck in question
	PRIMARY KEY (truck, productid, productname, producttype)
);

CREATE TABLE inventory_per_truck (
	truck 	uuid,
	productid 	uuid,
	productname text,
	producttype text,
	still_in_truck_not_delivered boolean, // true: delivery related values above will be null
	PRIMARY KEY (truck, productid, productname, producttype)
);

SELECT existence_no 
            FROM inventory_per_truck_existence_counter
            WHERE productid = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 and truck = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 
            and producttype = 'Clothes' and productname='Botas rojas sexys';

UPDATE inventory_per_truck_existence_counter 
SET  existence_no = existence_no + 19
WHERE productid = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 and truck = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 
            and producttype = 'Clothes' and productname='Botas rojas sexys';

UPDATE inventory_per_truck_existence_counter 
SET  existence_no = existence_no -1 
WHERE productid = uuid() and truck = uuid() and producttype = 'sss' and productname='zyx';

SELECT existence_no 
FROM inventory_per_truck_existence_counter
WHERE productid = uuid() and truck = uuid() and producttype = 'sss' and productname='zyx';

UPDATE inventory_per_truck 
SET still_in_truck_not_delivered = false
WHERE productid = uuid() and truck = uuid() and producttype = 'sss' and productname='zyx';


CREATE TABLE items_ordered_to_deliver_to_consumers (
	userid  							uuid,
	username							text,
	productid							uuid,
	productname							text,
	producttype							text,
	cost 								decimal,
	paid								boolean,
	pay_in_consumer_spot				boolean,
	payment_methods						text,
	preferred_radius_km_consumer_spot	int,
	delivery_route 						text,
	delivery_stop_in_route				text,
	delivery_latitude					float,
	delivery_longitude					float,
	ordertime_read_only					timestamp,
	ordertime   						timeuuid,
	partition_for_polling				uuid,
	PRIMARY KEY (partition_for_polling,ordertime)
) WITH CLUSTERING ORDER BY (ordertime DESC);


INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(5b6962dd-3f90-4c93-8f61-eabfa4a803e2,'viniciof',6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47,'Botas rojas vaqueras', 'Clothes',35000.0,false,true,'Cash',10,'Estudiantes','UCR',34.4,-23.3,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);

INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(uuid(),'alvivar',uuid(),'Botas rojas sexys', 'Clothes',45000.0,false,true,'Card',10,'Estudiantes','Mall San Pedro',34.1,-22.8,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);


INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(uuid(),'pedrito',uuid(),'Blusa roja sexy', 'Clothes',95000.0,false,true,'Card',5,'Estudiantes','Mall San Pedro',37.1,-20.8,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);


INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(uuid(),'robert',uuid(),'Blusa amarilla comoda', 'Clothes',95000.0,false,true,'Card',5,'Estudiantes','Mall San Pedro',37.1,-20.8,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);

INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(uuid(),'loco',uuid(),'Blusa amarilla comoda', 'Clothes',95000.0,false,true,'Card',5,'Estudiantes','Mall San Pedro',37.1,-20.8,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);

INSERT INTO items_ordered_to_deliver_to_consumers(userid,username,productid,productname,producttype,cost,paid,pay_in_consumer_spot,payment_methods,preferred_radius_km_consumer_spot,delivery_route,delivery_stop_in_route,delivery_latitude,delivery_longitude,ordertime_read_only,ordertime,partition_for_polling) VALUES(uuid(),'satan',uuid(),'Blusa amarilla comoda', 'Clothes',95000.0,false,true,'Card',5,'Estudiantes','UCR',34.4,-23.3,dateof(now()),now(),6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47);




SELECT  * FROM items_ordered_to_deliver_to_consumers WHERE  partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 ORDER BY ordertime DESC LIMIT 1;


CREATE TABLE payment_methods (
	methodid  uuid,
	methodname  text,
	methoddesc  text,
	PRIMARY KEY (methodid, methodname)
);




