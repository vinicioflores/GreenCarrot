sh.addShard("repsanjose/sj01:27018")
sh.addShard("repsanjose/sj02:27018")

sh.addShard("repcartago/ca01:27019")
sh.addShard("repcartago/ca02:27019")

sh.addShard("repalajuela/al01:27020")
sh.addShard("repalajuela/al02:27020")

sh.enableSharding("GreenCarrotRutasDB")
sh.shardCollection("GreenCarrotRutasDB.planrutas", { city : "hashed" } )