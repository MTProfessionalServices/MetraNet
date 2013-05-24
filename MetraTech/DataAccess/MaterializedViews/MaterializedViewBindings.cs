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
using MetraTech.DataAccess;
using MetraTech.DataAccess.MaterializedViews;

// Materialized View Manager class definition.
namespace MetraTech.DataAccess.MaterializedViews
{
	internal class Bindings
	{
		// Class constructor.
		public Bindings()
		{
			mBindings = new Hashtable();

			ConnectionInfo ciStageDb = new ConnectionInfo("NetMeterStage");
			mNetMeterStageName = ciStageDb.Catalog;
			mDot = ((ciStageDb.DatabaseType == DBType.Oracle) ? "." : "..");
		}

		// Are there any bindings.
		public bool IsEmpty
		{
			get
			{
				return (mBindings != null && mBindings.Count > 0) ? false : true;
			}
		}

		public void AddInsertBinding(string BaseTableName, string BaseTableDeltaName)
		{
			mBindings[GetDeltaTagName(Manager.Operation.Insert, BaseTableName)] = BaseTableDeltaName;
		}

		public void AddDeleteBinding(string BaseTableName, string BaseTableDeltaName)
		{
			mBindings[GetDeltaTagName(Manager.Operation.Delete, BaseTableName)] = BaseTableDeltaName;
		}

		public string GetInsertBinding(string BaseTableName)
		{
			string tag = GetDeltaTagName(Manager.Operation.Insert, BaseTableName);
			return (string) mBindings[tag];
		}
		public string GetDeleteBinding(string BaseTableName)
		{
			string tag = GetDeltaTagName(Manager.Operation.Delete, BaseTableName);
			return (string) mBindings[tag];
		}

		private string GetBinding(Manager.Operation op, string BaseTableName, out string tag)
		{
			tag = GetDeltaTagName(op, BaseTableName);
			return (string) mBindings[tag];
		}

		static public string ReplaceMVTableTags(string query, string TableName)
		{
			string MVName = GetMVNameFromTableName(TableName);
			return query.Replace(GetTableTagName(MVName), TableName);
		}

		public string ReplaceNetmeterStageTags(string query)
		{
			return query.Replace("%%NETMETERSTAGE%%", mNetMeterStageName);
		}
		static public string ReplaceNetmeterStageTags(string query, string NetMeterStageName)
		{
			return query.Replace("%%NETMETERSTAGE%%", NetMeterStageName);
		}

		public string ReplaceBaseTableTags(string query, Manager.Operation op, string Name)
		{
			string tag = String.Empty;
			string binding = GetBinding(op, Name, out tag);
			if (binding == null)
				throw new Exception("Unable to find binding for tag=\""+tag+"\", table [" + Name + "]");

			return query.Replace(tag, binding);
		}

		// Get Materialized View table name
		static public string GetMVTableName(string MaterializedViewName)
		{
			return mMVTablePrefix + MaterializedViewName.ToLower();
		}

		static public string GetMVNameFromTableName(string MVTableName)
		{
			if (MVTableName.StartsWith(mMVTablePrefix))
				return MVTableName.Substring(mMVTablePrefix.Length);

			return null;
		}

		// Get table name tag.
		static public string GetTableTagName(string Name)
		{
			return  "%%" + Name.ToUpper() + "%%";
		}

		// Get delta table tag name
		static public string GetDeltaTagName(Manager.Operation op, string TableName)
		{
			string DeltaTagName = "%%DELTA_" + ((op == Manager.Operation.Insert) ? "INSERT" : "DELETE");
			DeltaTagName += "_" + TableName.ToUpper() + "%%";
			return DeltaTagName;
		}

		// Get deferred delete delta table name
		static public string GetDeleteDeltaTableName(string TableName)
		{
			return new DBNameHash().GetDBNameHash("d_" + TableName);
		}
		
		// Get deferred insert delta table name
		static public string GetInsertDeltaTableName(string TableName)
		{
			return new DBNameHash().GetDBNameHash("i_" + TableName);
		}

		// Return transaction delta table name
		public string GetTransactionalInsertTableName(string name)
		{
			return mNetMeterStageName + mDot + new DBNameHash().GetDBNameHash("it_" + name);
		}
		public string GetTransactionalDeleteTableName(string name)
		{
			return mNetMeterStageName + mDot + new DBNameHash().GetDBNameHash("dt_" + name);
		}

		// DATA MEMBERS:
		private Hashtable mBindings = null;
		private string mNetMeterStageName = String.Empty;
		private string mDot = ".";
		static private string mMVTablePrefix = "t_mv_";
	}
}

// EOF0