using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Workflow.ComponentModel;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.Core.Activities
{
	public class BatchCreateAccountActivity : Activity
    {
        #region Dependency Properties
        public static DependencyProperty AccountsToCreateProperty = DependencyProperty.Register("AccountsToCreate", typeof(List<Account>), typeof(BatchCreateAccountActivity));

        [System.ComponentModel.DescriptionAttribute("This is the collection of accounts to be created")]
        [System.ComponentModel.CategoryAttribute("Inputs")]
        [System.ComponentModel.BrowsableAttribute(true)]
        [System.ComponentModel.DesignerSerializationVisibilityAttribute(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public List<Account> AccountsToCreate
        {
            get
            {
                return ((List<Account>)(base.GetValue(BatchCreateAccountActivity.AccountsToCreateProperty)));
            }
            set
            {
                base.SetValue(BatchCreateAccountActivity.AccountsToCreateProperty, value);
            }
        }

        public static DependencyProperty ErrorsProperty = DependencyProperty.Register("Errors", typeof(List<string>), typeof(BatchCreateAccountActivity));

        [System.ComponentModel.DescriptionAttribute("This is the set of errors that are returned from the operation")]
        [System.ComponentModel.CategoryAttribute("Outputs")]
        [System.ComponentModel.BrowsableAttribute(true)]
        [System.ComponentModel.DesignerSerializationVisibilityAttribute(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public List<string> Errors
        {
            get
            {
                return ((List<string>)(base.GetValue(BatchCreateAccountActivity.ErrorsProperty)));
            }
            set
            {
                base.SetValue(BatchCreateAccountActivity.ErrorsProperty, value);
            }
        }
        #endregion

        #region Activity Overrides
        protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
        {
            if (AccountsToCreate != null && AccountsToCreate.Count > 0)
            {
                Errors = BatchAccountCreator.CreateAccounts(AccountsToCreate);
            }

            return ActivityExecutionStatus.Closed;
        }
        #endregion
    }
}
