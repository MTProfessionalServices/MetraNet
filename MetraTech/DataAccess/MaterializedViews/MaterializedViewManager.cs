/**************************************************************************
* Copyright 2005 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* $Header$
* 
***************************************************************************/

// Depend on namespaces
using System;
using System.EnterpriseServices;
using System.Collections;
using System.Runtime.InteropServices;
using MetraTech;
using MetraTech.Xml;
using MetraTech.DataAccess;
using MetraTech.Interop.RCD;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

// Materialized View Manager class definition.
namespace MetraTech.DataAccess.MaterializedViews
{
	using MetraTech.Collections;
	using MetraTech.Pipeline;

	[ComVisible(true)]
	[Guid("8EDD51B1-F9CD-4982-9835-76D7BDCB8282")]
	public interface IManager
	{
		/// <summary>
		/// Initialize Materialized View Manager
		/// Must call before calling any other method.  
		/// </summary>
		void Initialize();

		/// <summary>
		/// Get queries used to insert into the Materialized View given a base table list.  
		/// </summary>
		/// <param name="TriggerList"></param>
		/// <returns></returns>
		string GetMaterializedViewInsertQuery(string[] TriggerList);

		/// <summary>
		/// Get queries used to update the Materialized View given a base table list. 
		/// </summary>
		/// <param name="TriggerList"></param>
		/// <returns></returns>
		string GetMaterializedViewUpdateQuery(string[] TriggerList);

		/// <summary>
		/// Get queries used to backout data from a materialized view.
		/// </summary>
		/// <param name="TriggerList"></param>
		/// <returns></returns>
		string GetMaterializedViewBackoutQuery(string[] TriggerList);

		/// <summary>
		/// Get a list of base table for materialized views that will be triggerd 
		/// given the trigger list. 
		/// </summary>
		/// <param name="TriggerList"></param>
		/// <returns></returns>
		string[] GetMaterializedViewBaseTables(string[] TriggerList);

		/// <summary>
		/// Enable/Disable materalized view cache.
		/// </summary>
		/// <param name="bEnable"></param>
		void EnableCache(bool bEnable);

		/// <summary>
		/// Run full update for specified materialized view.
		/// </summary>
		/// <param name="MaterializedViewName"></param>
		void DoFullMaterializedViewUpdate(string MaterializedViewName);

		/// <summary>
		/// Run full update on all specified materialized view.
		/// </summary>
		void DoFullMaterializedViewUpdateAll();

		/// <summary>
		/// Run materialized view update on all deferred materialized views.
		/// </summary>
		void UpdateAllDeferredMaterializedViews();

		/// <summary>
		/// Update a single materialized view in deferred mode.
		/// </summary>
		/// <param name="MaterializedViewName"></param>
		void UpdateDeferredMaterializedView(string MaterializedViewName);

		/// <summary>
		/// Find and process all materialized view configuration files,
		/// populate the catalog tables with configuration data, and
		/// update materialized view table where applicable.
		/// </summary>
		void UpdateMaterializedViewConfiguration();

		/// <summary>
		/// Add a binding for insert operations. 
		/// </summary>
		/// <param name="BaseTableName"></param>
		/// <param name="BaseTableDeltaName"></param>
		void AddInsertBinding(string BaseTableName, string BaseTableDeltaName);

		/// <summary>
		/// Add a binding for delete operations. 
		/// </summary>
		/// <param name="BaseTableName"></param>
		/// <param name="BaseTableDeltaName"></param>
		void AddDeleteBinding(string BaseTableName, string BaseTableDeltaName);

		/// <summary>
		/// Generate a transactional insert delta table name based on base table name.
		/// </summary>
		/// <param name="BaseTableName"></param>
		/// <returns></returns>
		string GenerateDeltaInsertTableName(string BaseTableName);

		/// <summary>
		/// Generate a transactional delete delta table name based on base table name.
		/// </summary>
		/// <param name="BaseTableName"></param>
		/// <returns></returns>
		string GenerateDeltaDeleteTableName(string BaseTableName);

		/// <summary>
		/// Is support for MetraView enabled?
		/// This includes WriteProductView and Adjustments.
		/// </summary>
		bool IsMetraViewSupportEnabled
		{
			get;
		}
	}

	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("370E8239-A95B-4602-9323-AEB259719C51")]
	public class Manager : IManager
	{
		// Enum for type of MaterializedView update operations.
		public enum Operation
		{
			Insert,
			Delete,
			Update,
			Deferred 
		};

		// Class constructor.
		public Manager()
		{
			mLogger = new Logger ("[MaterializedViewManager]");	
			mQueryPath = "Queries\\MaterializedViews";
			mbCacheEnabled = false;
			mQueryCache = new Hashtable();
			mIsMetraViewSupportEnabled = false;
			mConfig = null;
			mBindings = null;
		}

		// Initialize Materialized View Manager
		// Must call before calling any other method.
		public void Initialize()
		{
			// Get stage database name.
			ConnectionInfo ciStageDb = new ConnectionInfo("NetMeterStage");
			mNetMeterStageName = ciStageDb.Catalog;

			mBindings = new Bindings();
			mQueryAdapter = new QueryAdapter.MTQueryAdapter();
			mQueryAdapter.Init("Queries\\MaterializedViews");
			mPipelineManager = new PipelineManager();

			// Determine if MetraView support is enabled.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetDatabaseProperty"))
                {
                    stmt.AddParam("property", MTParameterType.String, "DATAMART");
                    stmt.AddOutputParam("value", MTParameterType.String, 5);
                    stmt.AddOutputParam("status", MTParameterType.Integer);
                    stmt.ExecuteNonQuery();
                    int status = (int)stmt.GetOutputValue("status");
                    if (status == -99)
                    {
                        mLogger.LogInfo("Materialized view framework did not find DATAMART property in t_db_values table.");
                        mIsMetraViewSupportEnabled = false;
                    }
                    else
                    {
                        string Value = (string)stmt.GetOutputValue("value");
                        mIsMetraViewSupportEnabled = (String.Compare(Value, "true", true) == 0);
                    }
                }
            }
		}

		// Get the query that will insert into the Materialized View given a trigger list.
		public string GetMaterializedViewInsertQuery(string[] TriggerList)
		{
			mLogger.LogDebug("Starting get insert query");
			string QueriesToExecute = GetMaterializedViewQuery(TriggerList, Operation.Insert, null);
            if (QueriesToExecute != null && QueriesToExecute.Length > 0)
            {
                mQueryAdapter.Init(mQueryPath);
                mQueryAdapter.SetQueryTag("__EXECUTE_BLOCK_QUERY__");
                mQueryAdapter.AddParam("%%EXECUTE_QUERY%%", QueriesToExecute, true);

                mLogger.LogDebug("End get insert query");
				return "begin " + mQueryAdapter.GetQuery() + " end;";
            }
			return null;
		}

		// Get the query that will update the Materialized View given a trigger list.
		public string GetMaterializedViewUpdateQuery(string[] TriggerList)
		{
			mLogger.LogDebug("Starting get update query");
			string QueriesToExecute = GetMaterializedViewQuery(TriggerList, Operation.Update, null);
			if (QueriesToExecute != null && QueriesToExecute.Length > 0)
			{
				mQueryAdapter.Init(mQueryPath);
				mQueryAdapter.SetQueryTag("__EXECUTE_BLOCK_QUERY__");
				mQueryAdapter.AddParam("%%EXECUTE_QUERY%%", QueriesToExecute, true);

				mLogger.LogDebug("End get update query");
				return "begin " + mQueryAdapter.GetQuery() + " end;";
			}
			return null;
		}

		// Backout the Materialized View given a table name.
		public string GetMaterializedViewBackoutQuery(string[] TriggerList)
		{
			mLogger.LogDebug("Starting get delete query");
			string QueriesToExecute = GetMaterializedViewQuery(TriggerList, Operation.Delete, null);
			if (QueriesToExecute != null && QueriesToExecute.Length > 0)
			{
				mQueryAdapter.Init(mQueryPath);
				mQueryAdapter.SetQueryTag("__EXECUTE_BLOCK_QUERY__");
				mQueryAdapter.AddParam("%%EXECUTE_QUERY%%", QueriesToExecute, true);

				mLogger.LogDebug("End get delete query");
				return "begin " + mQueryAdapter.GetQuery() + " end;";
			}
			return null;
		}

		// Get a list of base table for materialized views that will be triggerd 
		// given the trigger list. 
        public string[] GetMaterializedViewBaseTables(string[] TriggerList)
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                // Construct a comma delimited string of triggers, use to determine the
                // dependency chain.
                string DelimittedTriggerList = null;
                for (int i = 0; i < TriggerList.Length; i++)
                {
                    if (DelimittedTriggerList != null)
                        DelimittedTriggerList += ", ";

                    DelimittedTriggerList += "'" + TriggerList[i].ToLower() + "'";
                }

                mLogger.LogDebug("Materialized view dependency trigger list: " + DelimittedTriggerList);

                // Prepare statement to execute.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_BASE_TABLES__"))
                {
                    stmt.AddParam("%%TABLE_NAME_LIST%%", DelimittedTriggerList, true);

                    // Execute and loop through result set.
                    ArrayList BaseTablesArray = new ArrayList();
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        try
                        {
                            // Get the base table names.
                            while (reader.Read())
                                BaseTablesArray.Add(reader.GetString("base_table_name"));

                            // Construct return params.
                            if (BaseTablesArray.Count == 0)
                                return null;

                            int i = 0;
                            string[] BaseTablesResult = new string[BaseTablesArray.Count];
                            foreach (string name in BaseTablesArray)
                                BaseTablesResult[i++] = name;

                            return BaseTablesResult;
                        }
                        catch (Exception e)
                        {
                            string msg = "Failed to get base table information given the following triggers: " + DelimittedTriggerList;
                            msg += ", error: " + e.Message;
                            throw new Exception(msg);
                        }
                    }
                }
            }
        }

		// Get queries used to update materialized views in DEFERRED mode.
		public void UpdateAllDeferredMaterializedViews()
		{
			UpdateDeferredMaterializedView(null);
		}

		// Execute deferred queries for a specified materialized view.
		// If null the update all deferred MV's.
		public void UpdateDeferredMaterializedView(string MaterializedViewName)
		{
			try
			{
				// Execute Deferred update query.
				using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
				{
					// Get queries to execute.
					string QueriesToExecute = GetDeferredQuery(conn, MaterializedViewName);
					if (QueriesToExecute != null)
					{
						if (MaterializedViewName == null)
							mLogger.LogInfo("Start deferred update of all Materialized Views");
						else
							mLogger.LogInfo("Start deferred Materialized View(" + MaterializedViewName + ") update");

						// Adjustments can be made while the pipeline is stopped.
						// Take a lock on adjustment table.
            mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
						mQueryAdapter.AddParam("%%TABLE_NAME%%", "t_adjustment_transaction", true);
						QueriesToExecute = mQueryAdapter.GetQuery() + QueriesToExecute;

						// Execute the queries.
                        using (IMTStatement stmtNQ = conn.CreateStatement("begin " + QueriesToExecute + " end;"))
                        {
                            stmtNQ.ExecuteNonQuery();
                        }

						// Commit the work.
						conn.CommitTransaction();
						
						if (MaterializedViewName == null)
							mLogger.LogInfo("Finished deferred update of all Materialized Views");
						else
							mLogger.LogInfo("Finished deferred Materialized View(" + MaterializedViewName + ") update.");
					}
				}
			}
			catch (Exception e)
			{
				// Log error.
				if (MaterializedViewName != null)
					mLogger.LogError("UpdateDeferredMaterializedView(" + MaterializedViewName + ") failed with error: " + e.ToString());
				else
					mLogger.LogError("UpdateDeferredMaterializedView failed with error: " + e.ToString());
				throw e;
			}
		}

		// Ge the query for specified MV. IF MV name is null then do all.
		public string GetDeferredQuery(IMTConnection conn, string MaterializedViewName)
		{
			mLogger.LogDebug("Starting deferred operation");

      // Query used to truncate all the delta tables.
      string TruncateDeltaTablesQuery = String.Empty;

			// Determine which materialized views run in deferred mode.
			ArrayList DeferredMVs = new ArrayList();
            if (MaterializedViewName == null)
            {
                MaterializedViewName = String.Empty;
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_NAMES__"))
                {
                    stmt.AddParam("%%UPDATE_MODE%%", "D", true); // DEFERRED mode only
                    stmt.AddParam("%%NOT%%", "", true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string name = reader.GetString("name");
                            DeferredMVs.Add(name);

                            if (MaterializedViewName.Length > 0)
                                MaterializedViewName += ", ";
                            MaterializedViewName += name;

                            string tableName = reader.GetString("table_name");

                            // CR 15773 - Add the mv tables to the truncate query
                            // Truncate the materialized view delta tables.
                            mQueryAdapter.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
                            mQueryAdapter.AddParam("%%DELTA_INSERT_TABLE_NAME%%", Bindings.GetInsertDeltaTableName(tableName), true);
                            mQueryAdapter.AddParam("%%DELTA_DELETE_TABLE_NAME%%", Bindings.GetDeleteDeltaTableName(tableName), true);
                            TruncateDeltaTablesQuery += mQueryAdapter.GetQuery() + "\n";
                        }
                    }
                }

                // Any materialized views found?
                if (MaterializedViewName.Length == 0)
                {
                    mLogger.LogDebug("No materialized views found, nothing todo in deffered mode.");
                    return null;
                }
            }
            else
            {
                // Get a list of MV's that deferred MV's depend on.
                // This is the list of MV's that we must process to get the deferred result.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_DEPENDENTS__"))
                {
                    stmt.AddParam("%%TABLE_NAME_LIST%%", "'" + Bindings.GetMVTableName(MaterializedViewName) + "'", true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                            DeferredMVs.Add(reader.GetString("mv_name"));
                    }
                }
                // Validate that this is actually a materialized view.
                // If this is a real materialized view then there will be at least one dependant, itself.
                if (DeferredMVs.Count == 0)
                {
                    string msg = "Materialized View(" + MaterializedViewName + ") is not found.";
                    mLogger.LogError(msg);
                    throw new Exception(msg);
                }

                // CR 15773 - Add the mv tables to the truncate query
                foreach (string dmv in DeferredMVs)
                {
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_INFO_FROM_CATALOG__"))
                    {
                        stmt.AddParam("%%MV_NAME%%", dmv, true); // DEFERRED mode only
                        using (IMTDataReader reader1 = stmt.ExecuteReader())
                        {
                            while (reader1.Read())
                            {
                                string tableName = reader1.GetString("table_name");

                                mQueryAdapter.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
                                mQueryAdapter.AddParam("%%DELTA_INSERT_TABLE_NAME%%", Bindings.GetInsertDeltaTableName(tableName), true);
                                mQueryAdapter.AddParam("%%DELTA_DELETE_TABLE_NAME%%", Bindings.GetDeleteDeltaTableName(tableName), true);
                                TruncateDeltaTablesQuery += mQueryAdapter.GetQuery() + "\n";
                            }
                        }
                    }
                }
            }

			// Log all the materialized views that will be processed by this scheduled adapter.
			mLogger.LogDebug("Materialized views to process in DEFERRED mode: {0}", MaterializedViewName);

			//xxx TODO: Optimize: write stored procedure that returns a list of used delta tables.
			//-----
			// Setup triggers.
			// Find all base tables for which there is data in the persistent delta tables.
			// Get a list of base tables that the deferred materialized view depend on.
			// Using this list we can weed out table with data from those without data
			// and that will be our trigger list.
			//-----
			ArrayList AllReferencedBaseTables = new ArrayList();
			foreach (string MVName in DeferredMVs)
			{
				string BaseTableName;

				// Get the list of BaseTables from the materialized view catalog tables.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_BASE_TABLE_NAMES__"))
                {
                    stmt.AddParam("%%MATERIALIZED_VIEW_NAME%%", MVName, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            BaseTableName = reader.GetString("base_table_name");
                            if (!AllReferencedBaseTables.Contains(BaseTableName))
                                AllReferencedBaseTables.Add(BaseTableName);
                        }
                    }
                }

				// Add binding for any referenced transactional materialized views.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_REFERENCED_TRANSACTIONAL_MATERIALIZED_VIEWS__"))
                {
                    stmt.AddParam("%%MATERIALIZED_VIEW_NAME%%", MVName, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            BaseTableName = reader.GetString("base_table_name");

                            // Prepare query to truncate materialize view delta tables.
                            mQueryAdapter.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
                            mQueryAdapter.AddParam("%%DELTA_INSERT_TABLE_NAME%%", Bindings.GetInsertDeltaTableName(BaseTableName), true);
                            mQueryAdapter.AddParam("%%DELTA_DELETE_TABLE_NAME%%", Bindings.GetDeleteDeltaTableName(BaseTableName), true);
                            TruncateDeltaTablesQuery += mQueryAdapter.GetQuery() + "\n";

                            // Add bindings for all the referenced materialized views.
                            AddInsertBinding(BaseTableName, Bindings.GetInsertDeltaTableName(BaseTableName));
                            AddDeleteBinding(BaseTableName, Bindings.GetDeleteDeltaTableName(BaseTableName));
                        }
                    }
                }
			}

			// Determine which tables have data.
			ArrayList ReferencedBaseTablesWithData = new ArrayList();
			if (AllReferencedBaseTables.Count > 0)
			{
				// Find tables with data.
				foreach (string BaseTable in AllReferencedBaseTables)
				{
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__IS_TABLE_EMPTY__"))
                    {
                        stmt.AddParam("%%DELTA_INSERT_TABLE_NAME%%",
                            Bindings.GetInsertDeltaTableName(BaseTable), true);
                        stmt.AddParam("%%DELTA_DELETE_TABLE_NAME%%",
                            Bindings.GetDeleteDeltaTableName(BaseTable), true);
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                if (reader.GetBoolean("empty") == false)
                                    ReferencedBaseTablesWithData.Add(BaseTable);
                            }
                        }
                    }
				}
			}

			// Do we have any triggers?
			if (ReferencedBaseTablesWithData.Count > 0)
			{
				// Populate trigger list and truncate query.
				int i = 0;
				string[] Triggers = new string[ReferencedBaseTablesWithData.Count];
				foreach (string BaseTableName in ReferencedBaseTablesWithData)
				{
					Triggers[i++] = BaseTableName;

					// Truncate the base table delta tables.
					mQueryAdapter.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
					mQueryAdapter.AddParam("%%DELTA_INSERT_TABLE_NAME%%", Bindings.GetInsertDeltaTableName(BaseTableName), true);
					mQueryAdapter.AddParam("%%DELTA_DELETE_TABLE_NAME%%", Bindings.GetDeleteDeltaTableName(BaseTableName), true);
					TruncateDeltaTablesQuery += mQueryAdapter.GetQuery() + "\n";

					// Add bindings for all the referenced base tables.
					AddInsertBinding(BaseTableName, Bindings.GetInsertDeltaTableName(BaseTableName));
					AddDeleteBinding(BaseTableName, Bindings.GetDeleteDeltaTableName(BaseTableName));
				}

				// Get update queries to execute.
				string QueriesToExecute = GetMaterializedViewQuery(Triggers, Operation.Deferred, conn);

				//-----
				// Asseble result query.
				//-----
				if (QueriesToExecute != null && QueriesToExecute.Length > 0)
				{
					// Now get the query.
					string ResultQuery = QueriesToExecute;

					// Append truncate table queries.
					if (TruncateDeltaTablesQuery.Length > 0)
					{
						ResultQuery += "\n";
						ResultQuery += TruncateDeltaTablesQuery;
					}

					mQueryAdapter.Init(mQueryPath);
					mQueryAdapter.SetQueryTag("__EXECUTE_BLOCK_QUERY__");
					mQueryAdapter.AddParam("%%EXECUTE_QUERY%%", ResultQuery, true);
				
					// Return query.
					mLogger.LogDebug("Returning deferred queries to caller");
					return mQueryAdapter.GetQuery();
				}

				return null;
			}
			else
				mLogger.LogDebug("No deferred materialized views found for which there is data. Nothing to do.");

			return null;
		}
		
		// Enable/Disable materalized view cache.
		public void EnableCache(bool bEnable)
		{
			// Materialized view info cache.
			mbCacheEnabled = bEnable;
			if (mbCacheEnabled)
				mMaterializedViews = new Hashtable();
		}

		// Run full update for specified materialized view.
		public void DoFullMaterializedViewUpdate(string MaterializedViewName)
		{
			// Check that materialized view support is enabled.
			if (!mIsMetraViewSupportEnabled)
			{
				mLogger.LogInfo("Materialized view support is disabled.");
				return;
			}

			// Check if pipeline is running, we may not execute full update if pipeline is running.
			if (mPipelineManager.IsRunning)
			{
				string msg = "The pipeline may be running. Executing full update for Materialized View(" + MaterializedViewName + ") anyway.";
				mLogger.LogWarning(msg);
			}

			mLogger.LogInfo("Starting Materialized View(" + MaterializedViewName + ") Full Update.");
			try
			{
				// Get a connection to the database.
				using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
				{
					// Get the dependency chain for this materialized view.
					MaterializedViewCollection MViewCollection = GetDependantMaterializedViews(conn, "'" +
						Bindings.GetMVTableName(MaterializedViewName) + "'");
			
					// Get the materialized view.
					MaterializedView mv = MViewCollection.FindByName(MaterializedViewName);
					if (mv == null)
						throw new Exception("Materialized View(" + MaterializedViewName + ") not found.");

						// Check if materialized view is enabled.
					else if (mv.UpdateMode == MaterializedViewDefinition.Mode.OFF)
					{
						mLogger.LogDebug("Materialized View(" + MaterializedViewName + ") is turned off.  Nothig to do.");
						return;
					}

					// Loop through all the dependent materialized views that need to be updated.
					string FullQuery = String.Empty;
					string InitQuery = String.Empty;
					foreach(MaterializedView mvC in MViewCollection)
					{
						// Skip disabled materialized views.
						if (mvC.UpdateMode == MaterializedViewDefinition.Mode.OFF)
						{
							mLogger.LogDebug("Dependant Materialized View(" + mvC.Name + ") is skipped because it is turned off.");
							continue;
						}
							
						// Separate the queries with blank lines.
						if (InitQuery.Length > 0)
							InitQuery += "\n";
						if (FullQuery.Length > 0)
							FullQuery += "\n";
						
						// Get Full Update query and subsitute tags.
						InitQuery += mvC.GetInitQuery();
						FullQuery += mvC.GetFullUpdateQuery(mQueryAdapter, mNetMeterStageName);
					}
					
					// Execute Init query.
					if (InitQuery.Length > 0)
					{
						mLogger.LogDebug("Execute Materialized View(" + MaterializedViewName + ") init queries");
						using (IMTNonServicedConnection conn2 = ConnectionManager.CreateNonServicedConnection())
						{
                            using (IMTStatement stmtNQ = conn2.CreateStatement("begin " + InitQuery + " end;"))
                            {
                                stmtNQ.ExecuteNonQuery();
                            }

							conn2.CommitTransaction();
						}
					}

					// Execute Full Upadate query.
					if (FullQuery.Length > 0)
					{
						mLogger.LogDebug("Execute Materialized View(" + MaterializedViewName + ") full update queries");

						// Adjustments can be made while the pipeline is stopped.
						// Take a lock on adjustment table.
                        mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
						mQueryAdapter.AddParam("%%TABLE_NAME%%", "t_adjustment_transaction", true);
						FullQuery = mQueryAdapter.GetQuery() + FullQuery;

						// Execute queries.
                        using (IMTStatement stmtNQ = conn.CreateStatement("begin " + FullQuery + " end;"))
                        {
                            stmtNQ.ExecuteNonQuery();
                        }

						// Commit the work.
						conn.CommitTransaction();
						mLogger.LogInfo("Finished full Materialized View(" + MaterializedViewName + ") update.");
					}
				}
			}
			catch(System.Exception ex)
			{
				mLogger.LogError(ex.ToString());
				throw ex;
			}
		}

		// Run full update on all materialized view.
		public void DoFullMaterializedViewUpdateAll()
		{
			// Check that materialized view support is enabled.
			if (!mIsMetraViewSupportEnabled)
			{
				mLogger.LogInfo("Materialized view support is disabled.");
				return;
			}

			// Check if pipeline is running, we may not execute full update if pipeline is running.
			if (mPipelineManager.IsRunning)
			{
				string msg = "The pipeline maybe running. Executing full update on all Materialized Views anyway.";
				mLogger.LogWarning(msg);
			}

			mLogger.LogInfo("Starting Full Update on all enabled Materialized Views.");
			try
			{
				// Get a connection to the database.
				using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
				{
					// Get list of all enabled MV's.
					string MaterializedViewsTablesToUpdate = String.Empty;
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_TABLE_NAMES__"))
                    {
                        stmt.AddParam("%%NOT%%", "NOT", true);
                        stmt.AddParam("%%UPDATE_MODE%%", "O", true); // Not OFF mode
                        using (IMTDataReader reader = stmt.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (MaterializedViewsTablesToUpdate.Length > 0)
                                    MaterializedViewsTablesToUpdate += ", ";
                                MaterializedViewsTablesToUpdate += "'" + reader.GetString("Table_name") + "'";
                            }
                        }
                    }

					// Get the dependency chain for this materialized view.
					MaterializedViewCollection MViewCollection = GetDependantMaterializedViews(conn, MaterializedViewsTablesToUpdate);

					// Loop through all the dependent materialized views that need to be updated.
					string FullQuery = String.Empty;
					string InitQuery = String.Empty;
					foreach(MaterializedView mv in MViewCollection)
					{
						// Skip disabled materialized views.
						if (mv.UpdateMode == MaterializedViewDefinition.Mode.OFF)
						{
							mLogger.LogDebug("Dependant Materialized View(" + mv.Name + ") is skipped because it is turned off.");
							continue;
						}
							
						// Separate the queries with blank lines.
						if (InitQuery.Length > 0)
							InitQuery += "\n";
						if (FullQuery.Length > 0)
							FullQuery += "\n";
						
						// Get Full Update query and subsitute tags.
						InitQuery += mv.GetInitQuery();
						FullQuery += mv.GetFullUpdateQuery(mQueryAdapter, mNetMeterStageName);
					}

					// Execute init query.
					if (InitQuery.Length > 0)
					{
						mLogger.LogDebug("Execute init queries");
						using (IMTNonServicedConnection conn2 = ConnectionManager.CreateNonServicedConnection())
						{
                            using (IMTStatement stmtNQ = conn2.CreateStatement("begin " + InitQuery + " end;"))
                            {
                                stmtNQ.ExecuteNonQuery();
                            }

							conn2.CommitTransaction();
						}
					}

					// Execute Full Upadate query.
					if (FullQuery.Length > 0)
					{
						mLogger.LogDebug("Execute full update queries");

						// Adjustments can be made while the pipeline is stopped.
						// Take a lock on adjustment table.
            mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
						mQueryAdapter.AddParam("%%TABLE_NAME%%", "t_adjustment_transaction", true);
						FullQuery = mQueryAdapter.GetQuery() + FullQuery;

						// Execute queries.
                        using (IMTStatement stmtNQ = conn.CreateStatement("begin " + FullQuery + " end;"))
                        {
                            stmtNQ.ExecuteNonQuery();
                        }

						// Commit the work.
						conn.CommitTransaction();
						mLogger.LogInfo("Finished full update of all Materialized Views.");
					}
				}
			}
			catch(System.Exception ex)
			{
				mLogger.LogError(ex.ToString());
				throw ex;
			}
		}

		// Update materialized view configurations.
		public void UpdateMaterializedViewConfiguration()
		{
			// Check if pipeline is running, we may not execute full update if pipeline is running.
			if (mPipelineManager.IsRunning)
				mLogger.LogWarning("The pipeline may be running. Executing materialized view configuration update anyway.");

			if (mConfig == null)
				mConfig = new Configuration();
			
			try
			{
				// Update the materialized views configurations.
				mLogger.LogInfo("Starting Materialized View configuration update.");
				using (IMTNonServicedConnection conn = ConnectionManager.CreateNonServicedConnection())
				{
					bool bOldMVEnabled = mIsMetraViewSupportEnabled;
					mLogger.LogInfo("Materialized Views support is " + (bOldMVEnabled ? "enabled." : "disabled."));

					// Read configuration file.
					if (!ReadConfigFile(out mIsMetraViewSupportEnabled))
						mLogger.LogError("Failed to read materialized view configuration file.");

					// Update the database properties table to reflect the enabled status
					// of the Materialized View feature.
					mConfig.SetMaterializedViewEnabledProperty(conn, mIsMetraViewSupportEnabled);

					// Log what was done to materialized view enabled state.
					if (bOldMVEnabled && !mIsMetraViewSupportEnabled)
						mLogger.LogInfo("Materialized View support was disabled.");
					else if (!bOldMVEnabled && mIsMetraViewSupportEnabled)
						mLogger.LogInfo("Materialized View support was enabled.");

					// If materialized view is disabled no need to do further processing.
					if (!mIsMetraViewSupportEnabled)
					{
						// Commit work.
						conn.CommitTransaction();
						return;
					}

					// Update configuration.
					string MaterializedViewsToFullUpdate = null;
					mConfig.UpdateConfiguration(conn, this, out MaterializedViewsToFullUpdate);

					// Execute full update if there are any new tables to update.
					if (MaterializedViewsToFullUpdate != null &&
						MaterializedViewsToFullUpdate.Length > 0)
					{
						// Get the dependency chain for this materialized view.
						MaterializedViewCollection MViewCollection = 
							GetDependantMaterializedViews(conn, MaterializedViewsToFullUpdate);

						// Build full update query.
						string InitQuery = String.Empty;
						string FullQuery = String.Empty;
						foreach(MaterializedView mv in MViewCollection)
						{
							// Skip disabled materialized views.
							if (mv.UpdateMode == MaterializedViewDefinition.Mode.OFF)
							{
								mLogger.LogDebug("Dependant Materialized View(" + mv.Name + ") is skipped because it is turned off.");
								continue;
							}
						
							// Separate the queries with blank lines.
							if (InitQuery.Length > 0)
								InitQuery += "\n";
							if (FullQuery.Length > 0)
								FullQuery += "\n";
					
							// Get Full Update query and subsitute tags.
							InitQuery += mv.GetInitQuery();
							FullQuery += mv.GetFullUpdateQuery(mQueryAdapter, mNetMeterStageName);
						}

						// Execute init query.
						if (InitQuery.Length > 0)
						{
							mLogger.LogInfo("Execute Materialized View init queries");
							using (IMTNonServicedConnection conn2 = ConnectionManager.CreateNonServicedConnection())
							{
                                using (IMTStatement stmtNQ = conn2.CreateStatement("begin " + InitQuery + " end;"))
                                {
                                    stmtNQ.ExecuteNonQuery();
                                }

								conn2.CommitTransaction();
							}
						}

						// Execute Full Update query.
						if (FullQuery.Length > 0)
						{
							mLogger.LogInfo("Start full Materialized View update");

							// Adjustments can be made while the pipeline is stopped.
							// Take a lock on adjustment table.
              mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
							mQueryAdapter.AddParam("%%TABLE_NAME%%", "t_adjustment_transaction", true);
							FullQuery = mQueryAdapter.GetQuery() + FullQuery;

							// Execute queries
                            using (IMTStatement stmtNQ = conn.CreateStatement("begin " + FullQuery + " end;"))
                            {
                                stmtNQ.ExecuteNonQuery();
                            }

							mLogger.LogInfo("Finished full Materialized View update");
						}
					}

					// Commit work.
					conn.CommitTransaction();
				}
			}
			catch(System.Exception ex)
			{
				mLogger.LogError(ex.ToString());
				throw ex;
			}
		}

		// Is support for MetraView enabled?
		public bool IsMetraViewSupportEnabled
		{
			get { return mIsMetraViewSupportEnabled; }
		}

		// Add bindings.
		public void AddInsertBinding(string BaseTableName, string BaseTableDeltaName)
		{
			mBindings.AddInsertBinding(BaseTableName, BaseTableDeltaName);
		}
		public void AddDeleteBinding(string BaseTableName, string BaseTableDeltaName)
		{
			mBindings.AddDeleteBinding(BaseTableName, BaseTableDeltaName);
		}

		public string GenerateDeltaInsertTableName(string BaseTableName)
		{
			return mBindings.GetTransactionalInsertTableName(BaseTableName);
		}

		public string GenerateDeltaDeleteTableName(string BaseTableName)
		{
			return mBindings.GetTransactionalDeleteTableName(BaseTableName);
		}

		// Remove comments from SQL query.
		public static string StripComments(string query)
		{
			// Strip comment in form of "-- comment \r\n" or "/* comment */"
			string strNewQuery = String.Empty;
			string strEOL = "\r\n";
			char[] eol = strEOL.ToCharArray();
			int nIndex = -1;
			bool bMultiLineComment = false;
			while (true)
			{
				// Determine if this is a single or multi line comment.
				nIndex = query.IndexOf("--");
				int nTmpIndex = query.IndexOf("/*");
				if (nTmpIndex < nIndex && nTmpIndex != -1 || nIndex == -1)
				{
					bMultiLineComment = true;
					nIndex = nTmpIndex;
				}
				else
					bMultiLineComment = false;

				// Are we done yet?
				if (nIndex == -1)
					break;

				// Append portion before the comment.
				strNewQuery += query.Substring(0, nIndex);

				// Skip the comment.
				int nEOL = (bMultiLineComment) ? query.IndexOf("*/", nIndex) + 2
					: query.IndexOfAny(eol, nIndex) + 1;
				query = query.Substring(nEOL, query.Length - nEOL);
			}

			// Catch remainder of query and return.
			strNewQuery += query;

			// Strip extra linefeeds.
			strNewQuery = strNewQuery.Replace("\n\n", "\n");
			return strNewQuery;
		}

		// Update all the materialized views that change based on the set of changed basetables.
		private string GetMaterializedViewQuery(string[] TriggerList, Operation op,	IMTConnection conn)
		{
			// Return value; string containing all the queries to execute.
			string UpdateMaterializedViewQuery = String.Empty;

			// Query to execute to initialize all materialized view resources.
			string InitializeMaterializedViewQuery = String.Empty;

			// Query to execute to release the materialized view resources.
			string ReleaseMaterializedViewQuery = String.Empty;

			// Query to execute to move data from transactional delta table to persistent tables.
			string CopyDeltaQueries = String.Empty;

			// Query to lock the delta tables while pefroming a deferred operation.
			string LockDeltaTablesQueries = String.Empty;

            // ESR-6006 a port of ESR-5598 
            // Query to update the t_mv_payer_interval and t_mv_payee_session tables while doing an update
            string UpdatePayerAndPayeeTablesQueries = String.Empty;


      // Reversing changes made for CR 15061
      // Bae tables to lock to avois race condition from multiple pipelines.
      // string LockBaseTablesQueries = String.Empty;

      // Create transactional delta tables in a separate transaction.
			string CreateDeltaTablesQueries = String.Empty;

			// Construct a comma delimited string of triggers, use to determine the
			// dependency chain.
			string DelimittedTriggerList = null;
			for (int i = 0; i < TriggerList.Length; i++)
			{
				if (DelimittedTriggerList != null)
					DelimittedTriggerList += ", ";

				DelimittedTriggerList += "'" + TriggerList[i] + "'";
			}

			// Get a collection of datamarts that depend on this table.
			MaterializedViewCollection MViewCollection;
			if (conn == null)
			{
				using (IMTConnection conn2 = ConnectionManager.CreateConnection())
					MViewCollection = GetDependantMaterializedViews(conn2, DelimittedTriggerList);
			}
			else
				MViewCollection = GetDependantMaterializedViews(conn, DelimittedTriggerList);

			// If no dependents found return.
			if (MViewCollection.Count == 0)
			{
				mLogger.LogDebug("No materialized views found to update.");
				return null;
			}

			//-----
			// During metering we may copy some data to persistent delta tables.
			// We do this for each deferred materialized view and for transactional 
			// materialized views referenced by deferred materialized views.
			// For these cases we copy transactional information for each base table.
			// Some materialized views depend on same base tables, like t_acc_usage.
			// When processing a deferred operation instead of copying we take locks on 
			// the tables. To avoid copying or locking the same objects more than once
			// we need to keep track of what's done, hence, the following arrays.
			//-----
			ArrayList CreateDeltaTables = new ArrayList();
			ArrayList LockDeltaTables = new ArrayList();
			ArrayList CopiedDeltaTables = new ArrayList();
			ArrayList TruncateDeltaTables = new ArrayList();

			// Loop through all the materialized views and process queries.
			foreach (MaterializedView mv in MViewCollection)
			{
				// Optimization:
				if (op == Operation.Deferred &&
					mv.UpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL)
					continue;

				// Prepare a cache key and trigger set.
				string key = String.Empty;
				ArrayList TriggerSet = BuildCacheKeyAndTriggerSet(mv, TriggerList, MViewCollection, out key);

				// Get the materialized view queries based on operation and trigger set.
				Queries query = (mbCacheEnabled) ? (Queries) mQueryCache[key] : null;
				if (query == null)
				{
					// Create materialized view context.
					MaterializedViewContext ctx = new MaterializedViewContext(conn, mv, op, TriggerSet, mQueryAdapter, mBindings);

					// Get query set; collection is provided only to get copy queries.
					query = mv.GetQueries(ctx, MViewCollection);
			
					// Add new query set to cache.
					if (mbCacheEnabled)
						mQueryCache[key] = query;
				}

				//-----
				// Selectively add queries to work buffers:
				// We may be executing in one of two modes TRANSACTIONAL or DEFERRED.
				// Materialized Views may be configured for one of these modes.
				// If we are executing transactionally, then we should execute
				// all materialized views configured in TRANSACTIONAL mode, but copy
				// data needed for materialized views in DEFERRED mode into 
				// persistent delta tables.
				// If we are executing deferred, then we should only execute
				// the materialized views configured in DEFERRED mode.
				//-----
				if ((op == Operation.Deferred && mv.UpdateMode == MaterializedViewDefinition.Mode.DEFERRED) ||
					 op != Operation.Deferred && mv.UpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL)
				{
					InitializeMaterializedViewQuery += query.mInitializeQueries;
					UpdateMaterializedViewQuery += query.mUpdateQueries;
					ReleaseMaterializedViewQuery += query.mReleaseQueries;
				}

        // The following queries are only needed during a non-deferred operation.
        if (op != Operation.Deferred)
        {
          // Process copy queries.
				  if (query.mCopyTables != null)
				  {
					  foreach (Tables tb in query.mCopyTables)
					  {
						  if (CopiedDeltaTables.Contains(tb.DeltaTableName))
							  continue;
						  else
							  CopiedDeltaTables.Add(tb.DeltaTableName);
  				
						  // During a non-deferred operation copy transactional data to delta tables.
						  mQueryAdapter.SetQueryTag("__MOVE_TRANSACTIONAL_DATA_TO_DELTA_TABLE__");
						  mQueryAdapter.AddParam("%%DELTA_TABLE_NAME%%",	tb.DeltaTableName, true);
						  mQueryAdapter.AddParam("%%TRANSACTIONAL_TABLE_NAME%%", tb.TransactionTableName, true);
						  CopyDeltaQueries += mQueryAdapter.GetQuery();

						  // Add query to truncate transaction data.
						  TruncateDeltaTables.Add(tb.TransactionTableName);
						  mQueryAdapter.SetQueryTag("__TRUNCATE_TRANSACTIONAL_DELTA_TABLE__");
						  mQueryAdapter.AddParam("%%DELTA_TABLE_NAME%%", tb.TransactionTableName, true);
						  ReleaseMaterializedViewQuery += mQueryAdapter.GetQuery();
					  }
				  }

					// Process lock queries.
					if (query.mLockTables != null)
					{
						foreach (Tables tb in query.mLockTables)
						{
							if (!LockDeltaTables.Contains(tb.TransactionTableName))
							{
								// Lock the transactional delta tables.
								LockDeltaTables.Add(tb.TransactionTableName);
								mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
								mQueryAdapter.AddParam("%%TABLE_NAME%%", tb.TransactionTableName, true);
								LockDeltaTablesQueries += mQueryAdapter.GetQuery();
							}

							// Trucate any transactional delta table we locked, since we may have used it.
							if (!TruncateDeltaTables.Contains(tb.TransactionTableName))
							{
								// Add truncate query.
								TruncateDeltaTables.Add(tb.TransactionTableName);
								mQueryAdapter.SetQueryTag("__TRUNCATE_TRANSACTIONAL_DELTA_TABLE__");
								mQueryAdapter.AddParam("%%DELTA_TABLE_NAME%%", tb.TransactionTableName, true);
								ReleaseMaterializedViewQuery += mQueryAdapter.GetQuery();
							}
						}
					}
	
					// Process create queries.
					if (query.mCreateTables != null)
					{
						foreach (Tables tb in query.mCreateTables)
						{
							if (!CreateDeltaTables.Contains(tb.TransactionTableName))
							{
								CreateDeltaTables.Add(tb.TransactionTableName);

								//xxx This is not efficient. For now just get it to work.
								// we can cache the result as part of the Query object.
								string ddl = String.Empty;
								if (conn == null)
								{
									using (IMTConnection conn2 = ConnectionManager.CreateConnection())
										ddl = Configuration.CreateBaseTableDDL(conn2, tb.BaseTableName);
								}
								else
									ddl = Configuration.CreateBaseTableDDL(conn, tb.BaseTableName);
							
								if (ddl == String.Empty)
								{
									string msg = "Failed to create DDL for table " + tb.BaseTableName + ", table not found";
									mLogger.LogError(msg);
									throw new Exception(msg);
								}

								mQueryAdapter.SetQueryTag("__CREATE_TABLE__");
								mQueryAdapter.AddParam("%%DDL%%", ddl, true);
								mQueryAdapter.AddParam("%%TABLE_NAME%%", tb.TransactionTableName, true);
								CreateDeltaTablesQueries += mQueryAdapter.GetQuery();

                // Reversing changes made for CR 15061
								// mQueryAdapter.SetQueryTag("__LOCK_TABLE__");
								// mQueryAdapter.AddParam("%%TABLE_NAME%%", tb.BaseTableName, true);
                // LockBaseTablesQueries += mQueryAdapter.GetQuery();
							}
						}
					}
				}
			} // foreach mv

			//-----
			// Create queries create tables that are then used by the update SQL.
			// Oracle will (and maybe MS SQL 2005) not recognize these tables
			// if the are part of the same execution statement.
			// So, we need to execute the queries separately.
      //
      // xxx Probably best to create the delta tables at configuration time.
			//-----
			if (InitializeMaterializedViewQuery.Length > 0 || CreateDeltaTablesQueries.Length > 0)
			{
				// Prepare query.
				string query = "begin ";

        // Reversing changes made for CR 15061

        // Lock some tables to avoid race condition from multiple pipelines
        // while creating the tables.
				// if (LockBaseTablesQueries.Length > 0)
				//  	query += LockBaseTablesQueries;

				// Create initialize queries.
				if (CreateDeltaTablesQueries.Length > 0)
					query += CreateDeltaTablesQueries;

				// Insert initialize queries.
				if (InitializeMaterializedViewQuery.Length > 0)
					query += "\n" + InitializeMaterializedViewQuery;

				query += " end;";

				// Execute.
				if (conn == null)
				{
					using (IMTConnection conn2 = ConnectionManager.CreateConnection())
					{
                        using (IMTStatement stmtNQ = conn2.CreateStatement(query))
                        {
                            stmtNQ.ExecuteNonQuery();
                        }
					}
				}
				else
				{
                    using (IMTStatement stmtNQ = conn.CreateStatement(query))
                    {
                        stmtNQ.ExecuteNonQuery();
                    }
				}
			}

            // ESR-6006 a port of ESR-5598 
            // get the query to update the t_mv_payer_interval and t_mv_payee_session tables while doing an update            
            mQueryAdapter.SetQueryTag("__UPDATE_MV_PAYER_AND_MV_PAYEE__");
            UpdatePayerAndPayeeTablesQueries += mQueryAdapter.GetQuery();

			//-----
			// Assemble all query work buffers into result query.
			//-----
			string ResultQuery = String.Empty;

			// Lock the delta tables.
			if (LockDeltaTablesQueries.Length > 0)
				ResultQuery += LockDeltaTablesQueries + "\n";

			// Insert initialize queries.
			if (InitializeMaterializedViewQuery.Length > 0)
				ResultQuery += InitializeMaterializedViewQuery + "\n";

			// Append the update MV query.
			if (UpdateMaterializedViewQuery.Length > 0)
				ResultQuery += UpdateMaterializedViewQuery + "\n";

			// Move transactional data to persistent tables.
			if (CopyDeltaQueries.Length > 0)
				ResultQuery += CopyDeltaQueries + "\n";

            // ESR-6006 a port of ESR-5598
            if (UpdatePayerAndPayeeTablesQueries.Length >0)
                ResultQuery += UpdatePayerAndPayeeTablesQueries + "\n";

			// At this point, we should be done with all materialized views
			// and it is safe to release their resources.
			if (ReleaseMaterializedViewQuery.Length > 0)
				ResultQuery += ReleaseMaterializedViewQuery + "\n";

			return ResultQuery;
		}

		// Create a cache lookup key based on materialized view name and base tables actually metered.
		// Also return the trigger set, which is a combination of metered base tables and 
		// referenced materialized views.
		private ArrayList BuildCacheKeyAndTriggerSet(MaterializedView mv,
													 string[] TriggerList,
													 MaterializedViewCollection MViewCollection,
													 out string key)
		{
			// Setup an array of base tables for this materialized view.
			// Since the mv base table names are sorted, so will be the trigger list.
			ArrayList TriggerSet = new ArrayList();
			key = mv.Name;
			foreach (BaseTable bt in mv.BaseTables)
			{
				// The triggers are modified base tables that a material view depends on.
				// If a base table is also a materialized view then it is not metered directly
				// and should be added to trigger set only if it has changed. When mv is part
				// of the dependency collection, this indicates that core base tables that
				// materialized view depends on where metered; hence the mv has changed.
				if (bt.isMaterializedView)
				{
					// If the materialized view is part of the dependency collection then it
					// has been modified.
					MaterializedView tmpMV = MViewCollection.FindByName(Bindings.GetMVNameFromTableName(bt.Name));
					if (tmpMV != null)
					{
						TriggerSet.Add(bt);

						// Construct query cache key.
						if (mbCacheEnabled)
							key += ":" + bt.Name;
					}
				}
				else
				{
					for (int i = 0; i < TriggerList.Length; i++)
					{
						if (bt.Name == TriggerList[i].ToLower())
						{
							// Core base table that was metered.
							TriggerSet.Add(bt);

							// Construct query cache key.
							if (mbCacheEnabled)
								key += ":" + bt.Name;
							break;
						}
					}
				}
			} // foreach (BaseTable...

			return TriggerSet;
		}

		// Return all materialized views that depend on the list on base tables as an ordered collection of MaterializedView objects.
		private MaterializedViewCollection GetDependantMaterializedViews(IMTConnection conn, string TableNameList)
		{
            // Collection of materialized views that are affected by the changes to 
            // the specified set of base tables.
            MaterializedViewCollection MViewCollection = new MaterializedViewCollection();

            if (String.IsNullOrEmpty(TableNameList))
            {
                mLogger.LogInfo("No dependent materialized views found");
                return MViewCollection;
            }

            mLogger.LogDebug("Materialized view dependency trigger list: " + TableNameList);

            // Prepare statement to execute.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_DEPENDENTS__"))
            {
                stmt.AddParam("%%TABLE_NAME_LIST%%", TableNameList, true);

                // Execute and loop through result set.
                mLogger.LogDebug("Retrieving Materialized View dependents");
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    try
                    {
                        while (reader.Read())
                        {
                            // Get/create MaterializedView object.
                            string strMaterializedViewName = reader.GetString("mv_name");

                            // Get materialize view information.
                            MaterializedView mv = null;

                            // Is the cache enabled?
                            if (mbCacheEnabled)
                            {
                                // Check if MaterializedView is in cache.
                                mv = (MaterializedView)mMaterializedViews[strMaterializedViewName];
                                if (mv == null)
                                {
                                    // Not found, create and add to cache.
                                    mv = new MaterializedView(strMaterializedViewName);
                                    mMaterializedViews[strMaterializedViewName] = mv;
                                }
                            }
                            else // create a new MaterializedView object.
                                mv = new MaterializedView(strMaterializedViewName);

                            // Create new MaterializedView object and add to collection.
                            MViewCollection.Add(mv);
                        }
                    }
                    catch (Exception e)
                    {
                        string msg = "Unable to determine materialized view dependency order given the following triggers: " + TableNameList;
                        msg += ", error: " + e.Message;
                        throw new Exception(msg);
                    }
                }
            }

			// Loop through all the materialized views and update their info.
			foreach(MaterializedView mv in MViewCollection)
				mv.UpdateMaterializedView(conn);

			return MViewCollection;
		}

		// Read data from materialized view configuration file.
		private bool ReadConfigFile(out bool bIsMetraViewSupportEnabled)
		{
			IMTRcd rcd = new MTRcd();
			string configFile = rcd.ExtensionDir;
			configFile += @"\SystemConfig\config\MaterializedViews\config.xml";

			try
			{
				MTXmlDocument doc = new MTXmlDocument();
				doc.Load(configFile);  
				bIsMetraViewSupportEnabled = doc.GetNodeValueAsBool("/xmlconfig/MetraView/MaterializedViewsEnabled");
				return true;
			} 
			catch(Exception exp)
			{
				bIsMetraViewSupportEnabled = false;
				mLogger.LogError(exp.Message.ToString());
			}
			return false;
		}

		// Stage database name.
		private string mNetMeterStageName;

		// Materialized view cache.
		private bool mbCacheEnabled;
		private Hashtable mMaterializedViews;

		// Query Cache
		private Hashtable mQueryCache;

		// Is materialized view support enabled for MetraView.
		private bool mIsMetraViewSupportEnabled;

		// Logger object.
		private Logger mLogger;	

		// Configuration object.
		private Configuration mConfig; // Initialized on first use

		// Conffigured bindings.
		private Bindings mBindings;

		// Object used to managed pipeline state: paused, running...
		PipelineManager mPipelineManager;

		// Adapter used to get at the queries.
		private QueryAdapter.IMTQueryAdapter mQueryAdapter;

		// Path to all the materialized view manager queries.
		private string mQueryPath;
	}
}
// EOF