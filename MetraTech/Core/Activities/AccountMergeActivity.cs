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
using System.Runtime.InteropServices;

namespace MetraTech.Core.Activities
{
	public class AccountMergeActivity: BaseActivity
  {
    #region Inputs and Outputs
    public static DependencyProperty SourceAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SourceAccount", typeof(Account), typeof(AccountMergeActivity));

    [Description("This is the account whose properites have been modified")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account SourceAccount
    {
      get
      {
        return ((Account)(base.GetValue(AccountMergeActivity.SourceAccountProperty)));
      }
      set
      {
        base.SetValue(AccountMergeActivity.SourceAccountProperty, value);
      }
    }

    public static DependencyProperty TargetAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("TargetAccount", typeof(Account), typeof(AccountMergeActivity));

    [Description("This is the account that contains the original values")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account TargetAccount
    {
      get
      {
        return ((Account)(base.GetValue(AccountMergeActivity.TargetAccountProperty)));
      }
      set
      {
        base.SetValue(AccountMergeActivity.TargetAccountProperty, value);
      }
    }

    public static DependencyProperty MergedAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("MergedAccount", typeof(Account), typeof(AccountMergeActivity));

    [Description("This Account object is the result of the merge")]
    [Category("Outputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Account MergedAccount
    {
      get
      {
        return ((Account)(base.GetValue(AccountMergeActivity.MergedAccountProperty)));
      }
      set
      {
        base.SetValue(AccountMergeActivity.MergedAccountProperty, value);
      }
    }
    #endregion

    #region Activity Overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
        try
        {

            #region Create Clone of Source Account
            this.MergedAccount = TargetAccount.Clone() as Account;
            #endregion

            #region Apply Modified Properties
            MergedAccount.ApplyDirtyProperties(SourceAccount);
            #endregion
        }
        catch (MASBasicException masBasEx)
        {
            Logger.LogException("Account Merge activity failed.", masBasEx);
            throw;
        }
        catch (COMException comEx)
        {
            Logger.LogException("COM Exception occurred : ", comEx);
            throw new MASBasicException(comEx.Message);
        }
        catch (Exception ex)
        {
            Logger.LogException("Exception occurred at Account Merge Activity. ", ex);
            throw new MASBasicException("Exception occurred at Account Merge Activity.");
        }
      return ActivityExecutionStatus.Closed;
    }
    #endregion
  }
}
