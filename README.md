# kafka_jdbc_connect_sqlserver_example

## 目的：
JDBC source/sink connector を利用してMS SQL ServerのMemory-Optimizaed Tableへデータの入出力を行う。
操作はなるべくGUIで行った。（dockerの操作だけコマンドライン）

## 必要なアプリケーション

- docker (docker-composeが実行できる)  version 4.19.0 (106363)
- SSMS（sql serverに対してSQLを実行したりする）
  (https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16)
- browser (C3にアクセスして操作するため) なんでも。


### 利用コンテナイメージ:

confluent cp 7.4.0

	-  broker (confluent server)
	-  zookeeper
	-  schemaregistry
	-  ksqldb
	-  control-center
	-  rest-proxy
	-  connect -> based on cp 7.4.0 but included some connectors like jdbc connectors.


#### connect docker imageの作成

```
$ docker build . -f connect.Dockerfile -t "connect:0.1.0"
```
docker-composeではconnect:0.1.0と記載しているためここではタグをconnect:0.1.0としている。


* 利用している driverのリンク*
https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.22/mysql-connector-java-8.0.22.jar
https://github.com/microsoft/mssql-jdbc/releases

今回は、JDBC connectorに付随するデフォルトのjtlsのドライバーではなく、　Microsoft のドライバを利用している。



## JDBC connectors　作成用JSONファイル

### Source connector
mssql_source_connector.json


### sink connector
mssql_sink_connector.json


### datagen source connector
datagen_source_connector.json



## 手順（Procedure）

1. Connect のイメージをビルドする。
```
$ docker build . -f connect.Dockerfile -t 0.1.0
```

2. SQLserverとKafkaの環境を立ち上げる
```
$　docker-compose up 
```

3. SSMSからSQL server にログインして以下のSQL を実行する。
```
SQLQuery_MemOptimized_Table.sql
```

作成されるもの：
	DB    = mydb
	Table = users

DBはMemory-Optimize Table用の設定が含まれる状態で作成される。
TableはMemory-Optimized Tableとして作成される。


4. Control Center (http://127.0.0.1:9021) をブラウザで開けて、コネクタを作成する。
作成するコネクタは以下の順序で作成する。

```
事前準備
1. usersのtopicを作成する。

「Connect」のページから「Upload connector config file」を利用して以下の順番でコネクタを作成する。
1. datagen_source_connector.json　
2. mssql_sink_connector.json
3. mssql_source_connector.json
```

5. Control Center とSSMSからデータが入っているかを確認する。

Control CenterのTopicに以下の３つが作成されていることを確認する。
- sqlserver-users
- users	

※データが入っていることも確認する.


SSMSからDB:mydbのusersテーブルにデータが入っていることを確認する。
```
USER mydb;
GO
SELECT * FROM users;
GO
```


### メモ

#### JDBC sink connector

We can store data to memory_optimized table
Sink connectorでは特に設定は必要でなかった


#### JDBC source connector

Source connector ではSQL serverに作ったDBに設定の変更を行う必要がある。
*We need following setting enebaled in DB of where Table exists.*

```
ALTER DATABASE CURRENT 
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON
GO
```


### Errors (エラー)

Following setting cause SQL error.
```
"mode": "incrementing",
"incrementing.column.name": "id",
```

Error message
```
[2023-11-09 01:52:12,715] ERROR SQL exception while running query for table: TimestampIncrementingTableQuerier{table="mydb"."dbo"."users", query='null', topicPrefix='sqlserver-', incrementingColumn='ID', timestampColumns=[]}, com.microsoft.sqlserver.jdbc.SQLServerException: Accessing memory optimized tables using the READ COMMITTED isolation level is supported only for autocommit transactions. It is not supported for explicit or implicit transactions. Provide a supported isolation level for the memory optimized table using a table hint, such as WITH (SNAPSHOT).. Attempting retry 3 of -1 attempts. (io.confluent.connect.jdbc.source.JdbcSourceTask)
```

Following setting cause SQL error.
```
"mode": "timestamp",
"incrementing.column.name": "registertime",
```

Error Message
```
[2023-11-09 01:57:25,336] ERROR SQL exception while running query for table: TimestampTableQuerier{table="mydb"."dbo"."users", query='null', topicPrefix='sqlserver-', timestampColumns=[registertime]}, com.microsoft.sqlserver.jdbc.SQLServerException: Accessing memory optimized tables using the READ COMMITTED isolation level is supported only for autocommit transactions. It is not supported for explicit or implicit transactions. Provide a supported isolation level for the memory optimized table using a table hint, such as WITH (SNAPSHOT).. Attempting retry 2 of -1 attempts. (io.confluent.connect.jdbc.source.JdbcSourceTask)```
```




