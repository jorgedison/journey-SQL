SELECT '['+SCHEMA_NAME(schema_id)+']' as x FROM sys.tables
group by '['+SCHEMA_NAME(schema_id)+']'
