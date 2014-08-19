
CREATE OR REPLACE 
PROCEDURE bulksubscriptionchange (
				id_old_po          INT,
				id_new_po          INT,
				temp_date          DATE,
				nextbillingcycle   VARCHAR2,
				p_systemdate       DATE,
				p_new_sub					 INT,
				p_status out			 INT
				)
				AS
				CURSOR cursorvar IS
				SELECT id_acc, t_sub.vt_start, t_sub.vt_end, id_sub
        FROM t_sub
				WHERE t_sub.id_po = id_old_po AND t_sub.vt_end >= temp_date
				/* only deal with individual subscriptions */
				AND id_group is NULL;
				temp_id_acc            INT;
				start_date               DATE;
				end_date               DATE;
				temp_id_sub            INT;
				varmaxdatetime         DATE;
        subext                 raw(16);
        realenddate            date;
	 	    v_datemodified       VARCHAR2(1);
	 	    new_sub									int;
  tmp int;
  a int;

				BEGIN
        p_status := 1;
				new_sub := p_new_sub;
					varmaxdatetime := dbo.mtmaxdate ();
					OPEN cursorvar;
					LOOP
					FETCH cursorvar INTO temp_id_acc, start_date, end_date, temp_id_sub;
					EXIT WHEN cursorvar%NOTFOUND;


  select case when nextbillingcycle = 'Y' AND temp_date is not null then
		dbo.subtractsecond(dbo.NextDateAfterBillingCycle(temp_id_acc,temp_date))
	else
		dbo.subtractsecond(temp_date)
	end	into realenddate from dual;

  /* it is possible that temp_date <= end_date <= realenddate. */
  /* for this case treat as though subscription doesn't match at all */
  if end_date > realenddate then
	  /* either delete or update the old subscription */
    if realenddate >= start_date then
	    UPDATE t_sub SET vt_end = realenddate WHERE
	    id_sub = temp_id_sub;

	    /* update the old subscription tt_end */
	    UPDATE t_sub_history
      SET tt_end = dbo.subtractsecond (p_systemdate)
	    WHERE id_sub = temp_id_sub
	    AND tt_end =varmaxdatetime;

	    /* insert the new record*/
	    INSERT INTO t_sub_history
      SELECT id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group,
             vt_start, realenddate, p_systemdate, varmaxdatetime, TX_QUOTING_BATCH
      FROM t_sub_history
       WHERE id_sub = temp_id_sub
         AND tt_end = dbo.subtractsecond (p_systemdate);
    else
      DELETE FROM t_sub WHERE id_sub = temp_id_sub;

	    UPDATE t_sub_history
      SET tt_end = dbo.subtractsecond (p_systemdate)
	    WHERE id_sub = temp_id_sub
	    AND tt_end =varmaxdatetime;
    end if;

  tmp := new_sub;
  -- set @tmp = @tmp + (@tmp * 4096);
  tmp := tmp +(tmp * 4096);
  -- set @tmp = @tmp AND 0x7fffffff;
  tmp := bitand(tmp, 2147483647);
  -- set @tmp = @tmp ^ (@tmp / 4194304);
  a := FLOOR(tmp / 4194304);
  tmp := (tmp + a) - BITAND(tmp, a) * 2;
  -- set @tmp = @tmp + (@tmp * 16);
  tmp := tmp + (tmp * 16);
  --    set @tmp = @tmp AND 0x7fffffff;
  tmp := bitand(tmp, 2147483647);
  -- set @tmp = @tmp ^ (@tmp / 512);
  a := FLOOR(tmp / 512);
  tmp := (tmp + a) - BITAND(tmp, a) * 2;
  -- set @tmp = @tmp + (@tmp * 1024);
  tmp := tmp + (tmp * 1024);
  -- set @tmp = @tmp AND 0x7fffffff;
  tmp := bitand(tmp, 2147483647);
  -- set @tmp = @tmp ^ (@tmp / 4);
  a := FLOOR(tmp / 4);
  tmp := (tmp + a) - BITAND(tmp, a) * 2;
  -- set @tmp = @tmp + (@tmp * 128);
  tmp := tmp + (tmp * 128);
  -- set @tmp = @tmp AND 0x7fffffff;
  tmp := bitand(tmp, 2147483647);
  -- set @tmp = @tmp ^ (@tmp / 4096);
  a := FLOOR(tmp / 4096);
  tmp := (tmp + a) - BITAND(tmp, a) * 2;

    addnewsub (temp_id_acc,temp_date,end_date,nextbillingcycle,/* next billing cycle after start date */
		  'N',id_new_po,SYS_GUID (),p_systemdate,tmp,p_status,v_datemodified);
    if p_status <> 1 then
      raise_application_error(-20001, 'Unexpected error creating a subscription: error ' || p_status);
    end if;
	  /* CR 12529 - increment the id */
	  new_sub := new_sub + 1;
  end if;
  END LOOP;
  CLOSE cursorvar;
END;
					