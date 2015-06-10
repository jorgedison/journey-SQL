USE [DATABASE]
GO

/*
Creamos una Funci�n de Particionamiento, para crear 8 particiones:
Partici�n 1: Valores < 20100101 (Diciembre 2009 y meses anteriores)
Partici�n 2: 20100101 <= Valores < 20100201 (Enero 2010)
Partici�n 3: 20100201 <= Valores < 20100301 (Febrero 2010)
Partici�n 4: 20100301 <= Valores < 20100401 (Marzo 2010)
Partici�n 5: 20100401 <= Valores < 20100501 (Abril 2010)
Partici�n 6: 20100501 <= Valores < 20100601 (Mayo 2010)
Partici�n 7: 20100601 <= Valores < 20100701 (Junio 2010)
Partici�n 8: 20100701 <= Valores (Julio 2010 y meses posteriores)
Al trabajar con fechas, utilizaremos RANGE RIGHT (suele ser lo habitual)
NOTA: Suponemos que las partici�n 1 y 8 est�n vac�as, y el resto contienen datos.
La idea, es mantener inicialmente informaci�n de los meses de Enero a Junio.
*/

CREATE PARTITION FUNCTION [pfDatos] (datetime)
AS RANGE RIGHT FOR VALUES 
('20100101', '20100201', '20100301', '20100401', '20100501', '20100601', '20100701');
GO

/*
Creamos un Esquema de Particionamiento, 
para mapear todas las particiones a un mismo FileGroup
*/

CREATE PARTITION SCHEME [psDatos] 
AS PARTITION [pfDatos] ALL TO ([PRIMARY]);
GO

/*
Creamos una Funci�n de Particionamiento, para crear 2 particiones:
Partici�n 1: Valores < 20100101 (Diciembre 2009 y meses anteriores)
Partici�n 2: 20100101 <= Valores (Enero 2010 y meses posteriores)
El objetivo es mantener la Partici�n 1 llena, y la partici�n 2 vac�a
De este modo, la partici�n 2, al estar vac�a permitir� realizar SPLIT de forma eficiente.
Adem�s, despu�s del SPLIT, la nueva partici�n, podr� recibir datos con ALTER TABLE SWITCH PARTITION,
para seguidamente poder hacer un MERGE, y volver a la misma situaci�n inicial:
Dos particiones, con la Partici�n 1 llena, y la partici�n 2 vac�a.
*/

CREATE PARTITION FUNCTION [pfDatosHistoricos] (datetime)
AS RANGE RIGHT FOR VALUES 
('20100101');
GO

/*
Creamos un Esquema de Particionamiento, 
para mapear todas las particiones a un mismo FileGroup
*/

CREATE PARTITION SCHEME [psDatosHistoricos] 
AS PARTITION [pfDatosHistoricos] ALL TO ([PRIMARY]);
GO


/*
Creamos una tabla con varias particiones
para los datos recientes y frecuentemente accedidos
*/

CREATE TABLE dbo.tblDatos
(
ID UNIQUEIDENTIFIER NOT NULL
,DESCRIPCION VARCHAR(200) NOT NULL
,FECHA DATETIME NOT NULL
,CONSTRAINT	PK_tblDatos PRIMARY KEY NONCLUSTERED (ID, FECHA) ON psDatos(FECHA)
) ON psDatos(FECHA);

/*
Creamos una tabla con dos particiones
para los datos hist�ricos y poco accedidos
Debe tener el mismo esquema que la tabla anterior, para poder hacer el SWITCH !!
*/

CREATE TABLE dbo.tblDatosHistoricos
(
ID UNIQUEIDENTIFIER NOT NULL
,DESCRIPCION VARCHAR(200) NOT NULL
,FECHA DATETIME NOT NULL
,CONSTRAINT	PK_tblDatosHistoricos PRIMARY KEY NONCLUSTERED (ID, FECHA) ON psDatosHistoricos(FECHA)
) ON psDatosHistoricos(FECHA);

/*
Insertamos datos de prueba en la tabla de datos recientes, y los consultamos
*/

INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Junio 2010','20100601')
INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Mayo 2010','20100501')
INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Abril 2010','20100401')
INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Marzo 2010','20100301')
INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Febrero 2010','20100201')
INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Enero 2010','20100101')

SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.tblDatos 

/*
Insertamos datos de prueba en la tabla de datos hist�ricos, y los consultamos
*/

INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Dicembre 2009','20091201')
INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Noviembre 2009','20091101')
INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Octubre 2009','20091001')
INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Septiembre 2009','20090901')
INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Agosto 2009','20090801')
INSERT INTO dbo.tblDatosHistoricos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Julio 2009','20090701')

SELECT *, $PARTITION.pfDatosHistoricos(FECHA) [Partition] FROM dbo.tblDatosHistoricos 

/*
Ahora llega el momento de gracia.
Evidentemente, antes o despu�s, necesitaremos pasar el �ltimo mes de tblDatos (Enero 2010) a tblDatosHistoricos,
y adem�s en tblDatos se empezar�n a recibir datos para el nuevo mes (Julio 2010).
Por ello, debemos tanto archivar el mes de Enero 2010 en la tabla hist�rica,
como acondicionar tblDatos para recibir datos de Julio 2010.
El primer paso, hacer un SPLIT en tblDatos, para crear una partici�n para el mes de Julio 2010.
�Por qu�? Porque en este momento, la partici�n sobre la que vamos a hacer el SPLIT est� vac�a,
por lo tanto, el SPLIT ser� una operaci�n eficiente (metadata only operation).
Por ello, deberemos hacerlo ahora, y no dejar que avance el tiempo. Vamos a ello.
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100801');
-- Ojo: Deber�amos ejecutar la siguiente l�nea, pero no lo vamos a hacer
-- para que luego casque, y as� veamos claramente su necesidad. Prueba y error !
-- ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Realizado esto, ya se podr�an insertar datos de Julio 2010,
existiendo una partici�n adicional para Agosto 2010 y meses posteriores,
la cual se mantendr� vac�a.
As�, podremos repetir el proceso todos los meses, es decir, hacer SPLIT de una partici�n vac�a.
Bien. Ahora vamos a continuar con el archivado (SWITCH) del mes de Enero 2010.
Por ello, el siguiente paso es hacer un SPLIT sobre pfDatosHistoricos.
�Por qu�? Porque en este momento, la partici�n de destino para el SWITCH est� vac�a,
por lo que podemos hacer un SPLIT, aprovechando la mejora de rendimiento de esta situaci�n,
para seguidamente realizar el SWITCH.
As�, podremos repetir el proceso todos los meses, es decir, hacer SPLIT de una partici�n vac�a.
*/

ALTER PARTITION FUNCTION [pfDatosHistoricos] () SPLIT RANGE ('20100201');
-- Ojo: Deber�amos ejecutar la siguiente l�nea, pero no lo vamos a hacer
-- para que luego casque, y as� veamos claramente su necesidad. Prueba y error !
-- ALTER PARTITION SCHEME [psDatosHistoricos] NEXT USED [PRIMARY]

/*
Genial. Hecho esto, continuamos.
Para poder mover una partici�n (archivar), �sta debe ser un subconjunto de la partici�n destino.
Queremos mover la partici�n 2 de dbo.tblDatos, de rango:  20100101 <= Valores < 20100201 (Enero 2010)
utilizando como destino la partici�n 2 de dbo.tblDatosHistoricos, de rango:  20100101 <= Valores < 20100201 (Enero 2010)
Tanto las tablas como los �ndices, tienen que estar particionados
La partici�n destino debe estar vac�a
Las particiones origen y destino deben estar en el mismo FileGroup
Esta operaci�n es una operaci�n de metadatos (metadata only operation),
por lo que resulta muy eficiente (r�pida y sin crecimiento de Log).
*/

ALTER TABLE dbo.tblDatos SWITCH PARTITION 2 TO dbo.tblDatosHistoricos PARTITION 2

/*
Ahora, si comprobamos los datos, hemos conseguido mover los datos de Enero
desde la tabla origen a la tabla destino.
Claro que en dbo.tblDatos, sigue existiendo una partici�n 2 para Enero 2010,
aunque eso s�, despu�s del SWITCH, dicha partici�n est� vac�a.
Adem�s en dbo.tblDatosHistoricos tenemos tres particiones, 2 con datos y una vac�a.
A�n quedan cosas por hacer.
*/

SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.tblDatos
SELECT *, $PARTITION.pfDatosHistoricos(FECHA) [Partition] FROM dbo.tblDatosHistoricos 

/*
Ahora toca mezclar (MERGE) el mes de Enero con el resto de meses en la tabla hist�rica
NOTA: esta operaci�n es costosa, ya que las particiones a mezclar no est�n vac�as:
puede incurrir en un elevado tiempo de ejecuci�n y crecimiento de Log !!!
Una alternativa, es mantener en la tabla Hist�rica particiones para cada a�o, 
en vez de una �nica partici�n para todo, o incluso mantener una partici�n para cada mes evitando el MERGE.
Como siempre, es una cuesti�n de dise�o, que se debe examinar con calma en cada caso.
*/

ALTER PARTITION FUNCTION [pfDatosHistoricos] () MERGE RANGE ('20100101');

/*
Ahora toca alterar la funci�n de particionamiento correspondiente a tblDatos,
para mezclar la partici�n 2 de Enero 2010 (que est� vac�a despu�s del SPLIT)
con la partici�n 1 de Diciembre 2010 y meses posteriores (tambi�n vac�a).
Al estar vac�as ambas particiones, se tratara de una operaci�n de metadatos,
con la correspondiente mejora de rendimiento.
*/

ALTER PARTITION FUNCTION [pfDatos] () MERGE RANGE ('20100101');

/*
Ahora podemos insertar datos para el nuevo mes de Julio 2010, 
que se insertar�n en la partici�n correspondiente,
dejando la �ltima partici�n vac�a, para cuando sea necesario hacer otro SPLIT
*/

INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Julio 2010','20100701')

/*
As� queda el contenido de las tablas y la pertenencia de filas a particiones
En tblDatos, contin�an las particiones 1 y 8 vac�as, y el resto llenas.
En tblDatosHistoricos, contin�a con una partici�n llena, y otra vac�a.
Por lo tanto, el proceso es repetible. 
Dentro de un mes, podremos repetirlo de igual forma, 
quedando una configuraci�n equivalente de particiones llenas y vac�as, etc.
*/

SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.tblDatos
SELECT *, $PARTITION.pfDatosHistoricos(FECHA) [Partition] FROM dbo.tblDatosHistoricos 

/*
Si tenemos curiosidad, podemos consultar la configuraci�n de particiones,
seg�n las tablas/vistas del sistema. Por ejemplo:
*/

SELECT FN.name, FN.fanout, VL.boundary_id, VL.value 
FROM sys.partition_functions FN
INNER JOIN sys.partition_range_values VL
ON FN.function_id = VL.function_id

/*
�Hemos acabado ya? Pues no. Hay un detalle m�s que es interesante comentar.
En teor�a, el proceso que hemos llevado a cabo es repetible �Verdad?
La configuraci�n de particiones ahora mismo, es equivalente a como era al principio.
Por lo tanto, deber�amos poder hacer nuevos SPLITs �Verdad? Pues no. V�ase:
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100901');

/*
C�spita !!! Parece que nos insulta. 
Al crear las funciones y esquemas de particionamientos de nuestro ejemplo, 
se configura de manera impl�cita el FileGroup PRIMARY como siguiente FileGroup (NEXT USED)
a ser utilizado en una operaci�n SPLIT.
Por ello, al hacer un primer SPLIT todo funciona OK, 
pero para hacer un siguiente SPLIT debemos indicarle a SQL Server cual va a ser el NEXT USED FileGroup,
y sino lo hacemos, pues nada: Error al canto !!! 
Conclusi�n: ahora para salir del apuro:
*/

ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]
ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100901');
ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Moraleja, debemos tener como costubre en estos casos, despu�s de cada SPLIT,
establecer el FileGroup deseado como NEXT USED, para as� evitarnos sustos.
Pero a�n queda otro punto que ver: 
�Qu� ocurre si intentamos hacer un SWITCH, SPLIT o MERGE con actividad de usuarios sobre las particiones?
Este tipo de operaciones, generan bloqueos de esquema (locks), 
por lo podemos encontrarnos con esperas (waits) debidas a bloqueos (blocks).
Esto se puede ver iniciando en una sesi�n una transacci�n, pero sin finalizarla:
*/


BEGIN TRAN

UPDATE dbo.tblDatos SET DESCRIPCION=DESCRIPCION WHERE DESCRIPCION='Febrero 2010'


/*
En otra sesi�n, intentamos hacer un SWITCH
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20101001');
ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Hacemos un COMMIT en la transacci�n anterior:
*/

COMMIT

/*
En este momento, se ha finalizado la transacci�n, y adem�s, se ha ejecutado por fin el SPLIT 
que estaba esperando por el bloqueo (lock/block).
Y ahora, s� que hemos terminado !!!
*/