#
# download link, URL scheme @ http://docs.amazonwebservices.com/ElasticMapReduce/latest/DeveloperGuide/HiveJDBCDriver.html
#
# also need commons-logging from Apache
#

library(RJDBC)

hive.jdbc.jar.dir = '/usr/local/java/hive_jdbc'
hive.jdbc.jars = list.files(hive.jdbc.jar.dir, '*.jar')
hive.class.path = paste(hive.jdbc.jar.dir, hive.jdbc.jars, sep='/')

commons.jar.dir = '/usr/local/java/commons-logging'
commons.jars = list.files(commons.jar.dir, '^commons-logging-\\d.*\\..*\\d\\.jar')
commons.class.path = paste(commons.jar.dir, commons.jars, sep='/')

class.path=c(hive.class.path, commons.class.path)

drv <- JDBC("org.apache.hadoop.hive.jdbc.HiveDriver", classPath=class.path, "`")

# conn <- dbConnect(drv, "jdbc:hive://localhost:10003/default")
conn <- dbConnect(drv, "jdbc:hive://localhost:10000/default")

# setting the database name in the URL doesn't help, must issue 'use databasename':
res = dbSendQuery(conn, 'use default')

df = dbGetQuery(conn, "select * from airline where Year <> 'Year'")

# when done....

dbDisconnect(conn)
