using System;
using System.Reflection;
using System.Collections.Generic;
using System.Text;
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
using System.ServiceModel;

using MetraTech;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.Interop.MTAuth;
using MetraTech.ActivityServices.Common;
using MetraTech.DataAccess.MaterializedViews;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.Core.Activities
{
  public class BaseAccountActivity : BaseActivity
  {
    #region Properties
    public static DependencyProperty In_AccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("In_Account", typeof(Account), typeof(BaseAccountActivity));

    [Description("MetraNet domain model account object; used for account creation and update. This property must be set in order to use the activity.")]
    [Category("Account creation")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account In_Account
    {
      get
      {
        return ((Account)(base.GetValue(BaseAccountActivity.In_AccountProperty)));
      }
      set
      {
        base.SetValue(BaseAccountActivity.In_AccountProperty, value);
      }
    }

    public IMTSessionContext SessionContext
    {
      get
      {
        IMTSessionContext cntx = null;

        if (ServiceSecurityContext.Current != null)
        {
          // Get identity context.
          CMASClientIdentity clientIdentity = ServiceSecurityContext.Current.PrimaryIdentity as CMASClientIdentity;

          if (clientIdentity != null)
          {
            cntx = clientIdentity.SessionContext;
          }
        }

        return cntx;
      }
    }
    #endregion


    #region Methods

    public void UpdateMaterializedViews(bool isUpdate)
    {
      Manager materializedViewManager = new Manager();
      materializedViewManager.Initialize();

      if (!materializedViewManager.IsMetraViewSupportEnabled)
      {
        Logger.LogDebug("Materialized views are not enabled for MetraView.");
        return;
      }
      string baseTableName = "t_dm_account";

      string insertDeltaTableName = materializedViewManager.GenerateDeltaInsertTableName(baseTableName);
      string deleteDeltaTableName = materializedViewManager.GenerateDeltaDeleteTableName(baseTableName);

      // Enable caching support.
      materializedViewManager.EnableCache(true);

      // Prepare the base table bindings.
      materializedViewManager.AddInsertBinding(baseTableName, insertDeltaTableName);
      materializedViewManager.AddDeleteBinding(baseTableName, deleteDeltaTableName);

      using (IMTConnection conn = ConnectionManager.CreateConnection()) // ("Queries\AccHierarchies"))
      {
            using (IMTAdapterStatement stmt =
              conn.CreateAdapterStatement(@"Queries\AccountCreation", "__CREATE_ACCOUNT_DELTA_TABLE__"))
            {

        stmt.AddParam("%%TABLE_NAME%%", insertDeltaTableName, true);

        stmt.ExecuteNonQuery();
        stmt.ClearQuery();

        string mvquery = String.Empty;
        if (isUpdate)
        {
          stmt.QueryTag = "__UPDATE_ACCOUNT_DELTA_TABLE__";
          mvquery = materializedViewManager.GetMaterializedViewUpdateQuery(new string[] { baseTableName });
        }
        else
        {
          stmt.QueryTag = "__INSERT_INTO_ACCOUNT_DELTA_TABLE__";
          mvquery = materializedViewManager.GetMaterializedViewInsertQuery(new string[] { baseTableName });
        }

        stmt.AddParam("%%TABLE_NAME%%", baseTableName);
        stmt.AddParam("%%DELTA_TABLE_NAME%%", insertDeltaTableName);
        stmt.AddParam("%%ID_ACC_LIST%%", In_Account._AccountID);
        stmt.ExecuteNonQuery();

        if (!String.IsNullOrEmpty(mvquery))
        {
                    using (IMTStatement mvStmt = conn.CreateStatement(mvquery))
                    {
          mvStmt.ExecuteNonQuery();
}
        }

        stmt.ClearQuery();
        stmt.QueryTag = "__TRUNCATE_ACCOUNT_DELTA_TABLE__";
        stmt.AddParam("%%TABLE_NAME%%", insertDeltaTableName);
        stmt.ExecuteNonQuery();

        stmt.ClearQuery();
        stmt.QueryTag = "__TRUNCATE_ACCOUNT_DELTA_TABLE__";
        stmt.AddParam("%%TABLE_NAME%%", deleteDeltaTableName);
        stmt.ExecuteNonQuery();
      }
    }
    }

    public void CheckPaymentAuth(Account account)
    {
      IMTSecurity security = new MTSecurityClass();
      MetraTech.Interop.MTAuth.IMTCompositeCapability capability = null;

      try
      {
        InternalView internalView = (InternalView)account.GetInternalView();
        if (internalView.Billable.HasValue && internalView.Billable.Value == true)
        {
          capability = security.GetCapabilityTypeByName("Manage billable accounts").CreateInstance();
          SessionContext.SecurityContext.CheckAccess(capability);
        }

        if (account.PayerAccount != null || account.PayerID != null)
        {
          capability = security.GetCapabilityTypeByName("Manage Payment Redirection").CreateInstance();
          SessionContext.SecurityContext.CheckAccess(capability);
        }
      }
      finally
      {
        Marshal.ReleaseComObject(security);
      }
    }
      
    public static DateTime? ConvertToUtc(DateTime? dateTime)
    {
      DateTime? utc = null;
      if (dateTime.HasValue)
      {
        utc = dateTime.Value.ToUniversalTime();
      }
      return utc;
    }
    
    #endregion

    #region Activity Overrides
    //protected override ActivityExecutionStatus HandleFault(ActivityExecutionContext executionContext, Exception exception)
    //{
    //  PropertyInfo propertyInfo = null;
    //  Activity rootActivity = Parent;
    //  while (rootActivity != null)
    //  {
    //    propertyInfo = rootActivity.GetType().GetProperty("MTError");
    //    if (propertyInfo != null)
    //    {
    //      propertyInfo.SetValue(rootActivity, exception, null);
    //      break;
    //    }

    //    rootActivity = rootActivity.Parent;
    //  }

    //  return base.HandleFault(executionContext, exception);
    //}
    #endregion
  }
}
