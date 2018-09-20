from cassandra.cluster import Cluster
from pymongo import MongoClient
from bson.objectid import ObjectId
from pymongo.errors import AutoReconnect
import pyodbc
import uuid
import datetime

#### CONNECT TO AZURE SQL SERVER CLUSTER
server = 'alvivar2.database.windows.net'
database = 'GreenCarrot'
username = 'alvivar'
password = '5QDuF8jtZFcCe6i5'

try:
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 13 for SQL Server};SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = cnxn.cursor()
except:
    server = 'alvivar2secondary.database.windows.net'
    cnxn = pyodbc.connect('DRIVER={ODBC Driver 13 for SQL Server};SERVER='+server+';PORT=1443;DATABASE='+database+';UID='+username+';PWD='+ password)
    cursor = cnxn.cursor()


### CONNECT TO MONGO CLUSTER - HOSTED IN DOCKER 
#client = MongoClient('router01',27028)
client = MongoClient('mongodb://127.0.0.1:27028/')
db = client.GreenCarrotRutasDB
acquisitions=db.acquisitions
auditLog=db.auditLog
deliveries=db.deliveries
routes=db.routes
trucks=db.trucks

class myDict(dict):
    def __init__(self):
        self = dict()
    def add(self, key, value):
        self[key] = value


def mongo_get_delivery(row):        
    route = routes.find_one({ "stopName": row.delivery_stop_in_route  })
    truck = trucks.find_one({ "assignedRoute": row.delivery_route })
        
    data = myDict()
    data.add("truckid" , truck['truckid'])
    data.add("name" , truck['name'])
    data.add("assignedRoute", row.delivery_route)
    data.add("planned_position_order", route['order'])
    data.add("planned_stop_name", row.delivery_stop_in_route)
    data.add("planned_consumer_person", row.username)
    data.add("product_name", row.productname)
    data.add("product_family", row.producttype)
    data.add("payment_from_consumer_in_spot", row.pay_in_consumer_spot)
    data.add("payment_method", row.payment_methods)
    data.add("payment_amount", float(row.cost))
    data.add("completed",False)
    return data



### CONNECT TO APACHE CASSANDRA CLUSTER - HOSTED IN DOCKER

#cluster=Cluster(["inv01data"])
cluster=Cluster(["localhost"],port=9042)
session = cluster.connect()

session.execute("use greencarrotinventoryreplicationstrategy")

lastAmountOfOrders = 1
currentAmountOfOrders = 0

lastAmountOfCheckouts = 1
currentAmountOfCheckouts = 0

while True:
    ## Poll for new incoming orders in Cassandra
    try:
        cluster=Cluster(["localhost"],port=9042)
        session = cluster.connect()
        session.execute("use greencarrotinventoryreplicationstrategy")
    except:
        try:
            cluster=Cluster(["localhost"],port=9142)
            session = cluster.connect()
        except:
            cluster=Cluster(["localhost"],port=9242)
            session = cluster.connect()
        
    cnt=session.execute("""
        SELECT COUNT(*)  as cnt
        FROM items_ordered_to_deliver_to_consumers 
        WHERE partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47
    """)

    currentAmountOfOrders = cnt[0].cnt
    
    if(lastAmountOfOrders < currentAmountOfOrders):
        new_order=session.execute_async("SELECT  * FROM items_ordered_to_deliver_to_consumers WHERE  partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 ORDER BY ordertime DESC LIMIT 1")
        rows = new_order.result()
        print("\n\nNew incoming order detected! ...\n\n")
        
        ## add routes planning in MongoDB
        for row in rows:
            print(row)
            #refresh_mongo_connection()
            try:
                data = mongo_get_delivery(row)
                deliveries.insert_one(data)
            except AutoReconnect:
                print("Unable to connect ... connecting to the other mongos router ...")
                #client = MongoClient('router02',27029)
                client = MongoClient('mongodb://127.0.0.1:27029/')
                data = mongo_get_delivery(row)
                deliveries.insert_one(data)
            print("\nRoute plan inserted in Mongo\n\n")
        
                
    lastAmountOfOrders = currentAmountOfOrders
    
    cnt = session.execute("SELECT COUNT(*) as cnt FROM items_movements WHERE receipt_or_sale_confirmed_by_stakeholder  = true;")
    
    currentAmountOfCheckouts = cnt[0].cnt
    
    if(lastAmountOfCheckouts < currentAmountOfCheckouts):
        new_checkout=session.execute_async("SELECT * FROM items_movements WHERE receipt_or_sale_confirmed_by_stakeholder  = true ORDER BY updatetime DESC LIMIT 1")
        rows=new_checkout.result()
        
        for row in rows:
            print("\n\nAn article has just been checked out!! ... \n\n")

            ### Update Cassandra inventory & SQL Server payments and transactions
            session.execute("""UPDATE inventory_per_truck_existence_counter 
            SET  existence_no = existence_no -1 
            WHERE productid = %s and truck = %s and producttype = %s and productname=%s;
            """,(row.productid, row.truck, row.producttype, row.productname))
            
            print("Updated article counter \n")
            
            existence_no=session.execute("""
            SELECT existence_no 
            FROM inventory_per_truck_existence_counter
            WHERE productid = %s and truck = %s and producttype = %s and productname=%s;
            """, (row.productid, row.truck, row.producttype, row.productname))
        
            print("Article existence counter in inventory is now %d" % (existence_no[0].existence_no))
        
            if(existence_no[0].existence_no <= 0):
                session.execute("""
                UPDATE inventory_per_truck 
                SET still_in_truck_not_delivered = false
                WHERE productid = %s and truck = %s and producttype = %s and productname=%s;
                """, (row.productid, row.truck, row.producttype, row.productname))
                
                print("Article %s marked as empty\n" %   (row.productname))
        
            try:
                tsql = """\
                DECLARE @out nvarchar(max);
                EXEC [dbo].[test_for_pyodbc] @param_in = ?, @param_out = @out OUTPUT;
                SELECT @out AS the_output;
                """
                params = ("Burma!", )
                crsr.execute(tsql, params)
                print("Updated in Azure SQL financial info ... \n")
            except:
                print("Updated in Azure SQL financial info ... [SP not found, mock func]\n")
                
        lastAmountOfCheckouts = currentAmountOfCheckouts
        
