CREATE DATABASE "AUDITORIA";

create sequence "NumeroConexiones_id_seq";
create sequence "NumeroConexionesBd_id_seq";
create sequence "NumeroConexionesHost_id_seq";
create sequence "NumeroConexionesUser_id_seq";

CREATE TABLE public."NumeroConexiones"
(
  id integer NOT NULL DEFAULT nextval('"NumeroConexiones_id_seq"'::regclass),
  conexiones integer,
  fecha timestamp without time zone,
  CONSTRAINT "NumeroConexiones_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE public."NumeroConexionesBd"
(
  id integer NOT NULL DEFAULT nextval('"NumeroConexionesBd_id_seq"'::regclass),
  db character varying(100),
  conexiones integer,
  fecha timestamp without time zone,
  CONSTRAINT "NumeroConexionesBd_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE public."NumeroConexionesHost"
(
  id integer NOT NULL DEFAULT nextval('"NumeroConexionesHost_id_seq"'::regclass),
  "Host" character varying(100),
  conexiones integer,
  fecha timestamp without time zone,
  CONSTRAINT "NumeroConexionesHost_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE public."NumeroConexionesUser"
(
  id integer NOT NULL DEFAULT nextval('"NumeroConexionesUser_id_seq"'::regclass),
  "user" character varying(50),
  conexiones integer,
  fecha timestamp without time zone,
  CONSTRAINT "NumeroConexionesUser_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


INSERT INTO public."NumeroConexionesBd"(db, conexiones, fecha) select datname, count(pid), now() from pg_stat_activity where datname is not null group by datname;
INSERT INTO public."NumeroConexionesHost"("Host", conexiones, fecha) select client_addr, count(pid), now() from pg_stat_activity where client_addr is not null group by client_addr;
INSERT INTO public."NumeroConexionesUser"("user", conexiones, fecha) select usename, count(pid), now() from pg_stat_activity where usename is not null group by usename;
INSERT INTO public."NumeroConexiones"(conexiones, fecha) select count(pid), now() from pg_stat_activity where datname is not null;

