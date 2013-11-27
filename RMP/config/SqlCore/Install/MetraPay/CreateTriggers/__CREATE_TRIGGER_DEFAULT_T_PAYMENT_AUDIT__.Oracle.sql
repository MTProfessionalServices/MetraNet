
            create or replace trigger insert_t_payment_audit before insert on t_payment_audit
                referencing new as new old as old
                for each row
                begin
                if :new.dt_occurred is null
                then
              :new.dt_occurred :=to_date(getutcdate(),'YYYY-MM-DD HH24:MI:SS');
               end if;
               end;
	