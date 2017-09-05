;WITH BACKUP_CTE AS
(
    SELECT
        DATABASE_NAME,
        BACKUP_TYPE =
            CASE TYPE
                WHEN 'D' THEN 'FULL'
                WHEN 'L' THEN 'LOG'
                WHEN 'I' THEN 'DIFFERENTIAL'
                ELSE 'OTHER'
            END,
        BACKUP_FINISH_DATE,
        ROWNUM = 
            ROW_NUMBER() OVER
            (
                PARTITION BY DATABASE_NAME, TYPE 
                ORDER BY BACKUP_FINISH_DATE DESC
            )
    FROM MSDB.DBO.BACKUPSET
)
SELECT
    DATABASE_NAME,
    BACKUP_TYPE,
    BACKUP_FINISH_DATE
FROM BACKUP_CTE
--WHERE DATABASE_NAME='NOMNRE_BD'
--AND ROWNUM = 1
ORDER BY DATABASE_NAME;
