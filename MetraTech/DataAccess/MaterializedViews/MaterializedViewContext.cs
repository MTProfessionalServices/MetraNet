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

// Materialized view info and interface implementations.
namespace MetraTech.DataAccess.MaterializedViews
{
	[ComVisible(true)]
	[Guid("A049D510-EA18-4a90-9B3B-1ED23447E1A2")]
	public interface IMaterializedViewContext
	{
		/// <summary>
		/// 
		/// </summary>
		string Name
		{
			get;
		}
		
		/// <summary>
		/// 
		/// </summary>
		string TableName
		{
			get;
		}

		/// <summary>
		/// 
		/// </summary>
		string QueryPath
		{
			get;
		}

		/// <summary>
		/// 
		/// </summary>
		string OperationType
		{
			get;
		}

		/// <summary>
		/// 
		/// </summary>
		string[] Triggers
		{
			get;
		}

		/// <summary>
		/// 
		/// </summary>
		string[] BaseTables
		{
			get;
		}

		/// <summary>
		/// Any data that the query provider may wish to store between invocations.
		/// </summary>
		object UserData
		{
			get; set;
		}

		/// <summary>
		/// 
		/// </summary>
		IMTConnection Connection
		{
			get;
		}

		/// <summary>
		/// Return the transaction delta table name associated with insert operation.
		/// </summary>
		/// <returns></returns>
		string GetInsertBinding();

		/// <summary>
		/// Return the transaction delta table name associated with delete operation.
		/// </summary>
		/// <returns></returns>
		string GetDeleteBinding();
	}

	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("7837F4DA-C04C-4af7-9CC6-E69666F95D53")]
	public class MaterializedViewContext : IMaterializedViewContext
	{
		internal MaterializedViewContext(IMTConnection conn,
										 MaterializedView mv,
										 Manager.Operation op,
										 ArrayList TriggerList,
										 QueryAdapter.IMTQueryAdapter qa,
										 Bindings bindings)
		{
			mMaterializedView = mv;
			mTriggerList = TriggerList;
			mQueryAdapter = qa;
			mBindings = bindings;
			mConnection = conn;

			// For query manipulation methods, Deferred operation behaves exactly like
			// Update operation.
			mOp = (op == Manager.Operation.Deferred) ? Manager.Operation.Update : op;

			// Convert to string array.
			int i = 0;
			mTriggers = new string[TriggerList.Count];
			foreach(BaseTable bt in TriggerList)
				mTriggers[i++] = bt.Name;

			// Convert to base table list to strinfg array.
			i = 0;
			mBaseTables = new string[mMaterializedView.BaseTables.Count];
			foreach(BaseTable bt in mMaterializedView.BaseTables)
				mBaseTables[i++] = bt.Name;

			//-----
			// Add required bindings that may be missing.
			// Callers creates binding for tables they use, not necessarily all
			// base tables that an MV may depend on. We need to have bindings to all
			// the base tables that may be used during a transaction.
			//-----

			//xxx TODO: cleanup the Bindings class. We should only request name and it should know which.
			if (op == Manager.Operation.Deferred)
			{
				// Set the bindings to the materialized view transactional delta tables.
				mBindings.AddInsertBinding(Name, Bindings.GetInsertDeltaTableName(mv.TableName));
				mBindings.AddDeleteBinding(Name, Bindings.GetDeleteDeltaTableName(mv.TableName));

				// Set the transactional delata base table bindigs that may be missing.
				foreach (string TableName in mBaseTables)
				{
					if (mBindings.GetInsertBinding(TableName) == null)
						mBindings.AddInsertBinding(TableName,
							Bindings.GetInsertDeltaTableName(TableName));

					if (mBindings.GetDeleteBinding(TableName) == null)
						mBindings.AddDeleteBinding(TableName,
							Bindings.GetDeleteDeltaTableName(TableName));
				}
			}
			else
			{
				// Set the bindings to the materialized view transactional delta tables.
				mBindings.AddInsertBinding(Name, mBindings.GetTransactionalInsertTableName(mv.TableName));
				mBindings.AddDeleteBinding(Name, mBindings.GetTransactionalDeleteTableName(mv.TableName));

				// Set the transactional delata base table bindigs that may be missing.
				foreach (string TableName in mBaseTables)
				{
					if (mBindings.GetInsertBinding(TableName) == null)
						mBindings.AddInsertBinding(TableName,
							mBindings.GetTransactionalInsertTableName(TableName));

					if (mBindings.GetDeleteBinding(TableName) == null)
						mBindings.AddDeleteBinding(TableName,
							mBindings.GetTransactionalDeleteTableName(TableName));
				}
			}
		}

		public string Name
		{
			get { return mMaterializedView.Name; }
		}

		public string TableName
		{
			get { return mMaterializedView.TableName; }
		}

		public string QueryPath
		{
			get { return mMaterializedView.QueryPath; }
		}

		public string OperationType
		{
			get
			{
				if (mOp == Manager.Operation.Insert)
					return "I";
				else if (mOp == Manager.Operation.Delete)
					return "D";
				else
					return "U";
			}
		}

		public string[] Triggers
		{
			get { return mTriggers; }
		}

		public string[] BaseTables
		{
			get { return mBaseTables; }
		}

		public object UserData
		{
			get
			{
				return mUserData;
			}
			
			set
			{
				mUserData = value;
			}
		}

		public IMTConnection Connection
		{
			get
			{
				return mConnection;
			}
		}

		public ArrayList TriggerList
		{
			get { return mTriggerList; }
		}

		// Set operation id.
		public Manager.Operation Operation
		{
			set { mOp = value; }
			get { return mOp; }
		}

		// Get bindings.
		public string GetInsertBinding()
		{
			return mBindings.GetInsertBinding(Name);
		}
		public string GetDeleteBinding()
		{
			return mBindings.GetDeleteBinding(Name);
		}

		//
		internal Bindings Bindings
		{
			get { return mBindings; }
		}

		internal QueryAdapter.IMTQueryAdapter QueryAdapter
		{
			get { return mQueryAdapter; }
		}

		// Operation type.
		private Manager.Operation mOp;

		// Bindings
		private Bindings mBindings;

		// Collection of base tables that this materialized view depends on; that were metered.
		private string[] mTriggers;

		// Collection of base table names that this materialized view depends on.
		private string[] mBaseTables;

		// Connection associated with current transaction or null.
		IMTConnection mConnection;

		// List of base tables that triggered this materialized view.
		private ArrayList mTriggerList;

		// Materialized view information.
		private MaterializedView mMaterializedView;

		// Query adapter to use.
		QueryAdapter.IMTQueryAdapter mQueryAdapter;

		// Any data object user wants to pass around
		object mUserData;
	}
}

// EOF