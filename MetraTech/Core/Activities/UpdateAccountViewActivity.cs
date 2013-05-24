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

    public partial class UpdateAccountViewActivity : BaseAccountViewActivity
  	{
      #region Activity overrides
      protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
      {
        AccountHelper.UpdateAllAccountViews(false, In_Account);
        Logger.LogInfo("Exiting UpdateAccountViewActivity.");
        return ActivityExecutionStatus.Closed;
      }
      #endregion
	}
}
