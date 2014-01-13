
BEGIN TRAN

 /* __DELETE_SECOND_PASS_AGGREGATE_ESTIMATE_DATA__ */ 
 
  DELETE FROM %%SECOND_PASS_PV_TABLE_NAME%%
  WHERE EXISTS 
  (
    SELECT 1 
    FROM t_acc_usage
    WHERE 
      id_usage_interval %%USAGE_INTERVAL_FILTER%% AND
      id_pi_template = %%ID_PI_TEMPLATE%% AND
      id_view = %%SECOND_PASS_VIEW_ID%% AND
      id_sess = %%SECOND_PASS_PV_TABLE_NAME%%.id_sess AND
      id_usage_interval = %%SECOND_PASS_PV_TABLE_NAME%%.id_usage_interval
      %%BILLING_GROUP_FILTER%% 
  )

    /* ESR-3290 */   
    declare @sql nvarchar(4000)
    declare @keytab nvarchar(255)
    declare @idusageinterval nvarchar(512)
    declare @usage_tab nvarchar(255)
    set @usage_tab =  N'%%SECOND_PASS_PV_TABLE_NAME%%'
          
    /* get the list of unique tables, pv.nm_table should equal @usage_tab */
    set @sql = N'declare keycur cursor for
                  select uc.nm_table_name                  
                   from t_unique_cons uc
                   join t_prod_view pv on uc.id_prod_view = pv.id_prod_view
                   where pv.nm_table_name = '''  +  @usage_tab + N''''
                                          
     EXEC sp_executesql @sql                 
      open keycur
      fetch next from keycur into @keytab
      /* the filter contains comparsion and logical operators =,<>,IN etc */ 
      set @idusageinterval  = N'%%USAGE_INTERVAL_FILTER%%'
      
      while @@fetch_status = 0
        begin   
          set @sql = N'delete uk ' + 
                      'from ' + @keytab + ' uk ' +
                      'join t_acc_usage rr ' +
                      ' on uk.id_sess = rr.id_sess and rr.id_usage_interval  ' + cast(@idusageinterval as nvarchar(512))
     
          /* delete from the unique key tables */ 
          exec sp_executesql @sql
                       
          fetch next from keycur into @keytab
        end                                  
        deallocate keycur
  /* ESR-3290 */ 
  
  DELETE FROM t_acc_usage
  WHERE
    id_usage_interval %%USAGE_INTERVAL_FILTER%% AND
    id_pi_template = %%ID_PI_TEMPLATE%% AND
    id_view = %%SECOND_PASS_VIEW_ID%%
    %%BILLING_GROUP_FILTER%% 

COMMIT
           