using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;
using System.Runtime.InteropServices;
using System.ServiceModel;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTAuditEvents;

namespace MetraTech.Core.Activities
{
  public class AccountAuditActivity : BaseActivity
  {
    #region Inputs and Outputs
    public static DependencyProperty SourceAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SourceAccount", typeof(Account), typeof(AccountAuditActivity));

    [Description("This is the account whose properites have been modified")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account SourceAccount
    {
      get
      {
        return ((Account)(base.GetValue(AccountAuditActivity.SourceAccountProperty)));
      }
      set
      {
        base.SetValue(AccountAuditActivity.SourceAccountProperty, value);
      }
    }

    public static DependencyProperty TargetAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("TargetAccount", typeof(Account), typeof(AccountAuditActivity));

    [Description("This is the account that contains the original values")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account TargetAccount
    {
      get
      {
        return ((Account)(base.GetValue(AccountAuditActivity.TargetAccountProperty)));
      }
      set
      {
        base.SetValue(AccountAuditActivity.TargetAccountProperty, value);
      }
    }
    #endregion

    #region Activity Overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      try
      {
        #region Audit Modified Properties
        var resourceManager = new ResourcesManager();
        var sessionContext = GetSessionContext();
        int userAccount = sessionContext.AccountID;
        String changedProps = TargetAccount.AuditDirtyProperties(SourceAccount, userAccount);
        var auditor = new Auditor();
        if (changedProps != "")
        {
          changedProps = String.Format(resourceManager.GetLocalizedResource("SUCCESSFULLY_UPDATED_ACCOUNT_FOR"),
            SourceAccount.UserName, SourceAccount._AccountID) + changedProps;
          auditor.FireEventWithAdditionalData((int) MTAuditEvent.AUDITEVENT_ACCOUNT_UPDATE, userAccount,
                                              (int) MTAuditEntityType.AUDITENTITY_TYPE_ACCOUNT,
                                              TargetAccount._AccountID.Value, changedProps, 
                                              sessionContext.LoggedInAs,
                                              sessionContext.ApplicationName);
        }

        #endregion
      }
      catch (MASBasicException masBasEx)
      {
        Logger.LogException("Account Audit activity failed.", masBasEx);
        throw;
      }
      catch (COMException comEx)
      {
        Logger.LogException("COM Exception occurred : ", comEx);
        throw new MASBasicException(comEx.Message);
      }
      catch (Exception ex)
      {
        Logger.LogException("Exception occurred at Account Audit Activity. ", ex);
        throw new MASBasicException("Exception occurred at Account Audit Activity.");
      }
      return ActivityExecutionStatus.Closed;
    }
    #endregion


    private YAAC.IMTSessionContext GetSessionContext()
    {
      YAAC.IMTSessionContext retval = null;

      CMASClientIdentity identity = null;
      try
      {
        identity = (CMASClientIdentity)ServiceSecurityContext.Current.PrimaryIdentity;

        retval = (YAAC.IMTSessionContext)identity.SessionContext;
      }
      catch (Exception)
      {
        throw new MASBasicException("Service security identity is of improper type");
      }

      return retval;
    }
  }
}
