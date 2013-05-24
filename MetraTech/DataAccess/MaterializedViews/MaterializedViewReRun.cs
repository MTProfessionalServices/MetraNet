namespace MetraTech.DataAccess.MaterializedViews
{
	using System;
	using System.Collections;
	using System.EnterpriseServices;
	using System.Runtime.InteropServices;
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.MaterializedViews;
	using MetraTech.Pipeline.ReRun;
	using MetraTech.Interop.MTBillingReRun;
	using QueryAdapter = MetraTech.Interop.QueryAdapter;

	[ComVisible(true)]
	[Guid("20CC8635-DD06-4fb8-B626-B23878E407D3")]
	[Transaction(TransactionOption.Required, Isolation=TransactionIsolationLevel.Any)]
	[ClassInterface(ClassInterfaceType.None)]
	public class MaterializedViewReRun : ServicedComponent, IReRunTask
	{
		private string mStageDbName;
		
		// Constructor
		public MaterializedViewReRun()
		{
			ConnectionInfo ciStageDb = new ConnectionInfo("NetMeterStage");
			mStageDbName = ciStageDb.Catalog + ((ciStageDb.DatabaseType == DBType.Oracle) ? "." : "..");
		}

		[AutoComplete]
		public void Analyze(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
			int rerunID, string rerunTableName, bool useDBQueues)
		{
			/* Do nothing here */
		}

		[AutoComplete]
		public void Backout(MetraTech.Interop.MTBillingReRun.IMTSessionContext context,
							int rerunID, string rerunTableName, bool useDBQueues)
		{
			// To log or not to log...
			Logger logger = new Logger("[MaterializedViewReRun]");

			// Initialize query adapter.
			QueryAdapter.IMTQueryAdapter qa = new QueryAdapter.MTQueryAdapter();
			qa.Init("Queries\\MaterializedViews");

			// Initialize MV manager.
			Manager mvm = new Manager();
			mvm.Initialize();

			// Process MV queries if framework is enabled.
			if (mvm.IsMetraViewSupportEnabled)
			{
				using (IMTConnection conn = ConnectionManager.CreateConnection())
				{
					try
					{
						
						// Get all the unique table names that are associated with rerunTableName;
						qa.SetQueryTag("__GET_RERUN_ASSOCIATIONS__");
						qa.AddParam("%%TABLE_NAME%%", rerunTableName, true);
						string strGetTableNamesSQL = qa.GetQuery();
						logger.LogDebug("Query to get tables for rerun: " + strGetTableNamesSQL);

						// Prepare statement to execute and loop through result set.
						ArrayList BackoutTables = new ArrayList();
                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(strGetTableNamesSQL))
                        {
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                while (reader.Read())
                                    BackoutTables.Add(reader.GetString("nm_table_name"));
                            }
                        }

						if (BackoutTables.Count == 0)
							logger.LogDebug("No product view tables found to backout.");

						// Special case for account usage. All product view datamarts depend on t_acc_usage
						else BackoutTables.Add("t_acc_usage");

						// Are there any adjustment transaction backouts?
						qa.SetQueryTag("__FIND_ADJUSTMENT_BACKOUTS__");
						qa.AddParam("%%TABLE_NAME%%", rerunTableName, true);
						string strAnyAdjustmentTransactionsSQL = qa.GetQuery();
						logger.LogDebug("Query to detect any adjustment transactions for rerun: " + strAnyAdjustmentTransactionsSQL);

                        using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(strAnyAdjustmentTransactionsSQL))
                        {
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                reader.Read();
                                if (reader.GetInt32(0) > 0)
                                    BackoutTables.Add("t_adjustment_transaction");
                                else
                                    logger.LogDebug("No adjustment transactions found to backout.");
                            }
                        }

						// Are there any tables to backout?
						string[] BaseTables;
						if (BackoutTables.Count > 0)
						{
							// Construct a triggers list and provide table bindings.
							int i = 0;
							string[] Triggers = new string[BackoutTables.Count];
							foreach (string Name in BackoutTables)
								Triggers[i++] = Name;

							// Get a list of base tables that need data based on trigger list.
							// Make sure to populate delta_delete tables for them.
							string CreateQueries = String.Empty;
							string TruncateQueries = String.Empty;
							string LockQueries = String.Empty;
							string PopulateQueries = String.Empty;
							BaseTables = mvm.GetMaterializedViewBaseTables(Triggers);
							if (BaseTables != null)
							{
								// Populate the table.
								foreach(string Name in BaseTables)
								{
									string DeltaTableName = mvm.GenerateDeltaDeleteTableName(Name);

									// Add bindings.
									mvm.AddDeleteBinding(Name, DeltaTableName);

									// Create the delta table if does not exist otherwise truncate, but only once.
                  qa.SetQueryTag("__LOCK_TABLE__");
									qa.AddParam("%%TABLE_NAME%%", DeltaTableName, true);
									LockQueries += "\n" + qa.GetQuery();

									// Create the delta table if does not exist otherwise truncate, but only once.
									qa.SetQueryTag("__CREATE_RERUN_DELTA_TABLE__");
									qa.AddParam("%%BASE_TABLE_NAME%%", Name, true);
									qa.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName, true);
									CreateQueries += "\n" + qa.GetQuery();

									// Get the truncate queries.
									qa.SetQueryTag("__TRUNCATE_RERUN_DELTA_TABLE__");
									qa.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName, true);
									TruncateQueries += "\n" + qa.GetQuery();

									// Populate the delta delete tables with original data from source base tables.
									qa.SetQueryTag("__POPULATE_RERUN_DELTA_TABLE__");
									qa.AddParam("%%BASE_TABLE_NAME%%", Name, true);
									qa.AddParam("%%DELTA_TABLE_NAME%%", DeltaTableName, true);
									qa.AddParam("%%RERUN_TABLE_NAME%%", rerunTableName, true);
									PopulateQueries += "\n" + qa.GetQuery();
								}
							}

							// Execute the create queries.
							if (CreateQueries.Length > 0)
							{
                                using (IMTStatement stmtNQ = conn.CreateStatement("begin " + CreateQueries + " end;"))
                                {
                                    stmtNQ.ExecuteNonQuery();
                                }
							}

							//-----
							// Assemble the queries
							//-----
							string QueriesToExecute = String.Empty;

							// Add the lock queries.
							if (LockQueries.Length > 0)
								QueriesToExecute += LockQueries;

							if (PopulateQueries.Length > 0)
								QueriesToExecute += "\n" + PopulateQueries;

							// Get materialized update queries to backout.
							string MVQueries = mvm.GetMaterializedViewBackoutQuery(Triggers);
							if (MVQueries != null && MVQueries.Length > 0)
							{
								logger.LogDebug("Queries to populate delta tables: " + MVQueries);
								QueriesToExecute += "\n" + MVQueries;
							}
						
							// Add the truncate queries.
							if (TruncateQueries.Length > 0)
								QueriesToExecute += "\n" + TruncateQueries;

							// Execute the queries.
							if (QueriesToExecute.Length > 0)
							{
                                using (IMTStatement stmtNQ = conn.CreateStatement("begin " + QueriesToExecute + " end;"))
                                {
                                    stmtNQ.ExecuteNonQuery();
                                }
							}
						}
					}
					catch (Exception ex)
					{
						logger.LogError(ex.ToString());
						throw;
					}
				} // Using conn
			} // Is MV enabled?
			else
				logger.LogDebug("Materialized View support is disabled, no backouts applied.");
		}
	}
}

// EOF