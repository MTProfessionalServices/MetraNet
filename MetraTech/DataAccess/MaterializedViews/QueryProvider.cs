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
using MetraTech;
using MetraTech.DataAccess;
using MetraTech.Interop.SysContext;
using QueryAdapter = MetraTech.Interop.QueryAdapter;

// Materialized view info and interface implementations.
namespace MetraTech.DataAccess.MaterializedViews
{
	/// <summary>
	/// This is the interface that must be implemented by 
	/// each materialized view in provide SQL used to update the
	/// materialized view.
	/// </summary>
	[ComVisible(true)]
	[Guid("AF906480-4774-4553-95D4-8DFEF5BC70D8")]
	public interface IQueryProvider
	{
		/// <summary>
		/// The queries to be executed when materialized view is initialized.
		/// </summary>
		/// <param name="ctx"></param>
		/// <returns></returns>
		string GetInitializeQuery(IMaterializedViewContext ctx);

		/// <summary>
		/// The the queries necessary to update this materialized view.
		/// </summary>
		/// <param name="ctx"></param>
		/// <param name="UpdateQuery"></param>
		/// <returns></returns>
		string GetUpdateQuery(IMaterializedViewContext ctx);

		/// <summary>
		/// This materialized view is no longer needed, free and resource.
		/// This call may return SQL that must be executed in the caller's
		/// transaction context.
		/// </summary>
		string GetReleaseQuery(IMaterializedViewContext ctx);

		/// <summary>
		/// Returns true if Query provider can dynamically generate 
		/// queries and does not need the framwork to require operation queries
		/// in the materialized view configuration file. If false framework
		/// will require that Events are configured.
		/// </summary>
		/// <returns></returns>
		bool SupportsCustomQueries
		{ get; }
	}

	/// <summary>
	/// Implementation of materialized view interface
	/// used to generate queries for the out of the box materialized views.
	/// </summary>
	[ComVisible(true)]
	[ClassInterface(ClassInterfaceType.None)]
	[Guid("FD18C87A-7FB3-4ffc-B5C0-8317A7342B84")]
	public class QueryProvider : IQueryProvider
	{
		private QueryAdapter.IMTQueryAdapter mQueryAdapter = new QueryAdapter.MTQueryAdapter();
		private Logger mLogger = new Logger("[QueryProvider]");

		public QueryProvider()
		{
			/* Do nothing here */
		}

		public string GetInitializeQuery(IMaterializedViewContext ctx)
		{
			// Nothing to return.
			return null;
		}

		public string GetUpdateQuery(IMaterializedViewContext ctx)
		{
			// Format trigger list as a comma delimitted string.
			string TriggerList = null;
			foreach(string name in ctx.Triggers)
			{
				if (TriggerList == null)
					TriggerList = name;
				else
					TriggerList += "," + name;
			}

			if (TriggerList == null)
			{
				string msg = "Empty trigger list specified for Materialized View(" + ctx.Name + ").";
				mLogger.LogError(msg);
				throw new Exception(msg);
			}

			object utObj = System.DBNull.Value;

			// Given the materialized view and set of triggers determine
			// which queries fit best. This implementation requires that we have
			// and exact trigger match. This means that if not all the 
			// base tables that this materialized view depends on are metered then 
			// we have a misconfiguration and we should throw.
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				try
				{
					// *** We support exact match only *** - find rule that matches all the triggers
					// Get the query tags associated with an event that exactly matches our trigger set.
                    using (IMTCallableStatement call = conn.CreateCallableStatement("GetMaterializedViewQueryTags"))
                    {
                        call.AddParam("mv_name", MTParameterType.String, ctx.Name);
                        call.AddParam("operation_type", MTParameterType.String, ctx.OperationType);
                        call.AddParam("base_table_name", MTParameterType.String, TriggerList);
                        call.AddOutputParam("UpdateTag", MTParameterType.String, 200);
                        call.ExecuteNonQuery();

                        // Get output value.
                        utObj = call.GetOutputValue("UpdateTag");
                        if (utObj == System.DBNull.Value)
                        {
                            mLogger.LogInfo("No queries configured for operation(" + ctx.OperationType + "), Materialized View(" + ctx.Name + "), triggers: " + TriggerList);
                            return null;
                        }
                    }
				}
				catch (Exception e)
				{
					mLogger.LogError("Failed to get queries. " + e.Message);
					return null;
				}
			}

			// Initialize return value.
			string UpdateQuery = String.Empty;
			try
			{
				// Get queries using the tags.
				mQueryAdapter.Init(ctx.QueryPath);
				mQueryAdapter.SetQueryTag((string)utObj);
				UpdateQuery += " " + mQueryAdapter.GetRawSQLQuery(true);
			}
			catch (Exception e)
			{
				mLogger.LogError("Failed to get queries. " + e.Message);
				return null;
			}

			return UpdateQuery;
		}

		public string GetReleaseQuery(IMaterializedViewContext ctx)
		{
			// Nothing to return
			return null;
		}

		public bool SupportsCustomQueries
		{
			get { return false; } 
		}
	}
}

// EOF