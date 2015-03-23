
CREATE OR REPLACE PACKAGE BODY dbo
IS

   FUNCTION mtmaxdate
      RETURN DATE
   IS
      temp_time   DATE;
   BEGIN
		TEMP_time := to_date('01/01/2038 00:00','dd/mm/yyyy hh24:mi');
    return (temp_time); 
   END;

   FUNCTION mtmindate
      RETURN DATE
   AS
      temp_time   DATE;
   BEGIN
		temp_time := to_date('01/01/1753 00:00','dd/mm/yyyy hh24:mi');
    RETURN (temp_time);
   END;

   FUNCTION getutcdate
      RETURN DATE
   AS
      v_utcdate   DATE;
   BEGIN
      SELECT SYS_EXTRACT_UTC (SYSTIMESTAMP)
        INTO v_utcdate
        FROM DUAL;

      RETURN v_utcdate;
   END;

   FUNCTION addsecond (refdate DATE)
      RETURN DATE
   AS
   BEGIN
      RETURN   refdate + numtodsinterval(1,'second');
   END;

   FUNCTION subtractsecond (refdate DATE)
      RETURN DATE
   AS
   BEGIN
      RETURN   refdate + numtodsinterval(-1,'second');
   END;

  function addday(dt date) return date as
  begin
    return dt + numtodsinterval(1, 'day');
  end;

  function subtractday(dt date) return date as
  begin
    return dt + numtodsinterval(-1, 'day');
  end;
  
  
   function diffhour (dt_start date, dt_end date)
      return number
   as
   begin
      /* this expression is equivalent to sql server's datediff(hour, a, b).
         the fractional part of the result is discarded */
      return floor ((dt_end - dt_start) * 24);
   end;

  function isaccountbillable(p_id_acc IN integer) 
	return varchar2
	as
	 billableFlag char(1);
	begin
	 begin
		select c_billable into billableFlag from t_av_internal where 
		id_acc = p_id_acc;
		exception when NO_DATA_FOUND then
		 billableFlag := '0';
	 end;
	 if billableFlag is NULL then
			billableFlag := '0';
	 end if; 
	 return billableFlag;
	end;

	FUNCTION IsAccountFolder(p_id_acc IN integer) 
		return varchar2
	AS
		folderFlag char(1);
		BEGIN
		 BEGIN
			SELECT c_folder INTO folderFlag FROM t_av_internal 
			WHERE id_acc = p_id_acc;

			exception when NO_DATA_FOUND then
				folderFlag := 'N';
		 END;
 	 	IF folderFlag IS NULL then
			folderFlag := 'N';
		END IF; 

		RETURN folderFlag;
		END;

   FUNCTION encloseddaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER
   AS
   BEGIN
      /* check if the range specified by temp_dt_checkstart and */
      /* temp_dt_checkend is completely inside the range specified */
      /* by temp_dt_start, temp_dt_end */
			if temp_dt_checkend = MTMaxDate() and temp_dt_end = MTMaxDate() then
				if temp_dt_checkstart >= temp_dt_start then
					return 1;
				else
					return 0;
				end if;
			end if;

      IF      temp_dt_checkstart >= temp_dt_start
          AND temp_dt_checkend <= temp_dt_end
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   FUNCTION overlappingdaterange (
      temp_dt_start        DATE,
      temp_dt_end          DATE,
      temp_dt_checkstart   DATE,
      temp_dt_checkend     DATE
   )
      RETURN INTEGER
   AS
   BEGIN
      IF    (temp_dt_start IS NOT NULL AND temp_dt_start > temp_dt_checkend)
         OR (    temp_dt_checkstart IS NOT NULL
             AND temp_dt_checkstart > temp_dt_end
            )
      THEN
         RETURN 0;
      END IF;

      RETURN 1;
   END;

   FUNCTION mtcomputeeffectivebegindate (
      TYPE                  INT,
      offset                INT,
      base                  DATE,
      sub_begin             DATE,
      temp_id_usage_cycle   INT
   )
      RETURN DATE
   AS
      next_interval_begin   DATE;
   BEGIN
      IF (TYPE = 1)
      THEN
         RETURN (base);
      ELSIF (TYPE = 2)
      THEN
         RETURN (  sub_begin
                 + offset
                );
      ELSIF (TYPE = 3)
      THEN
         for i in (SELECT (  dt_end + numtodsinterval(1,'second')
                ) next_interval_begin
           FROM t_pc_interval
          WHERE base BETWEEN dt_start AND dt_end
            AND id_cycle = temp_id_usage_cycle) 
            loop
                next_interval_begin := i.next_interval_begin;
            end loop;

         RETURN (next_interval_begin);
      ELSE
         RETURN (NULL);
      END IF;
   END;

   FUNCTION mtrateschedulescore (TYPE INT, begindate DATE)
      RETURN INT
   AS
      datescore   INT;
      typescore   INT;
   BEGIN
      SELECT DECODE (
                TYPE,
                4, 0,
                0, 0,
                  (  TO_DATE ('1970-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                   - begindate
                  )
                * 86400
             )
        INTO datescore
        FROM DUAL;

      SELECT DECODE (TYPE, 2, 2, 4, 0, 0, 0, 1)
        INTO typescore
        FROM DUAL;

      RETURN (  (typescore * 4294967296)
              + datescore
             );
   END;

   FUNCTION mtdateinrange (startdate DATE, enddate DATE, comparedate DATE)
      RETURN INTEGER
   AS
   BEGIN
      IF  startdate <= comparedate AND comparedate < enddate
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   END;

   /* Function returns the minimum of two dates.  A null date is considered */
   /* to be infinitely large. */
   FUNCTION mtminoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE
   AS
   BEGIN
      IF (   subintervalleft IS NULL
          OR chargeintervalleft < subintervalleft
         )
      THEN
         RETURN (chargeintervalleft);
      ELSE
         RETURN (subintervalleft);
      END IF;
		END;

   /* Function returns the maximum of two dates.  A null date is considered */
   /* to be infinitely small. */
   FUNCTION mtmaxoftwodates (chargeintervalleft DATE, subintervalleft DATE)
      RETURN DATE
   AS
   BEGIN
      IF (   subintervalleft IS NULL
          OR chargeintervalleft > subintervalleft
         )
      THEN
         RETURN (chargeintervalleft);
      ELSE
         RETURN (subintervalleft);
      END IF;
   END;

  FUNCTION MTMinOfThreeDates (p_date1 DATE, p_date2 DATE, p_date3 DATE)
      RETURN DATE
  AS
  BEGIN
    RETURN dbo.MTMinOfTwoDates(p_date1, dbo.MTMinOfTwoDates(p_date2, p_date3));
  END;

  FUNCTION MTMaxOfThreeDates (p_date1 DATE, p_date2 DATE, p_date3 DATE)
      RETURN DATE
  AS
  BEGIN
    RETURN dbo.MTMaxOfTwoDates(p_date1, dbo.MTMaxOfTwoDates(p_date2, p_date3));
  END;

   FUNCTION nextdateafterbillingcycle (temp_id_acc INT, temp_datecheck DATE)
      RETURN DATE
   AS
      temp_dt   DATE;
   BEGIN
      for i in (SELECT (  tpc.dt_end + numtodsinterval(1,'second')
             ) temp_dt
        from t_payment_redirection redir
	      inner join t_acc_usage_cycle auc
	      on auc.id_acc = redir.id_payer
	      inner join t_pc_interval tpc
	      on tpc.id_cycle = auc.id_usage_cycle
	      where redir.id_payee = temp_id_acc
	      AND
	      tpc.dt_start <= temp_datecheck AND temp_datecheck <= tpc.dt_end
	      AND
	      redir.vt_start <= temp_datecheck AND temp_datecheck <= redir.vt_end)
         loop
            temp_dt := i.temp_dt;
         end loop;

      RETURN (temp_dt);
   END;

FUNCTION checksubscriptionconflicts (
      temp_id_acc            INT,
      temp_id_po             INT,
      temp_real_begin_date   DATE,
      temp_real_end_date     DATE,
      temp_id_sub            INT,
      p_allow_acc_po_curr_mismatch  INT,
      p_allow_multiple_pi_sub_rcnrc INT
   )
      RETURN INT
   AS
      temp_status   INTEGER;
      v_count             number := 0;
	  conflicting_usagepi_count INTEGER;
	  
   BEGIN
      SELECT COUNT (t_sub.id_sub)
        INTO temp_status
        FROM t_sub
       WHERE t_sub.id_acc = temp_id_acc
         AND t_sub.id_po = temp_id_po
         AND t_sub.id_sub <> temp_id_sub
         AND dbo.overlappingdaterange (
                t_sub.vt_start,
                t_sub.vt_end,
                temp_real_begin_date,
                temp_real_end_date
             ) = 1;

      IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc <> 1)
      THEN
         /* MTPCUSER_CONFLICTING_PO_SUBSCRIPTION */
         RETURN (-289472485);
      END IF;
	  
      for i in (
      select dbo.overlappingdaterange(temp_real_begin_date,temp_real_end_date,te.dt_start,te.dt_end) temp_status
      from t_po
      INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
      where id_po = temp_id_po) loop
        temp_status := i.temp_status;
      end loop;
      if temp_status <> 1 then
      /* MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE */
      return (-289472472);
      end if;

      SELECT COUNT (id_pi_template)
        INTO temp_status
        FROM t_pl_map
				WHERE t_pl_map.id_po = temp_id_po
				AND t_pl_map.id_paramtable IS NULL
         AND t_pl_map.id_pi_template IN
                   (SELECT id_pi_template
                      FROM t_pl_map
                     WHERE id_paramtable IS NULL AND
                     id_po IN
                                 (SELECT id_po
                                    FROM t_vw_effective_subs subs
                                     WHERE subs.id_sub <> temp_id_sub
														         AND subs.id_acc = temp_id_acc
                                     AND dbo.overlappingdaterange (
                                            subs.dt_start,
                                            subs.dt_end,
                                            temp_real_begin_date,
                                            temp_real_end_date
                                         ) = 1));

      IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc <> 1)
      THEN
         /* MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM; */
         return (-289472484);
      END IF;

    IF (temp_status > 0 AND p_allow_multiple_pi_sub_rcnrc = 1)
    THEN
    -- Check whether conflicting subscription has any Non RC/NRC PIs in it
    SELECT COUNT (id_pi_template) INTO conflicting_usagepi_count
    FROM t_pl_map JOIN t_base_props bp1 on t_pl_map.id_pi_template = bp1.id_prop 
    WHERE 
    t_pl_map.id_po = temp_id_po AND
    t_pl_map.id_paramtable IS NULL AND
    bp1.n_kind in (10,40) AND
    t_pl_map.id_pi_template IN
             (SELECT id_pi_template
              FROM t_pl_map
              WHERE 
                id_paramtable IS NULL AND
                id_po IN
                           (SELECT id_po
                              FROM t_vw_effective_subs subs
                              WHERE subs.id_sub <> temp_id_sub
                              AND subs.id_acc = temp_id_acc
                               AND dbo.overlappingdaterange (
                                      subs.dt_start,
                                      subs.dt_end,
                                      temp_real_begin_date,
                                      temp_real_end_date
                                   ) = 1));
    IF conflicting_usagepi_count > 0
      THEN 
        return (-289472484);
      END IF;
    END IF;
      
/* CR 10872: make sure account and po have the same currency

 BP - actually we need to check if a payer has different currency
 In Kona we allow non billable accounts to be created with no currency
if (dbo.IsAccountAndPOSameCurrency(p_id_acc, p_id_po) = '0') */
if p_allow_acc_po_curr_mismatch <> 1 then
	SELECT count(*) into v_count
	FROM t_payment_redirection pr
	INNER JOIN t_av_internal avi on avi.id_acc = pr.id_payer
	INNER JOIN t_po po on  po.id_po = temp_id_po
	INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
	WHERE pr.id_payee = temp_id_acc
	AND avi.c_currency <>  pl.nm_currency_code
	AND (pr.vt_start <= temp_real_end_date AND pr.vt_end >= temp_real_begin_date);
		 
	if (v_count > 0)
	then
		/* MT_ACCOUNT_PO_CURRENCY_MISMATCH */
		return (-486604729);
	end if;
end if;
/* Check for MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE 0xEEBF004EL -289472434
 BR violation */
   SELECT count(*) into v_count
    FROM  t_account tacc
    INNER JOIN t_account_type tacctype on tacc.id_type = tacctype.id_type
    WHERE tacc.id_acc = temp_id_acc AND tacctype.b_CanSubscribe = '0';
if (v_count > 0)
then
  return(-289472434); /* MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE */
end if;

/* check that account type of the account is compatible with the product offering
 since the absense of ANY mappings for the product offering means that PO is "wide open"
 we need to do 2 EXISTS queries */
SELECT count(*) into v_count
FROM t_po_account_type_map atmap
WHERE atmap.id_po = temp_id_po
AND
not exists (
SELECT 1
FROM  t_account tacc
INNER JOIN t_po_account_type_map atmap on atmap.id_po = temp_id_po AND atmap.id_account_type = tacc.id_type
 WHERE  tacc.id_acc = temp_id_acc);
if (v_count > 0)
then
 return (-289472435); /* MTPCUSER_CONFLICTING_PO_ACCOUNT_TYPE */
end if;

      RETURN (1);
   END;

   /* rounds up to the end of a day */
   FUNCTION mtendofday (indate DATE)
      RETURN DATE
   AS
      retval   DATE;
   BEGIN
		retval := TRUNC (indate);
    
		/* ESR-3933 any year < MTMaxDate (i.e 2038-01-01 00:00:00.000) then return the end of the day for indate (i.e 23:59:59 for the time) */
    if (retval < MTMaxDate) then     
        retval := retval
             + numtodsinterval(1,'day')
             + numtodsinterval(-1,'second');             
    else
    /* ESR-3933 when year > 2037 return 2038-01-01 00:00:00.000 */
    			retval := MTMaxDate;
		end if;
	
    RETURN (retval);
   END;

  FUNCTION mtstartofday (indate DATE) 
  return DATE
  as
   retval DATE;
  begin
   select trunc(indate) into retval from dual;
   return (retval);
  end;


function POContainsDiscount
(p_id_po IN integer) return integer
as
retval integer;
begin
select case when count(id_pi_template) > 0 then 1 else 0 end into retval
from t_pl_map 
INNER JOIN t_base_props tb on tb.id_prop = t_pl_map.id_pi_template
where t_pl_map.id_po = p_id_po AND tb.n_kind = 40; /* discount */
 return retval;
end;

FUNCTION IsCorporateAccount(p_id_acc IN integer,RefDate IN Date) return INTEGER
as
retval integer;
begin
  for i in (select b_IsCorporate 
	          from t_account_type atype
     	      inner join t_account acc on acc.id_type = atype.id_type
	          where acc.id_acc = p_id_acc
						)
  loop
    retval := i.b_IsCorporate;
  end loop;
 return retval;
end;


FUNCTION IsActive(state varchar2) return integer
as
retval integer;
begin
	if state = 'AC' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsSuspended(state varchar2) return integer
as
retval integer;
begin
	if state = 'SU' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsPendingFinalBill(state varchar2) return integer
as
retval integer;
begin
	if state = 'PF' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsClosed(state varchar2) return integer
as
retval integer;
begin
	if state = 'CL' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsArchived(state varchar2) return integer
as
retval integer;
begin
	if state = 'AR' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;

FUNCTION IsInVisableState(state varchar2) return integer
as
retval integer;
begin
	/* if the account is closed or archived */
	if state <> 'CL' AND state <> 'AR' then
		retval := 1;
	else
		retval := 0;
	end if;
	return retval;
end;


function mtconcat(str1 nvarchar2,str2 nvarchar2) return nvarchar2
as
retval nvarchar2(4000);
begin
  select concat(str1,str2) into retval from dual;
  return retval;
end;

function poConstrainedCycleType(offeringID integer) return integer
as
retval integer;
begin
    select max(result.id_cycle_type) into retval
    from (
    select
      case when t_recur.id_cycle_type is NOT NULL AND
				t_recur.tx_cycle_mode = 'BCR Constrained' then
			t_recur.id_cycle_type
	  else
		case when t_discount.id_cycle_type IS NOT NULL then
			t_discount.id_cycle_type
		else
			case when t_aggregate.id_cycle_type IS NOT NULL THEN
				t_aggregate.id_cycle_type
			else
				NULL
			end
		end
      end as id_cycle_type
	FROM t_pl_map
    LEFT OUTER JOIN t_recur on t_recur.id_prop = t_pl_map.id_pi_template OR t_recur.id_prop = t_pl_map.id_pi_instance
    LEFT OUTER JOIN t_discount on t_discount.id_prop = t_pl_map.id_pi_template  OR t_discount.id_prop = t_pl_map.id_pi_instance
    LEFT OUTER JOIN t_aggregate on t_aggregate.id_prop = t_pl_map.id_pi_template  OR t_aggregate.id_prop = t_pl_map.id_pi_instance
		WHERE
    t_pl_map.id_po = offeringID
    and t_pl_map.id_paramtable is null
    ) result;
    if retval is NULL then
      retval := 0;
    end if;
  return retval;
end;

function IsInSameCorporateAccount(
acc1 IN integer,
acc2 IN integer,
refdate date
) return integer
as
  retval integer;
  v_id_corp1 int;
  v_id_corp2 int;
begin
  retval := 0;
  
  begin

  for x in (select id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = acc1
  and refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1')
  loop
		v_id_corp1 := x.id_ancestor;
	end loop;

  for x in (select id_ancestor
  from t_account_ancestor anc
  inner join t_account acc
  on anc.id_ancestor = acc.id_acc
  inner join t_account_type atype
  on acc.id_type = atype.id_type
  where anc.id_descendent = acc2
  and refdate between anc.vt_start AND anc.vt_end
  and atype.b_iscorporate = '1')
  loop
		v_id_corp2 := x.id_ancestor;
	end loop;

		if (v_id_corp1 = v_id_corp2) then
			retval := 1;
		else 
			if (v_id_corp1 is null AND v_id_corp2 is null) then
				retval := 1;
			else 
				retval := 0;
			end if;
		end if;
  exception when NO_DATA_FOUND then
      retval := 0;
  end;
  return retval;
end;

function POContainsOnlyAbsoluteRates(
p_id_po IN integer
) return integer
as
  retval integer;
begin
	select count(te.id_eff_date) into retval
FROM t_po po
INNER JOIN t_pl_map map ON
	map.id_po = po.id_po
	AND map.id_paramtable IS NOT NULL
	AND map.id_sub IS NULL
LEFT OUTER JOIN t_rsched sched ON
	sched.id_pt = map.id_paramtable
	AND sched.id_pricelist = map.id_pricelist
	AND sched.id_pi_template = map.id_pi_template
INNER JOIN t_effectivedate te ON
	te.id_eff_date = sched.id_eff_date
	/* only absolute or NULL dates */
	AND (te.n_begintype in (2,3) OR te.n_endtype in (2,3))
WHERE po.id_po = p_id_po;
	if(retval > 0) then
		return 0;
  else
    return 1;
	end if;
  return 0;
end;

FUNCTION CheckEBCRCycleTypeCompatible
  (p_EBCRCycleType INT, p_OtherCycleType INT)
RETURN INT is
BEGIN
  /* checks weekly based cycle types */
  IF (((p_EBCRCycleType = 4) OR (p_EBCRCycleType = 5)) AND
      ((p_OtherCycleType = 4) OR (p_OtherCycleType = 5))) then
    RETURN 1;   /* success */
  END IF;
  /* checks monthly based cycle types */
  IF ((p_EBCRCycleType in (1,7,8,9)) AND
      (p_OtherCycleType in (1,7,8,9))) THEN
    RETURN 1;   /* success */
  END IF;
  RETURN 0;     /* failure */
END;

FUNCTION POCONTAINSBILLINGCYCLERELATIVE(
id_po 	IN NUMBER  DEFAULT NULL)
RETURN NUMBER
AS
id_po_ 	NUMBER(10,0) := id_po;
found 	NUMBER(10,0);
/*  product offering ID */
/*  1 if the PO contains BCR PIs, otherwise 0 */
/*  checks for billing cycle relative discounts */

BEGIN
	BEGIN
		SELECT  CASE  
		WHEN COUNT(*)>0 THEN 1 
		ELSE 0  
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp 
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_discount 
		disc 
		ON disc.id_prop = bp.id_prop  
		WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_ 
		 AND disc.id_usage_cycle IS NULL;
		IF  found = 1 THEN
/*  checks for billing cycle relative recurring charges */
			RETURN found;
		END IF;
		
		SELECT  CASE  
		WHEN COUNT(*)>0 THEN 1 
		ELSE 0  
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp 
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_recur 
		rc 
		ON rc.id_prop = bp.id_prop  
			WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_ 
			 AND  
			(rc.tx_cycle_mode = 'BCR'  
			 OR rc.tx_cycle_mode = 'BCR Constrained');
		IF  found = 1 THEN
/*  checks for billing cycle relative aggregate charges */
			RETURN found;
		END IF;
		SELECT  CASE  
		WHEN COUNT(*)>0 THEN 1 
		ELSE 0  
		END tmpAlias1
		into found
		FROM t_pl_map plm INNER JOIN t_base_props bp 
		ON bp.id_prop = plm.id_pi_template INNER JOIN t_aggregate 
		agg 
		ON agg.id_prop = bp.id_prop  
			WHERE plm.id_po = POCONTAINSBILLINGCYCLERELATIVE.id_po_ 
			 AND agg.id_usage_cycle IS NULL;
		RETURN found;
	END;
END POCONTAINSBILLINGCYCLERELATIVE;

FUNCTION CHECKGROUPMEMBERSHIPCYCLECONST(
dt_now 	IN DATE  DEFAULT NULL,
id_group 	IN NUMBER  DEFAULT NULL)
RETURN NUMBER
AS
dt_now_ 	DATE := dt_now;
id_group_ 	NUMBER(10,0) := id_group;
StoO_rowcnt	INTEGER;
id_po 	NUMBER(10,0);
violator 	NUMBER(10,0);
/*  system date */
/*  group ID to check */
/*  1 for success, otherwise negative decimal error code  */
/*  this function enforces the business rule given in CR9906 */
/*  a group subscription to a PO containing a BCR priceable item */
/*  should only have member's with payers that have a usage cycle */
/*  that matches the one specified by the group subscription. */
/*  at any point in time, this cycle consistency should hold true.  */
/*  looks up the PO the group is subscribed to */
BEGIN
	BEGIN
		FOR rec IN ( SELECT   sub.id_po
								 FROM t_group_sub gs INNER JOIN t_sub sub 
								ON sub.id_group = gs.id_group  
									WHERE gs.id_group = CHECKGROUPMEMBERSHIPCYCLECONST.id_group_)
		LOOP
		   id_po := rec.id_po ; 
		
		END LOOP;
/*  this check only applies to PO's that contain a BCR priceable item */
		/*[SPCONV-ERR(48)]:Manual conversion required POContainsBillingCycleRelative()*/

		IF  dbo.POContainsBillingCycleRelative(CHECKGROUPMEMBERSHIPCYCLECONST.id_po) = 1 THEN
		BEGIN
/*  true */
/*  attempts to find a usage cycle mismatch for the member's payers of the group sub */
/*  ideally there should be none */

			FOR rec IN ( SELECT   gsm.id_acc
											 FROM t_gsubmember gsm INNER JOIN t_group_sub gs 
												ON gs.id_group = gsm.id_group INNER JOIN t_sub sub 
												ON sub.id_group = gs.id_group INNER JOIN t_payment_redirection 
									payer 
												ON payer.id_payee = gsm.id_acc AND payer.vt_end >= 
									sub.vt_start AND payer.vt_start <= sub.vt_end INNER JOIN 
									t_acc_usage_cycle auc 
												ON auc.id_acc = payer.id_payer AND auc.id_usage_cycle 
									<> gs.id_usage_cycle  
													WHERE gs.id_group = CHECKGROUPMEMBERSHIPCYCLECONST.id_group_ 
									 
													 AND  
													( 
													(CHECKGROUPMEMBERSHIPCYCLECONST.dt_now_  BETWEEN 
									sub.vt_start AND sub.vt_end)  
													 OR  
													(sub.vt_start > CHECKGROUPMEMBERSHIPCYCLECONST.dt_now_)))
			LOOP
			   violator := rec.id_acc ; 
			   StoO_rowcnt := nvl(StoO_rowcnt,0)+1;
			END LOOP;
/*  checks all payer's who overlap with the group sub */
/*  cycle mismatch */
/*  checks only the requested group */
/*  only consider current or future group subs */
/*  don't worry about group subs in the past */
/*  MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH */

			IF  StoO_rowcnt > 0 THEN
				RETURN -486604730;
			END IF;
/*  success */


		END;
		END IF;
		RETURN 1;
	END;
END CHECKGROUPMEMBERSHIPCYCLECONST;

FUNCTION CheckGroupMembershipEBCRConstr
(
  p_dt_now DATE, /* system date */
  p_id_group INT     /* group ID to check */
)
RETURN INT  /* 1 for success, negative HRESULT for failure */
AS
TYPE REC IS RECORD
          (
            id_acc INT, /* member account (payee) */
            id_usage_cycle INT, /* payer's cycle */
            b_compatible INT /* EBCR compatibility: 1 or 0 */
          );
TYPE TAB_REC IS TABLE OF REC INDEX by binary_integer;
v_results TAB_REC;

BEGIN

  /* checks to see if a group subscription and all of its */
  /* members comply with EBCR payer cycle constraints: */
  /*   1) that for a member, all of its payers have the same billing cycle */
  /*   2) that this billing cycle is EBCR compatible. */
  /* checks group member's payers */

  SELECT 
    pay.id_payee,
    payercycle.id_usage_cycle,
    dbo.CheckEBCRCycleTypeCompatible(payercycle.id_cycle_type, rc.id_cycle_type)
    bulk collect into v_results
  FROM t_gsubmember gsm
  INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group   INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_payment_redirection pay ON 
    pay.id_payee = gsm.id_acc AND
    /* checks all payer's who overlap with the group sub */
    pay.vt_end >= sub.vt_start AND
    pay.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = pay.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE 
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'Y' AND
    gs.id_group = p_id_group AND
    plmap.id_paramtable IS NULL AND
    /* TODO: it would be better if we didn't consider subscriptions that ended */
    /*       in a hard closed interval so that retroactive changes would be properly guarded. */
    /* only consider current or future group subs */
    /* don't worry about group subs in the past */
    ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > p_dt_now));

	/* no results means on EBCR's to check */
	if v_results is not null and v_results.count < 1 then
		return 1;
	end if;

  /* checks that members' payers are compatible with the EBCR cycle type */
  FOR i in v_results.FIRST .. v_results.last
  LOOP
    IF v_results(i).b_compatible =0 THEN
        RETURN -289472443; /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_MEMBER */
    END IF;
  END LOOP;


  /* checks for each member there is only one payer cycle across all payers */
  FOR i in v_results.FIRST .. v_results.last
  LOOP
      FOR j in v_results.FIRST .. v_results.last
      LOOP
        IF v_results(i).id_acc = v_results(j).id_acc AND 
           v_results(i).id_usage_cycle <> v_results(j).id_usage_cycle THEN
            RETURN -289472442; /* MTPCUSER_EBCR_MEMBERS_CONFLICT_WITH_EACH_OTHER */
        END IF;
      END LOOP;
  END LOOP;

  RETURN 1; /* success */
END;

FUNCTION CHECKGROUPRECEIVEREBCRCONS
(
  p_dt_now DATE, /* system date */
  p_id_group INT     /* group ID to check */
)
RETURN INT  /* 1 for success, negative HRESULT for failure */
AS
    TYPE REC IS RECORD
      (
        id_acc INT, /* receiver account */
        id_usage_cycle INT, /* payer's cycle */
        b_compatible INT /* EBCR compatibility: 1 or 0 */
      );
    TYPE TAB_REC IS TABLE OF REC INDEX BY BINARY_INTEGER;
    v_results TAB_REC;
BEGIN
  /* checks to see if a group subscription and all of its' */
  /* receivers' payers comply with the EBCR payer cycle constraints: */
  /* 1) that all receivers' payers must have the same billing cycle */
  /* 2) that billing cycle must be EBCR compatible. */


  /* store intermediate results away for later use since different groupings will need to be made */

  SELECT DISTINCT gsrm.id_acc, payercycle.id_usage_cycle, dbo.CheckEBCRCycleTypeCompatible(payercycle.id_cycle_type, rc.id_cycle_type)
  BULK COLLECT INTO v_results
  FROM t_gsub_recur_map gsrm
  INNER JOIN t_group_sub gs ON gs.id_group = gsrm.id_group
  INNER JOIN t_sub sub ON sub.id_group = gs.id_group
  INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po AND
                               plmap.id_pi_instance = gsrm.id_prop
  INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
  INNER JOIN t_payment_redirection payer ON 
    payer.id_payee = gsrm.id_acc AND
    /* checks all payer's who overlap with the group sub */
    payer.vt_end >= sub.vt_start AND
    payer.vt_start <= sub.vt_end
  INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = payer.id_payer
  INNER JOIN t_usage_cycle payercycle ON payercycle.id_usage_cycle = auc.id_usage_cycle
  WHERE 
    rc.tx_cycle_mode = 'EBCR' AND
    rc.b_charge_per_participant = 'N' AND
    /* checks only the requested group */
    gs.id_group = p_id_group AND
    plmap.id_paramtable IS NULL AND
    /* only consider receivers based on wall-clock transaction time */
    p_dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
    /* TODO: it would be better if we didn't consider subscriptions that ended */
    /*       in a hard closed interval so that retroactive changes would be properly guarded. */
    /* only consider current or future group subs     don't worry about group subs in the past */
    ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
     (sub.vt_start > p_dt_now));

  /* checks that receivers' payers are compatible with the EBCR cycle type */
  IF v_results.EXISTS(1) THEN
      FOR I IN v_results.first .. v_results.last
      LOOP
        IF v_results(i).b_compatible = 0 THEN
            RETURN -289472441; /* MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_PAYER_OF_RECEIVER */
        END IF;
      END LOOP;
      IF v_results.COUNT > 1 THEN
         RETURN -289472440;
      END IF;
  END IF;

  RETURN 1; /* success */
END;

    function csvtoint (p_id_instances varchar2)return tab_id_instance is
        v_tab_id_instance tab_id_instance:=tab_id_instance();
    begin
        if instr(p_id_instances,',',1) = 0 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(p_id_instances);
            return v_tab_id_instance;
        elsif instr(p_id_instances,',',1) > 1 then
            v_tab_id_instance.extend(1);
            v_tab_id_instance(1) := to_number(substr(p_id_instances,1,instr(p_id_instances,',',1)-1));
            for i in 2..4000
            loop
                v_tab_id_instance.extend(1);
                if (instr(p_id_instances,',',1,i) > 0) then
                    v_tab_id_instance(i):= to_number( substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),((instr(p_id_instances,',',1,i))-(instr(p_id_instances,',',1,i-1))-1)) );
                else
                    v_tab_id_instance(i):= to_number(substr(p_id_instances,(instr(p_id_instances,',',1,i-1)+1),length(p_id_instances)- instr(p_id_instances,',',1,i-1)));
                    exit;
                end if;
            end loop;
            return v_tab_id_instance;
        end if;
    end csvtoint;

    function String2Table(p_str in clob, p_delim in varchar2 default '.')
  	  return  str_tab
    as
  	   l_str long default p_str || p_delim;
  	   l_n number;
  	   l_data str_tab := str_tab();
    begin
  	 loop
  	     l_n := instr( l_str, p_delim );
  	     exit when (nvl(l_n,0) = 0);
  	     l_data.extend;
   	     l_data( l_data.count ) := ltrim(rtrim(substr(l_str,1,l_n-1)));
  	     l_str := substr( l_str, l_n+length(p_delim) );
     end loop;
     return l_data;
    end String2Table;

    function csvtostrtab(csv varchar2) 
    return str_tab
    is 
      tab str_tab := str_tab();
      str varchar2(4000) := csv;
      tok varchar2(4000);
      apos int := 1;
      zpos int := 1;
      i int := 0;
    begin

      str := str || ',';
      while zpos < length(str)
      loop
        zpos := instr(str, ',', apos);
        tok := substr(str, apos, zpos-apos);
        apos := zpos + 1;

        i := i + 1;
        tab.extend;
        tab(i) := tok;
        
      end loop;
      
      return tab;

    end csvtostrtab;


    function strtabtocsv(
      tab str_tab) 
    return varchar2
    as 
      csv varchar2(4000) := '';
      i   number;

    begin

      i := tab.first;
      while i is not null 
      loop

        csv := csv || tab(i) 
          || case when i < tab.last then ', ' else '' end;

        i := tab.next(i);
      end loop;

      return csv;
      
    end strtabtocsv;

   
FUNCTION DERIVEEBCRCYCLE(
    usageCycle    IN NUMBER DEFAULT NULL,
    subStart      IN DATE DEFAULT NULL,
    ebcrCycleType IN NUMBER DEFAULT NULL)
  RETURN NUMBER
AS
  usageCycle_ NUMBER(10,0)    := usageCycle;
  subStart_ DATE              := subStart;
  ebcrCycleType_   NUMBER(10,0) := ebcrCycleType;
  StoO_rowcnt      INTEGER;
  usageCycleType   NUMBER(10,0);
  derivedEBCRCycle NUMBER(10,0);
  startDay         NUMBER(10,0);
  startMonth       NUMBER(10,0);
  endDay           NUMBER(10,0);
  endOfMonth       NUMBER(10,0);
  /*  billing cycle of the account (context-sensitive) */
  /*  start date of the subscription/membership (context-sensitive) */
  /*  cycle type of the EBCR PI  */
  /*  looks up the usage cycle's cycle type */
BEGIN
  BEGIN
    FOR rec IN
    (SELECT id_cycle_type
    FROM t_usage_cycle
    WHERE id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
    )
    LOOP
      usageCycleType := rec.id_cycle_type ;
      StoO_rowcnt    := NVL(StoO_rowcnt,0)+1;
    END LOOP;
    IF ( StoO_rowcnt != 1) THEN
      /*  ERROR: Exactly one usage cycle type was not found for given usage cycle ID */
      /*  if  cycle types are identical then EBCR reduces to a trivial BCR case */
      RETURN -1;
    END IF;
    IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = DERIVEEBCRCYCLE.usageCycleType) THEN
      /*  Case map: */
      /*    -Weekly EBCR */
      /*       -Bi-weekly BC */
      /*    - Bi-weekly EBCR */
      /*       -Weekly BC */
      /*    -Monthly EBCR */
      /*       -Quarterly BC */
      /*       -Annual BC */
      /*    -Quarterly EBCR */
      /*       -Monthly BC */
      /*       -Annual BC */
      /*    -Annual EBCR */
      /*       -Monthly BC */
      /*       -Quarterly BC */
      /*  Weekly EBCR */
      RETURN DERIVEEBCRCYCLE.usageCycle_;
    END IF;
    IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 4) THEN
      BEGIN
        /*  only Bi-weekly cycle type is permitted */
        IF ( DERIVEEBCRCYCLE.usageCycleType != 5) THEN
          /*  ERROR: unsupported EBCR cycle combination */
          RETURN -3;
        END IF;
        /*  retrieves the Bi-weekly start day */
        FOR rec IN
        (SELECT start_day
        FROM t_usage_cycle uc
        WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
        )
        LOOP
          startDay := rec.start_day ;
        END LOOP;
        /*  reduces the start day [1,14] to a start day between [1,7] */
        DERIVEEBCRCYCLE.startDay     := MOD(DERIVEEBCRCYCLE.startDay, 7);
        IF ( DERIVEEBCRCYCLE.startDay = 0) THEN
          /*    January 2000     */
          /*  Su Mo Tu We Th Fr Sa */
          /*                     1 */
          /*   2  3  4  5  6  7  8 */
          /*   9 10 11 12 13 14 15 */
          /*  16 17 18 19 20 21 22 */
          /*  23 24 25 26 27 28 29 */
          /*  30 31  */
          /*  Bi-weekly      Weekly */
          /*  start day  --> end day of week */
          /*  1, 8              6 */
          /*  2, 9              7 */
          /*  3, 10             1 */
          /*  4, 11             2 */
          /*  5, 12             3 */
          /*  6, 13             4 */
          /*  7, 14             5 */
          /*  translates the start day to an end day of week for use with Weekly  */
          DERIVEEBCRCYCLE.startDay := 7;
        END IF;
        DERIVEEBCRCYCLE.endDay     := DERIVEEBCRCYCLE.startDay - 2;
        IF ( DERIVEEBCRCYCLE.endDay < 1) THEN
          /*  handles wrap around */
          DERIVEEBCRCYCLE.endDay := DERIVEEBCRCYCLE.endDay + 7;
        END IF;
        FOR rec IN
        (SELECT ebcr.id_usage_cycle
        FROM t_usage_cycle ebcr
        WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
        AND ebcr.day_of_week     = DERIVEEBCRCYCLE.endDay
        )
        LOOP
          derivedEBCRCycle := rec.id_usage_cycle ;
        END LOOP;
      END;
    ELSE
      /*  Bi-weekly EBCR */
      IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 5) THEN
        BEGIN
          /*  only a Weekly cycle type is permitted */
          IF ( DERIVEEBCRCYCLE.usageCycleType != 4) THEN
            /*  ERROR: unsupported EBCR cycle combination */
            RETURN -3;
          END IF;
          /*  retrieves the Weekly end day */
          FOR rec IN
          (SELECT day_of_week
          FROM t_usage_cycle uc
          WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
          )
          LOOP
            endDay := rec.day_of_week ;
          END LOOP;
          /*  performs the reverse translation described in the Weekly EBCR case */
          /*  NOTE: subscription information is ignored */
          DERIVEEBCRCYCLE.startDay     := DERIVEEBCRCYCLE.endDay + 2;
          IF ( DERIVEEBCRCYCLE.startDay > 7) THEN
            /*  handles wrap around */
            DERIVEEBCRCYCLE.startDay := DERIVEEBCRCYCLE.startDay - 7;
          END IF;
          FOR rec IN
          (SELECT ebcr.id_usage_cycle
          FROM t_usage_cycle ebcr
          WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
          AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
          AND ebcr.start_month     = 1
          AND ebcr.start_year      = 2000
          )
          LOOP
            derivedEBCRCycle := rec.id_usage_cycle ;
          END LOOP;
        END;
      ELSE
        /*  Monthly EBCR */
        IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 1) THEN
          BEGIN
            /*  only Quarterly, SemiAnnual, and Annual billing cycle types are legal for this case */
            IF ( DERIVEEBCRCYCLE.usageCycleType NOT IN(7, 8, 9)) THEN
              /*  ERROR: unsupported EBCR cycle combination */
              /*  the usage cycle type is Quarterly, Semiannual, or Annual */
              /*  all of which use the same start_day property */
              RETURN -3;
            END IF;
            FOR rec IN
            (SELECT start_day
            FROM t_usage_cycle uc
            WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
            )
            LOOP
              startDay := rec.start_day ;
            END LOOP;
            /*  translates the start day to an end day since Monthly cycle types */
            /*  use end days and Quarterly and Annual cycle types use start days */
            BEGIN
              DERIVEEBCRCYCLE.endDay     := DERIVEEBCRCYCLE.startDay - 1;
              IF ( DERIVEEBCRCYCLE.endDay < 1) THEN
                /*  wraps around to EOM */
                DERIVEEBCRCYCLE.endDay := 31;
              END IF;
            END;
            FOR rec IN
            (SELECT ebcr.id_usage_cycle
            FROM t_usage_cycle ebcr
            WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
            AND ebcr.day_of_month    = DERIVEEBCRCYCLE.endDay
            )
            LOOP
              derivedEBCRCycle := rec.id_usage_cycle ;
            END LOOP;
          END;
        ELSE
          /*  Quarterly EBCR */
          IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 7) THEN
            BEGIN
              /*  Monthly billing cycle type */
              IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                BEGIN                  
                  /*  infers the start month from the subscription start date    */
                  /* CORE-8006 */
                  For rec in  
                    (
                        select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
							TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
                          from t_usage_interval tui
                          join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
                          where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                            and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
                            and tui.dt_end > DERIVEEBCRCYCLE.subStart_
                    )
                  LOOP
					  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
                      DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;                   
                  END LOOP;
					
				  /* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
				  IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
					  DERIVEEBCRCYCLE.startDay := 28;
				  END IF;
				  
                  DERIVEEBCRCYCLE.startMonth     := MOD(DERIVEEBCRCYCLE.startMonth, 3);
                  IF ( DERIVEEBCRCYCLE.startMonth = 0) THEN
                    DERIVEEBCRCYCLE.startMonth   := 3;
                  END IF;
                END;
              ELSE
                /*  Annual or semiannual billing cycle type */
                IF ( DERIVEEBCRCYCLE.usageCycleType IN (8,9)) THEN
                  BEGIN
                    FOR rec IN
                    (SELECT start_day,
                      start_month
                    FROM t_usage_cycle uc
                    WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                    )
                    LOOP
                      startDay   := rec.start_day ;
                      startMonth := rec.start_month ;
                    END LOOP;
                  END;
                ELSE
                  /*  ERROR: unsupported EBCR cycle combination */
                  RETURN -3;
                END IF;
              END IF;
              /*  translates the Annual start month [1 - 12] to a Quarterly start month [1 - 3] */
              DERIVEEBCRCYCLE.startMonth     := MOD(DERIVEEBCRCYCLE.startMonth, 3);
              IF ( DERIVEEBCRCYCLE.startMonth = 0) THEN
                DERIVEEBCRCYCLE.startMonth   := 3;
              END IF;
              FOR rec IN
              (SELECT ebcr.id_usage_cycle
              FROM t_usage_cycle ebcr
              WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
              AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
              AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
              )
              LOOP
                derivedEBCRCycle := rec.id_usage_cycle ;
              END LOOP;
            END;
          ELSE
            /*  Annual EBCR */
            IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 8) THEN
              BEGIN
                /*  Monthly billing cycle type */
                IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                  BEGIN                    
                    /*  infers the start month from the subscription start date    */
                    /* CORE-8006 */
                   For rec in  
                    (
                        select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
							TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
                          from t_usage_interval tui
                          join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
                          where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                            and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
                            and tui.dt_end > DERIVEEBCRCYCLE.subStart_
                    )
                    LOOP
					  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
                      DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;                   
                    END LOOP;
					
					/* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
					IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
						DERIVEEBCRCYCLE.startDay := 28;
					END IF;
                  END;
                ELSE
                  /*  Quarterly or semiannual billing cycle type */
                  IF ( DERIVEEBCRCYCLE.usageCycleType IN (7,9)) THEN
                    BEGIN
                      FOR rec IN
                      (SELECT start_day,
                        start_month
                      FROM t_usage_cycle uc
                      WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                      )
                      LOOP
                        startDay   := rec.start_day ;
                        startMonth := rec.start_month ;
                      END LOOP;
                      endOfMonth  := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(startMonth,'09')||'1999','MMYYYY')),'DD') );
                      IF (startDay > endOfMonth) THEN
                        startDay  := endOfMonth;
                      END IF;
                    END;
                  ELSE
                    /*  ERROR: unsupported usage cycle combination */
                    RETURN -3;
                  END IF;
                END IF;
                FOR rec IN
                (SELECT ebcr.id_usage_cycle
                FROM t_usage_cycle ebcr
                WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
                AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
                AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
                )
                LOOP
                  derivedEBCRCycle := rec.id_usage_cycle ;
                END LOOP;
              END;
            ELSE
				/* SemiAnnual EBCR */
              IF ( DERIVEEBCRCYCLE.ebcrCycleType_ = 9) THEN
                BEGIN
                  /*  Monthly billing cycle type */
                  IF ( DERIVEEBCRCYCLE.usageCycleType = 1) THEN
                    BEGIN
                      /*  infers the start month from the subscription start date    */
					  /* CORE-8006 */
					  For rec in  
						(
							select TO_NUMBER(TO_CHAR( tui.dt_start, 'DD')) tui_start_day,
								TO_NUMBER(TO_CHAR( tui.dt_start, 'MM')) tui_start_month
							  from t_usage_interval tui
							  join t_usage_cycle tuc on tuc.id_usage_cycle = tui.id_usage_cycle
							  where tui.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
								and tui.dt_start <= DERIVEEBCRCYCLE.subStart_
								and tui.dt_end > DERIVEEBCRCYCLE.subStart_
						)
					  LOOP
						  DERIVEEBCRCYCLE.startDay := rec.tui_start_day;
						  DERIVEEBCRCYCLE.startMonth := rec.tui_start_month;                   
					  END LOOP;

					  /* Leap years are a problem.  If the last day of the month is the 29th, it's really the 28th for this purpose */
					  IF (DERIVEEBCRCYCLE.startMonth = 2 AND DERIVEEBCRCYCLE.startDay = 29) THEN
						DERIVEEBCRCYCLE.startDay := 28;
					  END IF;
                    END;
                  ELSE
                    /*  Quarterly or annual billing cycle type */
                    IF ( DERIVEEBCRCYCLE.usageCycleType IN (7,8)) THEN
                      BEGIN
                        FOR rec IN
                        (SELECT start_day,
                          start_month
                        FROM t_usage_cycle uc
                        WHERE uc.id_usage_cycle = DERIVEEBCRCYCLE.usageCycle_
                        )
                        LOOP
                          startDay   := rec.start_day ;
                          startMonth := rec.start_month ;
                        END LOOP;
                        endOfMonth  := TO_NUMBER(TO_CHAR(LAST_DAY(TO_DATE(TO_CHAR(startMonth,'09')||'1999','MMYYYY')),'DD') );
                        IF (startDay > endOfMonth) THEN
                          startDay  := endOfMonth;
                        END IF;
                      END;
                    ELSE
                      /*  ERROR: unsupported usage cycle combination */
                      RETURN -3;
                    END IF;
                  END IF;
                  FOR rec IN
                  (SELECT ebcr.id_usage_cycle
                  FROM t_usage_cycle ebcr
                  WHERE ebcr.id_cycle_type = DERIVEEBCRCYCLE.ebcrCycleType_
                  AND ebcr.start_day       = DERIVEEBCRCYCLE.startDay
                  AND ebcr.start_month     = DERIVEEBCRCYCLE.startMonth
                  )
                  LOOP
                    derivedEBCRCycle := rec.id_usage_cycle ;
                  END LOOP;
                END;
              ELSE
                /*  unsupported EBCR cycle type */
                RETURN -4;
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;
    IF ( DERIVEEBCRCYCLE.derivedEBCRCycle IS NULL) THEN
      /*  derivation failed */
      RETURN -5;
    END IF;
    RETURN DERIVEEBCRCYCLE.derivedEBCRCycle;
  END;
END DERIVEEBCRCYCLE;

FUNCTION DOESACCOUNTHAVEPAYEES(
id_acc 	IN NUMBER  DEFAULT NULL,
dt_ref 	IN DATE  DEFAULT NULL)
RETURN VARCHAR2
AS
id_acc_ 	NUMBER(10,0) := id_acc;
dt_ref_ 	DATE := dt_ref;
returnValue 	CHAR(1);
BEGIN
	BEGIN
		SELECT  CASE  
		WHEN count(*)>0 THEN 'Y' 
		ELSE 'N'  
		END tmpAlias1
		into returnValue
		FROM t_payment_redirection  
		WHERE id_payer = DOESACCOUNTHAVEPAYEES.id_acc_  
		 and  
		( 
		(DOESACCOUNTHAVEPAYEES.dt_ref_  BETWEEN vt_start AND 
		vt_end)  
		 OR DOESACCOUNTHAVEPAYEES.dt_ref_ < vt_start);

		IF  ( DOESACCOUNTHAVEPAYEES.returnValue is NULL) THEN
		BEGIN
			
			DOESACCOUNTHAVEPAYEES.returnValue :=  'N';
		END;
		END IF;
		RETURN DOESACCOUNTHAVEPAYEES.returnValue;
	END;
END DOESACCOUNTHAVEPAYEES;

    FUNCTION GETCURRENTINTERVALID(
    aDTNow 	IN DATE  DEFAULT NULL,
    aDTSession 	IN DATE  DEFAULT NULL,
    aAccountID 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    aDTNow_ 	DATE := aDTNow;
    aDTSession_ 	DATE := aDTSession;
    aAccountID_ 	NUMBER(10,0) := aAccountID;
    retVal 	NUMBER(10,0);
    BEGIN
        BEGIN
            FOR rec IN ( SELECT   id_usage_interval
                                     FROM t_acc_usage_interval aui INNER JOIN t_usage_interval 
                                    ui 
                                    ON ui.id_interval = aui.id_usage_interval  
                                        WHERE ui.tx_interval_status  <> 'H'  
                                         AND GETCURRENTINTERVALID.aDTSession_  BETWEEN ui.dt_start 
                                    AND ui.dt_end  
                                         AND  
                                        ( 
                                        (aui.dt_effective IS NULL)  
                                         OR  
                                        (aui.dt_effective <= GETCURRENTINTERVALID.aDTNow_))  
                                         AND aui.id_acc = GETCURRENTINTERVALID.aAccountID_)
            LOOP
               retVal := rec.id_usage_interval ; 
            
            END LOOP;
            RETURN GETCURRENTINTERVALID.retVal;
        END;
    END GETCURRENTINTERVALID;

FUNCTION ISACCOUNTANDPOSAMECURRENCY(
id_acc 	IN NUMBER  DEFAULT NULL,
id_po 	IN NUMBER  DEFAULT NULL)
RETURN VARCHAR2
AS
id_acc_ 	NUMBER(10,0) := id_acc;
id_po_ 	NUMBER(10,0) := id_po;
sameCurrency 	CHAR(1);
BEGIN
	BEGIN
		FOR rec IN ( SELECT 
		 CASE  
		WHEN ( 
				SELECT  COUNT(id_po) 
				 FROM t_pricelist pl inner JOIN t_po po 
		ON po.id_nonshared_pl = pl.id_pricelist AND po.id_po = ISACCOUNTANDPOSAMECURRENCY.id_po_ 
		inner JOIN t_av_internal av 
		ON av.c_currency = pl.nm_currency_code AND av.id_acc = ISACCOUNTANDPOSAMECURRENCY.id_acc_ 
		 )=0 THEN '0' 
		ELSE '1'  
		END tmpAlias1
		 FROM DUAL )
		LOOP
		  
		 sameCurrency := rec.tmpAlias1 ; 
		
		END LOOP;
		RETURN ISACCOUNTANDPOSAMECURRENCY.sameCurrency;
	END;
END ISACCOUNTANDPOSAMECURRENCY;

    FUNCTION ISACCOUNTPAYINGFOROTHERS(
    id_acc 	IN NUMBER  DEFAULT NULL,
    dt_ref 	IN DATE  DEFAULT NULL)
    RETURN VARCHAR2
    AS
    id_acc_ 	NUMBER(10,0) := id_acc;
    dt_ref_ 	DATE := dt_ref;
    returnValue 	CHAR(1);
    BEGIN
        BEGIN
            SELECT  CASE  
            WHEN count(*)>0 THEN 'Y' 
            ELSE 'N'  
            END tmpAlias1
			into returnValue
                                     FROM t_payment_redirection  
                                        WHERE id_payer = ISACCOUNTPAYINGFOROTHERS.id_acc_  
                                         and id_payer <> id_payee  
                                         and  
                                        ( 
                                        (ISACCOUNTPAYINGFOROTHERS.dt_ref_  BETWEEN vt_start AND 
                                    vt_end)  
                                         OR ISACCOUNTPAYINGFOROTHERS.dt_ref_ < vt_start);

    /* this is the key difference between this and DoesAccountHavePayees */


            IF  ( ISACCOUNTPAYINGFOROTHERS.returnValue is NULL) THEN
            BEGIN
                
                ISACCOUNTPAYINGFOROTHERS.returnValue :=  'N';
            END;
            END IF;
            RETURN ISACCOUNTPAYINGFOROTHERS.returnValue;
        END;
    END ISACCOUNTPAYINGFOROTHERS;

    FUNCTION IsBillingCycleUpdProhibitedByG
    (
      p_dt_now DATE,
      p_id_acc INT
    )
    RETURN INT IS
    v_count number:=0;
    BEGIN

      /* checks if the account pays for a member of a group subscription */
      /* associated with a Per Participant EBCR RC */
        SELECT count(1) into v_count
        FROM t_gsubmember gsm
        INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group
        INNER JOIN t_sub sub ON sub.id_group = gs.id_group
        INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po
        INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
        INNER JOIN t_payment_redirection payer ON 
        payer.id_payee = gsm.id_acc AND
        /* checks all payer's who overlap with the group sub */
        payer.vt_end >= sub.vt_start AND
        payer.vt_start <= sub.vt_end
        INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
        WHERE 
          rc.tx_cycle_mode = 'EBCR' AND
          rc.b_charge_per_participant = 'Y' AND
          payer.id_payer = p_id_acc AND
          plmap.id_paramtable IS NULL AND
          /* TODO: it would be better if we didn't consider subscriptions that ended */
          /*       in a hard closed interval so that retroactive changes would be properly guarded. */
          /* only consider current or future group subs */
          /* don't worry about group subs in the past */
          ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
           (sub.vt_start > p_dt_now));
        if v_count>0 then
            RETURN -289472439;  /* MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_MEMBER */
        end if;

        v_count := 0;

      /* checks if the account pays for a receiver of a group subscription */
      /* associated with a Per Subscriber EBCR RC */

        SELECT count(1) into v_count
        FROM t_gsub_recur_map gsrm
        INNER JOIN t_group_sub gs ON gs.id_group = gsrm.id_group
        INNER JOIN t_sub sub ON sub.id_group = gs.id_group
        INNER JOIN t_pl_map plmap ON plmap.id_po = sub.id_po AND
                                     plmap.id_pi_instance = gsrm.id_prop
        INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_instance
        INNER JOIN t_payment_redirection payer ON 
          payer.id_payee = gsrm.id_acc AND
          /* checks all payer's who overlap with the group sub */
          payer.vt_end >= sub.vt_start AND
          payer.vt_start <= sub.vt_end     INNER JOIN t_acc_usage_cycle payercycle ON payercycle.id_acc = payer.id_payer
        WHERE 
          rc.tx_cycle_mode = 'EBCR' AND
          rc.b_charge_per_participant = 'N' AND
          /* checks only the requested group */
          payer.id_payer = p_id_acc AND
          plmap.id_paramtable IS NULL AND
          /* only consider receivers based on wall-clock transaction time */
          p_dt_now BETWEEN gsrm.tt_start AND gsrm.tt_end AND
          /* TODO: it would be better if we didn't consider subscriptions that ended */
          /*       in a hard closed interval so that retroactive changes would be properly guarded. */
          /* only consider current or future group subs */
          /* don't worry about group subs in the past */
          ((p_dt_now BETWEEN sub.vt_start AND sub.vt_end) OR
           (sub.vt_start > p_dt_now));
        IF v_count > 0 then
            RETURN -289472438;  /* MTPCUSER_CANNOT_CHANGE_BILLING_CYCLE_EBCR_PAYER_OF_RECEIVER */
        end if;
        
      RETURN 1; /* success, can update the billing cycle */
    END;

    FUNCTION ISINTERVALOPEN(
    aAccountID 	IN NUMBER  DEFAULT NULL,
    aIntervalID IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    aAccountID_ NUMBER(10,0) := aAccountID;
    aIntervalID_ NUMBER(10,0) := aIntervalID;
    retVal 	NUMBER(10,0);
    BEGIN
        BEGIN
            ISINTERVALOPEN.retval := 0;
            SELECT 
             CASE  
            WHEN (SELECT tx_status 
                  FROM t_acc_usage_interval ui  
                  WHERE id_acc = ISINTERVALOPEN.aAccountID_
                  AND id_usage_interval = ISINTERVALOPEN.aIntervalID_)
                  IN ('B','O') 
            THEN 1 
            ELSE 0  
            END tmpAlias1
			into retVal
             FROM DUAL;

			RETURN ISINTERVALOPEN.retVal;
        END;
    END ISINTERVALOPEN;

    FUNCTION LOOKUPACCOUNT(
    login 	IN VARCHAR2  DEFAULT NULL,
    namespace 	IN VARCHAR2  DEFAULT NULL)
    RETURN NUMBER
    AS
    login_ 	VARCHAR2(510) := login;
    namespace_ 	VARCHAR2(80) := namespace;
    retval 	NUMBER(10,0);
    BEGIN
        BEGIN
            SELECT   id_acc
			into retval
			FROM t_account_mapper  
			WHERE UPPER(nm_login) = UPPER(LOOKUPACCOUNT.login_)  
			AND UPPER(LOOKUPACCOUNT.namespace_) = upper(nm_space);

			IF  LOOKUPACCOUNT.retval is NULL THEN
                LOOKUPACCOUNT.retval := -1;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                LOOKUPACCOUNT.retval := -1;
        END;
        RETURN LOOKUPACCOUNT.retval;
    END LOOKUPACCOUNT;

    FUNCTION MTCOMPUTEEFFECTIVEENDDATE(
    type_ 	IN NUMBER  DEFAULT NULL,
    offset 	IN NUMBER  DEFAULT NULL,
    base 	IN DATE  DEFAULT NULL,
    sub_begin 	IN DATE  DEFAULT NULL,
    id_usage_cycle 	IN NUMBER  DEFAULT NULL)
    RETURN DATE
    AS
    type__ 	NUMBER(10,0) := type_;
    offset_ 	NUMBER(10,0) := offset;
    base_ 	DATE := base;
    sub_begin_ 	DATE := sub_begin;
    id_usage_cycle_ 	NUMBER(10,0) := id_usage_cycle;
    current_interval_end 	DATE;
    BEGIN
        BEGIN
            IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 1) THEN
            BEGIN
                RETURN MTCOMPUTEEFFECTIVEENDDATE.base_;
            END;
            ELSE
                IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 2) THEN
                BEGIN
                    /*[SPCONV-ERR(22)]:Manual conversion required MTEndOfDay()*/

                    RETURN MTEndOfDay(MTCOMPUTEEFFECTIVEENDDATE.sub_begin_ + MTCOMPUTEEFFECTIVEENDDATE.offset_);
                END;
                ELSE
                    IF  ( MTCOMPUTEEFFECTIVEENDDATE.type__ = 3) THEN
                    BEGIN
                        FOR rec IN ( SELECT   dt_end
                                                                 FROM t_pc_interval  
                                                                        WHERE MTCOMPUTEEFFECTIVEENDDATE.base_  BETWEEN 
                                                dt_start AND dt_end  
                                                                         and id_cycle = MTCOMPUTEEFFECTIVEENDDATE.id_usage_cycle_)
                        LOOP
                           current_interval_end := rec.dt_end ; 
                        
                        END LOOP;
                        RETURN MTCOMPUTEEFFECTIVEENDDATE.current_interval_end;
                    END;
                    END IF;
                    END IF;
                    END IF;
                RETURN NULL;
            END;
    END MTCOMPUTEEFFECTIVEENDDATE;

    FUNCTION WARNONEBCRMEMBERSTARTDATECHANG(
    id_sub 	IN NUMBER  DEFAULT NULL,
    id_acc 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
        id_sub_ 	NUMBER(10,0) := id_sub;
        id_acc_ 	NUMBER(10,0) := id_acc;
        StoO_selcnt	INTEGER;
        StoO_rowcnt	INTEGER;
        /* subscription ID */
        /* member account ID */
        /* 1 if a warning should be raised, 0 otherwise */
        /* checks to see if the subscription is associated with an EBCR RC */
        /* and that the EBCR cycle type and the subscriber's billing cycle */
        /* are such that the start date would be used in derivations */
    BEGIN
        BEGIN
            
            BEGIN
            StoO_selcnt := 0;
            StoO_rowcnt := 0;
            SELECT 1 INTO StoO_selcnt
            FROM DUAL
            WHERE  EXISTS ( 
                        SELECT  * 
                         FROM t_sub sub INNER JOIN t_group_sub gs 
                ON gs.id_group = sub.id_group INNER JOIN t_gsubmember gsm 
                ON gsm.id_group = gs.id_group INNER JOIN t_pl_map plmap 
                ON plmap.id_po = sub.id_po INNER JOIN t_recur rc 
                ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_payment_redirection 
                pay 
                ON pay.id_payee = gsm.id_acc AND pay.vt_end >= sub.vt_start 
                AND pay.vt_start <= sub.vt_end INNER JOIN t_acc_usage_cycle 
                auc 
                ON auc.id_acc = pay.id_payer INNER JOIN t_usage_cycle payercycle 
                ON payercycle.id_usage_cycle = auc.id_usage_cycle  
                    WHERE rc.tx_cycle_mode = 'EBCR'  
                     AND rc.b_charge_per_participant = 'Y'  
                     AND sub.id_sub = WARNONEBCRMEMBERSTARTDATECHANG.id_sub_  
                     AND gsm.id_acc = WARNONEBCRMEMBERSTARTDATECHANG.id_acc_  
                     AND plmap.id_paramtable IS NULL  
                     AND payercycle.id_cycle_type = 1  
                     AND rc.id_cycle_type  IN (7, 8)  );
            StoO_rowcnt := SQL%ROWCOUNT;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                WHEN OTHERS THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                    raise_application_error(SQLCODE, SQLERRM,true); 
            END;
            IF StoO_selcnt != 0 THEN

    /* checks all payer's who overlap with the group sub */
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
                RETURN 1;

            END IF;
    /* don't warn */
            RETURN 0;
        END;
    END WARNONEBCRMEMBERSTARTDATECHANG;

    FUNCTION WARNONEBCRSTARTDATECHANGE(
    id_sub 	IN NUMBER  DEFAULT NULL)
    RETURN NUMBER
    AS
    id_sub_ 	NUMBER(10,0) := id_sub;
    StoO_selcnt	INTEGER;
    StoO_rowcnt	INTEGER:=0;
    isGroup 	NUMBER(10,0);
    /* subscription ID */
    /* 1 if a warning should be raised, 0 otherwise */
    BEGIN
        BEGIN
            FOR rec IN ( SELECT  CASE  
            WHEN id_group IS NULL THEN 0 
            ELSE 1  
            END tmpAlias1
                                     FROM t_sub  
                                        WHERE id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_)
            LOOP
               isGroup := rec.tmpAlias1 ; 
               StoO_rowcnt := nvl(StoO_rowcnt,0)+1;
            END LOOP;
            IF  StoO_rowcnt = 0 THEN
    /* checks to see if the subscription is associated with an EBCR RC */
    /* and that the EBCR cycle type and the subscriber's billing cycle */
    /* are such that the start date would be used in derivations */
                RETURN -1;
            END IF;
            
            BEGIN
            StoO_selcnt := 0;
            StoO_rowcnt := 0;
            SELECT 1 INTO StoO_selcnt
            FROM DUAL
            WHERE  WARNONEBCRSTARTDATECHANGE.isGroup = 0 AND   EXISTS ( 
                        SELECT  * 
                             FROM t_sub sub INNER JOIN t_pl_map plmap 
                        ON plmap.id_po = sub.id_po INNER JOIN t_recur rc 
                        ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_acc_usage_cycle 
                auc 
                        ON auc.id_acc = sub.id_acc INNER JOIN t_usage_cycle payeecycle 
                        ON payeecycle.id_usage_cycle = auc.id_usage_cycle  
                            WHERE rc.tx_cycle_mode = 'EBCR'  
                             AND rc.b_charge_per_participant = 'N'  
                             AND sub.id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_  
                             AND plmap.id_paramtable IS NULL  
                             AND payeecycle.id_cycle_type = 1  
                             AND rc.id_cycle_type  IN (7, 8) 		 );
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                WHEN OTHERS THEN
                    StoO_rowcnt := 0;
                    StoO_selcnt := 0;
                    raise_application_error(SQLCODE, SQLERRM,true); 
            END;
            IF StoO_selcnt != 0 THEN
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
    /* checks to see if the group sub is associated with an EBCR RC */
    /* and that the EBCR cycle type and the receiver's payer's billing cycle */
    /* are such that the start date would be used in derivations */
                RETURN 1;
            ELSE
                BEGIN
                BEGIN
                StoO_selcnt := 0;
                StoO_rowcnt := 0;
                SELECT 1 INTO StoO_selcnt
                FROM DUAL
                WHERE  WARNONEBCRSTARTDATECHANGE.isGroup = 1 AND   EXISTS ( 
                            SELECT  NULL 
                                     FROM t_sub sub INNER JOIN t_gsub_recur_map gsrm 
                                ON gsrm.id_group = sub.id_group INNER JOIN t_pl_map plmap 
                                ON plmap.id_po = sub.id_po INNER JOIN t_recur rc 
                                ON rc.id_prop = plmap.id_pi_instance INNER JOIN t_payment_redirection 
                    pay 
                                ON pay.id_payee = gsrm.id_acc AND pay.vt_end >= sub.vt_start 
                    AND pay.vt_start <= sub.vt_end INNER JOIN t_acc_usage_cycle 
                    auc 
                                ON auc.id_acc = pay.id_payer INNER JOIN t_usage_cycle payercycle 
                                ON payercycle.id_usage_cycle = auc.id_usage_cycle  
                                    WHERE rc.tx_cycle_mode = 'EBCR'  
                                     AND rc.b_charge_per_participant = 'N'  
                                     AND sub.id_sub = WARNONEBCRSTARTDATECHANGE.id_sub_  
                                     AND plmap.id_paramtable IS NULL  
                                     AND payercycle.id_cycle_type = 1  
                                     AND rc.id_cycle_type  IN (7, 8) 			 );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        StoO_rowcnt := 0;
                        StoO_selcnt := 0;
                    WHEN OTHERS THEN
                        StoO_rowcnt := 0;
                        StoO_selcnt := 0;
                        raise_application_error(SQLCODE, SQLERRM,true); 
                END;
                IF StoO_selcnt != 0 THEN
    /* checks all payer's who overlap with the group sub */
    /* the subscriber is Monthly */
    /* and the EBCR cycle type is either Quarterly or Annually */
    /* warn the user! */
                    RETURN 1;
                END IF;
                END;
            END IF;
    /* don't warn */
            RETURN 0;
        END;
    END WARNONEBCRSTARTDATECHANGE;

FUNCTION GetCompatibleConcurrentEvents
RETURN retCompatibleEvent_table
AS
v_result  retCompatibleEvent_table;
BEGIN

SELECT retCompatibleEvent(tx_compatible_eventname)
BULK COLLECT INTO v_result
FROM
(  
     /* All internal events */
    select distinct evt.tx_name tx_compatible_eventname from t_recevent evt
    where evt.tx_type = 'Root'
    union
    ( /* All unique event names when there are no running adapters (no conflicts) */
    select distinct evt.tx_name  tx_compatible_eventname from t_recevent evt
    where evt.tx_type not in ('Checkpoint','Root')
        /* Intentionally not checking against active events to make sure we don't
        skip any older events that do not have rules or have been deactivated but still have instances */
        and ((select COUNT(*) from t_recevent_run evt_run2 WHERE tx_status = 'InProgress') = 0)
    )
    union
    (
      /* List of events compatible with currently running events */
	    select tx_compatible_eventname
	    from (
		      SELECT
				    evt2.tx_name
		      FROM t_recevent_run evt_run
		      INNER JOIN t_recevent_inst evt_inst2 ON evt_inst2.id_instance = evt_run.id_instance
		      INNER JOIN t_recevent evt2 ON evt2.id_event = evt_inst2.id_event
		      WHERE evt_run.tx_status = 'InProgress'
		      GROUP BY evt2.tx_name, evt2.id_event
	    ) r inner join t_recevent_concurrent c on r.tx_name = c.tx_eventname
	    group by tx_compatible_eventname
	    having COUNT(*) = (select COUNT(*) 
					       from (select id_run 
							     from t_recevent_run evt_run 
							     where evt_run.tx_status = 'InProgress' 
							     group by id_run) d
					      )
    )
); 


RETURN v_result;
END GetCompatibleConcurrentEvents;

          FUNCTION GetEventExecutionDeps(
            p_dt_now date, 
            p_id_instances VARCHAR2
            )
          RETURN int 
          is
            deps int;
          BEGIN
          
            /* builds up a table from the comma separated list of instance IDs
                if the list is null, then add all ReadyToRun instances
              */

            IF (p_id_instances IS NOT NULL) then
              INSERT INTO tmp_args
              SELECT column_value FROM table(dbo.csvtoint(p_id_instances));
            else
              INSERT INTO tmp_args 
              SELECT id_instance FROM t_recevent_inst
              WHERE tx_status = 'ReadyToRun';
            END if;
          
            /* inserts all active 'ReadyToRun' instances or the instance ID's passed in
              */
          
            INSERT INTO tmp_instances
            SELECT
              evt.id_event,
              evt.tx_type,
              evt.tx_name,
              inst.id_instance,
              inst.id_arg_interval,
              inst.id_arg_billgroup,
              inst.id_arg_root_billgroup,
              /* in the case of EOP then, use the interval's start date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
              /* in the case of EOP then, use the interval's end date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
            FROM t_recevent_inst inst
            INNER JOIN tmp_args args ON args.id_instance = inst.id_instance
            INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
            LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
            WHERE /* vent is active */
                  evt.dt_activated <= p_dt_now 
              AND (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated);
          
            /* inserts EOP to EOP dependencies for interval-only adapters
              */
            INSERT INTO tmp_deps
            SELECT
              inst.id_event,
              origevent.tx_billgroup_support,
              inst.id_instance,
              inst.id_arg_billgroup,
              inst.tx_name,
              depevt.tx_name,
              depevt.id_event,
              depevt.tx_billgroup_support,
              depinst.id_instance,
              depinst.id_arg_billgroup,
              depinst.id_arg_interval,
              NULL,
              NULL,
              CASE WHEN inst.id_instance = depinst.id_instance 
                THEN /* treats the identity dependency as successful */
                    'Succeeded'
                ELSE depinst.tx_status END,
              'Y' /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep 
                ON dep.id_event = inst.id_event
            INNER JOIN t_recevent depevt 
                ON depevt.id_event = dep.id_dependent_on_event
            INNER JOIN t_recevent_inst depinst 
                ON depinst.id_event = depevt.id_event 
                AND depinst.id_arg_interval = inst.id_arg_interval
            INNER JOIN t_recevent origevent
                ON origevent.id_event = inst.id_event
            WHERE /* dep event is active */
                  depevt.dt_activated <= p_dt_now 
              AND (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) 
              AND /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') 
              AND /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')  
             AND /* the original instance's event is 'Interval' */
                origevent.tx_billgroup_support = 'Interval';
          
             /* Inserts EOP to EOP dependencies for billing group-only and account-only adapters. 
                For a given adapter instance, the depends-on instance could
                be and interval-only instance, a billing-group-only instance or an account-only instance.
              */
            
            INSERT INTO tmp_deps
            SELECT
              inst.id_event,
              origevent.tx_billgroup_support,
              inst.id_instance,
              inst.id_arg_billgroup,
              inst.tx_name,
              depevt.tx_name,
              depevt.id_event,
              depevt.tx_billgroup_support,
              depinst.id_instance,
              depinst.id_arg_billgroup,
              depinst.id_arg_interval,
              NULL,
              NULL,
              CASE WHEN inst.id_instance = depinst.id_instance THEN
                /* treats the identity dependency as successful */
                'Succeeded'
              ELSE depinst.tx_status END,
              'Y'  /* b_critical_dependency */
            FROM tmp_instances inst
             INNER JOIN t_recevent origEvt
                ON origEvt.id_event = inst.id_event
            INNER JOIN t_recevent_dep dep 
                ON dep.id_event = inst.id_event
            INNER JOIN t_recevent depevt 
                ON depevt.id_event = dep.id_dependent_on_event
            INNER JOIN t_recevent_inst depinst 
                ON depinst.id_event = depevt.id_event AND
                    (
                           /* when the original event or dependent event is Interval then make sure
                              that the original instance and the dependent instance have the same interval
                            */
                         (
                             (
                                 origEvt.tx_billgroup_support = 'Interval' OR 
                                 depEvt.tx_billgroup_support = 'Interval'
                             )
                             AND 
                             (
                                 depinst.id_arg_interval = inst.id_arg_interval
                             )
                         )
                         OR
                         /* when the original event is BillingGroup */
                         (
                             (
                                origEvt.tx_billgroup_support = 'BillingGroup' 
                             )
                             AND 
                             (
                                 /* and dependent event is either BillingGroup or Account then make sure
                                    that the original instance and the dependent instance have the same root billgroup
                                    (depevt.tx_billgroup_support IN ('BillingGroup', 'Account') AND
                                    */
                                    depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                             )
                         )
                          /* when the original event is Account */
                         OR     
                         (
                             (
                                 origEvt.tx_billgroup_support = 'Account' 
                             )
                             AND 
                             (
                                (
                                      /* and dependent event is Account then make sure
                                        that the original instance and the dependent instance have the same billgroup 
                                      */
                                      depevt.tx_billgroup_support = 'Account' AND
                                      depinst.id_arg_billgroup = inst.id_arg_billgroup
                                )
                             
                                OR
                                     /* and dependent event is BillingGroup then make sure
                                        that the original instance and the dependent instance 
                                        have the same root billgroup 
                                      */
                                (
                                    depevt.tx_billgroup_support = 'BillingGroup' AND
                                    depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
                                )
                             )  /* closes that AND dangling up there */
                         ) /*  closes that OR dangling up there - no not that OR, the other OR */
                )         
            INNER JOIN t_recevent origevent
                ON origevent.id_event = inst.id_event
            WHERE
              /* dep event is active */ 
              depevt.dt_activated <= p_dt_now AND
              (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
              /* the original instance's event is root, EOP or a checkpoint event */
              inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
              /* the dependency instance's event is an EOP or Checkpoint event */
              depevt.tx_type IN ('EndOfPeriod', 'Checkpoint')  AND
              /* the original instance's event is 'BillingGroup' */
              origevent.tx_billgroup_support IN ('BillingGroup', 'Account');
               
          /* 
            It is possible for adapters instances which belong to pull lists to have dependencies 
            on 'BillingGroup' type adapters which exist at the parent billing group level and not at the pull list level.
            If the parent billing group is 'Open' then these BillingGroup adapter instances don't even exist in t_recvent_inst.
          
            Hence, create dummy BillingGroup type adapter instances (in a tmp table) for the parent billing groups (if necessary)
            Use the tmp table to generate dependencies specifically for BillingGroup type adapters.
          */
          
            /* select those parent billing groups which don't have any entries in t_recevent_inst */
            INSERT INTO tmp_billgroup(id_billgroup)
            SELECT id_arg_root_billgroup 
            FROM t_recevent_inst ri1
            WHERE NOT EXISTS (SELECT 1 
                              FROM t_recevent_inst ri2 
                              WHERE ri1.id_arg_root_billgroup = ri2.id_arg_billgroup) 
                  AND id_arg_root_billgroup IS NOT NULL                                
            GROUP BY id_arg_root_billgroup;
            
            /* create fake instance rows only for 'BillingGroup' type adapters */
            INSERT INTO  tmp_recevent_inst (
              id_event,
              id_arg_interval,
              id_arg_billgroup,
              id_arg_root_billgroup)
            SELECT evt.id_event id_event,
               bg.id_usage_interval id_arg_interval,
               tbg.id_billgroup,
               tbg.id_billgroup
            FROM tmp_billgroup tbg
              INNER JOIN t_billgroup bg ON bg.id_billgroup = tbg.id_billgroup 
              INNER JOIN t_usage_interval ui ON ui.id_interval = bg.id_usage_interval
              INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle
              INNER JOIN t_recevent_eop sch ON 
                           /* the schedule is not constrained in any way */
                           ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR
                           /* the schedule's cycle type is constrained */
                           (sch.id_cycle_type = uc.id_cycle_type) OR
                           /* the schedule's cycle is constrained */
                           (sch.id_cycle = uc.id_usage_cycle))
                INNER JOIN t_recevent evt ON evt.id_event = sch.id_event
            WHERE 
                  /* event must be active */
                  evt.dt_activated <= p_dt_now AND
                  (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                  /* event must be of type: end-of-period */
                  (evt.tx_type in ('EndOfPeriod')) AND
                  evt.tx_billgroup_support = 'BillingGroup';
            
             INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                origevent.tx_billgroup_support,
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                -1,
                depinst.id_arg_billgroup,
                depinst.id_arg_interval,
                NULL,
                NULL,
                'NotCreated',
                'Y'  /* b_critical_dependency */
              FROM tmp_instances inst
               INNER JOIN t_recevent origEvt
                  ON origEvt.id_event = inst.id_event
              INNER JOIN t_recevent_dep dep 
                  ON dep.id_event = inst.id_event
              INNER JOIN t_recevent depevt 
                  ON depevt.id_event = dep.id_dependent_on_event
              INNER JOIN tmp_recevent_inst depinst 
                  ON depinst.id_event = depevt.id_event AND
                         /* when the original event is Account */
                         origEvt.tx_billgroup_support = 'Account' AND 
                         /* and dependent event is BillingGroup then make sure
                            that the original instance and the dependent instance have the same root billgroup 
                            */
                         depevt.tx_billgroup_support = 'BillingGroup' AND
                         depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup
              INNER JOIN t_recevent origevent
                  ON origevent.id_event = inst.id_event
              WHERE
                /* dep event is active */
                depevt.dt_activated <= p_dt_now AND
                (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                /* the original instance's event is EOP event */
                inst.tx_type IN ('EndOfPeriod') AND
                /* the dependency instance's event is an EOP event */
                depevt.tx_type IN ('EndOfPeriod')  AND
                /* the original instance's event is 'Account' */
                origevent.tx_billgroup_support IN ('Account');
            
            /* SELECT * FROM deps  */
            
            /* inserts EOP cross-interval dependencies */
          
              INSERT INTO tmp_deps
              SELECT 
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                NULL, /* tx_billgroup_support */
                depinst.id_instance,
                depinst.id_arg_billgroup,
                ui.id_interval,
                NULL,
                NULL,
                nvl(depinst.tx_status, 'Missing'),
                'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN t_usage_interval ui ON ui.dt_end < inst.dt_arg_end 
              CROSS JOIN 
              (
                /* returns the event dependencies of the end root event
                  this event depends on all EOP events */
                SELECT
                  depevt.id_event,
                  depevt.tx_name
                FROM t_recevent evt
                INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
                INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
                WHERE
                  evt.tx_name = '_EndRoot' AND
                  /* end root event is active */
                  evt.dt_activated <= p_dt_now AND
                  (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                  /* dep event is active */
                  depevt.dt_activated <= p_dt_now AND
                  (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                  /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 
              ) depevt
              LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                depinst.id_arg_interval = ui.id_interval
              WHERE
                /* the original instance's event is root, EOP or a checkpoint event */
                inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                /* don't consider hard closed intervals */
                ui.tx_interval_status <> 'H';
            
              /* inserts scheduled dependencies (including complete missing instances)
                */
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                depinst.id_instance,
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                nvl(depinst.dt_arg_start, inst.dt_arg_start),
                nvl(depinst.dt_arg_end, inst.dt_arg_end),
                CASE WHEN inst.id_instance = depinst.id_instance THEN
                  /* treats the identity dependency as successful */
                  'Succeeded'
                ELSE
                  nvl(depinst.tx_status, 'Missing')
                END,
                 'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN t_recevent_dep dep ON dep.id_event = inst.id_event
              INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
              LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                /* enforce that the instance's dependency's start arg and end arg
                   at least partially overlap with the original instance's start and end arguments
                  */
                depinst.dt_arg_start <= inst.dt_arg_end AND
                depinst.dt_arg_end >= inst.dt_arg_start
              WHERE
                /* dep event is active */
                depevt.dt_activated <= p_dt_now AND
                (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                depevt.tx_type = 'Scheduled';
            
            /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
            
             /* inserts partially missing scheduled dependency instances (start to min)
                covers the original instance's start date to the minimum start date
                of all scheduled instances of an event
                */
          
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                missingdeps.tx_name,
                missingdeps.id_event,
                NULL, /* tx_billgroup_support */
                NULL, /* id_instance  */
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                inst.dt_arg_start,
                dbo.SubtractSecond(missingdeps.dt_min_arg_start),
                'Missing', /* tx_status,  */
                 'N'  /* b_critical_dependency  */
              FROM tmp_instances inst
              INNER JOIN
              (
                /* gets the minimum arg start date per scheduled event */
                SELECT
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name,
                  MIN(deps.dt_arg_start) dt_min_arg_start
                FROM tmp_deps deps
                INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
                WHERE
                  evt.tx_type = 'Scheduled' AND
                  deps.tx_status <> 'Missing'
                GROUP BY
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name
              ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
              WHERE
                /*  only adds a missing instance if the minimum start date is too late */
                missingdeps.dt_min_arg_start > inst.dt_arg_start ;
            
            
            /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
            
              /* inserts partially missing scheduled dependency instances (max to end)
                covers the maximum end date of all scheduled instances of an event to the
                original instance's end date
                */
              INSERT INTO tmp_deps
              SELECT
                inst.id_event,
                NULL, /* original tx_billgroup_support */
                inst.id_instance,
                NULL, /* id_arg_billgroup */
                inst.tx_name,
                missingdeps.tx_name,
                missingdeps.id_event,
                NULL, /* tx_billgroup_support */
                NULL, /* id_instance, */
                NULL, /* id_arg_billgroup */
                NULL, /* id_arg_interval */
                dbo.AddSecond(missingdeps.dt_max_arg_end),
                inst.dt_arg_end,
                'Missing', /* tx_status, */
                 'N'  /* b_critical_dependency */
              FROM tmp_instances inst
              INNER JOIN
              (
                /* gets the maximum arg end date per scheduled event */
                SELECT
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name,
                  MAX(deps.dt_arg_end) dt_max_arg_end
                FROM tmp_deps deps
                INNER JOIN t_recevent evt ON evt.id_event = deps.id_event
                WHERE
                  evt.tx_type = 'Scheduled' AND
                  deps.tx_status <> 'Missing'
                GROUP BY
                  deps.id_orig_instance,
                  deps.id_event,
                  deps.tx_name
              ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance
              WHERE
                /* only adds a missing instance if the maximum end date is too early */
                missingdeps.dt_max_arg_end < inst.dt_arg_end;
            
              /* SELECT * FROM deps ORDER BY tx_orig_name ASC */
          
/*
select deps_rec(
            id_orig_event,
            tx_orig_billgroup_support,
            id_orig_instance,
            id_orig_billgroup,
            tx_orig_name,
            tx_name,
            id_event,
            tx_billgroup_support,
            id_instance,
            id_billgroup,
            id_arg_interval,
            dt_arg_start,
            dt_arg_end,
            tx_status,
            b_critical_dependency)
          BULK COLLECT INTO deps from tmp_deps;
*/

		 SELECT COUNT(*) INTO deps FROM tmp_deps;

		  RETURN deps;
          
          END GetEventExecutionDeps;

          function geteventreversaldeps(
            p_dt_now date,   
            p_id_instances varchar2) 
          return int as
            deps int;
          begin
          
            /* builds up a table from the comma separated list of instance IDs */
            /* if the list is null, then add all ReadyToReverse instances */
          
            if p_id_instances is not null then
              insert into tmp_args
              select column_value from table(dbo.csvtoint(p_id_instances));
            else
              insert into tmp_args
              select id_instance from t_recevent_inst
              where tx_status = 'ReadyToReverse';
            end if;
          
            /* inserts all active instances found in @args
              */
            INSERT INTO tmp_instances
            SELECT
              evt.id_event,
              evt.tx_type,
              evt.tx_name,
              inst.id_instance,
              inst.id_arg_interval,
              inst.id_arg_billgroup,
              inst.id_arg_root_billgroup,
              /* in the case of EOP then, use the interval's start date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,
              /* in the case of EOP then, use the interval's end date */
              CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END
            FROM t_recevent_inst inst
            INNER JOIN tmp_args args ON args.id_instance = inst.id_instance
            INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
            LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval
            WHERE /* event is active */
                  evt.dt_activated <= p_dt_now 
              AND (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated);
          
            /* inserts EOP to EOP dependencies for interval-only adapters
              */
          INSERT INTO tmp_deps
          SELECT
                  inst.id_event,
                  origevent.tx_billgroup_support,
                  inst.id_instance,
                  inst.id_arg_billgroup,
                  inst.tx_name,
                  depevt.tx_name,
                  depevt.id_event,
                  depevt.tx_billgroup_support,
                  depinst.id_instance,
                  depinst.id_arg_billgroup,
                  depinst.id_arg_interval,
                  NULL,
                  NULL,
                  CASE WHEN inst.id_instance = depinst.id_instance THEN
                         /* treats the identity dependency as NotYetRun */
                          'NotYetRun'
                  ELSE
                          depinst.tx_status
                  END,
                   'Y'   /* b_critical_dependency */
          FROM tmp_instances inst
          INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
          INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
          INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event 
            AND depinst.id_arg_interval = inst.id_arg_interval
          INNER JOIN t_recevent origevent ON origevent.id_event = inst.id_event
          WHERE
                  /* dep event is active */
                  depevt.dt_activated <= p_dt_now AND
                  (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                  /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                  /* the dependency instance's event is an EOP or Checkpoint event */
                  depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
                  /* the original instance's event is 'Interval' */
                  origevent.tx_billgroup_support = 'Interval';
          
            /* SELECT * FROM @deps ORDER BY tx_orig_name ASC */
           /* 
              Inserts EOP to EOP dependencies for billing group-only and account-only adapters. 
              For a given adapter instance, the depends-on instance could
              be and interval-only instance, a billing-group-only instance or an account-only instance.
            */
          
            INSERT INTO tmp_deps
            SELECT
                inst.id_event,
                origevent.tx_billgroup_support,
                inst.id_instance,
                inst.id_arg_billgroup,
                inst.tx_name,
                depevt.tx_name,
                depevt.id_event,
                depevt.tx_billgroup_support,
                depinst.id_instance,
                depinst.id_arg_billgroup,
                depinst.id_arg_interval,
                NULL,
                NULL,
                CASE WHEN inst.id_instance = depinst.id_instance THEN
                        /* treats the identity dependency as NotYetRun */
                        'NotYetRun'
                ELSE
                        depinst.tx_status
                END,
                 'Y'  /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
            INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
            INNER JOIN t_recevent_inst depinst 
              ON depinst.id_event = depevt.id_event 
              AND (
                     /* if the depends-on instance is an interval-only instance */
                     (depinst.id_arg_interval = inst.id_arg_interval AND depevt.tx_billgroup_support = 'Interval') 
                     OR
                     /* if the depends-on instance is an account-only instance */
                    (depinst.id_arg_billgroup = inst.id_arg_billgroup AND depevt.tx_billgroup_support = 'Account')
                     OR
                    /* if the depends-on instance is a billing-group-only instance */
                    (depinst.id_arg_root_billgroup = inst.id_arg_root_billgroup AND depevt.tx_billgroup_support = 'BillingGroup')
                  )
            
            INNER JOIN t_recevent origevent ON origevent.id_event = inst.id_event
            WHERE
                    /* dep event is active */
                    depevt.dt_activated <= p_dt_now AND
                    (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                    /* the original instance's event is root, EOP or a checkpoint event */
                    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND
                    /* the dependency instance's event is an EOP or Checkpoint event */
                    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') AND
                    /* the original instance's event is 'BillingGroup' */
                    origevent.tx_billgroup_support IN ('BillingGroup', 'Account');
          
            /* inserts EOP cross-interval dependencies (every instance in future intervals)
              */
            INSERT INTO tmp_deps
            SELECT 
                    inst.id_event,
                    NULL, /* original tx_billgroup_support */
                    inst.id_instance,
                    inst.id_arg_billgroup,
                    inst.tx_name,
                    depevt.tx_name,
                    depevt.id_event,
                    NULL, /* tx_billgroup_support */
                    depinst.id_instance,
                    depinst.id_arg_billgroup,
                    ui.id_interval,
                    NULL,
                    NULL,
                    depinst.tx_status,
                    'N' /* b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_usage_interval ui ON ui.dt_end > inst.dt_arg_end
            CROSS JOIN (
                    /* returns the event dependencies of the end root event
                       this event depends on all EOP events */
                    SELECT
                            depevt.id_event,
                            depevt.tx_name
                    FROM t_recevent evt
                    INNER JOIN t_recevent_dep dep ON dep.id_event = evt.id_event
                    INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event
                    WHERE
                            evt.tx_name = '_EndRoot' AND
                            /* end root event is active */
                            evt.dt_activated <= p_dt_now AND
                            (evt.dt_deactivated IS NULL OR p_dt_now < evt.dt_deactivated) AND
                            /*  dep event is active */
                            depevt.dt_activated <= p_dt_now AND
                            (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                            /* the dependency instance's event is an EOP or Checkpoint event */
                            depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 
            ) depevt
            INNER JOIN t_recevent_inst depinst 
              ON depinst.id_event = depevt.id_event 
              AND depinst.id_arg_interval = ui.id_interval
            WHERE /* the original instance's event is root, EOP or a checkpoint event */
                  inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint');
          
          
            /* inserts scheduled dependencies
            */
          
            insert INTO tmp_deps
            SELECT
                  inst.id_event,
                  NULL, /* original tx_billgroup_support */
                  inst.id_instance,
                  NULL, /* id_arg_billgroup */
                  inst.tx_name,
                  depevt.tx_name,
                  depevt.id_event,
                  depevt.tx_billgroup_support,
                  depinst.id_instance,
                  NULL, /* id_arg_billgroup */
                  NULL, /* id_arg_interval */
                  nvl(depinst.dt_arg_start, inst.dt_arg_start),
                  nvl(depinst.dt_arg_end, inst.dt_arg_end),
                  CASE WHEN inst.id_instance = depinst.id_instance THEN
                          /* treats the identity dependency as NotYetRun */
                          'NotYetRun'
                  ELSE
                          depinst.tx_status
                  END,
                  'N'  /*  b_critical_dependency */
            FROM tmp_instances inst
            INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event
            INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event
            INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND
                    /* enforce that the instance's dependency's start arg and end arg
                      at least partially overlap with the original instance's start and end arguments */
                    depinst.dt_arg_start <= inst.dt_arg_end AND
                    depinst.dt_arg_end >= inst.dt_arg_start
            WHERE
                    /* dep event is active */
                    depevt.dt_activated <= p_dt_now AND
                    (depevt.dt_deactivated IS NULL OR p_dt_now < depevt.dt_deactivated) AND
                    depevt.tx_type = 'Scheduled';
          
            /* SELECT * FROM @deps ORDER BY tx_orig_name ASC */
/*
				select deps_rec(
                id_orig_event,
                tx_orig_billgroup_support,
                id_orig_instance,
                id_orig_billgroup,
                tx_orig_name,
                tx_name,
                id_event,
                tx_billgroup_support,
                id_instance,
                id_billgroup,
                id_arg_interval,
                dt_arg_start,
                dt_arg_end,
                tx_status,
                b_critical_dependency)
              BULK COLLECT INTO deps from tmp_deps;
*/

			SELECT COUNT(*) INTO deps FROM tmp_deps;

            return deps;
          
          end geteventreversaldeps;

function to_base( p_dec in number, p_base in number ) 
return varchar2
is
	l_str	varchar2(255) default NULL;
	l_num	number	default p_dec;
	l_hex	varchar2(16) default '0123456789ABCDEF';
begin
	if ( trunc(p_dec) <> p_dec OR p_dec < 0 ) then
		raise PROGRAM_ERROR;
	end if;
	loop
		l_str := substr( l_hex, mod(l_num,p_base)+1, 1 ) || l_str;
		l_num := trunc( l_num/p_base );
		exit when ( l_num = 0 );
	end loop;
	if (p_base = 2) then
		l_str := lpad(l_str,64,'0');
	end if;
	return l_str;
end to_base;

function twos_complement( in_bin_string varchar2)
return varchar2
is
bin_str char(64) := lpad(trim(in_bin_string),64,0);
str_length pls_integer := length(bin_str);
i pls_integer := 0;
begin
	/* find two's complement */
	dbms_output.put_line('init = ' || bin_str);
	/* reverse all bits */
	bin_str := replace(bin_str,'0','2');
	bin_str := replace(bin_str,'1','0');
	bin_str := replace(bin_str,'2','1');
	/*done, now add 1 to lsb */
	dbms_output.put_line( 'reverse = ' || bin_str);
	
	for i in reverse 0..64
	loop
  	    /* dbms_output.put_line( 'pos = ' || to_char(i) || 'value is ' || trim(substr(bin_str,i,1))); */
		if to_number(trim(substr(bin_str,i,1))) = 0 then
		   		   
			bin_str := substr(bin_str,1,i-1) || '1' || substr(bin_str,i+1); 
			exit when true;
		else
			bin_str := substr(bin_str,1,i-1) || '0' || substr(bin_str,i+1);
		end if;
	end loop;

	dbms_output.put_line( 'final = ' || bin_str);	
	return bin_str;
end twos_complement;

function to_dec( p_str in varchar2,  p_from_base in number default 16 ) return number
is
	l_num   number default 0;
	l_hex   varchar2(16) default '0123456789ABCDEF';
begin
	for i in 1 .. length(p_str) loop
		l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
	end loop;
	return l_num;
end to_dec;



FUNCTION MTHEXFORMAT(  value  IN NUMBER  DEFAULT NULL)  
RETURN VARCHAR2  AS  
ret_str varchar2(16);
bin_str varchar2(64);
BEGIN   
	if (value < 0 ) then
		bin_str := dbo.twos_complement(dbo.to_base(abs(value),2));
	else
		bin_str := dbo.to_base(abs(value),2);
	end if;
	/* data is required to convert to 4 bytes , how ever can be expanded upto 8 bytes */
	ret_str := lower(lpad(dbo.to_base(dbo.to_dec(substr(bin_str,33,16),2),16),4,'0') || lpad(dbo.to_base(dbo.to_dec(substr(bin_str,49,16),2),16),4,0));
	dbms_output.put_line(ret_str);
	return ret_str;
end mthexformat; 

function GetBillingGroupAncestor(
  p_id_current_billgroup int) 
return int 
as 
  parent_bg int := null;
  cur_bg int := p_id_current_billgroup;
begin

  loop
  
    select id_parent_billgroup into parent_bg
    from t_billgroup
    where id_billgroup = cur_bg;
  
    if (parent_bg is null) then
      exit;
    end if;

    cur_bg := parent_bg;

  end loop;
  
  return cur_bg;

end GetBillingGroupAncestor;

function GetBillingGroupDescendants(p_id_billgroup_current int) 
return billgroupdesc_results_tab 
as 
  results billgroupdesc_results_tab;
begin

  select billgroupdesc_results_rec(id_billgroup)
  bulk collect into results
  from t_billgroup 
  where id_parent_billgroup is not null
  start with id_billgroup = p_id_billgroup_current
  connect by prior id_billgroup = id_parent_billgroup
  ;

  return results;

end GetBillingGroupDescendants;

function getexpiredintervals(
  p_dt_now date,    
  p_not_materialized int
  ) return id_table
  
as
  retIntervals id_table;

begin

  SELECT id_rec(ui.id_interval)
  bulk collect into retIntervals
  FROM t_usage_interval ui
  INNER JOIN t_usage_cycle uc 
     ON uc.id_usage_cycle = ui.id_usage_cycle
  INNER JOIN t_usage_cycle_type uct 
     ON uct.id_cycle_type = uc.id_cycle_type
  WHERE
    /* if the not_materialized flag is '1' 
       then
          return only those intervals which have not been materialized
       else 
          the materialization status of the interval does not matter
    */
    CASE WHEN p_not_materialized = 1
             THEN (SELECT COUNT(id_materialization) 
                        FROM t_billgroup_materialization 
                        WHERE id_usage_interval = ui.id_interval)
             ELSE 0
             END = 0 
    AND
    CASE WHEN uct.n_grace_period IS NOT NULL 
      THEN ui.dt_end + uct.n_grace_period /* take into account the cycle type's grace period */
      ELSE p_dt_now /* the grace period has been disabled, so don't close this interval */
      END < p_dt_now;

    RETURN retIntervals;

end getexpiredintervals;

			function GetAllDescendentAccountTypes(
				parent varchar2
				) return retDescendents_table
as
retDescendents_tmp retDescendents_table;
begin
SELECT retDescendents(t_account_type.name) bulk collect into retDescendents_tmp
from t_account_type
where id_type in
(
select distinct id_descendent_type from t_acctype_descendenttype_map
start with id_type = (select id_type from t_account_type where upper(name) = upper(parent))
connect by nocycle prior id_descendent_type = id_type 
);
    RETURN retDescendents_tmp;

end GetAllDescendentAccountTypes;

    function IsSystemPartitioned 
      return int
    as
    begin
    
      for x in (select b_partitioning_enabled 
                from t_usage_server 
                where upper(b_partitioning_enabled) = 'Y'
                ) loop
        return 1;
      end loop;
      
      return 0;
    
    end IsSystemPartitioned;


    function GetUsageIntervalID (
      p_dt_end timestamp,
      p_id_cycle int)
    return int
    as
    begin
      
      return extract(day from
              p_dt_end - to_timestamp('1970-01-01', 'yyyy-mm-dd')) 
          * power(2,16) + p_id_cycle;

    end GetUsageIntervalID;

    function DaysFromPartitionEpoch(
      dt timestamp) 
    return int as
    begin
      return extract(day from dt - to_timestamp('1970-01-01', 'yyyy-mm-dd'));
    end DaysFromPartitionEpoch;

   function maxpartitionbound 
   return number as 
   begin 
    return 9999999999; 
   end;

  FUNCTION GenGuid
  RETURN RAW AS
    v_uid RAW(16);
  BEGIN
    v_uid := sys_guid();
    RETURN v_uid;
  END;

END;