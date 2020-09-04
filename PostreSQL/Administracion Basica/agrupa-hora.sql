SELECT date_trunc('hour', dreadtimestamp) AS hour, TO_CHAR(date_trunc('hour', dreadtimestamp), 'day') as day,
       count(dreadtimestamp) AS cant
	  -- to_char(dreadtimestamp, 'Dy') as dy
FROM   "schema"."table" 
WHERE dreadtimestamp >='2020-08-01 00:00:00' and dreadtimestamp<'2020-09-01 00:00:00'
group by date_trunc('hour', dreadtimestamp)--, dreadtimestamp
ORDER  BY 1 desc
