USE [DATABASE]
GO

CREATE TABLE Usuarios
(
Codigo INT PRIMARY KEY,
Nombre VARCHAR(100),
Puntos INT
)
GO
INSERT INTO Usuarios VALUES
(1,'Juan Perez',10),
(2,'Marco Salgado',5),
(3,'Carlos Soto',9),
(4,'Alberto Ruiz',12),
(5,'Alejandro Castro',5)
GO
CREATE TABLE UsuariosActual
(
Codigo INT PRIMARY KEY,
Nombre VARCHAR(100),
Puntos INT
)
GO
INSERT INTO UsuariosActual VALUES
(1,'Juan Perez',12),
(2,'Marco Salgado',11),
(4,'Alberto Ruiz Castro',4),
(5,'Alejandro Castro',5),
(6,'Pablo Ramos',8)

SELECT * FROM Usuarios
SELECT * FROM UsuariosActual

--Sincronizar la tabla TARGET con
--los datos actuales de la tabla SOURCE
MERGE Usuarios AS TARGET
USING UsuariosActual AS SOURCE
ON (TARGET.Codigo = SOURCE.Codigo)
--Cuandos los registros concuerdan por la llave
--se actualizan los registros si tienen alguna variación
WHEN MATCHED AND TARGET.Nombre <> SOURCE.Nombre
OR TARGET.Puntos <> SOURCE.Puntos THEN
UPDATE SET TARGET.Nombre = SOURCE.Nombre,
TARGET.Puntos = SOURCE.Puntos
--Cuando los registros no concuerdan por la llave
--indica que es un dato nuevo, se inserta el registro
--en la tabla TARGET proveniente de la tabla SOURCE
WHEN NOT MATCHED BY TARGET THEN
INSERT (Codigo, Nombre, Puntos)
VALUES (SOURCE.Codigo, SOURCE.Nombre, SOURCE.Puntos)
--Cuando el registro existe en TARGET y no existe en SOURCE
--se borra el registro en TARGET
WHEN NOT MATCHED BY SOURCE THEN
DELETE

--Seccion opcional e informativa
--$action indica el tipo de accion
--en OUTPUT retorna cualquiera de las 3 acciones
--'INSERT', 'UPDATE', or 'DELETE',
OUTPUT $action,
DELETED.Codigo AS TargetCodigo,
DELETED.Nombre AS TargetNombre,
DELETED.Puntos AS TargetPuntos,
INSERTED.Codigo AS SourceCodigo,
INSERTED.Nombre AS SourceNombre,
INSERTED.Puntos AS SourcePuntos;
SELECT @@ROWCOUNT;
GO

SELECT * FROM Usuarios
SELECT * FROM UsuariosActual

/*Tabla parametros, dos BD distintas*/
-- Deshabilita identity para inserciones
SET IDENTITY_INSERT BD_SGAC_G2_old.PS_SISTEMA.SI_PARAMETRO ON
-- Realiza Merge
MERGE BD_SGAC_G2_old.PS_SISTEMA.SI_PARAMETRO AS TARGET
USING TestJR.PS_SISTEMA.SI_PARAMETRO AS SOURCE
ON (TARGET.para_sParametroId = SOURCE.para_sParametroId)
WHEN MATCHED AND TARGET.para_vGrupo <> SOURCE.para_vGrupo OR TARGET.para_vDescripcion <> SOURCE.para_vDescripcion THEN
UPDATE SET  TARGET.para_vGrupo = SOURCE.para_vGrupo, TARGET.para_vDescripcion = SOURCE.para_vDescripcion, 
			TARGET.para_vValor = SOURCE.para_vValor, TARGET.para_vReferencia = SOURCE.para_vReferencia,
			TARGET.para_tOrden = SOURCE. para_tOrden, TARGET.para_bVisible = SOURCE.para_bVisible,
			TARGET.para_dVigenciaInicio = SOURCE.para_dVigenciaInicio, TARGET.para_dVigenciaFin = SOURCE.para_dVigenciaFin, 
			TARGET.para_bPrecarga = SOURCE.para_bPrecarga, TARGET.para_cEstado = SOURCE.para_cEstado,
			TARGET.para_sUsuarioCreacion = SOURCE.para_sUsuarioCreacion, TARGET.para_vIPCreacion = SOURCE.para_vIPCreacion,
			TARGET.para_dFechaCreacion = SOURCE.para_dFechaCreacion, TARGET.para_sUsuarioModificacion = SOURCE.para_sUsuarioModificacion,
			TARGET.para_vIPModificacion = SOURCE.para_vIPModificacion, TARGET.para_dFechaModificacion = SOURCE.para_dFechaModificacion
WHEN NOT MATCHED BY TARGET THEN
INSERT (para_sParametroId, para_vGrupo ,para_vDescripcion ,para_vValor ,para_vReferencia ,para_tOrden ,para_bVisible ,para_dVigenciaInicio,para_dVigenciaFin
           ,para_bPrecarga ,para_cEstado ,para_sUsuarioCreacion ,para_vIPCreacion ,para_dFechaCreacion ,para_sUsuarioModificacion
           ,para_vIPModificacion ,para_dFechaModificacion)
		   VALUES
		   (SOURCE.para_sParametroId, SOURCE.para_vGrupo ,SOURCE.para_vDescripcion ,SOURCE.para_vValor ,SOURCE.para_vReferencia
           ,SOURCE.para_tOrden ,SOURCE.para_bVisible ,SOURCE.para_dVigenciaInicio ,SOURCE.para_dVigenciaFin
           ,SOURCE.para_bPrecarga ,SOURCE.para_cEstado ,SOURCE.para_sUsuarioCreacion
           ,SOURCE.para_vIPCreacion ,SOURCE.para_dFechaCreacion ,SOURCE.para_sUsuarioModificacion
           ,SOURCE.para_vIPModificacion ,SOURCE.para_dFechaModificacion)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;
-- Habilita indetity
SET IDENTITY_INSERT BD_SGAC_G2_old.PS_SISTEMA.SI_PARAMETRO OFF
