namespace MetraTech.Pipeline.ReRun
{
	using MetraTech.DataAccess;
	using System.EnterpriseServices;
	using System.Runtime.InteropServices;

	[Guid("0A1D566E-ACFC-479e-AFC3-B6DA2299C5FD")]
	public interface ITxnNotSupportedHelper
	{
		void CreateSessionIDTable(string tableName);
	}


	/// <summary>
	/// Helper class to execute queries outside of the main Billing Rerun transaction
	/// avoiding blocking/deadlocking
	/// </summary>
	[Transaction(TransactionOption.NotSupported)]
	[Guid("71FCB648-76FD-47ec-A017-E0297474D394")]
	[ClassInterface(ClassInterfaceType.None)]
	public class TxnNotSupportedHelper : ServicedComponent, ITxnNotSupportedHelper
	{

		// Creates a table outside of the current COM+ txn to hold session UIDs
    [AutoComplete]
    public void CreateSessionIDTable(string tableName)
    {
			using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
			{
				//drop the source table if it exists
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__DROP_T_RERUN_SOURCE_SESSIONS__"))
                {
                    stmt.AddParam("%%TABLE_NAME%%", tableName);
                    stmt.ExecuteNonQuery();
                }

				//create the source table
                using (IMTAdapterStatement stmt1 = conn.CreateAdapterStatement("queries\\BillingRerun", "__CREATE_T_RERUN_SOURCE_SESSIONS__"))
                {
                    stmt1.AddParam("%%TABLE_NAME%%", tableName);
                    stmt1.ExecuteNonQuery();
                }

				return;
			}          
    }
	}

	[Guid("49154e6b-5172-448c-9d56-a1d1df5bb1d7")]
	public interface ITxnRequiresNewHelper
	{
		void AddHistoryRow(int accID, int rerunID, string comment, string action);
    int CreateSetup(int accID, string comment);
  }

	/// <summary>
	/// Helper class to execute queries outside of the main Billing Rerun transaction
	/// avoiding blocking/deadlocking
	/// </summary>
	[Transaction(TransactionOption.RequiresNew, Isolation=TransactionIsolationLevel.Any)]
	[Guid("a351c5b3-6ae2-4b1d-98f2-88014ca02e93")]
	[ClassInterface(ClassInterfaceType.None)]
	public class TxnRequiresNewHelper : ServicedComponent, ITxnRequiresNewHelper
	{

		/// <summary>
		/// Adds a row to the t_rerun_history table outside of the transaction that 
		/// rerun is executing in.
		/// </summary>
		/// <param name = "accID">Account id from the session context identifying the user performing the billing rerun task</param>
		/// <param name = "rerunID">The key into t_rerun and identifying the tables used for all sessions
		/// that were identified for backout.</param>
		/// <param name="comment">Comment passed in by the user</param>
		/// <param name="action">Action is used to track the phase of billing rerun, identify, analyze, backout etc</param>
    [AutoComplete]
		public void AddHistoryRow(int accID, int rerunID, string comment, string action)
		{
            using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\BillingRerun", "__ADD_RERUN_HISTORY__"))
                {
                    stmt.AddParam("%%ID_RERUN%%", rerunID);
                    stmt.AddParam("%%ACTION%%", action);
                    stmt.AddParam("%%ID_ACC%%", accID);
                    stmt.AddParam("%%COMMENT%%", comment);
                    stmt.ExecuteNonQuery();
                }
            }
		}  

    [AutoComplete]
    public int CreateSetup(int accID, string comment)
    {
      int id = -1;
      using (IMTConnection conn = ConnectionManager.CreateConnection(@"Queries\BillingRerun"))
      {
          using (IMTCallableStatement stmt = conn.CreateCallableStatement("ReRunCreate"))
          {
              //tx_filter is not used
              stmt.AddParam("tx_filter", MTParameterType.String, null);

              stmt.AddParam("id_acc", MTParameterType.Integer, accID);
              stmt.AddParam("tx_comment", MTParameterType.WideString, comment);
              stmt.AddParam("dt_system_date", MTParameterType.DateTime, MetraTime.Now);

              stmt.AddOutputParam("id_rerun", MTParameterType.Integer);
              stmt.ExecuteNonQuery();

              id = (int)stmt.GetOutputValue("id_rerun");
          }
      }

      return id;
    }

	}

}
