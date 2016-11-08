--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

-- Started on 2016-11-08 15:53:13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2582 (class 1262 OID 83359)
-- Dependencies: 2581
-- Name: VRS_BASE_OPERATION; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE "VRS_BASE_OPERATION" IS 'Database VRS_BASE_OPERATION';


--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2585 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 83360)
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- TOC entry 278 (class 1255 OID 83367)
-- Name: report_movementplate(integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION report_movementplate(p_splatetypeid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_language integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';
--declare p_language integer := p_slanguageid % 140;

/**
 * @param p_splatetypeid  type plate			                          INPUT
 * @param p_dstartdate   start date request                                                       INPUT
 * @param p_dfinishdate  finish date request                                                      INPUT
 * @param p_language
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	V.ivehicleid "ID",
	vvehiclecode "Code",
	CAST(TRIM(split_part(SP_C.vdescription,'|', p_language)) as character varying) "Vehicle Category",
	CAST(TRIM(split_part(SP_TP.vdescription,'|', p_language)) as character varying) "Type Plate",
	RL.vnumberplate "Number Plate",
	CAST(TRIM(split_part(SP.vdescription,'|', p_language)) as character varying) "Status",
	RL.dstartdate "Date"
FROM vehicle V
JOIN request_detail RD ON RD.ivehicleid = V.ivehicleid
JOIN request_license RL ON RL.irequestlicenseid = RD.irequestlicenseid
JOIN systemparameter SP ON SP.iparameterid = RL.sstatus
JOIN systemparameter SP_TP ON SP_TP.iparameterid = RL.splatetypeid
JOIN systemparameter SP_C ON SP_C.iparameterid = V.scategorytypeid
WHERE
	(p_splatetypeid = 0 OR  RL.splatetypeid = p_splatetypeid)AND
	(RL.dstartdate BETWEEN p_dstartdate AND p_dfinishdate)
ORDER BY RL.dstartdate);
RETURN (p_cursor);
END;
$$;


--
-- TOC entry 279 (class 1255 OID 83368)
-- Name: report_servicesnote(integer, timestamp without time zone, timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION report_servicesnote(p_packiproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_iinsertuserid integer, p_sstatus integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';
--declare p_language integer := p_slanguageid % 140;

/**
 * Description: Stored procedure that returns a list of request<br />
 * Detailed explanation of the object.
 * @param p_packiproductid   Id pakc product				                          INPUT
 * @param p_dstartdate   start date request                                                       INPUT
 * @param p_dfinishdate  finish date request                                                      INPUT
 * @param p_iinsertuserid id user								  INPUT
 * @param p_sstatus      Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000  INPUT
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	CASE WHEN COALESCE(vorganization, '') = '' THEN COALESCE(vlastname, '') || ' ' ||  COALESCE(vfirstname, '') || ' ' || COALESCE(vmiddlename, '') || ' ' || COALESCE(vmaidenname,'') 
			ELSE vorganization END "Name",
	R.irequestid "Request Id",
	RD.irequestdetailid "Request Detail Id",
	PrPack.vdescription "Pack ProductName",
	Pr.vdescription "Product Name",
	R.dstartdate "Date Request",
	CAST(TRIM(split_part(SP.vdescription,'|', 1)) as character varying) "Status",
	N.vobservation "Comment",
	N.dinsertdate "Date Note"
	--, R.irequestid, RD.irequestdetailid, N.inoteid
FROM party P
	JOIN Request R ON R.ipartyid = P.ipartyid
	JOIN Request_detail RD ON RD.irequestid = R.irequestid
	JOIN Product Pr ON Pr.iproductid = RD.iproductid
	JOIN Product PrPack ON PrPack.iproductid = R.iproductid
	JOIN Systemparameter SP ON SP.iparameterid = R.sstatus
	LEFT JOIN Note N ON N.irequestdetailid = RD.irequestdetailid
WHERE
	(p_packiproductid = 0 OR PrPack.iproductid = p_packiproductid) AND
	(R.dstartdate BETWEEN p_dstartdate AND p_dfinishdate) AND
	(p_iinsertuserid = 0 OR R.iinsertuserid = p_iinsertuserid) AND
	(p_sstatus = 0 OR R.sstatus = p_sstatus)
ORDER BY R.irequestid);

RETURN (p_cursor);
END;
$$;


--
-- TOC entry 280 (class 1255 OID 83369)
-- Name: report_vehicle(integer, integer, integer, integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION report_vehicle(p_scategorytypeid integer, p_sprimarycolourid integer, p_ssecondarycolourid integer, p_sstatus integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_language integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';
--declare p_language integer := p_slanguageid % 140;

/**
 * @param p_scategorytypeid  vehicle category			                  INPUT
 * @param p_sprimarycolourid  colour primary vehicle			          INPUT
 * @param p_ssecondarycolourid  colour secondary vehicle			  INPUT
 * @param p_sstatus  status vehicle		                  		  INPUT
 * @param p_dstartdate   start date request                                       INPUT
 * @param p_dfinishdate  finish date request                                      INPUT
 * @param p_language
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	V.vvehiclecode "Code",
	VC.vdescription "Make",
	VC1.vdescription "Model",
	CAST(TRIM(split_part(SP.vdescription,'|', p_language)) as character varying) "Colour Primary",
	CAST(TRIM(split_part(SP1.vdescription,'|', p_language)) as character varying) "Colour Secondary",
	CAST(TRIM(split_part(SP2.vdescription,'|', p_language)) as character varying) "Status",
	V.dinsertdate "Date"
FROM vehicle V
	JOIN vehicle_catalog VC ON VC.ivehiclecatalogid = V.imakeid
	JOIN vehicle_catalog VC1 ON VC1.ivehiclecatalogid = V.imodelid
	JOIN systemparameter SP ON SP.iparameterid = V.sprimarycolourid
	JOIN systemparameter SP1 ON SP1.iparameterid = V.ssecondarycolourid
	JOIN systemparameter SP2 ON SP2.iparameterid = V.sstatus
	JOIN systemparameter SP3 ON SP3.iparameterid = V.scategorytypeid
WHERE 
	(p_scategorytypeid = 0 OR V.scategorytypeid = p_scategorytypeid) AND
	(p_sprimarycolourid = 0 OR V.sprimarycolourid = p_sprimarycolourid) AND
	(p_ssecondarycolourid = 0 OR V.ssecondarycolourid = p_ssecondarycolourid) AND
	(p_sstatus = 0 OR V.sstatus = p_sstatus) AND
	(V.dinsertdate BETWEEN p_dstartdate AND p_dfinishdate)
);
RETURN (p_cursor);
END;
$$;


--
-- TOC entry 281 (class 1255 OID 83370)
-- Name: usp_admin_schedule_get(integer, smallint, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_admin_schedule_get(p_ilocationid integer, p_sexaminationtypeid smallint, p_vscheduledate character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param p_ilocationid Primary auto-increment key
 * @param p_sexaminationtypeid Primary auto-increment key
 * @param p_dscheduledate Primary auto-increment key
 * @return array printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 16/08/2016<BR/> Se agrego tabla location y su columna vdescription
 */
      OPEN ref_cursor FOR 
	select sc.ttimeday ,sc.ttimeendday ,sc.iofficeexaminationtypeid,sc.ischeduleid,sc.ivacant , sc.sdayofweekid ,sc.dscheduledate
	from schedule sc 
	inner join office_examinationtype et on sc.iofficeexaminationtypeid =et.iofficeexaminationtypeid
	where 
	et.ilocationid = p_ilocationid and
	et.sexaminationtypeid = p_sexaminationtypeid and 
	sc.dscheduledate in 
	(select case when item = '' then null else cast(item as timestamp) end  from (
	select regexp_split_to_table(p_vscheduledate, ',') as item) as table1)
	and
	sc.sstatus = 1;
				
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 281
-- Name: FUNCTION usp_admin_schedule_get(p_ilocationid integer, p_sexaminationtypeid smallint, p_vscheduledate character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_admin_schedule_get(p_ilocationid integer, p_sexaminationtypeid smallint, p_vscheduledate character varying) IS 'Stored procedure returns a list of schedule according to parameters entered';


--
-- TOC entry 282 (class 1255 OID 83371)
-- Name: usp_appointment_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_appointment_get(p_ischeduleid integer, p_iappointmentid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param iprinterid Primary auto-increment key
 * @return array printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 16/08/2016<BR/> Se agrego tabla location y su columna vdescription
 */
      OPEN ref_cursor FOR SELECT oe.iappointmentid , 
			  oe.ischeduleid , 
			  oe.ipartyid , 
			  oe.vcancellationnote , 
			  oe.sresultexaminationid,
			  oe.sstatus,
			  pa.vlastname,
			  pa.vmiddlename,
			  pa.vfirstname,
			  pa.vdocumentnumber,
			  pa.spartytypeid,
			  pa.sdocumenttypeid,
			  pa.vorganization
			FROM appointment oe 
			inner join party pa on oe.ipartyid = pa.ipartyid			
			WHERE (oe.ischeduleid = p_ischeduleid or p_ischeduleid = 0) and
			(oe.iappointmentid = p_iappointmentid or p_iappointmentid = 0) 
			and oe.sstatus = 1 ;
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 282
-- Name: FUNCTION usp_appointment_get(p_ischeduleid integer, p_iappointmentid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_appointment_get(p_ischeduleid integer, p_iappointmentid integer) IS 'Stored procedure returns a list of appointment according to parameters entered';


--
-- TOC entry 284 (class 1255 OID 83372)
-- Name: usp_appointment_maintenance(integer, integer, integer, character varying, smallint, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_appointment_maintenance(INOUT p_iappointmentid integer, p_ischeduleid integer, p_ipartyid integer, p_vcancellationnote character varying, p_sresultexaminationid smallint, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

BEGIN
/**
 * Description: Stored procedure that save, edit and delete a printer<br />
 * Detailed explanation of the object.
* @param  iappointmentid  -- Primary auto increment key
* @param  ischeduleid  -- Schedule id
* @param  ipartyid  -- Party id
* @param  vcancellationnote  -- Cancellation note
* @param  sresultexaminationid  -- Result examination id
* @param  sstatus  -- Status
* @param iinsertuserid 	User ID
* @param vinsertip 	IP address user
* @param iupdateuserid 	Updated user ID
* @param vupdateip 	Update user IP
* @param vipdescription Ip Description
* @param p_voption 	Option to perform.  'INS' - 'UPD' - 'DEL'
 * @return ID printer.
 * @author  rpaucar
 * @version 1.0 rpaucar 22/09/2016<BR/> 
 */


    IF p_vOption = 'INS' THEN
    IF not exists(select iappointmentid from public.appointment where ipartyid=p_ipartyid and ischeduleid=p_ischeduleid) then
	if exists(select ischeduleid from schedule where ischeduleid=p_ischeduleid  and ivacant >0) then
		INSERT INTO public.appointment(
		    ischeduleid,
		    ipartyid,
		    vcancellationnote, 
		    sresultexaminationid, 
		    sstatus,
		    iinsertuserid, 
		    dinsertdate,
		    vinsertip
		     )
		VALUES (
		    p_ischeduleid,
		    p_ipartyid,
		    p_vcancellationnote, 
		    p_sresultexaminationid, 
		    p_sstatus, 
		    p_iinsertuserid, 
		    now(), 
		    p_vinsertip
		    );
		p_iappointmentid := (select currval('appointment_seq'));

		update schedule set ivacant = (ivacant-1) where ischeduleid=p_ischeduleid ;
	else
		p_iappointmentid := -1;
	end if;
    else
		UPDATE public.appointment
				   SET ischeduleid=p_ischeduleid,
				    ipartyid=p_ipartyid,
				    sresultexaminationid=p_sresultexaminationid,  
				    sstatus= p_sstatus, 
				    iupdateuserid= p_iupdateuserid, 
				    dupdatedate= now(), 
				    vupdateip= p_vupdateip 
				 WHERE ipartyid=p_ipartyid and ischeduleid=p_ischeduleid;
		update schedule set ivacant = (ivacant-1) where ischeduleid=p_ischeduleid ;
		
		select iappointmentid into p_iappointmentid from public.appointment  WHERE ipartyid=p_ipartyid and ischeduleid=p_ischeduleid;
	--p_iPrinterId = -1;
    end if;
    
         ELSIF p_vOption = 'UPD' THEN
	 --IF not exists(select * from printer where iprinterid != p_iprinterid and sstatus != -1  and 
	 --(ilocationid=p_ilocationid or vipdescription= p_vipdescription or  upper(vdescription)=upper(p_vDescription) ))then --or  upper(vdescription)=upper(vdescription))) then -- )) then
		 UPDATE public.appointment
				   SET   
				    sstatus= p_sstatus, 
				    iupdateuserid= p_iupdateuserid, 
				    dupdatedate= now(), 
				    vupdateip= p_vupdateip 
				 WHERE ischeduleid=p_ischeduleid and ipartyid=p_ipartyid;
		
		
				 
	--else
		--p_iprinterid=-1;
	--end if;
	ELSIF p_vOption = 'DEL'
	    THEN 
			UPDATE appointment SET sstatus = 0,
			      vcancellationnote=( vcancellationnote || '<br />' || cast(p_vcancellationnote as character varying)), 
			      iupdateuserid = p_iupdateuserid,			      
			       dupdatedate = now(),
			       vupdateip= p_vupdateip 
			WHERE iappointmentid = p_iappointmentid;
			
			update schedule set ivacant = (ivacant+1) where ischeduleid=p_ischeduleid ;

	     END IF;
END;
$$;


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 284
-- Name: FUNCTION usp_appointment_maintenance(INOUT p_iappointmentid integer, p_ischeduleid integer, p_ipartyid integer, p_vcancellationnote character varying, p_sresultexaminationid smallint, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_appointment_maintenance(INOUT p_iappointmentid integer, p_ischeduleid integer, p_ipartyid integer, p_vcancellationnote character varying, p_sresultexaminationid smallint, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a appointment';


--
-- TOC entry 285 (class 1255 OID 83373)
-- Name: usp_calculator_payment(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_calculator_payment(p_ipaymentid integer, p_ipartyid integer, p_vstatusrequest character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
 declare ref_cursor REFCURSOR := 'p_cursor';
BEGIN
      OPEN ref_cursor FOR 
      select 
      r.ipaymentid,
      r.irequestid,
      rd.irequestdetailid,
      rd.ipricingid,
      pp.fpricetotal as fpricetotalrequest,
      COALESCE(rd.bwaived,false) as bwaived,
      r.sstatus,
      r.ipartyid,
      rd.iownerid,
      pa.fpricetotal as fpricetotalpayment,
      COALESCE((select n.snotesubcategoryid from  note n where n.irequestdetailid=rd.irequestdetailid and n.snotesubcategoryid=8802 order by n.inoteid desc limit 1),0) as snotesubcategoryid,
      COALESCE((select n.vobservation from  note n where n.irequestdetailid=rd.irequestdetailid and n.snotesubcategoryid=8802 order by n.inoteid desc limit 1),'') as vobservation
      from request_detail rd
      inner join request r on r.irequestid=rd.irequestid
      left join product_pricing pp on pp.ipricingid=rd.ipricingid      
      inner join payment pa on pa.ipaymentid=r.ipaymentid
      where   
      r.sstatus not in (select cast(regexp_split_to_table(p_vstatusrequest, ',')as int))     
      and (p_ipaymentid=0 or r.ipaymentid=p_ipaymentid)
      order by r.ipaymentid,r.irequestid;
RETURN ref_cursor;
END;
$$;


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 285
-- Name: FUNCTION usp_calculator_payment(p_ipaymentid integer, p_ipartyid integer, p_vstatusrequest character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_calculator_payment(p_ipaymentid integer, p_ipartyid integer, p_vstatusrequest character varying) IS 'Store Procedure';


--
-- TOC entry 286 (class 1255 OID 83374)
-- Name: usp_country_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_country_get(p_scountryid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of country<br />
 * Detailed explanation of the object.
 * @param p_scountryid          	It lets you search for primary key of country.
 * @return ref_cursor			stores data to return in a cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
BEGIN
      open ref_cursor for 
      select
           scountryid,
           vcountrycode,
           vname,
           sstatus
        from country
        where 
	scountryid != 0 and
        (scountryid = p_scountryid or  p_scountryid = 0);
      RETURN (ref_cursor);  
END;
$$;


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 286
-- Name: FUNCTION usp_country_get(p_scountryid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_country_get(p_scountryid integer) IS 'Stored procedure returns a list of country according to parameters entered';


--
-- TOC entry 287 (class 1255 OID 83375)
-- Name: usp_country_maintenance(character varying, integer, character varying, character varying, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_country_maintenance(p_voption character varying, INOUT p_scountryid integer, p_vcountrycode character varying, p_vname character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a country<br />
 * Detailed explanation of the object.
 * @param p_voption           Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_scountryid        Primary auto-increment key
 * @param p_vcountrycode      Stores country code
 * @param p_vname             Stores the name of the country
 * @param p_sstatus           Stores the status of the country 1 -> Activo 0 -> Inactivo
 * @param p_iinsertuserid     User ID
 * @param p_vinsertip         IP address user
 * @param p_iupdateuserid     Updated user ID
 * @param p_vupdateip         Update user IP
 * @return Number
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
BEGIN
  IF p_vOption = 'INS' THEN       
      INSERT INTO country (
        vcountrycode,
        vname,
        sstatus,
        iinsertuserid,
        dinsertdate,
        vinsertip
      ) VALUES (
        p_vcountrycode,
        p_vname,
        p_sstatus,
        p_iinsertuserid,
        now(),
        p_vinsertip
      );
      p_scountryid := (select currval('country_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE country
      SET vcountrycode = p_vcountrycode,
      vname = p_vname,
      sstatus = p_sstatus,
      iupdateuserid = p_iupdateuserid,
      dupdatedate = now(),
      vupdateip = p_vupdateip
      WHERE scountryid = p_scountryid;
  ELSIF p_vOption = 'DEL' THEN  
      UPDATE country
      SET sstatus = 0,
      iupdateuserid = p_iupdateuserid,
      dupdatedate = now(),
      vupdateip = p_vupdateip
      WHERE scountryid = p_scountryid;
  END IF;
END;
$$;


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 287
-- Name: FUNCTION usp_country_maintenance(p_voption character varying, INOUT p_scountryid integer, p_vcountrycode character varying, p_vname character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_country_maintenance(p_voption character varying, INOUT p_scountryid integer, p_vcountrycode character varying, p_vname character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a country';


--
-- TOC entry 288 (class 1255 OID 83376)
-- Name: usp_document_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_document_get(p_idocumentid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param idocumentid Primary auto-increment key
 * @return array printer.
 * @author  rpaucar
 * @version 1.0 rpaucar 31/08/2016<BR/> 
 */
      OPEN ref_cursor FOR SELECT idocumentid, vdocumentcode, vname, sstatus
			FROM public.document
			WHERE (idocumentid = p_idocumentid or p_idocumentid = 0) ;
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 288
-- Name: FUNCTION usp_document_get(p_idocumentid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_document_get(p_idocumentid integer) IS 'Stored procedure returns a list of document according to parameters entered';


--
-- TOC entry 289 (class 1255 OID 83377)
-- Name: usp_document_maintenance(integer, character varying, character varying, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_document_maintenance(INOUT p_idocumentid integer, p_vdocumentcode character varying, p_vname character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a document<br />
 * Detailed explanation of the object.
* @param idocumentid 	Primary auto-increment key
* @param vdocumentcode 	Code to identify the document
* @param vname 		document description
* @param sstatus 	Document Status
* @param iinsertuserid 	User ID
* @param dinsertdate 	Registration date
* @param vinsertip 	IP address user
* @param iupdateuserid  Updated user ID
* @param dupdatedate    Updated date
* @param vupdateip 	Update user IP
* @param p_voption 	Option to perform.  'INS' - 'UPD' - 'DEL'
 * @return ID Document.
 * @author  rpaucar
 * @version 1.0 rpaucar 31/08/2016<BR/> 
 */
 

    IF p_vOption = 'INS' THEN

    INSERT INTO public.document(
            vdocumentcode, 
            vname, 
            sstatus, 
            iinsertuserid, 
            dinsertdate,
            vinsertip
             )
    VALUES (
	    p_vdocumentcode, 
	    p_vname, 
	    1, 
	    p_iinsertuserid, 
	    now(), 
            p_vinsertip
            );

	p_idocumentid := (select currval('document_seq'));

         ELSIF p_vOption = 'UPD' THEN

		if(p_sstatus = 0) then		
			IF NOT EXISTS(select iproductdocumentid from product_document where idocumentid = p_idocumentid AND sstatus = 1 ) THEN
				UPDATE public.document
				   SET vdocumentcode= p_vdocumentcode, 
				   vname= p_vname, 
				   sstatus= p_sstatus, 
				    iupdateuserid= p_iupdateuserid, 
				    dupdatedate= now(), 
				    vupdateip= p_vupdateip 
				 WHERE idocumentid = p_idocumentid;
			ELSE
				p_idocumentid = -1;
			END IF;
		else
				UPDATE public.document
				   SET vdocumentcode= p_vdocumentcode, 
				   vname= p_vname, 
				   sstatus= p_sstatus, 
				    iupdateuserid= p_iupdateuserid, 
				    dupdatedate= now(), 
				    vupdateip= p_vupdateip 
				 WHERE idocumentid = p_idocumentid;
		end if ;



	ELSIF p_vOption = 'DEL'
	    THEN 
	    IF NOT EXISTS(select iproductdocumentid from product_document where idocumentid = p_idocumentid AND sstatus = 1) THEN
		    UPDATE public.document SET sstatus = 0,
				      iupdateuserid = p_iupdateuserid,
				       dupdatedate = now()
		    WHERE idocumentid = p_idocumentid;
	    ELSE
		p_idocumentid = -1;
	    END IF;

END IF;
END;
$$;


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 289
-- Name: FUNCTION usp_document_maintenance(INOUT p_idocumentid integer, p_vdocumentcode character varying, p_vname character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_document_maintenance(INOUT p_idocumentid integer, p_vdocumentcode character varying, p_vname character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a document';


--
-- TOC entry 283 (class 1255 OID 83378)
-- Name: usp_exchangerate_get(smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_exchangerate_get(p_scurrencyid smallint) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of payment<br />
 * Detailed explanation of the object.
 * @param p_scurrencyid     Id systemparameter Group CONFIGURATION_CURRENCY = 2300     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT 
	exc.iexchangerateid, exc.famount, exc.scurrencyid, 
	spar.vvalue as vcurrency,
	exc.dstartdate, exc.dfinishdate,exc.sstatus
	FROM exchangerate exc   
	inner join systemparameter spar on spar.iparameterid=exc.scurrencyid
        WHERE exc.sstatus = 1 AND (p_scurrencyid=0 or exc.scurrencyid = p_scurrencyid)
        AND now()  BETWEEN exc.dstartdate and exc.dfinishdate);      
return (p_cursor);
end;
$$;


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 283
-- Name: FUNCTION usp_exchangerate_get(p_scurrencyid smallint); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_exchangerate_get(p_scurrencyid smallint) IS 'Stored procedure returns a list of exchangerate according to parameters entered';


--
-- TOC entry 290 (class 1255 OID 83379)
-- Name: usp_indicador_cost(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_indicador_cost(p_iproductid integer, p_iplatetypeid integer, p_icategorytypeid integer, p_idurationlicenseid integer, p_idurationinspectionid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of payment <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
DECLARE p_cursor REFCURSOR := 'p_cursor';
declare montoadicional double precision = 0;
declare vproduct character varying(250) = '';
declare p_language integer := p_slanguageid % 140;
BEGIN
  IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

create temp table tbltmp_product (iproductid integer, vdescription character varying(250), icomponentid integer) on commit drop;
insert into tbltmp_product
select distinct p.iproductid, ('('|| p.vproductcode ||') '|| p.vdescription), pc.icomponentid
from product p left join product_composition pc on p.iproductid = pc.iproductid
where p.iproductid = p_iproductid;

create temp table tbltmp_pricing (iproductid integer, platetypecode integer, platetype text, 
categorycode integer, category text, durationlicensecode integer, durationlicense text, 
durationinspectioncode integer, durationinspection text, fpricetotal double precision) on commit drop;
INSERT INTO tbltmp_pricing

select iproductid, platetypecode, null, categorycode, null, durationlicensecode, null, durationinspectioncode, null, fpricetotal from (
	select iproductid,
	(case when platetypecode = '' then null else cast(platetypecode as integer) end) as platetypecode,
	(case when categorycode = '' then null else cast(categorycode as integer) end) as categorycode,
	(case when durationlicensecode = '' then null else cast(durationlicensecode as integer) end) as durationlicensecode,
	(case when durationinspectioncode = '' then null else cast(durationinspectioncode as integer) end) as durationinspectioncode,
	fpricetotal from (
		SELECT p.iproductid,
		trim(split_part(p.vconcept,'|', 1)) as platetypecode, 
		trim(split_part(p.vconcept,'|', 2)) as categorycode,
		trim(split_part(p.vconcept,'|', 3)) as durationlicensecode,
		trim(split_part(p.vconcept,'|', 4)) as durationinspectioncode,
		COALESCE(p.fpricetotal,0) as fpricetotal
		FROM product_pricing p
		inner join tbltmp_product po on po.icomponentid = p.iproductid or p.iproductid = p_iproductid
	) as tables1
) as tables2 where (p_icategorytypeid is null or tables2.categorycode is null or tables2.categorycode = p_icategorytypeid)
and (p_icategorytypeid=0 or tables2.categorycode is null or tables2.categorycode = p_icategorytypeid)
and (p_iplatetypeid=0 or tables2.platetypecode is null or tables2.platetypecode = p_iplatetypeid)
and (p_idurationlicenseid=0 or tables2.durationlicensecode is null or tables2.durationlicensecode = p_idurationlicenseid)
and (p_idurationinspectionid=0 or tables2.durationinspectioncode is null or tables2.durationinspectioncode = p_idurationinspectionid);

update tbltmp_pricing 
set platetype =(select cast(trim(split_part(s.vdescription,'|', p_language)) as character varying) from systemparameter s 
where s.igroupid = 3700 and s.iparameterid = tbltmp_pricing.platetypecode limit 1),
category =(select cast(trim(split_part(s.vdescription,'|', p_language)) as character varying) from systemparameter s 
where s.igroupid = 4000 and s.iparameterid = tbltmp_pricing.categorycode limit 1),
durationlicense =(select cast(trim(split_part(s.vdescription,'|', p_language)) as character varying) from systemparameter s 
where s.igroupid = 4400 and s.iparameterid = tbltmp_pricing.durationlicensecode limit 1),
durationinspection =(select cast(trim(split_part(s.vdescription,'|', p_language)) as character varying) from systemparameter s 
where s.igroupid = 4400 and s.iparameterid = tbltmp_pricing.durationinspectioncode limit 1);

select vdescription into vproduct from tbltmp_product where iproductid = p_iproductid;



if ((select count(iproductid) from tbltmp_pricing where durationlicensecode is not null) > 0 and
	(select count(iproductid) from tbltmp_pricing where durationinspectioncode is not null) > 0) then
	select sum(fpricetotal) into montoadicional from tbltmp_pricing 
	where platetypecode is null and categorycode is null and durationlicensecode is null and durationinspectioncode is null;
	
	OPEN p_cursor FOR
	select p_iproductid as iproductid, vproduct, temp1.platetypecode, temp1.platetype, temp1.categorycode, temp1.category, temp1.durationlicensecode, 
	temp1.durationlicense, temp2.durationinspectioncode, temp2.durationinspection, (temp1.fpricetotal + temp2.fpricetotal + montoadicional) as fpricetotal
	from tbltmp_pricing temp1 cross join tbltmp_pricing temp2
	where temp1.durationlicensecode is not null and temp2.durationinspectioncode is not null;
else
	OPEN p_cursor FOR
	select p_iproductid as iproductid, vproduct, platetypecode, platetype, categorycode, category, durationlicensecode, durationlicense, 
	durationinspectioncode, durationinspection, sum(fpricetotal) as fpricetotal from tbltmp_pricing
	group by platetypecode, platetype, categorycode, category, durationlicensecode, durationlicense, 
	durationinspectioncode, durationinspection;
end if;


--OPEN p_cursor FOR select * from tbltmp_pricing;
  RETURN (p_cursor);
  END;
$$;


--
-- TOC entry 291 (class 1255 OID 83380)
-- Name: usp_insert_data_copyrequest(integer, integer, smallint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_insert_data_copyrequest(p_irequestid integer, p_iproductid integer, p_sstatus smallint, p_iinsertuserid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare p_irequestids integer := 0;
    declare p_iproductidRequestOld integer := 0;
    declare p_irequestdetailid integer := 0;
    declare p_ipaymentid integer := 0;
    declare p_irequestlicenseid integer := 0;
    declare p_istatusreqLicense integer := 0;
    declare p_irequestlicenseidP integer := 0;
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
      
/**
 * Description: Stored procedure that returns a list of vehicles <br />
 * Detailed explanation of the object.
 * @param p_ivehicleid    Code of vehicle.
 * @param p_irequestid    Code of request.
 * @param p_ipartyid      Code of party.
 * @return Return table records vehicle.
 * @author  stello
 * @version 1.0 stello 20/09/2016<BR/> 
 */



INSERT INTO public.payment(
	    vreceiptnumber, dpaymentdate, fpricecost, fpricetax, 
            fpricetotal, sstatus, iinsertuserid, dinsertdate, vinsertip, 
            iupdateuserid, dupdatedate, vupdateip)
SELECT  '', null, 0, 0, 
            0, 6203, 2, now(), '', 
            2, null, null
            FROM payment limit 1; 
p_ipaymentid := (select currval('payment_seq'));           


INSERT INTO public.request(
	    ipaymentid, ipartyid, iproductid, ireferencerequestid, 
            dstartdate, dfinishdate, iproductstepid, bterminate, itramitadorid, 
            sstatus, iinsertuserid, dinsertdate, vinsertip, iupdateuserid, 
            dupdatedate, vupdateip)
SELECT      p_ipaymentid, ipartyid, p_iproductid, p_irequestid, 
            dstartdate, dfinishdate, iproductstepid, bterminate, itramitadorid, 
            p_sstatus, p_iinsertuserid, now(),'', p_iinsertuserid, 
            now(), null
            FROM request 
            WHERE irequestid =  p_irequestid;

p_irequestids := (select currval('request_seq'));

INSERT INTO public.request_history(
            irequestid, vobservation, sstatus, iinsertuserid, 
            dinsertdate, vinsertip, iupdateuserid, dupdatedate, vupdateip)
SELECT      p_irequestids, '', p_sstatus, p_iinsertuserid, 
            now(), '', p_iinsertuserid, now(), null 
            FROM request_history limit 1;


IF EXISTS(select rd.irequestlicenseid FROM request_license rl INNER JOIN request_detail rd 
            ON rl.irequestlicenseid = rd.irequestlicenseid
	    WHERE rd.irequestid = p_irequestid
	    limit 1) then
INSERT INTO public.request_license (
	    slicensetypeid, dstartdate, dexpirydate, dnewstartdate, 
            dnewenddate, vnumberlicense, splatetypeid, vnumberplate, vplatepreview, 
            sdurationlicense, vcomment, sstatus, iinsertuserid, dinsertdate, 
            vinsertip, iupdateuserid, dupdatedate, vupdateip)
SELECT 	    rl.slicensetypeid, rl.dstartdate, rl.dexpirydate, rl.dnewstartdate, 
            rl.dnewenddate, rl.vnumberlicense, rl.splatetypeid, rl.vnumberplate, rl.vplatepreview, 
            rl.sdurationlicense, rl.vcomment, rl.sstatus, rl.iinsertuserid, rl.dinsertdate, 
            rl.vinsertip, rl.iupdateuserid, rl.dupdatedate, rl.vupdateip
	    FROM request_license rl INNER JOIN request_detail rd 
            ON rl.irequestlicenseid = rd.irequestlicenseid
	    WHERE rd.irequestid = p_irequestid
	    limit 1;
p_irequestlicenseid := (select currval('request_license_seq'));
 end if;

INSERT INTO public.request_detail (
	    irequestid, ivehicleid, iownerid, irequestlicenseid, 
            sdriverlicensetypeid, smotocyclegroupid, smotorvehiclegroupid, 
            iproductid, ipricingid, igenevadetailterritoryid, vgenevadetailsubterritory, 
            svisitpermitdurationday, snumber, dissuedate, dexpirydate, vcurrenttab, 
            bwaived, fpricecost, fpricetax, fpricetotal, vnumberplate, vcoment, 
            vplatepreview, vjson, sauthorization, sstatus, iinsertuserid, 
            dinsertdate, vinsertip, iupdateuserid, dupdatedate, vupdateip)
SELECT      p_irequestids, ivehicleid, iownerid, null, 
            sdriverlicensetypeid, smotocyclegroupid, smotorvehiclegroupid, 
            iproductid, ipricingid, igenevadetailterritoryid, vgenevadetailsubterritory, 
            svisitpermitdurationday, snumber, dissuedate, dexpirydate, vcurrenttab, 
            bwaived, fpricecost, fpricetax, fpricetotal, '', vcoment, 
            '', vjson, 0, p_sstatus, p_iinsertuserid, 
            now(), '', p_iinsertuserid, now(), null
	    FROM request_detail 
	    WHERE irequestid =  p_irequestid
	    order by irequestdetailid asc;


 p_irequestdetailid := (select currval('request_detail_seq'));  

p_iproductidRequestOld := (SELECT iproductid FROM request WHERE irequestid = p_irequestids LIMIT 1);

IF (p_iproductidRequestOld = 52)  --REEMISION PARA NVL
THEN 
 UPDATE request_detail set irequestlicenseid = p_irequestlicenseid where irequestid = p_irequestids and iproductid = 9;

ELSEIF (p_iproductidRequestOld = 53) --REEMISION PARA REPLACE PLATE
THEN
 UPDATE request_detail set irequestlicenseid =  p_irequestlicenseid where irequestid = p_irequestids and iproductid = 11;
END IF;

 p_istatusreqLicense := (SELECT sstatus  FROM request_license WHERE irequestlicenseid = p_irequestlicenseid LIMIT 1);


p_irequestlicenseidP := (SELECT rd.irequestlicenseid from request_detail rd inner join request r on r.irequestid = rd.irequestid
				inner join request_license rl on rl.irequestlicenseid = rd.irequestlicenseid	
				where r.irequestid = p_irequestid order by rl.dinsertdate desc limit 1);

UPDATE request_license set sstatus = 4917 where irequestlicenseid = p_irequestlicenseidP;

OPEN ref_cursor FOR 

select p_irequestids AS irequestid, p_irequestdetailid AS irequestdetailid, p_ipaymentid AS ipaymentid, 
p_irequestlicenseid AS irequestlicenseid, p_istatusreqLicense AS istatusreqLicense;

RETURN ref_cursor;
END;
$$;


--
-- TOC entry 292 (class 1255 OID 83382)
-- Name: usp_inspector_get(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_inspector_get() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of inspectors according to parameters entered <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
  BEGIN
  OPEN ref_cursor FOR

  SELECT COALESCE(P.ipartyid, 0) as ipartyid,
  COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '') as vname
  FROM party P 
  WHERE P.spartytypeid = 3402 AND P.sstatus = 1
  ORDER BY COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '');

  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 292
-- Name: FUNCTION usp_inspector_get(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_inspector_get() IS 'Stored procedure returns a list of inspectors according to parameters entered';


--
-- TOC entry 293 (class 1255 OID 83383)
-- Name: usp_location_get(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_location_get(p_ilocationid integer, p_itypelocationid integer, p_slevelid integer, p_scountryid integer, p_ireferenceid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of location<br />
 * Detailed explanation of the object.
 * @param p_ilocationid          	It lets you search for primary key of location. 		'0' All values
 * @param p_itypelocationid          	Location Type. 							'0' All values
 * @param p_slevelid          		Location Level. 						'0' All values
 * @param p_scountryid          	It lets you search for primary key of country. 			'0' All values
 * @param p_ireferenceid          	It lets you search for primary key of location (reference). 	'0' All values
 * @return ref_cursor			stores data to return in a cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_ulti_ilocationid integer := p_ilocationid;
declare p_language integer := p_slanguageid % 140;
BEGIN
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
  IF p_ilocationid = 0 THEN
      open ref_cursor for 
      SELECT 
        LOC.ilocationid,
        LOC.slocationtypeid,
        cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) vlocationtype,
        LOC.slevelid,
        cast(trim(split_part(LVL.vdescription,'|', p_language)) as character varying)  vlevel,
        LOC.scountryid,
        CO.VNAME vcountry,
        LOC.vdescription,
        LOC.ireferenceid,
        CASE WHEN LOC.ireferenceid = 0 THEN '' ELSE (SELECT AUX.vdescription FROM LOCATION AUX WHERE AUX.ilocationid = LOC.ireferenceid) END vreference,
        LOC.sstatus
      FROM LOCATION LOC
      INNER JOIN SYSTEMPARAMETER SP ON SP.IPARAMETERID = LOC.slocationtypeid
      INNER JOIN SYSTEMPARAMETER LVL ON LVL.IPARAMETERID = LOC.slevelid
      INNER JOIN COUNTRY CO ON CO.scountryid = LOC.scountryid
      WHERE LOC.sstatus = 1 AND
      (p_iLocationId = 0  or LOC.ilocationid = p_iLocationId ) AND
      (p_iTypeLocationId = 0 or LOC.slocationtypeid = p_iTypeLocationId) AND
      (p_slevelid = 0 or LOC.slevelid = p_slevelid ) AND
      (p_sCountryId = 0 or LOC.scountryid = p_sCountryId) AND
      (p_iReferenceId = 0 or LOC.ireferenceid = p_iReferenceId)
      order by LOC.slevelid asc;
      RETURN (ref_cursor); 
      
  ELSE

      DROP TABLE IF EXISTS temp_location;
      CREATE TEMP TABLE temp_location (ilocationid integer);
      while p_ulti_ilocationid is not null LOOP
        insert into temp_location  (ilocationid) values (p_ulti_ilocationid);
        select ireferenceid into p_ulti_ilocationid from location where ilocationid = p_ulti_ilocationid;
      END LOOP;
	
      open ref_cursor for 
      SELECT 
        LOC.ilocationid,
        LOC.slocationtypeid,
        cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) vlocationtype,
        LOC.slevelid,
        cast(trim(split_part(lvl.vdescription,'|', p_language)) as character varying) vlevel,
        LOC.scountryid,
        CO.VNAME vcountry,
        LOC.vdescription,
        LOC.ireferenceid,
        CASE WHEN LOC.ireferenceid = 0 THEN '' ELSE (SELECT AUX.vdescription FROM LOCATION AUX WHERE AUX.ilocationid = LOC.ireferenceid) END vreference,
        --'' vreference,
        LOC.sstatus
      FROM LOCATION LOC
      INNER JOIN SYSTEMPARAMETER SP ON SP.IPARAMETERID = LOC.slocationtypeid
      INNER JOIN SYSTEMPARAMETER LVL ON LVL.IPARAMETERID = LOC.slevelid
      INNER JOIN COUNTRY CO ON CO.scountryid = LOC.scountryid
      WHERE LOC.sstatus = 1 AND LOC.ilocationid != 0 AND
      (LOC.ilocationid in (select ilocationid from temp_location)) AND
      (LOC.slocationtypeid = p_iTypeLocationId or p_iTypeLocationId = 0) AND
      (LOC.slevelid = p_slevelid or p_slevelid = 0) AND
      (LOC.scountryid = p_sCountryId or p_sCountryId = 0) AND
      (LOC.ireferenceid = p_iReferenceId or p_iReferenceId = 0)
      order by LOC.slevelid asc;
      RETURN (ref_cursor); 
      
  END IF; 
END;
$$;


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 293
-- Name: FUNCTION usp_location_get(p_ilocationid integer, p_itypelocationid integer, p_slevelid integer, p_scountryid integer, p_ireferenceid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_location_get(p_ilocationid integer, p_itypelocationid integer, p_slevelid integer, p_scountryid integer, p_ireferenceid integer, p_slanguageid integer) IS 'Stored procedure returns a list of location according to parameters entered';


--
-- TOC entry 294 (class 1255 OID 83384)
-- Name: usp_location_getall(integer, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_location_getall(p_ilocationid integer, p_itypelocationid integer, p_slevelid integer, p_scountryid integer, p_ireferenceid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of location<br />
 * Detailed explanation of the object.
 * @param p_ilocationid          	It lets you search for primary key of location. 		'0' All values
 * @param p_itypelocationid          	Location Type. 							'0' All values
 * @param p_slevelid          		Location Level. 						'0' All values
 * @param p_scountryid          	It lets you search for primary key of country. 			'0' All values
 * @param p_ireferenceid          	It lets you search for primary key of location (reference). 	'0' All values
 * @return ref_cursor			stores data to return in a cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_ulti_ilocationid integer := p_ilocationid;
declare p_language integer := p_slanguageid % 140;
BEGIN
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
  IF p_ilocationid = 0 THEN
      open ref_cursor for 
      SELECT 
        LOC.ilocationid,
        LOC.slocationtypeid,
        cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) vlocationtype,
        LOC.slevelid,
        cast(trim(split_part(LVL.vdescription,'|', p_language)) as character varying)  vlevel,
        LOC.scountryid,
        CO.VNAME vcountry,
        LOC.vdescription,
        LOC.ireferenceid,
        CASE WHEN LOC.ireferenceid = 0 THEN '' ELSE (SELECT AUX.vdescription FROM LOCATION AUX WHERE AUX.ilocationid = LOC.ireferenceid) END vreference,
        LOC.sstatus
      FROM LOCATION LOC
      INNER JOIN SYSTEMPARAMETER SP ON SP.IPARAMETERID = LOC.slocationtypeid
      INNER JOIN SYSTEMPARAMETER LVL ON LVL.IPARAMETERID = LOC.slevelid
      INNER JOIN COUNTRY CO ON CO.scountryid = LOC.scountryid
      WHERE LOC.sstatus = 1 AND
      (p_iLocationId = 0  or LOC.ilocationid = p_iLocationId ) AND
      (p_iTypeLocationId = 0 or LOC.slocationtypeid = p_iTypeLocationId) AND
      (p_slevelid = 0 or LOC.slevelid = p_slevelid ) AND
      (p_sCountryId = 0 or LOC.scountryid = p_sCountryId) AND
      (p_iReferenceId = 0 or LOC.ireferenceid = p_iReferenceId)
      order by LOC.slevelid asc;
      RETURN (ref_cursor); 
      
  ELSE

      CREATE TEMP TABLE temp_location (ilocationid integer, slevelid integer, ireferenceid integer, scountryid integer, slocationtypeid integer) on commit drop;
      while p_ulti_ilocationid is not null LOOP
        insert into temp_location  (ilocationid, slevelid, ireferenceid, scountryid, slocationtypeid)
        select p_ulti_ilocationid, slevelid, ireferenceid, scountryid, slocationtypeid from location where ilocationid = p_ulti_ilocationid;
        select ireferenceid into p_ulti_ilocationid from location where ilocationid = p_ulti_ilocationid;
      END LOOP;
	
      open ref_cursor for 
      SELECT 
        LOC.ilocationid,
        LOC.slocationtypeid,
        cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) vlocationtype,
        LOC.slevelid,
        cast(trim(split_part(lvl.vdescription,'|', p_language)) as character varying) vlevel,
        LOC.scountryid,
        CO.VNAME vcountry,
        LOC.vdescription,
        LOC.ireferenceid,
        CASE WHEN LOC.ireferenceid = 0 THEN '' ELSE (SELECT AUX.vdescription FROM LOCATION AUX WHERE AUX.ilocationid = LOC.ireferenceid) END vreference,
        --'' vreference,
        LOC.sstatus
      FROM temp_location temploc
      INNER JOIN LOCATION LOC ON LOC.slevelid = temploc.slevelid and LOC.scountryid = temploc.scountryid and LOC.slocationtypeid = temploc.slocationtypeid and  (temploc.ireferenceid is null or LOC.ireferenceid = temploc.ireferenceid)
      INNER JOIN SYSTEMPARAMETER SP ON SP.IPARAMETERID = LOC.slocationtypeid
      INNER JOIN SYSTEMPARAMETER LVL ON LVL.IPARAMETERID = LOC.slevelid
      INNER JOIN COUNTRY CO ON CO.scountryid = LOC.scountryid
      WHERE LOC.sstatus = 1 AND LOC.ilocationid != 0
      --(LOC.ilocationid in (select ilocationid from temp_location)) AND
      --(LOC.slocationtypeid = p_iTypeLocationId or p_iTypeLocationId = 0) AND
      --(LOC.slevelid = p_slevelid or p_slevelid = 0) AND
      --(LOC.scountryid = p_sCountryId or p_sCountryId = 0) AND
      --(LOC.ireferenceid = p_iReferenceId or p_iReferenceId = 0)
      order by LOC.slevelid, LOC.ilocationid  asc;
      RETURN (ref_cursor); 
      
  END IF; 
END;
$$;


--
-- TOC entry 295 (class 1255 OID 83385)
-- Name: usp_location_maintenance(character varying, integer, integer, integer, integer, character varying, integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_location_maintenance(p_voption character varying, INOUT p_ilocationid integer, p_slocationtypeid integer, p_slevelid integer, p_scountryid integer, p_vdescription character varying, p_ireferenceid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a location <br />
 * Detailed explanation of the object.
 * @param p_voption            Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_ilocationid        Primary auto-increment key
 * @param p_slocationtypeid    Referring to table systemparameter Stores references to the types of locations 
 * @param p_slevelid           Referring to table systemparameter Stores references to the level of locations
 * @param p_scountryid         Stores the reference to the table country
 * @param p_vdescription       Stores the description of location
 * @param p_ireferenceid       Referring to table location Stores references a location higher level
 * @param p_sstatus            Stores the status of the location 1 -> Activo 0 -> Inactivo
 * @param p_iinsertuserid      User ID
 * @param p_vinsertip          IP address user
 * @param p_iupdateuserid      Updated user ID
 * @param p_vupdateip          Update user IP
 * @return Number
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
BEGIN
  IF p_ireferenceid = 0 THEN 
        p_ireferenceid := null;
  END IF;
  IF p_vOption = 'INS' THEN       
      INSERT INTO location (
        slocationtypeid,
        slevelid,
        scountryid,
        vdescription,
        ireferenceid,
        sstatus,
        iinsertuserid,
        dinsertdate,
        vinsertip
      ) VALUES (
        p_slocationtypeid,
        p_slevelid,
        p_scountryid,
        p_vdescription,
        p_ireferenceid,
        p_sstatus,
        p_iinsertuserid,
        now(),
        p_vinsertip
      );
      p_ilocationid := (select currval('location_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE location
      SET slocationtypeid = p_slocationtypeid,
      slevelid = p_slevelid,
      scountryid = p_scountryid,
      vdescription = p_vdescription,
      ireferenceid = p_ireferenceid,
      sstatus = p_sstatus,
      iupdateuserid = p_iupdateuserid,
      dupdatedate = now(),
      vupdateip = p_vupdateip
      WHERE ilocationid = p_ilocationid;
  ELSIF p_vOption = 'DEL' THEN  
      UPDATE location
      SET sstatus = 0,
      iupdateuserid = p_iupdateuserid,
      dupdatedate = now(),
      vupdateip = p_vupdateip
      WHERE ilocationid = p_ilocationid;
  END IF;
END;
$$;


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 295
-- Name: FUNCTION usp_location_maintenance(p_voption character varying, INOUT p_ilocationid integer, p_slocationtypeid integer, p_slevelid integer, p_scountryid integer, p_vdescription character varying, p_ireferenceid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_location_maintenance(p_voption character varying, INOUT p_ilocationid integer, p_slocationtypeid integer, p_slevelid integer, p_scountryid integer, p_vdescription character varying, p_ireferenceid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a location';


--
-- TOC entry 296 (class 1255 OID 83386)
-- Name: usp_note(integer, integer, integer, integer, smallint, smallint, character varying, integer, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_note(INOUT p_inoteid integer, p_irequestdetailid integer, p_ipartyfromid integer, p_ipartyforid integer, p_snotecategoryid smallint, p_stabname smallint, p_vobservation character varying, p_ireferencenoteid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

	IF p_voption = 'INS' THEN

		INSERT INTO public.note(
					--inoteid,
					irequestdetailid,
					ipartyfromid,
					ipartyforid,
					snotecategoryid, 
					stabname,
					vobservation,
					ireferencenoteid,
					sstatus,
					iinsertuserid, 
					--dinsertdate,
					vinsertip
					)
			    VALUES (
				    --?,
				    p_irequestdetailid,
				    p_ipartyfromid,
				    p_ipartyforid,
				    p_snotecategoryid, 
				    p_stabname,
				    p_vobservation,
				    p_ireferencenoteid,
				    p_sstatus,
				    p_iinsertuserid, 
				    now(),
				    p_vinsertip
				    );

		p_inoteid := (select currval('printer_seq'));

	ELSIF p_voption = 'UPD' THEN

		UPDATE public.note
		   SET 
		       irequestdetailid = p_irequestdetailid,
		       ipartyfromid = p_ipartyfromid,
		       ipartyforid = p_ipartyforid, 
		       snotecategoryid = p_snotecategoryid,
		       stabname = p_stabname,
		       vobservation = p_vobservation,
		       ireferencenoteid = p_ireferencenoteid, 
		       sstatus = p_sstatus,
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE inoteid = p_inoteid;

	ELSIF p_voption = 'DEL' THEN
	
		UPDATE public.note
		   SET 
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE inoteid = p_inoteid AND
			sstatus = p_sstatus;
		
	END IF;
END;
$$;


--
-- TOC entry 297 (class 1255 OID 83387)
-- Name: usp_note_detail_get(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_note_detail_get(p_inoteid integer, p_iinsertuserid integer, p_irequestdetailid integer, p_ipartyfor integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    declare p_language integer := p_slanguageid % 140;
    BEGIN
	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
    /**
 * Description: Stored procedure that returns a list of notes<br />
 * Detailed explanation of the object.
 * @param p_inoteid        Note ID.
 * @param p_iinsertuserid  Insert User ID.
 * @return Return table vehicle detail
 * @author  stello
 * @version 1.0 stello 04/09/2016<BR/> 
 */
      OPEN ref_cursor FOR 
      SELECT  inoteid, no.irequestdetailid, no.vobservation, no.vtabname, ireferencenoteid, 
      no.sstatus, no.iinsertuserid, no.vinsertip, no.dinsertdate, cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vcategoryname,	
      pfrom.vfirstname vfrom, pfor.vfirstname vfor, p.vdescription vproductname, 
      (select p.vfirstname from party p 
				inner join request r on r.ipartyid = p.ipartyid 
				inner join request_detail rd on rd.irequestid = r.irequestid
				where rd.irequestdetailid = no.irequestdetailid) vnameparty,
				pk.vdescription vpackagename,
      --(select p1.vdescription from request r inner join product p1 on p1.iproductid = r.iproductid
						--where r.irequestid = rd.irequestid limit 1) vpackagename, 
						cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) as vsubcategoryname,
						(pk.vproductcode || '|' || p.vproductcode) vproductcode	
      FROM note no
      LEFT JOIN systemparameter sp on sp.iparameterid = no.snotecategoryid and sp.igroupid = 8700 
      LEFT JOIN party pfrom on pfrom.ipartyid = no.ipartyfromid
      LEFT JOIN party pfor on pfor.ipartyid = no.ipartyforid
      LEFT JOIN request_detail rd on rd.irequestdetailid = no.irequestdetailid
      LEFT JOIN product p on p.iproductid = rd.iproductid
      LEFT JOIN request r on r.irequestid = rd.irequestid
      LEFT JOIN product pk on pk.iproductid = r.iproductid
      LEFT JOIN systemparameter sp1 on sp1.iparameterid= no.snotecategoryid
      LEFT JOIN systemparameter sp2 on sp2.iparameterid= no.snotesubcategoryid  
      WHERE (p_inoteid = 0 or inoteid = p_inoteid) AND
      (p_iinsertuserid = 0 or no.iinsertuserid = p_iinsertuserid) AND
      (p_irequestdetailid = 0 or no.irequestdetailid = p_irequestdetailid) AND
      (p_ipartyfor = 0 or no.ipartyforid = p_ipartyfor) AND
      no.sstatus = 1 ORDER by dinsertdate desc;
      
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 298 (class 1255 OID 83388)
-- Name: usp_note_get(integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_note_get(p_inoteid integer, p_iinsertuserid integer, p_irequestdetailid integer, p_ipartyid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    declare p_language integer := p_slanguageid % 140;
    BEGIN
	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
    /**
 * Description: Stored procedure that returns a list of notes<br />
 * Detailed explanation of the object.
 * @param p_inoteid        Note ID.
 * @param p_iinsertuserid  Insert User ID.
 * @return Return table vehicle detail
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */
      OPEN ref_cursor FOR 
       SELECT data.* from (

 SELECT  inoteid, no.irequestdetailid, no.vobservation, no.vtabname, ireferencenoteid, 
      no.sstatus, no.iinsertuserid, no.vinsertip, no.dinsertdate, cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vcategoryname,	
      pfrom.vfirstname vfrom, pfor.vfirstname vfor, p.vdescription vproductname, 
      CASE WHEN COALESCE(p1.vorganization, '') = '' THEN COALESCE(p1.vlastname, '') || ' ' ||  COALESCE(p1.vfirstname, '') || ' ' || COALESCE(p1.vmiddlename, '') || ' ' || COALESCE(p1.vmaidenname,'') ELSE p1.vorganization END vnameparty,
      pk.vdescription vpackagename, cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) as vsubcategoryname,
      p1.ipartyid, no.snotecategoryid, (pk.vproductcode || '|' || p.vproductcode) vproductcode		
      FROM note no
      LEFT JOIN systemparameter sp on sp.iparameterid = no.snotecategoryid and sp.igroupid = 8700 
      LEFT JOIN party pfrom on pfrom.ipartyid = no.ipartyfromid
      LEFT JOIN party pfor on pfor.ipartyid = no.ipartyforid
      LEFT JOIN request_detail rd on rd.irequestdetailid = no.irequestdetailid
      LEFT JOIN product p on p.iproductid = rd.iproductid
      LEFT JOIN request r on r.irequestid = rd.irequestid
      LEFT JOIN product pk on pk.iproductid = r.iproductid
      LEFT JOIN party p1 on p1.ipartyid = r.ipartyid
      LEFT JOIN systemparameter sp1 on sp1.iparameterid= no.snotecategoryid 
      LEFT JOIN systemparameter sp2 on sp2.iparameterid= no.snotesubcategoryid 
      WHERE (p_inoteid = 0 or inoteid = p_inoteid) AND
      (p_iinsertuserid = 0 or no.iinsertuserid = p_iinsertuserid) AND
      (p_irequestdetailid = 0 or no.irequestdetailid = p_irequestdetailid) AND
      (p_ipartyid = 0 or p1.ipartyid = p_ipartyid) AND
      no.sstatus = 1 AND
      snotecategoryid in (8701,8702) AND
      no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid and no1.snotecategoryid in (8701,8702) ) 
      
      --ORDER by no.dinsertdate desc;

 UNION      

SELECT  inoteid, no.irequestdetailid, no.vobservation, no.vtabname, ireferencenoteid, 
      no.sstatus, no.iinsertuserid, no.vinsertip, no.dinsertdate, cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vcategoryname,	
      pfrom.vfirstname vfrom, pfor.vfirstname vfor, p.vdescription vproductname, 
      CASE WHEN COALESCE(p1.vorganization, '') = '' THEN COALESCE(p1.vlastname, '') || ' ' ||  COALESCE(p1.vfirstname, '') || ' ' || COALESCE(p1.vmiddlename, '') || ' ' || COALESCE(p1.vmaidenname,'') ELSE p1.vorganization END vnameparty,
      pk.vdescription vpackagename, cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) as vsubcategoryname,
      p1.ipartyid, no.snotecategoryid, (pk.vproductcode || '|' || p.vproductcode) vproductcode						
      FROM note no
      LEFT JOIN systemparameter sp on sp.iparameterid = no.snotecategoryid and sp.igroupid = 8700 
      LEFT JOIN party pfrom on pfrom.ipartyid = no.ipartyfromid
      LEFT JOIN party pfor on pfor.ipartyid = no.ipartyforid
      LEFT JOIN request_detail rd on rd.irequestdetailid = no.irequestdetailid
      LEFT JOIN product p on p.iproductid = rd.iproductid
      LEFT JOIN request r on r.irequestid = rd.irequestid
      LEFT JOIN product pk on pk.iproductid = r.iproductid
      LEFT JOIN party p1 on p1.ipartyid = no.ipartyforid
      LEFT JOIN systemparameter sp1 on sp1.iparameterid= no.snotecategoryid 
      LEFT JOIN systemparameter sp2 on sp2.iparameterid= no.snotesubcategoryid 
      WHERE (p_inoteid = 0 or inoteid = p_inoteid) AND
      (p_iinsertuserid = 0 or no.iinsertuserid = p_iinsertuserid) AND
      (p_irequestdetailid = 0 or no.irequestdetailid = p_irequestdetailid) AND
      (p_ipartyid = 0 or p1.ipartyid = p_ipartyid) AND
      no.sstatus = 1 AND
      snotecategoryid in (8703) AND
      no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.ipartyforid = p_ipartyid and no1.snotecategoryid in (8703)) 
      ) as data
      ORDER by data.dinsertdate desc;
      
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 299 (class 1255 OID 83389)
-- Name: usp_note_maintenance(integer, integer, integer, integer, smallint, character varying, character varying, integer, smallint, smallint, integer, character varying, integer, character varying, smallint, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_note_maintenance(INOUT p_inoteid integer, p_irequestdetailid integer, p_ipartyfromid integer, p_ipartyforid integer, p_snotecategoryid smallint, p_vtabname character varying, p_vobservation character varying, p_ireferencenoteid integer, p_snotesubcategoryid smallint, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_sstatusrequestdetail smallint, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

DECLARE irequestidget INTEGER := 0;

BEGIN

	IF p_voption = 'INS' THEN

		INSERT INTO public.note(
					--inoteid,
					irequestdetailid,
					ipartyfromid,
					ipartyforid,
					snotecategoryid, 
					vtabname,
					vobservation,
					ireferencenoteid,
					snotesubcategoryid,
					sstatus,
					iinsertuserid, 
					dinsertdate,
					vinsertip
					)
			    VALUES (
				    --?,
				    p_irequestdetailid,
				    p_ipartyfromid,
				    p_ipartyforid,
				    p_snotecategoryid, 
				    p_vtabname,
				    p_vobservation,
				    p_ireferencenoteid,
				    p_snotesubcategoryid,
				    p_sstatus,
				    p_iinsertuserid, 
				    now(),
				    p_vinsertip
				    );

		p_inoteid := (select currval('note_seq'));

	ELSIF p_voption = 'UPD' THEN

		UPDATE public.note
		   SET 
		       irequestdetailid = p_irequestdetailid,
		       ipartyfromid = p_ipartyfromid,
		       ipartyforid = p_ipartyforid, 
		       snotecategoryid = p_snotecategoryid,
		       vtabname = p_vtabname,
		       vobservation = p_vobservation,
		       ireferencenoteid = p_ireferencenoteid, 
		       snotesubcategoryid = p_snotesubcategoryid,
		       sstatus = p_sstatus,
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE inoteid = p_inoteid;

	ELSIF p_voption = 'DEL' THEN
	
		UPDATE public.note
		   SET 
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE inoteid = p_inoteid AND
			sstatus = p_sstatus;
		
	END IF;

	IF p_sstatusrequestdetail > 0 THEN

		UPDATE public.request_detail
		   SET 
		       sauthorization = ( CASE WHEN p_sstatusrequestdetail = 5007 THEN 8722 ELSE 0 END ) ,
		       sstatus = p_sstatusrequestdetail,
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE irequestdetailid = p_irequestdetailid;

		SELECT irequestid INTO irequestidget FROM request_detail WHERE irequestdetailid = p_irequestdetailid LIMIT 1;

		UPDATE public.request
		   SET 
		       sstatus = p_sstatusrequestdetail,
		       iupdateuserid= p_iupdateuserid, 
		       dupdatedate= now(), 
		       vupdateip= p_vupdateip 
		 WHERE irequestid = irequestidget;
				
	END IF;
	
END;
$$;


--
-- TOC entry 300 (class 1255 OID 83390)
-- Name: usp_office_examinationtype_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_office_examinationtype_get(p_iofficeexaminationtypeid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    declare p_language integer := p_slanguageid % 140;
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param iprinterid Primary auto-increment key
 * @return array printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 16/08/2016<BR/> Se agrego tabla location y su columna vdescription
 */
 IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
      OPEN ref_cursor FOR SELECT oe.iofficeexaminationtypeid , 
			  oe.ilocationid , 
			  oe.sexaminationtypeid , 
			  oe.snumberperson , 
			  oe.vnote , 
			  oe.sstatus,
			  cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) examinationtype,
			  cast(trim(split_part(l.vdescription,'|', p_language)) as character varying) vlocation
			FROM office_examinationtype oe 
			inner join location l on oe.ilocationid=l.ilocationid
			inner join systemparameter sp on sp.iparameterid = oe.sexaminationtypeid
			WHERE (oe.iofficeexaminationtypeid = p_iofficeexaminationtypeid or p_iofficeexaminationtypeid = 0) ;
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 300
-- Name: FUNCTION usp_office_examinationtype_get(p_iofficeexaminationtypeid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_office_examinationtype_get(p_iofficeexaminationtypeid integer, p_slanguageid integer) IS 'Stored procedure returns a list of examinationtype according to parameters entered';


--
-- TOC entry 302 (class 1255 OID 83391)
-- Name: usp_office_examinationtype_maintenance(integer, integer, smallint, smallint, character varying, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_office_examinationtype_maintenance(INOUT p_iofficeexaminationtypeid integer, p_ilocationid integer, p_sexaminationtypeid smallint, p_snumberperson smallint, p_vnote character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a printer<br />
 * Detailed explanation of the object.
* @param p_iofficeexaminationtypeid 	Primary auto-increment key
* @param p_ilocationid 	Location ID
* @param p_sexaminationtypeid 	Printer description
* @param p_snumberperson 	number person
* @param p_vnote 	note
* @param p_sstatus 	Status
* @param iinsertuserid 	User ID
* @param vinsertip 	IP address user
* @param iupdateuserid 	Updated user ID
* @param vupdateip 	Update user IP
* @param p_voption 	Option to perform.  'INS' - 'UPD' - 'DEL'
 * @return ID printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */


    IF p_vOption = 'INS' THEN
    --IF not exists(select * from printer where (ilocationid=p_ilocationid or upper(vdescription)=upper(p_vDescription) or vipdescription= p_vipdescription) and sstatus != -1 ) then
		INSERT INTO public.office_examinationtype(
		    ilocationid, 
		    sexaminationtypeid, 
		    snumberperson, 
		    vnote,
		    sstatus,
		    iinsertuserid, 
		    dinsertdate,
		    vinsertip
		     )
	    VALUES (
		    p_ilocationid, 
		    p_sexaminationtypeid, 
		    p_snumberperson, 
		    p_vnote, 
		    p_sstatus, 
		    p_iInsertUserId, 
		    now(), 
		    p_vInsertTip
		    );
		p_iofficeexaminationtypeid := (select currval('office_examinationtype_seq'));
    --else
	--p_iPrinterId = -1;
    --end if;
    
         ELSIF p_vOption = 'UPD' THEN
	 --IF not exists(select * from printer where iprinterid != p_iprinterid and sstatus != -1  and 
	 --(ilocationid=p_ilocationid or vipdescription= p_vipdescription or  upper(vdescription)=upper(p_vDescription) ))then --or  upper(vdescription)=upper(vdescription))) then -- )) then
		 UPDATE public.office_examinationtype
				   SET ilocationid= p_iLocationId, 
				   sexaminationtypeid= p_sexaminationtypeid, 
				   snumberperson= p_snumberperson, 
				   vnote= p_vnote, 
				   sstatus= p_sstatus, 
				    iupdateuserid= p_iUpdateUserId, 
				    dupdatedate= now(), 
				    vupdateip= p_vUpdateIp 
				 WHERE iofficeexaminationtypeid = p_iofficeexaminationtypeid;
	--else
		--p_iprinterid=-1;
	--end if;
	ELSIF p_vOption = 'DEL'
	    THEN 
	    --IF not exists(select * from printer_user where iprinterid = p_iprinterid and sstatus != -1) then
			UPDATE office_examinationtype SET sstatus = 0,
			      iupdateuserid = p_iUpdateUserId,
			       dupdatedate = now()
			WHERE iofficeexaminationtypeid = p_iofficeexaminationtypeid;
	    --else
		--p_iPrinterId=-1;
	    --end if;
	    

END IF;
END;
$$;


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 302
-- Name: FUNCTION usp_office_examinationtype_maintenance(INOUT p_iofficeexaminationtypeid integer, p_ilocationid integer, p_sexaminationtypeid smallint, p_snumberperson smallint, p_vnote character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_office_examinationtype_maintenance(INOUT p_iofficeexaminationtypeid integer, p_ilocationid integer, p_sexaminationtypeid smallint, p_snumberperson smallint, p_vnote character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a examinationtype';


--
-- TOC entry 303 (class 1255 OID 83392)
-- Name: usp_party_codeonlineaccess(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_codeonlineaccess(p_ipartyid integer, p_vcodeonlineacces character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of party_company <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  jcondori
 * @version 1.0 cburgos 01/08/2016 <br />
 */
declare p_cantidad integer := 0;
declare p_rspt integer := 0;
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
  BEGIN
	SELECT count(ipartyid) into p_cantidad
	FROM party
	WHERE vcodeonlineacces = p_vcodeonlineacces and ipartyid != p_ipartyid;

	
	IF p_cantidad > 0 THEN
		p_rspt = -2;
	ELSE 
		p_rspt = 1;
	END IF;
		
	OPEN ref_cursor FOR
		select p_rspt;
		
  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 304 (class 1255 OID 83393)
-- Name: usp_party_company_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_company_get(p_icompanyid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of party_company <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  jcondori
 * @version 1.0 cburgos 01/08/2016 <br />
 */
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
  BEGIN
  OPEN ref_cursor FOR

	SELECT 
		PC.ipartycompanyid AS ipartycompanyid,
		PC.ipartyid AS ipartyid,
		P.vfirstname AS vfirstname,
		P.vmiddlename AS vmiddlename,
		P.vlastname AS vlastname
	FROM party_company PC
	JOIN party P ON P.ipartyid = PC.ipartyid
	WHERE PC.icompanyid = p_icompanyid
	AND PC.sstatus = 1;

  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 304
-- Name: FUNCTION usp_party_company_get(p_icompanyid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_party_company_get(p_icompanyid integer) IS 'Stored procedure returns a list of party_company';


--
-- TOC entry 305 (class 1255 OID 83394)
-- Name: usp_party_concessionary_get(character varying, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_concessionary_get(p_vpartytypeid character varying, p_spartysubtypeid integer, p_ipartyid integer, p_ilocationid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a types of party <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  stello
 * @version 1.0 stello 02/08/2016 <br />
 */
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
DECLARE p_language integer := p_slanguageid % 140;
  BEGIN
  IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
  OPEN ref_cursor FOR

  SELECT COALESCE(P.ipartyid, 0) as ipartyid,
  COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '') as vname,
  COALESCE(P.vorganization, '') as vorganization,
  COALESCE(P.vphonenumberinformation, '') as vphonenumber,
  COALESCE(PL.ipartylocationid, 0) as ipartylocationid,
  COALESCE(PL.ilocationid, 0) as ilocationid,
  COALESCE(PL.ipartylocationtypeid, 0) as ipartylocationtypeid,
  COALESCE(PL.vstreet, '') as vstreet,
  COALESCE(PL.vinformation, '') as vinformation,
  COALESCE(P.vlastname, '') as vlastname,
  COALESCE(P.vfirstname, '') as vfirstname,
  COALESCE(P.vmiddlename, '') as vmiddlename,
  COALESCE(C.vname, '') as vcountry,
  COALESCE(P.ddateofbirth, now()) as ddateofbirth,
  cast(trim(split_part(sp.vdescription,'|', 1)) as character varying) as vdescriptionDocType,
  COALESCE(P.vdocumentnumber, '') as vdocumentnumber,
  COALESCE(P.vemailaddress, '') as vemailaddress,
  COALESCE(P.sdocumenttypeid, 0) as sdocumenttypeid,
  
  COALESCE(P.vmaidenname, '') as vmaidenname,
  COALESCE(P.snationalityid, 0) as snationalityid,
  COALESCE(P.ipartyaddressid, 0) as ipartyaddressid,
  COALESCE(P.sgenderid, 0) as sgenderid,
  COALESCE(P.fheigth, 0.0) as fheigth,
  COALESCE(P.seyecolourid, 0) as seyecolourid,
  COALESCE(P.shaircolourid, 0) as shaircolourid,
  COALESCE(P.sstatus, 0) as sstatus
  FROM party P 
  LEFT JOIN party_location PL ON PL.ipartyid = P.ipartyid and PL.ipartylocationtypeid !=1004
  LEFT JOIN location L ON L.ilocationid = PL.ilocationid 
  LEFT JOIN country C ON C.scountryid = L.scountryid
  LEFT JOIN systemparameter sp ON sp.iparameterid = P.sdocumenttypeid and  sp.igroupid = 3420 
  WHERE p.spartysubtypeid = p_spartysubtypeid and 
  (p_vpartytypeid = '-1' or P.spartytypeid in (select cast(regexp_split_to_table(p_vpartytypeid, ',')as int))) 
  AND (p_ipartyid = '0' or P.ipartyid = p_ipartyid) 
  AND  (COALESCE(p_ilocationid, 0) = 0 OR PL.ilocationid = p_ilocationid);
  --AND P.sstatus = 1;
  --ORDER BY COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '');

  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 306 (class 1255 OID 83395)
-- Name: usp_party_concessionary_requester_get(character varying, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_concessionary_requester_get(p_vpartytypeid character varying, p_ipartyid integer, p_icompanyid integer, p_ilocationid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a types of party <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  stello
 * @version 1.0 stello 02/08/2016 <br />
 */
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
DECLARE p_language integer := p_slanguageid % 140;
  BEGIN
  IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
  OPEN ref_cursor FOR

  select
	  COALESCE(P.ipartyid, 0) as ipartyid,
	  COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '') as vname,
	  COALESCE(P.vorganization, '') as vorganization,
	  COALESCE(P.vphonenumberinformation, '') as vphonenumber,
	  COALESCE(PL.ipartylocationid, 0) as ipartylocationid,
	  COALESCE(PL.ilocationid, 0) as ilocationid,
	  COALESCE(PL.ipartylocationtypeid, 0) as ipartylocationtypeid,
	  COALESCE(PL.vstreet, '') as vstreet,
	  COALESCE(PL.vinformation, '') as vinformation,
	  COALESCE(P.vlastname, '') as vlastname,
	  COALESCE(P.vfirstname, '') as vfirstname,
	  COALESCE(P.vmiddlename, '') as vmiddlename,
	  COALESCE(C.vname, '') as vcountry,
	  COALESCE(P.ddateofbirth, now()) as ddateofbirth,
	  cast(trim(split_part(sp.vdescription,'|', 1)) as character varying) as vdescriptionDocType,
	  COALESCE(P.vdocumentnumber, '') as vdocumentnumber,
	  COALESCE(P.vemailaddress, '') as vemailaddress,
	  COALESCE(P.sdocumenttypeid, 0) as sdocumenttypeid,  
	  COALESCE(P.vmaidenname, '') as vmaidenname,
	  COALESCE(P.snationalityid, 0) as snationalityid,
	  COALESCE(P.ipartyaddressid, 0) as ipartyaddressid,
	  COALESCE(P.sgenderid, 0) as sgenderid,
	  COALESCE(P.fheigth, 0.0) as fheigth,
	  COALESCE(P.seyecolourid, 0) as seyecolourid,
	  COALESCE(P.shaircolourid, 0) as shaircolourid,
	  pcom.sstatus as sstatus,
	  pcom.ipartycompanyid 
  from  party P
  LEFT JOIN party_location PL ON PL.ipartyid = P.ipartyid
  LEFT JOIN location L ON L.ilocationid = PL.ilocationid 
  LEFT JOIN country C ON C.scountryid = L.scountryid
  LEFT JOIN systemparameter sp ON sp.iparameterid = P.sdocumenttypeid and  sp.igroupid = 3420 
  inner join party_company pcom on P.ipartyid=pcom.ipartyid
  where pcom.icompanyid = p_icompanyid and 
        (p_vpartytypeid = '-1' or P.spartysubtypeid in (select cast(regexp_split_to_table(p_vpartytypeid, ',')as int))) 
        AND (p_ipartyid = '0' or P.ipartyid = p_ipartyid) 
        AND  (COALESCE(p_ilocationid, 0) = 0 OR PL.ilocationid = p_ilocationid);
  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 307 (class 1255 OID 83396)
-- Name: usp_party_maintenance(integer, smallint, smallint, smallint, character varying, character varying, character varying, character varying, character varying, character varying, smallint, smallint, integer, character varying, smallint, double precision, timestamp without time zone, boolean, smallint, smallint, boolean, character varying, character varying, character varying, character varying, character varying, boolean, timestamp without time zone, timestamp without time zone, boolean, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_maintenance(INOUT p_ipartyid integer, p_spartytypeid smallint, p_spartysubtypeid smallint, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vlastname character varying, p_vmiddlename character varying, p_vmaidenname character varying, p_vfirstname character varying, p_vorganization character varying, p_scountrybirth smallint, p_snationalityid smallint, p_ipartyaddressid integer, p_vpartycode character varying, p_sgenderid smallint, p_fheigth double precision, p_ddateofbirth timestamp without time zone, p_bdeceased boolean, p_seyecolourid smallint, p_shaircolourid smallint, p_bdisqualified boolean, p_vdisability character varying, p_vphoto character varying, p_vemailaddress character varying, p_vcontactinformation character varying, p_vphonenumberinformation character varying, p_bonlineaccess boolean, p_ddisqualifiedstartdate timestamp without time zone, p_ddisqualifiedenddate timestamp without time zone, p_bnocheques boolean, p_vcommentdeceased character varying, p_vcommentdisqualified character varying, p_vcommentnocheques character varying, p_vcodeonlineacces character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a party<br />
 * Detailed explanation of the object.
* @param ipartyid Id primary key
* @param spartytypeid relation to systemparameter igropud = 3400
* @param spartysubtypeid Type of organization, relation to systemparameter igropud = 3440
* @param sdocumenttypeid Type document, relation to systemparameter igropud = 3420
* @param vdocumentnumber Document Number
* @param vlastname Last name
* @param vmiddlename Middle name
* @param vmaidenname Maiden name
* @param vfirstname Firts name
* @param vorganization Organization name
* @param snationalityid Current nationality
* @param ipartyaddressid relation to table country
* @param vpartycode Personalized unique code considering any format
* @param sgenderid relation to systemparameter igropud = 3490
* @param fheigth Heigth
* @param ddateofbirth Date of birth
* @param bdeceased Is Deceased
* @param seyecolourid Eye colour
* @param shaircolourid Hair colour
* @param bdisqualified It is disqualified for procedures
* @param vdisability Disability, separated by | , max 3 disabilities. Format = 3600 igroupid | descrip | igroupid 3600 | descrip | igroupid 3600 | descrip
* @param vphoto Name and  extension photo 
* @param vemailaddress Phone and email contact
* @param vcontactinformation Last, first and middle name contact
* @param vphonenumberinformation Phone1, phone2, mobile and email in the address details
* @param bonlineaccess Is access online
* @param ddisqualifiedstartdate Initial date of disqualification
* @param ddisqualifiedenddate Finish date of disqualification
* @param sstatus Registration Status 
* @param iinsertuserid User ID
* @param vinsertip IP address user
* @param iupdateuserid Updated user ID
* @param vupdateip Update user IP
* @param p_voption conditional for the CRUD
 * @return ID party.
 * @author  jcondori
 * @version 1.0 jcondori 26/07/2016<BR/> 
 */

    IF p_vOption = 'INS' THEN
	IF not exists(select ipartyid from party where vdocumentnumber=p_vdocumentnumber and sdocumenttypeid=p_sdocumenttypeid) then
			INSERT INTO public.party(
			spartytypeid,
			spartysubtypeid,
			sdocumenttypeid,
			vdocumentnumber,
			vlastname,
			vmiddlename,
			vmaidenname,
			vfirstname,
			vorganization,
			scountrybirth,
			snationalityid,
			ipartyaddressid,
			vpartycode,
			sgenderid,
			fheigth,
			ddateofbirth,
			bdeceased,
			seyecolourid,
			shaircolourid,
			bdisqualified,
			vdisability,
			vphoto,
			vemailaddress,
			vcontactinformation,
			vphonenumberinformation,
			bonlineaccess,
			ddisqualifiedstartdate,
			ddisqualifiedenddate,
			bnocheques,
			vcommentdeceased,
			vcommentdisqualified,
			vcommentnocheques,
			vcodeonlineacces,
			sstatus,
			iinsertuserid,
			dinsertdate,
			vinsertip
			)
		VALUES (
			p_spartytypeid,
			p_spartysubtypeid,
			p_sdocumenttypeid,
			p_vdocumentnumber,
			p_vlastname,
			p_vmiddlename,
			p_vmaidenname,
			p_vfirstname,
			p_vorganization,
			p_scountrybirth,
			p_snationalityid,
			p_ipartyaddressid,
			p_vpartycode,
			p_sgenderid,
			p_fheigth,
			p_ddateofbirth,
			p_bdeceased,
			p_seyecolourid,
			p_shaircolourid,
			p_bdisqualified,
			p_vdisability,
			p_vphoto,
			p_vemailaddress,
			p_vcontactinformation,
			p_vphonenumberinformation,
			p_bonlineaccess,
			p_ddisqualifiedstartdate,
			p_ddisqualifiedenddate,
			p_bnocheques,
			p_vcommentdeceased,
			p_vcommentdisqualified,
			p_vcommentnocheques,
			p_vcodeonlineacces,
			p_sstatus,
			p_iinsertuserid,
			now(),
			p_vinsertip
		);
		p_ipartyid := (SELECT currval('party_seq'));
	else
		p_ipartyid := -1;
       end if;
       
    ELSIF p_vOption = 'UPD' THEN
	IF not exists(select ipartyid from party where vdocumentnumber=p_vdocumentnumber and sdocumenttypeid=p_sdocumenttypeid and ipartyid != p_ipartyid) then
		UPDATE party
		SET 
			spartytypeid = COALESCE(p_spartytypeid,spartytypeid),
			spartysubtypeid = COALESCE(p_spartysubtypeid,spartysubtypeid), 
			sdocumenttypeid = COALESCE(p_sdocumenttypeid,sdocumenttypeid), 
			vdocumentnumber = COALESCE(p_vdocumentnumber,vdocumentnumber), 
			vlastname = COALESCE(p_vlastname,vlastname), 
			vmiddlename = COALESCE(p_vmiddlename,vmiddlename), 
			vmaidenname = COALESCE(p_vmaidenname,vmaidenname), 
			vfirstname = COALESCE(p_vfirstname,vfirstname), 
			vorganization = COALESCE(p_vorganization,vorganization),
			scountrybirth = COALESCE(p_scountrybirth,scountrybirth),			
			snationalityid = COALESCE(p_snationalityid,snationalityid), 
			ipartyaddressid = COALESCE(p_ipartyaddressid,ipartyaddressid), 
			vpartycode = COALESCE(p_vpartycode,vpartycode), 
			sgenderid = COALESCE(p_sgenderid,sgenderid), 
			fheigth = COALESCE(p_fheigth,fheigth), 
			ddateofbirth = COALESCE(p_ddateofbirth,ddateofbirth), 
			bdeceased = COALESCE(p_bdeceased,bdeceased), 
			seyecolourid = COALESCE(p_seyecolourid,seyecolourid), 
			shaircolourid = COALESCE(p_shaircolourid,shaircolourid), 
			bdisqualified = COALESCE(p_bdisqualified,bdisqualified), 
			vdisability = COALESCE(p_vdisability,vdisability), 
			vphoto = COALESCE(p_vphoto,vphoto), 
			vemailaddress = COALESCE(p_vemailaddress,vemailaddress), 
			vcontactinformation = COALESCE(p_vcontactinformation,vcontactinformation), 
			vphonenumberinformation = COALESCE(p_vphonenumberinformation,vphonenumberinformation), 
			bonlineaccess = COALESCE(p_bonlineaccess,bonlineaccess), 
			ddisqualifiedstartdate = COALESCE(p_ddisqualifiedstartdate,ddisqualifiedstartdate), 
			ddisqualifiedenddate = COALESCE(p_ddisqualifiedenddate,ddisqualifiedenddate), 
			bnocheques = COALESCE(p_bnocheques,bnocheques),	
			vcommentdeceased=COALESCE(p_vcommentdeceased,vcommentdeceased),
			vcommentdisqualified=COALESCE(p_vcommentdisqualified,vcommentdisqualified),
			vcommentnocheques=COALESCE(p_vcommentnocheques,vcommentnocheques),	
			vcodeonlineacces = COALESCE(p_vcodeonlineacces,vcodeonlineacces),	
			sstatus = COALESCE(p_sstatus,sstatus), 
			iupdateuserid = COALESCE(p_iupdateuserid,iupdateuserid), 
			dupdatedate = now(),
			vupdateip = COALESCE(p_vupdateip,vupdateip)
		WHERE ipartyid = p_ipartyid;
	else
		p_ipartyid := -1;
	end if;

   ELSIF p_vOption = 'DEL' THEN

	UPDATE party
	SET 
		sstatus = p_sstatus,
		iupdateuserid = p_iupdateuserid,
		dupdatedate = now(),
		vupdateip = p_vupdateip
	WHERE ipartyid = p_ipartyid;

   END IF;
   
END;
$$;


--
-- TOC entry 301 (class 1255 OID 83398)
-- Name: usp_party_search(integer, integer, smallint, character varying, character varying, character varying, character varying, timestamp without time zone, character varying, character varying, smallint, integer, character varying, character varying, integer, integer, character varying, smallint, smallint, integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_search(p_ipartyid integer, p_spartytypeid integer, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vfirstname character varying, p_vmiddlename character varying, p_vlastname character varying, p_ddateofbirth timestamp without time zone, p_vorganization character varying, p_zipcode character varying, p_scountryid smallint, p_ilocationid integer, p_vstreet character varying, p_vvinnumber character varying, p_imakeid integer, p_imodelid integer, p_venginenumber character varying, p_scategorytypeid smallint, p_sprimarycolourid smallint, p_idriverlicenseid integer, p_vnumberplate character varying, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

DECLARE  ref_cursor REFCURSOR := 'ref_cursor';
DECLARE  locationtypeid integer := 0;
DECLARE p_language integer := p_slanguageid % 140;
  BEGIN

/**
 * Description: Stored procedure that returns a list of parties <br />
 * Detailed explanation of the object.
 * @param p_ipartyid Id primary key
* @param p_spartytypeid relation to systemparameter igropud = 3400
* @param p_sdocumenttypeid Type document, relation to systemparameter igropud = 3420
* @param p_vdocumentnumber Document Number
* @param p_vlastname Last name
* @param p_vmiddlename Middle name
* @param p_vmaidenname Maiden name
* @param p_vfirstname Firts name
* @param p_vorganization Organization name
* @param p_ddateofbirth Date of birth
* @param p_zipcode ZipCode
* @param p_ilocationid Id location
* @param p_vstreet Description street1 or street2
* @param p_vvinnumber VIN Number Vehicle
* @param p_imakeid Id Make Vehicle
* @param p_imodelid Id Model Vehicle
* @param p_venginenumber Number ebgine vehicle
* @param p_scategorytypeid category type vehicle
* @param p_sprimarycolourid id colour primary vehicle
* @param p_idriverlicenseid id driver licenses
* @param p_vnumberplate number plate vehicle
* @param p_voption conditional for the CRUD
 * @return array de party's.
 * @author  jcondori
 * @version 1.0 jcondori 26/07/2016<BR/> 
 */

	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

	IF (COALESCE(p_ipartyid, 0) = 0) THEN
		locationtypeid := 1004;
	END IF;

	OPEN ref_cursor FOR
			SELECT COALESCE(P.ipartyid, 0) as ipartyid,
				COALESCE(P.spartytypeid, 0) as spartytypeid,
				COALESCE(P.spartysubtypeid, 0) as spartysubtypeid,
				COALESCE(P.sdocumenttypeid, 0) as sdocumenttypeid,
				COALESCE(P.vdocumentnumber, '') as vdocumentnumber,
				COALESCE(P.vlastname, '') as vlastname,
				COALESCE(P.vmiddlename, '') as vmiddlename,
				COALESCE(P.vmaidenname, '') as vmaidenname,
				COALESCE(P.vfirstname, '') as vfirstname,
				COALESCE(P.vorganization, '') as vorganization,
				COALESCE(P.scountrybirth, 0) as scountrybirth,
				COALESCE(P.snationalityid, 0) as snationalityid,
				COALESCE(P.ipartyaddressid, 0) as ipartyaddressid,
				COALESCE(P.vpartycode, '') as vpartycode,
				COALESCE(P.sgenderid, 0) as sgenderid,
				COALESCE(P.fheigth, 0.0) as fheigth,
				COALESCE(P.ddateofbirth, now()) as ddateofbirth,
				COALESCE(P.bdeceased, false) as bdeceased,
				COALESCE(P.seyecolourid, 0) as seyecolourid,
				COALESCE(P.shaircolourid, 0) as shaircolourid,
				COALESCE(P.bdisqualified, false) as bdisqualified,
				COALESCE(P.vdisability, '') as vdisability,
				COALESCE(P.vphoto, '') as vphoto,
				COALESCE(P.vemailaddress, '') as vemailaddress,
				COALESCE(P.vcontactinformation, '') as vcontactinformation,
				COALESCE(P.vphonenumberinformation, '') as vphonenumberinformation,
				COALESCE(P.bonlineaccess, false) as bonlineaccess,
				COALESCE(P.ddisqualifiedstartdate, now()) as ddisqualifiedstartdate,
				COALESCE(P.ddisqualifiedenddate, now()) as ddisqualifiedenddate,
								
				COALESCE(P.bnocheques, false) as bnocheques,	--Aument
				COALESCE(vcommentdeceased,'')as vcommentdeceased, --Aument
				COALESCE(vcommentdisqualified,'') as vcommentdisqualified, --Aument
				COALESCE(vcommentnocheques,'') as vcommentnocheques, --Aument
				COALESCE(vcodeonlineacces,'') as vcodeonlineacces, --Aument
											
				COALESCE(P.sstatus, 0) as sstatus,
				COALESCE(P.iinsertuserid, 0) as iinsertuserid,
				COALESCE(P.dinsertdate, now()) as dinsertdate,
				COALESCE(P.vinsertip, '') as vinsertip,
				COALESCE(P.iupdateuserid, 0) as iupdateuserid,
				COALESCE(P.dupdatedate, now()) as dupdatedate,
				COALESCE(P.vupdateip, '') as vupdateip,
				-- Location
				COALESCE(PL.ipartylocationid, 0) as ipartylocationid,
				COALESCE(PL.ilocationid, 0) as ilocationid,
				COALESCE(PL.ipartylocationtypeid, 0) as ipartylocationtypeid,
				COALESCE(PL.vstreet, '') as vstreet,
				COALESCE(PL.vinformation, '') as vinformation,

				CASE WHEN COALESCE(P.vorganization, '') = '' THEN COALESCE(P.vlastname, '') || ' ' ||  COALESCE(P.vfirstname, '') || ' ' || COALESCE(P.vmiddlename, '') || ' ' || COALESCE(P.vmaidenname,'') ELSE P.vorganization END vnameparty,
				cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vdocumenttype,
				cast(trim(split_part(SP1.vdescription,'|', p_language)) as character varying) as vorganizationtypename
			FROM party P 
			--LEFT JOIN request RE ON RE.ipartyid = P.ipartyid 
			--LEFT JOIN request_detail RD ON RE.irequestid = RD.irequestid
			LEFT JOIN vehicle V ON V.iownerid = P.ipartyid
			LEFT JOIN party_location PL ON PL.ipartyid = P.ipartyid
			LEFT JOIN location l ON l.ilocationid = PL.ilocationid
			LEFT JOIN country c on c.scountryid = l.scountryid
			LEFT JOIN location l1 ON l1.ilocationid = l.ireferenceid
			LEFT JOIN location l2 ON l2.ilocationid = l1.ireferenceid
			LEFT JOIN location l3 ON l3.ilocationid = l2.ireferenceid
			LEFT JOIN systemparameter SP ON SP.iparameterid = P.sdocumenttypeid
			LEFT JOIN systemparameter SP1 ON SP1.iparameterid = P.spartysubtypeid and SP1.igroupid = 3440
			WHERE (COALESCE(p_ipartyid, 0) = 0 OR P.ipartyid = p_ipartyid)			
				AND ((COALESCE(p_spartytypeid, 0) = 0 and (3401 = P.spartytypeid OR 3404 = P.spartytypeid)) or  P.spartytypeid = p_spartytypeid)				
				AND  (COALESCE(p_sdocumenttypeid, 0) = 0 OR P.sdocumenttypeid = p_sdocumenttypeid)
				AND  (COALESCE(p_vdocumentnumber, '') = '' OR UPPER(P.vdocumentnumber) LIKE '%' || UPPER(p_vdocumentnumber) || '%')
				AND  (COALESCE(p_vfirstname, '') = '' OR UPPER(P.vfirstname) LIKE '%' || UPPER(p_vfirstname) || '%')
				AND  (COALESCE(p_vmiddlename, '') = '' OR UPPER(P.vmiddlename) LIKE '%' || UPPER(p_vmiddlename) || '%')
				AND  (COALESCE(p_vlastname, '') = '' OR UPPER(P.vlastname) LIKE '%' || UPPER(p_vlastname) || '%')
				AND  (COALESCE(p_ddateofbirth, '19900101') = '19900101' OR to_char(P.ddateofbirth,'YYYY/MM/DD')  = to_char(p_ddateofbirth,'YYYY/MM/DD'))
				AND  (COALESCE(p_vorganization, '') = '' OR UPPER(P.vorganization) LIKE '%' || UPPER(p_vorganization) || '%')
				AND  (COALESCE(p_zipcode, '') =  '' OR UPPER(PL.vinformation) LIKE '%' || UPPER(p_zipcode) || '%')
				--AND  (COALESCE(p_ilocationid, 0) = 0 OR PL.ilocationid = p_ilocationid)


				--AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || UPPER(p_vstreet) || '%')
				AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || split_part(UPPER(p_vstreet),'|', 1) || '%')   
				AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || split_part(UPPER(p_vstreet),'|', 2) || '%') 

				
				AND  (COALESCE(p_vvinnumber, '') =  '' OR UPPER(V.vvinnumber) LIKE '%' || UPPER(p_vvinnumber) || '%')
				AND  (COALESCE(p_imakeid, 0) = 0 OR V.imakeid = p_imakeid)
				AND  (COALESCE(p_imodelid, 0) = 0 OR V.imodelid = p_imodelid)
				AND  (COALESCE(p_venginenumber, '') = '' OR UPPER(V.venginenumber) LIKE '%' || UPPER(p_venginenumber) || '%')
				AND  (COALESCE(p_scategorytypeid, 0) = 0 OR V.scategorytypeid = p_scategorytypeid)
				AND  (COALESCE(p_sprimarycolourid, 0) = 0 OR V.sprimarycolourid = p_sprimarycolourid)
				--AND  (COALESCE(p_idriverlicenseid, 0) = 0 OR RD.irequestlicenseid = p_idriverlicenseid)
				--AND  (COALESCE(p_vnumberplate, '') = '' OR UPPER(RD.vnumberplate) LIKE '%' || UPPER(p_vnumberplate) || '%')
				AND  ((locationtypeid = 0) OR ipartylocationtypeid <> locationtypeid)
				AND  (COALESCE(P.spartysubtypeid, 0)  not in (3443,3444,3446,3447))
				AND P.sstatus = 1
				AND (COALESCE(p_scountryid, 0) = 0 OR c.scountryid = p_scountryid)
				AND (COALESCE(p_ilocationid, 0) = 0 OR l.ilocationid = p_ilocationid or l1.ilocationid = p_ilocationid or l2.ilocationid = p_ilocationid or l3.ilocationid = p_ilocationid)
				
			GROUP BY
			P.ipartyid, 
			P.spartytypeid, 
			P.spartysubtypeid, 
			P.sdocumenttypeid,
			P.vdocumentnumber,
			P.vlastname,
			P.vmiddlename,
			P.vmaidenname,
			P.vfirstname,
			P.vorganization,
			P.scountrybirth,
			P.snationalityid,
			P.ipartyaddressid,
			P.vpartycode,
			P.sgenderid,
			P.fheigth,
			P.ddateofbirth,
			P.bdeceased,
			P.seyecolourid,
			P.shaircolourid,
			P.bdisqualified,
			P.vdisability,
			P.vphoto,
			P.vemailaddress,
			P.vcontactinformation,
			P.vphonenumberinformation,
			P.bonlineaccess,
			P.ddisqualifiedstartdate,
			P.ddisqualifiedenddate,
			P.sstatus,
			P.iinsertuserid,
			P.dinsertdate,
			P.vinsertip,
			P.iupdateuserid,
			P.dupdatedate,
			P.vupdateip,
			PL.ipartylocationid,
			PL.ilocationid,
			PL.ipartylocationtypeid,
			PL.vstreet,
			PL.vinformation,
			SP.vdescription,
			SP1.vdescription;
	  RETURN (ref_cursor);  
    
  END;
$$;


--
-- TOC entry 277 (class 1255 OID 83400)
-- Name: usp_party_search(integer, integer, smallint, character varying, character varying, character varying, character varying, timestamp without time zone, character varying, character varying, smallint, integer, character varying, character varying, integer, integer, character varying, smallint, smallint, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_search(p_ipartyid integer, p_spartytypeid integer, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vfirstname character varying, p_vmiddlename character varying, p_vlastname character varying, p_ddateofbirth timestamp without time zone, p_vorganization character varying, p_zipcode character varying, p_scountryid smallint, p_ilocationid integer, p_vstreet character varying, p_vvinnumber character varying, p_imakeid integer, p_imodelid integer, p_venginenumber character varying, p_scategorytypeid smallint, p_sprimarycolourid smallint, p_idriverlicenseid integer, p_vnumberplate character varying, p_slanguageid integer, p_vpartytypeid character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

DECLARE  ref_cursor REFCURSOR := 'ref_cursor';
DECLARE  locationtypeid integer := 0;
DECLARE p_language integer := p_slanguageid % 140;
  BEGIN

/**
 * Description: Stored procedure that returns a list of parties <br />
 * Detailed explanation of the object.
 * @param p_ipartyid Id primary key
* @param p_spartytypeid relation to systemparameter igropud = 3400
* @param p_sdocumenttypeid Type document, relation to systemparameter igropud = 3420
* @param p_vdocumentnumber Document Number
* @param p_vlastname Last name
* @param p_vmiddlename Middle name
* @param p_vmaidenname Maiden name
* @param p_vfirstname Firts name
* @param p_vorganization Organization name
* @param p_ddateofbirth Date of birth
* @param p_zipcode ZipCode
* @param p_ilocationid Id location
* @param p_vstreet Description street1 or street2
* @param p_vvinnumber VIN Number Vehicle
* @param p_imakeid Id Make Vehicle
* @param p_imodelid Id Model Vehicle
* @param p_venginenumber Number ebgine vehicle
* @param p_scategorytypeid category type vehicle
* @param p_sprimarycolourid id colour primary vehicle
* @param p_idriverlicenseid id driver licenses
* @param p_vnumberplate number plate vehicle
* @param p_voption conditional for the CRUD
 * @return array de party's.
 * @author  jcondori
 * @version 1.0 jcondori 26/07/2016<BR/> 
 */

	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

	IF (COALESCE(p_ipartyid, 0) = 0) THEN
		locationtypeid := 1004;
	END IF;

	OPEN ref_cursor FOR
			SELECT COALESCE(P.ipartyid, 0) as ipartyid,
				COALESCE(P.spartytypeid, 0) as spartytypeid,
				COALESCE(P.spartysubtypeid, 0) as spartysubtypeid,
				COALESCE(P.sdocumenttypeid, 0) as sdocumenttypeid,
				COALESCE(P.vdocumentnumber, '') as vdocumentnumber,
				COALESCE(P.vlastname, '') as vlastname,
				COALESCE(P.vmiddlename, '') as vmiddlename,
				COALESCE(P.vmaidenname, '') as vmaidenname,
				COALESCE(P.vfirstname, '') as vfirstname,
				COALESCE(P.vorganization, '') as vorganization,
				COALESCE(P.scountrybirth, 0) as scountrybirth,
				COALESCE(P.snationalityid, 0) as snationalityid,
				COALESCE(P.ipartyaddressid, 0) as ipartyaddressid,
				COALESCE(P.vpartycode, '') as vpartycode,
				COALESCE(P.sgenderid, 0) as sgenderid,
				COALESCE(P.fheigth, 0.0) as fheigth,
				COALESCE(P.ddateofbirth, now()) as ddateofbirth,
				COALESCE(P.bdeceased, false) as bdeceased,
				COALESCE(P.seyecolourid, 0) as seyecolourid,
				COALESCE(P.shaircolourid, 0) as shaircolourid,
				COALESCE(P.bdisqualified, false) as bdisqualified,
				COALESCE(P.vdisability, '') as vdisability,
				COALESCE(P.vphoto, '') as vphoto,
				COALESCE(P.vemailaddress, '') as vemailaddress,
				COALESCE(P.vcontactinformation, '') as vcontactinformation,
				COALESCE(P.vphonenumberinformation, '') as vphonenumberinformation,
				COALESCE(P.bonlineaccess, false) as bonlineaccess,
				COALESCE(P.ddisqualifiedstartdate, now()) as ddisqualifiedstartdate,
				COALESCE(P.ddisqualifiedenddate, now()) as ddisqualifiedenddate,
								
				COALESCE(P.bnocheques, false) as bnocheques,	--Aument
				COALESCE(vcommentdeceased,'')as vcommentdeceased, --Aument
				COALESCE(vcommentdisqualified,'') as vcommentdisqualified, --Aument
				COALESCE(vcommentnocheques,'') as vcommentnocheques, --Aument
				COALESCE(vcodeonlineacces,'') as vcodeonlineacces, --Aument
											
				COALESCE(P.sstatus, 0) as sstatus,
				COALESCE(P.iinsertuserid, 0) as iinsertuserid,
				COALESCE(P.dinsertdate, now()) as dinsertdate,
				COALESCE(P.vinsertip, '') as vinsertip,
				COALESCE(P.iupdateuserid, 0) as iupdateuserid,
				COALESCE(P.dupdatedate, now()) as dupdatedate,
				COALESCE(P.vupdateip, '') as vupdateip,
				-- Location
				COALESCE(PL.ipartylocationid, 0) as ipartylocationid,
				COALESCE(PL.ilocationid, 0) as ilocationid,
				COALESCE(PL.ipartylocationtypeid, 0) as ipartylocationtypeid,
				COALESCE(PL.vstreet, '') as vstreet,
				COALESCE(PL.vinformation, '') as vinformation,

				CASE WHEN COALESCE(P.vorganization, '') = '' THEN COALESCE(P.vlastname, '') || ' ' ||  COALESCE(P.vfirstname, '') || ' ' || COALESCE(P.vmiddlename, '') || ' ' || COALESCE(P.vmaidenname,'') ELSE P.vorganization END vnameparty,
				cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vdocumenttype,
				cast(trim(split_part(SP1.vdescription,'|', p_language)) as character varying) as vorganizationtypename
			FROM party P 
			--LEFT JOIN request RE ON RE.ipartyid = P.ipartyid 
			--LEFT JOIN request_detail RD ON RE.irequestid = RD.irequestid
			LEFT JOIN vehicle V ON V.iownerid = P.ipartyid
			LEFT JOIN party_location PL ON PL.ipartyid = P.ipartyid
			LEFT JOIN location l ON l.ilocationid = PL.ilocationid
			LEFT JOIN country c on c.scountryid = l.scountryid
			LEFT JOIN location l1 ON l1.ilocationid = l.ireferenceid
			LEFT JOIN location l2 ON l2.ilocationid = l1.ireferenceid
			LEFT JOIN location l3 ON l3.ilocationid = l2.ireferenceid
			LEFT JOIN systemparameter SP ON SP.iparameterid = P.sdocumenttypeid
			LEFT JOIN systemparameter SP1 ON SP1.iparameterid = P.spartysubtypeid and SP1.igroupid = 3440
			WHERE (COALESCE(p_ipartyid, 0) = 0 OR P.ipartyid = p_ipartyid)			
				AND ((COALESCE(p_spartytypeid, 0) = 0 and (3401 = P.spartytypeid OR 3404 = P.spartytypeid)) or  P.spartytypeid = p_spartytypeid)				
				AND  (COALESCE(p_sdocumenttypeid, 0) = 0 OR P.sdocumenttypeid = p_sdocumenttypeid)
				AND  (COALESCE(p_vdocumentnumber, '') = '' OR UPPER(P.vdocumentnumber) LIKE '%' || UPPER(p_vdocumentnumber) || '%')
				AND  (COALESCE(p_vfirstname, '') = '' OR UPPER(P.vfirstname) LIKE '%' || UPPER(p_vfirstname) || '%')
				AND  (COALESCE(p_vmiddlename, '') = '' OR UPPER(P.vmiddlename) LIKE '%' || UPPER(p_vmiddlename) || '%')
				AND  (COALESCE(p_vlastname, '') = '' OR UPPER(P.vlastname) LIKE '%' || UPPER(p_vlastname) || '%')
				AND  (COALESCE(p_ddateofbirth, '19900101') = '19900101' OR to_char(P.ddateofbirth,'YYYY/MM/DD')  = to_char(p_ddateofbirth,'YYYY/MM/DD'))
				AND  (COALESCE(p_vorganization, '') = '' OR UPPER(P.vorganization) LIKE '%' || UPPER(p_vorganization) || '%')
				AND  (COALESCE(p_zipcode, '') =  '' OR UPPER(PL.vinformation) LIKE '%' || UPPER(p_zipcode) || '%')
				--AND  (COALESCE(p_ilocationid, 0) = 0 OR PL.ilocationid = p_ilocationid)


				--AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || UPPER(p_vstreet) || '%')
				AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || split_part(UPPER(p_vstreet),'|', 1) || '%')   
				AND  (COALESCE(p_vstreet, '') =  '' OR UPPER(PL.vstreet) LIKE '%' || split_part(UPPER(p_vstreet),'|', 2) || '%') 

				
				AND  (COALESCE(p_vvinnumber, '') =  '' OR UPPER(V.vvinnumber) LIKE '%' || UPPER(p_vvinnumber) || '%')
				AND  (COALESCE(p_imakeid, 0) = 0 OR V.imakeid = p_imakeid)
				AND  (COALESCE(p_imodelid, 0) = 0 OR V.imodelid = p_imodelid)
				AND  (COALESCE(p_venginenumber, '') = '' OR UPPER(V.venginenumber) LIKE '%' || UPPER(p_venginenumber) || '%')
				AND  (COALESCE(p_scategorytypeid, 0) = 0 OR V.scategorytypeid = p_scategorytypeid)
				AND  (COALESCE(p_sprimarycolourid, 0) = 0 OR V.sprimarycolourid = p_sprimarycolourid)
				--AND  (COALESCE(p_idriverlicenseid, 0) = 0 OR RD.irequestlicenseid = p_idriverlicenseid)
				--AND  (COALESCE(p_vnumberplate, '') = '' OR UPPER(RD.vnumberplate) LIKE '%' || UPPER(p_vnumberplate) || '%')
				AND  ((locationtypeid = 0) OR ipartylocationtypeid <> locationtypeid)

				--AND  (COALESCE(P.spartysubtypeid, 0)  not in (3443,3444,3446,3447))
				AND  (COALESCE(P.spartysubtypeid, 0)  not in (select case when item = '' then 0 else cast(item as smallint) end from 
				     (select regexp_split_to_table(p_vpartytypeid,',') as item) as table1))
				AND P.sstatus = 1
				AND (COALESCE(p_scountryid, 0) = 0 OR c.scountryid = p_scountryid)
				AND (COALESCE(p_ilocationid, 0) = 0 OR l.ilocationid = p_ilocationid or l1.ilocationid = p_ilocationid or l2.ilocationid = p_ilocationid or l3.ilocationid = p_ilocationid)

			GROUP BY
			P.ipartyid, 
			P.spartytypeid, 
			P.spartysubtypeid, 
			P.sdocumenttypeid,
			P.vdocumentnumber,
			P.vlastname,
			P.vmiddlename,
			P.vmaidenname,
			P.vfirstname,
			P.vorganization,
			P.scountrybirth,
			P.snationalityid,
			P.ipartyaddressid,
			P.vpartycode,
			P.sgenderid,
			P.fheigth,
			P.ddateofbirth,
			P.bdeceased,
			P.seyecolourid,
			P.shaircolourid,
			P.bdisqualified,
			P.vdisability,
			P.vphoto,
			P.vemailaddress,
			P.vcontactinformation,
			P.vphonenumberinformation,
			P.bonlineaccess,
			P.ddisqualifiedstartdate,
			P.ddisqualifiedenddate,
			P.sstatus,
			P.iinsertuserid,
			P.dinsertdate,
			P.vinsertip,
			P.iupdateuserid,
			P.dupdatedate,
			P.vupdateip,
			PL.ipartylocationid,
			PL.ilocationid,
			PL.ipartylocationtypeid,
			PL.vstreet,
			PL.vinformation,
			SP.vdescription,
			SP1.vdescription;
	  RETURN (ref_cursor);  
    
  END;
$$;


--
-- TOC entry 308 (class 1255 OID 83402)
-- Name: usp_party_types_get(character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_party_types_get(p_vpartytypeid character varying, p_ipartyid integer, p_ilocationid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a types of party <br />
 * Detailed explanation of the object.
 * @return refcursor
 * @author  stello
 * @version 1.0 stello 02/08/2016 <br />
 */
DECLARE ref_cursor REFCURSOR := 'ref_cursor';
DECLARE p_language integer := p_slanguageid % 140;
  BEGIN
  IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
  OPEN ref_cursor FOR

  SELECT COALESCE(P.ipartyid, 0) as ipartyid,
  COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '') as vname,
  COALESCE(P.vorganization, '') as vorganization,
  COALESCE(P.vphonenumberinformation, '') as vphonenumber,
  COALESCE(PL.ipartylocationid, 0) as ipartylocationid,
  COALESCE(PL.ilocationid, 0) as ilocationid,
  COALESCE(PL.ipartylocationtypeid, 0) as ipartylocationtypeid,
  COALESCE(PL.vstreet, '') as vstreet,
  COALESCE(PL.vinformation, '') as vinformation,
  COALESCE(P.vlastname, '') as vlastname,
  COALESCE(P.vfirstname, '') as vfirstname,
  COALESCE(P.vmiddlename, '') as vmiddlename,
  COALESCE(C.vname, '') as vcountry,
  COALESCE(P.ddateofbirth, now()) as ddateofbirth,
  cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vdescriptionDocType,
  COALESCE(P.vdocumentnumber, '') as vdocumentnumber,
  COALESCE(P.vemailaddress, '') as vemailaddress,
  COALESCE(P.sdocumenttypeid, 0) as sdocumenttypeid,
  
  COALESCE(P.vmaidenname, '') as vmaidenname,
  COALESCE(P.snationalityid, 0) as snationalityid,
  COALESCE(P.ipartyaddressid, 0) as ipartyaddressid,
  COALESCE(P.sgenderid, 0) as sgenderid,
  COALESCE(P.fheigth, 0.0) as fheigth,
  COALESCE(P.seyecolourid, 0) as seyecolourid,
  COALESCE(P.shaircolourid, 0) as shaircolourid,
  COALESCE(P.sstatus, 0) as sstatus,
  COALESCE(P.scountrybirth,0) as scountrybirth
  FROM party P 
  LEFT JOIN party_location PL ON PL.ipartyid = P.ipartyid
  LEFT JOIN location L ON L.ilocationid = PL.ilocationid 
  LEFT JOIN country C ON C.scountryid = L.scountryid
  LEFT JOIN systemparameter sp ON sp.iparameterid = P.sdocumenttypeid and  sp.igroupid = 3420 
  WHERE 
  --(p_vpartytypeid = '-1' or P.spartytypeid in (select cast(regexp_split_to_table(p_vpartytypeid, ',')as int))) 
  (p_vpartytypeid = '-1' or P.spartysubtypeid in (select cast(regexp_split_to_table(p_vpartytypeid, ',')as int)) or P.spartytypeid in (select cast(regexp_split_to_table(p_vpartytypeid, ',')as int)) ) 
  AND (p_ipartyid = '0' or P.ipartyid = p_ipartyid) 
  AND  (COALESCE(p_ilocationid, 0) = 0 OR PL.ilocationid = p_ilocationid);
  --AND P.sstatus = 1;
  --ORDER BY COALESCE(P.vlastname, '') || ' ' || COALESCE(P.vfirstname, '');

  RETURN (ref_cursor);
  END;
$$;


--
-- TOC entry 309 (class 1255 OID 83403)
-- Name: usp_partycom_maintenance(integer, integer, integer, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_partycom_maintenance(INOUT p_ipartycompanyid integer, p_ipartyid integer, p_icompanyid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a person or company type<br />
 * Detailed explanation of the object.
* @param p_ipartycompanyid 	ID key
* @param p_ipartyid 		ID party relation to the table Party, signatories
* @param p_icompanyid 		ID party relation to the table Party, one record company
* @param p_sstatus 		Registration Status
* @param p_iinsertuserid 	User ID
* @param p_dinsertdate 		Registration date
* @param p_vinsertip 		IP address user
* @param p_iupdateuserid 	Updated user ID
* @param p_dupdatedate 		Updated date
* @param p_vupdateip 		Update user IP
* @param p_voption 		conditional for the CRUD
 * @return array de Party_company.
 * @author  jcondori
 * @version 1.0 jcondori 26/07/2016<BR/> 
 */

IF p_voption = 'INS' THEN

    INSERT
    INTO
    party_company
    (

      ipartyid,
      icompanyid,
      sstatus,
      iinsertuserid,
      dinsertdate,
      vinsertip
    )
    VALUES
    (

      p_ipartyid,
      p_icompanyid,
      p_sstatus,
      p_iinsertuserid,
      Now(),
      p_vinsertip
    );

  p_ipartycompanyid :=  (SELECT currval('party_company_seq'));

ELSIF p_voption = 'UPD' THEN

    UPDATE party_company
    SET
        ipartyid = p_ipartyid,
        icompanyid = p_icompanyid,
        sstatus = p_sstatus,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = Now(),
        vupdateip = p_vupdateip
    WHERE
        --ipartycompanyid = p_ipartycompanyid;
        ipartyid = p_ipartyid;

ELSIF P_VOPTION = 'DEL' THEN

    UPDATE party_company
    SET
        sstatus = p_sstatus,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = Now(),
        vupdateip = p_vupdateip
    WHERE
        ipartycompanyid = p_ipartycompanyid;

END IF;

END;
$$;


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 309
-- Name: FUNCTION usp_partycom_maintenance(INOUT p_ipartycompanyid integer, p_ipartyid integer, p_icompanyid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_partycom_maintenance(INOUT p_ipartycompanyid integer, p_ipartyid integer, p_icompanyid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that saves, edits and deletes persons and company types';


--
-- TOC entry 310 (class 1255 OID 83404)
-- Name: usp_partylocation_maintenance(integer, integer, integer, integer, character varying, character varying, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_partylocation_maintenance(INOUT p_ipartylocationid integer, p_ipartyid integer, p_ilocationid integer, p_ipartylocationtypeid integer, p_vstreet character varying, p_vinformation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a party location<br />
 * Detailed explanation of the object.
 * @param p_ipartylocationid ID key
 * @param p_ipartyid ID party relation to the table Party
 * @param p_ilocationid ID party relation to the table Location, can be estate/provincia, city and district 
 * @param p_ipartylocationtypeid Location type, relation to the table systemparameter igroup = 1000
 * @param p_vstreet Street separated by | Formatted  street1 | street2 .
 * @param p_vinformation Field ZipCode|PO Box|Post Code
 * @param p_sstatus Registration Status
 * @param p_iinsertuserid User ID
 * @param p_vinsertip IP address user
 * @param p_iupdateuserid Updated user ID
 * @param p_vupdateip Update user IP
 * @param p_voption conditional for the CRUD
 * @return array de party location.
 * @author  jcondori
 * @version 1.0 jcondori 26/07/2016<BR/> 
 */


  IF p_voption = 'INS' THEN

	INSERT 
	INTO party_location
	(
             ipartyid,
             ilocationid, 
             ipartylocationtypeid, 
             vstreet, 
             vinformation, 
             sstatus,
             iinsertuserid,
             vinsertip
        )
	VALUES 
	(
	     p_ipartyid,
             p_ilocationid, 
             p_ipartylocationtypeid, 
             p_vstreet, 
             p_vinformation, 
             p_sstatus,
             p_iinsertuserid,
             p_vinsertip
        );

        p_ipartylocationid := (SELECT currval('party_location_seq'));  

  ELSIF p_voption = 'UPD' THEN  

    UPDATE party_location
    SET
        ipartyid = p_ipartyid, 
        ilocationid =  COALESCE(p_ilocationid,ilocationid), 
        ipartylocationtypeid = COALESCE(p_ipartylocationtypeid,ipartylocationtypeid), 
        vstreet = COALESCE(p_vstreet,vstreet), 
        vinformation = COALESCE(p_vinformation,vinformation), 
        sstatus = COALESCE(p_sstatus,sstatus), 
        iupdateuserid = COALESCE(p_iupdateuserid,iupdateuserid), 
        dupdatedate = now(),
        vupdateip = COALESCE(p_vupdateip,vupdateip)
    WHERE
        ipartylocationid = p_ipartylocationid;    

ELSIF P_VOPTION = 'DEL' THEN

    UPDATE party_location
    SET
        status = p_sstatus,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = systimestamp,
        vupdateip = p_vupdateip
    WHERE
        ipartylocationid = p_ipartylocationid;

END IF;

END;
$$;


--
-- TOC entry 2603 (class 0 OID 0)
-- Dependencies: 310
-- Name: FUNCTION usp_partylocation_maintenance(INOUT p_ipartylocationid integer, p_ipartyid integer, p_ilocationid integer, p_ipartylocationtypeid integer, p_vstreet character varying, p_vinformation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_partylocation_maintenance(INOUT p_ipartylocationid integer, p_ipartyid integer, p_ilocationid integer, p_ipartylocationtypeid integer, p_vstreet character varying, p_vinformation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that saves, edits and deletes a location related with a person or company';


--
-- TOC entry 311 (class 1255 OID 83405)
-- Name: usp_payment_detail_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_payment_detail_get(p_ipaymentid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of payment detail<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid     Id Table payment   INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
declare p_language integer := p_slanguageid % 140;
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN p_cursor FOR 
	(    
		select
		pd.ipayment_detailid, 
		pd.ipaymentid, 
		pd.smethodpaymentid, 
		(select cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) from systemparameter sp where sp.iparameterid=pd.smethodpaymentid) as vmethodpayment,
		exc.scurrencyid,  
		(select sp1.vvalue from systemparameter sp1 where sp1.iparameterid=exc.scurrencyid) as vcurrency,
		COALESCE(pd.sbanktypeid, null) as sbanktypeid,
		COALESCE((select cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) from systemparameter sp2 where sp2.iparameterid=pd.sbanktypeid),'') as vbank,
		COALESCE(pd.ichequenumber, null) as ichequenumber, 
		pd.fpricecost, 
		pd.fpricetax, 
		pd.fpricetotal, 
		pd.iexchangerateid,		
		pd.sstatus,
		exc.famount
		from payment_detail pd	
		inner join exchangerate exc on exc.iexchangerateid=pd.iexchangerateid
		where pd.sstatus=1 and  pd.ipaymentid=p_ipaymentid and pd.smethodpaymentid != 6109
		order by ipayment_detailid
	);             
return (p_cursor);
end;
$$;


--
-- TOC entry 312 (class 1255 OID 83406)
-- Name: usp_payment_detail_maintenance(integer, integer, smallint, smallint, smallint, integer, double precision, double precision, double precision, integer, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_payment_detail_maintenance(INOUT p_ipayment_detailid integer, p_ipaymentid integer, p_smethodpaymentid smallint, p_scurrencyid smallint, p_sbanktypeid smallint, p_ichequenumber integer, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_iexchangerateid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a payment detail<br />
 * Detailed explanation of the object.
 * @param p_ipayment_detailid   Id the table payment detail                                        INPUT Y OUTPUT
 * @param p_ipaymentid		Id the table payment                                               INPUT 
 * @param p_smethodpaymentid 	IdParameter Systemparameter Group OPERATION_PAYMENTMETHOD = 6100   INPUT
 * @param p_scurrencyid    	IdParameter Systemparameter Group CONFIGURATION_CURRENCY  = 2300   INPUT
 * @param p_sbanktypeid    	IdParameter Systemparameter					   INPUT
 * @param p_ichequenumber       cheque number Payment                                              INPUT
 * @param p_fpricecost 	        price cost Payment                                                 INPUT
 * @param p_fpricetax 		price tax Payment                                                  INPUT    
 * @param p_fpricetotal 	price total Payment                                                INPUT
 * @param p_iexchangerateid     Id the table exchangerate                                          INPUT
 * @param p_sstatus 		status Payment detail 1=Active; 0=Inactive                         INPUT
 * @param p_iinsertuserid 	User ID                                                            INPUT 
 * @param p_vinsertip 		IP address user		                                           INPUT
 * @param p_iupdateuserid 	Updated user ID                                                    INPUT 
 * @param p_vupdateip 		Update user IP                                                     INPUT
 * @param p_voption 		Option INS= INSERT; UPD= UPDATE; DEL=DELETE                        INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cnt integer := 0;
BEGIN
  IF p_vOption = 'INS' THEN  
        SELECT Count(ipayment_detailid) into p_cnt FROM payment_detail
	WHERE ipayment_detailid = p_ipayment_detailid; 

	IF p_cnt > 0 THEN
		UPDATE public.payment_detail
		SET 
		ipaymentid = p_ipaymentid,
		smethodpaymentid = p_smethodpaymentid,
		scurrencyid = p_scurrencyid,
		sbanktypeid = p_sbanktypeid,
		ichequenumber = p_ichequenumber,
		fpricecost = p_fpricecost,
		fpricetax = p_fpricetax,
		fpricetotal = p_fpricetotal,
		iexchangerateid= p_iexchangerateid,
		sstatus = p_sstatus,
		iupdateuserid = p_iupdateuserid,
		dupdatedate = now(),
		vupdateip = p_vupdateip
		WHERE ipayment_detailid=p_ipayment_detailid;
	ELSE
		INSERT INTO public.payment_detail(
		ipaymentid,
		smethodpaymentid,
		scurrencyid,
		sbanktypeid,
		ichequenumber,
		fpricecost,
		fpricetax,
		fpricetotal,
		iexchangerateid,
		sstatus,
		iinsertuserid,
		dinsertdate,
		vinsertip)
		VALUES (
		p_ipaymentid,
		p_smethodpaymentid,
		p_scurrencyid,
		p_sbanktypeid,
		p_ichequenumber,
		p_fpricecost,
		p_fpricetax,
		p_fpricetotal,
		p_iexchangerateid,
		p_sstatus,
		p_iinsertuserid,
		now(),
		p_vinsertip);
	  p_ipayment_detailid := (select currval('payment_detail_seq'));	
	END IF;
  
  ELSIF p_vOption = 'UPD' THEN
        UPDATE public.payment_detail
	SET 
	ipaymentid = p_ipaymentid,
        smethodpaymentid = p_smethodpaymentid,
        scurrencyid = p_scurrencyid,
        sbanktypeid = p_sbanktypeid,
        ichequenumber = p_ichequenumber,
        fpricecost = p_fpricecost,
        fpricetax = p_fpricetax,
        fpricetotal = p_fpricetotal,
        ichequenumber = p_ichequenumber,
        sstatus = p_sstatus,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = now(),
        vupdateip = p_vupdateip
	WHERE ipayment_detailid=p_ipayment_detailid;
	
  ELSIF p_vOption = 'DEL' THEN  
        UPDATE public.payment_detail
	SET 	
        sstatus = 0,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = now(),
        vupdateip = p_vupdateip
	WHERE ipayment_detailid=p_ipayment_detailid;
  END IF;    
END;
$$;


--
-- TOC entry 2604 (class 0 OID 0)
-- Dependencies: 312
-- Name: FUNCTION usp_payment_detail_maintenance(INOUT p_ipayment_detailid integer, p_ipaymentid integer, p_smethodpaymentid smallint, p_scurrencyid smallint, p_sbanktypeid smallint, p_ichequenumber integer, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_iexchangerateid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_payment_detail_maintenance(INOUT p_ipayment_detailid integer, p_ipaymentid integer, p_smethodpaymentid smallint, p_scurrencyid smallint, p_sbanktypeid smallint, p_ichequenumber integer, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_iexchangerateid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure  save, edit and delete a Payment Detail';


--
-- TOC entry 313 (class 1255 OID 83407)
-- Name: usp_payment_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_payment_get(p_ipaymentid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of payment<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid     Id the table payment     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(    
		SELECT pa.ipaymentid, 
		COALESCE(pa.vreceiptnumber, '') as vreceiptnumber, 
		pa.dpaymentdate, 
		pa.fpricecost, 
		pa.fpricetax, 
		pa.fpricetotal, 
		pa.sstatus
		FROM payment pa
		where ipaymentid=p_ipaymentid
	);             
return (p_cursor);
end;
$$;


--
-- TOC entry 2605 (class 0 OID 0)
-- Dependencies: 313
-- Name: FUNCTION usp_payment_get(p_ipaymentid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_payment_get(p_ipaymentid integer) IS 'Stored procedure returns a list of payment according to parameters entered';


--
-- TOC entry 314 (class 1255 OID 83408)
-- Name: usp_payment_maintenance(integer, character varying, timestamp without time zone, double precision, double precision, double precision, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_payment_maintenance(INOUT p_ipaymentid integer, p_vreceiptnumber character varying, p_dpaymentdate timestamp without time zone, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a payment<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid          Id the table payment                                       INPUT Y OUTPUT
 * @param p_vreceiptnumber      receipt number payment                                     INPUT
 * @param p_dpaymentdate        date payment                                               INPUT
 * @param p_fpricecost 	        price cost Payment                                         INPUT
 * @param p_fpricetax 		price tax Payment                                          INPUT    
 * @param p_fpricetotal 	price total Payment                                        INPUT
 * @param p_sstatus 		status Payment detail 1=Active; 0=Inactive                 INPUT
 * @param p_iinsertuserid 	User ID                                                    INPUT 
 * @param p_vinsertip 		IP address user		                                   INPUT
 * @param p_iupdateuserid 	Updated user ID                                            INPUT 
 * @param p_vupdateip 		Update user IP                                             INPUT
 * @param p_voption 		Option INS= INSERT; UPD= UPDATE; DEL=DELETE                INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
BEGIN
  IF p_vOption = 'INS' THEN  
    INSERT INTO payment(
        vreceiptnumber,
        fpricecost,
        fpricetax,
        fpricetotal,
        sstatus,
        iinsertuserid,
        dinsertdate,
        vinsertip
    )VALUES(
        p_vreceiptnumber,
        p_fpricecost,
        p_fpricetax,
        p_fpricetotal,
        p_sstatus,
        p_iinsertuserid,
        now(),
        p_vinsertip
    ); 

    p_ipaymentid := (select currval('payment_seq'));
  
  ELSIF p_vOption = 'UPD' THEN
    UPDATE payment
    SET 
        vreceiptnumber = p_vreceiptnumber,
        dpaymentdate = p_dpaymentdate,
        fpricecost = p_fpricecost,
        fpricetax = p_fpricetax,
        fpricetotal = p_fpricetotal,       
        sstatus = p_sstatus,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = now(),
        vupdateip = p_vupdateip
    WHERE ipaymentid = p_ipaymentid; 

  ELSIF p_vOption = 'DEL' THEN  
    UPDATE payment
    SET              
        sstatus = 0,
        iupdateuserid = p_iupdateuserid,
        dupdatedate = now(),
        vupdateip = p_vupdateip
    WHERE ipaymentid = p_ipaymentid; 
  END IF;    
END;
$$;


--
-- TOC entry 2606 (class 0 OID 0)
-- Dependencies: 314
-- Name: FUNCTION usp_payment_maintenance(INOUT p_ipaymentid integer, p_vreceiptnumber character varying, p_dpaymentdate timestamp without time zone, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_payment_maintenance(INOUT p_ipaymentid integer, p_vreceiptnumber character varying, p_dpaymentdate timestamp without time zone, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure  save, edit and delete a Payment';


--
-- TOC entry 315 (class 1255 OID 83409)
-- Name: usp_pricing_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_pricing_get(p_spricingid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
DECLARE p_language integer := p_slanguageid % 140;
begin
/**
 * Description: Stored procedure returns a list of payment<br />
 * Detailed explanation of the object.
 * @param p_spricingid     Id the table Pricing     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN p_cursor FOR 
	(
	SELECT 
          PRI.IPRICINGID,
          PRI.ILOCATIONID,
          LO.VADDRESS VLOCATION,
          PRI.SPRICINGTYPEID,
          cast(trim(split_part(SYPAR.VDESCRIPTION,'|', p_language)) as character varying) VPRICINGTYPE,
          PRI.VDESCRIPTION,
          PRI.SCURRENCYID,
          cast(trim(split_part(SYPAR2.VDESCRIPTION,'|', p_language)) as character varying) VCURRENCY,
          PRI.FPRICECOST,
          PRI.FPRICETAX,
          PRI.FPRICETOTAL,
          PRI.SDURATION,
          PRI.DSTARTDATE,
          PRI.DFINISHDATE,
          PRI.BVISIBLE,
          PRI.SSTATUS
        FROM PRICING PRI
        INNER JOIN LOCATION LO ON LO.ILOCATIONID= PRI.ILOCATIONID
        INNER JOIN SYSTEMPARAMETER SYPAR ON SYPAR.IPARAMETERID=PRI.SPRICINGTYPEID
        INNER JOIN SYSTEMPARAMETER SYPAR2 ON SYPAR2.IPARAMETERID=PRI.SCURRENCYID       
        WHERE PRI.SSTATUS = 1 AND (PRI.IPRICINGID = p_spricingid OR  p_spricingid = 0));      
return (p_cursor);
end;
$$;


--
-- TOC entry 2607 (class 0 OID 0)
-- Dependencies: 315
-- Name: FUNCTION usp_pricing_get(p_spricingid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_pricing_get(p_spricingid integer, p_slanguageid integer) IS 'Stored procedure returns a list of pricing according to parameters entered';


--
-- TOC entry 316 (class 1255 OID 83410)
-- Name: usp_pricing_maintenance(character varying, integer, integer, smallint, character varying, smallint, double precision, double precision, double precision, smallint, timestamp without time zone, timestamp without time zone, boolean, smallint, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sduration smallint, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
/**
 * Description: Stored procedure  save, edit and delete a pricing<br />
 * Detailed explanation of the object.
 * @param p_ipricingid          Pricing primary key		INPUT Y OUTPUT
 * @param p_ilocationid      	Location primary key		INPUT
 * @param p_spricingtypeid      Pricing type primary key        INPUT
 * @param p_vdescription 	Pricing description		INPUT
 * @param p_scurrencyid 	Currency primary key		INPUT    
 * @param p_fpricecost 		Price base cost 		INPUT
 * @param p_fpricetax 		Price tax cost			INPUT
 * @param p_fpricetotal 	Price total cost		INPUT
 * @param p_sduration 		Period of time that a price is available	INPUT
 * @param p_dstartdate 		Start date a price is valid     INPUT  
 * @param p_dfinishdate 	Finish date a price is valid    INPUT  
 * @param p_bvisible 		Visible flag			INPUT  
 * @param p_sstatus 		status pricing 1=Active; 0=Inactive		INPUT
 * @param p_iinsertuserid 	User ID                         INPUT 
 * @param p_vinsertip 		IP address user		        INPUT
 * @param p_iupdateuserid 	Updated user ID                	INPUT 
 * @param p_vupdateip 		Update user IP                 	INPUT
 * @param p_voption 		Option INS= INSERT; UPD= UPDATE; DEL=DELETE	INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */

  IF p_vOption = 'INS' THEN  
    INSERT
    INTO
      PRICING
      (
          ILOCATIONID,
          SPRICINGTYPEID,
          VDESCRIPTION,
          SCURRENCYID,
          FPRICECOST,
          FPRICETAX,
          FPRICETOTAL,
          SDURATION,
          DSTARTDATE,
          DFINISHDATE,
          BVISIBLE,
          SSTATUS,
          IINSERTUSERID,
          DINSERTDATE,
          VINSERTIP
      )
      VALUES
      (
          p_ILOCATIONID,
          p_SPRICINGTYPEID,
          p_VDESCRIPTION,
          p_SCURRENCYID,
          p_FPRICECOST,
          p_FPRICETAX,
          p_FPRICETOTAL,
          p_SDURATION,
          p_DSTARTDATE,
          p_DFINISHDATE,
          p_BVISIBLE,
          p_SSTATUS,
          p_IINSERTUSERID,
          now(),
          p_VINSERTIP
      );
    p_IPRICINGID := (select currval('pricing_seq'));
  
  ELSIF p_vOption = 'UPD' THEN
    UPDATE PRICING
      SET 
          ILOCATIONID = p_ILOCATIONID,
          SPRICINGTYPEID =P_SPRICINGTYPEID,
          VDESCRIPTION = p_VDESCRIPTION,
          SCURRENCYID = p_SCURRENCYID,
          FPRICECOST = p_FPRICECOST,
          FPRICETAX = p_FPRICETAX,
          FPRICETOTAL = p_FPRICETOTAL,
          SDURATION = p_SDURATION,
          DSTARTDATE = p_DSTARTDATE,
          DFINISHDATE = p_DFINISHDATE,
          BVISIBLE = p_BVISIBLE,
          SSTATUS = p_SSTATUS,
          IUPDATEUSERID = p_IUPDATEUSERID,
          DUPDATEDATE = now(),
          VUPDATEIP = p_VUPDATEIP
      WHERE 
          IPRICINGID = p_IPRICINGID;
  ELSIF p_vOption = 'DEL' THEN  
     UPDATE PRICING
      SET SSTATUS = 0,
          IUPDATEUSERID = p_IUPDATEUSERID,
          DUPDATEDATE = systimestamp,
          VUPDATEIP = p_VUPDATEIP
      WHERE 
          IPRICINGID = p_IPRICINGID;   
  END IF;    
END;
$$;


--
-- TOC entry 2608 (class 0 OID 0)
-- Dependencies: 316
-- Name: FUNCTION usp_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sduration smallint, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_sduration smallint, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a pricing';


--
-- TOC entry 317 (class 1255 OID 83411)
-- Name: usp_printer_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_printer_get(p_iprinterid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param iprinterid Primary auto-increment key
 * @return array printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 16/08/2016<BR/> Se agrego tabla location y su columna vdescription
 */
      OPEN ref_cursor FOR SELECT p.iprinterid , p.ilocationid, l.vdescription lvdescription, p.vdescription, p.vipdescription, p.dinsertdate  
			FROM printer p inner join location l on p.ilocationid=l.ilocationid
			WHERE (p.iprinterid = p_iPrinterId or p_iPrinterId = 0) AND p.sstatus = 1;
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2609 (class 0 OID 0)
-- Dependencies: 317
-- Name: FUNCTION usp_printer_get(p_iprinterid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_printer_get(p_iprinterid integer) IS 'Stored procedure returns a list of printers according to parameters entered';


--
-- TOC entry 319 (class 1255 OID 83412)
-- Name: usp_printer_maintenance(integer, integer, character varying, character varying, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_printer_maintenance(INOUT p_iprinterid integer, p_ilocationid integer, p_vdescription character varying, p_vipdescription character varying, p_sstatus integer, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a printer<br />
 * Detailed explanation of the object.
* @param iprinterid 	Primary auto-increment key
* @param ilocationid 	Location ID
* @param vdescription 	Printer description
* @param sstatus 	Status
* @param iinsertuserid 	User ID
* @param vinsertip 	IP address user
* @param iupdateuserid 	Updated user ID
* @param vupdateip 	Update user IP
* @param vipdescription Ip Description
* @param p_voption 	Option to perform.  'INS' - 'UPD' - 'DEL'
 * @return ID printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 26/08/2016<BR/> 
 */


    IF p_vOption = 'INS' THEN
    IF not exists(select iprinterid from printer where (ilocationid=p_ilocationid or upper(vdescription)=upper(p_vDescription) or vipdescription= p_vipdescription) and sstatus != -1 ) then
		INSERT INTO public.printer(
		    ilocationid, 
		    vdescription, 
		    sstatus, 
		    iinsertuserid, 
		    dinsertdate,
		    vinsertip, 
		    vipdescription
		     )
	    VALUES (
		    p_ilocationid, 
		    p_vDescription, 
		    p_sStatus, 
		    p_iInsertUserId, 
		    now(), 
		    p_vInsertTip, 
		    p_vIpDescription
		    );
		p_iPrinterId := (select currval('printer_seq'));
    else
	p_iPrinterId = -1;
    end if;
    
         ELSIF p_vOption = 'UPD' THEN
	 IF not exists(select iprinterid from printer where iprinterid != p_iprinterid and sstatus != -1  and 
	 (ilocationid=p_ilocationid or vipdescription= p_vipdescription or  upper(vdescription)=upper(p_vDescription) ))then --or  upper(vdescription)=upper(vdescription))) then -- )) then
		 UPDATE public.printer
				   SET ilocationid= p_iLocationId, 
				   vdescription= p_vDescription, 
				   vipdescription= p_vIpDescription, 
				    iupdateuserid= p_iUpdateUserId, 
				    dupdatedate= now(), 
				    vupdateip= p_vUpdateIp 
				 WHERE iprinterid = p_iprinterid;
	else
		p_iprinterid=-1;
	end if;
	ELSIF p_vOption = 'DEL'
	    THEN 
	    IF not exists(select iprinteruserid from printer_user where iprinterid = p_iprinterid and sstatus != -1) then
			UPDATE printer SET sstatus = -1,
			      iupdateuserid = p_iUpdateUserId,
			       dupdatedate = now()
			WHERE iprinterid = p_iPrinterId;
	    else
		p_iPrinterId=-1;
	    end if;
	    

END IF;
END;
$$;


--
-- TOC entry 320 (class 1255 OID 83413)
-- Name: usp_printeruser_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_printeruser_get(p_iprinterid integer, p_iprinteruserid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN

/**
 * Description: Stored procedure that returns a list of printer user<br />
 * Detailed explanation of the object.
 * @param iprinterid Primary auto-increment key
 * @param p_iprinteruserid user ID
 * @return array printer_user.
 * @author  rpaucar
 * @version 1.0 rpaucar 26/07/2016<BR/> 
 */


    
      OPEN ref_cursor FOR SELECT pu.iprinteruserid,pu.iprinterid,pu.isystemuserid, p.vdescription vfirstname,p.vdescription
				FROM printer_user pu
				INNER JOIN printer p on p.iprinterid = pu.iprinterid
				--LEFT JOIN systemuser sy on pu.isystemuserid = sy.isystemuserid
				WHERE (pu.iprinterid = p_iprinterid or p_iprinterid = 0) AND 
				      (pu.iprinteruserid = p_iprinteruserid or p_iprinteruserid = 0) AND 
				       pu.sstatus = 1;
				       
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 321 (class 1255 OID 83414)
-- Name: usp_printeruser_maintenance(integer, integer, integer, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_printeruser_maintenance(INOUT p_iprinteruserid integer, p_isystemuserid integer, p_iprinterid integer, p_sstatus integer, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN


/**
 * Description: Stored procedure that save, edit and delete a printer user<br />
 * Detailed explanation of the object. 
* @param iprinteruserid Primary key to identify the country
* @param isystemuserid System user id
* @param iprinterid Printer Id
* @param sstatus Status
* @param iinsertuserid User ID
* @param vinsertip IP address user
* @param iupdateuserid Updated user ID
* @param vupdateip Update user IP
 * @return array printer_user.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 26/07/2016<BR/> Conficiones para la insercion y edicion 
 */


    IF p_vOption = 'INS' THEN

	    IF not exists(select iprinteruserid from printer_user where isystemuserid=p_iSystemUserId and iprinterid= p_iPrinterId and sstatus != -1) then
			INSERT INTO printer_user(
			    isystemuserid, 
			    iprinterid, 
			    sstatus, 
			    iinsertuserid, 
			    dinsertdate,
			    vinsertip
			     )
		    VALUES (
			    p_iSystemUserId,
			    p_iPrinterId,
			    1,
			    p_iInsertUserId,
			    now(),
			    p_vInsertTip
			    );
			p_iPrinterUserId := (select currval('printer_user_seq'));		    
	     else
			p_iPrinterUserId := -1;
	     end if;

         ELSIF p_vOption = 'UPD' THEN

		IF not exists(select iprinteruserid from printer_user where isystemuserid=p_iSystemUserId and iprinterid= p_iPrinterId and sstatus != -1) then
			UPDATE printer_user
				   SET isystemuserid = p_iSystemUserId, 
				       iprinterid = p_iPrinterId,
				       iupdateuserid = p_iUpdateUserId,
				       dupdatedate = now(),
				       vupdateip = p_vUpdateIp
			WHERE iPrinterUserId = p_iPrinterUserId;
		else
			p_iPrinterUserId:= -1;
		end if;
	ELSIF p_vOption = 'DEL' THEN

	UPDATE printer_user SET sstatus = -1,
                       iupdateuserid = p_iUpdateUserId,
                       dupdatedate = now()
		WHERE iPrinterUserId = p_iPrinterUserId;

END IF;
END;
$$;


--
-- TOC entry 2610 (class 0 OID 0)
-- Dependencies: 321
-- Name: FUNCTION usp_printeruser_maintenance(INOUT p_iprinteruserid integer, p_isystemuserid integer, p_iprinterid integer, p_sstatus integer, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_printeruser_maintenance(INOUT p_iprinteruserid integer, p_isystemuserid integer, p_iprinterid integer, p_sstatus integer, p_iinsertuserid integer, p_vinserttip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a user printer';


--
-- TOC entry 322 (class 1255 OID 83415)
-- Name: usp_procedure_demo(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_procedure_demo(id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
     declare result refcursor := 'result';
    BEGIN
	OPEN result for (select * from vehicle where ivehicleid = id);
      RETURN (result);
    END;
    $$;


--
-- TOC entry 323 (class 1255 OID 83416)
-- Name: usp_product_composition_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_composition_get(p_iproductcompositionid integer, p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product composition<br />
 * Detailed explanation of the object.
 * @param p_iproductcompositionid       Id the table product_composition     
 * @param p_iproductid			id the table product
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT 
	pc.iproductcompositionid, 
	pc.iproductid, 
	pc.icomponentid, 
	pc.fquantity, 
	pc.bvisible, 
	pc.boptional,
        pc.sorder,
        pr.vdescription
        FROM product_composition pc
        inner join product pr on pc.icomponentid = pr.iproductid
        where pc.sstatus=1 and
        (p_iproductcompositionid=0 or pc.iproductcompositionid=p_iproductcompositionid) and
        (p_iproductid=0 or pc.iproductid=p_iproductid) 
        order by pc.sorder);
return (p_cursor);
end;
$$;


--
-- TOC entry 2611 (class 0 OID 0)
-- Dependencies: 323
-- Name: FUNCTION usp_product_composition_get(p_iproductcompositionid integer, p_iproductid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_composition_get(p_iproductcompositionid integer, p_iproductid integer) IS 'Stored procedure returns a list of product composition according to parameters entered';


--
-- TOC entry 324 (class 1255 OID 83417)
-- Name: usp_product_composition_maintenance(character varying, integer, integer, integer, double precision, boolean, smallint, boolean, smallint, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_composition_maintenance(p_voption character varying, INOUT p_iproductcompositionid integer, p_iproductid integer, p_icomponentid integer, p_fquantity double precision, p_bvisible boolean, p_sorder smallint, p_boptional boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a project <br />
 * Explicación detallada del objeto.
 * @param p_voption          Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_iproductcompositionid       Primary auto-increment key
 * @param p_iproductid            Stores the name of product
 * @param p_icomponentid       Stores the reference to the table product
 * @param p_fquantity     quantity
 * @param p_bvisible          visible
 * @param p_sorder          orde
 * @param p_boptional          Optional
 * @param p_sstatus            status
 * @param p_iinsertuserid    User ID
 * @param p_vinsertip        IP address user
 * @param p_iupdateuserid    Updated user ID
 * @param p_vupdateip    IP address user
 * @return Number
 * @author  rpaucar
 * @version 1.0 rpaucar 02/08/2016 <br />
 */
BEGIN
  
  IF p_vOption = 'INS' THEN       
      INSERT INTO product_composition (
        iproductid,
        icomponentid,
        fquantity,
        bvisible,
        sorder,
        boptional,
        sstatus,
        iinsertuserid,
        DINSERTDATE,
        vinsertip
      ) VALUES (
        p_iproductid,
        p_icomponentid,
        p_fquantity,
        p_bvisible,
        p_sorder,
        p_boptional,
        1,        
        p_iInsertUserId,
        now(),
        p_vInsertIP
      );
      p_iproductcompositionid := (select currval('product_composition_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE product_composition
      SET iproductid = p_iproductid,
      icomponentid = p_icomponentid,
      fquantity = p_fquantity,
      bvisible = p_bvisible,
      sorder = p_sorder,
      boptional = p_boptional,
      sstatus = 1,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductcompositionid = p_iproductcompositionid;
  ELSIF p_vOption = 'DEL' THEN  
      --DELETE FROM systemproject WHERE isystemprojectid = p_isystemprojectid; 
      UPDATE product_composition
      SET sstatus = 0,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductcompositionid = p_iproductcompositionid;
  END IF;
END;
$$;


--
-- TOC entry 2612 (class 0 OID 0)
-- Dependencies: 324
-- Name: FUNCTION usp_product_composition_maintenance(p_voption character varying, INOUT p_iproductcompositionid integer, p_iproductid integer, p_icomponentid integer, p_fquantity double precision, p_bvisible boolean, p_sorder smallint, p_boptional boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_composition_maintenance(p_voption character varying, INOUT p_iproductcompositionid integer, p_iproductid integer, p_icomponentid integer, p_fquantity double precision, p_bvisible boolean, p_sorder smallint, p_boptional boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a project composition';


--
-- TOC entry 318 (class 1255 OID 83418)
-- Name: usp_product_document_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_document_get(p_iproductdocumentid integer, p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product composition<br />
 * Detailed explanation of the object.
 * @param p_iproductcompositionid       Id the table product_document     
 * @param p_iproductid			Id the table product
 * @return cursor
 * @author  rpaucar
 * @version 1.0 rpaucar 02/09/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT 
	pc.iproductdocumentid,
	pc.iproductid, 
	pc.idocumentid, 
	pc.sdocumenttypeid, 
	pc.bmandatory,
	DOC.vname
        FROM product_document pc
        INNER JOIN DOCUMENT DOC on DOC.idocumentid=pc.idocumentid
        where pc.sstatus=1 and
        (p_iproductdocumentid=0 or pc.iproductdocumentid=p_iproductdocumentid) and
        (p_iproductid=0 or pc.iproductid=p_iproductid)
        );
return (p_cursor);
end;
$$;


--
-- TOC entry 2613 (class 0 OID 0)
-- Dependencies: 318
-- Name: FUNCTION usp_product_document_get(p_iproductdocumentid integer, p_iproductid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_document_get(p_iproductdocumentid integer, p_iproductid integer) IS 'Stored procedure returns a list of product document according to parameters entered';


--
-- TOC entry 325 (class 1255 OID 83419)
-- Name: usp_product_document_get(integer, integer, smallint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_document_get(p_iproductid integer, p_ipartyid integer, p_sdocumenttypeid smallint, p_irequestid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product document<br />
 * Detailed explanation of the object.
 * @param p_iproductid       Id the table product                                INPUT
 * @param p_ipartyid         Id the table Party                                  INPUT
 * @param p_sdocumenttypeid  document type systemparameter "igroupid =  2400"    INPUT
 * @return cursor
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
declare p_cnt integer := 0;
begin
	

	select Count(rdd.irequestdocument) into p_cnt from request r inner join request_detail rd 
			on r.irequestid = rd.irequestid
			inner join request_document rdd on rdd.irequestdetailid = rd.irequestdetailid
			where r.irequestid = p_irequestid; 

        IF p_cnt = 0 THEN
		p_irequestid := 0;	
	END IF;
	
    	create temp table tbltmp_requestdocument (irequestid integer, irequestdetailid integer, irequestdocument integer, 
	ivehicleid integer, vfilename character varying(50), vfilepath character varying(200),idocumentid integer,
	iproductid integer) on commit drop ;

	INSERT INTO tbltmp_requestdocument
	select r.irequestid,rd.irequestdetailid,rdd.irequestdocument,v.ivehicleid,rdd.vfilename,rdd.vfilepath,rdd.idocumentid,r.iproductid
	from request r 
	inner join request_detail rd on r.irequestid  = rd.irequestid 
	left join vehicle v on v.ivehicleid = rd.ivehicleid  -- Cambio de Inner por left
	inner join request_document rdd on rdd.irequestdetailid = rd.irequestdetailid
	where r.ipartyid = p_ipartyid and 
	 r.dinsertdate = (select max(rd1.dinsertdate) from request rd1
			inner join request_detail rd on rd1.irequestid  = rd.irequestid 
			left join vehicle v on v.ivehicleid = rd.ivehicleid -- Cambio de Inner por left
			inner join request_document rdd on rdd.irequestdetailid = rd.irequestdetailid
			where rd1.ipartyid = r.ipartyid and (p_irequestid = 0 or rd.irequestid = p_irequestid));


	OPEN p_cursor FOR 
	(
	SELECT DISTINCT
	COALESCE(pd.iproductdocumentid,0) as iproductdocumentid, 
	COALESCE(pd.iproductid,0) as iproductid, 
	COALESCE(pd.idocumentid,0) as idocumentid,
	COALESCE(d.vname, '') as vname,
	--COALESCE(pd.sstatus, 0) as sstatus,
	--COALESCE(tr.irequestdocument, 0) as irequestdocument,
	COALESCE(tr.ivehicleid, 0) as ivehicleid,
	COALESCE(tr.vfilename,'') as vfilename,
	COALESCE(tr.vfilepath, '') as vfilepath,
	COALESCE(tr.iproductid, 0) as iproductid,
	COALESCE(d.vdocumentcode, '') as vdocumentcode,
	COALESCE(pd.bmandatory, false) as bmandatory,
	COALESCE(pd.bfirmrequired, false) as bfirmrequired
        FROM product_document pd
        LEFT JOIN document d on pd.idocumentid = d.idocumentid
        LEFT JOIN tbltmp_requestdocument tr on tr.idocumentid = d.idocumentid
        LEFT JOIN product_composition pc on pc.icomponentid = pd.iproductid and pc.boptional=false
        where pd.sstatus=1 and sdocumenttypeid=p_sdocumenttypeid and (pc.iproductid=p_iproductid or pd.iproductid=p_iproductid));                
return (p_cursor);
end;
$$;


--
-- TOC entry 326 (class 1255 OID 83420)
-- Name: usp_product_document_maintenance(character varying, integer, integer, integer, smallint, boolean, smallint, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_document_maintenance(p_voption character varying, INOUT p_iproductdocumentid integer, p_iproductid integer, p_idocumentid integer, p_sdocumenttypeid smallint, p_bmandatory boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a project <br />
 * Explicación detallada del objeto.
 * @param p_voption          Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_iproductdocumentid       Primary auto-increment key
 * @param p_iproductid            Stores the name of product
 * @param p_idocumentid       Stores the reference to the table document
 * @param p_sdocumenttypeid     type document
 * @param p_bmandatory          mandatory
 * @param p_sstatus		status
 * @param p_iinsertuserid    User ID
 * @param p_vinsertip        IP address user
 * @param p_iupdateuserid    Updated user ID
 * @param p_vupdateip    IP address user
 * @return Number
 * @author  rpaucar
 * @version 1.0 rpaucar 02/08/2016 <br />
 */
BEGIN
  
  IF p_vOption = 'INS' THEN       
      INSERT INTO product_document (
        iproductid,
        idocumentid,
        sdocumenttypeid,
        bmandatory,
        sstatus,
        iinsertuserid,
        DINSERTDATE,
        vinsertip
      ) VALUES (
        p_iproductid,
        p_idocumentid,
        p_sdocumenttypeid,
        p_bmandatory,
        1,       
        p_iinsertuserid,
        now(),
        p_vinsertip
      );
      p_iproductdocumentid := (select currval('product_document_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE product_document
      SET iproductid = p_iproductid,
      idocumentid = p_idocumentid,
      sdocumenttypeid = p_sdocumenttypeid,
      bmandatory = p_bmandatory,
      sstatus = 1,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductdocumentid = p_iproductdocumentid;
  ELSIF p_vOption = 'DEL' THEN  
      --DELETE FROM systemproject WHERE isystemprojectid = p_isystemprojectid; 
      UPDATE product_document
      SET sstatus = 0,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductdocumentid = p_iproductdocumentid;
  END IF;
END;
$$;


--
-- TOC entry 2614 (class 0 OID 0)
-- Dependencies: 326
-- Name: FUNCTION usp_product_document_maintenance(p_voption character varying, INOUT p_iproductdocumentid integer, p_iproductid integer, p_idocumentid integer, p_sdocumenttypeid smallint, p_bmandatory boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_document_maintenance(p_voption character varying, INOUT p_iproductdocumentid integer, p_iproductid integer, p_idocumentid integer, p_sdocumenttypeid smallint, p_bmandatory boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a project document';


--
-- TOC entry 327 (class 1255 OID 83421)
-- Name: usp_product_get(integer, smallint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_get(p_iproductid integer, p_sproducttypeid smallint, p_vdescription character varying, p_vproductcode character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product<br />
 * Detailed explanation of the object.
 * @param p_iproductid       Id the table product                                INPUT
 * @param p_sproducttypeid   Product Type, Id systemparameter igropud = 1300     INPUT
 * @param p_vdescription     description product                                 INPUT
 * @param p_vproductcode     product code product                                INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	select 
		p.iproductid,
		0 as pack,
		p.sproducttypeid, 
		p.sproductuseid, 
		p.sproductcategoryid, 
		p.sproductscopeid, 
		('('|| p.vproductcode ||') '||p.vdescription) as vdescription, 
		p.vproductcode, 
		p.dstartdate, 
		p.denddate, 
		p.sstatus,
		p.bvisible,
		p.sorder,
		(select count(iproductcompositionid) from product_composition pc where pc.iproductid=p.iproductid) as cantidad,
		p.bconformity,
		p.bfloating,
		false as boptional,
		p.bauthorization		
	from  product p
	where p.sstatus=1 and --p.bvisible = true and 
	(p_iproductid=0 or p.iproductid=p_iproductid) and
	(p_sproducttypeid=0 or p.sproducttypeid=p_sproducttypeid)and
	(p_vdescription='' or p.vdescription like '%'||COALESCE(p_vdescription,'')||'%')and
	(p_vproductcode='' or p.vproductcode like '%'||COALESCE(p_vproductcode,'')||'%')
	union
	select
		pp.iproductid,
		pc.iproductid as pack,
		pp.sproducttypeid, 
		pp.sproductuseid, 
		pp.sproductcategoryid, 
		pp.sproductscopeid, 
		('('|| pp.vproductcode ||') '||pp.vdescription) as vdescription, 
		pp.vproductcode, 
		pp.dstartdate, 
		pp.denddate, 
		pp.sstatus,
		pp.bvisible,
		pc.sorder,
		0 as cantidad,
		pp.bconformity,
		pp.bfloating,
		pc.boptional as boptional,
		pp.bauthorization		
	from  product pp
	left join  product_composition pc on pc.icomponentid=pp.iproductid
	where  pc.sstatus=1 and pc.bvisible=true and pc.iproductid=p_iproductid and
        pp.vproductcode not in('PA01','PA02')
	order by sorder,vdescription);	
return (p_cursor);
end;
$$;


--
-- TOC entry 328 (class 1255 OID 83422)
-- Name: usp_product_maintenance(integer, smallint, smallint, smallint, smallint, character varying, character varying, timestamp without time zone, timestamp without time zone, boolean, character varying, smallint, boolean, boolean, boolean, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_maintenance(INOUT p_iproductid integer, p_sproducttypeid smallint, p_sproductuseid smallint, p_sproductcategoryid smallint, p_sproductscopeid smallint, p_vdescription character varying, p_vproductcode character varying, p_dstartdate timestamp without time zone, p_denddate timestamp without time zone, p_bauthorization boolean, p_vcharacteristics character varying, p_sorder smallint, p_bvisible boolean, p_bconformity boolean, p_bfloating boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a Product<br />
 * Detailed explanation of the object.
 * @param p_iproductid              ID key                                                                                   INPUT Y OUTPUT
 * @param p_sproducttypeid          Product Type, relation to systemparameter igropud = 1300                                 INPUT
 * @param p_sproductuseid           Product use, relation to systemparameter igropud = 1400                                  INPUT
 * @param p_sproductcategoryid      Product category, relation to systemparameter igropud = 1500                             INPUT
 * @param p_sproductscopeid         Relation to systemparameter igropud = 1600, cayman islands product only for foreigners   INPUT
 * @param p_vdescription            Description                                                                              INPUT
 * @param p_vproductcode            Code product                                                                             INPUT
 * @param p_dstartdate              Product inception date                                                                   INPUT
 * @param p_denddate                Effective end product                                                                    INPUT
 * @param p_bauthorization          If required authorization                                                                INPUT
 * @param p_vcharacteristics        Detailed description of the product and / or that this compound items                    INPUT
 * @param p_sorder                  Order                                                                                    INPUT
 * @param p_bvisible                Is visible in the app                                                                    INPUT
 * @param p_bconformity             Is requerit conformity in the finish app                                                 INPUT
 * @param p_bfloating               If it can be floating                                                                    INPUT
 * @param p_sstatus                 Registration Status                                                                      INPUT
 * @param p_iinsertuserid           User ID                                                                                  INPUT
 * @param p_vinsertip               IP address user                                                                          INPUT
 * @param p_iupdateuserid           Updated user ID                                                                          INPUT
 * @param p_vupdateip               Update user IP                                                                           INPUT
 * @param p_voption 		    Option INS= INSERT; UPD= UPDATE; DEL=DELETE                                              INPUT
 * @return Number
 * @author  rpaucar
 * @version 1.0 rpaucar 01/09/2016<BR/> 
 */

 declare validarDEL integer := 0;
BEGIN
  IF p_voption = 'INS' THEN  
	  INSERT INTO public.product(             
            sproducttypeid, 
            sproductuseid, 
            sproductcategoryid, 
            sproductscopeid, 
            vdescription, 
            vproductcode, 
            dstartdate,
            denddate,  
            bauthorization,
            vcharacteristics,
            sorder,
            bvisible,
            bconformity,
            bfloating,
            sstatus, 
            iinsertuserid,
            dinsertdate,
            vinsertip)
    VALUES (p_sproducttypeid, 
            p_sproductuseid, 
            p_sproductcategoryid, 
            p_sproductscopeid, 
            p_vdescription, 
            p_vproductcode, 
            p_dstartdate, 
            p_denddate, 
            p_bauthorization,
            p_vcharacteristics,
            p_sorder,
            p_bvisible,
            p_bconformity,
            p_bfloating,
            1, 
            p_iinsertuserid,
            now(),
            p_vinsertip);	  
    p_iproductid := (select currval('product_seq'));

	if not exists(select ipricingid from product_pricing where iproductid = p_iproductid) then
	
		INSERT INTO product_pricing (
		ilocationid ,
		spricingtypeid ,
		vdescription ,
		scurrencyid ,
		fpricecost ,
		fpricetax ,
		fpricetotal ,
		vconcept ,
		dstartdate ,
		dfinishdate ,
		bvisible ,
		sstatus ,
		iproductid ,
		iinsertuserid,
		DINSERTDATE,
		vinsertip
	      ) VALUES (
		1 ,
		1701 ,
		'default produc',
		2301 ,
		0 ,
		0 ,
		0 ,
		'|||' ,
		now() ,
		(now()::date + 30) ,
		true ,
		2 ,
		p_iproductid ,    
		p_iinsertuserid,
		now(),
		p_vinsertip
	      );	
	end if;	
	
  ELSIF p_voption = 'UPD' THEN
	UPDATE public.product
	SET 
	       sproducttypeid=p_sproducttypeid, 
	       sproductuseid=p_sproductuseid, 
	       sproductcategoryid=p_sproductcategoryid, 
	       sproductscopeid=p_sproductscopeid, 
	       vdescription=p_vdescription, 
	       vproductcode=p_vproductcode, 
	       dstartdate=p_dstartdate, 
	       denddate=p_denddate,
	       bauthorization=p_bauthorization,
               vcharacteristics=p_vcharacteristics,
               sorder=p_sorder,
               bvisible=p_bvisible,
               bconformity=p_bconformity,
	       bfloating=p_bfloating,
	       sstatus=1, 	       
	       iupdateuserid=p_iupdateuserid, 
	       dupdatedate=now(), 
	       vupdateip=p_vupdateip
	 WHERE iproductid=p_iproductid;
  ELSIF p_voption = 'DEL' THEN  
	
	validarDEL = 0;
	IF exists(select iproductid from product p inner join product_step ps on p.iproductid = ps.iproductid where ps.sstatus=1 and ps.iproductid = p_iproductid) then
		validarDEL =1;
	end if;
	IF exists(select iproductid from product p inner join product_composition pc on p.iproductid = pc.iproductid where pc.sstatus=1 and pc.iproductid = p_iproductid) then
		validarDEL =1;
	end if ;
	IF exists(select iproductid from product p inner join product_document pd on p.iproductid = pd.iproductid where pd.sstatus=1 and pd.iproductid = p_iproductid) then
		validarDEL =1;
	end if;
	IF exists(select iproductid from product p inner join product_pricing pp on p.iproductid = pp.iproductid where pp.sstatus=1 and pp.iproductid = p_iproductid) then
		validarDEL =1;
	end if;
	
	IF validarDEL = 0 then
		UPDATE public.product
		SET 
		       sstatus=-1, 	       
		       iupdateuserid=p_iupdateuserid, 
		       dupdatedate=now(), 
		       vupdateip=p_vupdateip
		 WHERE iproductid=p_iproductid;  
	 else
		p_iproductid = -1;
	 end if;
  END IF;    
END;
$$;


--
-- TOC entry 2615 (class 0 OID 0)
-- Dependencies: 328
-- Name: FUNCTION usp_product_maintenance(INOUT p_iproductid integer, p_sproducttypeid smallint, p_sproductuseid smallint, p_sproductcategoryid smallint, p_sproductscopeid smallint, p_vdescription character varying, p_vproductcode character varying, p_dstartdate timestamp without time zone, p_denddate timestamp without time zone, p_bauthorization boolean, p_vcharacteristics character varying, p_sorder smallint, p_bvisible boolean, p_bconformity boolean, p_bfloating boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_maintenance(INOUT p_iproductid integer, p_sproducttypeid smallint, p_sproductuseid smallint, p_sproductcategoryid smallint, p_sproductscopeid smallint, p_vdescription character varying, p_vproductcode character varying, p_dstartdate timestamp without time zone, p_denddate timestamp without time zone, p_bauthorization boolean, p_vcharacteristics character varying, p_sorder smallint, p_bvisible boolean, p_bconformity boolean, p_bfloating boolean, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a printer';


--
-- TOC entry 329 (class 1255 OID 83424)
-- Name: usp_product_pricing_get(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_pricing_get(p_ipricingid integer, p_iproductid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product composition<br />
 * Detailed explanation of the object.
 * @param p_ipricingid       Id the table product_pricing   
 * @param p_iproductid			Id the table product
 * @param p_slanguageid
 * @return cursor
 * @author  rpaucar
 * @version 1.0 rpaucar 02/09/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
DECLARE p_language integer := p_slanguageid % 140;
begin
	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN p_cursor FOR 
	(
	SELECT 
	  PRI.IPRICINGID,
	  PRI.IPRODUCTID,
          PRI.ILOCATIONID,
          LO.VDESCRIPTION VLOCATION,
          PRI.SPRICINGTYPEID,
          cast(trim(split_part(SYPAR.VDESCRIPTION,'|', p_language)) as character varying) VPRICINGTYPE,
          PRI.VDESCRIPTION,
          PRI.SCURRENCYID,
          cast(trim(split_part(SYPAR2.VDESCRIPTION,'|', p_language)) as character varying) VCURRENCY,
          PRI.FPRICECOST,
          PRI.FPRICETAX,
          PRI.FPRICETOTAL,
          PRI.VCONCEPT,
          PRI.DSTARTDATE,
          PRI.DFINISHDATE,
          PRI.BVISIBLE,
          PRI.SSTATUS
        FROM product_pricing PRI
        LEFT JOIN LOCATION LO ON LO.ILOCATIONID= PRI.ILOCATIONID
        INNER JOIN SYSTEMPARAMETER SYPAR ON SYPAR.IPARAMETERID=PRI.SPRICINGTYPEID
        INNER JOIN SYSTEMPARAMETER SYPAR2 ON SYPAR2.IPARAMETERID=PRI.SCURRENCYID    
        where PRI.sstatus >=1 and
        (p_ipricingid=0 or PRI.ipricingid=p_ipricingid) and
        (p_iproductid=0 or PRI.iproductid=p_iproductid)
        );
return (p_cursor);
end;
$$;


--
-- TOC entry 2616 (class 0 OID 0)
-- Dependencies: 329
-- Name: FUNCTION usp_product_pricing_get(p_ipricingid integer, p_iproductid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_pricing_get(p_ipricingid integer, p_iproductid integer, p_slanguageid integer) IS 'Stored procedure returns a list of product pricing according to parameters entered';


--
-- TOC entry 331 (class 1255 OID 83425)
-- Name: usp_product_pricing_maintenance(character varying, integer, integer, smallint, character varying, smallint, double precision, double precision, double precision, character varying, timestamp without time zone, timestamp without time zone, boolean, smallint, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_vconcept character varying, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a project <br />
 * Explicación detallada del objeto.
 * @param p_voption          Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_ipricingid       Primary auto-increment key
 * @param p_iproductid            Stores the name of product
 * @param p_ilocationid       Relation to the table location
 * @param p_spricingtypeid     Typo pricing, Relation to the table systemparameter igroupid = 1700
 * @param p_vdescription          Description
 * @param p_scurrencyid		Currency, Relation to the table systemparameter igroupid = 2300
 * @param p_fpricecost		Price cost
 * @param p_fpricetax		Price tax
 * @param p_fpricetotal		Price total
 * @param p_vconcept		Concatenated field and separated by | related systemparameter : igroupid 3700 | igroupid 4000 | igroupid 4400
 * @param p_dstartdate		Price inception date
 * @param p_dfinishdate		Effective end Price
 * @param p_bvisible		Is visible in the app
 * @param p_sstatus		Registration Status
 * @param p_iinsertuserid    User ID
 * @param p_vinsertip        IP address user
 * @param p_iupdateuserid    Updated user ID
 * @param p_vupdateip    IP address user
 * @return Number
 * @author  rpaucar
 * @version 1.0 rpaucar 02/08/2016 <br />
 */
BEGIN
  
  IF p_vOption = 'INS' THEN       
      INSERT INTO product_pricing (
        ilocationid ,
	spricingtypeid ,
	vdescription ,
	scurrencyid ,
	fpricecost ,
	fpricetax ,
	fpricetotal ,
	vconcept ,
	dstartdate ,
	dfinishdate ,
	bvisible ,
	sstatus ,
	iproductid ,
        iinsertuserid,
        DINSERTDATE,
        vinsertip
      ) VALUES (
        p_ilocationid ,
	p_spricingtypeid ,
	p_vdescription ,
	p_scurrencyid ,
	p_fpricecost ,
	p_fpricetax ,
	p_fpricetotal ,
	p_vconcept ,
	p_dstartdate ,
	p_dfinishdate ,
	p_bvisible ,
	1 ,
	p_iproductid ,    
        p_iinsertuserid,
        now(),
        p_vinsertip
      );
      p_ipricingid := (select currval('pricing_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE product_pricing
      SET 
	ilocationid=p_ilocationid ,
	spricingtypeid=p_spricingtypeid ,
	vdescription=p_vdescription ,
	scurrencyid=p_scurrencyid ,
	fpricecost=p_fpricecost ,
	fpricetax=p_fpricetax ,
	fpricetotal=p_fpricetotal ,
	vconcept=p_vconcept ,
	dstartdate=p_dstartdate ,
	dfinishdate=p_dfinishdate ,
	bvisible=p_bvisible ,
	sstatus=1 ,
	iproductid=p_iproductid ,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE ipricingid = p_ipricingid;
  ELSIF p_vOption = 'DEL' THEN  
      --DELETE FROM systemproject WHERE isystemprojectid = p_isystemprojectid; 
      UPDATE product_pricing
      SET sstatus = 0,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE ipricingid = p_ipricingid;
  END IF;
END;
$$;


--
-- TOC entry 2617 (class 0 OID 0)
-- Dependencies: 331
-- Name: FUNCTION usp_product_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_vconcept character varying, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_pricing_maintenance(p_voption character varying, INOUT p_ipricingid integer, p_ilocationid integer, p_spricingtypeid smallint, p_vdescription character varying, p_scurrencyid smallint, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_vconcept character varying, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_bvisible boolean, p_sstatus smallint, p_iproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a project document';


--
-- TOC entry 332 (class 1255 OID 83426)
-- Name: usp_product_step_get(integer, smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_step_get(p_iproductid integer, p_ssteptypeid smallint) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product step<br />
 * Detailed explanation of the object.
 * @param p_iproductid       Id the table product                                INPUT
 * @param p_ssteptypeid      step type, table systemparameter igroupid = 1800    INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT 
	ps.iproductstepid, 
	ps.iproductid, 
	ps.ssteptypeid, 
	ps.vdescription, 
	ps.sorden, 
	ps.ireferenceproductstepid, 
	ps.sstatus, 
	ps.bmandatory, 
	ps.bvisible,
	ps.vfunctionname,	
	ps.ifunctionproductid,
	(select p.vdescription from product_step p where p.iproductstepid=ps.ireferenceproductstepid) vreference  
        FROM public.product_step ps
        where ps.iproductid=p_iproductid and 
        (p_ssteptypeid=0 or ps.ssteptypeid=p_ssteptypeid)
        order by sorden
        );       
return (p_cursor);
end;
$$;


--
-- TOC entry 2618 (class 0 OID 0)
-- Dependencies: 332
-- Name: FUNCTION usp_product_step_get(p_iproductid integer, p_ssteptypeid smallint); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_step_get(p_iproductid integer, p_ssteptypeid smallint) IS 'Stored procedure  save, edit and delete a product step';


--
-- TOC entry 333 (class 1255 OID 83427)
-- Name: usp_product_step_maintenance(character varying, integer, integer, smallint, character varying, smallint, integer, smallint, boolean, boolean, character varying, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_product_step_maintenance(p_voption character varying, INOUT p_iproductstepid integer, p_iproductid integer, p_ssteptypeid smallint, p_vdescription character varying, p_sorden smallint, p_ireferenceproductstepid integer, p_sstatus smallint, p_bmandatory boolean, p_bvisible boolean, p_vfunctionname character varying, p_ifunctionproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a project <br />
 * Explicación detallada del objeto.
 * @param p_voption          Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_iproductstepid      Primary auto-increment key
 * @param p_iproductid  	-- Relation to the table product
 * @param p_ssteptypeid  	-- Relation to the table systemparameter igroupid = 1800
 * @param p_vdescription  	-- Description
 * @param p_sorden 		-- Order record
 * @param p_ireferenceproductstepid  -- Relation to the table product_step
 * @param p_sstatus 		 -- Registration Status
 * @param p_bmandatory 	 -- Is mandatory
 * @param p_bvisible 		 -- Is visible in the app
 * @param p_vfunctionname 	 -- Executes a function on app
 * @param p_ifunctionproductid -- Id product
 * @param p_iinsertuserid    User ID
 * @param p_vinsertip        IP address user
 * @param p_iupdateuserid    Updated user ID
 * @param p_vupdateip    IP address user
 * @return Number
 * @author  rpaucar
 * @version 1.0 rpaucar 02/08/2016 <br />
 */
BEGIN
if p_ifunctionproductid= -1 then
p_ifunctionproductid=null;
end if;

  
  IF p_vOption = 'INS' THEN       
      INSERT INTO product_step (
        iproductid ,
	ssteptypeid ,
	vdescription ,
	sorden ,
	ireferenceproductstepid ,
	sstatus ,
	bmandatory ,
	bvisible ,
	vfunctionname ,
	ifunctionproductid ,
        iinsertuserid,
        DINSERTDATE,
        vinsertip
      ) VALUES (
        p_iproductid ,
	p_ssteptypeid ,
	p_vdescription ,
	p_sorden ,
	p_ireferenceproductstepid ,
	1 ,
	p_bmandatory ,
	p_bvisible ,
	p_vfunctionname ,
	p_ifunctionproductid ,    
        p_iinsertuserid,
        now(),
        p_vinsertip
      );
      p_iproductstepid := (select currval('product_step_seq'));
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE product_step
      SET 
	iproductid=p_iproductid ,
	ssteptypeid=p_ssteptypeid ,
	vdescription=p_vdescription ,
	sorden=p_sorden ,
	ireferenceproductstepid=p_ireferenceproductstepid ,
	sstatus=1 ,
	bmandatory=p_bmandatory ,
	bvisible=p_bvisible ,
	vfunctionname=p_vfunctionname ,
	ifunctionproductid=p_ifunctionproductid ,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductstepid = p_iproductstepid;
  ELSIF p_vOption = 'DEL' THEN  
      --DELETE FROM systemproject WHERE isystemprojectid = p_isystemprojectid; 
      UPDATE product_step
      SET sstatus = 0,
      IUPDATEUSERID = p_iupdateuserid,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vupdateip
      WHERE iproductstepid = p_iproductstepid;
  END IF;
END;
$$;


--
-- TOC entry 2619 (class 0 OID 0)
-- Dependencies: 333
-- Name: FUNCTION usp_product_step_maintenance(p_voption character varying, INOUT p_iproductstepid integer, p_iproductid integer, p_ssteptypeid smallint, p_vdescription character varying, p_sorden smallint, p_ireferenceproductstepid integer, p_sstatus smallint, p_bmandatory boolean, p_bvisible boolean, p_vfunctionname character varying, p_ifunctionproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_product_step_maintenance(p_voption character varying, INOUT p_iproductstepid integer, p_iproductid integer, p_ssteptypeid smallint, p_vdescription character varying, p_sorden smallint, p_ireferenceproductstepid integer, p_sstatus smallint, p_bmandatory boolean, p_bvisible boolean, p_vfunctionname character varying, p_ifunctionproductid integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a project step';


--
-- TOC entry 334 (class 1255 OID 83428)
-- Name: usp_productid_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_productid_get(p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product<br />
 * Detailed explanation of the object.
 * @param p_iproductid       Id the table product                                INPUT
 * @return cursor
 * @author  rpaucar
 * @version 1.0 rpaucar 31/08/2016<BR/> 
 */
declare p_cursor refcursor :='ref_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT  iproductid, sproducttypeid, sproductuseid, sproductcategoryid, 
       sproductscopeid, vdescription, vproductcode, dstartdate, denddate, 
       bauthorization, vcharacteristics, sorder, bvisible, bconformity, 
       bfloating, sstatus
	FROM public.product 
	where sstatus>=0 and 
	(p_iproductid=0 or iproductid=p_iproductid)	
	order by iproductid desc);	
return (p_cursor);
end;
$$;


--
-- TOC entry 2620 (class 0 OID 0)
-- Dependencies: 334
-- Name: FUNCTION usp_productid_get(p_iproductid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_productid_get(p_iproductid integer) IS 'Stored procedure  save, edit and delete a product';


--
-- TOC entry 335 (class 1255 OID 83429)
-- Name: usp_productpricing_get(character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_productpricing_get(p_vproductid character varying, p_iplatetypeid integer, p_icategoryvehicleid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    declare p_language integer := p_slanguageid % 140;
    BEGIN

/**
 * Description: Stored procedure that returns a list of prices of a product<br />
 * Detailed explanation of the object.
 * @param p_vproductid            Product ID. Concat for ,
 * @param p_iplatetypeid          Plate Type.
 * @param p_icategoryvehicleid    Category of vehicle.
 * @return Return table product pricing
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

 IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
      OPEN ref_cursor FOR 

      --SELECT sp.iparameterid,
				 --(sp.vdescription || ' (price:' || p.fpricetotal ||')') vdescription 
				--FROM product_pricing pc INNER JOIN pricing p
				--ON pc.ipricingid = p.ipricingid INNER JOIN systemparameter sp
				--ON sp.iparameterid = p.sduration AND sp.igroupid = 4600
				 --WHERE pc.iproductid in (select cast(regexp_split_to_table(p_vproductid, ',')as int))
				 --AND pc.sstatus = 1 
				 --AND p.sstatus = 1;

	SELECT 
	COALESCE(p.ipricingid,0) as ipricingid,
	COALESCE(p.vconcept,'') as vconcept,
	COALESCE(p.fpricetotal,0) as fpricetotal,
	(SELECT cast(trim(split_part(spp.vdescription,'|', p_language)) as character varying) FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 3) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 3)) as integer) end) limit 1) ||' '|| (' (price:' || p.fpricetotal ||')') vdescriptionveh,
	(SELECT cast(trim(split_part(spp.vdescription,'|', p_language)) as character varying) FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 4) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 4)) as integer) end) limit 1)||' '||(' (price:' || p.fpricetotal ||')') vdescriptioninspe,
	( case when cast(trim(split_part(p.vconcept,'|', 3)) as character varying)=''
	  then 
	 (SELECT spp.vvalue FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 4) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 4)) as integer) end) limit 1)
	  else
	 (SELECT spp.vvalue FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 3) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 3)) as integer) end) limit 1)
	end) as vvalue,
	 ( case when cast(trim(split_part(p.vconcept,'|', 3)) as character varying)=''
	  then 
	 (SELECT spp.iparameterid FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 4) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 4)) as integer) end) limit 1)
	  else
	 (SELECT spp.iparameterid FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 3) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 3)) as integer) end) limit 1)
	end) as iparameterid,
	p.iproductid,
	(SELECT cast(trim(split_part(spp.vdescription,'|', 1)) as character varying) FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 3) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 3)) as integer) end) limit 1) vdescriptionlicense,
	(SELECT cast(trim(split_part(spp.vdescription,'|', 1)) as character varying) FROM systemparameter spp WHERE spp.igroupid = 4400
		AND spp.iparameterid = (CASE when split_part(p.vconcept,'|', 4) ='' THEN 0 
		else cast(trim(split_part(p.vconcept,'|', 4)) as integer) end) limit 1) vdescriptioninspection
	FROM product_pricing p 
	WHERE  p.iproductid  in (select cast(regexp_split_to_table(p_vproductid, ',')as int)) 
	AND  (p_iPlateTypeId = 0 OR cast(trim(  case when split_part(p.vconcept,'|', 1) = '' then '0' else split_part(p.vconcept,'|', 1) end  ) as integer) = p_iPlateTypeId)
	and (p_iCategoryVehicleId = 0 OR cast(trim(case when split_part(p.vconcept,'|', 2) = '' then '0' else split_part(p.vconcept,'|', 2) end) as integer)=p_iCategoryVehicleId);
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2621 (class 0 OID 0)
-- Dependencies: 335
-- Name: FUNCTION usp_productpricing_get(p_vproductid character varying, p_iplatetypeid integer, p_icategoryvehicleid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_productpricing_get(p_vproductid character varying, p_iplatetypeid integer, p_icategoryvehicleid integer, p_slanguageid integer) IS 'Stored procedure that returns a list of prices of a product';


--
-- TOC entry 330 (class 1255 OID 83430)
-- Name: usp_productstep_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_productstep_get(p_iproductstepid integer, p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of product composition<br />
 * Detailed explanation of the object.
 * @param p_iproductstepid       Id the table product_step   
 * @param p_iproductid			Id the table product
 * @return cursor
 * @author  rpaucar
 * @version 1.0 rpaucar 03/09/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT 
	  PRI.iproductstepid,
	  PRI.iproductid,
          PRI.ssteptypeid,
          PRI.vdescription,
          PRI.sorden,
          PRI.ireferenceproductstepid,
          PRI.sstatus,
          PRI.bmandatory,
          PRI.bvisible,
          PRI.vfunctionname,
          PRI.ifunctionproductid
        FROM product_step PRI   
        where PRI.sstatus=1 and
        (p_iproductstepid=0 or PRI.iproductstepid=p_iproductstepid) and
        (p_iproductid=0 or PRI.iproductid=p_iproductid)
        );
return (p_cursor);
end;
$$;


--
-- TOC entry 2622 (class 0 OID 0)
-- Dependencies: 330
-- Name: FUNCTION usp_productstep_get(p_iproductstepid integer, p_iproductid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_productstep_get(p_iproductstepid integer, p_iproductid integer) IS 'Stored procedure returns a list of product step according to parameters entered';


--
-- TOC entry 337 (class 1255 OID 83431)
-- Name: usp_report_movementplate(integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_report_movementplate(p_splatetypeid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_language integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';

/**
 * Description: Procedure to create Plate Movement Report<br />
 * Detailed explanation of the object.
 * @param p_splatetypeid	Plate Type ID				INPUT
 * @param p_dstartdate   	Start Date for the search   INPUT
 * @param p_dfinishdate  	Finish Date for the search	INPUT
 * @param p_language
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	V.ivehicleid "ID",
	vvehiclecode "Code",
	CAST(TRIM(split_part(SP_C.vdescription,'|', p_language)) as character varying) "Vehicle Category",
	CAST(TRIM(split_part(SP_TP.vdescription,'|', p_language)) as character varying) "Type Plate",
	RL.vnumberplate "Number Plate",
	CAST(TRIM(split_part(SP.vdescription,'|', p_language)) as character varying) "Status",
	RL.dstartdate "Date"
FROM vehicle V
JOIN request_detail RD ON RD.ivehicleid = V.ivehicleid
JOIN request_license RL ON RL.irequestlicenseid = RD.irequestlicenseid
JOIN systemparameter SP ON SP.iparameterid = RL.sstatus
JOIN systemparameter SP_TP ON SP_TP.iparameterid = RL.splatetypeid
JOIN systemparameter SP_C ON SP_C.iparameterid = V.scategorytypeid
WHERE
	(p_splatetypeid = 0 OR  RL.splatetypeid = p_splatetypeid)AND
	(RL.dstartdate BETWEEN p_dstartdate AND p_dfinishdate)
ORDER BY RL.dstartdate);
RETURN (p_cursor);
END;
$$;


--
-- TOC entry 338 (class 1255 OID 83432)
-- Name: usp_report_servicesnote(integer, timestamp without time zone, timestamp without time zone, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_report_servicesnote(p_packiproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_iinsertuserid integer, p_sstatus integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';

/**
 * Description: Stored procedure that returns a list of request<br />
 * Detailed explanation of the object.
 * @param p_packiproductid		Id pack product		INPUT
 * @param p_dstartdate   		start date request	INPUT
 * @param p_dfinishdate  		finish date request INPUT
 * @param p_iinsertuserid 		id user			  	INPUT
 * @param p_sstatus      		Id parameter the table Systemparameter Group OPERATION_REQUESTSTATUS=5000  INPUT
 * @return cursor
 * @author jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	CASE WHEN COALESCE(vorganization, '') = '' THEN COALESCE(vlastname, '') || ' ' ||  COALESCE(vfirstname, '') || ' ' || COALESCE(vmiddlename, '') || ' ' || COALESCE(vmaidenname,'') 
			ELSE vorganization END "Name",
	R.irequestid "Request Id",
	RD.irequestdetailid "Request Detail Id",
	PrPack.vdescription "Pack ProductName",
	Pr.vdescription "Product Name",
	R.dstartdate "Date Request",
	CAST(TRIM(split_part(SP.vdescription,'|', 1)) as character varying) "Status",
	N.vobservation "Comment",
	N.dinsertdate "Date Note"
	--, R.irequestid, RD.irequestdetailid, N.inoteid
FROM party P
	JOIN Request R ON R.ipartyid = P.ipartyid
	JOIN Request_detail RD ON RD.irequestid = R.irequestid
	JOIN Product Pr ON Pr.iproductid = RD.iproductid
	JOIN Product PrPack ON PrPack.iproductid = R.iproductid
	JOIN Systemparameter SP ON SP.iparameterid = R.sstatus
	LEFT JOIN Note N ON N.irequestdetailid = RD.irequestdetailid
WHERE
	(p_packiproductid = 0 OR PrPack.iproductid = p_packiproductid) AND
	(R.dstartdate BETWEEN p_dstartdate AND p_dfinishdate) AND
	(p_iinsertuserid = 0 OR R.iinsertuserid = p_iinsertuserid) AND
	(p_sstatus = 0 OR R.sstatus = p_sstatus)
ORDER BY R.irequestid);

RETURN (p_cursor);
END;
$$;


--
-- TOC entry 339 (class 1255 OID 83433)
-- Name: usp_report_vehicle(integer, integer, integer, integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_report_vehicle(p_scategorytypeid integer, p_sprimarycolourid integer, p_ssecondarycolourid integer, p_sstatus integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_language integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare p_cursor refcursor :='p_cursor';

/**
 * Description: Stored procedure that returns a list of vehicles<br />
 * Detailed explanation of the object.
 * @param p_scategorytypeid  	vehicle category	      	INPUT
 * @param p_sprimarycolourid  	colour primary vehicle		INPUT
 * @param p_ssecondarycolourid  colour secondary vehicle	INPUT
 * @param p_sstatus  			status vehicle			  	INPUT
 * @param p_dstartdate   		start date request   		INPUT
 * @param p_dfinishdate  		finish date request         INPUT
 * @param p_language
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 26/09/2016<BR/> 
 */
BEGIN
OPEN p_cursor FOR
(SELECT 
	V.vvehiclecode "Code",
	VC.vdescription "Make",
	VC1.vdescription "Model",
	CAST(TRIM(split_part(SP.vdescription,'|', p_language)) as character varying) "Colour Primary",
	CAST(TRIM(split_part(SP1.vdescription,'|', p_language)) as character varying) "Colour Secondary",
	CAST(TRIM(split_part(SP2.vdescription,'|', p_language)) as character varying) "Status",
	V.dinsertdate "Date"
FROM vehicle V
	JOIN vehicle_catalog VC ON VC.ivehiclecatalogid = V.imakeid
	JOIN vehicle_catalog VC1 ON VC1.ivehiclecatalogid = V.imodelid
	JOIN systemparameter SP ON SP.iparameterid = V.sprimarycolourid
	JOIN systemparameter SP1 ON SP1.iparameterid = V.ssecondarycolourid
	JOIN systemparameter SP2 ON SP2.iparameterid = V.sstatus
	JOIN systemparameter SP3 ON SP3.iparameterid = V.scategorytypeid
WHERE 
	(p_scategorytypeid = 0 OR V.scategorytypeid = p_scategorytypeid) AND
	(p_sprimarycolourid = 0 OR V.sprimarycolourid = p_sprimarycolourid) AND
	(p_ssecondarycolourid = 0 OR V.ssecondarycolourid = p_ssecondarycolourid) AND
	(p_sstatus = 0 OR V.sstatus = p_sstatus) AND
	(V.dinsertdate BETWEEN p_dstartdate AND p_dfinishdate)
);
RETURN (p_cursor);
END;
$$;


--
-- TOC entry 340 (class 1255 OID 83434)
-- Name: usp_request_detail_maintenance(integer, integer, integer, integer, integer, smallint, smallint, smallint, integer, integer, integer, character varying, smallint, smallint, timestamp without time zone, timestamp without time zone, character varying, boolean, double precision, double precision, double precision, character varying, character varying, character varying, character varying, smallint, integer, character varying, integer, character varying, character varying, smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_detail_maintenance(INOUT p_irequestdetailid integer, p_irequestid integer, p_iownerid integer, p_ivehicleid integer, p_idriverlicenseid integer, p_sdriverlicensetypeid smallint, p_smotocyclegroupid smallint, p_smotorvehiclegroupid smallint, p_iproductid integer, p_ipricingid integer, p_igenevadetailterritoryid integer, p_vgenevadetailsubterritory character varying, p_svisitpermitdurationday smallint, p_snumber smallint, p_dissuedate timestamp without time zone, p_dexpirydate timestamp without time zone, p_vcurrenttab character varying, p_bwaived boolean, p_fpricecost double precision, p_fpricetax double precision, p_fpricetotal double precision, p_vnumberplate character varying, p_vplatepreview character varying, p_vjson character varying, p_vcoment character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying, p_ispayment smallint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a Request Detail<br />
 * Detailed explanation of the object.
 * @param p_irequestdetailid                        Id the table request detail                                                      INPUT Y OUTPUT
 * @param p_irequestid                              Id the table request                                                             INPUT
 * @param p_iownerid 				    Id the table party                                                               INPUT
 * @param p_ivehicleid                              Id the table vehicle                                                             INPUT
 * @param p_idriverlicenseid                        Id Driver's License                                                              INPUT
 * @param p_sdriverlicensetypeid                    IdParameter table systemparameter Group OPERATION_DRIVERLICENSETYPE = 4100       INPUT
 * @param p_smotocyclegroupid 		            IdParameter table systemparameter Group OPERATION_MOTORCYCLEGROUP   = 4200       INPUT
 * @param p_smotorvehiclegroupid                    IdParameter table systemparameter Group OPERATION_MOTORVEHICLEGROUP = 4300       INPUT
 * @param p_ipricingid 			            Id the table Pricing                                                             INPUT
 * @param p_igenevadetailterritoryid                Id table Location                                                                INPUT
 * @param p_vgenevadetailsubterritory               Descripcion the subterritory                                                     INPUT
 * @param p_svisitpermitdurationday                 Duration visit permit                                                            INPUT
 * @param p_snumber                                 Number Driver´s License                                                          INPUT
 * @param p_dissuedate                              Issued Date Request Detail                                                       INPUT
 * @param p_dexpirydate                             Expire Date Request Detail                                                       INPUT
 * @param p_vcurrenttab                             Current tab the request detail                                                   INPUT
 * @param p_bwaived                                 Exemption from payment for a service 1 = Exonerated; 0 = No Exonerated           INPUT
 * @param p_fpricecost                              price cost request detail                                                        INPUT
 * @param p_fpricetax                               price tax request detail                                                         INPUT
 * @param p_fpricetotal                             price total request detail                                                       INPUT
 * @param p_vnumberplate                            number plate                                                                     INPUT
 * @param p_vplatepreview                           plate preview Format: Mask | Layout | Font Family | Font size | Font Colour      INPUT
 * @param p_vjson				    Onject Json									     INPUT
 * @param p_sstatus                                 Status Request Detail Group OPERATION_REQUESTSTATUS = 5000                       INPUT
 * @param p_iinsertuserid 			    User ID                                                                          INPUT 
 * @param p_vinsertip 		                    IP address user	                                                             INPUT
 * @param p_iupdateuserid 			    Updated user ID                                                                  INPUT 
 * @param p_vupdateip 		                    Update user IP                                                                   INPUT
 * @param p_voption 			            Option INS= INSERT; UPD= UPDATE; DEL=DELETE                                      INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 fjcosta 26/07/2016<BR/> 
 * @version 1.1 jcondori 15/08/2016<BR/> 
 */
declare p_cnt integer := 0;
BEGIN
  IF p_vOption = 'INS' THEN  
	INSERT INTO public.request_detail(
	      irequestid,
	      iownerid,
	      ivehicleid,
	      irequestlicenseid,
	      sdriverlicensetypeid,
	      smotocyclegroupid,
	      smotorvehiclegroupid,
	      iproductid,
	      ipricingid,
	      igenevadetailterritoryid,
	      vgenevadetailsubterritory,
	      svisitpermitdurationday,
	      snumber,
	      dissuedate,
	      dexpirydate,
	      vcurrenttab,
	      bwaived,
	      fpricecost,
	      fpricetax,
	      fpricetotal,
	      vnumberplate,
	      vplatepreview,
	      vjson,
	      vcoment,
	      sstatus,
	      iinsertuserid,
	      dinsertdate,
	      vinsertip
	)
	    VALUES (
	      p_irequestid,
	      p_iownerid,
	      p_ivehicleid,
	      p_idriverlicenseid,
	      p_sdriverlicensetypeid,
	      p_smotocyclegroupid,
	      p_smotorvehiclegroupid,
	      p_iproductid,
	      p_ipricingid,
	      p_igenevadetailterritoryid,
	      p_vgenevadetailsubterritory,
	      p_svisitpermitdurationday,
	      p_snumber,
	      p_dissuedate,
	      p_dexpirydate,
	      p_vcurrenttab,
	      p_bwaived,
	      p_fpricecost,
	      p_fpricetax,
	      p_fpricetotal,
	      p_vnumberplate,
	      p_vplatepreview,
	      p_vjson,
	      p_vcoment,
	      p_sstatus,
	      p_iinsertuserid,
	      now(),
	      p_vinsertip
	     );	  
	    p_irequestdetailid := (select currval('request_detail_seq'));  

	    if (p_vcurrenttab != '' and p_vcurrenttab is not null) then
	    update request set vtabname = p_vcurrenttab where irequestid = p_irequestid;
	    end if;
	      	
  ELSIF p_vOption = 'UPD' THEN
	IF(COALESCE(p_ispayment, 0) = 1) THEN

		UPDATE public.request_detail
		    SET 
		      irequestid = p_irequestid,
		      ivehicleid = COALESCE(p_ivehicleid,ivehicleid),
		      irequestlicenseid = COALESCE(p_idriverlicenseid,irequestlicenseid),
		      iownerid= COALESCE(p_iownerid, iownerid),
		      vjson = COALESCE(p_vjson,vjson),
		      vcoment = COALESCE(p_vcoment,vcoment),
		      sstatus = COALESCE(case when p_sstatus=0 then sstatus else p_sstatus end,sstatus),
		      iupdateuserid = COALESCE(p_iupdateuserid,iupdateuserid),
		      dupdatedate = now(),
		      vupdateip = COALESCE(p_vupdateip,vupdateip)
		    WHERE irequestdetailid=p_irequestdetailid;	
	ELSE
		UPDATE public.request_detail
		    SET 
		      irequestid = COALESCE(p_irequestid,irequestid),
		      iownerid=COALESCE(p_iownerid,iownerid),
		      ivehicleid = COALESCE(p_ivehicleid,ivehicleid),
		      irequestlicenseid = COALESCE(p_idriverlicenseid,irequestlicenseid),
		      sdriverlicensetypeid = COALESCE(p_sdriverlicensetypeid,sdriverlicensetypeid),
		      smotocyclegroupid = COALESCE(p_smotocyclegroupid,smotocyclegroupid),
		      smotorvehiclegroupid = COALESCE(p_smotorvehiclegroupid,smotorvehiclegroupid),
		      ipricingid = COALESCE(p_ipricingid,ipricingid),
		      igenevadetailterritoryid = COALESCE(p_igenevadetailterritoryid,igenevadetailterritoryid),
		      vgenevadetailsubterritory = COALESCE(p_vgenevadetailsubterritory,vgenevadetailsubterritory),
		      svisitpermitdurationday = COALESCE(p_svisitpermitdurationday,svisitpermitdurationday),
		      snumber = COALESCE(p_snumber,snumber),
		      dissuedate = COALESCE(p_dissuedate,dissuedate),
		      dexpirydate = COALESCE(p_dexpirydate,dexpirydate),
		      vcurrenttab = COALESCE(p_vcurrenttab,vcurrenttab),
		      bwaived = COALESCE(p_bwaived,bwaived),
		      fpricecost = COALESCE(p_fpricecost,fpricecost),
		      fpricetax = COALESCE(p_fpricetax,fpricetax),
		      fpricetotal = COALESCE(p_fpricetotal,fpricetotal),
		      vnumberplate = COALESCE(p_vnumberplate,vnumberplate),
		      vplatepreview = COALESCE(p_vplatepreview,vplatepreview),
		      vjson = COALESCE(p_vjson,vjson),
		      vcoment= COALESCE(p_vcoment,vcoment),
		      sstatus = COALESCE(p_sstatus,sstatus),
		      iupdateuserid = COALESCE(p_iupdateuserid,iupdateuserid),
		      dupdatedate = now(),
		      vupdateip = COALESCE(p_vupdateip,vupdateip)     
		    WHERE irequestdetailid=p_irequestdetailid;		    
	END IF;
	update request set vtabname = p_vcurrenttab where irequestid = p_irequestid;
	
  ELSIF p_vOption = 'DEL' THEN  
    UPDATE public.request_detail
    SET 
      sstatus = 0,
      iupdateuserid = p_iupdateuserid,
      dupdatedate = now(),
      vupdateip = p_vupdateip       
    WHERE irequestdetailid=p_irequestdetailid;  
  END IF;    
END;
$$;


--
-- TOC entry 341 (class 1255 OID 83436)
-- Name: usp_request_detail_status(integer, smallint, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_detail_status(p_irequestdetailid integer, p_sstatus smallint, p_iupdateuserid integer, p_vupdateip character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that updates the status of an request detail<br />
 * Detailed explanation of the object.
 * @param p_irequestdetailid   Id the table Request   INPUT
 * @param p_sstatus            status request detail  INPUT
 * @param p_iupdateuserid      Updated user ID        INPUT
 * @param p_vupdateip          Update user IP         INPUT
 * @return null
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
BEGIN
     UPDATE public.request_detail
     SET sstatus = p_sstatus,
     iupdateuserid = p_iupdateuserid,
     dupdatedate = now(),
     vupdateip = p_vupdateip       
     WHERE irequestdetailid = p_irequestdetailid; 
END;
$$;


--
-- TOC entry 2623 (class 0 OID 0)
-- Dependencies: 341
-- Name: FUNCTION usp_request_detail_status(p_irequestdetailid integer, p_sstatus smallint, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_detail_status(p_irequestdetailid integer, p_sstatus smallint, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure that updates the status of an request detail';


--
-- TOC entry 342 (class 1255 OID 83437)
-- Name: usp_request_document_get(integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_document_get(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of request document<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid          Id the table payment                                 INPUT
 * @param p_irequestid          Id the table request                                 INPUT
 * @param p_sdocumenttypeid     document type systemparameter "igroupid =  2400"     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='ref_cursor';
DECLARE p_language integer := p_slanguageid % 140;
begin
	IF (p_language is null or p_language = 0) THEN
	    p_language := 1;
	END IF;
	
	OPEN p_cursor FOR  (
	
	select distinct
	r.irequestid, p.vdescription as vproductrequest, rdd.irequestdetailid, pdd.vdescription as vproductdetail,
	rd.irequestdocument, d.idocumentid, d.vname, pd.sdocumenttypeid, 
	cast(trim(split_part(s.vdescription, '|', p_language)) as character varying) as vdocumenttype, 
	pd.bmandatory, rd.vfilename, rd.vfilepath, rd.dissuedate, rd.bprint, rd.dprint, rd.sstatus,
	rd.iinsertuserid, rd.dinsertdate, rd.vinsertip, rd.iupdateuserid, rd.dupdatedate, rd.vupdateip, pd.bfirmrequired, r.bconformity, r.iproductid,
	COALESCE((SELECT vnumberplate FROM request_detail rdtt WHERE rdtt.irequestid = r.irequestid and vnumberplate is not null limit(1)),'') as vnumberplate
	from request r
	inner join public.product p on p.iproductid = r.iproductid	
	inner join request_detail rdd on rdd.irequestid = r.irequestid
	inner join public.product pdd on pdd.iproductid = rdd.iproductid
	inner join request_document rd on rdd.irequestdetailid = rd.irequestdetailid
	inner join product_document pd on pd.iproductid = rdd.iproductid and pd.idocumentid = rd.idocumentid
	inner join document d on rd.idocumentid = d.idocumentid
	left join systemparameter s on  pd.sdocumenttypeid = s.iparameterid
	where (p_ipaymentid = 0 or r.ipaymentid = p_ipaymentid)
	and   (p_irequestid = 0 or r.irequestid = p_irequestid)
	and   (p_sdocumenttypeid = 0 or pd.sdocumenttypeid = p_sdocumenttypeid)
	and r.sstatus != 5005 --and (pd.sdocumenttypeid = 2401 or pd.sdocumenttypeid = 2402 or  r.sstatus = 5002 or r.sstatus = 5001)
	ORDER by r.irequestid, pd.sdocumenttypeid, d.vname asc

	);
return (p_cursor);
end;
$$;


--
-- TOC entry 2624 (class 0 OID 0)
-- Dependencies: 342
-- Name: FUNCTION usp_request_document_get(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_document_get(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid integer, p_slanguageid integer) IS 'Stored procedure returns a list of request document according to parameters entered';


--
-- TOC entry 336 (class 1255 OID 83438)
-- Name: usp_request_document_maintenance(integer, integer, integer, character varying, character varying, timestamp without time zone, boolean, timestamp without time zone, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_document_maintenance(INOUT p_irequestdocument integer, p_irequestdetailid integer, p_idocumentid integer, p_vfilename character varying, p_vfilepath character varying, p_dissuedate timestamp without time zone, p_bprint boolean, p_dprint timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a Request document<br />
 * Detailed explanation of the object.
 * @param  p_irequestdocument           Id the table request document                                              INPUT Y OUTPUT
 * @param p_irequestdetailid 		Id the table Request                                                       INPUT 
 * @param p_idocumentid 		Id the table document                                                      INPUT
 * @param p_vfilename                   file name                                                                  INPUT
 * @param p_vfilepath                   file path                                                                  INPUT
 * @param p_dissuedate                  issued date                                                                INPUT
 * @param p_bprint                      Indicates print date                                                       INPUT
 * @param p_sstatus 			Status request document 1=Active; 2=Inactive                               INPUT
 * @param p_iinsertuserid 		User ID                                                                    INPUT 
 * @param p_vinsertip 		        IP address user		                                                   INPUT
 * @param p_iupdateuserid 		Updated user ID                                                            INPUT 
 * @param p_vupdateip 		        Update user IP                                                             INPUT
 * @param p_voption 			Option INS= INSERT; UPD= UPDATE; DEL=DELETE                                INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cnt integer := -1;	
BEGIN
  IF p_vOption = 'INS' THEN  
	
	create temp table tbltmp_requestdetail (irequestdetailid integer,iproductid integer) on commit drop;
	INSERT INTO tbltmp_requestdetail
	select irequestdetailid,iproductid from request_detail where irequestid in 
	(select irequestid from request_detail rdd where rdd.irequestdetailid = p_irequestdetailid);
	
	SELECT Count(irequestdocument) into p_cnt  FROM request_detail rd
	inner join request_document rdd on  rdd.irequestdetailid = rd.irequestdetailid 
	WHERE idocumentid = p_idocumentid and irequestid = 
	(select irequestid from request_detail where irequestdetailid = p_irequestdetailid limit 1); 

	IF p_cnt > 0 THEN

		UPDATE request_document SET
		vfilename = p_vfilename,
		vfilepath = p_vfilepath,
		dprint = p_dprint,
		bprint = p_bprint,
		sstatus = 1,
		iupdateuserid = p_iupdateuserid,
		dupdatedate = now(),
		vupdateip = p_vupdateip  
		--WHERE irequestdetailid = p_irequestdetailid and idocumentid = p_idocumentid;
		WHERE irequestdocument = p_irequestdocument;
		--in (
		--select r.irequestdocument from request_document r  inner join request_detail rd on rd.irequestdetailid = r.irequestdetailid
		--WHERE rd.irequestid = (select irequestid  from request_detail where irequestdetailid = p_irequestdetailid limit 1) and r.idocumentid = p_idocumentid);

	ELSE	
		IF (0<(select count(iproductid) from product_composition where icomponentid = (select iproductid from request_detail where irequestdetailid = p_irequestdetailid))) THEN
			INSERT INTO request_document(irequestdetailid, idocumentid, 
			vfilename, vfilepath, dissuedate,
			bprint, dprint,
			sstatus, iinsertuserid, dinsertdate, vinsertip)
			SELECT distinct COALESCE(tr.irequestdetailid,0) as irequestdetailid, COALESCE(pd.idocumentid,0) as idocumentid,
			p_vfilename, p_vfilepath, now(),
			p_bprint, p_dprint,
			p_sstatus, p_iinsertuserid, now(), p_vinsertip
			FROM product_document pd
			inner JOIN document d on pd.idocumentid = d.idocumentid
			inner JOIN product_composition pc on pc.icomponentid = pd.iproductid
			inner JOIN tbltmp_requestdetail tr on tr.iproductid = pd.iproductid
			where pd.sstatus=1 and pc.iproductid in (select iproductid from product_composition where icomponentid = (select iproductid from request_detail where irequestdetailid = p_irequestdetailid))
			and pd.idocumentid = p_idocumentid;
		ELSE
			INSERT INTO request_document(irequestdetailid, idocumentid, 
			vfilename, vfilepath, dissuedate,
			bprint, dprint,
			sstatus, iinsertuserid, dinsertdate, vinsertip)
			SELECT distinct COALESCE(tr.irequestdetailid,0) as irequestdetailid, COALESCE(pd.idocumentid,0) as idocumentid,
			p_vfilename, p_vfilepath, now(),
			p_bprint, p_dprint,
			p_sstatus, p_iinsertuserid, now(), p_vinsertip
			FROM product_document pd
			inner JOIN document d on pd.idocumentid = d.idocumentid
			inner JOIN tbltmp_requestdetail tr on tr.iproductid = pd.iproductid
			where pd.sstatus=1 and pd.iproductid in (select iproductid from request_detail where irequestdetailid = p_irequestdetailid)
			and pd.idocumentid = p_idocumentid;
		END IF;  
		p_irequestdocument := (select currval('request_document_seq'));
			
    END IF;  
  ELSIF p_vOption = 'UPD' THEN

	UPDATE public.request_document SET 
	irequestdetailid = p_irequestdetailid,
	idocumentid = p_idocumentid,
	vfilename = p_vfilename,
	vfilepath = p_vfilepath,
	dprint = p_dprint,
	bprint = p_bprint,
	sstatus = p_sstatus,
	iupdateuserid = p_iupdateuserid,
	dupdatedate = now(),
	vupdateip = p_vupdateip  
	WHERE irequestdocument = p_irequestdocument;
  
  ELSIF p_vOption = 'DEL' THEN  
	UPDATE public.request_document SET       
	sstatus = 0,
	iupdateuserid = p_iupdateuserid,
	dupdatedate = now(),
	vupdateip = p_vupdateip  
	WHERE irequestdocument=p_irequestdocument;
  END IF;    
END;
$$;


--
-- TOC entry 2625 (class 0 OID 0)
-- Dependencies: 336
-- Name: FUNCTION usp_request_document_maintenance(INOUT p_irequestdocument integer, p_irequestdetailid integer, p_idocumentid integer, p_vfilename character varying, p_vfilepath character varying, p_dissuedate timestamp without time zone, p_bprint boolean, p_dprint timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_document_maintenance(INOUT p_irequestdocument integer, p_irequestdetailid integer, p_idocumentid integer, p_vfilename character varying, p_vfilepath character varying, p_dissuedate timestamp without time zone, p_bprint boolean, p_dprint timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure  save, edit and delete a Request Document';


--
-- TOC entry 343 (class 1255 OID 83440)
-- Name: usp_request_document_output(integer, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_document_output(p_ipaymentid integer, p_iinsertuserid integer, p_vinsertip character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of request document<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid          Id the table payment                            INPUT
 * @param p_iinsertuserid       User ID                                    	INPUT
 * @param p_vinsertip     	IP address user	     				INPUT
 * @return cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016<BR/> 
 */
declare p_sdocumenttypeid integer := 2402;
BEGIN

	INSERT INTO request_document( irequestdetailid,  idocumentid,  vfilename,  vfilepath, dissuedate, 
	bprint, dprint, sstatus, iinsertuserid,  dinsertdate, vinsertip)
	
	
	SELECT distinct rd.irequestdetailid, pd.idocumentid, null vfilename, null vfilepath, now() dissuedate, 
	false bprint, cast(null as timestamp) dprint, 1, p_iinsertuserid, now(), p_vinsertip
	FROM request r
	inner join request_detail rd on rd.irequestid = r.irequestid
	inner join product p on p.iproductid = rd.iproductid
	INNER JOIN product_document pd on rd.iproductid = pd.iproductid
	INNER JOIN document d on pd.idocumentid = d.idocumentid
	where r.sstatus != 5005 and rd.sstatus != 5005 and 
	d.sstatus = 1 and pd.sstatus = 1 and pd.sdocumenttypeid = p_sdocumenttypeid and r.ipaymentid = p_ipaymentid and 
	cast(r.irequestid as text) || rd.irequestdetailid || pd.idocumentid not in 
	(select cast(r.irequestid as text) || rd.irequestdetailid || rdd.idocumentid from request r 
	inner join request_detail rd on rd.irequestid = r.irequestid
	inner join request_document rdd on rdd.irequestdetailid = rd.irequestdetailid where r.ipaymentid = p_ipaymentid);
     
END;
$$;


--
-- TOC entry 2626 (class 0 OID 0)
-- Dependencies: 343
-- Name: FUNCTION usp_request_document_output(p_ipaymentid integer, p_iinsertuserid integer, p_vinsertip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_document_output(p_ipaymentid integer, p_iinsertuserid integer, p_vinsertip character varying) IS 'Stored procedure returns a list of request document outputs according to parameters entered';


--
-- TOC entry 344 (class 1255 OID 83441)
-- Name: usp_request_get(integer, smallint, integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_get(p_irequestid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
declare p_language integer := p_slanguageid % 140;
/**
 * Description: Stored procedure that returns a list of request<br />
 * Detailed explanation of the object.
 * @param p_irequestid   Id the table Request				                          INPUT
 * @param p_sstatus      Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000  INPUT
 * @param p_iproductid   Id tha table product                                                     INPUT
 * @param p_dstartdate   start date request                                                       INPUT
 * @param p_dfinishdate  finish date request                                                      INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN p_cursor FOR 
	(SELECT 
	      r.irequestid as irequestid,
	      rd.irequestdetailid as irequestdetailid,
	      r.ipartyid as ipartyid,
	      rd.ivehicleid as ivehicleid,
	      p.vfirstname,
	      pd.vdescription as vproduct,
	      v.vmodel,
	      cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying)  as vstatus,
	      r.dinsertdate       
       FROM public.request r
       LEFT JOIN request_detail rd on rd.irequestid=r.irequestid
       LEFT JOIN party p on p.ipartyid = r.ipartyid
       LEFT JOIN product pd on pd.iproductid = r.iproductid
       LEFT JOIN vehicle v on v.ivehicleid = rd.ivehicleid
       LEFT JOIN systemparameter sp on sp.iparameterid = r.sstatus and sp.igroupid = 7000
       where 
       (r.irequestid = p_irequestid or p_irequestid = 0) and
       (r.sstatus = p_sstatus or p_sstatus = 0) and 
       (r.iproductid = p_iproductid or p_iproductid = 0)and
       (r.dinsertdate between p_dstartdate and p_dfinishdate));
       
return (p_cursor);
end;
$$;


--
-- TOC entry 2627 (class 0 OID 0)
-- Dependencies: 344
-- Name: FUNCTION usp_request_get(p_irequestid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_get(p_irequestid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer) IS 'Stored procedure returns a list of request according to parameters entered';


--
-- TOC entry 345 (class 1255 OID 83442)
-- Name: usp_request_histo_maintenance(integer, integer, character varying, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_histo_maintenance(INOUT p_irequesthistoryid integer, p_irequestid integer, p_vobservation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a Request History<br />
 * Detailed explanation of the object.
 * @param p_irequesthistoryid        Id the table Request history                                         INPUT Y OUTPUT
 * @param p_irequestid               Id the table Request                                                 INPUT 
 * @param p_vobservation             observation request observation when the state is float              INPUT
 * @param p_sstatus                  Status Request systemparameter Group OPERATION_REQUESTSTATUS = 5000  INPUT
 * @param p_iinsertuserid 	     User ID                                                              INPUT 
 * @param p_vinsertip 		     IP address user		                                          INPUT
 * @param p_iupdateuserid 	     Updated user ID                                                      INPUT 
 * @param p_vupdateip 		     Update user IP                                                       INPUT
 * @param p_voption 		     Option INS= INSERT; UPD= UPDATE; DEL=DELETE                          INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
BEGIN
  IF p_vOption = 'INS' THEN  
	INSERT INTO public.request_history(
		  irequestid,vobservation,sstatus,iinsertuserid, 
		  dinsertdate,vinsertip)
        VALUES(
		  p_irequestid,p_vobservation,p_sstatus,p_iinsertuserid,
		  now(),p_vinsertip);
	  
    p_irequesthistoryid := (select currval('request_history_seq'));
  
  ELSIF p_vOption = 'UPD' THEN
	UPDATE public.request_history
	SET  
		irequestid=p_irequestid, 
		vobservation=p_vobservation, 
		sstatus=p_sstatus,  
		iupdateuserid=p_iupdateuserid, 
		dupdatedate=now(), 
		vupdateip=p_vupdateip
	WHERE irequesthistoryid=p_irequesthistoryid;


  ELSIF p_vOption = 'DEL' THEN  
        UPDATE public.request_history
	SET  
		sstatus=0,  
		iupdateuserid=p_iupdateuserid, 
		dupdatedate=now(), 
		vupdateip=p_vupdateip
	WHERE irequesthistoryid=p_irequesthistoryid;
  
  END IF;    
END;
$$;


--
-- TOC entry 2628 (class 0 OID 0)
-- Dependencies: 345
-- Name: FUNCTION usp_request_histo_maintenance(INOUT p_irequesthistoryid integer, p_irequestid integer, p_vobservation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_histo_maintenance(INOUT p_irequesthistoryid integer, p_irequestid integer, p_vobservation character varying, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure  save, edit and delete a Request History';


--
-- TOC entry 346 (class 1255 OID 83443)
-- Name: usp_request_history_get(integer, integer, timestamp without time zone, timestamp without time zone, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_history_get(p_ipartyid integer, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_vstatus character varying, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
declare p_language integer := p_slanguageid % 140;
/**
 * Description: Stored procedure returns a list of request history<br />
 * Detailed explanation of the object.
 * @param p_ipartyid     Id the table Party                                                          INPUT
 * @param p_sstatus      Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN p_cursor FOR 
	(
		select 
		r.irequestid,
		0 as irequestdetailid,
		r.ipartyid,
		r.iproductid,
		r.ipaymentid,
		('('|| p.vproductcode ||')'|| p.vdescription ||'  '||
		  COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')
		) as vdescription,
		pa.fpricetotal,
		(case when dfinishdate is null 
		then TO_TIMESTAMP(cast(r.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp 
		else TO_TIMESTAMP(cast(r.dfinishdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp end		
		)as dstartdate,
		r.sstatus,
		cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vstatus,
		r.iinsertuserid,
		COALESCE((select rd.ivehicleid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as ivehicleid,
		COALESCE((select rd.iownerid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as iownerid				
		from request r 		
		inner join product p on p.iproductid=r.iproductid
		inner join payment pa on pa.ipaymentid=r.ipaymentid
		inner join systemparameter sp on sp.iparameterid = r.sstatus	
		where 
		(p_ipartyid = 0 or r.ipartyid = p_ipartyid)
		and (p_iproductid = 0 or r.iproductid = p_iproductid)
		and r.sstatus in (select cast(regexp_split_to_table(p_vstatus, ',')as int)) --r.sstatus in(5002,5003)  --OPEN /CERRADO
		--and (p_sstatus = 0 or r.sstatus = p_sstatus)
		and (cast(p_dstartdate as date) <= cast(r.dstartdate as date) and cast(r.dstartdate as date) <= cast(p_dfinishdate as date))
		order by TO_TIMESTAMP(cast(r.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp desc
	);      
return (p_cursor);
end;
$$;


--
-- TOC entry 347 (class 1255 OID 83444)
-- Name: usp_request_information(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_information(p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of request <br />
 * Detailed explanation of the object.
 * @param p_scountryid          	It lets you search for primary key of country.
 * @return ref_cursor			stores data to return in a cursor
 * @author  rpaucar
 * @version 1.0 rpaucar 05/08/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
BEGIN
      open ref_cursor for 
      select 
	   rq.sstatus status,
	   paym.vreceiptnumber patmentnumber,
	   par.vdocumentnumber partdocumnumber,
	   pro.vdescription prodescription,
	   prst.vdescription prodstep_description
        from request rq 
        inner join payment paym on rq.ipaymentid = paym.ipaymentid
        inner join party par on rq.ipartyid = par.ipartyid
        inner join product pro on rq.iproductid = pro.iproductid
        left join product_step prst on rq.iproductstepid = prst.iproductstepid
        where 
	pro.iproductid = p_iproductid;
      RETURN (ref_cursor);  
END;
$$;


--
-- TOC entry 2629 (class 0 OID 0)
-- Dependencies: 347
-- Name: FUNCTION usp_request_information(p_iproductid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_information(p_iproductid integer) IS 'Stored procedure returns a list of request according to parameters entered';


--
-- TOC entry 348 (class 1255 OID 83445)
-- Name: usp_request_license_maintenance(integer, smallint, smallint, timestamp without time zone, timestamp without time zone, timestamp without time zone, timestamp without time zone, character varying, smallint, character varying, character varying, character varying, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_license_maintenance(INOUT p_irequestlicenseid integer, p_slicensetypeid smallint, p_sdurationlicense smallint, p_dstartdate timestamp without time zone, p_dexpirydate timestamp without time zone, p_dnewstartdate timestamp without time zone, p_dnewenddate timestamp without time zone, p_vnumberlicense character varying, p_splatetypeid smallint, p_vnumberplate character varying, p_vplatepreview character varying, p_vcomment character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a license <br />
 * Detailed explanation of the object.
 * @param p_irequestlicenseid  Primary key
 * @param p_slicensetypeid     Type of license
 * @param p_dstartdate         Start Date.
 * @param p_dexpirydate        Expiry Date.
 * @param p_vnumberlicense     Number License.
 * @param p_splatetypeid       Plate Type.
 * @param p_vnumberplate       Number Plate.
 * @param p_vplatepreview      Plate Preview
 * @param p_vcomment	       Comment	
 * @param p_sstatus            Status of license.
 * @param p_iinsertuserid      User ID.
 * @param p_vinsertip          IP address user.
 * @param p_iupdateuserid      Update user ID.
 * @param p_vupdateip          Update user IP.
 * @param p_voption            Option.
 * @return Save, edit and delete a license
 * @author  stello
 * @version 1.0 stello 15/08/2016<BR/> 
 * @version 2.0 stello 23/08/2016<BR/> Se añadio el campo vcomment 
 */

    IF p_vOption = 'INS' THEN
	
	  INSERT INTO
	    request_license
	    (
	      slicensetypeid,
	      sdurationlicense,
	      dstartdate,
	      dexpirydate,
	      vnumberlicense,
	      splatetypeid,
	      vnumberplate,
	      vplatepreview,
	      vcomment,
	      sstatus,
	      iinsertuserid,
	      dinsertdate,
	      vinsertip
	    )
	    VALUES
	    (
	      p_slicensetypeid,
	      p_sdurationlicense,
	      p_dstartdate,
	      p_dexpirydate,
	      p_vnumberlicense,
	      p_splatetypeid,
	      p_vnumberplate,
	      p_vplatepreview,
	      p_vcomment,
	      p_sstatus,
	      p_iinsertuserid,
	      now(),
	      p_vinsertip
	    );
	p_irequestlicenseid := (select currval('request_license_seq'));

         ELSIF p_vOption = 'UPD' THEN

         UPDATE request_license SET 
	      slicensetypeid = COALESCE(p_slicensetypeid,slicensetypeid),
	      sdurationlicense = COALESCE(p_sdurationlicense,sdurationlicense),
	      dstartdate = COALESCE(p_dstartdate,dstartdate),
	      dexpirydate = COALESCE(p_dexpirydate,dexpirydate),	           
	      vnumberlicense = COALESCE(p_vnumberlicense,vnumberlicense),
	      splatetypeid = COALESCE(p_splatetypeid,splatetypeid),
	      vnumberplate = COALESCE(p_vnumberplate,vnumberplate),
	      vplatepreview = COALESCE(p_vplatepreview,vplatepreview),
	      vcomment = COALESCE(p_vcomment,vcomment),
	      sstatus = COALESCE(case when p_sstatus=0 then sstatus else p_sstatus end,sstatus),
	      iupdateuserid = COALESCE(p_iinsertuserid,iupdateuserid),
	      dupdatedate = now(),
              vupdateip = COALESCE(p_vinsertip,vupdateip),
              dnewstartdate=COALESCE(p_dnewstartdate,dnewstartdate),
	      dnewenddate=COALESCE(p_dnewenddate,dnewenddate)
	WHERE irequestlicenseid = p_irequestlicenseid; 


	ELSIF p_vOption = 'DEL'
	    THEN 
	     UPDATE request_license
		    SET
		      sstatus = p_sstatus,
		      iupdateuserid = p_iupdateuserid,
		      dupdatedate = now(),
		      vupdateip = p_vupdateip
		    WHERE irequestlicenseid = p_irequestlicenseid; 

END IF;
END;
$$;


--
-- TOC entry 2630 (class 0 OID 0)
-- Dependencies: 348
-- Name: FUNCTION usp_request_license_maintenance(INOUT p_irequestlicenseid integer, p_slicensetypeid smallint, p_sdurationlicense smallint, p_dstartdate timestamp without time zone, p_dexpirydate timestamp without time zone, p_dnewstartdate timestamp without time zone, p_dnewenddate timestamp without time zone, p_vnumberlicense character varying, p_splatetypeid smallint, p_vnumberplate character varying, p_vplatepreview character varying, p_vcomment character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_request_license_maintenance(INOUT p_irequestlicenseid integer, p_slicensetypeid smallint, p_sdurationlicense smallint, p_dstartdate timestamp without time zone, p_dexpirydate timestamp without time zone, p_dnewstartdate timestamp without time zone, p_dnewenddate timestamp without time zone, p_vnumberlicense character varying, p_splatetypeid smallint, p_vnumberplate character varying, p_vplatepreview character varying, p_vcomment character varying, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that save, edit and delete a license';


--
-- TOC entry 349 (class 1255 OID 83446)
-- Name: usp_request_maintenance(integer, integer, integer, integer, integer, boolean, smallint, timestamp without time zone, timestamp without time zone, integer, boolean, integer, character varying, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_maintenance(INOUT p_irequestid integer, p_ipaymentid integer, p_iproductid integer, p_ipartyid integer, p_ireferencerequestid integer, p_bterminate boolean, p_sstatus smallint, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_itramitadorid integer, p_bconformity boolean, p_iuserfirm integer, p_vtabname character varying, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
/**
 * Description: Stored procedure  save, edit and delete a Request<br />
 * Detailed explanation of the object.
 * @param p_irequestid 			Id the table Request                                                       INPUT Y OUTPUT
 * @param p_ipaymentid 			Id the table Payment                                                       INPUT
 * @param p_iproductid 			Id the table Product                                                       INPUT
 * @param p_ipartyid 			Id the table Party                                                         INPUT
 * @param p_ireferencerequestid 	Id the table reference Request                                             INPUT
 * @param p_sstatus 			Status Request systemparameter Group OPERATION_REQUESTSTATUS = 5000        INPUT
 * @param p_dstartdate 	                start date request                                                         INPUT
 * @param p_dfinishdate                 finish date request 
 * @param p_itramitadorid               Id the table Party  (Tramitador)
 * @param p_iinsertuserid 		User ID                                                                    INPUT 
 * @param p_vinsertip 		        IP address user		                                                   INPUT
 * @param p_iupdateuserid 		Updated user ID                                                            INPUT 
 * @param p_vupdateip 		        Update user IP                                                             INPUT
 * @param p_voption 			Option INS= INSERT; UPD= UPDATE; DEL=DELETE                                INPUT
 * @return Number
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */

DECLARE v_ireferencerequestid INTEGER := 0;
BEGIN
      
  IF p_vOption = 'INS' THEN  
	INSERT INTO public.request(ipaymentid, ipartyid, iproductid, ireferencerequestid, dstartdate, bterminate, itramitadorid, bconformity, iuserfirm, vtabname, sstatus, iinsertuserid,dinsertdate,vinsertip)
	VALUES (p_ipaymentid, p_ipartyid, p_iproductid, p_ireferencerequestid, now(), p_bterminate, p_itramitadorid, false, null, p_vtabname, p_sstatus, p_iinsertuserid, now(), p_vinsertip);
	        
	p_irequestid := (select currval('request_seq'));

	--if ((select count(pc.icomponentid) from product p left join product_composition pc on pc.iproductid=p.iproductid where pc.iproductid=p_iproductid)>0) then
	--     INSERT INTO public.request_detail(irequestid,iproductid,sstatus,iinsertuserid,dinsertdate,vinsertip)
	--                select  p_irequestid,pc.icomponentid,p_sstatus,p_iinsertuserid,now(),p_vinsertip  from product p  
	--		left join product_composition pc on pc.iproductid=p.iproductid 
	--		where pc.iproductid=p_iproductid and pc.bvisible=true and pc.sstatus=1 and pc.boptional=false
	--		order by pc.sorder;
	--else 
	--		INSERT INTO public.request_detail(irequestid,iproductid,sstatus,iinsertuserid,dinsertdate,vinsertip)
	--		values(p_irequestid,p_iproductid,p_sstatus,p_iinsertuserid,now(),p_vinsertip);
	--end if;
  
ELSIF p_vOption = 'UPD' THEN
begin
	UPDATE public.request
	SET 
	   --ipaymentid=COALESCE(p_ipaymentid,ipaymentid), 
	   --ipartyid=COALESCE(p_ipartyid,ipartyid), 
	   --itramitadorid=COALESCE(p_itramitadorid,itramitadorid), 
	   --iproductid=COALESCE(p_iproductid,iproductid), 
	   --ireferencerequestid=COALESCE(p_ireferencerequestid,ireferencerequestid), 
	   bterminate=COALESCE(p_bterminate, bterminate),
	   bconformity=COALESCE(p_bconformity, bconformity),
	   iuserfirm=COALESCE(p_iuserfirm, iuserfirm),
	   dfinishdate=now(),
	   vtabname=COALESCE(p_vtabname, vtabname),
	   sstatus=COALESCE(case when p_sstatus=0 then sstatus else p_sstatus end,sstatus),
	   iupdateuserid=COALESCE(p_iinsertuserid,iupdateuserid),
	   dupdatedate=now(),
	   vupdateip=COALESCE(p_vinsertip,vupdateip)
	 WHERE irequestid=p_irequestid;
		
	SELECT ireferencerequestid INTO v_ireferencerequestid FROM request WHERE irequestid = p_irequestid LIMIT 1;

	IF v_ireferencerequestid != 0 THEN
		UPDATE public.request SET 
		sstatus=COALESCE(case when p_sstatus=0 then sstatus else p_sstatus end,sstatus)  
		WHERE irequestid = v_ireferencerequestid;
	END IF;
	--UPDATE request_detail
	--SET 
	   --sstatus = p_sstatus,
	   --iupdateuserid=p_iinsertuserid, 
	   --dupdatedate=now(), 
	   --vupdateip=p_vinsertip 
	--WHERE irequestid = p_irequestid;
end;
ELSIF p_vOption = 'DEL' THEN  
begin
    UPDATE REQUEST
    SET 
	sstatus = p_sstatus,
        iupdateuserid=p_iinsertuserid, 
	dupdatedate=now(), 
	vupdateip=p_vinsertip 
    WHERE irequestid = p_irequestid;

    UPDATE request_detail
    SET 
	sstatus = p_sstatus,
        iupdateuserid=p_iinsertuserid, 
	dupdatedate=now(), 
	vupdateip=p_vinsertip 
    WHERE irequestid = p_irequestid;    
end;
END IF;    
END;
$$;


--
-- TOC entry 350 (class 1255 OID 83448)
-- Name: usp_request_party_search(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_party_search(p_irequestid integer, p_iproductid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare ref_cursor REFCURSOR := 'ref_cursor';

begin
 /**
 * @param p_irequestid 
 * @param p_iproductid 
 * @return array de party's.
 * @author  rpaucar
 * @version 1.0 rpaucar 24/09/2016<BR/> 
 */

create temp table tbltmp_reqdetail (irequestid integer, iownerid integer) on commit drop;
INSERT INTO tbltmp_reqdetail 
select irequestid,iownerid from request_detail
where irequestid = p_irequestid limit 1;
 
open ref_cursor for
	select distinct p1.ipartyid,
	CASE WHEN COALESCE(P1.vorganization, '') = '' THEN COALESCE(P1.vlastname, '') || ' ' ||  COALESCE(P1.vfirstname, '') || ' ' || COALESCE(P1.vmiddlename, '') || ' ' || COALESCE(P1.vmaidenname,'') ELSE P1.vorganization END vnameparty,
	p2.ipartyid itramitadorid,
	CASE WHEN COALESCE(P2.vorganization, '') = '' THEN COALESCE(P2.vlastname, '') || ' ' ||  COALESCE(P2.vfirstname, '') || ' ' || COALESCE(P2.vmiddlename, '') || ' ' || COALESCE(P2.vmaidenname,'') ELSE P2.vorganization END vnamepartyTra,
	p3.ipartyid irequesterid,
	CASE WHEN COALESCE(p3.vorganization, '') = '' THEN COALESCE(p3.vlastname, '') || ' ' ||  COALESCE(p3.vfirstname, '') || ' ' || COALESCE(p3.vmiddlename, '') || ' ' || COALESCE(p3.vmaidenname,'') ELSE p3.vorganization END vnamerequester
	from request r
	inner join party P1 on p1.ipartyid = r.ipartyid
	inner join tbltmp_reqdetail tr on tr.irequestid = r.irequestid
	left join party p2 on p2.ipartyid = tr.iownerid
	left join party p3 on p3.ipartyid = r.itramitadorid
	inner join product pr on pr.iproductid = r.iproductid
	where r.iproductid= p_iproductid and r.irequestid = p_irequestid;
return (ref_cursor);
end;
$$;


--
-- TOC entry 351 (class 1255 OID 83449)
-- Name: usp_request_product_get(integer, smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_product_get(p_ipaymentid integer, p_sstatus smallint) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure returns a list of request product<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid       Id the table Payment                                                        INPUT
 * @param p_sstatus          Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(
	SELECT
	0 as pack,
	r.irequestid,
        r.iproductid, 
        ('('|| pro.vproductcode ||') '||pro.vdescription ||' '|| 
	COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')
        ) as vdescription,
        pro.vproductcode,     
        array_to_string(ARRAY(
        SELECT rd.irequestdetailid 
        FROM request_detail rd 
            WHERE rd.irequestid = r.irequestid 
            ORDER BY rd.irequestdetailid) ,'|') As vrequestdetailid,
        array_to_string(ARRAY(SELECT rd.iproductid 
        FROM request_detail rd 
            WHERE rd.irequestid = r.irequestid 
            ORDER BY rd.irequestdetailid) ,'|') As vproductid,
        (SELECT case when sum(pp.fpricetotal) is null then 0 else sum(pp.fpricetotal) end        
        FROM request_detail rd 
        LEFT JOIN product_pricing pp on  pp.ipricingid=rd.ipricingid and pp.iproductid=rd.iproductid
        WHERE rd.irequestid = r.irequestid) as fpricetotal,	
        (select count(pc.iproductcompositionid) from product_composition pc where pc.iproductid=pro.iproductid) as cantidad,
        pro.bauthorization,
        pro.bvisible,
        pro.bconformity,
	pro.bfloating,
	false as boptional,
	COALESCE(r.bterminate,null) as bterminate,
	pro.sstatus,
	r.sstatus as statusrequest,
	COALESCE((SELECT rd2.vjson from request_detail rd2 WHERE rd2.irequestid = r.irequestid   and r.iproductid=rd2.iproductid limit 1),'') as vjson,
	COALESCE ((SELECT rd2.sauthorization FROM request_detail rd2 WHERE rd2.irequestid = r.irequestid AND r.iproductid = rd2.iproductid LIMIT 1),0) as sauthorization,
	r.ipaymentid
	FROM request r
        LEFT JOIN product pro on pro.iproductid=r.iproductid
        WHERE (p_sstatus = 0 OR r.sstatus=p_sstatus)
		and (r.sstatus!=5005)
		and r.ipaymentid=p_ipaymentid
        
	union
	
	select 
	r.iproductid as pack,
	r.irequestid,
	rd.iproductid,
	('('|| pro.vproductcode ||') '||pro.vdescription) as vdescription,
        pro.vproductcode,
        cast(rd.irequestdetailid as text) as vrequestdetailid,
        cast(rd.iproductid as text) as vproductid,
        case when pp.fpricetotal is null then 0 else pp.fpricetotal end as fpricetotal,
        0 as cantidad,
        pro.bauthorization,
        pro.bvisible,
        pro.bconformity,
	pro.bfloating,
	pc.boptional as boptional,
	COALESCE(r.bterminate,null) as bterminate,
	pro.sstatus,
	rd.sstatus as statusrequest,
	rd.vjson as vjson,
	rd.sauthorization as sauthorization,
	r.ipaymentid
	from request_detail rd
	left join product_pricing pp on  pp.ipricingid=rd.ipricingid and pp.iproductid=rd.iproductid
	inner join product pro on pro.iproductid=rd.iproductid
	left join  product_composition pc on pc.icomponentid=pro.iproductid 
	inner join request r on r.irequestid=rd.irequestid and pc.iproductid = r.iproductid
	where (p_sstatus = 0 OR r.sstatus=p_sstatus) 
		and (r.sstatus!=5005)
		and r.ipaymentid = p_ipaymentid and r.iproductid !=rd.iproductid
	order by irequestid,pack,vrequestdetailid
        );
return (p_cursor);
end;
$$;


--
-- TOC entry 352 (class 1255 OID 83450)
-- Name: usp_request_status_case_get(integer, smallint, integer, timestamp without time zone, timestamp without time zone, integer, smallint, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_status_case_get(p_ipartyid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_userid integer, p_slicensetypeid smallint, p_vnumberplate character varying, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_language integer := p_slanguageid % 140;
/**
 * Description: Stored procedure returns a list of request history<br />
 * Detailed explanation of the object.
 * @param p_ipartyid        Id the table Party                                                         INPUT
 * @param p_sstatus        Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @param p_dstartdate     start date request  
 * @param p_dfinishdate    finish date request  
 * @return cursor
 * @author  stello
 * @version 1.0 stello 31/08/2016<BR/> 
 */
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

create temp table tbltmp_requestlicense (irequestlicenseid integer, irequestid integer, irequestdetailid integer, 
slicensetypeid smallint, vnumberplate character varying(12))on commit drop;

INSERT INTO tbltmp_requestlicense 
select rd.irequestlicenseid, rd.irequestid, rd.irequestdetailid, rl.slicensetypeid, rl.vnumberplate 
from request r inner join request_detail rd
on r.irequestid = rd.irequestid inner join request_license rl
on rl.irequestlicenseid = rd.irequestlicenseid
where (r.dinsertdate between p_dstartdate and p_dfinishdate); 


	OPEN ref_cursor FOR 
	(
	select data.irequestid, data.ipartyid, data.iproductid, data.ipaymentid, data.vdescription, data.fpricetotal, 
	data.dstartdate, data.sstatus, data.vstatus, data.iinsertuserid, data.ivehicleid, data.vorganization, data.vname, data.vproductcode, 
	data.vtabname, data.vstatusname, data.irequestdetailid, data.snotesubcategoryid, data.vobservationnote, data.iownerid, data.sstatuspayment from (
		select 
		r.irequestid,
		--0 as irequestdetailid,
		r.ipartyid,
		r.iproductid,
		r.ipaymentid,
		('('|| p.vproductcode ||')'|| p.vdescription ||'  '||
		  COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')
		) as vdescription,
		pa.fpricetotal,
		/*(case when dfinishdate is null 
		then TO_TIMESTAMP(cast(r.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp 
		else TO_TIMESTAMP(cast(r.dfinishdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp end		
		)as dstartdate,*/
		COALESCE((select TO_TIMESTAMP(cast(no.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp from request_detail rd 
						inner join note no on 
						no.irequestdetailid = rd.irequestdetailid
						where rd.irequestid = r.irequestid 
						   AND no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid) 
						limit 1),(CASE WHEN r.dupdatedate is null then 
			COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
			else 
			COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
		end))	as dstartdate, --muestra la ultima fecha de la nota
		r.sstatus,
		cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vstatus,
		r.iinsertuserid,
		COALESCE((select rd.ivehicleid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as ivehicleid,
		par.vorganization,
		CASE WHEN COALESCE(par.vorganization, '') = '' THEN COALESCE(par.vlastname, '') || ' ' ||  COALESCE(par.vfirstname, '') || ' ' || COALESCE(par.vmiddlename, '') || ' ' || COALESCE(par.vmaidenname,'') ELSE par.vorganization END vname,
		p.vproductcode,
		COALESCE((select no.vtabname from request_detail rd 
						inner join note no on 
						no.irequestdetailid = rd.irequestdetailid
						where rd.irequestid = r.irequestid 
						   AND no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid) 
						   order by no.dinsertdate desc
						limit 1),(r.vtabname))	as vtabname, --muestra el ultimo tab donde se quedo
		cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vstatusname,
		COALESCE((select rd.irequestdetailid from request_detail rd 
						inner join note no on 
						no.irequestdetailid = rd.irequestdetailid
						where rd.irequestid = r.irequestid 
						   AND no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid) 
						   order by no.dinsertdate desc
						limit 1),COALESCE((select rd.irequestdetailid from request_detail rd 
						where rd.irequestid = r.irequestid 
						limit 1),0)
						)	as irequestdetailid, --muestra el ultimo tab donde se quedo   
		COALESCE((select no.snotesubcategoryid from request_detail rd 
						inner join note no on 
						no.irequestdetailid = rd.irequestdetailid
						where rd.irequestid = r.irequestid 
						   AND no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid) 
						   order by no.dinsertdate desc
						limit 1),0)	as snotesubcategoryid, --muestra la categoria de la nota
		COALESCE((select no.vobservation from request_detail rd 
						inner join note no on 
						no.irequestdetailid = rd.irequestdetailid
						where rd.irequestid = r.irequestid 
						   AND no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid) 
						   order by no.dinsertdate desc
						limit 1),'')	as vobservationnote,
						COALESCE((select rd.iownerid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as iownerid,
		pa.sstatus as sstatuspayment						
		from request r 		
		inner join product p on p.iproductid=r.iproductid
		inner join payment pa on pa.ipaymentid=r.ipaymentid
		inner join systemparameter sp on sp.iparameterid= r.sstatus 
		inner join systemparameter sp1 on sp1.iparameterid = r.sstatus and sp1.igroupid = 5000
		inner join party par on par.ipartyid = r.ipartyid
		left join tbltmp_requestlicense trl on trl.irequestid = r.irequestid 
		where (p_ipartyid = 0 OR r.ipartyid=p_ipartyid)
		AND (p_sstatus = 0 OR r.sstatus = p_sstatus)
		AND (p_iproductid = 0 OR p.iproductid = p_iproductid)
		--AND (r.dinsertdate between p_dstartdate and p_dfinishdate) and
		AND (r.dinsertdate between p_dstartdate and p_dfinishdate) and
		(p_userid=0 or r.iinsertuserid=p_userid) and 
		(p_slicensetypeid=0 or trl.slicensetypeid=p_slicensetypeid) and
		(p_vnumberplate='' or trl.vnumberplate=p_vnumberplate) and
		p.vproductcode not in('PA01','PA02')
		) as data --where data.dstartdate is not null
		--order by TO_TIMESTAMP(cast(data.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp desc
	);      
return (ref_cursor);
end;
$$;


--
-- TOC entry 353 (class 1255 OID 83452)
-- Name: usp_request_status_menu_get(integer, smallint, integer, timestamp without time zone, timestamp without time zone, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_status_menu_get(p_ipartyid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_userid integer, p_irequestid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_language integer := (case when p_slanguageid is null or p_slanguageid = 0 then 1 else (p_slanguageid % 140) end);
declare p_cantidad integer := 10;
declare p_bnow boolean := (TO_TIMESTAMP(cast(p_dstartdate as text), 'YYYY/MM/DD') = TO_TIMESTAMP(cast(p_dfinishdate as text), 'YYYY/MM/DD'));
/**
 * Description: Stored procedure returns a list of request history<br />
 * Detailed explanation of the object.
 * @param p_ipartyid        Id the table Party                                                         INPUT
 * @param p_sstatus        Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @param p_dstartdate     start date request  
 * @param p_dfinishdate    finish date request  
 * @return cursor
 * @author  stello
 * @version 1.0 stello 31/08/2016<BR/> 
 */
begin

--IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

create temp table tbltmp_note (dinsertdate timestamp without time zone, inoteid integer, vtabname character varying(100), 
irequestdetailid integer, snotesubcategoryid smallint, vobservation character varying(300),irequestid integer) on commit drop;

create temp table tbltmp_request (roww integer, irequestid integer, ipartyid integer, iproductid integer, ipaymentid integer, vdescription text, 
fpricetotal double precision, dstartdate timestamp, sstatus smallint, vstatus character varying, iinsertuserid integer, ivehicleid integer, vorganization character varying,
vname character varying, vproductcode character varying, vtabname character varying, irequestdetailid integer, snotesubcategoryid integer, 
vobservationnote character varying, datestartrequest timestamp, iownerid integer, sstatuspayment smallint, ireferencerequestid integer) on commit drop;

if p_bnow = true then
	INSERT INTO tbltmp_note
	select x.dinsertdate, x.inoteid, x.vtabname, x.irequestdetailid, x.snotesubcategoryid, x.vobservation, x.irequestid from
	(select ROW_NUMBER() OVER (PARTITION BY r.sstatus ORDER BY r.dstartdate desc) AS r,
	no.dinsertdate, no.inoteid, no.vtabname, no.irequestdetailid, no.snotesubcategoryid, no.vobservation, r.irequestid
	from note no 
	inner join request_detail rd on no.irequestdetailid = rd.irequestdetailid
	inner join request r on r.irequestid = rd.irequestid	
	where 
	--no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid order by no.dinsertdate desc) and 
	no.dinsertdate = (select no1.dinsertdate from note no1 where no1.irequestdetailid = no.irequestdetailid order by no.dinsertdate, no1.dinsertdate desc limit 1) and 
	(CASE WHEN r.dupdatedate is null then (r.dinsertdate::date = p_dstartdate::date) else (r.dupdatedate::date = p_dstartdate::date) end)

	--*****(CASE WHEN r.dupdatedate is null then (r.dinsertdate::date = p_dstartdate::date) else (r.dupdatedate::date = p_dstartdate::date) end)
	--(case when p_bnow 
	--then (CASE WHEN r.dupdatedate is null then (r.dinsertdate::date = p_dstartdate::date) else (r.dupdatedate::date = p_dstartdate::date) end)
	--else (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	--end)
	) x
	where x.r<= (p_cantidad * 2);

	INSERT INTO tbltmp_request
	select x.r, x.irequestid, x.ipartyid, x.iproductid, x.ipaymentid, x.vdescription, x.fpricetotal, 
	x.dstartdate, x.sstatus, x.vstatus, x.iinsertuserid, x.ivehicleid, x.vorganization, x.vname, x.vproductcode, x.vtabname, x.irequestdetailid, 
	x.snotesubcategoryid, x.vobservationnote, x.datestartrequest, x.iownerid, x.sstatuspayment, x.ireferencerequestid
	FROM (
	select ROW_NUMBER() OVER (PARTITION BY r.sstatus ORDER BY r.dstartdate desc) AS r,
	r.irequestid, --0 as irequestdetailid,
	r.ipartyid,
	r.iproductid,
	r.ipaymentid,
	('('|| p.vproductcode ||')'|| p.vdescription ||'  '|| COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')) as vdescription,
	pa.fpricetotal,
	COALESCE(no.dinsertdate,(CASE WHEN r.dupdatedate is null then COALESCE(r.dinsertdate, null) else COALESCE(r.dupdatedate, null) end)) as dstartdate,
	--COALESCE((TO_TIMESTAMP(cast(no.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),(CASE WHEN r.dupdatedate is null 
	--then COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
	--else COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
	--end)) as dstartdate, --muestra la ultima fecha de la nota					
	r.sstatus,
	cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vstatus,--p_language
	r.iinsertuserid,
	COALESCE((select rd.ivehicleid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as ivehicleid,
	par.vorganization,
	(case when par.vorganization is null then (par.vfirstname || ' ' || par.vlastname) else par.vorganization end) as vname,
	p.vproductcode,
	COALESCE(no.vtabname,r.vtabname) as vtabname, --muestra el ultimo tab donde se quedo
	--r.vtabname as vtabname, --muestra el ultimo tab donde se quedo
	COALESCE(no.irequestdetailid,COALESCE((select rd.irequestdetailid from request_detail rd 
	where rd.irequestid = r.irequestid limit 1),0)) as irequestdetailid, --muestra el ultimo tab donde se quedo
	COALESCE(no.snotesubcategoryid,0) as snotesubcategoryid, --muestra la categoria de la nota
	COALESCE(no.vobservation,'') as vobservationnote,
	(CASE WHEN r.dupdatedate is null then COALESCE(r.dinsertdate, null) else COALESCE(r.dupdatedate, null) end) as datestartrequest,
	--(CASE WHEN r.dupdatedate is null 
	--then COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp), null) 
	--else COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp), null)	
	--end)as datestartrequest,
	COALESCE((select rd.iownerid from request_detail rd where rd.irequestid = r.irequestid limit 1), 0) as iownerid,
	pa.sstatus as sstatuspayment,
	r.ireferencerequestid
	from request r 	
	left join tbltmp_note no on r.irequestid = no.irequestid	
	inner join product p on p.iproductid = r.iproductid
	inner join payment pa on pa.ipaymentid = r.ipaymentid
	inner join systemparameter sp on sp.iparameterid = r.sstatus
	inner join party par on par.ipartyid = r.ipartyid
	where (p_ipartyid = 0 OR r.ipartyid = p_ipartyid)
	AND (p_sstatus = 0 OR r.sstatus = p_sstatus)
	AND (p_iproductid = 0 OR p.iproductid = p_iproductid) 
	AND (CASE WHEN r.dupdatedate is null then (r.dinsertdate::date = p_dstartdate::date) else (r.dupdatedate::date = p_dstartdate::date) end)
	--AND (case when p_bnow 
	--then (CASE WHEN r.dupdatedate is null then (r.dinsertdate::date = p_dstartdate::date) else (r.dupdatedate::date = p_dstartdate::date) end)
	--else (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	--end)
	--AND (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	AND (p_userid = 0 or r.iinsertuserid = p_userid)
	AND (p_irequestid = 0 or r.irequestid = p_irequestid)
	AND r.sstatus != 5005
	AND p.vproductcode not in ('PA01','PA02')
	) x
	WHERE x.r <= (p_cantidad * 2);
else
	INSERT INTO tbltmp_note
	select x.dinsertdate, x.inoteid, x.vtabname, x.irequestdetailid, x.snotesubcategoryid, x.vobservation, x.irequestid from
	(select ROW_NUMBER() OVER (PARTITION BY r.sstatus ORDER BY r.dstartdate desc) AS r,
	no.dinsertdate, no.inoteid, no.vtabname, no.irequestdetailid, no.snotesubcategoryid, no.vobservation, r.irequestid
	from note no 
	inner join request_detail rd on no.irequestdetailid = rd.irequestdetailid
	inner join request r on r.irequestid = rd.irequestid	
	where 
	--no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid order by no.dinsertdate desc) and 
	no.dinsertdate = (select no1.dinsertdate from note no1 where no1.irequestdetailid = no.irequestdetailid order by no.dinsertdate, no1.dinsertdate desc limit 1) and 
	(CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	) x
	where x.r<= (p_cantidad * 2);

	INSERT INTO tbltmp_request
	select x.r, x.irequestid, x.ipartyid, x.iproductid, x.ipaymentid, x.vdescription, x.fpricetotal, 
	x.dstartdate, x.sstatus, x.vstatus, x.iinsertuserid, x.ivehicleid, x.vorganization, x.vname, x.vproductcode, x.vtabname, x.irequestdetailid, 
	x.snotesubcategoryid, x.vobservationnote, x.datestartrequest, x.iownerid, x.sstatuspayment, x.ireferencerequestid
	FROM (
	select ROW_NUMBER() OVER (PARTITION BY r.sstatus ORDER BY r.dstartdate desc) AS r,
	r.irequestid, --0 as irequestdetailid,
	r.ipartyid,
	r.iproductid,
	r.ipaymentid,
	('('|| p.vproductcode ||')'|| p.vdescription ||'  '|| COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')) as vdescription,
	pa.fpricetotal,
	COALESCE(no.dinsertdate,(CASE WHEN r.dupdatedate is null then COALESCE(r.dinsertdate, null) else COALESCE(r.dupdatedate, null) end)) as dstartdate,
	--COALESCE((TO_TIMESTAMP(cast(no.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),(CASE WHEN r.dupdatedate is null 
	--then COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
	--else COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
	--end)) as dstartdate, --muestra la ultima fecha de la nota					
	r.sstatus,
	cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vstatus,--p_language
	r.iinsertuserid,
	COALESCE((select rd.ivehicleid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as ivehicleid,
	par.vorganization,
	(case when par.vorganization is null then (par.vfirstname || ' ' || par.vlastname) else par.vorganization end) as vname,
	p.vproductcode,
	COALESCE(no.vtabname,r.vtabname) as vtabname, --muestra el ultimo tab donde se quedo
	--r.vtabname as vtabname, --muestra el ultimo tab donde se quedo
	COALESCE(no.irequestdetailid,COALESCE((select rd.irequestdetailid from request_detail rd 
	where rd.irequestid = r.irequestid limit 1),0)) as irequestdetailid, --muestra el ultimo tab donde se quedo
	COALESCE(no.snotesubcategoryid,0) as snotesubcategoryid, --muestra la categoria de la nota
	COALESCE(no.vobservation,'') as vobservationnote,
	(CASE WHEN r.dupdatedate is null then COALESCE(r.dinsertdate, null) else COALESCE(r.dupdatedate, null) end) as datestartrequest,
	--(CASE WHEN r.dupdatedate is null 
	--then COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp), null) 
	--else COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp), null)	
	--end)as datestartrequest,
	COALESCE((select rd.iownerid from request_detail rd where rd.irequestid = r.irequestid limit 1), 0) as iownerid,
	pa.sstatus as sstatuspayment,
	r.ireferencerequestid
	from request r 	
	left join tbltmp_note no on r.irequestid = no.irequestid	
	inner join product p on p.iproductid = r.iproductid
	inner join payment pa on pa.ipaymentid = r.ipaymentid
	inner join systemparameter sp on sp.iparameterid = r.sstatus
	inner join party par on par.ipartyid = r.ipartyid
	where (p_ipartyid = 0 OR r.ipartyid = p_ipartyid)
	AND (p_sstatus = 0 OR r.sstatus = p_sstatus)
	AND (p_iproductid = 0 OR p.iproductid = p_iproductid) 
	AND (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	--AND (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else (r.dupdatedate between p_dstartdate and p_dfinishdate) end)
	AND (p_userid = 0 or r.iinsertuserid = p_userid)
	AND (p_irequestid = 0 or r.irequestid = p_irequestid)
	AND r.sstatus != 5005
	AND p.vproductcode not in ('PA01','PA02')
	) x
	WHERE x.r <= (p_cantidad * 2);
end if;



delete FROM tbltmp_request where --sstatus = 5001 and 	PENDING , PERO CON CLOSED CREO QUE TMB PREGUNTAR A SEBASTIAN
irequestid in (select xx.ireferencerequestid from tbltmp_request xx where xx.ireferencerequestid != 0 and xx.ireferencerequestid is not null);

OPEN ref_cursor FOR 
(
SELECT x.r, x.irequestid, x.ipartyid, x.iproductid, x.ipaymentid, x.vdescription, x.fpricetotal, 
x.dstartdate, x.sstatus, x.vstatus, x.iinsertuserid, x.ivehicleid, x.vorganization, x.vname, x.vproductcode, 
x.vtabname, x.irequestdetailid, x.snotesubcategoryid, x.vobservationnote, x.datestartrequest, x.iownerid, x.sstatuspayment FROM (
	select 
	ROW_NUMBER() OVER (PARTITION BY tr.sstatus ORDER BY tr.roww asc) AS r,
	tr.irequestid, tr.ipartyid, tr.iproductid, tr.ipaymentid, tr.vdescription, tr.fpricetotal, 
	tr.dstartdate, tr.sstatus, tr.vstatus, tr.iinsertuserid, tr.ivehicleid, tr.vorganization, tr.vname, tr.vproductcode, 
	tr.vtabname, tr.irequestdetailid, tr.snotesubcategoryid, tr.vobservationnote, tr.datestartrequest, tr.iownerid, tr.sstatuspayment
	from tbltmp_request tr
	order by tr.dstartdate desc
	--order by COALESCE(no.dinsertdate,(CASE WHEN r.dupdatedate is null then COALESCE(r.dinsertdate, null) else COALESCE(r.dupdatedate, null) end)) desc
) x
WHERE x.r <= p_cantidad);

return (ref_cursor);
end;
$$;


--
-- TOC entry 354 (class 1255 OID 83454)
-- Name: usp_request_status_menu_get2(integer, smallint, integer, timestamp without time zone, timestamp without time zone, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_status_menu_get2(p_ipartyid integer, p_sstatus smallint, p_iproductid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_userid integer, p_irequestid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_language integer := p_slanguageid % 140;
/**
 * Description: Stored procedure returns a list of request history<br />
 * Detailed explanation of the object.
 * @param p_ipartyid        Id the table Party                                                         INPUT
 * @param p_sstatus        Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @param p_dstartdate     start date request  
 * @param p_dfinishdate    finish date request  
 * @return cursor
 * @author  stello
 * @version 1.0 stello 31/08/2016<BR/> 
 */
begin


create temp table tbltmp_note (dinsertdate timestamp without time zone, inoteid integer, vtabname character varying(100), 
		               irequestdetailid integer, snotesubcategoryid smallint, vobservation character varying(300),irequestid integer) on commit drop;

INSERT INTO tbltmp_note 
select no.dinsertdate,no.inoteid,no.vtabname,no.irequestdetailid,no.snotesubcategoryid,no.vobservation,r.irequestid from note no 
inner join request_detail rd on no.irequestdetailid = rd.irequestdetailid
inner join request r on r.irequestid = rd.irequestid	
where no.dinsertdate = (select max(no1.dinsertdate) from note no1 where no1.irequestdetailid = no.irequestdetailid
						   order by no.dinsertdate desc)
and (CASE WHEN r.dupdatedate is null then (r.dinsertdate between p_dstartdate and p_dfinishdate) else 
			r.dupdatedate between p_dstartdate and p_dfinishdate end);


IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
	OPEN ref_cursor FOR 
	(
	SELECT
  * 
FROM (

	select data.* from (

		
select 
		ROW_NUMBER() OVER (PARTITION BY r.sstatus ORDER BY TO_TIMESTAMP(cast(r.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp desc) AS r,
		r.irequestid,
		--0 as irequestdetailid,
		r.ipartyid,
		r.iproductid,
		r.ipaymentid,
		('('|| p.vproductcode ||')'|| p.vdescription ||'  '||
		  COALESCE((SELECT vnumberplate FROM request_detail rd WHERE rd.irequestid = r.irequestid and vnumberplate is not null limit(1)),'')
		) as vdescription,
		pa.fpricetotal,
		COALESCE((TO_TIMESTAMP(cast(no.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),(CASE WHEN r.dupdatedate is null then 
			COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
			else 
			COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
		end))	as dstartdate, --muestra la ultima fecha de la nota					
		r.sstatus,
		cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) as vstatus,--p_language
		r.iinsertuserid,
		COALESCE((select rd.ivehicleid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as ivehicleid,
		par.vorganization,
		(case when par.vorganization is null then (par.vfirstname || ' ' || par.vlastname) else par.vorganization end) as vname,
		p.vproductcode,
		COALESCE(no.vtabname,r.vtabname) as vtabname, --muestra el ultimo tab donde se quedo
					
	        --r.vtabname as vtabname, --muestra el ultimo tab donde se quedo
		COALESCE(no.irequestdetailid,COALESCE((select rd.irequestdetailid from request_detail rd 
						where rd.irequestid = r.irequestid 
						limit 1),0)
						)	as irequestdetailid, --muestra el ultimo tab donde se quedo
		COALESCE(no.snotesubcategoryid,0)	as snotesubcategoryid, --muestra la categoria de la nota
		COALESCE(no.vobservation,'')	as vobservationnote,

		(CASE WHEN r.dupdatedate is null then 
			COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
			else 
			COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
		end)as datestartrequest,
		COALESCE((select rd.iownerid from request_detail rd where rd.irequestid=r.irequestid limit 1),0) as iownerid,
		pa.sstatus as sstatuspayment
		from request r 	
		left join tbltmp_note no on r.irequestid = no.irequestid	
		inner join product p on p.iproductid=r.iproductid
		inner join payment pa on pa.ipaymentid=r.ipaymentid
		inner join systemparameter sp on sp.iparameterid=r.sstatus
		inner join party par on par.ipartyid = r.ipartyid
		where (p_ipartyid = 0 OR r.ipartyid=p_ipartyid)
		AND (p_sstatus = 0 OR r.sstatus = p_sstatus)
		AND (p_iproductid = 0 OR p.iproductid = p_iproductid)AND (CASE WHEN r.dupdatedate is null then 
			(r.dinsertdate between p_dstartdate and p_dfinishdate)
			else 
			(r.dupdatedate between p_dstartdate and p_dfinishdate)
		end)
		AND (p_userid=0 or r.iinsertuserid=p_userid)
		AND (p_irequestid=0 or r.irequestid=p_irequestid)
		AND p.vproductcode not in('PA01','PA02')
		) as data 
		--where data.dstartdate is not null
		--order by TO_TIMESTAMP(cast(r.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp desc
		order by TO_TIMESTAMP(cast(data.dstartdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp desc
		) x
WHERE
  x.r <= 10
	);      
return (ref_cursor);
end;
$$;


--
-- TOC entry 355 (class 1255 OID 83456)
-- Name: usp_request_user_location(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_request_user_location() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
     declare result refcursor := 'result';
     recursive_city character varying;
     recursive_city_id integer;
     recursive_state_province character varying;
     recursive_state_province_id integer;
     recursive_country character varying;
     recursive_country_id integer;     
     rrow RECORD;
    BEGIN
	create temporary table table_with_names (
	user_location_id integer,
	user_name character varying,
	country character varying,
	state_province character varying,
	city character varying,
	district character varying,
	address character varying
	) on commit drop;

	FOR rrow IN select ul.*, l.slocationtypeid, l.slevelid, l.scountryid, l.vdescription, l.ireferenceid, l.sstatus, l.iinsertuserid 
	from user_location ul 
	inner join public.location l on ul.ilocationid = l.ilocationid 
	where ul.sstatus = 1
	LOOP
	
	    CASE rrow.slevelid
	    WHEN  1103 THEN
		    select vdescription into recursive_city from location where ilocationid = rrow.ireferenceid;
		    select ireferenceid into recursive_city_id from location where ilocationid = rrow.ireferenceid;
		    select vdescription into recursive_state_province from location where ilocationid = recursive_city_id;
		    select scountryid into recursive_country_id from location where ilocationid = recursive_city_id;
		    select vname into recursive_country from country where scountryid = recursive_country_id;				
		    INSERT INTO table_with_names (user_location_id,user_name,country,state_province,city,district,address) values(rrow.iuserlocationid,rrow.vusername,recursive_country,recursive_state_province,recursive_city,rrow.vdescription,rrow.vuseraddress);

	    WHEN  1102 THEN
		    select vdescription into recursive_state_province from location where ilocationid = rrow.ireferenceid;
		    select scountryid into recursive_country_id from location where ilocationid = rrow.ireferenceid;
		    select vname into recursive_country from country where scountryid = recursive_country_id;				
		    INSERT INTO table_with_names (user_location_id,user_name,country,state_province,city,address) values(rrow.iuserlocationid,rrow.vusername,recursive_country,recursive_state_province,rrow.vdescription,rrow.vuseraddress);		    

	    WHEN  1101 THEN
		    select vname into recursive_country from country where scountryid = rrow.scountryid;				
		    INSERT INTO table_with_names (user_location_id,user_name,country,state_province,address) values(rrow.iuserlocationid,rrow.vusername,recursive_country,rrow.vdescription,rrow.vuseraddress);		    		    
		ELSE
	    END CASE;
    
	END LOOP;

	OPEN result for (select * from table_with_names);
	/*
	OPEN result for (select ul.*, l.slocationtypeid, l.slevelid, l.scountryid, l.vdescription, l.ireferenceid, l.sstatus, l.iinsertuserid 
	from user_location ul 
	inner join public.location l on ul.ilocationid = l.ilocationid
	);*/
      RETURN (result);
    END;
    $$;


--
-- TOC entry 356 (class 1255 OID 83457)
-- Name: usp_requestlicense_get(smallint, smallint, character varying, character varying, smallint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_requestlicense_get(p_slicensetypeid smallint, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
declare p_language integer := p_slanguageid % 140;
declare p_ipartyid integer := 0;
/**
 * Description: Stored procedure that returns a list of request<br />
 * Detailed explanation of the object.
 * @param p_irequestid   Id the table Request				                          INPUT
 * @param p_sstatus      Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000  INPUT
 * @param p_iproductid   Id tha table product                                                     INPUT
 * @param p_dstartdate   start date request                                                       INPUT
 * @param p_dfinishdate  finish date request                                                      INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
select COALESCE(ipartyid, 0) into p_ipartyid from party where 
COALESCE(p_sdocumenttypeid, 0) = 0 OR (sdocumenttypeid = p_sdocumenttypeid 
AND (UPPER(TRIM(COALESCE(p_vdocumentnumber, '')))) = UPPER(TRIM(vdocumentnumber))) LIMIT 1;

	OPEN p_cursor FOR 
	SELECT distinct
	      rl.irequestlicenseid,
	      rl.slicensetypeid,
	      cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vlicensetype,
	      rl.dstartdate,
	      rl.dexpirydate,
	      rl.dnewstartdate,
	      rl.dnewenddate,
	      rl.vnumberlicense,
	      rl.splatetypeid,
	      cast(trim(split_part(sp4.vdescription,'|', p_language)) as character varying) as vplatetype,
	      rl.vnumberplate,
	      rl.vplatepreview,
	      rl.sdurationlicense,
	      cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) as vdurationlicense,
	      rl.vcomment,
	      rl.sstatus,
	      cast(trim(split_part(sp3.vdescription,'|', p_language)) as character varying) as vstatus
       FROM request_license rl
       INNER JOIN request_detail rd on rd.irequestlicenseid = rl.irequestlicenseid
       INNER JOIN request r on rd.irequestid = r.irequestid       
       INNER JOIN systemparameter sp1 on sp1.iparameterid = rl.slicensetypeid and sp1.igroupid = 4800
       INNER JOIN systemparameter sp2 on sp2.iparameterid = rl.sdurationlicense and sp2.igroupid = 4400
       INNER JOIN systemparameter sp3 on sp3.iparameterid = rl.sstatus and sp3.igroupid = 4900
       INNER JOIN systemparameter sp4 on sp4.iparameterid = rl.splatetypeid and sp4.igroupid = 3700
       where 
       (p_slicensetypeid = 0 or rl.slicensetypeid = p_slicensetypeid) and
       (p_ipartyid = 0 or rd.iownerid = p_ipartyid) and
       (COALESCE(p_vplatenumber, '') = '' or p_vplatenumber = rl.vnumberplate) and
       (p_sstatus = 0 or rl.sstatus = p_sstatus) and 
       r.sstatus = 5003
       order by rl.dstartdate desc;
              
return (p_cursor);
end;
$$;


--
-- TOC entry 2631 (class 0 OID 0)
-- Dependencies: 356
-- Name: FUNCTION usp_requestlicense_get(p_slicensetypeid smallint, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_requestlicense_get(p_slicensetypeid smallint, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer) IS 'Stored procedure that returns a list of request licence';


--
-- TOC entry 357 (class 1255 OID 83458)
-- Name: usp_schedule_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_schedule_get(p_iofficeexaminationtypeid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN
/**
 * Description: Stored procedure that returns a list of printers<br />
 * Detailed explanation of the object.
 * @param iprinterid Primary auto-increment key
 * @return array printer.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 * @version 2.0 rpaucar 16/08/2016<BR/> Se agrego tabla location y su columna vdescription
 */
      OPEN ref_cursor FOR SELECT oe.ischeduleid , 
			  oe.dscheduledate , 
			  oe.sdayofweekid , 
			  oe.ivacant , 
			  oe.sstatus,
			  oe.iofficeexaminationtypeid
			FROM schedule oe 
			WHERE (oe.ischeduleid = p_ischeduleid or p_ischeduleid = 0) ;
      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2632 (class 0 OID 0)
-- Dependencies: 357
-- Name: FUNCTION usp_schedule_get(p_iofficeexaminationtypeid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_schedule_get(p_iofficeexaminationtypeid integer) IS 'Stored procedure returns a list of schedule according to parameters entered';


--
-- TOC entry 358 (class 1255 OID 83459)
-- Name: usp_schedule_maintenance(integer, integer, timestamp without time zone, time without time zone, time without time zone, integer, integer, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_schedule_maintenance(INOUT p_ischeduleid integer, p_iofficeexaminationtypeid integer, p_dscheduledate timestamp without time zone, p_ttimeday time without time zone, p_ttimeendday time without time zone, p_sdayofweekid integer, p_ivacant integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
/**
 * Description: Stored procedure that save, edit and delete a printer<br />
 * Detailed explanation of the object.
* @param p_ischeduleid 	Primary auto-increment key
* @param p_dscheduledate 	date
* @param p_ttimeday time stard,
* @param p_ttimeendday time end,
* @param p_sdayofweekid 	Day of week Id
* @param p_ivacant 	number vacant for schedule
* @param p_sstatus 	status
* @param iinsertuserid 	User ID
* @param vinsertip 	IP address user
* @param iupdateuserid 	Updated user ID
* @param vupdateip 	Update user IP
* @param vipdescription Ip Description
* @param p_voption 	Option to perform.  'INS' - 'UPD' - 'DEL'
 * @return ID printer.
 * @author  rpaucar
 * @version 1.0 rpaucar 23/09/2016<BR/> 
 */


IF p_vOption = 'INS' THEN
    IF not exists(select ischeduleid from public.schedule where dscheduledate=p_dscheduledate and 
    ((p_ttimeday between ttimeday and ttimeendday) or (p_ttimeendday between ttimeday and ttimeendday)) and
    p_iofficeexaminationtypeid = iofficeexaminationtypeid and
    sstatus != 0) then
	INSERT INTO public.schedule(
		iofficeexaminationtypeid,
		dscheduledate,
		ttimeday, 
		ttimeendday,
		sdayofweekid, 
		ivacant, 
		sstatus,
		iinsertuserid, 
		dinsertdate,
		vinsertip
	) VALUES (
		p_iofficeexaminationtypeid,
		p_dscheduledate,
		p_ttimeday, 
		p_ttimeendday,
		p_sdayofweekid, 
		p_ivacant, 
		p_sstatus, 
		p_iinsertuserid, 
		now(), 
		p_vinsertip
	);
	p_ischeduleid := (select currval('schedule_seq'));
    end if;
    ELSIF p_vOption = 'UPD' THEN
	UPDATE public.schedule
	   SET iofficeexaminationtypeid=p_iofficeexaminationtypeid,
	   dscheduledate= p_dscheduledate, 
	   ttimeday = p_ttimeday,
	   ttimeendday = p_ttimeendday,
	   sdayofweekid= p_sdayofweekid, 
	   ivacant= p_ivacant, 
	   sstatus= p_sstatus, 
	    iupdateuserid= p_iupdateuserid, 
	    dupdatedate= now(), 
	    vupdateip= p_vupdateip 
	 WHERE ischeduleid = p_ischeduleid;
     ELSIF p_vOption = 'DEL' THEN
	UPDATE schedule SET sstatus = 0,
	      iupdateuserid = p_iupdateuserid,
	       dupdatedate = now()
	WHERE ischeduleid = p_ischeduleid;
END IF;
END;
$$;


--
-- TOC entry 2633 (class 0 OID 0)
-- Dependencies: 358
-- Name: FUNCTION usp_schedule_maintenance(INOUT p_ischeduleid integer, p_iofficeexaminationtypeid integer, p_dscheduledate timestamp without time zone, p_ttimeday time without time zone, p_ttimeendday time without time zone, p_sdayofweekid integer, p_ivacant integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_schedule_maintenance(INOUT p_ischeduleid integer, p_iofficeexaminationtypeid integer, p_dscheduledate timestamp without time zone, p_ttimeday time without time zone, p_ttimeendday time without time zone, p_sdayofweekid integer, p_ivacant integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that inserts or updates a schedule';


--
-- TOC entry 359 (class 1255 OID 83460)
-- Name: usp_service_payment_get(integer, smallint); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_service_payment_get(p_ipaymentid integer, p_sstatus smallint) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
/**
 * Description: Stored procedure returns a list of payment product<br />
 * Detailed explanation of the object.
 * @param p_ipaymentid       Id the table Payment                                                        INPUT
 * @param p_sstatus          Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000     INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
declare p_cursor refcursor :='p_cursor';
begin
	OPEN p_cursor FOR 
	(    
		select 
		r.irequestid,0 as irequestdetailid,r.iproductid,
		('('|| p.vproductcode ||') '||p.vdescription) as vproduct,
		cast(-1 as double precision) as fpricetotal,
		p.sstatus
		from request r
		inner join product p on p.iproductid=r.iproductid
		where r.ipaymentid=p_ipaymentid and r.sstatus=p_sstatus
	        union
		select rd.irequestid,irequestdetailid as irequestdetailid,rd.iproductid,
		(case when rd.snumber is null then p.vdescription else p.vdescription ||' ('|| rd.snumber ||')' end) as vproduct,
		case when pp.fpricetotal is null then 0 else pp.fpricetotal end as fpricetotal,
		p.sstatus
		from request r1
		inner join request_detail rd on rd.irequestid=r1.irequestid
		inner join product p on p.iproductid=rd.iproductid
		left join product_pricing pp on pp.ipricingid=rd.ipricingid
		where r1.ipaymentid=p_ipaymentid and r1.sstatus=p_sstatus and r1.iproductid !=rd.iproductid
		order by irequestid,irequestdetailid		
	);             
return (p_cursor);
end;
$$;


--
-- TOC entry 2634 (class 0 OID 0)
-- Dependencies: 359
-- Name: FUNCTION usp_service_payment_get(p_ipaymentid integer, p_sstatus smallint); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_service_payment_get(p_ipaymentid integer, p_sstatus smallint) IS 'Stored procedure returns a list of payment product according to parameters entered';


--
-- TOC entry 360 (class 1255 OID 83461)
-- Name: usp_systemaudit_get(integer, integer, integer, integer, integer, integer, timestamp without time zone, timestamp without time zone, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_systemaudit_get(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_iuserid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of system audit<br />
 * Detailed explanation of the object.
 * @param p_seventtypeid         	It lets you search for primary key of System Audit.	'0' All values
 * @param p_sprocessid          	Process of System. 					'0' All values
 * @param p_staskid          		Task of System. 					'0' All values
 * @param p_sactionid          		Action of System. 					'0' All values
 * @param p_sresultid          		Result of System. 					'0' All values
 * @param p_iuserid          		System user. 						'0' All values
 * @param p_dstartdate          	Start Date.
 * @param p_dfinishdate          	Finish Date.
 * @return ref_cursor			stores data to return in a cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_language integer := p_slanguageid % 140;
BEGIN
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
      open ref_cursor for 
      SELECT 
        SA.IEVENTID,
        SA.SEVENTTYPEID,
        cast(trim(split_part(EVE.VDESCRIPTION,'|', p_language)) as character varying) VEVENTTYPE,
        SA.SPROCESSID,
        cast(trim(split_part(PRO.VDESCRIPTION,'|', p_language)) as character varying) VPROCESS,
        SA.STASKID,
        cast(trim(split_part(TAS.VDESCRIPTION,'|', p_language)) as character varying) VTASK,
        SA.SACTIONID,
        cast(trim(split_part(ACT.VDESCRIPTION,'|', p_language)) as character varying) VACTION,
        SA.SRESULTID,
        cast(trim(split_part(RES.VDESCRIPTION,'|', p_language)) as character varying) VRESULT,
        SA.VMESSAGE,
        SA.VHOSTNAME,
        SA.IINSERTUSERID,
        '' VUSER,
        SA.DINSERTDATE,
        SA.VINSERTIP
      FROM SYSTEMAUDIT SA
      INNER JOIN SYSTEMPARAMETER EVE ON EVE.IPARAMETERID = SA.SEVENTTYPEID
      INNER JOIN SYSTEMPARAMETER PRO ON PRO.IPARAMETERID = SA.SPROCESSID
      INNER JOIN SYSTEMPARAMETER TAS ON TAS.IPARAMETERID = SA.STASKID
      INNER JOIN SYSTEMPARAMETER ACT ON ACT.IPARAMETERID = SA.SACTIONID
      INNER JOIN SYSTEMPARAMETER RES ON RES.IPARAMETERID = SA.SRESULTID
      WHERE 
      (SA.SEVENTTYPEID = p_sEventTypeId OR p_sEventTypeId = 0) AND
      (SA.SPROCESSID = p_sProcessId OR p_sProcessId = 0) AND
      (SA.STASKID = p_sTaskId OR p_sTaskId = 0) AND
      (SA.SACTIONID = p_sActionId OR p_sActionId = 0) AND
      (SA.SRESULTID = p_sResultId OR p_sResultId = 0) AND
      (SA.IINSERTUSERID = p_iUserId OR p_iUserId = 0) AND
      (p_dStartDate < SA.DINSERTDATE  AND SA.DINSERTDATE < p_dFinishDate);
      RETURN (ref_cursor);  
END;
$$;


--
-- TOC entry 2635 (class 0 OID 0)
-- Dependencies: 360
-- Name: FUNCTION usp_systemaudit_get(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_iuserid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_systemaudit_get(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_iuserid integer, p_dstartdate timestamp without time zone, p_dfinishdate timestamp without time zone, p_slanguageid integer) IS 'Stored procedure returns a list of system audit according to parameters entered';


--
-- TOC entry 361 (class 1255 OID 83462)
-- Name: usp_systemaudit_maintenance(integer, integer, integer, integer, integer, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_systemaudit_maintenance(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_vmessage character varying, p_vhostname character varying, p_iinsertuserid integer, p_vinsertip character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a system audit <br />
 * Detailed explanation of the object.
 * @param p_voption        Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_seventtypeid   Referring to table system parameter.Stores references to the types of event
 * @param p_sprocessid     Referring to table system parameter.Stores references to the process of system
 * @param p_staskid        Referring to table system parameter.Stores references to the task of system
 * @param p_sactionid      Referring to table system parameter.Stores references to the action of system
 * @param p_sresultid      Referring to table system parameter.Stores references to the result of system
 * @param p_vmessage       Stores the message thrown by the system
 * @param p_vhostname      Stores the host name that generated the event
 * @param p_iinsertuserid  User ID
 * @param p_vinsertip      IP address user
 * @return Void
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
BEGIN
    INSERT INTO SYSTEMAUDIT (
      SEVENTTYPEID,
      SPROCESSID,
      STASKID,
      SACTIONID,
      SRESULTID,
      VMESSAGE,
      VHOSTNAME,
      IINSERTUSERID,
      DINSERTDATE,
      VINSERTIP
    ) VALUES (
      p_sEventTypeId,
      p_sProcessId,
      p_sTaskId,
      p_sActionId,
      p_sResultId,
      p_vMessage,
      p_vHostName,
      p_iInsertUserId,
      now(),
      p_vInsertIP
    );
END;
$$;


--
-- TOC entry 2636 (class 0 OID 0)
-- Dependencies: 361
-- Name: FUNCTION usp_systemaudit_maintenance(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_vmessage character varying, p_vhostname character varying, p_iinsertuserid integer, p_vinsertip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_systemaudit_maintenance(p_seventtypeid integer, p_sprocessid integer, p_staskid integer, p_sactionid integer, p_sresultid integer, p_vmessage character varying, p_vhostname character varying, p_iinsertuserid integer, p_vinsertip character varying) IS 'Stored procedure  save, edit and delete a system audit';


--
-- TOC entry 362 (class 1255 OID 83463)
-- Name: usp_systemparam_get(integer, character varying, character varying, character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_systemparam_get(p_iparameterid integer, p_vgroupid character varying, p_vvalue character varying, p_vreferenceid character varying, p_svisible integer, p_sstatus integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure that returns a list of system param<br />
 * Detailed explanation of the object.
 * @param p_iparameterid        It lets you search for primary key of Parameter. 		 '0'    All values
 * @param p_vgroupid         	Id Group of parameter concatenated by ','			''-1''  All values
 * @param p_vvalue         	Value of parameter						''0''   All values
 * @param p_vreferenceid        Id reference of parameter. 					''0''   All values
 * @param p_svisible         	Visibility of parameter.					''-1''  All values
 * @param p_sstatus         	Status of parameter.						''-1''  All values
 * @param p_slanguageid              Referring to table system parameter. SECURITY_LANGUAGE = 140
 * @return ref_cursor		stores data to return in a cursor
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare ref_cursor REFCURSOR := 'ref_cursor';
declare p_language integer := p_slanguageid % 140;

BEGIN
	IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
      open ref_cursor for 
      select distinct
        sp.iparameterid,
        sp.igroupid,
        case when (sp.igroupid = 0) then  cast(trim(split_part(sp.vdescription,'|', 1)) as character varying)
        else cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) end as vdescription,
        --sp.vdescription,
        sp.vvalue,
        sp.vreferenceid,
        sp.sorder,
        sp.svisible,
        sp.sstatus,
        sp.iinsertuserid,
        sp.dinsertdate,
        sp.vinsertip,
        sp.iupdateuserid,
        sp.dupdatedate,
        sp.vupdateip
      from systemparameter sp
      where sp.iparameterid <> 0 and (p_iparameterid = 0 or sp.iparameterid = p_iparameterid) and
      (p_vgroupid = '-1' or sp.igroupid in (select cast(regexp_split_to_table(p_vgroupid, ',')as int))) and
      (p_vvalue = '0' or sp.vvalue = p_vvalue) and 
      (p_vreferenceid = '0' or sp.vreferenceid = p_vreferenceid) and 
      (p_svisible = -1 or sp.svisible = p_svisible) and 
      (p_sstatus = -1 or sp.sstatus =  p_sstatus)
      order by sp.igroupid, sp.iparameterid asc;
      return (ref_cursor);  
	--AND (COALESCE(p_vdescription, '0') = '0' OR vdescription = p_vdescription)
END;
$$;


--
-- TOC entry 2637 (class 0 OID 0)
-- Dependencies: 362
-- Name: FUNCTION usp_systemparam_get(p_iparameterid integer, p_vgroupid character varying, p_vvalue character varying, p_vreferenceid character varying, p_svisible integer, p_sstatus integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_systemparam_get(p_iparameterid integer, p_vgroupid character varying, p_vvalue character varying, p_vreferenceid character varying, p_svisible integer, p_sstatus integer, p_slanguageid integer) IS 'Stored procedure returns a list of system parameter according to parameters entered';


--
-- TOC entry 363 (class 1255 OID 83464)
-- Name: usp_systemparam_maintenance(character varying, integer, integer, character varying, character varying, character varying, integer, integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_systemparam_maintenance(p_voption character varying, p_iparameterid integer, p_igroupid integer, p_vdescription character varying, p_vvalue character varying, p_vreferenceid character varying, p_sorder integer, p_svisible integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
/**
 * Description: Stored procedure  save, edit and delete a system parameter <br />
 * Detailed explanation of the object.
 * @param p_voption          Lets you know the action to perform.  'INS' - 'UPD' - 'DEL'
 * @param p_iparameterid     Primary key
 * @param p_igroupid         Stores the group of systemparameter
 * @param p_vdescription     Stores the description of systemparameter
 * @param p_vvalue           Stores the value of systemparameter
 * @param p_vreferenceid     Field to link any table or place a particular value
 * @param p_sorder           Stores the order of systemparameter
 * @param p_svisible         Stores the visible of systemparameter 1=Visible; 0= Not Visible
 * @param p_sstatus          Stores the status of systemparameter 1=Active; 0= Inactive
 * @param p_iinsertuserid    User ID
 * @param p_vinsertip        IP address user
 * @param p_iupdateuserid    Updated user ID
 * @param p_vupdateip        Update user IP
 * @return Void
 * @author  cburgos
 * @version 1.0 cburgos 26/07/2016 <br />
 */
declare p_cantidad integer := 0;
declare p_cnt integer := 0;
BEGIN

  IF p_vOption = 'INS' THEN 
     IF p_iGroupId <> 0 THEN     
          SELECT coalesce(MAX(IPARAMETERID), p_iGroupId) into p_cantidad FROM SYSTEMPARAMETER WHERE IGROUPID = p_iGroupId;          
          IF p_cantidad = 0 THEN 
            p_cantidad := p_iGroupId;
          END IF;
          p_cantidad := p_cantidad + 1;         
      END IF;
     SELECT Count(IPARAMETERID) into p_cnt FROM SYSTEMPARAMETER WHERE IPARAMETERID = p_iParameterId;      
     IF p_cnt > 0 THEN
        UPDATE SYSTEMPARAMETER SET 
          VDESCRIPTION = UPPER(p_vDescription),
          VVALUE = p_vValue,
          SORDER = p_sOrder,
          SVISIBLE = p_sVisible,
          IGROUPID = p_iGroupId,
          SSTATUS = 1
        where IPARAMETERID = p_iParameterId;
      ELSE
        INSERT INTO SYSTEMPARAMETER (
          IPARAMETERID,
          IGROUPID,
          VDESCRIPTION,
          VVALUE,
          VREFERENCEID,
          SORDER,
          SVISIBLE,
          SSTATUS,
          IINSERTUSERID,
          DINSERTDATE,
          VINSERTIP
        ) VALUES (
          p_iParameterId,
          p_iGroupId,
          upper(p_vDescription),
          p_vValue,
          p_vReferenceId,
          p_sOrder,
          p_sVisible,          
          p_sStatus,
          p_iInsertUserId,
          now(),
          p_vInsertIP
        );
      END IF;      
  ELSIF p_vOption = 'UPD' THEN  
      UPDATE SYSTEMPARAMETER
      SET
      IGROUPID = p_iGroupId,
      VDESCRIPTION = UPPER(p_vDescription),
      VVALUE = p_vValue,
      VREFERENCEID = p_vReferenceId,
      SORDER = p_sOrder,
      SVISIBLE = p_sVisible,
      SSTATUS = p_sStatus,
      IUPDATEUSERID = p_iUpdateUserId,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vUpdateIP
      WHERE IPARAMETERID = p_iParameterId;
  ELSIF p_vOption = 'DEL' THEN 
      UPDATE SYSTEMPARAMETER
      SET SSTATUS = 0,
      IUPDATEUSERID = p_iUpdateUserId,
      DUPDATEDATE = now(),
      VUPDATEIP = p_vUpdateIP
      WHERE IPARAMETERID = p_iParameterId;
  END IF;
  
END;
$$;


--
-- TOC entry 2638 (class 0 OID 0)
-- Dependencies: 363
-- Name: FUNCTION usp_systemparam_maintenance(p_voption character varying, p_iparameterid integer, p_igroupid integer, p_vdescription character varying, p_vvalue character varying, p_vreferenceid character varying, p_sorder integer, p_svisible integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_systemparam_maintenance(p_voption character varying, p_iparameterid integer, p_igroupid integer, p_vdescription character varying, p_vvalue character varying, p_vreferenceid character varying, p_sorder integer, p_svisible integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying) IS 'Stored procedure  save, edit and delete a system parameter';


--
-- TOC entry 364 (class 1255 OID 83465)
-- Name: usp_top_services(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_top_services(p_cant_top integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
begin
/**
 * Description: Stored procedure returns a list of top services<br />
 * @return cursor
 * @author  jcondori
 * @version 1.0 jcondori 05/08/2016<BR/> 
 */

	OPEN p_cursor FOR 
	(
		select * from (SELECT  0 AS pack,
			0 AS irequestid,
			R.iproductid AS iproductid,
			P.vdescription AS vdescription,
			'' AS vproductcode,
			'' AS vrequestdetailid,
			'' AS vproductid,
			0 AS fpricetotal,
			count(R.iproductid) AS cantidad,
			0 AS bauthorization,
			0 AS bvisible,
			0 AS bconformity,
			0 AS bfloating,
			0 AS boptional,
			0 AS bterminate,
			0 AS sstatus,
			0 AS statusrequest,
			0 AS vjson,
			0 AS sauthorization,
			0 AS ipaymentid
		FROM request R
		JOIN product P ON P.iproductid = R.iproductid
		where cast(r.dfinishdate as date) = cast(now()  as date) and r.sstatus = 5003
		GROUP BY R.iproductid, P.vdescription) as tabla
		order by tabla.cantidad desc
		LIMIT p_Cant_Top);
	return (p_cursor);
	
end;
$$;


--
-- TOC entry 2639 (class 0 OID 0)
-- Dependencies: 364
-- Name: FUNCTION usp_top_services(p_cant_top integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_top_services(p_cant_top integer) IS 'Stored procedure returns a list of top services';


--
-- TOC entry 365 (class 1255 OID 83466)
-- Name: usp_tracingrequest(integer, integer, smallint, character varying, integer, character varying, smallint, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_tracingrequest(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_iproductid integer, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare p_cursor refcursor :='p_cursor';
declare p_language integer := p_slanguageid % 140;
declare p_ipartyid integer := 0;
/**
 * Description: Stored procedure that returns a list of request<br />
 * Detailed explanation of the object.
 * @param p_irequestid   Id the table Request				                          INPUT
 * @param p_sstatus      Idparameter the table Systemparameter Grup OPERATION_REQUESTSTATUS=5000  INPUT
 * @param p_iproductid   Id tha table product                                                     INPUT
 * @param p_dstartdate   start date request                                                       INPUT
 * @param p_dfinishdate  finish date request                                                      INPUT
 * @return cursor
 * @author  apereyra
 * @version 1.0 apereyra 26/07/2016<BR/> 
 */
begin
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
select COALESCE(ipartyid, 0) into p_ipartyid from party where 
COALESCE(p_sdocumenttypeid, 0) = 0 OR (sdocumenttypeid = p_sdocumenttypeid 
AND (UPPER(TRIM(COALESCE(p_vdocumentnumber, '')))) = UPPER(TRIM(vdocumentnumber))) LIMIT 1;

	OPEN p_cursor FOR 
	SELECT 
	      r.irequestid,
	      r.ipaymentid,
	      r.ipartyid,
	      (case when r.ipartyid is not null then 
	      (select case when vorganization is null then vlastname || ' ' || vfirstname else vorganization end from party where r.ipartyid = ipartyid)
	      else null end) as vparty,
	      r.iproductid,
	      p.vproductcode,
	      p.vdescription as vproduct,
	      r.ireferencerequestid,
	      r.dstartdate,
	      r.dfinishdate,
	      r.bterminate,
	      r.itramitadorid,
	      (case when r.itramitadorid is not null then 
	      (select case when vorganization is null then vlastname || ' ' || vfirstname else vorganization end from party where r.itramitadorid = ipartyid)
	      else null end) as vtramitador,
	      r.sstatus,
	      cast(trim(split_part(sp1.vdescription,'|', p_language)) as character varying) as vstatus
       FROM request r
       INNER JOIN product p on p.iproductid = r.iproductid
       INNER JOIN request_detail rd on rd.irequestid = r.irequestid    
       INNER JOIN systemparameter sp1 on sp1.iparameterid = r.sstatus and sp1.igroupid = 5000
       where 
       (p_ipaymentid = 0 or r.ipaymentid = p_ipaymentid) and
       (p_irequestid = 0 or r.irequestid = p_irequestid) and
       (p_iproductid = 0 or r.iproductid = p_iproductid) and
       (p_ipartyid = 0 or r.ipartyid = p_ipartyid or r.itramitadorid = p_ipartyid) and
       (COALESCE(p_vplatenumber, '') = '' or p_vplatenumber = rd.vnumberplate) and
       (p_sstatus = 0 or r.sstatus = p_sstatus);
              
return (p_cursor);
end;
$$;


--
-- TOC entry 2640 (class 0 OID 0)
-- Dependencies: 365
-- Name: FUNCTION usp_tracingrequest(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_iproductid integer, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_tracingrequest(p_ipaymentid integer, p_irequestid integer, p_sdocumenttypeid smallint, p_vdocumentnumber character varying, p_iproductid integer, p_vplatenumber character varying, p_sstatus smallint, p_slanguageid integer) IS 'Stored procedure that returns a list of request';


--
-- TOC entry 366 (class 1255 OID 83467)
-- Name: usp_user_location_maintenance(integer, integer, integer, character varying, character varying, smallint, integer, timestamp without time zone, character varying, integer, timestamp without time zone, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_user_location_maintenance(p_iregid integer, p_iuserid integer, p_ilocationid integer, p_vusername character varying, p_vuseraddress character varying, p_sstatus smallint, p_iinsertuserid integer, p_dinsertdate timestamp without time zone, p_vinsertip character varying, p_iupdateuserid integer, p_dupdatedate timestamp without time zone, p_vupdateip character varying, INOUT p_lastid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    BEGIN

    IF (p_sstatus) THEN

    INSERT INTO public.user_location(iuserid,ilocationid,vusername,vuseraddress,sstatus,iinsertuserid,
    	dinsertdate,vinsertip,iupdateuserid,dupdatedate,vupdateip) VALUES
    (p_iuserid,p_ilocationid,p_vusername,p_vuseraddress,p_sstatus,p_iinsertuserid,now(),p_vinsertip,p_iupdateuserid,now(),p_vupdateip);
    p_lastid := (select currval('user_location_seq'));

    ELSE

    UPDATE public.user_location SET sstatus = p_sstatus WHERE iuserlocationid = p_iregid;

    END IF;

END;
$$;


--
-- TOC entry 2641 (class 0 OID 0)
-- Dependencies: 366
-- Name: FUNCTION usp_user_location_maintenance(p_iregid integer, p_iuserid integer, p_ilocationid integer, p_vusername character varying, p_vuseraddress character varying, p_sstatus smallint, p_iinsertuserid integer, p_dinsertdate timestamp without time zone, p_vinsertip character varying, p_iupdateuserid integer, p_dupdatedate timestamp without time zone, p_vupdateip character varying, INOUT p_lastid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_user_location_maintenance(p_iregid integer, p_iuserid integer, p_ilocationid integer, p_vusername character varying, p_vuseraddress character varying, p_sstatus smallint, p_iinsertuserid integer, p_dinsertdate timestamp without time zone, p_vinsertip character varying, p_iupdateuserid integer, p_dupdatedate timestamp without time zone, p_vupdateip character varying, INOUT p_lastid integer) IS 'Store procedure save, edit and delete a location of users';


--
-- TOC entry 367 (class 1255 OID 83468)
-- Name: usp_vehicle_detail_search(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_detail_search(p_ivehicleid integer, p_irequestid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN

/**
 * Description: Stored procedure that returns a list of vehicle detail<br />
 * Detailed explanation of the object.
 * @param p_ivehicleid     Vehicle code.
 * @param p_irequestid     Request code.
 * @return Return table vehicle detail
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */
      
OPEN ref_cursor FOR 

SELECT 
	--DATOS VEHICULO
	COALESCE(v.ivehicleid, 0) as ivehicleid,
        COALESCE(vvehiclecode,'') as vvehiclecode,
        COALESCE(scategorytypeid,0) as scategorytypeid,
        COALESCE(sfuelsourcetypeid,0) as sfuelsourcetypeid,
        COALESCE(sprimarycolourid,0) as sprimarycolourid,
        COALESCE(ssecondarycolourid,0) as ssecondarycolourid,
        COALESCE(bnew,false) as bnew,
	COALESCE(vusedby,'') as vusedby,
	COALESCE(downedsince,null) as downedsince,
	COALESCE(venginenumber,'') as venginenumber,
	COALESCE(iseatingcapacity,0) as iseatingcapacity,
	COALESCE(smaximunload,0) as smaximunload,
	COALESCE(ddatestolen,null) as ddatestolen,
	COALESCE(fgrossweight,0) as fgrossweight,
	COALESCE(funladenweigth,0) as funladenweigth,
	COALESCE(vexportdetails,'') as vexportdetails,
	COALESCE(imodelid,0) as imodelid,
	COALESCE(iversionid,0) as imodelversion,
	COALESCE(smanufacturingyear,0) as smanufacturingyear,
	COALESCE(sseatnumber,0) as sseatnumber,
	COALESCE(spassengernumber,0) as spassengernumber,
	COALESCE(ftravellingwidthfeet,0) as ftravellingwidthfeet,
	COALESCE(foveralllengthfeet,0) as foveralllengthfeet,
	COALESCE(shanddriveid,0) as shanddriveid,
	COALESCE(vtrailer,'') as vtrailer,
	COALESCE(iimportfrom,0) as iimportfrom,
	COALESCE(vorigin,'') as vorigin,
	COALESCE(vvinnumber,'') as vvinnumber,
	COALESCE(imakeid,0) as imakeid,

		
        --VEHICLE INSURANCE
        COALESCE(vi.iinsuranceid,0) as iinsuranceid,
        COALESCE(vi.icompanyid,0) as icompanyid,
	COALESCE(vi.vcertificatenumber,'') as vcertificatenumber,
	COALESCE(vi.dissuedate,null) as dissuedate,
	COALESCE(vi.dexpirydate,null) as dexpirydate,

        --VEHICLE LIEN
        COALESCE(vl.ibanklienid,0) as ibanklienid,
        COALESCE(vl.ilienholderid,0) as ilienholderid,
	COALESCE(vl.vphonenumber,'') as vphonenumber,
	COALESCE(vl.dstartdate,now()) as dstartdate,
	
        --OTROS
	COALESCE(p.ipartyid) as ipartyid,
	COALESCE(r.irequestid,0) as irequestid,
	COALESCE(r.iproductid,0) as iproductidR,
	COALESCE(vc.vdescription,'') as vmakedesc,
	COALESCE(vc1.vdescription,'') as vmodeldesc,
	COALESCE(vc2.vdescription,'') as vmodelversion,
	COALESCE(rd.iproductid,0) as iproductid,
	COALESCE(rd.irequestdetailid,0) as irequestdetailid,
	COALESCE(rd.irequestdetailid,0) as vrequestdetailid,
	COALESCE(rl.splatetypeid,0) as splatetypeid,
	COALESCE(rd.ipricingid,0) as ipricingid,
	COALESCE(rl.sdurationlicense,0) as sdurationlicense,
	COALESCE(vinsp.sdurationinspection,0) as sdurationinspection

FROM request r
LEFT JOIN party p ON p.ipartyid = r.ipartyid
LEFT JOIN request_detail rd ON r.irequestid = rd.irequestid
LEFT JOIN vehicle v ON v.ivehicleid = rd.ivehicleid
LEFT JOIN vehicle_catalog vc ON vc.ivehiclecatalogid = v.imakeid AND vc.icatalogtypeid = 5101 
LEFT JOIN vehicle_catalog vc1 ON vc1.ivehiclecatalogid = v.imodelid AND vc1.icatalogtypeid = 5102 
LEFT JOIN vehicle_catalog vc2 ON vc2.ivehiclecatalogid = v.iversionid AND vc2.icatalogtypeid = 5103  
LEFT JOIN vehicle_insurance vi ON vi.ivehicleid = v.ivehicleid
LEFT JOIN vehicle_banklien vl ON vl.ivehicleid = v.ivehicleid
LEFT JOIN request_license rl ON rl.irequestlicenseid = rd.irequestlicenseid
LEFT JOIN vehicle_inspection vinsp ON vinsp.ivehicleid = v.ivehicleid
WHERE  (p_ivehicleid = 0 or v.ivehicleid = p_ivehicleid) AND ((rl.sstatus = 4916 or rl.sstatus=4918) OR (rd.iproductid = 13 AND vinsp.sstatus = 1))
;
--AND (p_irequestid = 0 or r.irequestid = p_irequestid);

 RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2642 (class 0 OID 0)
-- Dependencies: 367
-- Name: FUNCTION usp_vehicle_detail_search(p_ivehicleid integer, p_irequestid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_detail_search(p_ivehicleid integer, p_irequestid integer) IS 'Stored procedure that returns a list of vehicle detail';


--
-- TOC entry 368 (class 1255 OID 83469)
-- Name: usp_vehicle_inspection_get(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_inspection_get(p_ivehicleid integer, p_slanguageid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$ 
declare ref_cursor refcursor :='ref_cursor';
declare p_language integer := p_slanguageid % 140;
begin

/**
 * Description: Stored procedure that returns a list of inspection<br />
 * Detailed explanation of the object.
 * @param p_ivehicleid     Vehicle primary key.
 * @return Return table vehicle inspection
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */
IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;
OPEN ref_cursor FOR 
	
SELECT 
    cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying) vresult,
    (SELECT cast(trim(split_part(spp.vdescription,'|', p_language)) as character varying) FROM systemparameter spp WHERE spp.igroupid = 4400 AND 
    spp.iparameterid = (CASE when split_part(p.vconcept,'|', 4) ='' THEN 0 else cast(trim(split_part(p.vconcept,'|', 4)) as integer) end) limit 1) vduration,
    vi.dinspectiondate, vi.dexpirydate dexpirydateinsp, pa.vfirstname vinspectorname, ws.vorganization vworkshopname
from vehicle_inspection vi inner join systemparameter sp
on vi.sresulttypeid = sp.iparameterid and sp.igroupid = 7200 inner join request_detail rd
on rd.ivehicleid = vi.ivehicleid and rd.iproductid = 13 inner join product_pricing  p
on p.ipricingid = rd.ipricingid left join party pa on vi.iinspectorid = pa.ipartyid
left join party ws on ws.ipartyid = vi.iworkshopid
where rd.ivehicleid = p_ivehicleid;

return ref_cursor;
end;
$$;


--
-- TOC entry 2643 (class 0 OID 0)
-- Dependencies: 368
-- Name: FUNCTION usp_vehicle_inspection_get(p_ivehicleid integer, p_slanguageid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_inspection_get(p_ivehicleid integer, p_slanguageid integer) IS 'Stored procedure that returns a list of inspection';


--
-- TOC entry 369 (class 1255 OID 83470)
-- Name: usp_vehicle_inspection_maintenance(integer, integer, smallint, character varying, timestamp without time zone, timestamp without time zone, smallint, integer, boolean, character varying, integer, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_inspection_maintenance(INOUT p_ivehicleinspectionid integer, p_ivehicleid integer, p_sresulttypeid smallint, p_vcertificatenumber character varying, p_dinspectiondate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sdurationinspection smallint, p_iinspectorid integer, p_bpaymentrequired boolean, p_vinspectorname character varying, p_iworkshopid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a vehicle inspection <br />
 * Detailed explanation of the object.
 * @param p_ivehicleinspectionid  Primary key.
 * @param p_ivehicleid            Code Vehicle.
 * @param p_sresulttypeid         Result type: refers to the table systemparameter "igroupid =  7200".
 * @param p_vcertificatenumber    Certificate number.
 * @param p_dinspectiondate       Inspection Date.
 * @param p_dexpirydate           Expiry Date.
 * @param p_sdurationinspection   Duration inspection.
 * @param p_iinspectorid          Inspector ID: refers to the table party "spartytypeid = 3402".
 * @param p_bpaymentrequired      Payment Required : 1=Active; 0=Inactive.
 * @param p_vinspectorname        Inspector name.
 * @param p_iworkshopid           Id Taller
 * @param p_sstatus               Status of vehicle.
 * @param p_iinsertuserid         User ID.
 * @param p_vinsertip             IP address user.
 * @param p_iupdateuserid         Update user ID.
 * @param p_vupdateip             Update user IP.
 * @param p_voption               Option.
 * @return Save, edit and delete a Vehicle Inspection
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

    IF p_vOption = 'INS' THEN

	SELECT Count(ivehicleinspectionid) into p_cnt FROM vehicle_inspection
	WHERE ivehicleinspectionid = p_ivehicleinspectionid; 

	IF p_cnt > 0 THEN
	UPDATE vehicle_inspection SET 
	      sresulttypeid = p_sresulttypeid,
	      vcertificatenumber = p_vcertificatenumber,
	      dinspectiondate = p_dinspectiondate,
	      dexpirydate = p_dexpirydate,
	      sdurationinspection = p_sdurationinspection,
	      iinspectorid = p_iinspectorid,
	      bpaymentrequired = p_bpaymentrequired,
	      vinspectorname = p_vinspectorname,
	      iworkshopid = p_iworkshopid,
	      sstatus = 1
	WHERE ivehicleinspectionid = p_ivehicleinspectionid;

	ELSE
	
	  INSERT INTO
	    vehicle_inspection
	    (
	      ivehicleid,
	      sresulttypeid,
	      vcertificatenumber,
	      dinspectiondate,
	      dexpirydate,
	      sdurationinspection,
	      iinspectorid,
	      bpaymentrequired,
              vinspectorname,
              iworkshopid,
	      sstatus,
	      iinsertuserid,
	      dinsertdate,
	      vinsertip
	    )
	    VALUES
	    (
	      p_ivehicleid,
	      p_sresulttypeid,
	      p_vcertificatenumber,
	      p_dinspectiondate,
	      p_dexpirydate,
	      p_sdurationinspection,
	      p_iinspectorid,
	      p_bpaymentrequired,
	      p_vinspectorname,
	      p_iworkshopid,
	      p_sstatus,
	      p_iinsertuserid,
	      now(),
	      p_vinsertip
	    );
	p_ivehicleinspectionid := (select currval('vehicle_inspection_seq'));

	END IF;
	
         ELSIF p_vOption = 'UPD' THEN

         UPDATE vehicle_inspection SET 
	      sresulttypeid = p_sresulttypeid,
	      vcertificatenumber = p_vcertificatenumber,
	      dinspectiondate = p_dinspectiondate,
	      dexpirydate = p_dexpirydate,
	      sdurationinspection = p_sdurationinspection,
	      iinspectorid = p_iinspectorid,
	      bpaymentrequired = p_bpaymentrequired,
              vinspectorname = p_vinspectorname,
	      iworkshopid = p_iworkshopid,
	      sstatus = 1
	WHERE ivehicleinspectionid = p_ivehicleinspectionid;

	ELSIF p_vOption = 'DEL'
	    THEN 
	     UPDATE vehicle_inspection
		    SET
		      sstatus = p_sstatus,
		      iupdateuserid = p_iupdateuserid,
		      dupdatedate = now(),
		      vupdateip = p_vupdateip
		    WHERE ivehicleinspectionid = p_ivehicleinspectionid;

END IF;
END;
$$;


--
-- TOC entry 2644 (class 0 OID 0)
-- Dependencies: 369
-- Name: FUNCTION usp_vehicle_inspection_maintenance(INOUT p_ivehicleinspectionid integer, p_ivehicleid integer, p_sresulttypeid smallint, p_vcertificatenumber character varying, p_dinspectiondate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sdurationinspection smallint, p_iinspectorid integer, p_bpaymentrequired boolean, p_vinspectorname character varying, p_iworkshopid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_inspection_maintenance(INOUT p_ivehicleinspectionid integer, p_ivehicleid integer, p_sresulttypeid smallint, p_vcertificatenumber character varying, p_dinspectiondate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sdurationinspection smallint, p_iinspectorid integer, p_bpaymentrequired boolean, p_vinspectorname character varying, p_iworkshopid integer, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that save, edit and delete a vehicle inspection';


--
-- TOC entry 370 (class 1255 OID 83471)
-- Name: usp_vehicle_insur_maintenance(integer, integer, integer, character varying, timestamp without time zone, timestamp without time zone, integer, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_insur_maintenance(INOUT p_iinsurance integer, p_ivehicleid integer, p_icompanyid integer, p_vcertificatenumber character varying, p_dissuedate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a vehicle insurance<br />
 * Detailed explanation of the object.
 * @param p_iinsurance          Primary key.
 * @param p_ivehicleid          Code Vehicle.
 * @param p_icompanyid            Company.
 * @param p_vcertificatenumber  Certificate number.
 * @param p_dissuedate          Issue Date.
 * @param p_dexpirydate         Expiry Date.
 * @param p_sstatus             Status of vehicle.
 * @param p_iinsertuserid       User ID.
 * @param p_vinsertip           IP address user.
 * @param p_iupdateuserid       Update user ID.
 * @param p_vupdateip           Update user IP.
 * @param p_voption             Action to perform.  'INS' - 'UPD' - 'DEL'
 * @return Save, edit and delete a Vehicle insurance
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

    IF p_vOption = 'INS' THEN

	SELECT Count(iinsuranceid) into p_cnt FROM vehicle_insurance 
	WHERE iinsuranceid = p_iinsurance; 

	IF p_cnt > 0 THEN
	UPDATE vehicle_insurance SET 
	      icompanyid = p_icompanyid,
	      vcertificatenumber = p_vcertificatenumber,
	      dissuedate = p_dissuedate,
	      dexpirydate = p_dexpirydate,
	      sstatus = 1
	WHERE iinsuranceid = p_iinsurance;

	ELSE
	
	  INSERT INTO
	    vehicle_insurance
	    (
	      ivehicleid,
	      vcertificatenumber,
	      dissuedate,
	      dexpirydate,
	      icompanyid,
	      sstatus,
	      iinsertuserid,
	      dinsertdate,
	      vinsertip
	    )
	    VALUES
	    (
	      p_ivehicleid,
	      p_vcertificatenumber,
	      p_dissuedate,
	      p_dexpirydate,
	      p_icompanyid,
	      p_sstatus,
	      p_iinsertuserid,
	      now(),
	      p_vinsertip
	    );
	p_iinsurance := (select currval('vehicle_insurance_seq'));

	END IF;
	
         ELSIF p_vOption = 'UPD' THEN

         UPDATE vehicle_insurance
		    SET
		      ivehicleid = p_ivehicleid,
		      icompanyid = p_icompanyid,
		      vcertificatenumber = p_vcertificatenumber,
		      dissuedate = p_dissuedate,
		      dexpirydate = p_dexpirydate,
		      sstatus = p_sstatus,
		      iupdateuserid = p_iupdateuserid,
		      dupdatedate = now(),
		      vupdateip = p_vupdateip
		    WHERE
		      iinsuranceid = p_iinsurance;

	ELSIF p_vOption = 'DEL'
	    THEN 
	     UPDATE vehicle_insurance
		    SET
		      sstatus = p_sstatus,
		      iupdateuserid = p_iupdateuserid,
		      dupdatedate = now(),
		      vupdateip = p_vupdateip
		    WHERE
		      iinsuranceid = p_iinsurance;

END IF;
END;
$$;


--
-- TOC entry 2645 (class 0 OID 0)
-- Dependencies: 370
-- Name: FUNCTION usp_vehicle_insur_maintenance(INOUT p_iinsurance integer, p_ivehicleid integer, p_icompanyid integer, p_vcertificatenumber character varying, p_dissuedate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_insur_maintenance(INOUT p_iinsurance integer, p_ivehicleid integer, p_icompanyid integer, p_vcertificatenumber character varying, p_dissuedate timestamp without time zone, p_dexpirydate timestamp without time zone, p_sstatus integer, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that save, edit and delete a vehicle insurance';


--
-- TOC entry 371 (class 1255 OID 83472)
-- Name: usp_vehicle_lien_maintenance(integer, integer, integer, character varying, timestamp without time zone, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_lien_maintenance(INOUT p_ibanklienid integer, p_ivehicleid integer, p_ilienholderid integer, p_vphonenumber character varying, p_dstartdate timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
BEGIN


/**
 * Description: Stored procedure that save, edit and delete a lien holder of a vechile<br />
 * Detailed explanation of the object.
 * @param p_ibanklienid         Primary key.
 * @param p_ivehicleid          Code Vehicle.
 * @param p_ilienholderid         Lien holder.
 * @param p_vphonenumber        Phone number.
 * @param p_dstartdate          Start Date.
 * @param p_sstatus             Status of vehicle.
 * @param p_iinsertuserid       User ID.
 * @param p_vinsertip           IP address user.
 * @param p_iupdateuserid       Update user ID.
 * @param p_vupdateip           Update user IP.
 * @param p_voption             Option.
 * @return Save, edit and delete a Vehicle
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */


    IF p_vOption = 'INS' THEN
	
	SELECT Count(ibanklienid) into p_cnt FROM vehicle_banklien 
	WHERE ibanklienid = p_ibanklienid; 

	IF p_cnt > 0 THEN
	UPDATE vehicle_banklien SET
		ilienholderid = p_ilienholderid,
		vphonenumber = p_vphonenumber,
		dstartdate = p_dstartdate,
		sstatus = 1
	WHERE ibanklienid = p_ibanklienid;

	ELSE
	
	INSERT
	  INTO
	    vehicle_banklien
	    (
		ivehicleid,
		vphonenumber,
		dstartdate,
	        ilienholderid,
		sstatus,
		iinsertuserid,
		dinsertdate,
		vinsertip
	    )
	    VALUES
	    (
		p_ivehicleid,
		p_vphonenumber,
		p_dstartdate,
		p_ilienholderid,
		p_sstatus,
		p_iinsertuserid,
		now(),
		p_vinsertip
	    );
	p_ibanklienid := (select currval('vehicle_lienbank_seq'));
	
	END IF;

         ELSIF p_vOption = 'UPD' THEN

         UPDATE vehicle_banklien
	      SET
		ivehicleid = p_ivehicleid,
		ilienholderid = p_ilienholderid,
		vphonenumber = p_vphonenumber,
		dstartdate = p_dstartdate,
		sstatus = p_sstatus,
		iupdateuserid = p_iupdateuserid,
		dupdatedate = now(),
		vupdateip = p_vupdateip
	    WHERE 
		ibanklienid = p_ibanklienid;

	ELSIF p_vOption = 'DEL'
	    THEN 
	     UPDATE vehicle_banklien
	      SET
		sstatus = p_sstatus,
		iupdateuserid = p_iupdateuserid,
		dupdatedate = now(),
		vupdateip = p_vupdateip
	    WHERE 
		ibanklienid = p_ibanklienid;

END IF;
END;
$$;


--
-- TOC entry 2646 (class 0 OID 0)
-- Dependencies: 371
-- Name: FUNCTION usp_vehicle_lien_maintenance(INOUT p_ibanklienid integer, p_ivehicleid integer, p_ilienholderid integer, p_vphonenumber character varying, p_dstartdate timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_lien_maintenance(INOUT p_ibanklienid integer, p_ivehicleid integer, p_ilienholderid integer, p_vphonenumber character varying, p_dstartdate timestamp without time zone, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that save, edit and delete a lien holder of a vehicle';


--
-- TOC entry 372 (class 1255 OID 83473)
-- Name: usp_vehicle_maintenance(integer, character varying, smallint, smallint, smallint, smallint, boolean, character varying, timestamp without time zone, character varying, integer, smallint, timestamp without time zone, double precision, double precision, character varying, integer, integer, integer, smallint, smallint, smallint, double precision, double precision, smallint, character varying, integer, character varying, character varying, smallint, integer, smallint, integer, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_maintenance(INOUT p_ivehicleid integer, p_vvehiclecode character varying, p_scategorytypeid smallint, p_sfuelsourcetypeid smallint, p_sprimarycolour smallint, p_ssecondarycolour smallint, p_bnew boolean, p_vusedby character varying, p_downedsince timestamp without time zone, p_venginenumber character varying, p_iseatingcapacity integer, p_smaximunload smallint, p_ddatestolen timestamp without time zone, p_fgrossweight double precision, p_funladenweigth double precision, p_vexportdetails character varying, p_imakeid integer, p_imodelid integer, p_iversionid integer, p_smanufacturingyear smallint, p_sseatnumber smallint, p_spassengernumber smallint, p_ftravellingwidthfeet double precision, p_foveralllengthfeet double precision, p_shanddriveid smallint, p_vtrailer character varying, p_iimportfrom integer, p_vorigin character varying, p_vvinnumber character varying, p_splatetypeid smallint, p_iownerid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare p_cnt integer := 0;
BEGIN

/**
 * Description: Stored procedure that save, edit and delete a vehicle<br />
 * Detailed explanation of the object.
 * @param p_ivehicleid          Primary key.
 * @param p_vvehiclecode        Code Vehicle.
 * @param p_scategorytypeid     Category type: refers to the table systemparameter "igroupid =  4000".
 * @param p_sfuelsourcetypeid   Fuel source type.
 * @param p_sprimarycolour      Primary color: refers to the table systemparameter "igroupid =  4700"..
 * @param p_ssecondarycolour    Secondary color: refers to the table systemparameter "igroupid =  4700"..
 * @param p_bnew                New.
 * @param p_vusedby             Used by.
 * @param p_downedsince         Date Owner since.
 * @param p_venginenumber       Engine number.
 * @param p_iseatingcapacity    Seating capacity.
 * @param p_smaximunload        Maximum load.
 * @param p_ddatestolen         Date stolen.
 * @param p_fgrossweight        Gross weigth.
 * @param p_funladenweigth      Unladen weigth.
 * @param p_vexportdetails      Export details.
 * @param p_imakeid             Make of vehicle: refers to the table vehiclecatalog "icatalogtypeid = 5101".
 * @param p_imodelid            Model of vehicle: refers to the table vehiclecatalog "icatalogtypeid = 5101".
 * @param p_iversionid          Version of vehicle: refers to the table vehiclecatalog "icatalogtypeid = 5101".
 * @param p_smanufacturingyear  Manufacturing year.
 * @param p_sseatnumber         Seat number.
 * @param p_spassengernumber    Passenger number.
 * @param p_ftravellingwidthfeet  Travelling width feet.
 * @param p_foveralllengthfeet  Overall length feet.
 * @param p_shanddriveid        Hand drive.
 * @param p_vtrailer            Trailer.
 * @param p_iimportfrom         Import from.
 * @param p_vorigin             Origin.
 * @param p_vvinnumber          Vin number.
 * @param p_splatetypeid        Plate type.
 * @param p_sstatus             Status of vehicle.
 * @param p_iinsertuserid       User ID.
 * @param p_vinsertip           IP address user.
 * @param p_iupdateuserid       Update user ID.
 * @param p_vupdateip           Update user IP.
 * @param p_voption             Option.
 * @return Save, edit and delete a Vehicle
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

    IF p_vOption = 'INS' THEN

	SELECT Count(ivehicleid) into p_cnt FROM vehicle 
	WHERE ivehicleid = p_ivehicleid; 

	IF p_cnt > 0 THEN
	UPDATE vehicle SET
	      vvehiclecode = COALESCE(p_vvehiclecode,vvehiclecode), 
	      scategorytypeid = COALESCE(p_scategorytypeid,scategorytypeid), 
	      sfuelsourcetypeid = COALESCE(p_sfuelsourcetypeid,sfuelsourcetypeid), 
	      sprimarycolourid = COALESCE(p_sprimarycolour,sprimarycolourid), 
	      ssecondarycolourid = COALESCE(p_ssecondarycolour,ssecondarycolourid), 
	      bnew = COALESCE(p_bnew,bnew), 
	      vusedby = COALESCE(p_vusedby,vusedby), 
	      downedsince = COALESCE(p_downedsince,downedsince), 
	      venginenumber = COALESCE(p_venginenumber,venginenumber), 
	      iseatingcapacity = COALESCE(p_iseatingcapacity,iseatingcapacity), 
	      smaximunload = COALESCE(p_smaximunload,smaximunload), 
	      ddatestolen = COALESCE(p_ddatestolen,ddatestolen), 
	      fgrossweight = COALESCE(p_fgrossweight,fgrossweight), 
	      funladenweigth = COALESCE(p_funladenweigth,funladenweigth), 
	      vexportdetails = COALESCE(p_vexportdetails,vexportdetails), 
	      imakeid = COALESCE(p_imakeid,imakeid), 
	      imodelid = COALESCE(p_imodelid,imodelid), 
	      iversionid = COALESCE(p_iversionid,iversionid), 
	      smanufacturingyear = COALESCE(p_smanufacturingyear,smanufacturingyear), 
	      sseatnumber = COALESCE(p_sseatnumber,sseatnumber), 
	      spassengernumber = COALESCE(p_spassengernumber,spassengernumber), 
	      ftravellingwidthfeet = COALESCE(p_ftravellingwidthfeet,ftravellingwidthfeet), 
	      foveralllengthfeet = COALESCE(p_foveralllengthfeet,foveralllengthfeet), 
	      shanddriveid = COALESCE(p_shanddriveid,shanddriveid), 
	      vtrailer = COALESCE(p_vtrailer,vtrailer), 
	      iimportfrom = COALESCE(p_iimportfrom,iimportfrom), 
	      vorigin = COALESCE(p_vorigin,vorigin), 
	      vvinnumber = COALESCE(p_vvinnumber,vvinnumber), 
	      splatetypeid = COALESCE(p_splatetypeid,splatetypeid), 
	      iownerid =  COALESCE(p_iownerid,iownerid),
	      sstatus = COALESCE(p_sstatus,1),  
	      iupdateuserid = p_iupdateuserid,
	      dupdatedate = now(),
              vupdateip = COALESCE(p_vupdateip,'1')
	WHERE ivehicleid = p_ivehicleid; 

	ELSE

	INSERT INTO vehicle(
             vvehiclecode,
	      scategorytypeid,
	      sfuelsourcetypeid,
	      sprimarycolourid,
	      ssecondarycolourid,
	      bnew,
	      vusedby,
	      downedsince,
	      venginenumber,
	      iseatingcapacity,
	      smaximunload,
	      ddatestolen,
	      fgrossweight,
	      funladenweigth,
	      vexportdetails,
	      imakeid,
	      imodelid,
	      iversionid,
	      smanufacturingyear,
	      sseatnumber,
	      spassengernumber,
	      ftravellingwidthfeet,
	      foveralllengthfeet,
	      shanddriveid,
	      vtrailer,
	      iimportfrom,
	      vorigin,
	      vvinnumber,
	      splatetypeid,
	      iownerid,
	      sstatus,
	      iinsertuserid,
	      dinsertdate,
	      vinsertip
             )
    VALUES (
	      p_vvehiclecode,
	      p_scategorytypeid,
	      p_sfuelsourcetypeid,
	      p_sprimarycolour,
	      p_ssecondarycolour,
	      p_bnew,
	      p_vusedby,
	      p_downedsince,
	      p_venginenumber,
	      p_iseatingcapacity,
	      p_smaximunload,
	      p_ddatestolen,
	      p_fgrossweight,
	      p_funladenweigth,
	      p_vexportdetails,
	      p_imakeid,
	      p_imodelid,
	      p_iversionid,
	      p_smanufacturingyear,
	      p_sseatnumber,
	      p_spassengernumber,
	      p_ftravellingwidthfeet,
	      p_foveralllengthfeet,
	      p_shanddriveid,
	      p_vtrailer,
	      p_iimportfrom,
	      p_vorigin,
	      p_vvinnumber,
	      p_splatetypeid,
	      p_iownerid,
	      p_sstatus,
	      p_iinsertuserid,
	      now(),
	      p_vinsertip
            );

	p_ivehicleid := (select currval('vehicle_seq'));

	END IF;
	
         ELSIF p_vOption = 'UPD' THEN
	
          UPDATE vehicle  SET   
	      vvehiclecode = COALESCE(p_vvehiclecode,vvehiclecode), 
	      scategorytypeid = COALESCE(p_scategorytypeid,scategorytypeid), 
	      sfuelsourcetypeid = COALESCE(p_sfuelsourcetypeid,sfuelsourcetypeid), 
	      sprimarycolourid = COALESCE(p_sprimarycolour,sprimarycolourid), 
	      ssecondarycolourid = COALESCE(p_ssecondarycolour,ssecondarycolourid), 
	      bnew = COALESCE(p_bnew,bnew), 
	      vusedby = COALESCE(p_vusedby,vusedby), 
	      downedsince = COALESCE(p_downedsince,downedsince), 
	      venginenumber = COALESCE(p_venginenumber,venginenumber), 
	      iseatingcapacity = COALESCE(p_iseatingcapacity,iseatingcapacity), 
	      smaximunload = COALESCE(p_smaximunload,smaximunload), 
	      ddatestolen = COALESCE(p_ddatestolen,ddatestolen), 
	      fgrossweight = COALESCE(p_fgrossweight,fgrossweight), 
	      funladenweigth = COALESCE(p_funladenweigth,funladenweigth), 
	      vexportdetails = COALESCE(p_vexportdetails,vexportdetails), 
	      imakeid = COALESCE(p_imakeid,imakeid), 
	      imodelid = COALESCE(p_imodelid,imodelid), 
	      iversionid = COALESCE(p_iversionid,iversionid), 
	      smanufacturingyear = COALESCE(p_smanufacturingyear,smanufacturingyear), 
	      sseatnumber = COALESCE(p_sseatnumber,sseatnumber), 
	      spassengernumber = COALESCE(p_spassengernumber,spassengernumber), 
	      ftravellingwidthfeet = COALESCE(p_ftravellingwidthfeet,ftravellingwidthfeet), 
	      foveralllengthfeet = COALESCE(p_foveralllengthfeet,foveralllengthfeet), 
	      shanddriveid = COALESCE(p_shanddriveid,shanddriveid), 
	      vtrailer = COALESCE(p_vtrailer,vtrailer), 
	      iimportfrom = COALESCE(p_iimportfrom,iimportfrom), 
	      vorigin = COALESCE(p_vorigin,vorigin), 
	      vvinnumber = COALESCE(p_vvinnumber,vvinnumber), 
	      splatetypeid = COALESCE(p_splatetypeid,splatetypeid), 
	      iownerid =  COALESCE(p_iownerid,iownerid),
	      sstatus = COALESCE(case when p_sstatus=0 then sstatus else p_sstatus end,sstatus),
	      iupdateuserid = p_iupdateuserid,
	      dupdatedate = now(),
              vupdateip = COALESCE(p_vupdateip,'1')
		WHERE ivehicleid = p_ivehicleid;

	ELSIF p_vOption = 'DEL'
	    THEN 
	    UPDATE vehicle SET 
				      sstatus = p_sstatus,
				      iupdateuserid = p_iupdateuserid,
				      dupdatedate = now(),
				      vupdateip = p_vupdateip
	    WHERE ivehicleid = p_ivehicleid;

END IF;
END;
$$;


--
-- TOC entry 2647 (class 0 OID 0)
-- Dependencies: 372
-- Name: FUNCTION usp_vehicle_maintenance(INOUT p_ivehicleid integer, p_vvehiclecode character varying, p_scategorytypeid smallint, p_sfuelsourcetypeid smallint, p_sprimarycolour smallint, p_ssecondarycolour smallint, p_bnew boolean, p_vusedby character varying, p_downedsince timestamp without time zone, p_venginenumber character varying, p_iseatingcapacity integer, p_smaximunload smallint, p_ddatestolen timestamp without time zone, p_fgrossweight double precision, p_funladenweigth double precision, p_vexportdetails character varying, p_imakeid integer, p_imodelid integer, p_iversionid integer, p_smanufacturingyear smallint, p_sseatnumber smallint, p_spassengernumber smallint, p_ftravellingwidthfeet double precision, p_foveralllengthfeet double precision, p_shanddriveid smallint, p_vtrailer character varying, p_iimportfrom integer, p_vorigin character varying, p_vvinnumber character varying, p_splatetypeid smallint, p_iownerid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehicle_maintenance(INOUT p_ivehicleid integer, p_vvehiclecode character varying, p_scategorytypeid smallint, p_sfuelsourcetypeid smallint, p_sprimarycolour smallint, p_ssecondarycolour smallint, p_bnew boolean, p_vusedby character varying, p_downedsince timestamp without time zone, p_venginenumber character varying, p_iseatingcapacity integer, p_smaximunload smallint, p_ddatestolen timestamp without time zone, p_fgrossweight double precision, p_funladenweigth double precision, p_vexportdetails character varying, p_imakeid integer, p_imodelid integer, p_iversionid integer, p_smanufacturingyear smallint, p_sseatnumber smallint, p_spassengernumber smallint, p_ftravellingwidthfeet double precision, p_foveralllengthfeet double precision, p_shanddriveid smallint, p_vtrailer character varying, p_iimportfrom integer, p_vorigin character varying, p_vvinnumber character varying, p_splatetypeid smallint, p_iownerid integer, p_sstatus smallint, p_iinsertuserid integer, p_vinsertip character varying, p_iupdateuserid integer, p_vupdateip character varying, p_voption character varying) IS 'Stored procedure that save, edit and delete a vehicle';


--
-- TOC entry 373 (class 1255 OID 83475)
-- Name: usp_vehicle_search(integer, integer, integer, character varying, integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehicle_search(p_ivehicleid integer, p_irequestid integer, p_ipartyid integer, p_vstatusvehicle character varying, p_slanguageid integer, p_vstatuslicense character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE p_language integer := p_slanguageid % 140;
declare ref_cursor REFCURSOR := 'ref_cursor';
BEGIN
/**
 * Description: Stored procedure that returns a list of vehicles <br />
 * Detailed explanation of the object.
 * @param p_ivehicleid    Code of vehicle.
 * @param p_irequestid    Code of request.
 * @param p_ipartyid      Code of party.
 * @return Return table records vehicle.
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

IF (p_language is null or p_language = 0) THEN p_language := 1; END IF;

create temp table tbltmp_vehicles (ivehicleid integer, vnumberplate character varying(200), vplatepreview character varying(50), 
dlicensestart timestamp, dlicensefinish timestamp, splatetypeid smallint, irequestlicenseid integer, sdurationlicense integer, 
vstatuslicense character varying, sstatuslicense integer, vstatusvehicle character varying, sstatusvehicle integer) on commit drop;

INSERT INTO tbltmp_vehicles 
select ivehicleid, null, null, null, null, null, xxx, null, null, null, null, statusvehicle from 
(
----------------------------
select distinct v.ivehicleid, 
(select max(rl2.irequestlicenseid) from request_license rl2 inner join request_detail rd2 
on rd2.irequestlicenseid = rl2.irequestlicenseid where v.ivehicleid = rd2.ivehicleid and 4801 = rl2.slicensetypeid) as xxx,
v.sstatus as statusvehicle
from vehicle v 
where (p_ipartyid = 0 or p_ipartyid = iownerid) and (p_ivehicleid = 0 or p_ivehicleid = ivehicleid) and 
(p_vstatusvehicle = '0' OR v.sstatus in (select cast(regexp_split_to_table(p_vstatusvehicle, ',')as int)))
----------------------------
) as tablamuestra  left join request_license rl3 on rl3.irequestlicenseid = xxx 
where (p_vstatuslicense is null or rl3.sstatus in (select cast(regexp_split_to_table(p_vstatuslicense, ',') as int)));

update tbltmp_vehicles set 
vnumberplate = rl.vnumberplate,
vplatepreview = rl.vplatepreview,
dlicensestart = rl.dstartdate, --COALESCE(rl.dstartdate,now())
dlicensefinish = rl.dexpirydate, --COALESCE(rl.dexpirydate,now())
splatetypeid = rl.splatetypeid, --COALESCE(rl.splatetypeid,0)
sdurationlicense = rl.sdurationlicense,
vstatuslicense = cast(trim(split_part(sp.vdescription,'|', p_language)) as character varying),
sstatuslicense = rl.sstatus,
vstatusvehicle = (select cast(trim(split_part(sp2.vdescription,'|', p_language)) as character varying) from systemparameter sp2 
where sp2.igroupid = 4900 and sp2.iparameterid = tbltmp_vehicles.sstatusvehicle)
from request_license rl
left join systemparameter sp on sp.igroupid = 4900 and sp.iparameterid = rl.sstatus
where rl.irequestlicenseid = tbltmp_vehicles.irequestlicenseid;

OPEN ref_cursor FOR 

SELECT DISTINCT
--DATOS VEHICULO
COALESCE(v.ivehicleid, 0) as ivehicleid,
COALESCE(vvehiclecode,'') as vvehiclecode,
COALESCE(scategorytypeid,0) as scategorytypeid,
COALESCE(sfuelsourcetypeid,0) as sfuelsourcetypeid,
COALESCE(sprimarycolourid,0) as sprimarycolourid,
COALESCE(ssecondarycolourid,0) as ssecondarycolourid,
COALESCE(bnew,false) as bnew,
COALESCE(vusedby,'') as vusedby,
COALESCE(downedsince,null) as downedsince,
COALESCE(venginenumber,'') as venginenumber,
COALESCE(iseatingcapacity,0) as iseatingcapacity,
COALESCE(smaximunload,0) as smaximunload,
COALESCE(ddatestolen,null) as ddatestolen,
COALESCE(fgrossweight,0) as fgrossweight,
COALESCE(funladenweigth,0) as funladenweigth,
COALESCE(vexportdetails,'') as vexportdetails,
COALESCE(imodelid,0) as imodelid,
COALESCE(iversionid,0) as imodelversion,
COALESCE(smanufacturingyear,0) as smanufacturingyear,
COALESCE(sseatnumber,0) as sseatnumber,
COALESCE(spassengernumber,0) as spassengernumber,
COALESCE(ftravellingwidthfeet,0) as ftravellingwidthfeet,
COALESCE(foveralllengthfeet,0) as foveralllengthfeet,
COALESCE(shanddriveid,0) as shanddriveid,
COALESCE(vtrailer,'') as vtrailer,
COALESCE(iimportfrom,0) as iimportfrom,
COALESCE(vorigin,'') as vorigin,
COALESCE(vvinnumber,'') as vvinnumber,
COALESCE(imakeid,0) as imakeid,
--VEHICLE INSURANCE
COALESCE(vi.iinsuranceid,0) as iinsuranceid,
COALESCE(vi.icompanyid,0) as icompanyid,
COALESCE(vi.vcertificatenumber,'') as vcertificatenumber,
COALESCE(vi.dissuedate,null) as dissuedate, --COALESCE(vi.dissuedate,null)
COALESCE(vi.dexpirydate,null) as dexpirydate, --COALESCE(vi.dexpirydate,null)
--VEHICLE LIEN
COALESCE(vl.ibanklienid,0) as ibanklienid,
COALESCE(vl.ilienholderid,0) as ilienholderid,
COALESCE(vl.vphonenumber,'') as vphonenumber,
COALESCE(vl.dstartdate,now()) as dstartdate,	
--OTROS
COALESCE(v.iownerid) as ipartyid, --p.ipartyid) as ipartyid,
0 as irequestid,--COALESCE(r.irequestid,0) as irequestid,
0 as iproductid,--COALESCE(r.iproductid,0) as iproductid,
COALESCE(vc.vdescription,'') as vmakedesc,
COALESCE(vc1.vdescription,'') as vmodeldesc,
COALESCE(vc2.vdescription,'') as vmodelversion,
(select ee.vnumberplate from tbltmp_vehicles ee where ee.vnumberplate is not null and ee.vnumberplate!='0' and ee.ivehicleid = ve.ivehicleid),
--VEHICLE INSPECTION
COALESCE(vins.ivehicleinspectionid) as ivehicleinspectionid,
COALESCE(vins.dinspectiondate) as dinspectiondate,
COALESCE(vins.dexpirydate) as dexpirydateinsp,
COALESCE(vins.sdurationinspection) as sdurationinspection,
COALESCE(vins.iworkshopid) as iworkshopid,
--COALESCE(v.splatetypeid,0) as splatetypeid,
COALESCE(ve.splatetypeid,0) as splatetypeid,
COALESCE(ve.vplatepreview,'') as vplatepreview,
COALESCE(vins.vinspectorname, '') as vinspectorname,
COALESCE(ve.dlicensestart, now()) as dlicensestart,
COALESCE(ve.dlicensefinish, now()) as dlicensefinish,
COALESCE(ve.irequestlicenseid, 0) as irequestlicenseid,
COALESCE(vins.iinspectorid, 0) as iinspectorid,
COALESCE(vins.sresulttypeid, 0) as sresulttypeid,
COALESCE(ve.sdurationlicense, 0) as sdurationlicense,
ve.vstatusvehicle as vstatusvehicle,
COALESCE(ve.vstatuslicense, '') as vstatuslicense,
COALESCE(ve.sstatuslicense, 0) as sstatuslicense,
ve.sstatusvehicle as  sstatusvehicle,
(select  (COALESCE(r.sstatus,0) || '|' || 
		(CASE WHEN r.dupdatedate is null then 
			COALESCE((TO_TIMESTAMP(cast(r.dinsertdate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null) 
			else 
			COALESCE((TO_TIMESTAMP(cast(r.dupdatedate as text), 'YYYY/MM/DD HH24:MI:SS')::timestamp),null)	
		end)  || '|' ||  r.irequestid) A            from request r inner join request_detail rd
				on r.irequestid = rd.irequestid
				where rd.ivehicleid = v.ivehicleid order by r.dinsertdate desc limit 1) sstatusRequestDate
FROM tbltmp_vehicles ve 
INNER JOIN vehicle v on ve.ivehicleid = v.ivehicleid
LEFT JOIN vehicle_catalog vc ON vc.ivehiclecatalogid = v.imakeid AND vc.icatalogtypeid = 5101 
LEFT JOIN vehicle_catalog vc1 ON vc1.ivehiclecatalogid = v.imodelid AND vc1.icatalogtypeid = 5102 
LEFT JOIN vehicle_catalog vc2 ON vc2.ivehiclecatalogid = v.iversionid AND vc2.icatalogtypeid = 5103  
LEFT JOIN vehicle_insurance vi ON vi.ivehicleid = v.ivehicleid
LEFT JOIN vehicle_banklien vl ON vl.ivehicleid = v.ivehicleid
LEFT JOIN vehicle_inspection vins ON vins.ivehicleid = v.ivehicleid
LEFT JOIN request_detail rd ON v.ivehicleid = rd.ivehicleid
INNER JOIN request r ON r.irequestid = rd.irequestid 
WHERE  (p_ivehicleid = 0 or v.ivehicleid = p_ivehicleid)
AND  (p_irequestid = 0 or rd.irequestid = p_irequestid)
--AND (p_ipartyid = 0 or p_ipartyid = v.iownerid) --p.ipartyid)
AND  (r.iproductid = 29 OR r.iproductid = 9 or r.iproductid = 52 or r.iproductid = 53);
--AND (p_vstatusvehicle = '0' OR v.sstatus in (select cast(regexp_split_to_table(p_vstatusvehicle, ',')as int)));
RETURN ref_cursor;
END;
$$;


--
-- TOC entry 374 (class 1255 OID 83477)
-- Name: usp_vehiclecatalog_get(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION usp_vehiclecatalog_get(p_ireferenceid integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
    declare ref_cursor REFCURSOR := 'ref_cursor';
    BEGIN

	
/**
 * Description: Stored procedure that returns a list of vehicle catalog<br />
 * Detailed explanation of the object.
 * @param p_ivehicleid   Code of vehicle.
 * @return Return table records of vehicle catalog
 * @author  stello
 * @version 1.0 stello 26/07/2016<BR/> 
 */

      OPEN ref_cursor FOR SELECT vc.ivehiclecatalogid,vdescription
				FROM vehicle_catalog vc
				 WHERE   vc.ireferenceid = p_ireferenceid
				 AND vc.sstatus = 1;
				

      RETURN ref_cursor;
    END;
$$;


--
-- TOC entry 2648 (class 0 OID 0)
-- Dependencies: 374
-- Name: FUNCTION usp_vehiclecatalog_get(p_ireferenceid integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION usp_vehiclecatalog_get(p_ireferenceid integer) IS 'Stored procedure returns a list of vehicle catalog according to parameters entered';


--
-- TOC entry 193 (class 1259 OID 83478)
-- Name: appointment_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE appointment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 194 (class 1259 OID 83480)
-- Name: appointment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE appointment (
    iappointmentid integer DEFAULT nextval('appointment_seq'::regclass) NOT NULL,
    ischeduleid integer NOT NULL,
    ipartyid integer NOT NULL,
    vcancellationnote character varying(300),
    sresultexaminationid smallint,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2649 (class 0 OID 0)
-- Dependencies: 194
-- Name: TABLE appointment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE appointment IS 'Table that stores information about the quotes from participants';


--
-- TOC entry 2650 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.iappointmentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.iappointmentid IS 'Primary auto increment key';


--
-- TOC entry 2651 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.ischeduleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.ischeduleid IS 'Schedule id';


--
-- TOC entry 2652 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.ipartyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.ipartyid IS 'Party id';


--
-- TOC entry 2653 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.vcancellationnote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.vcancellationnote IS 'Cancellation note';


--
-- TOC entry 2654 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.sresultexaminationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.sresultexaminationid IS 'Result examination id';


--
-- TOC entry 2655 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.sstatus IS 'Status';


--
-- TOC entry 2656 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.iinsertuserid IS 'User ID';


--
-- TOC entry 2657 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.dinsertdate IS 'Registration date';


--
-- TOC entry 2658 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.vinsertip IS 'IP address user';


--
-- TOC entry 2659 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2660 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.dupdatedate IS 'Updated date';


--
-- TOC entry 2661 (class 0 OID 0)
-- Dependencies: 194
-- Name: COLUMN appointment.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN appointment.vupdateip IS 'Update user IP';


--
-- TOC entry 195 (class 1259 OID 83484)
-- Name: authorization_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorization_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 196 (class 1259 OID 83486)
-- Name: authorization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "authorization" (
    iauthorizationid integer DEFAULT nextval('authorization_seq'::regclass) NOT NULL,
    irequestid integer NOT NULL,
    isystemuserid integer NOT NULL,
    dissuedate timestamp without time zone NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2662 (class 0 OID 0)
-- Dependencies: 196
-- Name: TABLE "authorization"; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE "authorization" IS 'Table that stores information of all Authorization';


--
-- TOC entry 2663 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".iauthorizationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".iauthorizationid IS 'Primary auto-increment key';


--
-- TOC entry 2664 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".irequestid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".irequestid IS 'Referring to table request';


--
-- TOC entry 2665 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".isystemuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".isystemuserid IS 'Referring to table systemuser';


--
-- TOC entry 2666 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".dissuedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".dissuedate IS 'Date of issued';


--
-- TOC entry 2667 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".sstatus IS 'It represents the status of authorization; 1= Active; 0= Inactive';


--
-- TOC entry 2668 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".iinsertuserid IS 'User ID';


--
-- TOC entry 2669 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".dinsertdate IS 'Updated user ID';


--
-- TOC entry 2670 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".vinsertip IS 'IP address user';


--
-- TOC entry 2671 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2672 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".dupdatedate IS 'Updated date';


--
-- TOC entry 2673 (class 0 OID 0)
-- Dependencies: 196
-- Name: COLUMN "authorization".vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN "authorization".vupdateip IS 'Update user IP';


--
-- TOC entry 197 (class 1259 OID 83490)
-- Name: country_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE country_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 198 (class 1259 OID 83492)
-- Name: country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE country (
    scountryid smallint DEFAULT nextval('country_seq'::regclass) NOT NULL,
    vcountrycode character varying(50) NOT NULL,
    vname character varying(100) NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50),
    ilicenseid integer
);


--
-- TOC entry 2674 (class 0 OID 0)
-- Dependencies: 198
-- Name: TABLE country; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE country IS 'Table containing the description of countries';


--
-- TOC entry 2675 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.scountryid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.scountryid IS 'Primary auto-increment key';


--
-- TOC entry 2676 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.vcountrycode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.vcountrycode IS 'Code to identify the country';


--
-- TOC entry 2677 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.vname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.vname IS 'Country name';


--
-- TOC entry 2678 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.sstatus IS 'State of the country';


--
-- TOC entry 2679 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.iinsertuserid IS 'User ID';


--
-- TOC entry 2680 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.dinsertdate IS 'Registration date';


--
-- TOC entry 2681 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.vinsertip IS 'IP address user';


--
-- TOC entry 2682 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2683 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.dupdatedate IS 'Updated date';


--
-- TOC entry 2684 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.vupdateip IS 'Update user IP';


--
-- TOC entry 2685 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN country.ilicenseid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN country.ilicenseid IS 'Referring to table license';


--
-- TOC entry 199 (class 1259 OID 83496)
-- Name: document_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE document_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 200 (class 1259 OID 83498)
-- Name: document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE document (
    idocumentid integer DEFAULT nextval('document_seq'::regclass) NOT NULL,
    vdocumentcode character varying,
    vname character varying,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2686 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE document; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE document IS 'Table that stores the types of documentation';


--
-- TOC entry 2687 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.idocumentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.idocumentid IS 'Primary key to identify the country';


--
-- TOC entry 2688 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.vdocumentcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.vdocumentcode IS 'Code to identify the document';


--
-- TOC entry 2689 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.vname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.vname IS 'document description ';


--
-- TOC entry 2690 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.sstatus IS 'Document Status';


--
-- TOC entry 2691 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.iinsertuserid IS 'User ID';


--
-- TOC entry 2692 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.dinsertdate IS 'Registration date';


--
-- TOC entry 2693 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.vinsertip IS 'IP address user';


--
-- TOC entry 2694 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2695 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.dupdatedate IS 'Updated date';


--
-- TOC entry 2696 (class 0 OID 0)
-- Dependencies: 200
-- Name: COLUMN document.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN document.vupdateip IS 'Update user IP';


--
-- TOC entry 201 (class 1259 OID 83505)
-- Name: exchangerate_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exchangerate_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 202 (class 1259 OID 83507)
-- Name: exchangerate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE exchangerate (
    iexchangerateid integer DEFAULT nextval('exchangerate_seq'::regclass) NOT NULL,
    famount real NOT NULL,
    scurrencyid smallint NOT NULL,
    dstartdate timestamp without time zone NOT NULL,
    dfinishdate timestamp without time zone NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2697 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE exchangerate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE exchangerate IS 'Table that stores information of all exchangerate';


--
-- TOC entry 2698 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.iexchangerateid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.iexchangerateid IS 'Primary auto-increment key';


--
-- TOC entry 2699 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.famount; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.famount IS 'Amount of exchange';


--
-- TOC entry 2700 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.scurrencyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.scurrencyid IS 'Referring to Table systemparameter 
Group CONFIGURATION_CURRENCY = 2300 : 2301 => USD; 2302 => PAB; 2303 => S /.';


--
-- TOC entry 2701 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.dstartdate IS 'Start date exchange rate';


--
-- TOC entry 2702 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.dfinishdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.dfinishdate IS 'Finish date exchange rate';


--
-- TOC entry 2703 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.sstatus IS 'It represents the status of exchangerate; 0 = Off y 1 = Active';


--
-- TOC entry 2704 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.iinsertuserid IS 'User ID';


--
-- TOC entry 2705 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.dinsertdate IS 'Registration date';


--
-- TOC entry 2706 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.vinsertip IS 'IP address user';


--
-- TOC entry 2707 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2708 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.dupdatedate IS 'Updated date';


--
-- TOC entry 2709 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN exchangerate.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN exchangerate.vupdateip IS 'Update user IP';


--
-- TOC entry 260 (class 1259 OID 84116)
-- Name: location_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE location_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 203 (class 1259 OID 83513)
-- Name: location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE location (
    ilocationid integer DEFAULT nextval('location_seq'::regclass) NOT NULL,
    slocationtypeid smallint NOT NULL,
    slevelid smallint NOT NULL,
    scountryid smallint NOT NULL,
    vdescription character varying(100) NOT NULL,
    ireferenceid integer,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2710 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE location IS 'Table that stores information regarding locations';


--
-- TOC entry 2711 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.ilocationid IS 'Primary key to identify the location';


--
-- TOC entry 2712 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.slocationtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.slocationtypeid IS 'Location type id ';


--
-- TOC entry 2713 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.slevelid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.slevelid IS 'location lavel id';


--
-- TOC entry 2714 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.scountryid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.scountryid IS 'Country id';


--
-- TOC entry 2715 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.vdescription IS 'Location description';


--
-- TOC entry 2716 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.ireferenceid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.ireferenceid IS 'Location refernce id';


--
-- TOC entry 2717 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.sstatus IS 'Location Status';


--
-- TOC entry 2718 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.iinsertuserid IS 'User ID';


--
-- TOC entry 2719 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.dinsertdate IS 'Registration date';


--
-- TOC entry 2720 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.vinsertip IS 'IP address user';


--
-- TOC entry 2721 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2722 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.dupdatedate IS 'Updated date';


--
-- TOC entry 2723 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN location.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN location.vupdateip IS 'Update user IP';


--
-- TOC entry 204 (class 1259 OID 83517)
-- Name: note_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE note_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 205 (class 1259 OID 83519)
-- Name: note; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE note (
    inoteid integer DEFAULT nextval('note_seq'::regclass) NOT NULL,
    irequestdetailid integer,
    ipartyfromid integer,
    ipartyforid integer,
    snotecategoryid smallint,
    vtabname character varying,
    vobservation character varying,
    ireferencenoteid integer,
    snotesubcategoryid smallint,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2724 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE note; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE note IS 'Table that stores Note';


--
-- TOC entry 206 (class 1259 OID 83526)
-- Name: office_examinationtype_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE office_examinationtype_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 207 (class 1259 OID 83528)
-- Name: office_examinationtype; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE office_examinationtype (
    iofficeexaminationtypeid integer DEFAULT nextval('office_examinationtype_seq'::regclass) NOT NULL,
    ilocationid integer NOT NULL,
    sexaminationtypeid smallint NOT NULL,
    snumberperson smallint NOT NULL,
    vnote character varying(400),
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2725 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE office_examinationtype; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE office_examinationtype IS 'Table that stores information of the types of examination located in offices';


--
-- TOC entry 2726 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.iofficeexaminationtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.iofficeexaminationtypeid IS 'Primary auto-increment key';


--
-- TOC entry 2727 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.ilocationid IS 'Location id';


--
-- TOC entry 2728 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.sexaminationtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.sexaminationtypeid IS 'Examination type id';


--
-- TOC entry 2729 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.snumberperson; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.snumberperson IS 'Person number ';


--
-- TOC entry 2730 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.vnote; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.vnote IS 'Description the notes';


--
-- TOC entry 2731 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.sstatus IS 'Status';


--
-- TOC entry 2732 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.iinsertuserid IS 'User ID';


--
-- TOC entry 2733 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.dinsertdate IS 'Registration date';


--
-- TOC entry 2734 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.vinsertip IS 'IP address user';


--
-- TOC entry 2735 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2736 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.dupdatedate IS 'Updated date';


--
-- TOC entry 2737 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN office_examinationtype.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN office_examinationtype.vupdateip IS 'Update user IP';


--
-- TOC entry 208 (class 1259 OID 83535)
-- Name: p_ipartyid; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE p_ipartyid (
    "coalesce" integer
);


--
-- TOC entry 209 (class 1259 OID 83538)
-- Name: party_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE party_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 210 (class 1259 OID 83540)
-- Name: party; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE party (
    ipartyid integer DEFAULT nextval('party_seq'::regclass) NOT NULL,
    spartytypeid smallint,
    spartysubtypeid smallint,
    sdocumenttypeid smallint,
    vdocumentnumber character varying,
    vlastname character varying,
    vmiddlename character varying,
    vmaidenname character varying,
    vfirstname character varying,
    vorganization character varying,
    scountrybirth smallint,
    snationalityid smallint,
    ipartyaddressid integer,
    vpartycode character varying,
    sgenderid smallint,
    fheigth double precision,
    ddateofbirth timestamp without time zone,
    bdeceased boolean,
    seyecolourid smallint,
    shaircolourid smallint,
    bdisqualified boolean,
    vdisability character varying,
    vphoto character varying,
    vemailaddress character varying,
    vcontactinformation character varying,
    vphonenumberinformation character varying,
    bonlineaccess boolean,
    ddisqualifiedstartdate timestamp without time zone,
    ddisqualifiedenddate timestamp without time zone,
    bnocheques boolean,
    vcommentdeceased character varying,
    vcommentdisqualified character varying,
    vcommentnocheques character varying,
    vcodeonlineacces character varying,
    sstatus integer,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2738 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE party; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE party IS 'Table that stores all types of users';


--
-- TOC entry 2739 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.ipartyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.ipartyid IS 'Id primary key';


--
-- TOC entry 2740 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.spartytypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.spartytypeid IS 'relation to systemparameter igropud = 3400';


--
-- TOC entry 2741 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.spartysubtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.spartysubtypeid IS 'Type of organization, relation to systemparameter igropud = 3440';


--
-- TOC entry 2742 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.sdocumenttypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.sdocumenttypeid IS 'Type document, relation to systemparameter igropud = 3420';


--
-- TOC entry 2743 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vdocumentnumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vdocumentnumber IS 'Document Number';


--
-- TOC entry 2744 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vlastname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vlastname IS 'Last name';


--
-- TOC entry 2745 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vmiddlename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vmiddlename IS 'Middle name';


--
-- TOC entry 2746 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vmaidenname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vmaidenname IS 'Maiden name';


--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vfirstname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vfirstname IS 'Firts name';


--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vorganization; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vorganization IS 'Organization name';


--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.snationalityid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.snationalityid IS 'Current nationality';


--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.ipartyaddressid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.ipartyaddressid IS 'relation to table country';


--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vpartycode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vpartycode IS 'Personalized unique code considering any format';


--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.sgenderid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.sgenderid IS 'relation to systemparameter igropud = 3490';


--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.fheigth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.fheigth IS 'Heigth';


--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.ddateofbirth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.ddateofbirth IS 'Date of birth';


--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.bdeceased; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.bdeceased IS 'Is Deceased';


--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.seyecolourid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.seyecolourid IS 'Eye colour';


--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.shaircolourid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.shaircolourid IS 'Hair colour';


--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.bdisqualified; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.bdisqualified IS 'It is disqualified for procedures';


--
-- TOC entry 2759 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vdisability; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vdisability IS 'Disability, separated by | , max 3 disabilities. Format = 3600 igroupid | descrip | igroupid 3600 | descrip | igroupid 3600 | descrip';


--
-- TOC entry 2760 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vphoto; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vphoto IS 'Name and  extension photo ';


--
-- TOC entry 2761 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vemailaddress; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vemailaddress IS 'Phone and email contact';


--
-- TOC entry 2762 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vcontactinformation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vcontactinformation IS 'Last, first and middle name contact';


--
-- TOC entry 2763 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.vphonenumberinformation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.vphonenumberinformation IS 'Phone1, phone2, mobile and email in the address details';


--
-- TOC entry 2764 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.bonlineaccess; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.bonlineaccess IS 'Is access online';


--
-- TOC entry 2765 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.ddisqualifiedstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.ddisqualifiedstartdate IS 'Initial date of disqualification';


--
-- TOC entry 2766 (class 0 OID 0)
-- Dependencies: 210
-- Name: COLUMN party.ddisqualifiedenddate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party.ddisqualifiedenddate IS 'Finish date of disqualification';


--
-- TOC entry 211 (class 1259 OID 83547)
-- Name: party_company_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE party_company_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 212 (class 1259 OID 83549)
-- Name: party_company; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE party_company (
    ipartycompanyid integer DEFAULT nextval('party_company_seq'::regclass) NOT NULL,
    ipartyid integer,
    icompanyid integer,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2767 (class 0 OID 0)
-- Dependencies: 212
-- Name: TABLE party_company; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE party_company IS 'Table that stores a user company related to multiple users type type of person .';


--
-- TOC entry 2768 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.ipartycompanyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.ipartycompanyid IS 'ID key';


--
-- TOC entry 2769 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.ipartyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.ipartyid IS 'ID party relation to the table Party, signatories';


--
-- TOC entry 2770 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.icompanyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.icompanyid IS 'ID party relation to the table Party, one record company';


--
-- TOC entry 2771 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.sstatus IS 'Registration Status';


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.iinsertuserid IS 'User ID';


--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.dinsertdate IS 'Registration date';


--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.vinsertip IS 'IP address user';


--
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2776 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.dupdatedate IS 'Updated date';


--
-- TOC entry 2777 (class 0 OID 0)
-- Dependencies: 212
-- Name: COLUMN party_company.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_company.vupdateip IS 'Update user IP';


--
-- TOC entry 213 (class 1259 OID 83553)
-- Name: party_location_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE party_location_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 214 (class 1259 OID 83555)
-- Name: party_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE party_location (
    ipartylocationid integer DEFAULT nextval('party_location_seq'::regclass) NOT NULL,
    ipartyid integer,
    ilocationid integer,
    ipartylocationtypeid integer,
    vstreet character varying(500),
    vinformation character varying(350),
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2778 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE party_location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE party_location IS 'Table that stores the addresses of users.';


--
-- TOC entry 2779 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.ipartylocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.ipartylocationid IS 'ID key';


--
-- TOC entry 2780 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.ipartyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.ipartyid IS 'ID party relation to the table Party';


--
-- TOC entry 2781 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.ilocationid IS 'ID party relation to the table Location, can be estate/provincia, city and district ';


--
-- TOC entry 2782 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.ipartylocationtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.ipartylocationtypeid IS 'Location type, relation to the table systemparameter igroup = 1000';


--
-- TOC entry 2783 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.vstreet; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.vstreet IS 'Street separated by | Formatted  street1 | street2 .';


--
-- TOC entry 2784 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.vinformation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.vinformation IS 'Field ZipCode|PO Box|Post Code';


--
-- TOC entry 2785 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.sstatus IS 'Registration Status';


--
-- TOC entry 2786 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.iinsertuserid IS 'User ID';


--
-- TOC entry 2787 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.dinsertdate IS 'Registration date';


--
-- TOC entry 2788 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.vinsertip IS 'IP address user';


--
-- TOC entry 2789 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2790 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.dupdatedate IS 'Updated date';


--
-- TOC entry 2791 (class 0 OID 0)
-- Dependencies: 214
-- Name: COLUMN party_location.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN party_location.vupdateip IS 'Update user IP';


--
-- TOC entry 215 (class 1259 OID 83562)
-- Name: payment_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 216 (class 1259 OID 83564)
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payment (
    ipaymentid integer DEFAULT nextval('payment_seq'::regclass) NOT NULL,
    vreceiptnumber character varying(50),
    dpaymentdate timestamp without time zone,
    fpricecost double precision,
    fpricetax double precision,
    fpricetotal double precision,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2792 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE payment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE payment IS 'Table that stores information of all payments';


--
-- TOC entry 2793 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.ipaymentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.ipaymentid IS 'Primary auto-increment key';


--
-- TOC entry 2794 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.vreceiptnumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.vreceiptnumber IS 'It represents the number of receipt';


--
-- TOC entry 2795 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.dpaymentdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.dpaymentdate IS 'It represents the date the payment was made';


--
-- TOC entry 2796 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.fpricecost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.fpricecost IS 'It represents the price cost of a payment';


--
-- TOC entry 2797 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.fpricetax; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.fpricetax IS 'It represents the price tax';


--
-- TOC entry 2798 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.fpricetotal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.fpricetotal IS 'It represents the sum of the price cost and price tax';


--
-- TOC entry 2799 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.sstatus IS 'It represents the status of a payment; 1= Active; 0= Inactive';


--
-- TOC entry 2800 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.iinsertuserid IS 'User ID';


--
-- TOC entry 2801 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.dinsertdate IS 'Registration date';


--
-- TOC entry 2802 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.vinsertip IS 'IP address user';


--
-- TOC entry 2803 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2804 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.dupdatedate IS 'Updated date';


--
-- TOC entry 2805 (class 0 OID 0)
-- Dependencies: 216
-- Name: COLUMN payment.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment.vupdateip IS 'Update user IP';


--
-- TOC entry 217 (class 1259 OID 83568)
-- Name: payment_detail_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE payment_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 218 (class 1259 OID 83570)
-- Name: payment_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE payment_detail (
    ipayment_detailid integer DEFAULT nextval('payment_detail_seq'::regclass) NOT NULL,
    ipaymentid integer NOT NULL,
    smethodpaymentid smallint NOT NULL,
    scurrencyid integer NOT NULL,
    sbanktypeid smallint,
    ichequenumber integer,
    fpricecost double precision NOT NULL,
    fpricetax double precision NOT NULL,
    fpricetotal double precision NOT NULL,
    iexchangerateid integer,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2806 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE payment_detail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE payment_detail IS 'Table that stores information of all payment detail';


--
-- TOC entry 2807 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.ipayment_detailid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.ipayment_detailid IS 'Primary auto-increment key';


--
-- TOC entry 2808 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.ipaymentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.ipaymentid IS 'Referring to table payment';


--
-- TOC entry 2809 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.smethodpaymentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.smethodpaymentid IS 'Referring to Table systemparameter 
Group OPERATION_PAYMENTMETHOD = 6100; 6101 => BANK; 6102 => CASH; 6103 => CREDIT CARD; 6104=>CHEQUE;6105=> DEBIT CARD;6106 =>MASTER CARD;6107=>REFUND;6108=>TRANSFER VOUCHER';


--
-- TOC entry 2810 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.scurrencyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.scurrencyid IS 'Referring to Table systemparameter 
Group CONFIGURATION_CURRENCY = 2300 : 2301 => USD; 2302 => PAB; 2303 => S /.';


--
-- TOC entry 2811 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.sbanktypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.sbanktypeid IS 'Referring to Table systemparameter does not include version Base';


--
-- TOC entry 2812 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.ichequenumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.ichequenumber IS 'Number Cheque';


--
-- TOC entry 2813 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.fpricecost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.fpricecost IS 'It represents the price cost of a payment';


--
-- TOC entry 2814 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.fpricetax; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.fpricetax IS 'It represents the price tax';


--
-- TOC entry 2815 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.fpricetotal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.fpricetotal IS 'It represents the sum of the price cost and price tax';


--
-- TOC entry 2816 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.iexchangerateid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.iexchangerateid IS 'Referring to table exchangerate';


--
-- TOC entry 2817 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.sstatus IS 'It represents the status of payment detail; 1= Active; 0= Inactive';


--
-- TOC entry 2818 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.iinsertuserid IS 'User ID';


--
-- TOC entry 2819 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.dinsertdate IS 'Registration date';


--
-- TOC entry 2820 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.vinsertip IS 'IP address user';


--
-- TOC entry 2821 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2822 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.dupdatedate IS 'Updated date';


--
-- TOC entry 2823 (class 0 OID 0)
-- Dependencies: 218
-- Name: COLUMN payment_detail.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN payment_detail.vupdateip IS 'Update user IP';


--
-- TOC entry 219 (class 1259 OID 83574)
-- Name: pricing_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pricing_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 220 (class 1259 OID 83576)
-- Name: printer_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE printer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 221 (class 1259 OID 83578)
-- Name: printer; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE printer (
    iprinterid integer DEFAULT nextval('printer_seq'::regclass) NOT NULL,
    ilocationid integer NOT NULL,
    vdescription character varying(50) NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50),
    vipdescription character varying(50) NOT NULL
);


--
-- TOC entry 2824 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE printer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE printer IS 'Table containing information about printers';


--
-- TOC entry 2825 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.iprinterid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.iprinterid IS 'Primary auto-increment key';


--
-- TOC entry 2826 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.ilocationid IS 'Location ID';


--
-- TOC entry 2827 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.vdescription IS 'Printer description';


--
-- TOC entry 2828 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.sstatus IS 'Status';


--
-- TOC entry 2829 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.iinsertuserid IS 'User ID';


--
-- TOC entry 2830 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.dinsertdate IS 'Registration date';


--
-- TOC entry 2831 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.vinsertip IS 'IP address user';


--
-- TOC entry 2832 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2833 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.dupdatedate IS 'Updated date';


--
-- TOC entry 2834 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.vupdateip IS 'Update user IP';


--
-- TOC entry 2835 (class 0 OID 0)
-- Dependencies: 221
-- Name: COLUMN printer.vipdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer.vipdescription IS 'Ip Description';


--
-- TOC entry 222 (class 1259 OID 83582)
-- Name: printer_user_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE printer_user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 223 (class 1259 OID 83584)
-- Name: printer_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE printer_user (
    iprinteruserid integer DEFAULT nextval('printer_user_seq'::regclass) NOT NULL,
    isystemuserid integer NOT NULL,
    iprinterid integer NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2836 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE printer_user; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE printer_user IS 'Table containing information about printers assigned to users';


--
-- TOC entry 2837 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.iprinteruserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.iprinteruserid IS 'Primary key to identify the country';


--
-- TOC entry 2838 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.isystemuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.isystemuserid IS 'System user id';


--
-- TOC entry 2839 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.iprinterid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.iprinterid IS 'Printer Id';


--
-- TOC entry 2840 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.sstatus IS 'Status';


--
-- TOC entry 2841 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.iinsertuserid IS 'User ID';


--
-- TOC entry 2842 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.dinsertdate IS 'Registration date';


--
-- TOC entry 2843 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.vinsertip IS 'IP address user';


--
-- TOC entry 2844 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2845 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.dupdatedate IS 'Updated date';


--
-- TOC entry 2846 (class 0 OID 0)
-- Dependencies: 223
-- Name: COLUMN printer_user.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN printer_user.vupdateip IS 'Update user IP';


--
-- TOC entry 261 (class 1259 OID 84119)
-- Name: product_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 224 (class 1259 OID 83590)
-- Name: product; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product (
    iproductid integer DEFAULT nextval('product_seq'::regclass) NOT NULL,
    sproducttypeid smallint NOT NULL,
    sproductuseid smallint,
    sproductcategoryid smallint,
    sproductscopeid smallint,
    vdescription character varying(250) NOT NULL,
    vproductcode character varying(50) NOT NULL,
    dstartdate timestamp without time zone NOT NULL,
    denddate timestamp without time zone,
    bauthorization boolean,
    vcharacteristics character varying(200),
    sorder smallint,
    bvisible boolean,
    bconformity boolean,
    bfloating boolean,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2847 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE product; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product IS 'Table that stores product information.';


--
-- TOC entry 2848 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.iproductid IS 'ID key';


--
-- TOC entry 2849 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sproducttypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sproducttypeid IS 'Product Type, relation to systemparameter igropud = 1300';


--
-- TOC entry 2850 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sproductuseid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sproductuseid IS 'Product use, relation to systemparameter igropud = 1400';


--
-- TOC entry 2851 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sproductcategoryid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sproductcategoryid IS 'Product category, relation to systemparameter igropud = 1500';


--
-- TOC entry 2852 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sproductscopeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sproductscopeid IS 'Relation to systemparameter igropud = 1600, cayman islands product only for foreigners';


--
-- TOC entry 2853 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.vdescription IS 'Description';


--
-- TOC entry 2854 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.vproductcode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.vproductcode IS 'Code product';


--
-- TOC entry 2855 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.dstartdate IS 'Product inception date';


--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.denddate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.denddate IS 'Effective end product';


--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.bauthorization; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.bauthorization IS 'If required authorization';


--
-- TOC entry 2858 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.vcharacteristics; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.vcharacteristics IS 'Detailed description of the product and / or that this compound items';


--
-- TOC entry 2859 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sorder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sorder IS 'Order';


--
-- TOC entry 2860 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.bvisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.bvisible IS 'Is visible in the app';


--
-- TOC entry 2861 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.bconformity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.bconformity IS 'Is requerit conformity in the finish app';


--
-- TOC entry 2862 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.bfloating; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.bfloating IS 'If it can be floating';


--
-- TOC entry 2863 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.sstatus IS 'Registration Status';


--
-- TOC entry 2864 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.iinsertuserid IS 'User ID';


--
-- TOC entry 2865 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.dinsertdate IS 'Registration date';


--
-- TOC entry 2866 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.vinsertip IS 'IP address user';


--
-- TOC entry 2867 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2868 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.dupdatedate IS 'Updated date';


--
-- TOC entry 2869 (class 0 OID 0)
-- Dependencies: 224
-- Name: COLUMN product.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product.vupdateip IS 'Update user IP';


--
-- TOC entry 225 (class 1259 OID 83597)
-- Name: product_composition_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_composition_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 226 (class 1259 OID 83599)
-- Name: product_composition; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_composition (
    iproductcompositionid integer DEFAULT nextval('product_composition_seq'::regclass) NOT NULL,
    iproductid integer NOT NULL,
    icomponentid integer NOT NULL,
    fquantity double precision,
    bvisible boolean,
    sorder smallint,
    boptional boolean,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2870 (class 0 OID 0)
-- Dependencies: 226
-- Name: TABLE product_composition; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_composition IS 'Table that stores the relationship of products forming a composite product products.';


--
-- TOC entry 2871 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.iproductcompositionid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.iproductcompositionid IS 'ID key';


--
-- TOC entry 2872 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.iproductid IS 'Relation to the table product';


--
-- TOC entry 2873 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.icomponentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.icomponentid IS 'Relation to the table product, They can be several products that make up a package';


--
-- TOC entry 2874 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.fquantity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.fquantity IS 'quantity';


--
-- TOC entry 2875 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.bvisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.bvisible IS 'Product is visible in the app';


--
-- TOC entry 2876 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.sorder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.sorder IS 'Order for the composition';


--
-- TOC entry 2877 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.boptional; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.boptional IS 'Product is not displayed in the tab requirement, but may be inserted during registration';


--
-- TOC entry 2878 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.sstatus IS 'Registration Status';


--
-- TOC entry 2879 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.iinsertuserid IS 'User ID';


--
-- TOC entry 2880 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.dinsertdate IS 'Registration date';


--
-- TOC entry 2881 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.vinsertip IS 'IP address user';


--
-- TOC entry 2882 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2883 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.dupdatedate IS 'Updated date';


--
-- TOC entry 2884 (class 0 OID 0)
-- Dependencies: 226
-- Name: COLUMN product_composition.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_composition.vupdateip IS 'Update user IP';


--
-- TOC entry 227 (class 1259 OID 83603)
-- Name: product_document_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_document_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 228 (class 1259 OID 83605)
-- Name: product_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_document (
    iproductdocumentid integer DEFAULT nextval('product_document_seq'::regclass) NOT NULL,
    iproductid integer NOT NULL,
    idocumentid integer NOT NULL,
    sdocumenttypeid smallint,
    bmandatory boolean,
    bfirmrequired boolean,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2885 (class 0 OID 0)
-- Dependencies: 228
-- Name: TABLE product_document; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_document IS 'Table that stores documents of a product';


--
-- TOC entry 2886 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.iproductdocumentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.iproductdocumentid IS 'Primary key';


--
-- TOC entry 2887 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.iproductid IS 'iproductid: refers to the table product "iproductid"';


--
-- TOC entry 2888 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.idocumentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.idocumentid IS 'idocumentidl: refers to the table document "idocumentid"';


--
-- TOC entry 2889 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.sdocumenttypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.sdocumenttypeid IS 'sdocumenttypeid: refers to the table systemparameter "igroupid =  2400"';


--
-- TOC entry 2890 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.bmandatory; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.bmandatory IS 'Mandatory : 1 = true, 2 = false';


--
-- TOC entry 2891 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.sstatus IS 'Status';


--
-- TOC entry 2892 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.iinsertuserid IS 'User ID';


--
-- TOC entry 2893 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.dinsertdate IS 'Registration date';


--
-- TOC entry 2894 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.vinsertip IS 'IP address user';


--
-- TOC entry 2895 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2896 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.dupdatedate IS 'Updated date';


--
-- TOC entry 2897 (class 0 OID 0)
-- Dependencies: 228
-- Name: COLUMN product_document.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_document.vupdateip IS 'Update user IP';


--
-- TOC entry 229 (class 1259 OID 83609)
-- Name: product_pricing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_pricing (
    ipricingid integer DEFAULT nextval('pricing_seq'::regclass) NOT NULL,
    ilocationid integer,
    spricingtypeid smallint,
    vdescription character varying(1000),
    scurrencyid smallint,
    fpricecost double precision,
    fpricetax double precision,
    fpricetotal double precision,
    vconcept character varying,
    dstartdate timestamp without time zone,
    dfinishdate timestamp without time zone,
    bvisible boolean,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50),
    iproductid integer
);


--
-- TOC entry 2898 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE product_pricing; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_pricing IS 'Table that stores product prices.';


--
-- TOC entry 2899 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.ipricingid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.ipricingid IS 'ID key';


--
-- TOC entry 2900 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.ilocationid IS 'Relation to the table location';


--
-- TOC entry 2901 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.spricingtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.spricingtypeid IS 'Typo pricing, Relation to the table systemparameter igroupid = 1700';


--
-- TOC entry 2902 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.vdescription IS 'Description';


--
-- TOC entry 2903 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.scurrencyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.scurrencyid IS 'Currency, Relation to the table systemparameter igroupid = 2300';


--
-- TOC entry 2904 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.fpricecost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.fpricecost IS 'Price cost';


--
-- TOC entry 2905 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.fpricetax; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.fpricetax IS 'Price tax';


--
-- TOC entry 2906 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.fpricetotal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.fpricetotal IS 'Price total';


--
-- TOC entry 2907 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.vconcept; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.vconcept IS 'Concatenated field and separated by | related systemparameter : igroupid 3700 | igroupid 4000 | igroupid 4400';


--
-- TOC entry 2908 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.dstartdate IS 'Price inception date';


--
-- TOC entry 2909 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.dfinishdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.dfinishdate IS 'Effective end Price';


--
-- TOC entry 2910 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.bvisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.bvisible IS 'Is visible in the app';


--
-- TOC entry 2911 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.sstatus IS 'Registration Status';


--
-- TOC entry 2912 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.iinsertuserid IS 'User ID';


--
-- TOC entry 2913 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.dinsertdate IS 'Registration date';


--
-- TOC entry 2914 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.vinsertip IS 'IP address user';


--
-- TOC entry 2915 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2916 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.dupdatedate IS 'Updated date';


--
-- TOC entry 2917 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.vupdateip IS 'Update user IP';


--
-- TOC entry 2918 (class 0 OID 0)
-- Dependencies: 229
-- Name: COLUMN product_pricing.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_pricing.iproductid IS 'Relation to the product table';


--
-- TOC entry 230 (class 1259 OID 83616)
-- Name: service_rule_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE service_rule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 231 (class 1259 OID 83618)
-- Name: product_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_rule (
    iproductrule integer DEFAULT nextval('service_rule_seq'::regclass) NOT NULL,
    iproductid integer NOT NULL,
    vdescription character varying(200) NOT NULL,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer NOT NULL,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2919 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE product_rule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_rule IS 'Table that stores the rules for product prices , discounts , percentages, etc.';


--
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.iproductrule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.iproductrule IS 'Primary auto-increment key';


--
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.iproductid IS 'Product ID';


--
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.vdescription IS 'Product description';


--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.sstatus IS 'Product Status';


--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.iinsertuserid IS 'User ID';


--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.dinsertdate IS 'Registration date';


--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.vinsertip IS 'IP address user';


--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.dupdatedate IS 'Updated date';


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 231
-- Name: COLUMN product_rule.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_rule.vupdateip IS 'Update user IP';


--
-- TOC entry 232 (class 1259 OID 83622)
-- Name: product_step_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE product_step_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 233 (class 1259 OID 83624)
-- Name: product_step; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE product_step (
    iproductstepid integer DEFAULT nextval('product_step_seq'::regclass) NOT NULL,
    iproductid integer,
    ssteptypeid smallint,
    vdescription character varying,
    sorden smallint,
    ireferenceproductstepid integer,
    sstatus smallint,
    bmandatory boolean,
    bvisible boolean,
    vfunctionname character varying,
    ifunctionproductid integer,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE product_step; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE product_step IS 'Table that stores product configuration controls.';


--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.iproductstepid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.iproductstepid IS 'ID key';


--
-- TOC entry 2932 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.iproductid IS 'Relation to the table product';


--
-- TOC entry 2933 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.ssteptypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.ssteptypeid IS 'Relation to the table systemparameter igroupid = 1800';


--
-- TOC entry 2934 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.vdescription IS 'Description';


--
-- TOC entry 2935 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.sorden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.sorden IS 'Order record';


--
-- TOC entry 2936 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.ireferenceproductstepid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.ireferenceproductstepid IS 'Relation to the table product_step';


--
-- TOC entry 2937 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.sstatus IS 'Registration Status';


--
-- TOC entry 2938 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.bmandatory; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.bmandatory IS 'Is mandatory';


--
-- TOC entry 2939 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.bvisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.bvisible IS 'Is visible in the app';


--
-- TOC entry 2940 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.vfunctionname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.vfunctionname IS 'Executes a function on app';


--
-- TOC entry 2941 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.ifunctionproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.ifunctionproductid IS 'Id product';


--
-- TOC entry 2942 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.iinsertuserid IS 'User ID';


--
-- TOC entry 2943 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.dinsertdate IS 'Registration date';


--
-- TOC entry 2944 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.vinsertip IS 'IP address user';


--
-- TOC entry 2945 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2946 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.dupdatedate IS 'Updated date';


--
-- TOC entry 2947 (class 0 OID 0)
-- Dependencies: 233
-- Name: COLUMN product_step.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN product_step.vupdateip IS 'Update user IP';


--
-- TOC entry 234 (class 1259 OID 83631)
-- Name: request_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 235 (class 1259 OID 83633)
-- Name: request; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request (
    irequestid integer DEFAULT nextval('request_seq'::regclass) NOT NULL,
    ipaymentid integer,
    ipartyid integer NOT NULL,
    iproductid integer NOT NULL,
    ireferencerequestid integer,
    dstartdate timestamp without time zone NOT NULL,
    dfinishdate timestamp without time zone,
    iproductstepid integer,
    bterminate boolean,
    itramitadorid integer,
    bconformity boolean,
    iuserfirm integer,
    vtabname character varying,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2948 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE request; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE request IS 'Table that stores information of all request';


--
-- TOC entry 2949 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.irequestid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.irequestid IS 'Primary auto-increment key';


--
-- TOC entry 2950 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.ipaymentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.ipaymentid IS 'Referring to table payment';


--
-- TOC entry 2951 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.ipartyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.ipartyid IS 'Referring to table party';


--
-- TOC entry 2952 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.iproductid IS 'Referring to table product';


--
-- TOC entry 2953 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.ireferencerequestid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.ireferencerequestid IS 'Referring to table request when the state is floating';


--
-- TOC entry 2954 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.dstartdate IS 'Starting Date Request';


--
-- TOC entry 2955 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.dfinishdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.dfinishdate IS 'Finish Date Request';


--
-- TOC entry 2956 (class 0 OID 0)
-- Dependencies: 235
-- Name: COLUMN request.iproductstepid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request.iproductstepid IS 'Referring to table prodect step';


--
-- TOC entry 236 (class 1259 OID 83640)
-- Name: request_detail_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 237 (class 1259 OID 83642)
-- Name: request_detail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_detail (
    irequestdetailid integer DEFAULT nextval('request_detail_seq'::regclass) NOT NULL,
    irequestid integer NOT NULL,
    ivehicleid integer,
    iownerid integer,
    irequestlicenseid integer,
    sdriverlicensetypeid smallint,
    smotocyclegroupid smallint,
    smotorvehiclegroupid smallint,
    iproductid integer,
    ipricingid integer,
    igenevadetailterritoryid integer,
    vgenevadetailsubterritory character varying,
    svisitpermitdurationday smallint,
    snumber smallint,
    dissuedate timestamp without time zone,
    dexpirydate timestamp without time zone,
    vcurrenttab character varying,
    bwaived boolean,
    fpricecost double precision,
    fpricetax double precision,
    fpricetotal double precision,
    vnumberplate character varying,
    vcoment character varying(500),
    vplatepreview character varying(50),
    vjson character varying,
    sauthorization smallint,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2957 (class 0 OID 0)
-- Dependencies: 237
-- Name: TABLE request_detail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE request_detail IS 'Table that stores information of all request detail';


--
-- TOC entry 2958 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.irequestdetailid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.irequestdetailid IS 'Primary auto-increment key';


--
-- TOC entry 2959 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.irequestid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.irequestid IS 'Referring to table request';


--
-- TOC entry 2960 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.ivehicleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.ivehicleid IS 'Referring to table vehicle';


--
-- TOC entry 2961 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.iownerid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.iownerid IS 'Referring to table party';


--
-- TOC entry 2962 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.irequestlicenseid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.irequestlicenseid IS 'Id Driver´s License';


--
-- TOC entry 2963 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.sdriverlicensetypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.sdriverlicensetypeid IS 'Referring to table systemparameter Group OPERATION_DRIVERLICENSETYPE = 4100';


--
-- TOC entry 2964 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.smotocyclegroupid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.smotocyclegroupid IS 'Referring to table systemparameter Group OPERATION_MOTORCYCLEGROUP= 4200';


--
-- TOC entry 2965 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.smotorvehiclegroupid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.smotorvehiclegroupid IS 'Referring to table systemparameter Group OPERATION_MOTORVEHICLEGROUP= 4300';


--
-- TOC entry 2966 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.iproductid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.iproductid IS 'Referring to table product';


--
-- TOC entry 2967 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.ipricingid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.ipricingid IS 'Referring to table pricing';


--
-- TOC entry 2968 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.igenevadetailterritoryid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.igenevadetailterritoryid IS 'Referring to table location';


--
-- TOC entry 2969 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vgenevadetailsubterritory; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vgenevadetailsubterritory IS 'Descripcion the subterritory';


--
-- TOC entry 2970 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.svisitpermitdurationday; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.svisitpermitdurationday IS 'Duration visit permit';


--
-- TOC entry 2971 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.snumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.snumber IS 'Number Driver´s License';


--
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.dissuedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.dissuedate IS 'Issued Date Request Detail';


--
-- TOC entry 2973 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.dexpirydate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.dexpirydate IS 'Expire Date Request Detail';


--
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vcurrenttab; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vcurrenttab IS 'Current tab the request detail';


--
-- TOC entry 2975 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.bwaived; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.bwaived IS 'Exemption from payment for a service 1 = Exonerated; 0 = No Exonerated';


--
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.fpricecost; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.fpricecost IS 'It represents the price cost';


--
-- TOC entry 2977 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.fpricetax; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.fpricetax IS 'It represents the price tax';


--
-- TOC entry 2978 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.fpricetotal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.fpricetotal IS 'It represents the sum of the price cost and price tax';


--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vnumberplate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vnumberplate IS 'Number Plate Vehicle';


--
-- TOC entry 2980 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vcoment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vcoment IS 'Coment Request Detail';


--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vplatepreview; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vplatepreview IS 'Plate type configuration layout
Format: Mask | Layout | Font Family | Font size | Font Colour';


--
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 237
-- Name: COLUMN request_detail.vjson; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_detail.vjson IS 'Object JSON';


--
-- TOC entry 238 (class 1259 OID 83649)
-- Name: request_document_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_document_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 239 (class 1259 OID 83651)
-- Name: request_document; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_document (
    irequestdocument integer DEFAULT nextval('request_document_seq'::regclass) NOT NULL,
    irequestdetailid integer NOT NULL,
    idocumentid integer NOT NULL,
    vfilename character varying(50),
    dissuedate timestamp without time zone NOT NULL,
    vfilepath character varying(200),
    bprint boolean,
    dprint timestamp without time zone,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2983 (class 0 OID 0)
-- Dependencies: 239
-- Name: TABLE request_document; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE request_document IS 'Table that stores information of all request document';


--
-- TOC entry 2984 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.irequestdocument; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.irequestdocument IS 'Primary auto-increment key';


--
-- TOC entry 2985 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.irequestdetailid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.irequestdetailid IS 'Referring to table request detail';


--
-- TOC entry 2986 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.idocumentid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.idocumentid IS 'Referring to table document';


--
-- TOC entry 2987 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.vfilename; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.vfilename IS 'File Name Document';


--
-- TOC entry 2988 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.dissuedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.dissuedate IS 'Date of issued Load document';


--
-- TOC entry 2989 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.vfilepath; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.vfilepath IS 'File path Document';


--
-- TOC entry 2990 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.bprint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.bprint IS 'Indicates whether printed';


--
-- TOC entry 2991 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.dprint; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.dprint IS 'Indicates print date';


--
-- TOC entry 2992 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.sstatus IS 'Status Documento 1= Active; 0= Inactive';


--
-- TOC entry 2993 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.iinsertuserid IS 'User ID';


--
-- TOC entry 2994 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.dinsertdate IS 'Registration date';


--
-- TOC entry 2995 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.vinsertip IS 'IP address user';


--
-- TOC entry 2996 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 2997 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.dupdatedate IS 'Updated date';


--
-- TOC entry 2998 (class 0 OID 0)
-- Dependencies: 239
-- Name: COLUMN request_document.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_document.vupdateip IS 'Update user IP';


--
-- TOC entry 240 (class 1259 OID 83655)
-- Name: request_history_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_history_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 241 (class 1259 OID 83657)
-- Name: request_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_history (
    irequesthistoryid integer DEFAULT nextval('request_history_seq'::regclass) NOT NULL,
    irequestid integer NOT NULL,
    vobservation character varying(500),
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 2999 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE request_history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE request_history IS 'Table that stores information of all request history';


--
-- TOC entry 3000 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.irequesthistoryid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.irequesthistoryid IS 'Primary auto-increment key';


--
-- TOC entry 3001 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.irequestid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.irequestid IS 'Referring to table request';


--
-- TOC entry 3002 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.vobservation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.vobservation IS 'observation request observation when the state is float';


--
-- TOC entry 3003 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.sstatus IS 'Status Request; Referring to table systemparameter Group OPERATION_REQUESTSTATUS = 5000';


--
-- TOC entry 3004 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.iinsertuserid IS 'User ID';


--
-- TOC entry 3005 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.dinsertdate IS 'Registration date';


--
-- TOC entry 3006 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.vinsertip IS 'IP address user';


--
-- TOC entry 3007 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3008 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.dupdatedate IS 'Updated date';


--
-- TOC entry 3009 (class 0 OID 0)
-- Dependencies: 241
-- Name: COLUMN request_history.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_history.vupdateip IS 'Update user IP';


--
-- TOC entry 242 (class 1259 OID 83664)
-- Name: request_license_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE request_license_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 243 (class 1259 OID 83666)
-- Name: request_license; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE request_license (
    irequestlicenseid integer DEFAULT nextval('request_license_seq'::regclass) NOT NULL,
    slicensetypeid smallint,
    dstartdate timestamp without time zone,
    dexpirydate timestamp without time zone,
    dnewstartdate timestamp without time zone,
    dnewenddate timestamp without time zone,
    vnumberlicense character varying,
    splatetypeid smallint,
    vnumberplate character varying,
    vplatepreview character varying,
    sdurationlicense integer,
    vcomment character varying,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3010 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE request_license; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE request_license IS 'Table of the general data of the license';


--
-- TOC entry 3011 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.irequestlicenseid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.irequestlicenseid IS 'Primary Key';


--
-- TOC entry 3012 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.slicensetypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.slicensetypeid IS 'Type of License';


--
-- TOC entry 3013 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.dstartdate IS 'Issued Date License';


--
-- TOC entry 3014 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.dexpirydate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.dexpirydate IS 'Expire Date License';


--
-- TOC entry 3015 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.vnumberlicense; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.vnumberlicense IS 'Expire Date License';


--
-- TOC entry 3016 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.splatetypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.splatetypeid IS 'Type of Plate';


--
-- TOC entry 3017 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.vnumberplate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.vnumberplate IS 'Number Plate Vehicle';


--
-- TOC entry 3018 (class 0 OID 0)
-- Dependencies: 243
-- Name: COLUMN request_license.vplatepreview; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN request_license.vplatepreview IS 'Plate type configuration layout Format: Mask | Layout | Font Family | Font size | Font Colour';


--
-- TOC entry 244 (class 1259 OID 83673)
-- Name: schedule_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 245 (class 1259 OID 83675)
-- Name: schedule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schedule (
    ischeduleid integer DEFAULT nextval('schedule_seq'::regclass) NOT NULL,
    dscheduledate timestamp without time zone NOT NULL,
    sdayofweekid integer NOT NULL,
    sstatus integer NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50),
    iofficeexaminationtypeid integer,
    ivacant integer,
    ttimeday time without time zone,
    ttimeendday time without time zone
);


--
-- TOC entry 3019 (class 0 OID 0)
-- Dependencies: 245
-- Name: TABLE schedule; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE schedule IS 'Table that stores information of all schedule';


--
-- TOC entry 3020 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.ischeduleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.ischeduleid IS 'Primary key to identify the location';


--
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.dscheduledate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.dscheduledate IS 'Schedule description';


--
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.sdayofweekid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.sdayofweekid IS 'Day of week Id';


--
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.sstatus IS 'Status';


--
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.iinsertuserid IS 'User ID';


--
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.dinsertdate IS 'Registration date';


--
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.vinsertip IS 'IP address user';


--
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.dupdatedate IS 'Updated date';


--
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.vupdateip IS 'Update user IP';


--
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.iofficeexaminationtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.iofficeexaminationtypeid IS 'Referring to table officeexaminationtype';


--
-- TOC entry 3031 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.ivacant; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.ivacant IS 'number vacant for schedule';


--
-- TOC entry 3032 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.ttimeday; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.ttimeday IS 'time of the day';


--
-- TOC entry 3033 (class 0 OID 0)
-- Dependencies: 245
-- Name: COLUMN schedule.ttimeendday; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN schedule.ttimeendday IS 'time of the end day';


--
-- TOC entry 246 (class 1259 OID 83679)
-- Name: systemaudit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE systemaudit (
    ieventid integer NOT NULL,
    seventtypeid smallint,
    sprocessid smallint,
    staskid smallint,
    sactionid smallint,
    sresultid smallint,
    vmessage character varying(1000),
    vhostname character varying(50),
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50)
);


--
-- TOC entry 3034 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE systemaudit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE systemaudit IS 'Table that stores information of all system audit';


--
-- TOC entry 3035 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.ieventid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.ieventid IS 'Primary key';


--
-- TOC entry 3036 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.seventtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.seventtypeid IS 'Referring to table system parameter.
Stores references to the types of event';


--
-- TOC entry 3037 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.sprocessid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.sprocessid IS 'Referring to table system parameter.
Stores references to the process of system';


--
-- TOC entry 3038 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.staskid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.staskid IS 'Referring to table system parameter.
Stores references to the task of system';


--
-- TOC entry 3039 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.sactionid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.sactionid IS 'Referring to table system parameter.
Stores references to the action of system';


--
-- TOC entry 3040 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.sresultid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.sresultid IS 'Referring to table system parameter.
Stores references to the result of system';


--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.vmessage; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.vmessage IS 'Stores the message thrown by the system';


--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.vhostname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.vhostname IS 'Stores the host name that generated the event';


--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.iinsertuserid IS 'User ID';


--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.dinsertdate IS 'Registration date';


--
-- TOC entry 3045 (class 0 OID 0)
-- Dependencies: 246
-- Name: COLUMN systemaudit.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemaudit.vinsertip IS 'IP address user';


--
-- TOC entry 247 (class 1259 OID 83685)
-- Name: systemaudit_ieventid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE systemaudit_ieventid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3046 (class 0 OID 0)
-- Dependencies: 247
-- Name: systemaudit_ieventid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE systemaudit_ieventid_seq OWNED BY systemaudit.ieventid;


--
-- TOC entry 248 (class 1259 OID 83687)
-- Name: systemparameter; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE systemparameter (
    iparameterid integer NOT NULL,
    igroupid integer,
    vdescription character varying(1000),
    vvalue character varying(250),
    vreferenceid character varying(200),
    sorder smallint,
    svisible smallint,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3047 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE systemparameter; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE systemparameter IS 'Table that stores the system parameters.';


--
-- TOC entry 3048 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.iparameterid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.iparameterid IS 'ID key';


--
-- TOC entry 3049 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.igroupid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.igroupid IS 'ID grouper';


--
-- TOC entry 3050 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.vdescription IS 'description parameter';


--
-- TOC entry 3051 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.vvalue; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.vvalue IS 'Value';


--
-- TOC entry 3052 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.vreferenceid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.vreferenceid IS 'Field to link any table or place a particular value';


--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.sorder; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.sorder IS 'Orders the fields in each group';


--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.svisible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.svisible IS 'Is visible =  1';


--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.sstatus IS 'Is activo = 1';


--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.iinsertuserid IS 'User ID';


--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.dinsertdate IS 'Registration date';


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.vinsertip IS 'IP address user';


--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.dupdatedate IS 'Updated date';


--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 248
-- Name: COLUMN systemparameter.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN systemparameter.vupdateip IS 'Update user IP';


--
-- TOC entry 249 (class 1259 OID 83693)
-- Name: user_location_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_location_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 250 (class 1259 OID 83695)
-- Name: user_location; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_location (
    iuserlocationid integer DEFAULT nextval('user_location_seq'::regclass) NOT NULL,
    iuserid integer NOT NULL,
    ilocationid integer NOT NULL,
    vusername character varying(50),
    vuseraddress character varying(200),
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 250
-- Name: TABLE user_location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE user_location IS 'Table that stores the relationship between users and offices';


--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN user_location.iuserlocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN user_location.iuserlocationid IS 'ID';


--
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN user_location.iuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN user_location.iuserid IS 'ID user';


--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN user_location.ilocationid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN user_location.ilocationid IS 'ID location';


--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 250
-- Name: COLUMN user_location.vusername; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN user_location.vusername IS 'User Name';


--
-- TOC entry 251 (class 1259 OID 83699)
-- Name: vehicle_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 252 (class 1259 OID 83701)
-- Name: vehicle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicle (
    ivehicleid integer DEFAULT nextval('vehicle_seq'::regclass) NOT NULL,
    vvehiclecode character varying(50),
    scategorytypeid smallint,
    sfuelsourcetypeid smallint,
    sprimarycolourid smallint,
    ssecondarycolourid smallint,
    bnew boolean,
    vusedby character varying(100),
    downedsince timestamp without time zone,
    venginenumber character varying(50),
    iseatingcapacity integer,
    smaximunload smallint,
    ddatestolen timestamp without time zone,
    fgrossweight double precision,
    funladenweigth double precision,
    vexportdetails character varying(50),
    imakeid integer,
    imodelid integer,
    iversionid integer,
    smanufacturingyear smallint,
    sseatnumber smallint,
    spassengernumber smallint,
    ftravellingwidthfeet double precision,
    foveralllengthfeet double precision,
    shanddriveid smallint,
    vtrailer character varying(50),
    iimportfrom integer,
    vorigin character varying(50),
    vvinnumber character varying(50),
    splatetypeid smallint,
    iownerid integer,
    sstatus smallint NOT NULL,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 252
-- Name: TABLE vehicle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vehicle IS 'Table of the general data of the vehicle';


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.ivehicleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.ivehicleid IS 'Primary Key';


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vvehiclecode; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vvehiclecode IS 'Vehicle category code: refers to the table systemparameter "igroupid =  4000"';


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.scategorytypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.scategorytypeid IS 'Vehicle category type: refers to the table systemparameter "igroupid =  4000"';


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.sfuelsourcetypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.sfuelsourcetypeid IS 'Fuel source type: refers to the table systemparameter "igroupid =  4500"';


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.sprimarycolourid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.sprimarycolourid IS 'Primary Color: refers to the table systemparameter "igroupid =  4700"';


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.ssecondarycolourid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.ssecondarycolourid IS 'Secondary Color: refers to the table systemparameter "igroupid =  4700"';


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.bnew; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.bnew IS 'Identifies whether the vehicle is new';


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vusedby; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vusedby IS 'Identifies whether the vehicle is used';


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.downedsince; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.downedsince IS 'Date owned since';


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.venginenumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.venginenumber IS 'Engine number';


--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iseatingcapacity; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iseatingcapacity IS 'Seating capacity';


--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.smaximunload; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.smaximunload IS 'Maximum load';


--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.ddatestolen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.ddatestolen IS 'Date stolen';


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.fgrossweight; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.fgrossweight IS 'Gross weight';


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.funladenweigth; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.funladenweigth IS 'Unladen weight';


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vexportdetails; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vexportdetails IS 'Export details';


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.imakeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.imakeid IS 'Make of vehicle Fuel: refers to the table vehiclecatalog "icatalogtypeid = 5101"';


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.imodelid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.imodelid IS 'Model of vehicle Fuel: refers to the table vehiclecatalog "icatalogtypeid = 5102"';


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iversionid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iversionid IS 'Versino of vehicle Fuel: refers to the table vehiclecatalog "icatalogtypeid = 5103"';


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.smanufacturingyear; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.smanufacturingyear IS 'Manufacturing year';


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.sseatnumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.sseatnumber IS 'Seat number';


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.spassengernumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.spassengernumber IS 'Passenger number';


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.ftravellingwidthfeet; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.ftravellingwidthfeet IS 'Traveling width feet';


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.foveralllengthfeet; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.foveralllengthfeet IS 'Overall length feet';


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.shanddriveid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.shanddriveid IS 'Hand Drive';


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vtrailer; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vtrailer IS 'Trailer';


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iimportfrom; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iimportfrom IS 'Import from';


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vorigin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vorigin IS 'Origin';


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vvinnumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vvinnumber IS 'VIN number of vehicle';


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.splatetypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.splatetypeid IS 'Tipo de placa';


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iownerid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iownerid IS 'Current Owner of vehicle';


--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.sstatus IS 'Status of vehicle ';


--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iinsertuserid IS 'User ID';


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.dinsertdate IS 'Registration date';


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vinsertip IS 'IP address user';


--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.dupdatedate IS 'Updated date';


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 252
-- Name: COLUMN vehicle.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle.vupdateip IS 'Update user IP';


--
-- TOC entry 253 (class 1259 OID 83708)
-- Name: vehicle_lienbank_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_lienbank_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 254 (class 1259 OID 83710)
-- Name: vehicle_banklien; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicle_banklien (
    ibanklienid integer DEFAULT nextval('vehicle_lienbank_seq'::regclass) NOT NULL,
    ivehicleid integer,
    vphonenumber character varying(50),
    dstartdate timestamp without time zone,
    ilienholderid integer,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 254
-- Name: TABLE vehicle_banklien; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vehicle_banklien IS 'Table that stores Vehicle bank lien';


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.ibanklienid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.ibanklienid IS 'Primary Key';


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.ivehicleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.ivehicleid IS 'ivehicleid: refers to the table vehicle "ivehicleid"';


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.vphonenumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.vphonenumber IS 'Phone number';


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.dstartdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.dstartdate IS 'Start Date';


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.ilienholderid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.ilienholderid IS 'Lienholder ID';


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.sstatus IS 'Status';


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.iinsertuserid IS 'User ID';


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.dinsertdate IS 'Registration date';


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.vinsertip IS 'IP address user';


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.dupdatedate IS 'Updated date';


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 254
-- Name: COLUMN vehicle_banklien.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_banklien.vupdateip IS 'Update user IP';


--
-- TOC entry 262 (class 1259 OID 84122)
-- Name: vehicle_catalog_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_catalog_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 255 (class 1259 OID 83716)
-- Name: vehicle_catalog; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicle_catalog (
    ivehiclecatalogid integer DEFAULT nextval('vehicle_catalog_seq'::regclass) NOT NULL,
    icatalogtypeid integer,
    vdescription character varying(100),
    ireferenceid integer,
    sstatus smallint,
    iinsertuserid integer NOT NULL,
    dinsertdate timestamp without time zone NOT NULL,
    vinsertip character varying(50) NOT NULL,
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE vehicle_catalog; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vehicle_catalog IS 'Table that stores Vehicle Catalog';


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.ivehiclecatalogid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.ivehiclecatalogid IS 'Primary Key';


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.icatalogtypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.icatalogtypeid IS 'Group=4800';


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.vdescription; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.vdescription IS 'Description';


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.ireferenceid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.ireferenceid IS 'Father ID ';


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.sstatus IS '1=ACT, 0=INA';


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.iinsertuserid IS 'User ID';


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.dinsertdate IS 'Registration date';


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.vinsertip IS 'IP address user';


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.dupdatedate IS 'Updated date';


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 255
-- Name: COLUMN vehicle_catalog.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_catalog.vupdateip IS 'Update user IP';


--
-- TOC entry 256 (class 1259 OID 83720)
-- Name: vehicle_inspection_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_inspection_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 257 (class 1259 OID 83722)
-- Name: vehicle_inspection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicle_inspection (
    ivehicleinspectionid integer DEFAULT nextval('vehicle_inspection_seq'::regclass) NOT NULL,
    ivehicleid integer,
    sresulttypeid smallint,
    vcertificatenumber character varying(50),
    dinspectiondate timestamp without time zone,
    dexpirydate timestamp without time zone,
    sdurationinspection smallint,
    iinspectorid integer,
    bpaymentrequired boolean,
    vinspectorname character varying(50),
    iworkshopid integer,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE vehicle_inspection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vehicle_inspection IS 'Table that stores Vehicle Inspection';


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.ivehicleinspectionid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.ivehicleinspectionid IS 'Primary key';


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.ivehicleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.ivehicleid IS 'ivehicleid: refers to the table vehicle "ivehicleid"';


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.sresulttypeid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.sresulttypeid IS 'Result Type: refers to the table systemparameter "igroupid =  7200"';


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.vcertificatenumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.vcertificatenumber IS 'Number Certificate';


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.dinspectiondate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.dinspectiondate IS 'Inspection Date';


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.dexpirydate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.dexpirydate IS 'Expiry Date';


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.sdurationinspection; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.sdurationinspection IS 'Duration Inspection';


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.iinspectorid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.iinspectorid IS 'iinspectorid: refers to the table party "spartytypeid = 3402"';


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.bpaymentrequired; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.bpaymentrequired IS 'Payment Required : 1=Active; 0=Inactive';


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 257
-- Name: COLUMN vehicle_inspection.vinspectorname; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_inspection.vinspectorname IS 'Inspector Name';


--
-- TOC entry 258 (class 1259 OID 83726)
-- Name: vehicle_insurance_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE vehicle_insurance_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 259 (class 1259 OID 83728)
-- Name: vehicle_insurance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE vehicle_insurance (
    iinsuranceid integer DEFAULT nextval('vehicle_insurance_seq'::regclass) NOT NULL,
    ivehicleid integer,
    vcertificatenumber character varying(50),
    dissuedate timestamp without time zone,
    dexpirydate timestamp without time zone,
    icompanyid integer,
    sstatus smallint,
    iinsertuserid integer,
    dinsertdate timestamp without time zone,
    vinsertip character varying(50),
    iupdateuserid integer,
    dupdatedate timestamp without time zone,
    vupdateip character varying(50)
);


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE vehicle_insurance; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE vehicle_insurance IS 'Table that stores Vehicle Insurance';


--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.iinsuranceid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.iinsuranceid IS 'Primary key';


--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.ivehicleid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.ivehicleid IS 'ivehicleid: refers to the table vehicle';


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.vcertificatenumber; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.vcertificatenumber IS 'Number of certificate';


--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.dissuedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.dissuedate IS 'Issue Date';


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.dexpirydate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.dexpirydate IS 'Expiry Date';


--
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.icompanyid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.icompanyid IS 'Company ID';


--
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.sstatus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.sstatus IS 'Vehicle insurance status';


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.iinsertuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.iinsertuserid IS 'User ID';


--
-- TOC entry 3151 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.dinsertdate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.dinsertdate IS 'Registration date';


--
-- TOC entry 3152 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.vinsertip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.vinsertip IS 'IP address user';


--
-- TOC entry 3153 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.iupdateuserid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.iupdateuserid IS 'Updated user ID';


--
-- TOC entry 3154 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.dupdatedate; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.dupdatedate IS 'Updated date';


--
-- TOC entry 3155 (class 0 OID 0)
-- Dependencies: 259
-- Name: COLUMN vehicle_insurance.vupdateip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN vehicle_insurance.vupdateip IS 'Update user IP';


--
-- TOC entry 2344 (class 2604 OID 83732)
-- Name: ieventid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY systemaudit ALTER COLUMN ieventid SET DEFAULT nextval('systemaudit_ieventid_seq'::regclass);


--
-- TOC entry 2358 (class 2606 OID 83734)
-- Name: document_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pk PRIMARY KEY (idocumentid);


--
-- TOC entry 2360 (class 2606 OID 83736)
-- Name: exchangerate_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY exchangerate
    ADD CONSTRAINT exchangerate_pk PRIMARY KEY (iexchangerateid);


--
-- TOC entry 2400 (class 2606 OID 83738)
-- Name: license_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_license
    ADD CONSTRAINT license_pkey PRIMARY KEY (irequestlicenseid);


--
-- TOC entry 2370 (class 2606 OID 83740)
-- Name: party_location_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_location
    ADD CONSTRAINT party_location_pkey PRIMARY KEY (ipartylocationid);


--
-- TOC entry 2366 (class 2606 OID 83742)
-- Name: party_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_pk PRIMARY KEY (ipartyid);


--
-- TOC entry 2409 (class 2606 OID 83744)
-- Name: pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT pk PRIMARY KEY (iuserlocationid);


--
-- TOC entry 2394 (class 2606 OID 83746)
-- Name: pk_application_detail; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_detail
    ADD CONSTRAINT pk_application_detail PRIMARY KEY (irequestdetailid);


--
-- TOC entry 2396 (class 2606 OID 83748)
-- Name: pk_application_document; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_document
    ADD CONSTRAINT pk_application_document PRIMARY KEY (irequestdocument);


--
-- TOC entry 2398 (class 2606 OID 83750)
-- Name: pk_application_status; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_history
    ADD CONSTRAINT pk_application_status PRIMARY KEY (irequesthistoryid);


--
-- TOC entry 2352 (class 2606 OID 83752)
-- Name: pk_appointment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment
    ADD CONSTRAINT pk_appointment PRIMARY KEY (iappointmentid);


--
-- TOC entry 2354 (class 2606 OID 83754)
-- Name: pk_authorisation; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "authorization"
    ADD CONSTRAINT pk_authorisation PRIMARY KEY (iauthorizationid);


--
-- TOC entry 2413 (class 2606 OID 83756)
-- Name: pk_banklien; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_banklien
    ADD CONSTRAINT pk_banklien PRIMARY KEY (ibanklienid) WITH (fillfactor='100');


--
-- TOC entry 2356 (class 2606 OID 83758)
-- Name: pk_country; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY country
    ADD CONSTRAINT pk_country PRIMARY KEY (scountryid);


--
-- TOC entry 2419 (class 2606 OID 83760)
-- Name: pk_insurance; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_insurance
    ADD CONSTRAINT pk_insurance PRIMARY KEY (iinsuranceid);


--
-- TOC entry 2362 (class 2606 OID 83762)
-- Name: pk_location; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY location
    ADD CONSTRAINT pk_location PRIMARY KEY (ilocationid);


--
-- TOC entry 2364 (class 2606 OID 83764)
-- Name: pk_office_examinationtype; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY office_examinationtype
    ADD CONSTRAINT pk_office_examinationtype PRIMARY KEY (iofficeexaminationtypeid);


--
-- TOC entry 2368 (class 2606 OID 83766)
-- Name: pk_party_company; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_company
    ADD CONSTRAINT pk_party_company PRIMARY KEY (ipartycompanyid);


--
-- TOC entry 2372 (class 2606 OID 83768)
-- Name: pk_payment; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment
    ADD CONSTRAINT pk_payment PRIMARY KEY (ipaymentid);


--
-- TOC entry 2374 (class 2606 OID 83770)
-- Name: pk_payment_deta_01; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_detail
    ADD CONSTRAINT pk_payment_deta_01 PRIMARY KEY (ipayment_detailid);


--
-- TOC entry 2386 (class 2606 OID 83772)
-- Name: pk_pricing; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_pricing
    ADD CONSTRAINT pk_pricing PRIMARY KEY (ipricingid);


--
-- TOC entry 2376 (class 2606 OID 83774)
-- Name: pk_printer; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY printer
    ADD CONSTRAINT pk_printer PRIMARY KEY (iprinterid);


--
-- TOC entry 2378 (class 2606 OID 83776)
-- Name: pk_printersettings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY printer_user
    ADD CONSTRAINT pk_printersettings PRIMARY KEY (iprinteruserid);


--
-- TOC entry 2380 (class 2606 OID 83778)
-- Name: pk_procedure; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product
    ADD CONSTRAINT pk_procedure PRIMARY KEY (iproductid);


--
-- TOC entry 2384 (class 2606 OID 83780)
-- Name: pk_procedure_document; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_document
    ADD CONSTRAINT pk_procedure_document PRIMARY KEY (iproductdocumentid);


--
-- TOC entry 2388 (class 2606 OID 83782)
-- Name: pk_procedure_rule; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_rule
    ADD CONSTRAINT pk_procedure_rule PRIMARY KEY (iproductrule);


--
-- TOC entry 2390 (class 2606 OID 83784)
-- Name: pk_procedure_step; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_step
    ADD CONSTRAINT pk_procedure_step PRIMARY KEY (iproductstepid);


--
-- TOC entry 2392 (class 2606 OID 83786)
-- Name: pk_request; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request
    ADD CONSTRAINT pk_request PRIMARY KEY (irequestid);


--
-- TOC entry 2402 (class 2606 OID 83788)
-- Name: pk_schedule; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT pk_schedule PRIMARY KEY (ischeduleid);


--
-- TOC entry 2405 (class 2606 OID 83790)
-- Name: pk_systemaudit; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY systemaudit
    ADD CONSTRAINT pk_systemaudit PRIMARY KEY (ieventid);


--
-- TOC entry 2407 (class 2606 OID 83792)
-- Name: pk_systemparameter_parameter; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY systemparameter
    ADD CONSTRAINT pk_systemparameter_parameter PRIMARY KEY (iparameterid);


--
-- TOC entry 2417 (class 2606 OID 83794)
-- Name: pk_vehicle_inspection; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_inspection
    ADD CONSTRAINT pk_vehicle_inspection PRIMARY KEY (ivehicleinspectionid);


--
-- TOC entry 2382 (class 2606 OID 83796)
-- Name: product_composition_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_composition
    ADD CONSTRAINT product_composition_pkey PRIMARY KEY (iproductcompositionid);


--
-- TOC entry 2415 (class 2606 OID 83798)
-- Name: vehicle_catalog_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_catalog
    ADD CONSTRAINT vehicle_catalog_pkey PRIMARY KEY (ivehiclecatalogid);


--
-- TOC entry 2411 (class 2606 OID 83800)
-- Name: vehicle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (ivehicleid);


--
-- TOC entry 2403 (class 1259 OID 83801)
-- Name: idx_systemaudit_ieventid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_systemaudit_ieventid ON systemaudit USING btree (ieventid);


--
-- TOC entry 2420 (class 2606 OID 83802)
-- Name: fk_appointment_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment
    ADD CONSTRAINT fk_appointment_party FOREIGN KEY (ipartyid) REFERENCES party(ipartyid);


--
-- TOC entry 2421 (class 2606 OID 83807)
-- Name: fk_appointment_schedule; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY appointment
    ADD CONSTRAINT fk_appointment_schedule FOREIGN KEY (ischeduleid) REFERENCES schedule(ischeduleid);


--
-- TOC entry 2422 (class 2606 OID 83812)
-- Name: fk_authorization_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "authorization"
    ADD CONSTRAINT fk_authorization_request FOREIGN KEY (irequestid) REFERENCES request(irequestid);


--
-- TOC entry 2453 (class 2606 OID 83817)
-- Name: fk_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_location
    ADD CONSTRAINT fk_location FOREIGN KEY (ilocationid) REFERENCES location(ilocationid);


--
-- TOC entry 2423 (class 2606 OID 83822)
-- Name: fk_location_ireferenceid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY location
    ADD CONSTRAINT fk_location_ireferenceid FOREIGN KEY (ireferenceid) REFERENCES location(ilocationid);


--
-- TOC entry 2424 (class 2606 OID 83827)
-- Name: fk_location_scountryid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY location
    ADD CONSTRAINT fk_location_scountryid FOREIGN KEY (scountryid) REFERENCES country(scountryid);


--
-- TOC entry 2425 (class 2606 OID 83832)
-- Name: fk_party_company_organization; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_company
    ADD CONSTRAINT fk_party_company_organization FOREIGN KEY (icompanyid) REFERENCES party(ipartyid);


--
-- TOC entry 2426 (class 2606 OID 83837)
-- Name: fk_party_company_party; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_company
    ADD CONSTRAINT fk_party_company_party FOREIGN KEY (ipartyid) REFERENCES party(ipartyid);


--
-- TOC entry 2427 (class 2606 OID 83842)
-- Name: fk_partylocation_locationid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_location
    ADD CONSTRAINT fk_partylocation_locationid FOREIGN KEY (ilocationid) REFERENCES location(ilocationid);


--
-- TOC entry 2428 (class 2606 OID 83847)
-- Name: fk_partylocation_partyid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY party_location
    ADD CONSTRAINT fk_partylocation_partyid FOREIGN KEY (ipartyid) REFERENCES party(ipartyid);


--
-- TOC entry 2429 (class 2606 OID 83852)
-- Name: fk_payment_detail_payment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_detail
    ADD CONSTRAINT fk_payment_detail_payment FOREIGN KEY (ipaymentid) REFERENCES payment(ipaymentid);


--
-- TOC entry 2430 (class 2606 OID 83857)
-- Name: fk_paymentexchangerate_exchangerateid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY payment_detail
    ADD CONSTRAINT fk_paymentexchangerate_exchangerateid FOREIGN KEY (iexchangerateid) REFERENCES exchangerate(iexchangerateid);


--
-- TOC entry 2431 (class 2606 OID 83862)
-- Name: fk_printer_locationid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY printer
    ADD CONSTRAINT fk_printer_locationid FOREIGN KEY (ilocationid) REFERENCES location(ilocationid);


--
-- TOC entry 2432 (class 2606 OID 83867)
-- Name: fk_printeruser_printerid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY printer_user
    ADD CONSTRAINT fk_printeruser_printerid FOREIGN KEY (iprinterid) REFERENCES printer(iprinterid);


--
-- TOC entry 2439 (class 2606 OID 83872)
-- Name: fk_procedure_rule_procedure; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_rule
    ADD CONSTRAINT fk_procedure_rule_procedure FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2433 (class 2606 OID 83877)
-- Name: fk_product_composition_icompositionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_composition
    ADD CONSTRAINT fk_product_composition_icompositionid FOREIGN KEY (icomponentid) REFERENCES product(iproductid);


--
-- TOC entry 2434 (class 2606 OID 83882)
-- Name: fk_product_composition_iproductid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_composition
    ADD CONSTRAINT fk_product_composition_iproductid FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2437 (class 2606 OID 83887)
-- Name: fk_product_location_ilocationid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_pricing
    ADD CONSTRAINT fk_product_location_ilocationid FOREIGN KEY (ilocationid) REFERENCES location(ilocationid);


--
-- TOC entry 2438 (class 2606 OID 83892)
-- Name: fk_product_pricing_iproductid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_pricing
    ADD CONSTRAINT fk_product_pricing_iproductid FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2440 (class 2606 OID 83897)
-- Name: fk_product_step_iproductid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_step
    ADD CONSTRAINT fk_product_step_iproductid FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2435 (class 2606 OID 83902)
-- Name: fk_productdocument_documentid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_document
    ADD CONSTRAINT fk_productdocument_documentid FOREIGN KEY (idocumentid) REFERENCES document(idocumentid);


--
-- TOC entry 2436 (class 2606 OID 83907)
-- Name: fk_productdocument_productid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY product_document
    ADD CONSTRAINT fk_productdocument_productid FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2448 (class 2606 OID 83912)
-- Name: fk_request_detail_document_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_document
    ADD CONSTRAINT fk_request_detail_document_request FOREIGN KEY (irequestdetailid) REFERENCES request_detail(irequestdetailid);


--
-- TOC entry 2444 (class 2606 OID 83917)
-- Name: fk_request_detail_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_detail
    ADD CONSTRAINT fk_request_detail_request FOREIGN KEY (irequestid) REFERENCES request(irequestid);


--
-- TOC entry 2450 (class 2606 OID 83922)
-- Name: fk_request_history_request; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_history
    ADD CONSTRAINT fk_request_history_request FOREIGN KEY (irequestid) REFERENCES request(irequestid);


--
-- TOC entry 2441 (class 2606 OID 83927)
-- Name: fk_request_payment; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request
    ADD CONSTRAINT fk_request_payment FOREIGN KEY (ipaymentid) REFERENCES payment(ipaymentid);


--
-- TOC entry 2442 (class 2606 OID 83932)
-- Name: fk_request_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request
    ADD CONSTRAINT fk_request_product FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2443 (class 2606 OID 83937)
-- Name: fk_request_service_step; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request
    ADD CONSTRAINT fk_request_service_step FOREIGN KEY (iproductstepid) REFERENCES product_step(iproductstepid);


--
-- TOC entry 2445 (class 2606 OID 83942)
-- Name: fk_requestdetail_irequestlicenseid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_detail
    ADD CONSTRAINT fk_requestdetail_irequestlicenseid FOREIGN KEY (irequestlicenseid) REFERENCES request_license(irequestlicenseid);


--
-- TOC entry 2446 (class 2606 OID 83947)
-- Name: fk_requestdetail_ivehicleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_detail
    ADD CONSTRAINT fk_requestdetail_ivehicleid FOREIGN KEY (ivehicleid) REFERENCES vehicle(ivehicleid);


--
-- TOC entry 2447 (class 2606 OID 83952)
-- Name: fk_requestdetail_product; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_detail
    ADD CONSTRAINT fk_requestdetail_product FOREIGN KEY (iproductid) REFERENCES product(iproductid);


--
-- TOC entry 2449 (class 2606 OID 83957)
-- Name: fk_requestdocument_documentid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY request_document
    ADD CONSTRAINT fk_requestdocument_documentid FOREIGN KEY (idocumentid) REFERENCES document(idocumentid);


--
-- TOC entry 2451 (class 2606 OID 83962)
-- Name: fk_schedule_office_examinat_01; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedule
    ADD CONSTRAINT fk_schedule_office_examinat_01 FOREIGN KEY (iofficeexaminationtypeid) REFERENCES office_examinationtype(iofficeexaminationtypeid);


--
-- TOC entry 2452 (class 2606 OID 83967)
-- Name: fk_systemparameter_group; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY systemparameter
    ADD CONSTRAINT fk_systemparameter_group FOREIGN KEY (igroupid) REFERENCES systemparameter(iparameterid);


--
-- TOC entry 2454 (class 2606 OID 83972)
-- Name: fk_vehicle_imakeid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT fk_vehicle_imakeid FOREIGN KEY (imakeid) REFERENCES vehicle_catalog(ivehiclecatalogid);


--
-- TOC entry 2455 (class 2606 OID 83977)
-- Name: fk_vehicle_imodelid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT fk_vehicle_imodelid FOREIGN KEY (imodelid) REFERENCES vehicle_catalog(ivehiclecatalogid);


--
-- TOC entry 2459 (class 2606 OID 83982)
-- Name: fk_vehicle_inspection_inspector; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_inspection
    ADD CONSTRAINT fk_vehicle_inspection_inspector FOREIGN KEY (iinspectorid) REFERENCES party(ipartyid);


--
-- TOC entry 2456 (class 2606 OID 83987)
-- Name: fk_vehicle_iversionid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle
    ADD CONSTRAINT fk_vehicle_iversionid FOREIGN KEY (iversionid) REFERENCES vehicle_catalog(ivehiclecatalogid);


--
-- TOC entry 2457 (class 2606 OID 83992)
-- Name: fk_vehiclebanklien_ivehicleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_banklien
    ADD CONSTRAINT fk_vehiclebanklien_ivehicleid FOREIGN KEY (ivehicleid) REFERENCES vehicle(ivehicleid);


--
-- TOC entry 2458 (class 2606 OID 83997)
-- Name: fk_vehiclecatalog_ireferenceid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_catalog
    ADD CONSTRAINT fk_vehiclecatalog_ireferenceid FOREIGN KEY (ireferenceid) REFERENCES vehicle_catalog(ivehiclecatalogid);


--
-- TOC entry 2460 (class 2606 OID 84002)
-- Name: fk_vehicleinspection_ivehicleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_inspection
    ADD CONSTRAINT fk_vehicleinspection_ivehicleid FOREIGN KEY (ivehicleid) REFERENCES vehicle(ivehicleid);


--
-- TOC entry 2461 (class 2606 OID 84007)
-- Name: fk_vehicleinsurance_ivehicleid; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY vehicle_insurance
    ADD CONSTRAINT fk_vehicleinsurance_ivehicleid FOREIGN KEY (ivehicleid) REFERENCES vehicle(ivehicleid);


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 8
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-11-08 15:53:14

--
-- PostgreSQL database dump complete
--

