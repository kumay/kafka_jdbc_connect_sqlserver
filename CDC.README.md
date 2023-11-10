# CDC with memory-optimised table

As of 2023-11-10 it is not possible to conduct CDC on memory-optimised table.

Accroding to microsoft docs.

```
SQL Server 2017 CU15 and higher support enabling CDC on a database that has memory optimized tables. This is only applicable to the database and any on-disk tables in the database. In earlier versions of SQL Server, CDC cannot be used with a database that has memory-optimized tables, because internally CDC uses a DDL trigger for DROP TABLE.
```

link:

https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/unsupported-sql-server-features-for-in-memory-oltp?view=sql-server-ver16



## Possible Approaches

**Use Temporal Table for CDC source.**

https://learn.microsoft.com/en-us/sql/relational-databases/tables/system-versioned-temporal-tables-with-memory-optimized-tables?view=sql-server-ver16&redirectedfrom=MSDN


**Enabling CDC for Azure SQl**

https://learn.microsoft.com/en-us/samples/azure-samples/azure-sql-db-change-stream-debezium/azure-sql%2D%2Dsql-server-change-stream-with-debezium/



**Debizium - set up SQL server for CDC**

https://debezium.io/documentation/reference/2.4/connectors/sqlserver.html#setting-up-sqlserver



## Error

After executing follwoing to the table, we got schema error.

```
-- for CDC preparation --

ALTER TABLE users
  add
    SysStartTime datetime2 generated always as row start not null default getutcdate(),
    SysEndTime   datetime2 generated always as row end   not null default convert(datetime2, '9999-12-31 23:59:59.9999999'),
    period for system_time (SysStartTime, SysEndTime);
GO

ALTER TABLE users
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.[users_History]))
GO
```

Error message:

```
[2023-11-10 00:47:27,695] ERROR Error encountered in task mssql-to-users-0. Executing stage 'VALUE_CONVERTER' with class 'io.confluent.connect.avro.AvroConverter', where source record is = SourceRecord{sourcePartition={protocol=1, table=mydb.dbo.users}, sourceOffset={timestamp_nanos=765000000, timestamp=1519264804765}} ConnectRecord{topic='sqlserver-users', kafkaPartition=null, key=null, keySchema=null, value=Struct{ID=1190,userid=User_8,regionid=Region_8,gender=FEMALE,registertime=2018-02-22 02:00:04.765,SysStartTime=2023-11-10 00:47:25.7975555,SysEndTime=9999-12-31 23:59:59.9999999}, valueSchema=Schema{users:STRUCT}, timestamp=null, headers=ConnectHeaders(headers=)}. (org.apache.kafka.connect.runtime.errors.LogReporter)
org.apache.kafka.common.config.ConfigException: Failed to access Avro data from topic sqlserver-users : Schema being registered is incompatible with an earlier schema for subject "sqlserver-users-value", details: [{errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysStartTime' at path '/fields/5' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysStartTime'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysEndTime' at path '/fields/6' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysEndTime'}, {oldSchemaVersion: 1}, {oldSchema: '{"type":"record","name":"users","fields":[{"name":"ID","type":"int"},{"name":"userid","type":["null","string"],"default":null},{"name":"regionid","type":["null","string"],"default":null},{"name":"gender","type":["null","string"],"default":null},{"name":"registertime","type":["null",{"type":"long","connect.version":1,"connect.name":"org.apache.kafka.connect.data.Timestamp","logicalType":"timestamp-millis"}],"default":null}],"connect.name":"users"}'}, {compatibility: 'BACKWARD'}]; error code: 409
```


```
2023-11-10 00:58:50,019] INFO Begin using SQL query: SELECT * FROM "mydb"."dbo"."users" WHERE "mydb"."dbo"."users"."registertime" > ? AND "mydb"."dbo"."users"."registertime" < ? ORDER BY "mydb"."dbo"."users"."registertime" ASC (io.confluent.connect.jdbc.source.TableQuerier)
[2023-11-10 00:58:50,050] ERROR Error encountered in task mssql-to-users-0. Executing stage 'VALUE_CONVERTER' with class 'io.confluent.connect.avro.AvroConverter', where source record is = SourceRecord{sourcePartition={protocol=1, table=mydb.dbo.users}, sourceOffset={timestamp_nanos=608000000, timestamp=1519249723608}} ConnectRecord{topic='sqlserver-users', kafkaPartition=null, key=null, keySchema=null, value=Struct{ID=1709,userid=User_2,regionid=Region_2,gender=FEMALE,registertime=2018-02-21 21:48:43.608,SysStartTime=2023-11-10 00:49:37.1278585,SysEndTime=9999-12-31 23:59:59.9999999}, valueSchema=Schema{users:STRUCT}, timestamp=null, headers=ConnectHeaders(headers=)}. (org.apache.kafka.connect.runtime.errors.LogReporter)
org.apache.kafka.common.config.ConfigException: Failed to access Avro data from topic sqlserver-users : Schema being registered is incompatible with an earlier schema for subject "sqlserver-users-value", details: [{errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysStartTime' at path '/fields/5' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysStartTime'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysEndTime' at path '/fields/6' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysEndTime'}, {oldSchemaVersion: 1}, {oldSchema: '{"type":"record","name":"users","fields":[{"name":"ID","type":"int"},{"name":"userid","type":["null","string"],"default":null},{"name":"regionid","type":["null","string"],"default":null},{"name":"gender","type":["null","string"],"default":null},{"name":"registertime","type":["null",{"type":"long","connect.version":1,"connect.name":"org.apache.kafka.connect.data.Timestamp","logicalType":"timestamp-millis"}],"default":null}],"connect.name":"users"}'}, {compatibility: 'BACKWARD'}]; error code: 409
        at io.confluent.connect.avro.AvroConverter.fromConnectData(AvroConverter.java:112)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.lambda$convertTransformedRecord$9(AbstractWorkerSourceTask.java:504)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execAndRetry(RetryWithToleranceOperator.java:190)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execAndHandleError(RetryWithToleranceOperator.java:224)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execute(RetryWithToleranceOperator.java:166)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.convertTransformedRecord(AbstractWorkerSourceTask.java:504)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.sendRecords(AbstractWorkerSourceTask.java:401)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.execute(AbstractWorkerSourceTask.java:364)
        at org.apache.kafka.connect.runtime.WorkerTask.doRun(WorkerTask.java:213)
        at org.apache.kafka.connect.runtime.WorkerTask.run(WorkerTask.java:268)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.run(AbstractWorkerSourceTask.java:78)
        at org.apache.kafka.connect.runtime.isolation.Plugins.lambda$withClassLoader$1(Plugins.java:177)
        at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)
        at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
        at java.base/java.lang.Thread.run(Thread.java:829)
[2023-11-10 00:58:50,051] ERROR WorkerSourceTask{id=mssql-to-users-0} Task threw an uncaught and unrecoverable exception. Task is being killed and will not recover until manually restarted (org.apache.kafka.connect.runtime.WorkerTask)
org.apache.kafka.connect.errors.ConnectException: Tolerance exceeded in error handler
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execAndHandleError(RetryWithToleranceOperator.java:244)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execute(RetryWithToleranceOperator.java:166)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.convertTransformedRecord(AbstractWorkerSourceTask.java:504)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.sendRecords(AbstractWorkerSourceTask.java:401)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.execute(AbstractWorkerSourceTask.java:364)
        at org.apache.kafka.connect.runtime.WorkerTask.doRun(WorkerTask.java:213)
        at org.apache.kafka.connect.runtime.WorkerTask.run(WorkerTask.java:268)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.run(AbstractWorkerSourceTask.java:78)
        at org.apache.kafka.connect.runtime.isolation.Plugins.lambda$withClassLoader$1(Plugins.java:177)
        at java.base/java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:515)
        at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:264)
        at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1128)
        at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:628)
        at java.base/java.lang.Thread.run(Thread.java:829)
Caused by: org.apache.kafka.common.config.ConfigException: Failed to access Avro data from topic sqlserver-users : Schema being registered is incompatible with an earlier schema for subject "sqlserver-users-value", details: [{errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysStartTime' at path '/fields/5' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysStartTime'}, {errorType:'READER_FIELD_MISSING_DEFAULT_VALUE', description:'The field 'SysEndTime' at path '/fields/6' in the new schema has no default value and is missing in the old schema', additionalInfo:'SysEndTime'}, {oldSchemaVersion: 1}, {oldSchema: '{"type":"record","name":"users","fields":[{"name":"ID","type":"int"},{"name":"userid","type":["null","string"],"default":null},{"name":"regionid","type":["null","string"],"default":null},{"name":"gender","type":["null","string"],"default":null},{"name":"registertime","type":["null",{"type":"long","connect.version":1,"connect.name":"org.apache.kafka.connect.data.Timestamp","logicalType":"timestamp-millis"}],"default":null}],"connect.name":"users"}'}, {compatibility: 'BACKWARD'}]; error code: 409
        at io.confluent.connect.avro.AvroConverter.fromConnectData(AvroConverter.java:112)
        at org.apache.kafka.connect.runtime.AbstractWorkerSourceTask.lambda$convertTransformedRecord$9(AbstractWorkerSourceTask.java:504)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execAndRetry(RetryWithToleranceOperator.java:190)
        at org.apache.kafka.connect.runtime.errors.RetryWithToleranceOperator.execAndHandleError(RetryWithToleranceOperator.java:224)
        ... 13 more
```