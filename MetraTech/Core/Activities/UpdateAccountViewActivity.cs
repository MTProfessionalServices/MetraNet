using System;
using System.Transactions;
using System.Reflection;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.Interop.MTAccount;
using MetraTech.DomainModel.Common;

namespace MetraTech.Core.Activities
{
    using MetraTech.DomainModel.Common;
    using MetraTech.ActivityServices.Common;
    using MetraTech.DataAccess;

    public partial class UpdateAccountViewActivity : BaseAccountViewActivity
  	{
      #region Activity overrides
      protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
      {
        AccountHelper.UpdateAllAccountViews(false, In_Account);
        using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
        {
            using (IMTCallableStatement stmt = conn.CreateCallableStatement("ApplyTemplateToOneAccount"))
            {

                stmt.AddParam("accountID", MTParameterType.Integer, In_Account._AccountID);
                stmt.AddParam("p_systemdate", MTParameterType.DateTime, MetraTime.Now);
                stmt.AddParam("p_acc_type", MTParameterType.String, In_Account.AccountType);
                try
                {
                    stmt.ExecuteNonQuery();
                }
                catch (Exception e)
                {
                    Logger.LogError("Exception applying templates to acct with ID: {0}", In_Account._AccountID);
                    throw e;
                }
            }
        }
        Logger.LogInfo("Exiting UpdateAccountViewActivity.");
        return ActivityExecutionStatus.Closed;
      }
      #endregion
	}
}
