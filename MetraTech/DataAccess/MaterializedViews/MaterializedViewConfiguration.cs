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
using System.Runtime.InteropServices;
using System.Collections;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

// Materialized View Configuration class definition.
namespace MetraTech.DataAccess.MaterializedViews
{
	/// <summary>
	/// Class used to configure materialized views
	/// </summary>
	/// 
	internal class Configuration
	{
		/// <summary>
		/// Constructor
		/// </summary>
		public Configuration()
		{
			mLogger = new Logger("[MaterializedViewConfiguration]");
			mQueryPath = "Queries\\MaterializedViews";
			mQueryAdapter.Init(mQueryPath);

			// Initialize the collection of all materialized view configurations.
			mMVDefCollection = new MaterializedViewDefinitionCollection();
		}

		/// <summary>
		/// Find and process all materialized view configuration files.
		/// </summary>
        public void UpdateConfiguration(IMTNonServicedConnection conn,
                                        Manager mgr, //xxx This is a hack. Shoud not have to pass in manager
                                        out string MaterializedViewsToFullUpdate)
        {
            // Initialize output value.
            MaterializedViewsToFullUpdate = String.Empty;

            //-----
            // Determine what needs to be done:
            // 1. Changed materialized views will be dropped and recreated.
            // 2. Materialized views that no longer exist will be dropped.
            // 3. If the view did not change based on checksum, leave the tables alone.
            // 4. If Materialized view if turned off drop the delta tables only.
            // 5. If Materialized View tables should exist, but do not, then create them.
            //	  Could have been manually dropped, etc.
            // 6. If the Materialized View is new then run full update mode.
            //-----

            //-----
            // Update materialized views.
            //-----
            MaterializedViewDefinition mvDef = null;

            // Get the list of existing materialized views from catalog.
            ArrayList ExistingMaterializedViews = new ArrayList();
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_NAMES__"))
            {
                stmt.AddParam("%%UPDATE_MODE%%", "_", true); // All
                stmt.AddParam("%%NOT%%", "", true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                        ExistingMaterializedViews.Add(reader.GetString("name"));
                }
            }

            /******
             * Execute deffered update queries prior to dropping them:
             * We must run the deferred update before we drop the delta tables.
             * Delta tables are dropped by UpdateConfiguration code. This is a problem
             * that we solve by runnig Full Update if table schema changes.
             * However, if only query changes then we're ok, but we still need the data in the 
             * delta tables. A better solution would be to store old queries in the database
             * and run deffered update before using old queries prior to executing 
             * UpdateConfiguration. For now we'll simply execute Deffered queries
             * inside UpdateConfiguration prior to dropping the delta tables.
             * xxx This is why this is a hack and why we need to mass the Manager object in.
             ******/
            string QueryToExecute = String.Empty;
            string UpdateDeferredMVQuery = mgr.GetDeferredQuery(conn, null);
            if (UpdateDeferredMVQuery != null && UpdateDeferredMVQuery.Length > 0)
            {
                mLogger.LogDebug("Executing deffered update queries");
                QueryToExecute += UpdateDeferredMVQuery;
            }

            // Prepare query to drop materialized views that need to be dropped.
            ArrayList UpdatedMaterializedViews = null;
            string DropTableQuery = PrepareDropTablesQuery(conn, ExistingMaterializedViews,
                                                           out UpdatedMaterializedViews);
            if (DropTableQuery != null && DropTableQuery.Length > 0)
            {
                mLogger.LogDebug("Executing drop MV tables query");
                QueryToExecute += " ";
                QueryToExecute += DropTableQuery;
            }

            // Execute the queries.
            if (QueryToExecute.Length > 0)
            {
                using (IMTStatement stmtNQ = conn.CreateStatement("begin " + QueryToExecute + " end;"))
                {
                    stmtNQ.ExecuteNonQuery();
                }
            }

            // Delete materialized view configuration tables and 
            // update the tables with latest configuration settings.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__DELETE_CONFIGURATION_TABLES__"))
            {
                stmt.ExecuteNonQuery();
            }

            foreach (string name in mMVDefCollection.Names)
            {
                // Get the materialized view definition by name and insert into database.
                mvDef = mMVDefCollection.GetMaterializedViewDefinition(name);

                // Validate materialized view
                ValidateMatrializedView(conn, mvDef);

                // Insert info about existing materialized views.
                InsertMaterializedViewIntoCatalogTables(conn, mvDef);

                // Add the materialized view to DAG if it is enabled.
                // This DAG is used to create a gloabl sort of the materialized views 
                // and their dependents.
                if (mvDef.UpdateMode != MaterializedViewDefinition.Mode.OFF)
                {
                    AddMaterializedViewToDAG(mvDef);

                    // Only full update for new materialized views. If materialized view
                    // did not exist before then we should run full update.
                    // Create a comma delimeted list of MV's to update.
                    if (!ExistingMaterializedViews.Contains(mvDef.Name))
                    {
                        if (MaterializedViewsToFullUpdate.Length > 0)
                            MaterializedViewsToFullUpdate += ",";
                        MaterializedViewsToFullUpdate += "'" + mvDef.TableName + "'";
                    }
                }
            }

            // Adjust all parent and child relationships in DAG.
            foreach (MVNode node in mTopNode.Values)
            {
                // We only need to adjust Materialized View nodes; all other nodes are leaves.
                if (node.MVDef != null)
                {
                    foreach (string BaseTableName in node.MVDef.BaseTables)
                    {
                        MVNode childNode = (MVNode)mTopNode[BaseTableName];
                        childNode.Parents[node.Name] = node;
                        node.Children[BaseTableName] = childNode;
                    }
                }
            }

            // Do a topological sort on DAG to get a global order list of MV.
            TopologicalTableSort sortedList = new TopologicalTableSort(mTopNode, false);

            // Store global sort in database and create materialized view tables.
            ArrayList DeltaTablesToCreate = new ArrayList();
            string SortedOutput = "Materialized view dependency order: ";
            string InsertToMapTable = String.Empty;
            string CreateMVTables = String.Empty;
            QueryAdapter.IMTQueryAdapter tmpQueryAdapter = new QueryAdapter.MTQueryAdapter();
            foreach (MVNode node in sortedList)
            {
                // Prepare output to diplay sort order.
                if (node.GlobalIndex > 0)
                    SortedOutput += "->";
                SortedOutput += node.Name + "(" + node.GlobalIndex.ToString() + ")";

                //-----
                // For each node prepare query to populate the map table.
                // Map table contains a mapping between base tables and their heritage
                // including the global order id of each parent. 
                //-----
                InsertToMapTable = PrepareInsertIntoMapTable(null, node.Name, node, InsertToMapTable);

                // If materialized view the create associated tables.
                if (node.MVDef != null)
                {
                    // Ignore materialized views which are turned OFF.
                    // We do not want to drop the materialized view tables incase
                    // user want to reference them later.
                    if (node.MVDef.UpdateMode == MaterializedViewDefinition.Mode.OFF)
                        continue;

                    // If materialized view is in the updated hash this means that it's create query
                    // did not change. We may still need to recreate the materialized view tables
                    // incase they were somehow lost.
                    int MVDefExists = (UpdatedMaterializedViews.Contains(node.MVDef.Name)) ? 1 : 0;

                    // Generate query to create materialized view tables.
                    mQueryAdapter.SetQueryTag("__CREATE_MATERIALIZED_VIEW_TABLES__");
                    mQueryAdapter.AddParam("%%MV_TABLE_NAME%%", node.MVDef.TableName, true);
                    mQueryAdapter.AddParam("%%MV_EXISTS_VAR%%",
                        System.String.Format("existing{0}", node.GlobalIndex), true);

                    // This will throw an error if MV config does not exist, but the table is present.
                    mQueryAdapter.AddParam("%%MV_EXISTS_VALUE%%", MVDefExists, true);

                    //-----
                    // We need to create a table for each materialized view in the NetMeter database.
                    // We only create tables if they do not already exist.
                    // If they do already exist, then we check to see if MV is existing to decide to
                    // to raise an error.  If MV existed before and the table exist then this is not
                    // and error.
                    //-----
                    tmpQueryAdapter.Init(node.MVDef.QueryPath);
                    tmpQueryAdapter.SetQueryTag(node.MVDef.CreateQueryTag);
                    tmpQueryAdapter.AddParam(Bindings.GetTableTagName(node.MVDef.Name), node.MVDef.TableName, true);
                    mQueryAdapter.AddParam("%%CREATE_MV_QUERY%%", tmpQueryAdapter.GetQuery(), true);

                    CreateMVTables += mQueryAdapter.GetQuery() + "\n";

                    //-----
                    // Create a delta insert and delta delete table for each source base table 
                    // that a materialized view depends on.  The delta tables must be 
                    // created in the netmeter database because netmeter is backed up,
                    // and the delta tables must be backed up in DEFERRED mode.
                    // Must do this after materialized views are created or CreateBaseTableDDL
                    // will fail when applied to a materialized view base table.
                    //
                    // Note: We only need to create the delta tables if MV is in deferred mode
                    // or it is in transactional mode, but referenced by another MV in deferred mode.
                    //-----
                    if (node.MVDef.UpdateMode == MaterializedViewDefinition.Mode.DEFERRED)
                    {
                        // Create a delta table for each of the base tables.
                        foreach (string name in node.MVDef.BaseTables)
                            DeltaTablesToCreate.Add(name);

                        // Create MV delta table.
                        DeltaTablesToCreate.Add(node.MVDef.TableName);
                    }

                    if (node.MVDef.UpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL &&
                        mMVDefCollection.IsReferenced(node.MVDef.TableName, MaterializedViewDefinition.Mode.DEFERRED))
                        DeltaTablesToCreate.Add(node.MVDef.TableName);
                }
            }
            mLogger.LogDebug(SortedOutput);

            // Create materialized view tables.
            if (CreateMVTables.Length > 0)
            {
                mLogger.LogDebug("Executing create Materialized View tables");
                using (IMTStatement stmtNQ = conn.CreateStatement("begin " + CreateMVTables + " end;"))
                {
                    stmtNQ.ExecuteNonQuery();
                }
            }

            // Create delta tables query.
            string CreateDeltaTables = String.Empty;
            foreach (string BaseTable in DeltaTablesToCreate)
            {
                string ddl = CreateBaseTableDDL(conn, BaseTable);
                if (ddl == String.Empty)
                {
                    string msg = "Failed to create DDL for table " + BaseTable + ", table not found";
                    mLogger.LogError(msg);
                    throw new Exception(msg);
                }

                mQueryAdapter.SetQueryTag("__CREATE_SOURCE_DELTA_TABLES__");
                mQueryAdapter.AddParam("%%DDL%%", ddl, true);
                mQueryAdapter.AddParam("%%DELTA_INSERT_TABLE_NAME%%",
                    Bindings.GetInsertDeltaTableName(BaseTable), true);
                mQueryAdapter.AddParam("%%DELTA_DELETE_TABLE_NAME%%",
                                       Bindings.GetDeleteDeltaTableName(BaseTable), true);
                CreateDeltaTables += mQueryAdapter.GetQuery() + "\n";
            }

            // Create delta tables.
            if (CreateDeltaTables.Length > 0)
            {
                mLogger.LogDebug("Executing create Delta tables");
                using (IMTStatement stmtNQ = conn.CreateStatement("begin" + CreateDeltaTables + " end;"))
                {
                    stmtNQ.ExecuteNonQuery();
                }
            }

            // Populate the map table.
            if (InsertToMapTable.Length > 0)
            {
                mLogger.LogDebug("Executing populate Materialized View map.");
                using (IMTStatement stmtNQ = conn.CreateStatement("begin " + InsertToMapTable + " end;"))
                {
                    stmtNQ.ExecuteNonQuery();
                }
            }
        }

		static public string CreateBaseTableDDL(IMTConnection conn, string BaseTableName)
		{
			// Initialize return values.
			string ddl = String.Empty;

			// Get temp table format from BaseTableName table so that it is not hard coded.
			// We generate our own ddl instead of select into where 1=0 because we want to
			// avoid generating identity column if they are used.
			string isNullable = "NULL";
			string isNotNullable = "NOT NULL";
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("GetMetaDataForProps"))
            {
                stmt.AddParam("tablename", MTParameterType.String, BaseTableName);
                stmt.AddParam("columnname", MTParameterType.String, "");
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        if (ddl.Length > 1)
                            ddl += ",";
                        else
                            ddl = "(";

                        string Type = reader.GetString("type").ToLower();
                        string Name = reader.GetString("name");
                        // g. cieplik CR16068, in oracle the data type returns as number
                        if (Type == "numeric" || Type == "number")
                        {
                            ddl += System.String.Format("{0} {1} ({2},{3}) {4}",
                                Name, Type,
                                reader.GetValue("length"),
                                reader.GetValue("decplaces"),
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                        }
                        else if (Type == "char" || Type == "varchar" || Type == "nvarchar" ||
                                 Type == "varchar2" || Type == "nvarchar2" ||
                                 Type == "varbinary" || Type == "raw")
                        {
                            ddl += System.String.Format("{0} {1} ({2}) {3}",
                                Name, Type, reader.GetValue("length"),
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                        }
                        else
                            ddl += System.String.Format("{0} {1} {2}",
                                Name, Type,
                                Convert.ToBoolean(reader.GetValue("required")) ? isNotNullable : isNullable);
                    }

                    if (ddl.Length > 1)
                        ddl += ")";
                }
            }

			return ddl;
		}

		/// <summary>
		/// Class used to construct a directed acyclic graph.
		/// Node is a collection of children nodes and contains a collection of
		/// parents. Each node contains a reference to the materialized view
		/// definition.
		/// </summary>
		/// 
		private class MVNode : Hashtable
		{
			public string Name
			{
				get { return mName; }
				set { mName = value; }
			}
			public int GlobalIndex
			{
				get { return mGlobalIndex; }
				set { mGlobalIndex = value; }
			}
			public MaterializedViewDefinition MVDef
			{
				get { return mMVDef; }
				set { mMVDef = value; }
			}
			public MVNode Parents
			{
				get
				{
					if (mParents == null)
						mParents = new MVNode();
					return mParents;
				}
			}
			public MVNode Children
			{
				get { return this; }
			}
			private string mName;
			private int mGlobalIndex;
			private MVNode mParents = null;
			private MaterializedViewDefinition mMVDef = null;
		}

		/// <summary>
		/// 
		/// </summary>
		private class TopologicalTableSort : CollectionBase
		{
			private ArrayList mDiscovered;
			private ArrayList mPredecessors;
			private int mGlobalIndex;

			public void Add(MVNode node)
			{
				node.GlobalIndex = mGlobalIndex++;
				List.Add(node);
			}

			public int IndexOf(MVNode node)
			{
				return List.IndexOf(node);
			}

			public bool Contains(MVNode node)
			{
				return List.Contains(node);
			}

			public void Remove(MVNode node)
			{
				List.Remove(node);
			}

			private void DepthFirstSearch(MVNode node)
			{
				mDiscovered.Add(node);
				mPredecessors.Add(node);

				foreach(MVNode childNode in node.Children.Values)
				{
					// Is this child node it's own predecessor?
					if (mPredecessors.Contains(childNode))
					{
						// Child of the node is the node.
						string msg = "Cyclic dependency detected";
						if (childNode.Name == node.Name)
						{
							msg += ": materialized view \""+ node.Name + "\" depends on itself.";
						}
						else
						{
							msg += ", materialized view dependency chain: " + node.Name;
							foreach (MVNode parentNode in mPredecessors)
								msg += "->" + parentNode.Name;
						}

						throw new Exception(msg);
					}

					if (mDiscovered.Contains(childNode))
						continue;

					DepthFirstSearch(childNode);
				}

				// Finished!
				Add(node);
				mPredecessors.Remove(node);
			}

			// Instead of looking at my decendants, find out my parent lineage.
			private void ReverseDepthFirstSearch(MVNode node)
			{
				mDiscovered.Add(node);
				mPredecessors.Add(node);

				foreach(MVNode parentNode in node.Parents.Values)
				{
					// Is this child node it's own predecessor?
					if (mPredecessors.Contains(parentNode))
					{
						// Child of the node is the node.
						string msg = "Cyclic dependency detected";
						if (parentNode.Name == node.Name)
						{
							msg += ": materialized view \""+ node.Name + "\" is its own parent.";
						}
						else
						{
							msg += ", materialized view dependency chain: ";
							foreach (MVNode childNode in mPredecessors)
							{
								if (childNode.Name == null)
								{
									msg += node.Name;
									continue;
								}

								msg += parentNode.Name + "<-";
							}
						}

						throw new Exception(msg);
					}

					if (mDiscovered.Contains(parentNode))
						continue;

					ReverseDepthFirstSearch(parentNode);
				}

				// Finished!
				Add(node);
				mPredecessors.Remove(node);
			}

			public TopologicalTableSort(MVNode firstNode, bool isReverse) : base()
			{
				mDiscovered = new ArrayList();
				mPredecessors = new ArrayList();

				// Do Depth First search of graph, do a post-order sort.
				foreach(MVNode node in firstNode.Children.Values)
				{
					if (mDiscovered.Contains(node))
						continue;

					if (isReverse)
						ReverseDepthFirstSearch(node);
					else
						DepthFirstSearch(node);
				}
			}
		}

		/// <summary>
		/// Return the query to drop a materialized view table
		/// and anything else necessary.
		/// </summary>
		/// <param name="strMaterializedViewName"></param>
		/// <returns></returns>
		private string GetDropMaterializedViewQuery(string MaterializedViewName,
													string oldQueryPath,
													string oldDropQueryTag)
		{
			// Get configured drop queries.
			string Query = String.Empty;
			if (oldQueryPath != null && oldQueryPath != String.Empty &&
				oldDropQueryTag != null && oldDropQueryTag != String.Empty)
			{
				QueryAdapter.IMTQueryAdapter tmpQA = new QueryAdapter.MTQueryAdapter();
				tmpQA.Init(oldQueryPath);
				tmpQA.SetQueryTag(oldDropQueryTag);

				// Replace materialize view query tag if one exists.
				Query = tmpQA.GetRawSQLQuery(true).Replace(Bindings.GetTableTagName(MaterializedViewName),
														   Bindings.GetMVTableName(MaterializedViewName));
				Query += "\n";
			}
			
			// Append the default drop queries.
			mQueryAdapter.SetQueryTag("__DROP_TABLE__");
			mQueryAdapter.AddParam("%%TABLE_NAME%%", Bindings.GetMVTableName(MaterializedViewName), true);
			Query += mQueryAdapter.GetQuery() + "\n";

			// Update the checksum for this materialized view.
			mQueryAdapter.SetQueryTag("__UPDATE_MATERIALIZED_VIEW_CHECKSUM_CATALOG__");
			mQueryAdapter.AddParam("%%MV_NAME%%", MaterializedViewName, true);
			mQueryAdapter.AddParam("%%INCREMENT%%", 0, true); // do not increment
			mQueryAdapter.AddParam("%%MV_CHECKSUM%%", NoCheckSumValue, true); // Reset.

			// Return query.
			return (Query + mQueryAdapter.GetQuery());
		}

		private string GetDropDeltaTablesQuery(IMTConnection conn, string MaterializedViewName)
		{
			//-----
			// We need to drop delta tables associated with Materialized View being dropped.
			// Between all materialized views there will be redundant delta tables. Here
			// we'll keep track of all the processed base tables. Since the base tables may have
			// changed in the configuration file, we need to get the list of base tables from 
			// the current materialized view catalog tables and not from the configuration files.
			//-----
			string Query = String.Empty;
			ArrayList ProcessedBaseTables = new ArrayList();

			// Get the list of BaseTables from the materialized view catalog tables.
			mQueryAdapter.SetQueryTag("__GET_MATERIALIZED_VIEW_BASE_TABLE_NAMES__");
			mQueryAdapter.AddParam("%%MATERIALIZED_VIEW_NAME%%", MaterializedViewName, true);
            using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(mQueryAdapter.GetQuery()))
            {
                try
                {
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        string BaseTableName;
                        while (reader.Read())
                        {
                            BaseTableName = reader.GetString("base_table_name");
                            if (!ProcessedBaseTables.Contains(BaseTableName))
                            {
                                ProcessedBaseTables.Add(BaseTableName);

                                // We should not drop dase delta tables if they are referenced by other materialized views
                                // configured in DEFERRED mode.
                                if (!mMVDefCollection.IsReferenced(BaseTableName, MaterializedViewDefinition.Mode.DEFERRED))
                                {
                                    // Get the drop delta tables query.
                                    mQueryAdapter.SetQueryTag("__DROP_TABLE__");
                                    mQueryAdapter.AddParam("%%TABLE_NAME%%",
                                        Bindings.GetInsertDeltaTableName(BaseTableName), true);
                                    Query += mQueryAdapter.GetQuery() + "\n";

                                    // Drop the delta delete table.
                                    mQueryAdapter.SetQueryTag("__DROP_TABLE__");
                                    mQueryAdapter.AddParam("%%TABLE_NAME%%",
                                                           Bindings.GetDeleteDeltaTableName(BaseTableName), true);
                                    Query += mQueryAdapter.GetQuery() + "\n";
                                }
                            }
                        }

                        // If materialized view is not being used as a base table it
                        // will not be picked up by the above query. So we need to handle
                        // this case.
                        string MVTableName = Bindings.GetMVTableName(MaterializedViewName);
                        if (!ProcessedBaseTables.Contains(MVTableName))
                        {
                            ProcessedBaseTables.Add(MVTableName);

                            // We should not drop materialized view delta tables if they are referenced by other materialized views
                            // configured in DEFERRED mode.
                            if (!mMVDefCollection.IsReferenced(MVTableName, MaterializedViewDefinition.Mode.DEFERRED))
                            {
                                // Get the drop delta tables query.
                                mQueryAdapter.SetQueryTag("__DROP_TABLE__");
                                mQueryAdapter.AddParam("%%TABLE_NAME%%",
                                                       Bindings.GetInsertDeltaTableName(MVTableName), true);
                                Query += mQueryAdapter.GetQuery() + "\n";

                                // Drop the delta delete table.
                                mQueryAdapter.SetQueryTag("__DROP_TABLE__");
                                mQueryAdapter.AddParam("%%TABLE_NAME%%",
                                                       Bindings.GetDeleteDeltaTableName(MVTableName), true);
                                Query += mQueryAdapter.GetQuery() + "\n";
                            }
                        }
                    }
                }
                catch (Exception e)
                {
                    throw new Exception("Unable to determine base tables for materialized view(" + MaterializedViewName + "), error: " + e.Message);
                }
            }

			// Return query.
			return Query;
		}

		// Get the checksum from database.
		private string GetExistingMaterializedViewInfo(IMTConnection conn, string strMaterializedViewName,
													   out string oldQueryPath,
													   out string oldDropQueryTag,
													   out MaterializedViewDefinition.Mode oldUpdateMode)
		{
			oldQueryPath = String.Empty;
			oldDropQueryTag = String.Empty;
			oldUpdateMode = MaterializedViewDefinition.Mode.TRANSACTIONAL;
			string oldChecksum = null;
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_MATERIALIZED_VIEW_INFO_FROM_CATALOG__"))
            {
                stmt.AddParam("%%MV_NAME%%", strMaterializedViewName, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Required: Retrieve the old checksum value.
                        oldChecksum = reader.GetString("tx_checksum");

                        // Required: query path
                        oldQueryPath = reader.GetString("query_path");

                        // Optional: drop query tag.
                        if (!reader.IsDBNull("drop_query_tag"))
                            oldDropQueryTag = reader.GetString("drop_query_tag");

                        // Required: update mode.
                        string UpdateModeDB = reader.GetString("update_mode");
                        if (UpdateModeDB == "T")
                            oldUpdateMode = MaterializedViewDefinition.Mode.TRANSACTIONAL;
                        else if (UpdateModeDB == "D")
                            oldUpdateMode = MaterializedViewDefinition.Mode.DEFERRED;
                        else if (UpdateModeDB == "O")
                            oldUpdateMode = MaterializedViewDefinition.Mode.OFF;
                        else
                            throw new Exception("Invalid update_mode in t_mview_catalog, value: " + UpdateModeDB);
                    }
                }
            }

			return oldChecksum;
		}

		internal void SetMaterializedViewEnabledProperty(IMTConnection conn, bool bEnabled)
		{
			try
			{
                using (IMTCallableStatement stmt = conn.CreateCallableStatement("AddDatabaseProperty"))
                {
                    stmt.AddParam("property", MTParameterType.String, "DATAMART");
                    stmt.AddParam("value", MTParameterType.String, bEnabled ? "true" : "false");
                    stmt.ExecuteNonQuery();
                }
			}
			catch (Exception inner)
			{
				string msg = String.Format("Materialized view framework failed to insert into t_db_values table.");
				throw new Exception(msg, inner);
			}
			
		}

		/// <summary>
		/// Prepare drop tables query. 
		/// </summary>
		/// <param name="conn"></param>
		/// <param name="ExistingMaterializedViews"></param>
		/// <param name="UpdatedMaterializedViews"></param>
		/// <returns></returns>
		private string PrepareDropTablesQuery(IMTConnection conn, 
											  ArrayList ExistingMaterializedViews,
											  out ArrayList UpdatedMaterializedViews)
		{
			// Materialized views that did not change. This really means that
			// the MV table creation is unchanged, but the configuration
			// may have been modified. In this case we update the catalog tables
			// but do not recreate the materialized view tables.
			UpdatedMaterializedViews = new ArrayList();

			// Loop through existing material views.
			MaterializedViewDefinition mvDef = null;
			string DropTableQuery = String.Empty;
			foreach (string MaterializedViewName in ExistingMaterializedViews)
			{
				// Get the materialized view definition by name.
				mvDef = mMVDefCollection.GetMaterializedViewDefinition(MaterializedViewName);

				// Does materialized view still exist?
				bool bDropMVTable = true;
				bool bDropDeltaTable = true;
				string oldQueryPath = String.Empty;
				string oldDropQueryTag = String.Empty;
				string msg = "Materialized View(" + MaterializedViewName + ")";
				if (mvDef != null)
				{
					// Yes it does.
					// If materialized view is OFF then drop.
					if (mvDef.UpdateMode != MaterializedViewDefinition.Mode.OFF)
					{
						// Not OFF, did the summary table change?
						MaterializedViewDefinition.Mode oldUpdateMode;
						string oldChecksum = GetExistingMaterializedViewInfo(conn, MaterializedViewName,
																			 out oldQueryPath,
																			 out oldDropQueryTag,
																			 out oldUpdateMode);
						if (mvDef.Checksum == oldChecksum)
						{
							// If MV Update mode changed from DEFERRED to TRANSACTIONAL then we 
							// need to drop the delta tables for they are no longer needed.
							if (oldUpdateMode == MaterializedViewDefinition.Mode.DEFERRED &&
								mvDef.UpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL)
							{
								// Do not drop the MV table, only drop the delta tables.
								bDropMVTable = false;
								UpdatedMaterializedViews.Add(MaterializedViewName);
							}
							else
							{
								// Materialized view did not change, do not drop the table.
								mLogger.LogDebug(msg + " did not change, summary and delta tables will not be dropped.");
								UpdatedMaterializedViews.Add(MaterializedViewName);
								continue;
							}
						}
					}
					else
					{
						// In OFF mode we do not drop the materialized view table.
						mLogger.LogDebug(msg + " is OFF.");
						UpdatedMaterializedViews.Add(MaterializedViewName);
						continue;
					}
				}
				else mLogger.LogDebug(msg + " was deleted, summary and delta tables will be dropped.");

				// Get the query used to drop materialized view summary table.
				if (bDropMVTable)
				{
					mLogger.LogDebug(msg + " has changed, materialized view table will be dropped.");
					DropTableQuery += GetDropMaterializedViewQuery(MaterializedViewName, oldQueryPath, oldDropQueryTag) + "\n";
				}

				// Get the query used to drop all the delta tables the materialized view depends on.
				if (bDropDeltaTable)
				{
					mLogger.LogDebug(msg + " has changed, delta tables will be dropped.");
					DropTableQuery += GetDropDeltaTablesQuery(conn, MaterializedViewName) + "\n";
				}
			} // foreach

			return DropTableQuery;
		}

		/// <summary>
		/// Validate that all the depenencies for this materialized view 
		/// either exist or will be created during current configuration effort.
		/// 1. All the base tables must exist. If base table is another view, then it must exist
		/// or be created
		/// 2. Base table must be of the type currently supported: t_pv_*, t_adjustment_transaction,
		/// t_dm_account, t_acc_usage, and t_mv_*
		/// 3. Materialized view base table must be configured to update in following way:
		///	  - DEFERRED MV may depend on another DEFERRED MV or TRANSACTIONAL MV, but not MV that is OFF
		///   - A TRANSACTIONAL MV may not depend on DEFERRED or OFF MV
		/// </summary>
		/// <param name="conn"></param>
		/// <param name="mvDef"></param>
		private void ValidateMatrializedView(IMTConnection conn, MaterializedViewDefinition mvDef)
		{
			// No validation to be done for materialized view that is ddisabled.
			if (mvDef.UpdateMode == MaterializedViewDefinition.Mode.OFF)
				return;

			string msg = String.Empty;
			foreach(string BaseTableName in mvDef.BaseTables)
			{
				// Determine if base table may be a materialized view.
				string MVName = Bindings.GetMVNameFromTableName(BaseTableName);
				if (MVName != null)
				{
				// If materialized view definition in collection then continue.
				MaterializedViewDefinition mvBase = mMVDefCollection.GetMaterializedViewDefinition(MVName);
				if (mvBase != null)
				{
					// Check that the referenced materialized view operates in a supported mode.
					if (mvDef.UpdateMode == MaterializedViewDefinition.Mode.DEFERRED && 
						mvBase.UpdateMode == MaterializedViewDefinition.Mode.OFF)
					{
						msg = "Invalid configuration: Materialized View(" + mvDef.Name;
						msg += ") is configured in DEFERRED mode, but depends on a materialized view(" + mvBase.Name;
						msg += ") that is OFF.";
						throw new Exception(msg);
					}
					else if (mvDef.UpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL &&
							 (mvBase.UpdateMode == MaterializedViewDefinition.Mode.OFF ||
					 		  mvBase.UpdateMode == MaterializedViewDefinition.Mode.DEFERRED))
					{
						msg = "Invalid configuration: Materialized View(" + mvDef.Name;
						msg += ") is configured in TRANSACTIONAL mode, but depends on a materialized view(" + mvBase.Name;
						msg += ") configured in ";
						msg += mvBase.UpdateMode == MaterializedViewDefinition.Mode.OFF ? "OFF" : "DEFERRED";
						msg += " mode.";
						throw new Exception(msg);
					}

					// Materialized View is configured correctly.
					continue;
				}
				}

				// Is transaction adjustment?
				if (BaseTableName == "t_adjustment_transaction")
					continue;

				// Is account usage?
				if (BaseTableName == "t_acc_usage")
					continue;

				// Is accounts table?
				if (BaseTableName == "t_dm_account")
					continue;

				// Is product view?
                if (BaseTableName.StartsWith("t_pv_"))
                {
                    // Check that product view table exists.
                    using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__DOES_BASETABLE_EXIST__"))
                    {
                        stmt.AddParam("%%TABLE_NAME%%", BaseTableName, true);
                        try
                        {
                            using (IMTDataReader reader = stmt.ExecuteReader())
                            {
                                if (reader.Read() &&
                                    reader.GetInt32("found") > 0)
                                    continue;
                            }
                        }
                        catch (Exception e)
                        {
                            throw new Exception("Unable to determine if Materialized View(" + mvDef.Name + "), depends on base table(" + BaseTableName + "), error: " + e.Message);
                        }
                    }
                }

				// Base table not supported.
				msg = "Materialized View("+mvDef.Name+") depends on an unsupported base table("+BaseTableName+")";
				throw new Exception(msg);
			}
		}

		/// <summary>
		/// Insert materialized view configuration information into
		/// configuration tables.
		/// </summary>
		/// <param name="conn"></param>
		/// <param name="mvDef"></param>
		private void InsertMaterializedViewIntoCatalogTables(IMTConnection conn, MaterializedViewDefinition mvDef)
		{
            int id_mv = -1;
			// Insert into Catalog table.
            using (IMTCallableStatement call = conn.CreateCallableStatement("InsertIntoCatalogTable"))
            {
                call.AddParam("name", MTParameterType.String, mvDef.Name);
                call.AddParam("table_name", MTParameterType.String, mvDef.TableName);
                call.AddParam("description", MTParameterType.String, mvDef.Description);
                call.AddParam("updatemode", MTParameterType.String, mvDef.UpdateModeDB);
                call.AddParam("querypath", MTParameterType.String, mvDef.QueryPath);
                call.AddParam("createquerytag", MTParameterType.String, mvDef.CreateQueryTag);
                call.AddParam("dropquerytag", MTParameterType.String, mvDef.DropQueryTag);
                call.AddParam("initquerytag", MTParameterType.String, mvDef.InitQueryTag);
                call.AddParam("fullquerytag", MTParameterType.String, mvDef.FullQueryTag);
                call.AddParam("progid", MTParameterType.String, mvDef.ProgId);
                call.AddParam("idrevision", MTParameterType.Integer, 1);

                // Do not store checksum for disabled materialized views.
                // This will force the creation of materialized view tabled
                // when and if it is ever enabled.
                if (mvDef.UpdateMode == MaterializedViewDefinition.Mode.OFF)
                    call.AddParam("checksum", MTParameterType.String, NoCheckSumValue);
                else
                    call.AddParam("checksum", MTParameterType.String, mvDef.Checksum);

                call.AddOutputParam("id_mv", MTParameterType.Integer);
                call.ExecuteNonQuery();
                id_mv = (int)call.GetOutputValue("id_mv");
            }

			// Loop through all the events
			foreach(MaterializedViewEvent ev in mvDef.Events)
			{
                int id_event = -1;
				// Insert into Event table.
                using (IMTCallableStatement call = conn.CreateCallableStatement("InsertIntoEventTable"))
                {
                    call.AddParam("id_mv", MTParameterType.Integer, id_mv);
                    call.AddParam("description", MTParameterType.String, ev.Description);
                    call.AddOutputParam("id_event", MTParameterType.Integer);
                    call.ExecuteNonQuery();
                    id_event = (int)call.GetOutputValue("id_event");
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__INSERT_INTO_BASETABLES_TABLE__"))
                {
                    // Insert into BaseTables table.
                    foreach (string BaseTableName in ev.BaseTables)
                    {
                        stmt.ClearQuery();
                        stmt.AddParam("%%ID_EVENT%%", id_event);
                        stmt.AddParam("%%TABLE_NAME%%", BaseTableName);
                        stmt.ExecuteNonQuery();
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__INSERT_INTO_QUERIES_TABLE__"))
                {
                    // Insert into Queries table.
                    foreach (string opName in ev.Operations)
                    {
                        stmt.ClearQuery();
                        string UpdateQuery = ev.GetQueryTag(opName);
                        stmt.AddParam("%%ID_EVENT%%", id_event);
                        stmt.AddParam("%%OPERATION_TYPE%%", opName);
                        stmt.AddParam("%%UPDATE_QUERY_TAG%%", UpdateQuery);
                        stmt.ExecuteNonQuery();
                    }
                }
			}
		}

		/// <summary>
		/// Update the mat table
		/// </summary>
		/// <param name="conn"></param>
		/// <param name="node"></param>
		private string PrepareInsertIntoMapTable(Hashtable discovered,
												 string BaseTableName,
												 MVNode node,
												 string InsertToMapTable)
		{
			if (discovered == null)
				discovered = new Hashtable();

			// Check if this base table is already in discovered list.
			ArrayList list = (ArrayList) discovered[BaseTableName];
			if (list == null)
			{
				list = new ArrayList();
				discovered[BaseTableName] = list;
			}

			// Add all nodes parents that reference this node.
			foreach(MVNode nodeParent in node.Parents.Values)
			{
				if (list.Contains(nodeParent) == false)
				{
					// Add node to discovered collection.
					list.Add(nodeParent);

					// Get query to insert into map table.
					mQueryAdapter.SetQueryTag("__INSERT_INTO_MAP_TABLE__");
					mQueryAdapter.AddParam("%%BASE_TABLE_NAME%%", BaseTableName, true);
					mQueryAdapter.AddParam("%%MV_NAME%%", nodeParent.MVDef.Name, true);
					mQueryAdapter.AddParam("%%GLOBAL_INDEX%%", nodeParent.GlobalIndex, true);

					if (InsertToMapTable.Length > 0)
						InsertToMapTable += " ";

					// Add to query.
					InsertToMapTable += mQueryAdapter.GetQuery();

					// Update query is parent info.
					InsertToMapTable = PrepareInsertIntoMapTable(discovered, BaseTableName, nodeParent, InsertToMapTable);
				}
			}

			// Add self reference for each materialized view.
			if (node.MVDef != null &&
				list.Contains(node) == false)
			{
				// Add node to discovered collection.
				list = new ArrayList();
				list.Add(node);
				discovered[node.MVDef.TableName] = list;
				
				// Get query to insert into map table.
				mQueryAdapter.SetQueryTag("__INSERT_INTO_MAP_TABLE__");
				mQueryAdapter.AddParam("%%BASE_TABLE_NAME%%", node.MVDef.TableName, true);
				mQueryAdapter.AddParam("%%MV_NAME%%", node.MVDef.Name, true);
				mQueryAdapter.AddParam("%%GLOBAL_INDEX%%", node.GlobalIndex, true);
				if (InsertToMapTable.Length > 0)
					InsertToMapTable += " ";
				InsertToMapTable += mQueryAdapter.GetQuery();
			}

			return InsertToMapTable;
		}

		/// <summary>
		/// Add materialized view and it's children to hash table as node.
		/// </summary>
		/// <param name="mvDef"></param>
		private void AddMaterializedViewToDAG(MaterializedViewDefinition mvDef)
		{
			// Add a node representing the materialized view to hash.
			MVNode node = new MVNode();
			node.Name = mvDef.TableName;
			node.MVDef = mvDef;
			mTopNode[node.Name] = node;

			// Now add 
			foreach(string BaseTableName in mvDef.BaseTables)
			{
				// Add all the children to the DAG.
				if (mTopNode[BaseTableName] == null)
				{
					node = new MVNode();
					node.Name = BaseTableName;
					node.MVDef = mMVDefCollection.GetMaterializedViewDefinition(BaseTableName);
					mTopNode[BaseTableName] = node;
				}
				// else already in hash.
			}
		}

		// Private data members
		private MetraTech.Logger mLogger;
		private string mQueryPath;
		private MaterializedViewDefinitionCollection mMVDefCollection;
		private MVNode mTopNode = new MVNode();
		private QueryAdapter.IMTQueryAdapter mQueryAdapter = new QueryAdapter.MTQueryAdapter();
		private string NoCheckSumValue = "== No Checksum ==";

	}
}

// EOF