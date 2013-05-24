using System;
using System.EnterpriseServices;
using System.Runtime.InteropServices;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using MetraTech;
using MetraTech.Collections;
using MetraTech.DataAccess;
using MetraTech.Product.Hooks.DynamicTableUpdate;
using MetraTech.Product.Hooks.InsertProdProperties;
using System.Diagnostics;
using MetraTech.Pipeline;

namespace MetraTech.Product.Hooks
{
	//[ComVisible(false)]
  [ClassInterface(ClassInterfaceType.None)]
  [Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
  [Guid("6340072E-4E40-4e37-A92B-5B617D7DDC57")]
  public class AccountTypeWriter : ServicedComponent
  {	
    // by the time we are at a point to use the writer -- we have already done all error checking
    // and validated that update/deletes are all kosher.  This component just goes and does the work.

    private ServiceDefinitionCollection mAvCollection;
    private Dictionary<string, bool> addedViews = new Dictionary<string, bool>(StringComparer.OrdinalIgnoreCase);
    private MetraTech.Logger mLog;
		
    public AccountTypeWriter()
    {    
      mAvCollection = new ServiceDefinitionCollection("accountview");
      mLog = new Logger("[AccountTypeWriter]");
    }

    [AutoComplete]
    public void DoIt(MTStringCollection typesToAdd, MTStringCollection typesToUpdate, MTStringCollection typesToDelete, NameValueCollection typeFiles)
    {
      foreach (string typeToAdd in typesToAdd)
      {
        //get the file and read it.
        AccountTypeFileReader reader = new AccountTypeFileReader();
        AccountTypeHelper currentAccountType = reader.ReadAccounTypeConfigFile(typeFiles[typeToAdd]);
        AddAccountType(currentAccountType);
      }
      foreach (string typeToDelete in typesToDelete)
      {
        DeleteAccountType(typeToDelete);
      }
      
      foreach (string typeToUpdate in typesToUpdate)
      {
        AccountTypeFileReader reader = new AccountTypeFileReader();
        AccountTypeHelper currentAccountType = reader.ReadAccounTypeConfigFile(typeFiles[typeToUpdate]);
        UpdateAccountType(currentAccountType);
      }
      //now that all types are up-to-date
      CreateChildMappings(typeFiles);
    }
   
    public void DeleteAccountType(string typename)
    {

      ArrayList accountViewNames = new ArrayList();

			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				//get the names of the account views associated with this account type. 
				//     -- may need to delete them first.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(
                    @"queries\Account", "__FIND_ACCOUNT_VIEWS_FOR_TYPE__"))
                {

                    stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", typename, false);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            accountViewNames.Add(rdr.GetString(0));
                        }
                    }


                    // for each account view, is there any other account type using it?  If no, it needs to be deleted.
                    foreach (string aviewName in accountViewNames)
                    {
                        //find out is this account view used by any other account type?
                        stmt.QueryTag = "__ACCOUNT_VIEWS_IN_USE__";
                        stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", typename, false);
                        stmt.AddParam("%%ACCOUNT_VIEW_NAME%%", aviewName, false);

                        bool accInUse = false;
                        using (IMTDataReader rdr = stmt.ExecuteReader())
                            accInUse = rdr.Read();

                        if (!accInUse)
                        {
                            //get the name of the accountview table
                            using (IMTAdapterStatement stmtav = conn.CreateAdapterStatement(
                                @"queries\AccountView", "__SELECT_ACCOUNT_VIEW_BY_NAME__"))
                            {
                                stmtav.AddParam("%%AV_NAME%%", aviewName, false);

                                string avTableName;
                                using (IMTDataReader rdr = stmtav.ExecuteReader())
                                {
                                    if (!rdr.Read())	// it better be there now that we inserted it
                                        throw new Exception(@"Couldn't select view by name: " + aviewName);
                                    avTableName = rdr.GetString("nm_table_name");
                                }

                                //delete the account view table
                                stmtav.QueryTag = "__DROP_ACCOUNT_VIEW_TABLE_AV__";
                                stmtav.AddParam("%%ACCOUNT_VIEW_TABLENAME%%", avTableName);
                                stmtav.ExecuteNonQuery();

                                //delete entries from t_account_view_prop
                                stmtav.QueryTag = "__DELETE_FROM_AV_PROP__";
                                stmtav.AddParam("%%AV_NAME%%", aviewName);
                                stmtav.ExecuteNonQuery();

                                //delete the row from t_account_view_log
                                stmtav.QueryTag = "__DELETE_FROM_AV_LOG__";
                                stmtav.AddParam("%%AV_NAME%%", aviewName);
                                stmtav.ExecuteNonQuery();
                            }
                        }
                    }

                    //delete the account view itself (this will delete from t_account_type_servicedef_map,t_account_type_view_map, t_acctype_descendenttype_map
                    //and t_account_type tables.

                    stmt.QueryTag = "__DELETE_ACCOUNT_TYPE__";
                    stmt.AddParam("%%ACCOUNT_TYPE_NAME%%", typename);
                    stmt.ExecuteNonQuery();

                } // using stmt
			}	// using connection
    }


    public void AddAccountType(AccountTypeHelper currentType)
    {
      int newAccountTypeID;
      int accountViewID;
      IInsertProdProperties insertprodprop = new MetraTech.Product.Hooks.InsertProdProperties.InsertProdProperties();

      ArrayList createTableQueries = new ArrayList();
      MTStringCollection currentViews = currentType.AccountViews;
      NameValueCollection accountViewsChksum= new NameValueCollection();
      NameValueCollection accountViewsTablename = new NameValueCollection();
      NameValueCollection accountViewsFilename = new NameValueCollection();

      foreach (string viewname in currentViews)
      {
        IServiceDefinition accountView = mAvCollection.GetServiceDefinition(viewname);
        //generate query to create the table.
        AVDDLCreator creator = new AVDDLCreator("t_av_", accountView);
        string query = creator.GenerateCreateTableStatement();
        //mLog.LogDebug("query = {0}", query);
        createTableQueries.Add(query);
        addedViews[viewname] = true;

        accountViewsTablename[viewname] = creator.GetTableName();

        //generate chksum.  The msixdef file is being read twice...
        MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
        bool ck=false;
        string chkSum = config.ReadConfiguration(mAvCollection.GetServiceDefFileName(viewname), out ck).Checksum;
        accountViewsChksum[viewname] = chkSum;

        accountViewsFilename[viewname] = mAvCollection.GetServiceDefFileName(viewname);
      }

			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
        //insert into t_account_type
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertAccountType"))
                {
                    stmt.AddParam("name", MTParameterType.String, currentType.Name);
                    stmt.AddParam("b_cansubscribe", MTParameterType.String, currentType.CanSubscribe);
                    stmt.AddParam("b_canbepayer", MTParameterType.String, currentType.CanBePayer);
                    stmt.AddParam("b_canhavesyntheticroot", MTParameterType.String, currentType.CanHaveSyntheticRoot);
                    stmt.AddParam("b_CanParticipateInGSub", MTParameterType.String, currentType.CanParticipateInGSub);
                    stmt.AddParam("bIsVisibleInHierarchy", MTParameterType.String, currentType.IsVisibleInHierarchy);
                    stmt.AddParam("b_CanHaveTemplates", MTParameterType.String, currentType.CanHaveTemplates);
                    stmt.AddParam("b_IsCorporate", MTParameterType.String, currentType.IsCorporate);
                    stmt.AddParam("nm_desc", MTParameterType.String, currentType.Desc);
                    stmt.AddOutputParam("id_accounttype", MTParameterType.Integer);

                    stmt.ExecuteNonQuery();

                    newAccountTypeID = (int)stmt.GetOutputValue("id_accounttype");
                }

        //insert into t_account_type_service_def_map
                foreach (string op in currentType.ServiceDefOpPair)
                {
                    using (IMTCallableStatement stmt2 = conn.CreateCallableStatement("UpsertAccountTypeServiceDefMap"))
                    {
                        stmt2.AddParam("accounttype", MTParameterType.Integer, newAccountTypeID);
                        stmt2.AddParam("operation", MTParameterType.String, op);
                        stmt2.AddParam("servicedefname", MTParameterType.String, currentType.ServiceDefOpPair[op]);

                        stmt2.ExecuteNonQuery();
                    }
                }
        
				// create the t_av_tables
                foreach (string query in createTableQueries)
                {
                    using (IMTStatement stmt4 = conn.CreateStatement(query))
                    {
                        stmt4.ExecuteNonQuery();
                    }
                }

        foreach(string viewname in currentType.AccountViews)
        {
					//insert into t_account_type_view_map
            using (IMTAdapterStatement stmt3 = conn.CreateAdapterStatement("queries\\Account", "__ADD_ACCOUNT_VIEW__"))
            {
                stmt3.AddParam("%%ACCOUNTTYPEID%%", newAccountTypeID);
                stmt3.AddParam("%%ACCOUNTVIEWNAME%%", viewname);
                stmt3.ExecuteNonQuery();
            }
          //did this account view already exist?  that would be the case if this account view is associated with another account
          //type created earlier.
            using (IMTAdapterStatement s4 = conn.CreateAdapterStatement(
                        @"Queries\AccountView", "__SELECT_ACCOUNT_VIEW_BY_NAME__"))
            {
                s4.AddParam("%%AV_NAME%%", viewname, false);

                bool found = false;
                using (IMTDataReader rdr = s4.ExecuteReader())
                {
                    found = rdr.Read();
                }

                if (!found) //the account view is not in the log, means it has been newly created and needs to be added
                {
                    using (IMTAdapterStatement s5 = conn.CreateAdapterStatement(
                        @"Queries\AccountView", "__INSERT_INTO_AV_LOG__"))
                    {
                        s5.AddParam("%%AV_NAME%%", viewname, false);
                        s5.AddParam("%%AV_CHECKSUM%%", accountViewsChksum[viewname], false);
                        s5.AddParam("%%AV_TABLE_NAME%%", accountViewsTablename[viewname], false);
                        s5.ExecuteNonQuery();

                        //ok, added the account view, now get its id.
                        s5.QueryTag = "__SELECT_ACCOUNT_VIEW_BY_NAME__";
                        s5.AddParam("%%AV_NAME%%", viewname, false);
                        s5.ExecuteNonQuery();

                        using (IMTDataReader rdr2 = s5.ExecuteReader())
                        {
                            if (!rdr2.Read())	// it better be there now that we inserted it
                                throw new Exception(@"Couldn't select view by name: " + accountViewsFilename[viewname]);
                            accountViewID = rdr2.GetInt32("id_account_view");
                        }
                    }

                    //insert into t_account_view_prop 
                    insertprodprop.Initialize(accountViewsFilename[viewname], accountViewID);
                    if (insertprodprop.InsertProperties() == 0)
                        throw new Exception("Inserting account view properties failed for " + accountViewsFilename[viewname]);
                } // !found
            } // using statement s4
        }	// foreach account view
      }	// using connection
    }

 
    public void UpdateAccountType(AccountTypeHelper currentType)
    {
      //we know that all updates are going to be non destructive.
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        //upsert account type.
        //upsert servicdef map.

        //insert into t_account_type_service_def_map, delete from t_account_type_service_def_map
        //insert into t_account_type_view_map, delete from t_account_type_view_map
        //create the t_av_tables, drop t_av_tables
        //insert into and delete from t_account_view_prop and t_account_view_log tables.


      }

      int newAccountTypeID;
      int accountViewID;
      IInsertProdProperties insertprodprop = new MetraTech.Product.Hooks.InsertProdProperties.InsertProdProperties();

      
      ArrayList createTableQueries = new ArrayList();
      MTStringCollection currentViews = currentType.AccountViews;
      NameValueCollection accountViewsChksum= new NameValueCollection();
      NameValueCollection accountViewsTablename = new NameValueCollection();
      NameValueCollection accountViewsFilename = new NameValueCollection();

      foreach (string viewname in currentViews)
      {
        IServiceDefinition accountView = mAvCollection.GetServiceDefinition(viewname);
        //generate query to create the table.
        AVDDLCreator creator = new AVDDLCreator("t_av_", accountView);
        string query = creator.GenerateCreateTableStatement();
        createTableQueries.Add(query);

        accountViewsTablename[viewname] = creator.GetTableName();

        //generate chksum.  The msixdef file is being read twice...
        MetraTech.Interop.PropSet.IMTConfig config = new MetraTech.Interop.PropSet.MTConfig();
        bool ck=false;
        string chkSum = config.ReadConfiguration(mAvCollection.GetServiceDefFileName(viewname), out ck).Checksum;
        accountViewsChksum[viewname] = chkSum;

        accountViewsFilename[viewname] = mAvCollection.GetServiceDefFileName(viewname);
      }

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        //upsert into t_account_type
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("UpsertAccountType"))
          {
              stmt.AddParam("name", MTParameterType.String, currentType.Name);
              stmt.AddParam("b_cansubscribe", MTParameterType.String, currentType.CanSubscribe);
              stmt.AddParam("b_canbepayer", MTParameterType.String, currentType.CanBePayer);
              stmt.AddParam("b_canhavesyntheticroot", MTParameterType.String, currentType.CanHaveSyntheticRoot);
              stmt.AddParam("b_CanParticipateInGSub", MTParameterType.String, currentType.CanParticipateInGSub);
              stmt.AddParam("bIsVisibleInHierarchy", MTParameterType.String, currentType.IsVisibleInHierarchy);
              stmt.AddParam("b_CanHaveTemplates", MTParameterType.String, currentType.CanHaveTemplates);
              stmt.AddParam("b_IsCorporate", MTParameterType.String, currentType.IsCorporate);
              stmt.AddParam("nm_desc", MTParameterType.String, currentType.Desc);
              stmt.AddOutputParam("id_accounttype", MTParameterType.Integer);

              stmt.ExecuteNonQuery();

              newAccountTypeID = (int)stmt.GetOutputValue("id_accounttype");
          }

        //upsert into t_account_type_service_def_map
          foreach (string op in currentType.ServiceDefOpPair)
          {
              using (IMTCallableStatement stmt2 = conn.CreateCallableStatement("UpsertAccountTypeServiceDefMap"))
              {
                  stmt2.AddParam("accounttype", MTParameterType.Integer, newAccountTypeID);
                  stmt2.AddParam("operation", MTParameterType.String, op);
                  stmt2.AddParam("servicedefname", MTParameterType.String, currentType.ServiceDefOpPair[op]);

                  stmt2.ExecuteNonQuery();
              }
          }

        //create the t_av_tables
          foreach (string query in createTableQueries)
          {
              using (IMTStatement stmt4 = conn.CreateStatement(query))
              {
                  stmt4.ExecuteNonQuery();
              }
          }

        foreach(string viewname in currentType.AccountViews)
        {
          //insert into t_account_type_view_map
            using (IMTAdapterStatement stmt3 = conn.CreateAdapterStatement("queries\\Account", "__ADD_ACCOUNT_VIEW__"))
            {
                stmt3.AddParam("%%ACCOUNTTYPEID%%", newAccountTypeID);
                stmt3.AddParam("%%ACCOUNTVIEWNAME%%", viewname);
                stmt3.ExecuteNonQuery();
            }

          //did this account view already exist?  that would be the case if this account view is associated with another account
          //type created earlier.
            using (IMTAdapterStatement s4 = conn.CreateAdapterStatement(
                @"Queries\AccountView", "__SELECT_ACCOUNT_VIEW_BY_NAME__"))
            {
                s4.AddParam("%%AV_NAME%%", viewname, false);

                bool foundAcct = false;
                using (IMTDataReader rdr = s4.ExecuteReader())
                    foundAcct = rdr.Read();

                if (!foundAcct)
                {
                    //the account view is not in the log, means it has been newly created and needs to be added
                    s4.QueryTag = "__INSERT_INTO_AV_LOG__";
                    s4.AddParam("%%AV_NAME%%", viewname, false);
                    s4.AddParam("%%AV_CHECKSUM%%", accountViewsChksum[viewname], false);
                    s4.AddParam("%%AV_TABLE_NAME%%", accountViewsTablename[viewname], false);
                    s4.ExecuteNonQuery();

                    //ok, added the account view, now get its id.
                    s4.QueryTag = "__SELECT_ACCOUNT_VIEW_BY_NAME__";
                    s4.AddParam("%%AV_NAME%%", viewname, false);

                    using (IMTDataReader rdr2 = s4.ExecuteReader())
                    {
                        if (!rdr2.Read())	// it better be there now that we inserted it
                            throw new Exception(@"Couldn't select view by name: " + viewname);
                        accountViewID = rdr2.GetInt32("id_account_view");
                    }

                    //insert into t_account_view_prop 
                    insertprodprop.Initialize(accountViewsFilename[viewname], accountViewID);
                    if (insertprodprop.InsertProperties() == 0)
                    {
                        throw new Exception("Inserting account view properties failed for " + accountViewsFilename[viewname]);
                    }
                }
                else if (!addedViews.ContainsKey(viewname))
                {
                    // For Oracle we need to use non service connections when altering account view tables.

                    // It's not entirely clear why we need a separate non-service connection for this; the original
                    // bug CR15533 seems to be lost somewhere in the old StarTeam server (I couldn't find it there).
                    // But the separate connection causes a problem: it executes in a separate session/transaction,
                    // so if an account view table was created earlier in AddAccountType(), then we won't find it in
                    // the db in ApplyRulesInTransaction() and we will error. So make sure the view was not created
                    // earlier.

                    ConnectionInfo connInfo = new ConnectionInfo("NetMeter");
                    bool isOracle = (connInfo.DatabaseType == DBType.Oracle) ? true : false;

                    //the account view already existed and may need to be updated. call update on account view.
                    IDynamicTableUpdate update = new MetraTech.Product.Hooks.DynamicTableUpdate.DynamicTableUpdate();
                    if (!update.UpdateTable(mAvCollection.GetServiceDefFileName(viewname), null, false, isOracle ? true : false))
                        throw new Exception("Update of " + viewname + " failed.");
                }
            }
        }
      }
      //possibly delete views?

    }

  
    public void CreateChildMappings(NameValueCollection accountTypesFromFiles)
    {
      //truncate the account type table.
      //read each file, I know I know I am reading the file twice
      //Add mappings for each type.
      try
      {
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          //truncate the t_acctype_descendentType_map table
            using (IMTAdapterStatement adpStmt = conn.CreateAdapterStatement("Queries\\Account", "__TRUNCATE_ACCOUNT_TYPE_DESC_TYPE_MAP__"))
            {
                adpStmt.ExecuteNonQuery();
            }

          //read each file and add its mappings.
          foreach (string accountTypeName in accountTypesFromFiles)
          {
            //read the file
            AccountTypeFileReader reader = new AccountTypeFileReader();
            MetraTech.Product.Hooks.AccountTypeHelper currentAccountType = reader.ReadAccounTypeConfigFile(accountTypesFromFiles[accountTypeName]);
            foreach (string childtype in currentAccountType.DescendentTypes)
            {
                using (IMTAdapterStatement adpStmtAdd = conn.CreateAdapterStatement("Queries\\Account", "__CREATE_ACCOUNT_TYPE_DESC_MAP_"))
                {
                    adpStmtAdd.AddParam("%%PARENT_NAME%%", accountTypeName);
                    adpStmtAdd.AddParam("%%DESC_NAME%%", childtype);
                    adpStmtAdd.ExecuteNonQuery();
                }
            }

            foreach (string parentType in currentAccountType.AncestorTypes)
            {
                using (IMTAdapterStatement adpStmtAdd = conn.CreateAdapterStatement("Queries\\Account", "__CREATE_ACCOUNT_TYPE_DESC_MAP_"))
                {
                    adpStmtAdd.AddParam("%%PARENT_NAME%%", parentType);
                    adpStmtAdd.AddParam("%%DESC_NAME%%", accountTypeName);
                    adpStmtAdd.ExecuteNonQuery();
                }
            }
          }
        }
      }
      catch (Exception e)
      {
				mLog.LogDebug(e.Message);
        throw new ApplicationException("AccountType hook failed. Possible causes could be: \n 1. Either the same parent child relationship between account types is mentioned more than once. \n Or \n 2. A non-existent parent or child is specified in the parent-child relationship");
      }
      
    } 

  }

}
