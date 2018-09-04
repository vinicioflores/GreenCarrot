CREATE KEYSPACE GreenCarrotInventoryReplicationStrategy
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 3};

USE GreenCarrotInventoryReplicationStrategy


// damaged good, stolen, returned ...
CREATE TABLE movements_types (
	movementid      uuid,
	movname 		text,
	desc 			text,

	PRIMARY KEY (movementid, movname)
)

// from web site, phone call, face to face, bill's signature, et c ...
CREATE TABLE confirmation_methods (
	methodid	uuid,
	name 		text,
	desc   		text,

	PRIMARY KEY (methodid, name)
)


CREATE TABLE product_families (
	familyid uuid,
	familyname    text,
	products set<frozen <productname>>,

	PRIMARY KEY (familyid, familyname)
)


CREATE TABLE items_movements (
	productid   	uuid,
	productname 	text,
	producttype 	text,   //familyname
	truck 			uuid,
	routename   	text, // reference to the existing route in Mongo where this article can be bought by a customer
	stopName		text,   // name of the stop within the route in which the article was provided or delivered - this ties to MongoDB 
	latitude		float, 
	longitude 		float,  // Cassandra does not support geolocation data types ... will store X/Y for further search in Mongo ...
	updatetime  	timestamp,
	movement_type   text,
	damaged_article boolean,
	stolen_article  boolean,
	stakeholder_involved text,   // a consumer name or a provider name - person
	receipt_or_sale_confirmed_by_stakeholder boolean,   // the confirmation that article was sold to us by the provider - or - delivered to customer
	receipt_or_sale_confirmation_method text,
	cost        	decimal,
		
	PRIMARY KEY ((truck,routename), producttype)	
)



// this table will behave as a summary/catalog being directly impacted by the items movements in table above (master-details design pattern)
CREATE TABLE inventory_per_truck (
	truck 	uuid,
	productid 	uuid,
	productname text,
	producttype text,
	existence_no  int, //amount of existences of the article within the truck in question
	acquired_time timestamp,
	acquired_stop text, // from within a certain route from Mongo
	acquired_in_route text,
	acquired_latitude float,
	acquired_longitude float,
	acquired_from_provider text, // a provider physical person's name
	delivered_time timestamp,
	delivered_stop text,
	delivered_in_route text,
	delivered_latitude float,
	delivered_longitude float,
	delivered_to_consumer text, //a customer's name
	still_in_truck_not_delivered boolean, // true: delivery related values above will be null

	PRIMARY KEY ((truck, productid), productname)
)



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

	PRIMARY KEY ((userid), productid)
)


CREATE TABLE payment_methods (
	methodid		uuid,
	methodname		text,
	methoddesc		text,

	PRIMARY KEY (methodid, methodname)
)

