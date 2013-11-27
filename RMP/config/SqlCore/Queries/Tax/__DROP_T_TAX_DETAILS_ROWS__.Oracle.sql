
       begin
         if table_exists('t_tax_details') then
           loop
             delete from t_tax_details
             where id_tax_run=%%RUN_ID%%
             and rownum < 5000;
             if SQL%ROWCOUNT <= 0 then
               exit;
             end if;
             commit;
           end loop;
         end if;
        end;