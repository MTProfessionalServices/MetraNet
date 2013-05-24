using System;
using System.ComponentModel;
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
using MetraTech.ActivityServices.Activities;
using MetraTech.DomainModel.Common;
using MetraTech.ActivityServices.Common;

namespace MetraTech.Core.Workflows
{
    public partial class UpdateAccountWorkflow : BaseAccountWorkflowActivity
    {
        public AccountIdentifier InAccountID
        {
            get
            {
                if (In_Account._AccountID.HasValue)
                {
                    return new AccountIdentifier(In_Account._AccountID.Value);
                }
                else
                {
                    return new AccountIdentifier(In_Account.UserName, In_Account.Name_Space);
                }
            }
        }

        public static DependencyProperty LoadTimeProperty = System.Workflow.ComponentModel.DependencyProperty.Register("LoadTime", typeof(DateTime?), typeof(UpdateAccountWorkflow));

        [Description("LoadTime")]
        [Category("Misc")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public DateTime? LoadTime
        {
            get
            {
                return ((DateTime?)(base.GetValue(UpdateAccountWorkflow.LoadTimeProperty))) ?? MetraTime.Now;
            }
            set
            {
                base.SetValue(UpdateAccountWorkflow.LoadTimeProperty, value);
            }
        }

        public static DependencyProperty LoadedAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("LoadedAccount", typeof(MetraTech.DomainModel.BaseTypes.Account), typeof(UpdateAccountWorkflow));

        [Category("Misc")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public MetraTech.DomainModel.BaseTypes.Account LoadedAccount
        {
            get
            {
                return ((MetraTech.DomainModel.BaseTypes.Account)(base.GetValue(UpdateAccountWorkflow.LoadedAccountProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountWorkflow.LoadedAccountProperty, value);
            }
        }

        public static DependencyProperty MergedAccountProperty = System.Workflow.ComponentModel.DependencyProperty.Register("MergedAccount", typeof(MetraTech.DomainModel.BaseTypes.Account), typeof(UpdateAccountWorkflow));

        [Description("This is the account with the loaded values merged with the submitted values")]
        [Category("Misc")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public MetraTech.DomainModel.BaseTypes.Account MergedAccount
        { 
            get
            {
                return ((MetraTech.DomainModel.BaseTypes.Account)(base.GetValue(UpdateAccountWorkflow.MergedAccountProperty)));
            }
            set
            {
                base.SetValue(UpdateAccountWorkflow.MergedAccountProperty, value);
            }
        }


        public void CheckPayerProperties_ExecuteCode(object sender, EventArgs e)
        {
          if ((In_Account.PayerID.HasValue) && ((String.IsNullOrEmpty(In_Account.PayerAccount) && String.IsNullOrEmpty(In_Account.PayerAccountNS))))
          {
            MergedAccount.PayerAccount = null;
            MergedAccount.PayerAccountNS = null;
          }
          else if ((!String.IsNullOrEmpty(In_Account.PayerAccountNS) && !String.IsNullOrEmpty(In_Account.PayerAccount)) && (!In_Account.PayerID.HasValue))
          {
            MergedAccount.PayerID = null;
          }

          if ((In_Account.AncestorAccountID.HasValue) && ((String.IsNullOrEmpty(In_Account.AncestorAccount) && String.IsNullOrEmpty(In_Account.AncestorAccountNS))))
          {
              MergedAccount.AncestorAccount= null;
              MergedAccount.AncestorAccountNS = null;
          }
          else if ((!String.IsNullOrEmpty(In_Account.AncestorAccountNS) && !String.IsNullOrEmpty(In_Account.AncestorAccount)) && (!In_Account.AncestorAccountID.HasValue))
          {
              MergedAccount.AncestorAccountID = null;
          }
        }
    }

}