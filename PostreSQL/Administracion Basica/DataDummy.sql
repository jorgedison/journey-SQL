#1
SELECT 'HTWWWW-' ||generate_series(10000,96000), 'SSSSSSS-' ||generate_series(10000,96000), 
generate_series(10000,96000), generate_series(10000,96000), 
			now(), now(), 
			generate_series(10000,96000), 'MEMDDDD-' ||generate_series(10000,96000), 
			'HDDDDDT-' ||generate_series(10000,96000), 
      'HT44444-' ||generate_series(10000,96000), 'HT4444-' ||generate_series(10000,96000);
			
#2
CREATE TABLE t_random AS SELECT s, md5(random()::text) FROM generate_Series(1,5) s;
INSERT INTO t_random VALUES (generate_series(1,100), md5(random()::text));

SELECT pg_size_pretty(pg_relation_size('t_random'));
