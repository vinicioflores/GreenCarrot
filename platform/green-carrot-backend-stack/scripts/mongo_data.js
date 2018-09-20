use GreenCarrotRutasDB

db.createCollection("auditLog")


db.auditLog.insert({
	objectId: ObjectId("507f191e810c19729de860ea"),
	truck: "greenCarrot01", 
	visitime: new Date(), 
	routeName: "Estudiantes",
	location: { type: "Point", coordinates: [ -73.97, 40.77 ] },
	orderPosition: 1

})


db.createCollection("trucks")

db.trucks.insert({
	truckid: ObjectId("507f191e810c19729de860ea"),
	name: "greenCarrot01", 
	lastKnownOrderPositionInRoute: 1,
	assignedRoute: "Estudiantes"
})



db.trucks.insert({

})



db.createCollection("acquisitions")

db.acquisitions.insert({
	truckid: ObjectId("507f191e810c19729de860ea"),
	name: "greenCarrot01", 
	,assignedRoute: "Estudiantes",
	planned_position_order: 2,
	planned_stop_name: "Boutique Gala",
	planned_provider_person: "Jackie Meza",
	product_name: "Botas rojas vaqueras",
	product_family: "Calzado Femenino",
	payment_to_provider_in_spot: true,
	payment_method: "Cash",
	payment_amount: 35.000,
	completed:false
})


db.createCollection("deliveries")

db.deliveries.insert({
	truckid: ObjectId("507f1f77bcf86cd799439011"),
	name: "greenCarrot01", 
	assignedRoute: "Estudiantes",
	planned_position_order: 3,
	planned_stop_name: "Mall San Pedro",
	planned_consumer_person: "Rosa Navarro",
	product_name: "Botas rojas vaqueras",
	product_family: "Calzado Femenino",
	payment_from_consumer_in_spot: true,
	payment_method: "Tarjeta Credito",
	payment_amount: 45.000,
	completed:false
})

db.createCollection("routes")

db.routes.insert({ 
	city: "San Jose",  
	routeName:"Estudiantes",
	routeEnabled: true,
	stopName: "Zapateria La Casual",
	productType: "clothing",   
	location: { type: "Point", coordinates: [ -73.97, 40.77 ] },
	area: { type: "Polygon", coordinates: [[[1,4],[5,6],[7,9],[4,5]]] },
	role: "Provider",
	action: "Acquire incoming products from provider",
	currentlyRunning:true,
	order: 1

})

db.routes.insert({ 
	city: "San Jose",  
	routeName:"Estudiantes",
	routeEnabled: true,
	stopName: "Boutique Gala",
	productType: "clothing",   
	location: { type: "Point", coordinates: [ -73.34, 40.62 ] },
	area: { type: "Polygon", coordinates: [[[1,4],[5,6],[7,9],[4,5]]] },
	role: "Provider",
	action: "Acquire incoming products from provider",
	currentlyRunning:true,
	order: 2

})

db.routes.insert({ 
	city: "San Jose",  
	routeName:"Estudiantes",
	routeEnabled: true,
	stopName: "Mall San Pedro",   
	location: { type: "Point", coordinates: [ -73.90, 40.70 ] },
	area: { type: "Polygon", coordinates: [[[1,4],[5,6],[7,9],[4,5]]] },
	role: "Consumer",
	action: "Wait for consumers to gather around this stop",
	currentlyRunning:true,
	order: 3
})


db.routes.insert({ 
	city: "San Jose",  
	routeName:"Estudiantes",
	routeEnabled: true,
	stopName: "UCR",   
	location: { type: "Point", coordinates: [ -73.70, 40.60 ] },
	area: { type: "Polygon", coordinates: [[[1,4],[5,6],[7,9],[4,5]]] },
	role: "Consumer",
	action: "Wait for consumers to gather around this stop",
	currentlyRunning:true,
	order: 4
})


db.routes.createIndex( { location: "2dsphere", routeName: 1, order: 1 } )



db.routes.find({ route: "Estudiantes" }).sort({order: 1}) 



db.routes.find(
   {
     area: {
       $geoWithin: {
          $geometry: {
             type : "Polygon" ,
             coordinates: [ [ [ 0, 0 ], [ 3, 6 ], [ 6, 1 ], [ 0, 0 ] ] ] 
          }
       }
     }
   }
)



