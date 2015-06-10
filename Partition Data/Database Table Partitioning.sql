-- Consideramos que tenemos una base de datos Prueba y tabla Ventas creadas

-- Primer Paso : Agregar Filegroups Para Contener los Files Semestrales

	ALTER DATABASE Prueba ADD FILEGROUP [Fg_Ventas_20011A]
	ALTER DATABASE Prueba ADD FILEGROUP [Fg_Ventas_20011B]
	ALTER DATABASE Prueba ADD FILEGROUP [Fg_Ventas_20012A]
	ALTER DATABASE Prueba ADD FILEGROUP [Fg_Ventas_20012B]

-- Segundo Paso : Agregar Files Para  los Filegroups Creados

	ALTER DATABASE Prueba ADD FILE
	(Name = 'ventas_2011A', FILENAME = 'D:\Data\ventas2011A.ndf', Size = 25000MB, Maxsize = 100000MB)
	 TO FILEGROUP [Fg_Ventas_20011A]

	ALTER DATABASE Prueba ADD FILE
	(Name = 'ventas_2011B', FILENAME = 'E:\Data\ventas2011B.ndf', Size = 25000MB, Maxsize = 100000MB)
	 TO FILEGROUP [Fg_Ventas_20011B]

	ALTER DATABASE Prueba ADD FILE
	(Name = 'ventas_2012A', FILENAME = 'F:\Data\ventas2012A.ndf', Size = 25000MB, Maxsize = 100000MB)
	 TO FILEGROUP [Fg_Ventas_20012A]

	 ALTER DATABASE Prueba ADD FILE
	(Name = 'ventas_2012B', FILENAME = 'G:\Data\ventas2012B.ndf', Size = 25000MB, Maxsize = 100000MB)
	 TO FILEGROUP [Fg_Ventas_20012B]

-- Tercer Paso :  Generar una Partition Function (la cual determinará los rangos a partir de los cuales particionaremos la tabla, - en nuestro caso por fecha -)

	CREATE PARTITION FUNCTION [PF_Ventas](datetime)
	AS RANGE LEFT FOR VALUES
	 ('2011-06-30 23:59:59', '2011-12-31 23:59:59','2012-06-30 23:59:59' )

-- Cuarto Paso :  Generar una Partition Scheme (el cual mapeará las particiones a los filegroups creados en el primer paso)

	CREATE PARTITION SCHEME [PS_Ventas] AS PARTITION [PF_Ventas]
	TO ([Fg_Ventas_20011A], [Fg_Ventas_20011B] , [Fg_Ventas_20012A], [Fg_Ventas_20012B] )

-- Quinto Paso:  Distribuir Físicamente los Registros de la Tabla Ventas en los Files Creados Mediante el Dropeado y la Creación de Indice Cluster Sobre el Partiton Scheme

   DROP INDEX [ix_fecha] ON [dbo].[ventas]
         WITH( ONLINE = OFF )

   CREATE CLUSTERED INDEX [ix_fecha] ON [dbo].[Ventas] (fecha)
          on [PS_Ventas] (fecha)