create or replace PROCEDURE CreateAnalyticsDataMartDB(
v_dt_now date, 
v_id_run integer)
IS
 l_count INTEGER;
l_exists number(1);
BEGIN
     select case
               when exists(select 1 from user_tablespaces where tablespace_name = UPPER('AnalyticsDataMart'))
               then 1
               else 0
            end into l_exists
            from dual;

if (v_id_run is not null) then
       INSERT INTO t_recevent_run_details (id_run, dt_crt, tx_type, tx_detail) VALUES (v_id_run, v_dt_now, 'Debug', 'Starting Analytics DataMart');
end if;
if l_exists=0 
then
       if v_id_run is not null then
         INSERT INTO t_recevent_run_details (id_run, dt_crt, tx_type, tx_detail) VALUES (v_id_run, v_dt_now, 'Info', 'Creating database for AnalyticsDataMart');
         EXECUTE IMMEDIATE 'CREATE TABLESPACE AnalyticsDataMart DATAFILE ''analyticsdatamart.dbf'' SIZE 50M EXTENT MANAGEMENT LOCAL AUTOALLOCATE';
       end if;
end if;


if (v_id_run is not null) then
       INSERT INTO t_recevent_run_details (id_run, dt_crt, tx_type, tx_detail) VALUES (v_id_run, v_dt_now, 'Info', 'Finished creating empty Analytics DataMart');
end if;

end;