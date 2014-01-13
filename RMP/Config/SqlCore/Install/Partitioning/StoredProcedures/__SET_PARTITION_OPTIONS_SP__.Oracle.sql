
      create or replace
      procedure SetPartitionOptions(
        p_enable varchar,
        p_type varchar2,
        p_datasize int,
        p_logsize int)
      as
        idcycle int := null;
        cycletype varchar2(300);
        cnt int;
        tax_details_enum_id int := 0;
        
        prodid int;
        enumid int;
        ukid int;
        pvid int;
        
      begin
        dbms_output.put_line('Invoked SetPartitionOptions().');

        /* validate enable flag */
        if lower(p_enable) not in ('y', 'n') then
          raise_application_error(-20000, 'Enable flag must be "Y" or "N", not ' || p_enable);
        end if;

        /* find cycle id for a supported partition cycle */
        for x in (
              select uc.id_usage_cycle, uct.tx_desc
              from  t_usage_cycle uc
              join t_usage_cycle_type uct
                      on uct.id_cycle_type = uc.id_cycle_type
              where lower(uct.tx_desc) = lower(p_type)
                      and ((uc.id_cycle_type = 1 /* monthly */
                              and day_of_month = 31)
                          or (uc.id_cycle_type = 4 /* weekly */
                              and day_of_week = 1)
                          or (uc.id_cycle_type = 6  /* semi-montly */
                              and first_day_of_month = 14 
                              and second_day_of_month = 31)
                          or (uc.id_cycle_type = 7  /* quarterly */
                              and start_day = 1 and start_month = 1))
              )
        loop
          idcycle := x.id_usage_cycle;
          cycletype := x.tx_desc;
        end loop;
        dbms_output.put_line('idcycle=' || to_char(idcycle));

        if (idcycle is null) then
          raise_application_error(-20000, 'Partition type '|| p_type ||' not supported.');
        end if;

        /* Update t_usage_server */
        update t_usage_server set
          b_partitioning_enabled = upper(p_enable),
          partition_cycle = idcycle,
          partition_type = cycletype,
          partition_data_size = p_datasize,
          partition_log_size = p_logsize;
        
        /* Treat t_acc_usage kinda like a product view */
        select count(1) into cnt from dual
          where exists (select * from t_prod_view 
                        where lower(nm_table_name) = 't_acc_usage');

        if cnt < 1 then

          /* get the enum id for the acc_usage_table */
          select id_enum_data into enumid
          from t_enum_data
          where lower(nm_enum_data) = 'usage';

          select seq_t_prod_view.nextval into prodid from dual;
          
          insert into t_prod_view 
            (id_prod_view, id_view, dt_modified, nm_name, nm_table_name,b_can_resubmit_from)
          values 
            (prodid, enumid, sysdate, 'metratech.com/acc_usage', 't_acc_usage', 'N');

          /* add acc_usage columns to t_prod_view_prop */
          insert into t_prod_view_prop( 
                  id_prod_view_prop,
                  id_prod_view, nm_name, nm_data_type, nm_column_name, 
                  b_required, b_composite_idx, b_single_idx, b_part_of_key, b_exportable, 
                  b_filterable, b_user_visible, nm_default_value, n_prop_type, nm_space, 
                  nm_enum, b_core) 
          select  seq_t_prod_view_prop.nextval,
                  prodid as id_prod_view,
                  column_name as nm_name, 
                  data_type as nm_data_type, 
                  column_name as nm_column_name, 
                  'Y' as b_required, 
                  'N' as b_composite_idx, 
                  'N' as b_single_idx, 
                  'N' as b_part_of_key, 
                  'Y' as b_exportable, 
                  'Y' as b_filterable, 
                  'Y' as b_user_visible, 
                  null as nm_default_value,   
                  0 as n_prop_type, 
                  null as nm_space,       
                  null as nm_enum, 
                  case when column_name like 'ID%' then 'Y' else 'N' end as b_core 
          from user_tab_cols
          where lower(table_name) = 't_acc_usage';
          
          /* make tx_uid a uniquekey */
          
          select id_prod_view into pvid
          from t_prod_view
          where lower(nm_table_name) = 't_acc_usage';
          
          select seq_t_unique_cons.nextval into ukid from dual;
          
          insert into t_unique_cons (id_unique_cons, id_prod_view, 
              constraint_name, nm_table_name)
            values (ukid, pvid, 
              'uk_acc_usage_tx_uid', 't_uk_acc_usage_tx_uid');

          insert into t_unique_cons_columns
            select ukid, id_prod_view_prop, 1
            from t_prod_view_prop
            where id_prod_view = pvid
              and lower(nm_name) = 'tx_uid';

        end if; /* t_acc_usage not in t_prod_view */

        /* Treat t_tax_details like a product view with respect to partitioning */
        select count(1) into cnt from dual
          where exists (select * from t_prod_view 
                        where lower(nm_table_name) = 't_tax_details');

        dbms_output.put_line('cnt=' || to_char(cnt));

        if cnt < 1 then
        
          dbms_output.put_line('cnt less than 1');

	  /* get the enum id for the t_tax_details table */
	  /* Note: should add tax_details enum instead of using metratax */
          select id_enum_data into tax_details_enum_id
          from t_enum_data
          where lower(nm_enum_data) = 'metratech.com/tax/taxvendor/metratax';

          dbms_output.put_line('tax_details_enum_id=' || to_char(tax_details_enum_id));

          select seq_t_prod_view.nextval into prodid from dual;
          dbms_output.put_line('prodid=' || to_char(prodid));
          
          insert into t_prod_view 
            (id_prod_view, id_view, dt_modified, nm_name, nm_table_name,b_can_resubmit_from)
          values 
            (prodid, tax_details_enum_id, sysdate, 'metratech.com/tax_details', 't_tax_details', 'N');

          /* add t_tax_details columns to t_prod_view_prop */
          insert into t_prod_view_prop( 
                  id_prod_view_prop,
                  id_prod_view, nm_name, nm_data_type, nm_column_name, 
                  b_required, b_composite_idx, b_single_idx, b_part_of_key, b_exportable, 
                  b_filterable, b_user_visible, nm_default_value, n_prop_type, nm_space, 
                  nm_enum, b_core) 
          select  seq_t_prod_view_prop.nextval,
                  prodid as id_prod_view,
                  column_name as nm_name, 
                  data_type as nm_data_type, 
                  column_name as nm_column_name, 
                  'Y' as b_required, 
                  'N' as b_composite_idx, 
                  'N' as b_single_idx, 
                  'N' as b_part_of_key, 
                  'Y' as b_exportable, 
                  'Y' as b_filterable, 
                  'Y' as b_user_visible, 
                  null as nm_default_value,   
                  0 as n_prop_type, 
                  null as nm_space,       
                  null as nm_enum, 
                  case when column_name like 'ID%' then 'Y' else 'N' end as b_core 
          from user_tab_cols
          where lower(table_name) = 't_tax_details';
          
        end if; /* t_tax_details not in t_prod_view */

        commit;

      end SetPartitionOptions;
   