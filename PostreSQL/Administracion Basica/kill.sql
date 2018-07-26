-- Elimina Transacciones abiertas

SELECT * FROM PG_STAT_ACTIVITY 

SELECT PG_CANCEL_BACKEND(PID)

SELECT PG_TERMINATE_BACKEND(PID)

-- Elimina transacciones con estado inactivo mayor a 10 minutos

WITH inactive_connections AS (
    SELECT
        pid,
        rank() over (partition by client_addr order by backend_start ASC) as rank
    FROM 
        pg_stat_activity
    WHERE
        pid <> pg_backend_pid( )
    --AND
    --    application_name like '%pgAdmin%' 
    AND
        state in ('idle', 'idle in transaction', 'idle in transaction (aborted)', 'disabled') 
    AND
      current_timestamp - state_change > interval '10 minutes' 
)
SELECT
    pg_terminate_backend(pid)
FROM
    inactive_connections 
WHERE
    rank > 1 

    select count(*) from pg_stat_activity;
    select * from pg_stat_activity; where 
select now()

-- Elimina todas las sesiones de la base de datos

SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE pg_stat_activity.datname = 'TARGET_DB' ← change this to your DB
  AND pid <> pg_backend_pid();
