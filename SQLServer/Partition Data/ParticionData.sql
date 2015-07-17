USE [DATABASE]
GO

/*
Creamos una Función de Particionamiento, para crear 8 particiones:
Partición 1: Valores < 20100101 (Diciembre 2009 y meses anteriores)
Partición 2: 20100101 <= Valores < 20100201 (Enero 2010)
Partición 3: 20100201 <= Valores < 20100301 (Febrero 2010)
Partición 4: 20100301 <= Valores < 20100401 (Marzo 2010)
Partición 5: 20100401 <= Valores < 20100501 (Abril 2010)
Partición 6: 20100501 <= Valores < 20100601 (Mayo 2010)
Partición 7: 20100601 <= Valores < 20100701 (Junio 2010)
Partición 8: 20100701 <= Valores (Julio 2010 y meses posteriores)
Al trabajar con fechas, utilizaremos RANGE RIGHT (suele ser lo habitual)
NOTA: Suponemos que las partición 1 y 8 están vacías, y el resto contienen datos.
La idea, es mantener inicialmente información de los meses de Enero a Junio.
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
Creamos una Función de Particionamiento, para crear 2 particiones:
Partición 1: Valores < 20100101 (Diciembre 2009 y meses anteriores)
Partición 2: 20100101 <= Valores (Enero 2010 y meses posteriores)
El objetivo es mantener la Partición 1 llena, y la partición 2 vacía
De este modo, la partición 2, al estar vacía permitirá realizar SPLIT de forma eficiente.
Además, después del SPLIT, la nueva partición, podrá recibir datos con ALTER TABLE SWITCH PARTITION,
para seguidamente poder hacer un MERGE, y volver a la misma situación inicial:
Dos particiones, con la Partición 1 llena, y la partición 2 vacía.
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
para los datos históricos y poco accedidos
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
Insertamos datos de prueba en la tabla de datos históricos, y los consultamos
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
Evidentemente, antes o después, necesitaremos pasar el último mes de tblDatos (Enero 2010) a tblDatosHistoricos,
y además en tblDatos se empezarán a recibir datos para el nuevo mes (Julio 2010).
Por ello, debemos tanto archivar el mes de Enero 2010 en la tabla histórica,
como acondicionar tblDatos para recibir datos de Julio 2010.
El primer paso, hacer un SPLIT en tblDatos, para crear una partición para el mes de Julio 2010.
¿Por qué? Porque en este momento, la partición sobre la que vamos a hacer el SPLIT está vacía,
por lo tanto, el SPLIT será una operación eficiente (metadata only operation).
Por ello, deberemos hacerlo ahora, y no dejar que avance el tiempo. Vamos a ello.
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100801');
-- Ojo: Deberíamos ejecutar la siguiente línea, pero no lo vamos a hacer
-- para que luego casque, y así veamos claramente su necesidad. Prueba y error !
-- ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Realizado esto, ya se podrían insertar datos de Julio 2010,
existiendo una partición adicional para Agosto 2010 y meses posteriores,
la cual se mantendrá vacía.
Así, podremos repetir el proceso todos los meses, es decir, hacer SPLIT de una partición vacía.
Bien. Ahora vamos a continuar con el archivado (SWITCH) del mes de Enero 2010.
Por ello, el siguiente paso es hacer un SPLIT sobre pfDatosHistoricos.
¿Por qué? Porque en este momento, la partición de destino para el SWITCH está vacía,
por lo que podemos hacer un SPLIT, aprovechando la mejora de rendimiento de esta situación,
para seguidamente realizar el SWITCH.
Así, podremos repetir el proceso todos los meses, es decir, hacer SPLIT de una partición vacía.
*/

ALTER PARTITION FUNCTION [pfDatosHistoricos] () SPLIT RANGE ('20100201');
-- Ojo: Deberíamos ejecutar la siguiente línea, pero no lo vamos a hacer
-- para que luego casque, y así veamos claramente su necesidad. Prueba y error !
-- ALTER PARTITION SCHEME [psDatosHistoricos] NEXT USED [PRIMARY]

/*
Genial. Hecho esto, continuamos.
Para poder mover una partición (archivar), ésta debe ser un subconjunto de la partición destino.
Queremos mover la partición 2 de dbo.tblDatos, de rango:  20100101 <= Valores < 20100201 (Enero 2010)
utilizando como destino la partición 2 de dbo.tblDatosHistoricos, de rango:  20100101 <= Valores < 20100201 (Enero 2010)
Tanto las tablas como los índices, tienen que estar particionados
La partición destino debe estar vacía
Las particiones origen y destino deben estar en el mismo FileGroup
Esta operación es una operación de metadatos (metadata only operation),
por lo que resulta muy eficiente (rápida y sin crecimiento de Log).
*/

ALTER TABLE dbo.tblDatos SWITCH PARTITION 2 TO dbo.tblDatosHistoricos PARTITION 2

/*
Ahora, si comprobamos los datos, hemos conseguido mover los datos de Enero
desde la tabla origen a la tabla destino.
Claro que en dbo.tblDatos, sigue existiendo una partición 2 para Enero 2010,
aunque eso sí, después del SWITCH, dicha partición está vacía.
Además en dbo.tblDatosHistoricos tenemos tres particiones, 2 con datos y una vacía.
Aún quedan cosas por hacer.
*/

SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.tblDatos
SELECT *, $PARTITION.pfDatosHistoricos(FECHA) [Partition] FROM dbo.tblDatosHistoricos 

/*
Ahora toca mezclar (MERGE) el mes de Enero con el resto de meses en la tabla histórica
NOTA: esta operación es costosa, ya que las particiones a mezclar no están vacías:
puede incurrir en un elevado tiempo de ejecución y crecimiento de Log !!!
Una alternativa, es mantener en la tabla Histórica particiones para cada año, 
en vez de una única partición para todo, o incluso mantener una partición para cada mes evitando el MERGE.
Como siempre, es una cuestión de diseño, que se debe examinar con calma en cada caso.
*/

ALTER PARTITION FUNCTION [pfDatosHistoricos] () MERGE RANGE ('20100101');

/*
Ahora toca alterar la función de particionamiento correspondiente a tblDatos,
para mezclar la partición 2 de Enero 2010 (que está vacía después del SPLIT)
con la partición 1 de Diciembre 2010 y meses posteriores (también vacía).
Al estar vacías ambas particiones, se tratara de una operación de metadatos,
con la correspondiente mejora de rendimiento.
*/

ALTER PARTITION FUNCTION [pfDatos] () MERGE RANGE ('20100101');

/*
Ahora podemos insertar datos para el nuevo mes de Julio 2010, 
que se insertarán en la partición correspondiente,
dejando la última partición vacía, para cuando sea necesario hacer otro SPLIT
*/

INSERT INTO dbo.tblDatos (ID, DESCRIPCION, FECHA) VALUES (NEWID(), 'Julio 2010','20100701')

/*
Así queda el contenido de las tablas y la pertenencia de filas a particiones
En tblDatos, continúan las particiones 1 y 8 vacías, y el resto llenas.
En tblDatosHistoricos, continúa con una partición llena, y otra vacía.
Por lo tanto, el proceso es repetible. 
Dentro de un mes, podremos repetirlo de igual forma, 
quedando una configuración equivalente de particiones llenas y vacías, etc.
*/

SELECT *, $PARTITION.pfDatos(FECHA) [Partition] FROM dbo.tblDatos
SELECT *, $PARTITION.pfDatosHistoricos(FECHA) [Partition] FROM dbo.tblDatosHistoricos 

/*
Si tenemos curiosidad, podemos consultar la configuración de particiones,
según las tablas/vistas del sistema. Por ejemplo:
*/

SELECT FN.name, FN.fanout, VL.boundary_id, VL.value 
FROM sys.partition_functions FN
INNER JOIN sys.partition_range_values VL
ON FN.function_id = VL.function_id

/*
¿Hemos acabado ya? Pues no. Hay un detalle más que es interesante comentar.
En teoría, el proceso que hemos llevado a cabo es repetible ¿Verdad?
La configuración de particiones ahora mismo, es equivalente a como era al principio.
Por lo tanto, deberíamos poder hacer nuevos SPLITs ¿Verdad? Pues no. Véase:
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100901');

/*
Cáspita !!! Parece que nos insulta. 
Al crear las funciones y esquemas de particionamientos de nuestro ejemplo, 
se configura de manera implícita el FileGroup PRIMARY como siguiente FileGroup (NEXT USED)
a ser utilizado en una operación SPLIT.
Por ello, al hacer un primer SPLIT todo funciona OK, 
pero para hacer un siguiente SPLIT debemos indicarle a SQL Server cual va a ser el NEXT USED FileGroup,
y sino lo hacemos, pues nada: Error al canto !!! 
Conclusión: ahora para salir del apuro:
*/

ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]
ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20100901');
ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Moraleja, debemos tener como costubre en estos casos, después de cada SPLIT,
establecer el FileGroup deseado como NEXT USED, para así evitarnos sustos.
Pero aún queda otro punto que ver: 
¿Qué ocurre si intentamos hacer un SWITCH, SPLIT o MERGE con actividad de usuarios sobre las particiones?
Este tipo de operaciones, generan bloqueos de esquema (locks), 
por lo podemos encontrarnos con esperas (waits) debidas a bloqueos (blocks).
Esto se puede ver iniciando en una sesión una transacción, pero sin finalizarla:
*/


BEGIN TRAN

UPDATE dbo.tblDatos SET DESCRIPCION=DESCRIPCION WHERE DESCRIPCION='Febrero 2010'


/*
En otra sesión, intentamos hacer un SWITCH
*/

ALTER PARTITION FUNCTION [pfDatos] () SPLIT RANGE ('20101001');
ALTER PARTITION SCHEME [psDatos] NEXT USED [PRIMARY]

/*
Hacemos un COMMIT en la transacción anterior:
*/

COMMIT

/*
En este momento, se ha finalizado la transacción, y además, se ha ejecutado por fin el SPLIT 
que estaba esperando por el bloqueo (lock/block).
Y ahora, sí que hemos terminado !!!
*/