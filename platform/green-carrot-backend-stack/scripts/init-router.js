sh.addShard("repsanjose/sj01:27019")
sh.addShard("repsanjose/sj02:27020")

sh.addShard("repcartago/ca01:27021")
sh.addShard("repcartago/ca02:27022")

sh.addShard("repalajuela/al01:27023")
sh.addShard("repalajuela/al02:27024")

sh.enableSharding("GreenCarrotRutasDB")
sh.shardCollection("GreenCarrotRutasDB.planrutas", { city : "hashed" } )