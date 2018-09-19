from cassandra.cluster import Cluster
cluster=Cluster(["inv01data"])
session = cluster.connect()

session.execute("use greencarrotinventoryreplicationstrategy")

session.execute("""
SELECT COUNT(*) 
FROM items_ordered_to_deliver_to_consumers 
WHERE partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47
""")

future=session.execute_async("SELECT  * FROM items_ordered_to_deliver_to_consumers WHERE  partition_for_polling = 6ab09bec-e68e-48d9-a5f8-97e6fb4c9b47 ORDER BY ordertime DESC LIMIT 1")
rows = future.result()
print("New incoming order detected! ...")
for row in rows:
    print(row)