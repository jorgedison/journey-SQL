USE BD_SGAC_G2
GO

--SELECT * FROM 
SELECT
DB_name()
,sp.name 
,dp.name    
,dp2.name
,dp.type_desc
,perm.permission_name
, objectType = case perm.class
when 1 then obj.type_desc
else perm.class_desc
end
, objectName = case perm.class
when 1 then Object_name(perm.major_id)
when 3 then schem.name
when 4 then imp.name
end
, col.name
FROM
sys.database_role_members drm
right join sys.database_principals dp
on dp.principal_id = drm.member_principal_id 
left join sys.database_principals dp2 on dp2.principal_id = drm.role_principal_id full 
JOIN sys.server_principals sp ON dp.[sid] = sp.[sid] 
LEFT JOIN sys.database_permissions perm ON perm.[grantee_principal_id] = dp.[principal_id] 
LEFT JOIN sys.columns col ON col.[object_id] = perm.major_id AND col.[column_id] = perm.[minor_id] 
LEFT JOIN sys.objects obj ON perm.[major_id] = obj.[object_id] 
LEFT JOIN sys.schemas schem ON schem.[schema_id] = perm.[major_id] 
LEFT JOIN sys.database_principals imp ON imp.[principal_id] = perm.[major_id] 
where dp.name not in ('sys' , 'information_schema' , 'guest', 'public') Order by sp.name 

