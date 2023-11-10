# CDC with memory-optimised table

As of 2023-11-10 it is not possible to conduct CDC on memory-optimised table.

Accroding to microsoft docs.

```
SQL Server 2017 CU15 and higher support enabling CDC on a database that has memory optimized tables. This is only applicable to the database and any on-disk tables in the database. In earlier versions of SQL Server, CDC cannot be used with a database that has memory-optimized tables, because internally CDC uses a DDL trigger for DROP TABLE.
```

link:

https://learn.microsoft.com/en-us/sql/relational-databases/in-memory-oltp/unsupported-sql-server-features-for-in-memory-oltp?view=sql-server-ver16



## Possible Approaches

Use Temporal Table for CDC source.

https://learn.microsoft.com/en-us/sql/relational-databases/tables/system-versioned-temporal-tables-with-memory-optimized-tables?view=sql-server-ver16&redirectedfrom=MSDN


