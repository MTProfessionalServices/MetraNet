CREATE OR REPLACE PROCEDURE AdapterConcurrencyAddRule           
( 
 p_eventname IN NVARCHAR2,              
 p_compatibleeventname IN NVARCHAR2,
 p_status OUT number
)
IS

v_eventid number(10);
v_compatibleeventid number(10);

BEGIN

/* Look up the valid event id */   
select max(id_event) into v_eventid from t_recevent re where re.tx_name like p_eventname;
IF (v_eventid is null) THEN
  p_status := -1; /*Unknown event name*/
  RETURN;
  END IF;
IF (p_compatibleeventname = 'ALL') THEN
   
   insert into t_recevent_concurrent (tx_eventname, tx_compatible_eventname)
     (select p_eventname, re.tx_name  from t_recevent re
     where re.dt_deactivated is null
     and re.tx_type not in ('Checkpoint', 'Root')
     and (select COUNT(*) from t_recevent_concurrent where tx_eventname=p_eventname and tx_compatible_eventname = re.tx_name)=0  /* Where no rule is already specified */
     );

ELSE
  /* v_compatibleeventid := (select max(id_event) from t_recevent re where re.tx_name like p_compatibleeventname);*/
  select max(id_event) into v_compatibleeventid from t_recevent re where re.tx_name like p_compatibleeventname;
   IF v_compatibleeventid is null THEN
      p_status := -2; /*Unknown compatible event name*/
      RETURN;

   ELSE
     insert into t_recevent_concurrent (tx_eventname, tx_compatible_eventname)
                 values(p_eventname, p_compatibleeventname);
   END IF;
END IF;

 p_status := 0;
END;
