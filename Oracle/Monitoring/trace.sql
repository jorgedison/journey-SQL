
SELECT            
 S.LAST_ACTIVE_TIME,     
 S.MODULE,
 S.SQL_FULLTEXT, 
 S.SQL_PROFILE,
 S.EXECUTIONS,
 S.LAST_LOAD_TIME,
 S.PARSING_USER_ID,
 S.SERVICE                                                                       
FROM
 SYS.V_$SQL S, 
 SYS.ALL_USERS U
WHERE
 S.PARSING_USER_ID=U.USER_ID 
-- AND UPPER(U.USERNAME) IN ('oracle user name here')   
ORDER BY TO_DATE(S.LAST_LOAD_TIME, 'YYYY-MM-DD/HH24:MI:SS') desc;
