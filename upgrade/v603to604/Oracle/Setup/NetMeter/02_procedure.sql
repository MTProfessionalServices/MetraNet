Create Or Replace Procedure WorkflowInsertInstanceState
          ( p_id_instance nvarchar2,
          p_state blob,
          p_n_status number,
          p_n_unlocked number,
          p_n_blocked number,
          p_tx_info nclob,
          p_id_owner nvarchar2,
          p_dt_ownedUntil date,
          p_dt_nextTimer date,
          p_result OUT number,
          p_currentOwnerID OUT nvarchar2
) 
AS
              p_InsertInstanceState_Failed nvarchar2(256);
              p_now date;
              p_cnt number; 
Begin
              p_result := 0;
              p_cnt := 0;
               
              p_InsertInstanceState_Failed := 'Instance ownership conflict';
              p_currentOwnerID := p_id_owner;
              p_now := to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss');

              /* SET TRANSACTION ISOLATION LEVEL READ COMMITTED; */
 
              IF p_n_status=1 OR p_n_status=3 then
                BEGIN            
	               DELETE FROM t_wf_InstanceState WHERE id_instance=p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));
	               IF (sql%rowcount  = 0 ) then 
	                   begin
		                    
                      BEGIN
    		                select id_owner  INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                      END;
                      
		                  if ( p_currentOwnerID IS NOT NULL ) THEN
		                      begin	
                           /* gkc 9/27/07 leave out the RAISERERROR
                            cannot delete the instance state because of an ownership conflict
			                     RAISEERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1)	*/			
			                     p_result := -2;
			                     Return;
		                      end;
		                  end if;
	                   end;
	               else
	                   BEGIN
		                  DELETE FROM t_wf_CompletedScope WHERE id_instance=p_id_instance;
	                   end;
	               end if; 
                END;
                         
              ELSE 
                BEGIN                                
                    /* if not exists ( Select 1 from t_wf_InstanceState Where id_instance = p_id_instance ) then
                     gkc 9/27/07 when p_cnt = 0, is equivalent to NOT EXISTS (SELECT 1) in sql server */
                  BEGIN
                    Select 1 into p_cnt from t_wf_InstanceState Where id_instance = p_id_instance;                    
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN p_cnt := 0;
                  END;
                    
                   If p_cnt = 0 then 
		              BEGIN
			            /* Insert Operation */
			            IF p_n_unlocked = 0 then
			             begin
			               Insert INTO t_wf_InstanceState 
							(ID_INSTANCE,STATE,N_STATUS,N_UNLOCKED,N_BLOCKED,TX_INFO,DT_MODIFIED,ID_OWNER,DT_OWNEDUNTIL,DT_NEXTTIMER)
			               Values(p_id_instance,p_state,p_n_status,p_n_unlocked,p_n_blocked,p_tx_info,p_now,p_id_owner,p_dt_ownedUntil,p_dt_nextTimer);
			             end;
			            else
			             begin
			               Insert INTO t_wf_InstanceState 
							(ID_INSTANCE,STATE,N_STATUS,N_UNLOCKED,N_BLOCKED,TX_INFO,DT_MODIFIED,ID_OWNER,DT_OWNEDUNTIL,DT_NEXTTIMER)
			               Values(p_id_instance,p_state,p_n_status,p_n_unlocked,p_n_blocked,p_tx_info,p_now,p_id_owner,p_dt_ownedUntil,p_dt_nextTimer);
			             end;
			            END IF;
		              END; 
                    ELSE
                        BEGIN 
				     	IF p_n_unlocked = 0 then 
				            begin
					          Update t_wf_InstanceState  
					          Set state = p_state,
						          n_status = p_n_status,
						          n_unlocked = p_n_unlocked,
						          n_blocked = p_n_blocked,
						          tx_info = p_tx_info,
						          dt_modified = p_now,
						          dt_ownedUntil = p_dt_ownedUntil,
						          dt_nextTimer = p_dt_nextTimer
					          Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));
					          if (sql%rowcount = 0) then
					           BEGIN
							  /* gkc 9/27/07 leave out the RAISERERROR
						           RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                      BEGIN
						            select id_owner INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                      END;
						          p_result := -2;
						          return;
					           END;
					          end if;
				            end;
				          else
				            	begin
					          		Update t_wf_InstanceState  
					          			Set state = p_state,
						          		n_status = p_n_status,
						          		n_unlocked = p_n_unlocked,
						          		n_blocked = p_n_blocked,
						          		tx_info = p_tx_info,
						          		dt_modified = p_now,
						          		id_owner = NULL,
						          		dt_ownedUntil = NULL,
						          		dt_nextTimer = p_dt_nextTimer
					          		Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=p_now) OR (id_owner IS NULL AND p_id_owner IS NULL ));                          			
									if ( sql%rowcount = 0) then 
					          			BEGIN
					          			    /* gkc 9/27/07 leave out the RAISERERROR
						          		     RAISERROR(p_local_str_InsertInstanceState_Failed_Ownership, 16, -1) */
                            BEGIN
						          			  select id_owner INTO p_currentOwnerID from t_wf_InstanceState Where id_instance = p_id_instance;
                            EXCEPTION
                              WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                            END;
						          			p_result := -2;
						          			return;
					          			END;
					          			end if;									
      					        end;
                          end if;    
				        END;                           
                     end if;        				
                /* gkc 9/27/07 goes with outer begin */ 
                END;
              END IF;
          /* gkc 9/27/07 what about exception handling ?? */ 
          Return; 
END WorkflowInsertInstanceState;
/

              Create Or Replace Procedure WorkflowUnlockInstanceState
              (p_id_instance IN nvarchar2,
               p_id_owner nvarchar2)
            As
            BEGIN
                
                Update t_wf_InstanceState  
                Set 	id_owner = NULL,
                      dt_ownedUntil = NULL
                Where id_instance = p_id_instance AND ((id_owner = p_id_owner AND dt_ownedUntil>=to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')) OR (id_owner IS NULL AND p_id_owner IS NULL )); 
            END WorkflowUnlockInstanceState;              
/

              Create or Replace Procedure WorkflowRetrieveInstanceState
              (p_id_instance nvarchar2,
               p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_result out number ,
               p_currentOwnerID out nvarchar2,
               p_state out sys_refcursor)
               As
                p_Failed_Ownership nvarchar2(256);

                Begin
                  
                p_Failed_Ownership := 'Instance ownership conflict';
                p_result := 0;
                p_currentOwnerID := p_id_owner;
                
                /* Possible workflow n_status: 0 for executing; 1 for completed; 2 for suspended; 3 for terminated; 4 for invalid */

                if p_id_owner IS NOT NULL then	/* if id is null then just loading readonly state, so ignore the ownership check */
                    begin
                        Update t_wf_InstanceState  
                          set	id_owner = p_id_owner,
                          dt_ownedUntil = p_dt_ownedUntil
                        where id_instance = p_id_instance 
                        AND (id_owner = p_id_owner 
                         OR id_owner IS NULL 
                         OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'));
						
                        if (Sql%ROWCOUNT = 0 ) then
                          BEGIN
                            BEGIN
                              select id_owner INTO p_currentOwnerID 
                                from t_wf_InstanceState 
                              Where id_instance = p_id_instance;
                            EXCEPTION
                              WHEN NO_DATA_FOUND THEN p_currentOwnerId := NULL;
                            END;  
						  
                            if (sql%ROWCOUNT = 0) then
                                p_result := -1;
                            else
                                p_result := -2;
                            end if;
                            GOTO DONE;
                          END;									                	
                        end if; 
                    end;
                end if; 
    
                open p_state for      	
                Select state from t_wf_InstanceState Where id_instance = p_id_instance;              
                p_result := sql%ROWCOUNT;

                if (p_result = 0) then 
                  begin
                    p_result := -1;
                    GOTO DONE;
                  end;
                end if; 
          	
            <<DONE>> 

	/*        COMMIT TRANSACTION */

            RETURN;
            END WorkflowRetrieveInstanceState;
/

              CREATE OR REPLACE PROCEDURE WFRetNonblockInstanceStateIds
              (p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_now date,
              p_result out sys_refcursor
              )
              AS
              BEGIN
              OPEN p_result FOR               
              /* gkc 9/27/07 added for update nowait to lock the rows */
              SELECT id_instance FROM t_wf_InstanceState /* WITH (TABLOCK,UPDLOCK,HOLDLOCK) */
               WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2  /* not n_blocked and not completed and not terminated and not suspended */
                 AND ( id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'))
                 FOR update
                 NOWAIT;
		 		
              if (SQL%ROWCOUNT > 0) THEN 
                  BEGIN
                  /* lock the table entries that are returned */
                    Update t_wf_InstanceState  
                        set id_owner = p_id_owner,
                            dt_ownedUntil = p_dt_ownedUntil
                    WHERE n_blocked=0 AND n_status<>1 AND n_status<>3 AND n_status<>2
                      AND ( id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') );              	
                  END;
              END IF;
                       
            END WFRetNonblockInstanceStateIds;                             
/

            CREATE OR REPLACE PROCEDURE WFRetNonblockInstanceStateId
            (p_id_owner nvarchar2,
            p_dt_ownedUntil date,
            p_id_instance OUT nvarchar2,
            p_found OUT number
            ) 
            AS
            BEGIN
                  /* Guarantee that no one else grabs this record between the select and update
                  SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
                   accept the default transaction isolation level of "Read Committed" 

                   Begin TRANASCTION    
                   gkc 9/27/07 get lock on ONE row... */
                  BEGIN
                    SELECT	id_instance into p_id_instance
                      FROM	t_wf_InstanceState
                      WHERE	n_blocked=0 
                        AND	n_status NOT IN ( 1,2,3 )
                        AND	(id_owner IS NULL OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'))
                        AND rownum <=1
                        FOR update
                        NOWAIT;
                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN p_id_instance := NULL;
                  END;

                  /* what is going to release this lock?  */
                  IF p_id_instance IS NOT NULL then
                    BEGIN
                      UPDATE  t_wf_InstanceState  
                      SET	id_owner = p_id_owner,
                        dt_ownedUntil = p_dt_ownedUntil
                        WHERE	id_instance = p_id_instance;
			        
                      p_found := 1;
                    END;
                  ELSE
                    BEGIN
                      p_found := 0;
                    END;
                  END IF; 
        
                /*  gkc 9/27/07 ???? question do we want the commit to occur; 
                 COMMIT; */		
                END WFRetNonblockInstanceStateId;
/


              CREATE OR REPLACE PROCEDURE WFRetrieveExpiredTimerIds
              (p_id_owner nvarchar2,
               p_dt_ownedUntil date,
               p_now date,
               p_result out sys_refcursor) 
               AS
               Begin
               /* gkc 9/27/07 allow return of multiple "id_instance" by adding a "sys_refcursor" parameter */
               open p_result for 
               SELECT id_instance FROM t_wf_InstanceState
                  WHERE dt_nextTimer<p_now AND n_status<>1 AND n_status<>3 AND n_status<>2 /* not n_blocked and not completed and not terminated and not suspended */
                      AND ((n_unlocked=1 AND id_owner IS NULL) OR dt_ownedUntil<to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss') );
                END WFRetrieveExpiredTimerIds;
/


        CREATE OR REPLACE PROCEDURE WorkflowInsertCompletedScope
        (p_id_instance nvarchar2,
        p_id_completedScope nvarchar2,
        p_state blob)
        As
        BEGIN

            /* gkc 9/27/07 if entry exists update else insert */
            MERGE INTO t_wf_CompletedScope twc 
            USING t_wf_CompletedScope twc1
            ON (twc1.id_completedScope=p_id_completedScope)
            When Matched then 
              Update
                SET twc.state = p_state,
                    twc.dt_modified = to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss')
            WHEN NOT MATCHED THEN 
                INSERT (twc.ID_INSTANCE,twc.ID_COMPLETEDSCOPE,twc.STATE,twc.DT_MODIFIED)
                VALUES(p_id_instance, p_id_completedScope, p_state, to_date(to_char(sys_extract_utc(systimestamp),'dd/mm/yyyy hh24:mi:ss'), 'dd/mm/yyyy hh24:mi:ss'));   
        END WorkflowInsertCompletedScope;
/

CREATE or replace PROCEDURE MTSP_INSERTINVOICE
    (p_id_billgroup int,
    p_invoicenumber_storedproc varchar2, /* this is the name of the stored procedure used to generate invoice numbers */
    p_is_sample varchar2,
    p_dt_now DATE,  /* the MetraTech system's date */
    p_id_run int,
    p_num_invoices OUT int ,
    p_return_code OUT int)
AS
    v_invoice_date date := trunc(p_dt_now);
    v_cnt int;
    v_id_interval_exist int;
    v_id_billgroup_exist int;
    v_debug_flag number(1) := 1 ; -- yes
    v_ErrMsg varchar(200);
    type v_cur is ref cursor;
    v_cur1   v_cur;
    v_tmp_invoicenumber tmp_invoicenumber%ROWTYPE;
    FatalError exception ;
    SkipReturn exception ;
BEGIN

    -- Initialization
    p_num_invoices := 0;

    -- Validate input parameter values
    IF p_id_billgroup IS NULL
    THEN
      v_ErrMsg := 'InsertInvoice: Completed abnormally, id_billgroup is null';
      raise FatalError;
    END IF;
    if p_invoicenumber_storedproc IS NULL OR RTRIM(p_invoicenumber_storedproc) = ''
    then
      v_ErrMsg := 'InsertInvoice: Completed abnormally, invoicenumber_storedproc is null';
      raise FatalError;
    END if;
    IF v_debug_flag = 1 then

      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
        VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Started', dbo.getutcdate);
    end if;

    -- If already exists, do not process again
    begin
        v_id_billgroup_exist := null;
        for i in (SELECT id_billgroup FROM t_invoice_range
        WHERE id_billgroup = p_id_billgroup and id_run is NULL)
        loop
            v_id_billgroup_exist := i.id_billgroup;
            exit;
        end loop;
        if v_id_billgroup_exist is not null then
            v_ErrMsg := 'InsertInvoice: Invoice number already exists in the t_invoice_range table, '
                      ||'process skipped, process completed successfully at '
                      || to_char(SYS_EXTRACT_UTC(SYSTIMESTAMP),'mon dd yyyy hh:mi:ss:ff PM');
            raise SkipReturn;
        end if;
    exception
    when SkipReturn then
        raise SkipReturn;
    when others then
        raise FatalError;
    END;

    begin
    v_id_interval_exist := NULL;
    for i in (SELECT id_interval FROM t_invoice inv
							INNER JOIN t_billgroup_member bgm
							ON bgm.id_acc = inv.id_acc
						INNER JOIN t_billgroup bg
							ON bg.id_usage_interval = inv.id_interval AND
								bg.id_billgroup = bgm.id_billgroup
						WHERE bgm.id_billgroup = p_id_billgroup and
												inv.sample_flag = 'N')
    loop
        v_id_interval_exist := i.id_interval;
        exit;
    end loop;
    IF v_id_interval_exist IS NOT NULL
    then
      v_ErrMsg := 'InsertInvoice: Invoice number already exists in the t_invoice table, '
                  ||'process skipped, process completed successfully at '
                  ||to_char(SYSTIMESTAMP,'mon dd yyyy hh:mi:ss:ff PM');
      raise SkipReturn;
    END IF;
    exception
    when SkipReturn then
        raise SkipReturn;
    when others then
        raise FatalError;
    end;

    /* call MTSP_INSERTINVOICE_BALANCES to populate tmp_acc_amounts, tmp_prev_balance, tmp_adjustments */
    MTSP_INSERTINVOICE_BALANCES (p_id_billgroup, 0, p_id_run, p_return_code);
    if p_return_code <> 0 then
        raise FatalError;
    end if;

    begin
      execute immediate 'begin '||p_invoicenumber_storedproc||'(:var1,:var2); end;' using v_invoice_date, in out v_cur1;
      loop
         fetch v_cur1 into v_tmp_invoicenumber;
         exit when v_cur1%NOTFOUND;
         INSERT INTO tmp_invoicenumber (id_acc,namespace,invoice_string,invoice_due_date,id_invoice_num)
         values (v_tmp_invoicenumber.id_acc,v_tmp_invoicenumber.namespace,v_tmp_invoicenumber.invoice_string,
                 v_tmp_invoicenumber.invoice_due_date,v_tmp_invoicenumber.id_invoice_num);
      end loop;
    exception
      when others then
      raise FatalError;
    end;

    IF v_debug_flag = 1 then
      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
      VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Begin Insert into t_invoice', dbo.getutcdate);
    end if;

    -- Save all the invoice data to the t_invoice table
    begin
    INSERT INTO t_invoice
      (id_invoice,
      namespace,
      invoice_string,
      id_interval,
      id_acc,
      invoice_amount,
      invoice_date,
      invoice_due_date,
      id_invoice_num,
      invoice_currency,
      payment_ttl_amt,
      postbill_adj_ttl_amt,
      ar_adj_ttl_amt,
      tax_ttl_amt,
      current_balance,
      id_payer,
      id_payer_interval,
      sample_flag,
      balance_forward_date)
    SELECT
	  seq_t_invoice.nextval,
      tmp_acc_amounts.namespace,
      tmpin.invoice_string, -- from the stored proc as below
		  ui.id_interval, /*@id_interval,*/
      tmp_acc_amounts.id_acc,
      current_charges
        + nvl(tmp_adjustments.PrebillAdjAmt,0)
        + tax_ttl_amt
        + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0),  -- invoice_amount = current_charges + prebill adjustments + taxes + prebill tax adjustments,
      v_invoice_date invoice_date,
      tmpin.invoice_due_date, -- from the stored proc as @invoice_date+@invoice_due_date_offset   invoice_due_date,
      tmpin.id_invoice_num, -- from the stored proc as tmp_seq + @invoice_number - 1,
      invoice_currency,
      payment_ttl_amt, -- payment_ttl_amt
     nvl(tmp_adjustments.PostbillAdjAmt, 0.0) + nvl(tmp_adjustments.PostbillTaxAdjAmt, 0.0), -- postbill_adj_ttl_amt
      ar_adj_ttl_amt, -- ar_adj_ttl_amt
      tax_ttl_amt + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0), -- tax_ttl_amt
      current_charges + tax_ttl_amt + ar_adj_ttl_amt
          + nvl(tmp_adjustments.PostbillAdjAmt, 0.0)
        + nvl(tmp_adjustments.PostbillTaxAdjAmt,0.0)
        + payment_ttl_amt
          + nvl(tmp_prev_balance.previous_balance, 0.0)
        + nvl(tmp_adjustments.PrebillAdjAmt, 0.0)
        + nvl(tmp_adjustments.PrebillTaxAdjAmt,0.0), -- current_balance
      id_payer, -- id_payer
      CASE WHEN tmp_acc_amounts.id_payer_interval IS NULL THEN
      (SELECT id_usage_interval FROM t_billgroup WHERE id_billgroup = p_id_billgroup)
      ELSE tmp_acc_amounts.id_payer_interval END, -- id_payer_interval
      p_is_sample sample_flag,
      ui.dt_end -- balance_forward_date
    FROM tmp_acc_amounts
    INNER JOIN tmp_invoicenumber tmpin ON tmpin.id_acc = tmp_acc_amounts.id_acc
    LEFT OUTER JOIN tmp_prev_balance ON tmp_prev_balance.id_acc = tmp_acc_amounts.id_acc
    LEFT OUTER JOIN tmp_adjustments ON tmp_adjustments.id_acc = tmp_acc_amounts.id_acc
    INNER JOIN t_usage_interval ui ON ui.id_interval IN (SELECT id_usage_interval
			                                               FROM t_billgroup
			                                               WHERE id_billgroup = p_id_billgroup)/*= @id_interval*/
    INNER JOIN t_av_internal avi ON avi.id_acc = tmp_acc_amounts.id_acc;

    p_num_invoices := SQL%ROWCOUNT;
    exception
    when others then
      raise FatalError;
    end;

    -- Store the invoice range data to the t_invoice_range table
    begin
    SELECT MAX(tmp_seq) into v_cnt
    FROM tmp_acc_amounts;
    exception
    when others then
      raise FatalError;
    end;

    IF v_cnt IS NOT NULL then
    BEGIN
      --insert info about the current run into the t_invoice_range table
      INSERT INTO t_invoice_range (id_interval,id_billgroup, namespace, id_invoice_num_first, id_invoice_num_last)
      SELECT i.id_interval, bm.id_billgroup, i.namespace, nvl(min(id_invoice_num),0), nvl(max(id_invoice_num),0)
      FROM t_invoice i
        INNER JOIN t_billgroup_member bm ON bm.id_acc = i.id_acc
        INNER JOIN t_billgroup b ON b.id_billgroup = bm.id_billgroup 
                                AND i.id_interval = b.id_usage_interval
      WHERE bm.id_billgroup = p_id_billgroup
      GROUP by i.id_interval, bm.id_billgroup, i.namespace;

      --update the id_invoice_num_last in the t_invoice_namespace table
      UPDATE t_invoice_namespace
      SET t_invoice_namespace.id_invoice_num_last =
        (SELECT nvl(max(t_invoice.id_invoice_num),t_invoice_namespace.id_invoice_num_last)
        FROM t_invoice
        WHERE t_invoice_namespace.namespace = t_invoice.namespace AND
				t_invoice.id_interval IN (SELECT id_usage_interval
			              FROM t_billgroup
			              WHERE id_billgroup = p_id_billgroup));
	exception
	when others then
      raise FatalError;
    END;
    ELSE
      v_cnt := 0;
    end if;

    IF v_debug_flag = 1 then
      INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
       VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', 'InsertInvoice: Completed successfully', dbo.getutcdate);
    end if;
    p_return_code := 0;
    RETURN;

exception
when SkipReturn then
      IF v_ErrMsg IS NULL then
        v_ErrMsg := 'InsertInvoice: Process skipped';
      end if;
      IF v_debug_flag = 1  then
        INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
                    VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
      end if;
      p_return_code := 0;
      RETURN;

-- others will catch anything else including fatalexceptions 
when Others then
      IF v_ErrMsg IS NULL then
        v_ErrMsg := 'InsertInvoice: Adapter stored procedure failed';
      end if;
      IF v_debug_flag = 1 then
        INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
          VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', v_ErrMsg, dbo.getutcdate);
      END IF;
      p_return_code := -1;
      RETURN;

END;
/

CREATE OR REPLACE PROCEDURE updatebatchstatus (
   tx_batch           IN   RAW,
   tx_batch_encoded   IN   VARCHAR2,
   n_completed        IN   INT,
   sysdate_           IN   DATE
)
AS
   tx_batch_           RAW (255)      := tx_batch;
   tx_batch_encoded_   VARCHAR2 (24)  := tx_batch_encoded;
   n_completed_        NUMBER (10, 0) := n_completed;
   sysdate__           DATE           := sysdate_;
   stoo_selcnt         INTEGER;
   initialstatus       CHAR (1);
   finalstatus         CHAR (1);
BEGIN
      stoo_selcnt := 0;

      SELECT count(1)
        INTO stoo_selcnt
                    FROM t_batch
                   WHERE tx_batch =
                                           hextoraw(updatebatchstatus.tx_batch_)
                                           ;
   IF stoo_selcnt = 0
   THEN
      INSERT INTO t_batch
                  (id_batch, tx_namespace,
                   tx_name,
                   tx_batch,
                   tx_batch_encoded, tx_status, n_completed, n_failed,
                   dt_first, dt_crt
                  )
           VALUES (seq_t_batch.NEXTVAL, 'pipeline',
                   updatebatchstatus.tx_batch_encoded_,
                   updatebatchstatus.tx_batch_,
                   updatebatchstatus.tx_batch_encoded_, 'A', 0, 0,
                   updatebatchstatus.sysdate__, updatebatchstatus.sysdate__
                  );
   END IF;

   SELECT tx_status into initialstatus
                 FROM t_batch
                WHERE tx_batch= hextoraw(updatebatchstatus.tx_batch_)
                for update;

   UPDATE t_batch
      SET t_batch.n_completed =
                          t_batch.n_completed + updatebatchstatus.n_completed_,
          t_batch.tx_status =
             CASE
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) = t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) = t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'C'
                WHEN (   (  t_batch.n_completed
                          + t_batch.n_failed
                          + nvl(t_batch.n_dismissed, 0)
                          + updatebatchstatus.n_completed_
                         ) < t_batch.n_expected
                      OR (    ((  t_batch.n_completed
                                + t_batch.n_failed
                                + nvl(t_batch.n_dismissed, 0)
                                + updatebatchstatus.n_completed_
                               ) < t_batch.n_metered
                              )
                          AND t_batch.n_expected = 0
                         )
                     )
                   THEN 'A'
                WHEN ((  t_batch.n_completed
                       + t_batch.n_failed
                       + nvl(t_batch.n_dismissed, 0)
                       + updatebatchstatus.n_completed_
                      ) > t_batch.n_expected
                     )
                AND t_batch.n_expected > 0
                   THEN 'F'
                ELSE t_batch.tx_status
             END,
          t_batch.dt_last = updatebatchstatus.sysdate__,
          t_batch.dt_first =
             CASE
                WHEN t_batch.n_completed = 0
                   THEN updatebatchstatus.sysdate__
                ELSE t_batch.dt_first
             END
    WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);

   SELECT tx_status into finalstatus
                 FROM t_batch
                WHERE tx_batch = hextoraw(updatebatchstatus.tx_batch_);
END updatebatchstatus;
/

        create or replace procedure mtsp_BackoutInvoices (
            p_id_billgroup int,
            p_id_run int,
            p_num_invoices OUT int ,
            p_info_string OUT nvarchar2,
            p_return_code OUT int
        )
        as
            v_count number:=0;
            p_debug_flag number(1) := 1;
            p_msg nvarchar2(256) := 'Invoice-Backout: Invoice adapter reversed';
            p_usage_cycle_type int;

        begin

            /* SET p_debug_flag = 0 */
            p_info_string := NULL;
            for i in (select id_usage_cycle from t_usage_interval
               							 where id_interval  IN (SELECT id_usage_interval
						                                               FROM t_billgroup
						                                               WHERE id_billgroup = p_id_billgroup))
            loop
                p_usage_cycle_type := i.id_usage_cycle ;
            end loop;

            for i in (select t_invoice.id_invoice from t_invoice left outer join t_usage_interval
                on t_invoice.id_interval = t_usage_interval.id_interval
                where id_usage_cycle = p_usage_cycle_type
 					and t_invoice.id_interval > (SELECT id_usage_interval
						                                FROM t_billgroup
						                                WHERE id_billgroup = p_id_billgroup))
            loop
                v_count := v_count + 1;
            end loop;
            if (v_count > 0) then
                p_info_string := 'Reversing the invoice adapter for this interval has caused the invoices for subsequent intervals to be invalid';
            end if;

            /* truncate the table so that all rows corresponding to this interval are removed */
						DELETE FROM t_invoice
						WHERE id_acc IN (SELECT bgm.id_acc
						    FROM t_billgroup_member bgm
						    WHERE bgm.id_billgroup = p_id_billgroup) AND
	            	id_interval IN (SELECT id_usage_interval
			                                FROM t_billgroup
			                                WHERE id_billgroup = p_id_billgroup);
            p_num_invoices := v_count;
            /* update the t_invoice_range table's id_run field */
                UPDATE t_invoice_range
                    SET id_run = p_id_run 
		WHERE id_billgroup = p_id_billgroup
		  AND id_run IS NULL;
                IF p_debug_flag = 1 then
                    INSERT INTO t_recevent_run_details (id_detail, id_run, tx_type, tx_detail, dt_crt)
                      VALUES (seq_t_recevent_run_details.nextval, p_id_run, 'Debug', p_msg, dbo.getutcdate);
                end if;

                p_return_code := 0;

        end;
/

call RecompileMetraTech();

exit;