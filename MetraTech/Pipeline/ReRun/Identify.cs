
using System.Runtime.InteropServices;

[assembly: GuidAttribute("3cec7d2f-6768-4069-9e7e-c22d0a4b5a96")]

namespace MetraTech.Pipeline.ReRun
{
	using MetraTech;
	using MetraTech.Utils;
	using MetraTech.Xml;
	using MetraTech.Pipeline;

	using MetraTech.Interop.Rowset;
	using MetraTech.Interop.MTBillingReRun;
	using MetraTech.Interop.NameID;
	using MetraTech.Interop.MTAccount;
	using MetraTech.Interop.MTYAAC;
	using MetraTech.Interop.MTAuth;
	using MetraTech.Interop.MTEnumConfig;

	using System;
	using System.Diagnostics;
	using System.Text;
	using System.Collections;
	using System.Collections.Specialized;

	//using System.Xml.Serialization;
	using System.Runtime.Serialization;
	using System.Runtime.Serialization.Formatters.Soap;

	using MetraTech.DataAccess;


	[Guid("3976ff56-fe35-4077-934a-a79873374991")]
	public interface IDBIdentify
	{
		MetraTech.Interop.Rowset.IMTDataFilter
			GenerateDatabaseFilter(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
														 IMTIdentificationFilter identifyFilter,
                              string UIDTableName,
														bool useDBQueues);

    string GenerateDatabaseFilterForFailedTransactions(IMTIdentificationFilter identifyFilter, 
                                                        string UIDTableName,
                                                      bool useDBQueues);

		string GetSourceDataQuery(IMTIdentificationFilter identifyFilter, string sourceTableName);
    string GenerateQueryForNotProcessedTransactions(IMTIdentificationFilter identifyFilter);
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("228b693c-3780-4b20-b1e3-b43a037b1c2a")]
	public class DBIdentify : IDBIdentify
	{
	  public DBIdentify(bool isOracle)
	  {
		  mIsOracle = isOracle;
	  }
	  public MetraTech.Interop.Rowset.IMTDataFilter GenerateDatabaseFilter(MetraTech.Interop.MTBillingReRun.IMTSessionContext context, 
      IMTIdentificationFilter identifyFilter,
      string UIDTableName,
			bool useDBQueues)
		{
			try
			{
				bool first;
				MetraTech.Interop.Rowset.IMTDataFilter dbfilter = new MTDataFilter();
       
        if (mIsOracle)
        {
          dbfilter.IsOracle = true;
        }
				IMTNameID nameid = new MTNameID();

				//
				// batch ID
				//
				if (identifyFilter.BatchID != null && identifyFilter.BatchID.Length > 0)
				{
					byte [] uidBytes;
					try
					{
						uidBytes = MSIXUtils.DecodeUID(identifyFilter.BatchID);
					}
					catch (System.FormatException e)
					{
						throw new ApplicationException(string.Format("Invalid batch UID: {0} (should be in the format wKgBtvqCN9KiVIDloPNsXA==): {1}",
																												 identifyFilter.BatchID, e.Message));
					}

					dbfilter.Add("au.tx_batch",
											 (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
											 uidBytes);
				}

				//
				// interval ID
				//
				if (identifyFilter.IntervalID != -1)
				{
						dbfilter.Add("au.id_usage_interval",
                        //Fix for backing out AMP pushed usage ESR-6336
                        //If AMP is being used it is possible that originally specified interval for usage
                        //has been altered (pushed) to later interval by AMP
                        //when backing original batch look for identifying batch and potentially later intervalid
                        //only when batchid is specfied
                       (identifyFilter.BatchID != null && identifyFilter.BatchID.Length > 0) ? 
                          (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL :
											    (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
											 identifyFilter.IntervalID);
 	                                }
									
				//
				// billing group ID
				//
				if (identifyFilter.BillingGroupID != -1)
				{
					string inClause = String.Format("SELECT id_acc FROM t_billgroup_member WHERE id_billgroup = {0}",
																					identifyFilter.BillingGroupID);
					dbfilter.Add("au.id_acc",
											 (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
											 inClause);
				}

				//
				// session IDs
				//
		
        int numSessions = identifyFilter.SessionIDs.Count;
        if(numSessions > 0)
        {
          //The table UIDList_rerunID has been created already.
     
          MetraTech.DataAccess.IBulkInsert bulkInsert =  BulkInsertManager.CreateBulkInsert("NetMeter");
         // bulkInsert.Connect(connInfo);
          using (bulkInsert)
          {
            bulkInsert.PrepareForInsert(UIDTableName, 1000);
            int sessCounter = 0;
            foreach (string sessionID in identifyFilter.SessionIDs)
            {
              byte [] uidBytes;
              try
              {
                uidBytes = MSIXUtils.DecodeUID(sessionID);
              }
              catch (System.FormatException e)
              {
                throw new ApplicationException(string.Format("Invalid session UID: {0} (should be in the format wKgBtvqCN9KiVIDloPNsXA==): {1}",
                  identifyFilter.BatchID, e.Message));
              }

              bulkInsert.SetValue(1, MTParameterType.Binary, uidBytes);
              bulkInsert.AddBatch();
              if (++sessCounter % 1000 == 0)
                  bulkInsert.ExecuteBatch();
                 
            }
            bulkInsert.ExecuteBatch();
          }
          
        }

     
				//
				// time range
				//

				if (identifyFilter.BeginDatetimeIsSet)
				{
					System.DateTime begin = identifyFilter.BeginDatetime;

					dbfilter.Add("au.dt_crt",
											 (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL,
											 begin);
				}

				if (identifyFilter.EndDatetimeIsSet)
				{
					System.DateTime end = identifyFilter.EndDatetime;

					dbfilter.Add("au.dt_crt",
											 (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_LESS_EQUAL,
											 end);
				}

				//
				// service definitions
				//
				first = true;
				StringBuilder svcDefClause = new StringBuilder();
				foreach (string svcDefName in identifyFilter.ServiceDefinitions)
				{
					int serviceID = nameid.GetNameID(svcDefName);
					if (!first)
						svcDefClause.Append(", ");
					else
						first = false;

					svcDefClause.Append(serviceID.ToString());
				}
				if (svcDefClause.Length > 0)
					dbfilter.Add("au.id_svc", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
											 svcDefClause.ToString());

				//
				// product views
				//
				first = true;
				StringBuilder pvClause = new StringBuilder();
				foreach (string pvName in identifyFilter.ProductViews)
				{
					int pvID = nameid.GetNameID(pvName);
					if (!first)
						pvClause.Append(", ");
					else
						first = true;
					pvClause.Append(pvID.ToString());
				}

				if (pvClause.Length > 0)
					dbfilter.Add("au.id_view", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
											 pvClause.ToString());


				//
				// account view
				//

				if (identifyFilter.AccountConditions != null)
				{
					IMTAccountCatalog accountCatalog = new MTAccountCatalog();

					accountCatalog.Init((MetraTech.Interop.MTYAAC.IMTSessionContext) context);

					DateTime now = MetraTech.MetraTime.Now;

					// we only care about the account IDs
					MetraTech.Interop.MTYAAC.IMTCollection cols =
						(MetraTech.Interop.MTYAAC.IMTCollection) new MetraTech.Interop.GenericCollection.MTCollection();
					cols.Add("_AccountID");

					MetraTech.Interop.MTYAAC.IMTDataFilter accountSearchFilter =
						(MetraTech.Interop.MTYAAC.IMTDataFilter) identifyFilter.AccountConditions;

					string query =
						accountCatalog.GenerateAccountSearchQuery(now, cols, accountSearchFilter, null, null, 0);

					dbfilter.Add("au.id_acc", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
											 query);
				}

				//
				// service definition
				//
				if ((identifyFilter.ServiceDefinitionProperties.Count > 0) && !useDBQueues)
					AddProductViewClause(dbfilter, identifyFilter.ServiceDefinitionProperties, nameid, false);

         // bug fix for 12408
        if ((identifyFilter.ServiceDefinitionProperties.Count > 0) && useDBQueues)
          dbfilter.Add("1", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, 1);

				//
				// product view definition
				//
				if (identifyFilter.ProductViewProperties.Count > 0)
					AddProductViewClause(dbfilter, identifyFilter.ProductViewProperties, nameid, true);

				return dbfilter;
			}
			catch (System.Exception err)
			{
				Logger logger = new Logger("[BillingReRun]");
				logger.LogError("Exception throw: " + err);
				throw;
			}
		}

   
    public string GenerateDatabaseFilterForFailedTransactions(IMTIdentificationFilter identifyFilter, 
      string UIDTableName,
      bool useDBQueues)
    {
      try
      {
        bool first = true;
        bool batchSpecified = false;
        bool serviceSpecified = false;
        bool dateSpecified = false;
        bool serviceDefPropSpecified = false;


        IMTNameID nameid = new MTNameID();
        MetraTech.Interop.Rowset.IMTDataFilter dbfilterBatch = new MTDataFilter();
        MetraTech.Interop.Rowset.IMTDataFilter dbfilterService = new MTDataFilter();
        MetraTech.Interop.Rowset.IMTDataFilter dbfilterDateRange = new MTDataFilter();
        MetraTech.Interop.Rowset.IMTDataFilter dbfilterServiceDefProp = new MTDataFilter();

        if (mIsOracle)
        {
          dbfilterBatch.IsOracle = true;
          dbfilterService.IsOracle = true;
          dbfilterDateRange.IsOracle = true;
          dbfilterServiceDefProp.IsOracle = true;
        }

        //
        // batch ID
        //
        if (identifyFilter.BatchID != null && identifyFilter.BatchID.Length > 0)
        {
          batchSpecified = true;
          byte [] uidBytes;
          try
          {
            uidBytes = MSIXUtils.DecodeUID(identifyFilter.BatchID);
          }
          catch (System.FormatException e)
          {
            throw new ApplicationException(string.Format("Invalid batch UID: {0} (should be in the format wKgBtvqCN9KiVIDloPNsXA==): {1}",
              identifyFilter.BatchID, e.Message));
          }

          dbfilterBatch.Add("ft.tx_batch",
            (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
            uidBytes);
        }

        //
        // service definitions
        //
        first = true;
        if (identifyFilter.ServiceDefinitions.Count > 0)
        {
          serviceSpecified = true;
          StringBuilder svcDefClause = new StringBuilder();
          foreach (string svcDefName in identifyFilter.ServiceDefinitions)
          {
            int serviceID = nameid.GetNameID(svcDefName);
            if (!first)
              svcDefClause.Append(", ");
            else
              first = false;

            svcDefClause.Append(serviceID.ToString());
          }
          if (svcDefClause.Length > 0)
            dbfilterService.Add("ed.id_enum_data", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
              svcDefClause.ToString());

        }

        //
        // Service definition property
        //
        // bug fix for 12408
        if ((identifyFilter.ServiceDefinitionProperties.Count > 0) && useDBQueues)
        {
          serviceDefPropSpecified = true;
          dbfilterServiceDefProp.Add("1", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL, 1);
        }
        

        //
        // time range
        //

        if ((identifyFilter.BeginDatetimeIsSet) ||(identifyFilter.EndDatetimeIsSet))
        {
          dateSpecified = true;
          if (identifyFilter.BeginDatetimeIsSet)
          {
            System.DateTime begin = identifyFilter.BeginDatetime;

            dbfilterDateRange.Add("ft.dt_FailureTime",
              (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL,
              begin);
          }

          if (identifyFilter.EndDatetimeIsSet)
          {
            System.DateTime end = identifyFilter.EndDatetime;

            dbfilterDateRange.Add("ft.dt_FailureTime",
              (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_LESS_EQUAL,
              end);
          }
        }

        StringBuilder whereClause = new StringBuilder();

        if (batchSpecified)
        {
          whereClause.Append(" and ");
          whereClause.Append(dbfilterBatch.FilterString);
        }
        if (serviceSpecified)
        {
          whereClause.Append(" and ");
          whereClause.Append(dbfilterService.FilterString);
        }
        if (dateSpecified)
        {
          whereClause.Append(" and ");
          whereClause.Append(dbfilterDateRange.FilterString);
        }
        if (serviceDefPropSpecified)
        {
          whereClause.Append(" and ");
          whereClause.Append(dbfilterServiceDefProp.FilterString);
        }

				//
				// billing group ID
				//
				if (identifyFilter.BillingGroupID != -1)
				{
          whereClause.Append(" and ");
          whereClause.Append(String.Format("ft.id_PossiblePayerID IN (SELECT id_acc FROM t_billgroup_member WHERE id_billgroup = {0})",
																						identifyFilter.BillingGroupID));
				}


        return whereClause.ToString();

      }
      catch (System.Exception err)
      {
        Logger logger = new Logger("[BillingReRun]");
        logger.LogError("Exception throw: " + err);
        throw;
      }
    }
		
		public string GetSourceDataQuery(IMTIdentificationFilter identifyFilter, string sourceTableName)
		{
			//the filters that would be used are servicedef and servicedef prop.  If batchid is specified,
			//it will be used in conjunction with the service defs. The where clause would look like
			//select id_source_sess from %%t_svc_tablename%%
			//where PROPNAME1 = value1
			//AND PROPNAME2 = value2
			//AND id_batch = value3 and so on.  
			//note, only one t_svc_tablename should be possible.
			//only called in conjuction with dbqueues.
			
			StringBuilder query = new StringBuilder();
			bool error = false;
			string svcName = "";
			string svcName2 = "";

			MetraTech.Interop.MTBillingReRun.IMTCollection conditions = identifyFilter.ServiceDefinitionProperties;

			if (conditions.Count > 0)
			{
				IMTFilterCondition firstCondition = (IMTFilterCondition) conditions[1];
				svcName = firstCondition.EntityName;
				foreach (IMTFilterCondition condition in conditions)
				{
					string currentName = condition.EntityName;
					if (svcName != currentName)
						error = true;
				}
			}

			if (identifyFilter.ServiceDefinitions.Count > 0)
			{
				svcName2 = identifyFilter.ServiceDefinitions[1].ToString();
				foreach (string svcDefName in identifyFilter.ServiceDefinitions)
				{
					if (svcDefName != svcName2)
						error = true;
				}
			}

			if (conditions.Count>0 && identifyFilter.ServiceDefinitions.Count>0)
			{
				if (svcName != svcName2)
					error = true;
			}
			
			if (error)
				throw new ApplicationException("Only one service definition can be chosen during Identify");
			
			//use query adapter to create the query??
			string svcTableName = GetSourceDataTableName(identifyFilter);
			query.Append("insert into ");
			query.Append(sourceTableName);
			query.Append(" select id_source_sess from ");
			query.Append(svcTableName);

			//special case where filter is identifying all sessions from a particular service def, without specifying
			//properties.  
			if (conditions.Count == 0 && identifyFilter.ServiceDefinitions.Count >0)
			{
				if (identifyFilter.BatchID != null && identifyFilter.BatchID.Length > 0)
				{
					byte [] uidBytes;
					try
					{
						uidBytes = MSIXUtils.DecodeUID(identifyFilter.BatchID);
					}
					catch (System.FormatException e)
					{
						throw new ApplicationException(string.Format("Invalid batch UID: {0} (should be in the format wKgBtvqCN9KiVIDloPNsXA==): {1}",
							identifyFilter.BatchID, e.Message));
					}
					string batchid = ToHexString(uidBytes);
					query.Append(" where c__CollectionID = ");
					query.Append(batchid);
				}
				
			}
			else
			{
				// we have a filter that should generate a query like select id_source_sess from svcTableName 
				//where prop1 = val1 and prop2 = val2 and batchid= hex value  (batchid being optional)
				
				bool first = true;
				IServiceDefinition svcDef = null;

				foreach (IMTFilterCondition condition in conditions)
				{
					try
					{
						//read the properties and types and metadata from the msixdef file
						svcDef = GetServiceDefinition(condition.EntityName); 
					}
					catch (System.ArgumentException)
					{
						//log it into the log as well
						throw new ApplicationException(String.Format("Service definition {0} could not be found",
							condition.EntityName));;
					}
						
					if (!svcDef.Contains(condition.PropertyName))
					{
						throw new ApplicationException(String.Format("Service definition {0} does not have a property named {1}",
							condition.EntityName, condition.PropertyName));
					}
					else
					{
						MetraTech.Interop.Rowset.IMTDataFilter subselect = new MTDataFilter();

						MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop =
							(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData) svcDef[condition.PropertyName];

						if (first)
						{
							query.Append (" where ");
							first = false;
						}
						else
						{	
							query.Append(" AND ");
						}

						object myval;
						string columnName = prop.DBColumnName;

						if (prop.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
						{
							IEnumConfig enumConfig = new EnumConfig();
							// enums are handled specially
							myval = enumConfig.GetID(prop.EnumSpace, prop.EnumType, condition.Value.ToString());
						}
						else
						{
								myval = MetaDataParser.ParseValue(prop.DataType, condition.Value.ToString());
						}
						subselect.Add(columnName,(int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
							myval);
						string tryit = subselect.FilterString;
						query.Append(subselect.FilterString);
											
					}
				}

				
			}
			mSourceDataQuery = query.ToString();
			return mSourceDataQuery;
	
		}
		
		
    public string GenerateQueryForNotProcessedTransactions(IMTIdentificationFilter identifyFilter)
    {
      StringBuilder whereClause = new StringBuilder();
      StringBuilder pendingClause = new StringBuilder();
      StringBuilder suspendedClause = new StringBuilder();
      
      if (identifyFilter.IsIdentifyPendingTransactions)
      {
        pendingClause.Append(" (msg.dt_assigned is null)");
      }
      if (identifyFilter.IsIdentifySuspendedTransactions)
      {
        string suspendedInterval = identifyFilter.SuspendedInterval.ToString();
        DateTime now = MetraTech.MetraTime.Now;
        suspendedClause.Append(" ((msg.dt_assigned is not null) and (msg.dt_completed is null) and (dbo.diffhour(msg.dt_assigned, ");
        suspendedClause.Append(DBUtil.ToDBString(now));
        // ESR-3170 select all suspended transactions
        suspendedClause.Append(") >= ");
        suspendedClause.Append(suspendedInterval);
        suspendedClause.Append("))");
      }
      if(identifyFilter.IsIdentifyPendingTransactions && identifyFilter.IsIdentifySuspendedTransactions)
      {
        whereClause.Append("and ( ");
        whereClause.Append(pendingClause.ToString());
        whereClause.Append(" OR ");
        whereClause.Append(suspendedClause.ToString());
        whereClause.Append(" ) ");
      }
      else if (identifyFilter.IsIdentifyPendingTransactions)
      {
        whereClause.Append(" and ");
        whereClause.Append(pendingClause.ToString());
      }
      else if (identifyFilter.IsIdentifySuspendedTransactions)
      {
        whereClause.Append(" and ");
        whereClause.Append(suspendedClause.ToString());
      }
      
      //ok, we know the sessions that are not complete.  Additional filters
      // that could be used are batchid (used by adapter reversal), service def id and
      // service def property.  batch id is present only in the root service of 
      // any message.  Following query will give us the root message.
      if (identifyFilter.BatchID != null && identifyFilter.BatchID.Length > 0)
      {
        byte [] uidBytes;
        try
        {
          uidBytes = MSIXUtils.DecodeUID(identifyFilter.BatchID);
        }
        catch (System.FormatException e)
        {
          throw new ApplicationException(string.Format("Invalid batch UID: {0} (should be in the format wKgBtvqCN9KiVIDloPNsXA==): {1}",
            identifyFilter.BatchID, e.Message));
        }
        string batchid = ToHexString(uidBytes);
        StringBuilder queryWhereClause = new StringBuilder();
        queryWhereClause.Append(whereClause.ToString());
        queryWhereClause.Append(" and b_root = 1");
       
        //query.Append(" where c__CollectionID = 0x");
        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__FIND_TABLES_WITH_SUSPENDED_OR_PENDING_USAGE__"))
            {
                stmt.AddParam("%%WHERE_CLAUSE%%", queryWhereClause.ToString(), true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    bool first = true;
                    bool atLeastOne = false;
                    while (reader.Read())
                    {
                        if (first)
                        {
                            whereClause.Append(" and ( ");
                            first = false;
                            atLeastOne = true;
                        }
                        else
                            whereClause.Append(" OR ");
                        string tablename = reader.GetString("nm_table_name");
                        whereClause.Append("(sess.id_source_sess in (select id_source_sess from ");
                        whereClause.Append(tablename);
                        whereClause.Append(" where c__CollectionID = ");
                        whereClause.Append(batchid);
                        whereClause.Append("))");
                    }
                    if (atLeastOne)
                        whereClause.Append(")");
                }

            }
        }
      }
      return whereClause.ToString();
    }
    private void AddProductViewClause(MetraTech.Interop.Rowset.IMTDataFilter dbfilter,
																			MetraTech.Interop.MTBillingReRun.IMTCollection conditions,
																			IMTNameID nameID, bool allRequired)
		{
			// we have to generate this as a subselect to make it easy to fit into the IMTDataFilter
			//   au.id_view = 23 and au.id_sess in (select id_sess from t_pv_testservice where c_units = 10.0)
			// we want to generate one subselect for each productview

			// first divide them up by productview
			Hashtable conditionsByPV = CollectionsUtil.CreateCaseInsensitiveHashtable();

			foreach (IMTFilterCondition condition in conditions)
			{
				string pvName = condition.EntityName;
				if (!conditionsByPV.Contains(pvName))
					conditionsByPV[pvName] = new ArrayList();

				ArrayList conditionList = (ArrayList) conditionsByPV[pvName];
				Debug.Assert(conditionList != null);
				conditionList.Add(condition);
			}

			foreach (string pvName in conditionsByPV.Keys)
			{
				MetraTech.Interop.Rowset.IMTDataFilter subselect = new MTDataFilter();

				string tableName = null;
				foreach (IMTFilterCondition condition in (ArrayList) conditionsByPV[pvName])
				{
					IProductViewDefinition pvDef = null;
					try
					{
						pvDef = GetProductViewDefinition(condition.EntityName);
					}
					catch (System.ArgumentException)
					{
						if (!allRequired)
							// if we're looking for service definitions and
							// no product view exists with the service def name, skip it
							continue;
						else
							throw;
					}

					if (!pvDef.Contains(condition.PropertyName))
					{
						// if a service def property is not in the product view, then
						// don't throw an error, just ignore it
						if (allRequired)
							throw new ApplicationException(String.Format("Product definition {0} does not have a property named {1}",
																													 condition.EntityName, condition.PropertyName));
					}
					else
					{
						if (tableName == null)
							tableName = pvDef.TableName;

						MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop =
							(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData) pvDef[condition.PropertyName];

						object value;
						if (prop.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
						{
							IEnumConfig enumConfig = new EnumConfig();
							// enums are handled specially
							value = enumConfig.GetID(prop.EnumSpace, prop.EnumType, condition.Value.ToString());
						}
						else
							value = MetaDataParser.ParseValue(prop.DataType, condition.Value.ToString());

						string columnName = prop.DBColumnName;

						subselect.Add(columnName,
													(int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
													value);
					}
				}

				if (subselect.Count > 0)
				{
					int viewID = nameID.GetNameID(pvName);
					dbfilter.Add("au.id_view",
											 (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_EQUAL,
											 viewID);


					StringBuilder queryBuilder = new StringBuilder();
					queryBuilder.Append("select id_sess from ");
					queryBuilder.Append(tableName);
					queryBuilder.Append(" where ");
					queryBuilder.Append(subselect.FilterString);

					dbfilter.Add("au.id_sess", (int) MetraTech.Interop.Rowset.MTOperatorType.OPERATOR_TYPE_IN,
											 queryBuilder.ToString());
				}
			}
		}

		private string ToHex(byte [] value)
		{
			StringBuilder str = new StringBuilder();

			// convert the session id to a string ...
			// MSSqlServer and Oracle have different binary string encodings.  Oracle
			// requires single quotes and no 0x prefix.  MSSql requires a 0x prefix 
			// and does not allow quotes.
			//
			// MSSql:  0xC0A8012D93E8363C5888FCC4E95ABB3A
			// Oracle: 'C0A8012D93E8363C5888FCC4E95ABB3A'
			// 
			str.Append(mIsOracle ? "'" : "0x");

			for (int i=0 ; i < value.Length; i++)
				str.Append(value[i].ToString("X2"));

			if (mIsOracle)
				str.Append("'");

			return str.ToString();
		}


		private IServiceDefinition GetServiceDefinition(string name)
		{
			if (mSvcDefCollection == null)
				mSvcDefCollection = new ServiceDefinitionCollection();

			return mSvcDefCollection.GetServiceDefinition(name);
		}

		private IProductViewDefinition GetProductViewDefinition(string name)
		{
			if (mPVDefCollection == null)
				mPVDefCollection = new ProductViewDefinitionCollection();

			return mPVDefCollection.GetProductViewDefinition(name);
		}



		private string GetSourceDataTableName(IMTIdentificationFilter identifyFilter)
		{
	
			//no error checking needed here
			string svcName = "";

			if (identifyFilter.ServiceDefinitions.Count > 0)
			{
				svcName = identifyFilter.ServiceDefinitions[1].ToString();
		
			}
			else if (identifyFilter.ServiceDefinitionProperties.Count > 0)
			{
				IMTFilterCondition condition = (IMTFilterCondition)(identifyFilter.ServiceDefinitionProperties[1]);
				svcName = condition.EntityName;
			}
			
			if (svcName != "")
			{
				try
				{
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__GET_SERVICE_DEF_TABLE_NAME__"))
                        {
                            stmt.AddParam("%%SERVICE_DEF_NAME%%", svcName);
                            using (IMTDataReader output = stmt.ExecuteReader())
                            {
                                while (output.Read())
                                    mSvcTableName = (string)output.GetString("nm_table_name");
                            }
                        }
                    }
				}
			
				catch (System.Exception err)
				{
					Logger logger = new Logger("[BillingReRun]");
					logger.LogError("Exception throw: " + err);
					throw;
				}
			}
			return mSvcTableName;
		}

		private string ToHexString(byte[] bytes) 
		{
			char[] chars = new char[bytes.Length * 2];
			for (int i = 0; i < bytes.Length; i++) 
			{
				int b = bytes[i];
				chars[i * 2] = hexDigits[b >> 4];
				chars[i * 2 + 1] = hexDigits[b & 0xF];
			}
			string bareString = new string(chars);

			StringBuilder str = new StringBuilder();
			str.Append(mIsOracle ? "'" : "0x");
			str.Append(bareString);
			if (mIsOracle)
				str.Append("'");
			return str.ToString();
			
		}


		ServiceDefinitionCollection mSvcDefCollection;
		ProductViewDefinitionCollection mPVDefCollection;
		private string mSvcTableName = "";
		private string mSourceDataQuery = "";
	

		static char[] hexDigits = {	  '0', '1', '2', '3', '4', '5', '6', '7',
									  '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        private bool mIsOracle;
	}

	[ClassInterface(ClassInterfaceType.None)]
	[Guid("1c07a005-b356-4c14-a619-54fd46f1f36a")]
	[Serializable]
	public class FilterCondition : IMTFilterCondition
	{
		public string EntityName
		{
			get
			{
				return mEntityName;
			}
			set
			{
				mEntityName = value;
			}
		}

		public string PropertyName
		{
			get
			{
				return mPropertyName;
			}
			set
			{
				mPropertyName = value;
			}
		}

		public object Value
		{
			get
			{
				return mValue;
			}
			set
			{
				mValue = value;
			}
		}

		string mEntityName;
		string mPropertyName;
		object mValue;
	};

	[Guid("5723f91f-d3a1-4f20-92ee-7250d5971e8c")]
	public interface IFilterItem
	{
		string PropertyName{get;set;}
		MetraTech.Interop.MTBillingReRun.MTOperatorType Operator{get;set;}
		object Value{get;set;}
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("d7bc9883-f609-4a14-9176-49721c29d40e")]
	[Serializable]
	// this class holds the same properties as IMTFilterItem.
	// We use it because it's serializable.
	public class FilterItem : IFilterItem
	{
		public FilterItem()
		{ }
		
		public FilterItem(MetraTech.Interop.MTBillingReRun.IMTFilterItem filterItem)
		{
			mPropertyName = filterItem.PropertyName;
			mOperatorType = filterItem.Operator;
			mValue = filterItem.Value;
		}

		public string PropertyName
		{
			get
			{
				return mPropertyName;
			}
			set
			{
				mPropertyName = value;
			}
		}

		public MetraTech.Interop.MTBillingReRun.MTOperatorType Operator
		{
			get
			{
				return mOperatorType;
			}
			set
			{
				mOperatorType = value;
			}
		}

		public object Value
		{
			get
			{
				return mValue;
			}
			set
			{
				mValue = value;
			}
		}

		private string mPropertyName;
		private MetraTech.Interop.MTBillingReRun.MTOperatorType mOperatorType;
		private object mValue;
	}


	[ClassInterface(ClassInterfaceType.None)]
	[Guid("ccb9be2f-a936-4249-8185-ad5a4c1e3b51")]
	[Serializable]
	public class IdentificationFilter : IMTIdentificationFilter, ISerializable
	{
		public IdentificationFilter()
		{ }

		protected IdentificationFilter(SerializationInfo info,
																	 StreamingContext context)
		{
			// NOTE: it's very important to deserialize all members!
			mBatchID = info.GetString("BatchID");
			mIntervalID = info.GetInt32("IntervalID");
			mBillingGroupID = info.GetInt32("BillingGroupID");
			mBeginDateTime = info.GetDateTime("BeginDateTime");
			mBeginDateTimeSet = info.GetBoolean("BeginDateTimeSet");
			mEndDateTime = info.GetDateTime("EndDateTime");
			mEndDateTimeSet = info.GetBoolean("EndDateTimeSet");
      mIdentifySuspendedTransactions = info.GetBoolean("IdentifySuspendedTransactions");
      mIdentifyPendingTransactions = info.GetBoolean("IdentifyPendingTransactions");
      mSuspendedInterval = info.GetDouble("SuspendedInterval");

			mServiceDefinitions = (MetraTech.Interop.MTBillingReRun.IMTCollection)
				info.GetValue("ServiceDefinitions", typeof(MetraTech.Collections.Collection));
			mProductViews = (MetraTech.Interop.MTBillingReRun.IMTCollection)
				info.GetValue("ProductViewDefinitions", typeof(MetraTech.Collections.Collection));

			// deserialize the account filter
			ArrayList accountFilterItems = (ArrayList)
				info.GetValue("AccountConditions", typeof(ArrayList));

			if (accountFilterItems.Count > 0)
			{
				mAccountConditions =
					(MetraTech.Interop.MTBillingReRun.IMTDataFilter)
					new MetraTech.Interop.Rowset.MTDataFilter();
					
				foreach (MetraTech.Pipeline.ReRun.FilterItem clone in accountFilterItems)
					mAccountConditions.Add(clone.PropertyName, clone.Operator, clone.Value);
			}
			else 
				mAccountConditions = null;

			mProductViewProps = (MetraTech.Interop.MTBillingReRun.IMTCollection)
				info.GetValue("ProductViewProps", typeof(MetraTech.Collections.Collection));

			mSvcDefProps = (MetraTech.Interop.MTBillingReRun.IMTCollection)
				info.GetValue("ServiceDefProps", typeof(MetraTech.Collections.Collection));

			mSessionIDs = (MetraTech.Interop.MTBillingReRun.IMTCollection)
				info.GetValue("SessionIDs", typeof(MetraTech.Collections.Collection));
		}

		public virtual void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			info.AddValue("BatchID", mBatchID);
			info.AddValue("IntervalID", mIntervalID);
			info.AddValue("BillingGroupID", mBillingGroupID);
			info.AddValue("BeginDateTime", mBeginDateTime);
			info.AddValue("BeginDateTimeSet", mBeginDateTimeSet);
			info.AddValue("EndDateTime", mEndDateTime);
			info.AddValue("EndDateTimeSet", mEndDateTimeSet);
			info.AddValue("ServiceDefinitions", mServiceDefinitions);
			info.AddValue("ProductViewDefinitions", mProductViews);
      info.AddValue("IdentifySuspendedTransactions", mIdentifySuspendedTransactions);
      info.AddValue("IdentifyPendingTransactions", mIdentifyPendingTransactions);
      info.AddValue("SuspendedInterval", mSuspendedInterval);

			// serialize the account filter
			ArrayList accountFilterItems = new ArrayList();
			if (mAccountConditions != null)
			{
				for (int i = 0; i < mAccountConditions.Count; i++)
				{
					MetraTech.Interop.MTBillingReRun.IMTFilterItem item =
						(MetraTech.Interop.MTBillingReRun.IMTFilterItem) mAccountConditions.get_Item(i);

					MetraTech.Pipeline.ReRun.FilterItem clone = new MetraTech.Pipeline.ReRun.FilterItem(item);
					accountFilterItems.Add(clone);
				}
			}
			info.AddValue("AccountConditions", accountFilterItems);

			info.AddValue("ProductViewProps", mProductViewProps);
			info.AddValue("ServiceDefProps", mSvcDefProps);
			info.AddValue("SessionIDs", mSessionIDs);
		}

		public string BatchID
		{		
			get
			{
				return mBatchID;
			}
			set
			{
				mBatchID = value;
			}
		}

		public int IntervalID
		{
			get
			{
				return mIntervalID;
			}
			set
			{
				mIntervalID = value;
			}
		}

		public int BillingGroupID
		{
			get
			{
				return mBillingGroupID;
			}
			set
			{
				mBillingGroupID = value;
			}
		}

		public MetraTech.Interop.MTBillingReRun.IMTCollection SessionIDs
		{
			get
			{
				return mSessionIDs;
			}
		}

		public void AddSessionID(string sessionID)
		{
			mSessionIDs.Add(sessionID);
		}

		public void AddServiceDefinition(string serviceDef)
		{
			mServiceDefinitions.Add(serviceDef);
		}
			
		public DateTime BeginDatetime
		{		
			get
			{
				Debug.Assert(mBeginDateTimeSet);
				return mBeginDateTime;
			}
			set
			{
				mBeginDateTimeSet = true;
				mBeginDateTime = value;
			}
		}

		public bool BeginDatetimeIsSet
		{		
			get
			{
				return mBeginDateTimeSet;
			}
		}

		public DateTime EndDatetime
		{		
			get
			{
				Debug.Assert(mEndDateTimeSet);
				return mEndDateTime;
			}
			set
			{
				mEndDateTimeSet = true;
				mEndDateTime = value;
			}
		}

    public double SuspendedInterval
    {
      get
      {
        return mSuspendedInterval;
      }
      set
      {
        mSuspendedInterval = value;
      }
    }

    public bool IsIdentifySuspendedTransactions
    {
      get 
      {
        return mIdentifySuspendedTransactions;
      }
      set
      {
        mIdentifySuspendedTransactions = value;
      }
    }

    public bool IsIdentifyPendingTransactions
    {
      get
      {
        return mIdentifyPendingTransactions;
      }
      set
      {
        mIdentifyPendingTransactions = value;
      }
    }
		public bool EndDatetimeIsSet
		{		
			get
			{
				return mEndDateTimeSet;
			}
		}

		public void AddUserDefinedProperty(string propName, string propValue)
		{
			Debug.Assert(false, "not implemented yet");
		}

		public MetraTech.Interop.MTBillingReRun.IMTCollection ServiceDefinitions
		{
			get
			{
				return mServiceDefinitions;
			}
		}

		public void AddProductView(string pvName)
		{
			mProductViews.Add(pvName);
		}

		public MetraTech.Interop.MTBillingReRun.IMTCollection ProductViews
		{
			get
			{
				return mProductViews;
			}
		}

		public MetraTech.Interop.MTBillingReRun.IMTDataFilter AccountConditions
		{
			get
			{
				return mAccountConditions;
			}
			set
			{
				mAccountConditions = value;
			}
		}

		public void AddProductViewProperty(string productViewName, string propName, object value)
		{
			IProductViewDefinition pvDef = GetProductViewDefinition(productViewName);
			if (!pvDef.Contains(propName))
				throw new ApplicationException(String.Format("Product definition {0} does not have a property named {1}",
																										 productViewName, propName));
			MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop =
				(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData) pvDef[propName];


			IMTFilterCondition condition = new FilterCondition();
			condition.EntityName = productViewName;
			condition.PropertyName = propName;
			condition.Value = value;
			mProductViewProps.Add(condition);
		}

		public void AddServiceDefinitionProperty(string svcDefName, string propName, object value)
		{
			IServiceDefinition svcDef = GetServiceDefinition(svcDefName);
			if (!svcDef.Contains(propName))
				throw new ApplicationException(String.Format("Service definition {0} does not have a property named {1}",
																										 svcDefName, propName));
			MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop =
				(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData) svcDef[propName];

			IMTFilterCondition condition = new FilterCondition();
			condition.EntityName = svcDefName;
			condition.PropertyName = propName;
			condition.Value = value;
			mSvcDefProps.Add(condition);
		}

		public MetraTech.Interop.MTBillingReRun.IMTCollection ServiceDefinitionProperties
		{
			get
			{
				return mSvcDefProps;
			}
		}

		public MetraTech.Interop.MTBillingReRun.IMTCollection ProductViewProperties
		{
			get
			{
				return mProductViewProps;
			}
		}

		public bool QueueMatchPossible
		{
			get
			{
	
				// at least one queue specific criteria must be set
				if ((ServiceDefinitions.Count > 0) ||
					(ServiceDefinitionProperties.Count > 0))
					return true;
				else
					return false;
			}
		}

		public bool IsOnlyBatchIDSet()
		{
			//special case when adapter is being reversed.
			if ((BatchID != null) && 
				(BatchID.Length != 0) &&
				(!BeginDatetimeIsSet) &&
				(!EndDatetimeIsSet) &&
				(ServiceDefinitions.Count == 0) &&
				(ServiceDefinitionProperties.Count == 0) &&
				(SessionIDs.Count == 0) &&
				(ProductViews.Count == 0) &&
				(ProductViewProperties.Count == 0) &&
				(IntervalID == -1) &&
				(AccountConditions == null) )
				return true;
			else
				return false;

		}

    public bool IsNoFilterSpecified()
    {
      	if ((BatchID == null) && 
				(!BeginDatetimeIsSet) &&
				(!EndDatetimeIsSet) &&
				(ServiceDefinitions.Count == 0) &&
				(ServiceDefinitionProperties.Count == 0) &&
				(SessionIDs.Count == 0) &&
				(ProductViews.Count == 0) &&
				(ProductViewProperties.Count == 0) &&
				(mIntervalID == -1) &&
				(mBillingGroupID == -1) &&
				(AccountConditions == null) &&
        (!IsIdentifySuspendedTransactions)&&
        (!IsIdentifyPendingTransactions))
          return true;
        else
          return false;

    }

		public bool IsFailedTransactionMatchPossible()
		{
			// if a filter contains product view, product view property, intervalid, account criteria, no match in t_failed_transaction
			// is possible.
			if ((ProductViews.Count != 0) ||
				(ProductViewProperties.Count != 0) ||
				(IntervalID != -1) ||
				((AccountConditions !=null) &&(AccountConditions.Count != 0))
				)
				return false;
			else
				return true;

		}
		private IServiceDefinition GetServiceDefinition(string name)
		{
			if (mSvcDefCollection == null)
				mSvcDefCollection = new ServiceDefinitionCollection();

			return mSvcDefCollection.GetServiceDefinition(name);
		}

		private IProductViewDefinition GetProductViewDefinition(string name)
		{
			if (mPVDefCollection == null)
				mPVDefCollection = new ProductViewDefinitionCollection();

			return mPVDefCollection.GetProductViewDefinition(name);
		}


		// NOTE: it's VERY important to serialize and deserialize all members here!
		// update the serialization code if you add a member variable!
		private string mBatchID;
		private int mIntervalID = -1;
		private int mBillingGroupID = -1;
		private DateTime mBeginDateTime;
		private bool mBeginDateTimeSet = false;
		private DateTime mEndDateTime;
		private bool mEndDateTimeSet = false;
    private bool mIdentifySuspendedTransactions = false;
    private bool mIdentifyPendingTransactions = false;
    private double mSuspendedInterval = 0.0;

		private MetraTech.Interop.MTBillingReRun.IMTCollection mServiceDefinitions =
			(MetraTech.Interop.MTBillingReRun.IMTCollection) new MetraTech.Collections.Collection();
		private MetraTech.Interop.MTBillingReRun.IMTCollection mProductViews =
			(MetraTech.Interop.MTBillingReRun.IMTCollection) new MetraTech.Collections.Collection();

		private MetraTech.Interop.MTBillingReRun.IMTDataFilter mAccountConditions;

		private MetraTech.Interop.MTBillingReRun.IMTCollection mProductViewProps =
			(MetraTech.Interop.MTBillingReRun.IMTCollection) new MetraTech.Collections.Collection();
		private MetraTech.Interop.MTBillingReRun.IMTCollection mSvcDefProps =
			(MetraTech.Interop.MTBillingReRun.IMTCollection) new MetraTech.Collections.Collection();
		private MetraTech.Interop.MTBillingReRun.IMTCollection mSessionIDs =
			(MetraTech.Interop.MTBillingReRun.IMTCollection) new MetraTech.Collections.Collection();

		private ServiceDefinitionCollection mSvcDefCollection;
		private ProductViewDefinitionCollection mPVDefCollection;
	}


}

