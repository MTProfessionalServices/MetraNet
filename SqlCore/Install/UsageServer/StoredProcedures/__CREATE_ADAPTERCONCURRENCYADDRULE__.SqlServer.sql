
		CREATE PROCEDURE AdapterConcurrencyAddRule           
   @eventname NVARCHAR(4000),              
   @compatibleeventname NVARCHAR(4000),
   @status INT OUTPUT
  AS              
BEGIN              
  
declare @eventid int
declare @compatibleeventid int

/* Look up the valid event id */   
set @eventid = (select max(id_event) from t_recevent re where re.tx_name like @eventname);
IF (@eventid is null)
  BEGIN
  SET @status = -1; /*Unknown event name*/
  RETURN
  END
IF (@compatibleeventname = 'ALL')
   BEGIN
   insert into t_recevent_concurrent (tx_eventname, tx_compatible_eventname)
	 (select @eventname, re.tx_name  from t_recevent re
	 --left join t_recevent_concurrent recon on re.tx_name = recon.tx_compatible_eventname
	 where re.dt_deactivated is null
	 and re.tx_type not in ('Checkpoint', 'Root')
	 and (select COUNT(*) from t_recevent_concurrent where tx_eventname=@eventname and tx_compatible_eventname = re.tx_name)=0  /* Where no rule is already specified */
	 )
   END
ELSE
   BEGIN
   set @compatibleeventid = (select max(id_event) from t_recevent re where re.tx_name like @compatibleeventname);
   IF (@compatibleeventid is null)
	  BEGIN
	  SET @status = -2; /*Unknown compatible event name*/
	  RETURN
	  END
   ELSE
     insert into t_recevent_concurrent (tx_eventname, tx_compatible_eventname)
                 values(@eventname, @compatibleeventname)
   END
   
   --select * from t_recevent re where re.tx_name like @eventname
   --select * from t_recevent_concurrent
   
   
   --delete from t_recevent_concurrent
set @status = 0;
END
  