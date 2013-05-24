using System;
using System.Runtime.InteropServices;

namespace MetraTech.Product.Hooks
{
	using MetraTech.DataAccess;
	using MetraTech.DataAccess.MaterializedViews;

	/// <summary>
	/// Hook used to populate and update Materialized View configuration tables.
	/// </summary>
	[Guid("54DB7DCB-9113-47c1-AD1D-DA419FFFF904")]
	[ClassInterface(ClassInterfaceType.None)]
	public class MaterializedViewHook : MetraTech.Interop.MTHooklib.IMTHook
	{
		/// <summary>
		/// Constructor
		/// </summary>
		public MaterializedViewHook()
		{
			mLogger = new Logger("[MaterializedViewHook]");
		}

		/// <summary>
		/// Run the materialized view hook
		/// </summary>
		public void Execute(/*[in]*/ object var,/*[in, out]*/ ref int pVal)
		{
			try
			{
				mLogger.LogDebug("Starting hook execution.");

				// Initialize Materialized View Manager on first use.
				if (mMaterializedViewMgr == null)
				{
					mMaterializedViewMgr = new Manager();
					mMaterializedViewMgr.Initialize();
				}

				// Always run update incase we're turning on the materialized view framework.
				mMaterializedViewMgr.UpdateMaterializedViewConfiguration();

				//-----
				// Create adjustment summary data view.
				//
				// xxx HACK: The MV framework never supported this case.
				// This view depends on: t_adjustment_transaction and t_mv_max_sess
				// However the adjustment materialized view has no queries
				// that depend on max_sess.
				//
				// We may need a mechanism to identify create query dependencies.
				//-----
				if (mMaterializedViewMgr.IsMetraViewSupportEnabled)
				{
					string QueryPath = "Queries\\MaterializedViews\\MetraView";
                    using (IMTConnection conn = ConnectionManager.CreateConnection())
                    {
                        // Create view based on adjustment tables.
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueryPath, "__DROP_ADJUSTMENT_DATAMART_VIEWS__"))
                        {
                            stmt.ExecuteNonQuery();
                        }

                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueryPath, "__CREATE_ADJUSTMENT_DATAMART_VIEWS__"))
                        {
                            stmt.ExecuteNonQuery();
                        }

                        // Create GetBalances datamart procedure.
                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueryPath, "__DROP_GET_BALANCES_DATAMART_SPROC__"))
                        {
                            stmt.ExecuteNonQuery();
                        }

                        using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(QueryPath, "__CREATE_GETBALANCES_DATAMART_SPROC__"))
                        {
                            stmt.ExecuteNonQuery();
                        }
                    }
				}

				// Done.
				mLogger.LogDebug("Done executing hook.");
			}
			catch(System.Exception ex)
			{
				mLogger.LogError(ex.ToString());
				throw ex;
			}
		}

		// Logging object
		private MetraTech.Logger mLogger = null;
		
		// Materizlized manager object.
		private Manager mMaterializedViewMgr = null; // Initialize on first use
	}
}

// EOF