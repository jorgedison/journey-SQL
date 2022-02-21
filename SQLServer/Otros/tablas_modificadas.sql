select
    object_name(object_id) as OBJ_NAME, dm_db_index_usage_stats.last_user_update, *
from
    sys.dm_db_index_usage_stats
where
    database_id = db_id(db_name())
order by
    dm_db_index_usage_stats.last_user_update desc
