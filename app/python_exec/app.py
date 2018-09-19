from cassandra.cluster import Cluster
from pymongo import MongoClient
from bson.objectid import ObjectId

import datetime

#client = MongoClient('mongodb://router01:27028/')
client = MongoClient('mongodb://127.0.0.1:27028/')

db = client.GreenCarrotRutasDB
acquisitions=db.acquisitions
auditLog=db.auditLog
deliveries=db.deliveries
planrutas=db.planrutas
routes=db.routes
trucks=db.trucks

#cluster=Cluster(["inv01data"])
cluster=Cluster(["localhost"])
session = cluster.connect()

session.execute("use greencarrotinventoryreplicationstrategy")

lastLen = 1
dataLen = 0

while True:

    ## Poll for new incoming orders in Cassandra
    session = cluster.connect()
    cnt=session.execute("""
    SELECT COUNT(*)  as cnt
    FROM items_ordered_to_deliver_to_consumers 
    WHERE partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47
    """)

    dataLen = cnt[0].cnt
    
    if(lastLen < dataLen):
        future=session.execute_async("SELECT  * FROM items_ordered_to_deliver_to_consumers WHERE  partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 ORDER BY ordertime DESC LIMIT 1")
        rows = future.result()
        print("New incoming order detected! ...")
        
        ## add routes planning in MongoDB
        for row in rows:
            print(row)
            data = {}
            data['truckid'] = ObjectId("507f191e810c19729de860ea")
            data['name'] = "greenCarrot"
            data['assignedRoute']: row.delivery_route
            data['planned_position_order']: 3
            data['planned_stop_name']: row.delivery_stop_in_route
            data['planned_consumer_person']: row.username
            data['product_name']: row.productname
            data['product_family']: row.producttype
            data['payment_from_consumer_in_spot']: row.pay_in_consumer_spot
            data['payment_method']: row.payment_methods
            data['payment_amount']: row.cost
            data['completed']:False
            deliveries.insert_one(data)
            
    lastLen = dataLen
    
    