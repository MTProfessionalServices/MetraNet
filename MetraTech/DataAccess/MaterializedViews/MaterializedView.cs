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
using System.Collections;
using System.Runtime.InteropServices;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

[assembly: GuidAttribute("A91EB354-8E70-4679-9616-4BAE499E4983")]

// Materialized view info and interface implementations.
namespace MetraTech.DataAccess.MaterializedViews
{
	/// <summary>
	/// 
	/// </summary>
	internal class BaseTable : IComparable
	{
		// Used for sorting by string.
		public int CompareTo(object obj)
		{
		  BaseTable bt = (BaseTable) obj;
		   return string.Compare(mName, bt.Name);
		}

		public string Name
		{
			get { return mName; }
			set { mName = value; }
		}

		public bool isMaterializedView
		{
			get { return mbIsMaterializedView; }
			set { mbIsMaterializedView = value; }
		}

		private string mName = null;
		private bool mbIsMaterializedView = false;
	}

	/// <summary>
	/// 
	/// </summary>
	internal class Tables
	{
		public Tables(string TransactionTableName, string DeltaTableName, string BaseTableName)
		{
			mTransactionTableName = TransactionTableName;
			mDeltaTableName = DeltaTableName;
			mBaseTableName = BaseTableName;
		}

		public string TransactionTableName	{ get { return mTransactionTableName; } }
		public string DeltaTableName { get { return mDeltaTableName; } }
		public string BaseTableName	{ get { return mBaseTableName; } }

		private string mTransactionTableName = String.Empty;
		private string mDeltaTableName = String.Empty;
		private string mBaseTableName = String.Empty;
	}

	/// <summary>
	/// xxx We create this object for each MV. Obviously this not very efficient because
	/// some of the information is redundant, but mem usage is low here.
	/// /// </summary>
	internal class Queries
	{
		public string mInitializeQueries = String.Empty;
		public string mUpdateQueries = String.Empty;
		public string mReleaseQueries = String.Empty;
		public ArrayList mCopyTables = null;
		public ArrayList mLockTables = null;
		public ArrayList mCreateTables = null;
	}
		
	/// <summary>
	/// 
	/// </summary>
	internal class MaterializedViewCollection : ArrayList
	{
		/// <summary>
		/// 
		/// </summary>
		/// <param name="name"></param>
		/// <returns></returns>
		public MaterializedView FindByName(string name)
		{
			foreach(MaterializedView mv in this)
			{
				if (mv.Name == name.ToLower())
					return mv;
			}

			return null;
		}

		/// <summary>
		/// Return true if materialized view is referenced in the collection
		/// by another materialized view in specified mode.
		/// </summary>
		/// <param name="Name"></param>
		/// <param name="UpdateMode"></param>
		/// <returns></returns>
		public bool IsReferenced(string Name, MaterializedViewDefinition.Mode UpdateMode)
		{
			foreach(MaterializedView mv in this)
			{
				// Skip if mode not specified.
				if (mv.UpdateMode != UpdateMode)
					continue;

				// Skip self.
				if (mv.Name == Name)
					continue;

				// Loop through all the base tables to check if referenced.
				foreach (BaseTable bt in mv.BaseTables)
				{
					if (bt.Name == Name)
						return true;
				}
			}
			return false;
		}
	}

	/// <summary>
	/// 
	/// </summary>
	internal class MaterializedView
	{
		// Class construct / destructor pair.
		public MaterializedView(string Name)
		{
			mMaterializedViewName = Name;
			mTableName = Bindings.GetMVTableName(Name);
			mDeltaInsertTableName = Bindings.GetInsertDeltaTableName(mTableName);
			mDeltaDeleteTableName = Bindings.GetDeleteDeltaTableName(mTableName);
			mQueryProvider = null;
			mBaseTables = new ArrayList();
			mUpdateMode = MaterializedViewDefinition.Mode.OFF;
			mIsLoaded = false;
		}

		// Get queries for materialized view based on operation and trigger set.
		internal Queries GetQueries(MaterializedViewContext ctx,
									MaterializedViewCollection MViewCollection)
		{
			// Create queries object to return.
			Queries query = new Queries();
			
			// Get the init queires.
			query.mInitializeQueries = GetInitQuery(ctx);

			//-----
			// If a materialized view is referenced by another in current dependency chain
			// then we need to execute an update on the referencing materialized view.
			// This is because an insert or delete operation may result in an insert and delete
			// or an update. In this case both insert and delete tables are populated.  Thus we must 
			// either run an update sql or insert and delete sql's for the referencing MV.
			//-----
			bool bUseDeleteInsert = false;
			if ((ctx.Operation == Manager.Operation.Insert ||
				 ctx.Operation == Manager.Operation.Delete) &&
				  mDependsOnAnotherMaterializedView)
			{
				//xxx One optimization is to execute both insert and update queries,
				// if they exist.  This should simplify the sql that needs to be written for 
				// each materialized view. The materialized view component should provide information
				// about which operation it performed: insert, update, delete or a comibination
				
				// Do an update as an insert and a delete.
				bUseDeleteInsert = true;
			}
			else
			{
				// Get update queries based on operation context.
				query.mUpdateQueries = GetUpdateQuery(ctx);

				// In update or deferred operation mode, if update queries
				// are not available we can execute insert and delete queries instead.
				if (query.mUpdateQueries == null)
					bUseDeleteInsert = true;
			}

			// Execute Insert and delete queries if 
			if (bUseDeleteInsert)
			{
				Manager.Operation op = ctx.Operation;
				ctx.Operation = Manager.Operation.Insert;
				query.mUpdateQueries = GetUpdateQuery(ctx);
				if (query.mUpdateQueries != null)
				{
					query.mUpdateQueries += "\n";
					ctx.Operation = Manager.Operation.Delete;
					query.mUpdateQueries += GetUpdateQuery(ctx);
					ctx.Operation = op;
				}
			}

			// Check that we have queries to execute.
			if (query.mUpdateQueries == null)
				throw new Exception("Materialized View(" + mMaterializedViewName + "), unable to get queries");

			// Get copy queries.
			query.mCopyTables = GetCopyQuery(ctx, MViewCollection);

			// Get the lock queries, we need to lock all the tables that participate in the transaction.
			query.mLockTables = GetLockTables(ctx);

			// Get a list of tables that needs to be created.
			query.mCreateTables = GetCreateTables(ctx);

			//-----
			// We can assume all MV transactional delta tables may be refferenced so we don't release
			// them until the very end; after we move any data refferenced by the MV's in DEFERRED mode.
			// Get release query to execute when done.
			//-----
			query.mReleaseQueries = mQueryProvider.GetReleaseQuery(ctx);

			// Return result.
			return query;
		}

		private ArrayList GetCopyQuery(MaterializedViewContext ctx,
									   MaterializedViewCollection MViewCollection)
		{
			return GetTransactionRelatedTables(ctx, ctx.TriggerList, MViewCollection);
		}

		// Return queries used to lock delta tables.
		internal ArrayList GetLockTables(MaterializedViewContext ctx)
		{
			return GetTransactionRelatedTables(ctx, ctx.TriggerList, null);
		}

		// Return list of table that must be created, because the materialize view queries
		// depend on their existance.
		internal ArrayList GetCreateTables(MaterializedViewContext ctx)
		{
			return GetTransactionRelatedTables(ctx, mBaseTables, null);
		}
		
		// Get an array of all tables associated with current transaction.
		internal ArrayList GetTransactionRelatedTables(MaterializedViewContext ctx, ArrayList BaseTables, MaterializedViewCollection MViewCollection)
		{
			// Allow copy for transactional MV's only if they are referenced by 
			// a deferred materialized view.
			if (MViewCollection != null &&
				mUpdateMode == MaterializedViewDefinition.Mode.TRANSACTIONAL &&
				!MViewCollection.IsReferenced(mMaterializedViewName, MaterializedViewDefinition.Mode.DEFERRED))
				return null;

			ArrayList queries = new ArrayList();

			// Materialized view delta tables.
			queries.Add(new Tables(ctx.GetInsertBinding(), mDeltaInsertTableName, mTableName));
			queries.Add(new Tables(ctx.GetDeleteBinding(), mDeltaDeleteTableName, mTableName));

			// Delta tables involved in this transaction.
			foreach(BaseTable bt in BaseTables)
			{
				if (MViewCollection != null && bt.isMaterializedView)
				{
					MaterializedView mvBase = MViewCollection.FindByName(Name);
					if (mvBase.UpdateMode == MaterializedViewDefinition.Mode.DEFERRED)
						continue;
				}

				if ((MViewCollection != null && bt.isMaterializedView) // Copy situation
					|| ctx.Operation == Manager.Operation.Update)
				{
					queries.Add(new Tables(ctx.Bindings.GetInsertBinding(bt.Name),
										   Bindings.GetInsertDeltaTableName(bt.Name),
										   bt.Name));
					queries.Add(new Tables(ctx.Bindings.GetDeleteBinding(bt.Name),
										   Bindings.GetDeleteDeltaTableName(bt.Name),
										   bt.Name));
				}
				else
				{
					if (ctx.Operation == Manager.Operation.Insert)
						queries.Add(new Tables(ctx.Bindings.GetInsertBinding(bt.Name),
											   Bindings.GetInsertDeltaTableName(bt.Name),
											   bt.Name));
					else
						queries.Add(new Tables(ctx.Bindings.GetDeleteBinding(bt.Name),
											   Bindings.GetDeleteDeltaTableName(bt.Name),
											   bt.Name));
				}
			}

			return queries;
		}

		// Return init query.
		internal string GetInitQuery(MaterializedViewContext ctx)
		{
			// Get the configured init query, if one is configured.
			string InitQuery = GetInitQuery();

			// Get the dynamic init query.
			InitQuery += mQueryProvider.GetInitializeQuery(ctx);
			return InitQuery;
		}

		// Get the configured query.	
		internal string GetInitQuery()
		{
			// Get the configured init query, if one is configured.
			if (mInitQueryTag != null && mInitQueryTag != String.Empty)
			{
				mQueryAdapter.SetQueryTag(mInitQueryTag);
				return mQueryAdapter.GetQuery();
			}

			return null;
		}

		// Return Full Update query.
		internal string GetFullUpdateQuery(QueryAdapter.IMTQueryAdapter qaFramework, string NetMeterStageName)
		{
			// Get the full query.
			string FullQuery = String.Empty;
			mQueryAdapter.Init(mQueryPath);
			mQueryAdapter.SetQueryTag(mFullQueryTag);
			FullQuery += mQueryAdapter.GetRawSQLQuery(true);

			// Replace this materialized view table name tags.
			FullQuery = Bindings.ReplaceMVTableTags(FullQuery, mTableName);

			// Replace stage database tag.
			FullQuery = Bindings.ReplaceNetmeterStageTags(FullQuery, NetMeterStageName);

			// Truncate the materialized view delta tables. It is the reponsibility
			// of the Materialized View query to truncate the MV table.
			qaFramework.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
			qaFramework.AddParam("%%DELTA_INSERT_TABLE_NAME%%", mDeltaInsertTableName, true);
			qaFramework.AddParam("%%DELTA_DELETE_TABLE_NAME%%", mDeltaDeleteTableName, true);
			string TruncateQuery = qaFramework.GetQuery() + "\n";

			// Truncate all the delta tables associated with this view.
			foreach(BaseTable bt in mBaseTables)
			{
				qaFramework.SetQueryTag("__TRUNCATE_DELTA_TABLES_TABLE__");
				if (bt.isMaterializedView)
				{
					// Truncate the materialized view delta tables.
					qaFramework.AddParam("%%DELTA_INSERT_TABLE_NAME%%",
								Bindings.GetInsertDeltaTableName(Bindings.GetMVNameFromTableName(bt.Name)), true);
					qaFramework.AddParam("%%DELTA_DELETE_TABLE_NAME%%",
								Bindings.GetDeleteDeltaTableName(Bindings.GetMVNameFromTableName(bt.Name)), true);
					TruncateQuery += qaFramework.GetQuery() + "\n";

					// Replace any materialized view name tags.
					FullQuery = Bindings.ReplaceMVTableTags(FullQuery, bt.Name);
				}
				else
				{
					// Truncate the base delta tables.
					qaFramework.AddParam("%%DELTA_INSERT_TABLE_NAME%%", Bindings.GetInsertDeltaTableName(bt.Name), true);
					qaFramework.AddParam("%%DELTA_DELETE_TABLE_NAME%%", Bindings.GetDeleteDeltaTableName(bt.Name), true);
					TruncateQuery += qaFramework.GetQuery() + "\n";
				}
			}

			// Check if we have any tags left.
			string msg = CheckForRemainingTags(FullQuery);
			if (msg != null)
				throw new Exception(msg);

			return (TruncateQuery + FullQuery);
		}

		// Update the materialized view information with data from
		// Materialized View configuration tables.
        internal void UpdateMaterializedView(IMTConnection conn)
        {
            // Have we read the configuration info?
            if (mIsLoaded)
                return;

            // Retrieve all the base tables that this materialized depends on.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mFrameworkQueryPath, "__GET_BASE_TABLES_MV_DEPENDS_ON__"))
            {
                stmt.AddParam("%%MATERIALIZED_VIEW_NAME%%", mMaterializedViewName, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    try
                    {
                        while (reader.Read())
                            AddBaseTable(reader.GetString("base_table_name"),
                                         reader.GetBoolean("is_materialized_view"));
                    }
                    catch (Exception e)
                    {
                        string msg = "Unable to determine base tables for materialized view(" + mMaterializedViewName + "), error: " + e.Message;
                        throw new Exception(msg);
                    }
                }
            }
            // Sort basetable list to make sure we alway process them in same order
            // useful for generating keys.
            BaseTables.Sort();

            // Retrieve materialized view properties.
            using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mFrameworkQueryPath, "__GET_MV_PROPERTIES__"))
            {
                stmt.AddParam("%%MATERIALIZED_VIEW_NAME%%", mMaterializedViewName, true);
                using (IMTDataReader reader = stmt.ExecuteReader())
                {
                    // Should only ever be one record.
                    if (reader.Read())
                    {
                        // Get the required progid for this materialized view.
                        mProgId = reader.GetString("progid");

                        // Get the required query path for this materialized view.
                        mQueryPath = reader.GetString("query_path");
                        mQueryAdapter = new QueryAdapter.MTQueryAdapter();
                        mQueryAdapter.Init(mQueryPath);

                        // Get the required full query path for this materialized view.
                        mFullQueryTag = reader.GetString("full_query_tag");

                        // Get the init query path for this materialized view.
                        // Optional: drop query tag.
                        if (!reader.IsDBNull("init_query_tag"))
                            mInitQueryTag = reader.GetString("init_query_tag");

                        // Get Update Mode.
                        UpdateModeDB = reader.GetString("update_mode");

                        // Create an instance of the interface.
                        try
                        {
                            // Get the interface given the progid.
                            Type MVType = Type.GetTypeFromProgID(mProgId, true); // throws
                            mQueryProvider = (IQueryProvider)Activator.CreateInstance(MVType);
                        }
                        catch (Exception e)
                        {
                            string msg = "Invalid progid: " + mProgId + " for materalized view(" + mMaterializedViewName;
                            msg += "), error: " + e.Message;
                            throw new Exception(msg);
                        }
                    }
                }

                mIsLoaded = true;
            }
        }

		// Return MaterializedView name
		public string Name
		{
			get { return mMaterializedViewName; }
			set { mMaterializedViewName = value; }
		}

		public string TableName
		{
			get { return mTableName; }
		}

		// Prog id for interface associated with materialized view
		public string ProgId
		{
			get { return mProgId; }
		}

		// 
		public string QueryPath
		{
			get { return mQueryPath; }
		}

		// 
		public string FullQueryTag
		{
			get { return mFullQueryTag; }
		}

		public MaterializedViewDefinition.Mode UpdateMode
		{
			get	{ return mUpdateMode; }
		}

		//
		public ArrayList BaseTables
		{
			get { return mBaseTables; }
		}

		//
		public void AddBaseTable(string TableName, bool bIsMaterializedView)
		{
			BaseTable bt = new BaseTable();
			bt.Name = TableName.ToLower();
			bt.isMaterializedView = bIsMaterializedView;
			mBaseTables.Add(bt);

			// This materializewd view depends on another.
			if (bIsMaterializedView)
				mDependsOnAnotherMaterializedView = bIsMaterializedView;
		}

		//
		private string GetUpdateQuery(MaterializedViewContext ctx)
		{
			string query = mQueryProvider.GetUpdateQuery(ctx);
			if (query == null)
				return null;

			// Strip all comments. Useful incase the comments are prolific
			// and there are tags that are embeded in the comments.
			query = Manager.StripComments(query);

			// Retrieve context bindings.
			Bindings bng = ctx.Bindings;

			// Replace this materialized view table name tags.
			query = Bindings.ReplaceMVTableTags(query, mTableName);

			// Replace stage database name tag.
			query = bng.ReplaceNetmeterStageTags(query);

			// Replace materialized view transactional table bindings.
			query = bng.ReplaceBaseTableTags(query, Manager.Operation.Insert, mMaterializedViewName);
			query = bng.ReplaceBaseTableTags(query, Manager.Operation.Delete, mMaterializedViewName);

			// Replace all base table bindings.
			try
			{
				foreach (BaseTable bt in mBaseTables)
				{
					// Replace all instances of materialized view table name tag with table name.
					if (bt.isMaterializedView)
						query = Bindings.ReplaceMVTableTags(query, bt.Name);

					// If the base table is a materialized view assume it performed and update so we need to 
					// replace both kinds of tags: insert and delete.
					if (bt.isMaterializedView || ctx.Operation == Manager.Operation.Update)
					{
						string Name = bt.isMaterializedView ? Bindings.GetMVNameFromTableName(bt.Name) : bt.Name;

						// Update operation type expects to see both insert and delete delta table tags.
						query = bng.ReplaceBaseTableTags(query, Manager.Operation.Insert, Name);
						query = bng.ReplaceBaseTableTags(query, Manager.Operation.Delete, Name);
					}

					// Replace tag for source base table; use provided bindings.
					else query = bng.ReplaceBaseTableTags(query, ctx.Operation, bt.Name);

				} // for each trigger
			}
			catch(Exception e)
			{
				throw new Exception("Unable to set bindings for materialized view("+mMaterializedViewName+"), error: " + e.Message);
			}

			// Check if we have any tags left.
			string msg = CheckForRemainingTags(query);
			if (msg != null)
				throw new Exception(msg);

			return query;
		}

		// Check if we have any tags left.
		private string CheckForRemainingTags(string Query)
		{
			int nIndex = Query.IndexOf("%%");
			if (nIndex != -1)
			{
				int nEOT = Query.IndexOf("%%", nIndex + 2) - nIndex + 2;
				string msg = "Materialized View(" + mMaterializedViewName + ") query contains an unknown tag: ";

				if (nEOT >= 0)
					msg += Query.Substring(nIndex, nEOT);
				else
					msg += Query.Substring(nIndex);
								
				return msg;
			}
			return null;
		}

		private string UpdateModeDB
		{
			set
			{
				if (value == "T")
					mUpdateMode = MaterializedViewDefinition.Mode.TRANSACTIONAL;
				else if (value == "D")
					mUpdateMode = MaterializedViewDefinition.Mode.DEFERRED;
				else if (value == "O")
					mUpdateMode = MaterializedViewDefinition.Mode.OFF;
				else
					throw new Exception("Materialized View Manager is unable to determine update mode, value: " + value);
			}
		}

		// Materialized View name
		private string mMaterializedViewName;

		// Materialized View table name
		private string mTableName;

		// Deferred delta tabled.
		private string mDeltaInsertTableName;
		private string mDeltaDeleteTableName;

		// SQL used to delete or insert in the MaterializedView from delta.
		private string mProgId;

		// Path to all the queries defined for this materialized view.
		private string mQueryPath;

		// Materialized View Framework queries.
		private string mFrameworkQueryPath = "Queries\\MaterializedViews";

		// Tag to the full update query.
		private string mFullQueryTag;

		// Tag to the init query.
		private string mInitQueryTag = String.Empty;

		// Interface that is responsible to generationg queries for this materialized view.
		private IQueryProvider mQueryProvider;

		// Collection of all the basetable this materialized view depends on.
		private ArrayList mBaseTables;

		// The mode in which this materialized view configures.
		MaterializedViewDefinition.Mode mUpdateMode;

		// Track if this materialized depends on another materialized view.
		bool mDependsOnAnotherMaterializedView = false;

		// Is the materialized view object populate from catalog tables?
		private bool mIsLoaded;

		private QueryAdapter.IMTQueryAdapter mQueryAdapter;
	}
}

// EOF