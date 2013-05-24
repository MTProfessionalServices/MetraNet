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
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.ActivityServices.Common;
using MetraTech.Interop.Subscription;
using MetraTech.Interop.MTProductCatalog;

namespace MetraTech.Core.Workflows
{
    public class AddAccountWorkflow : BaseAccountWorkflowActivity
    {
        public static DependencyProperty ARExtAccountIDProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARExtAccountID", typeof(string), typeof(MetraTech.Core.Workflows.AddAccountWorkflow));

        [Description("NewLoginName for this account on the AR/External system")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string ARExtAccountID
        {
            get
            {
                return ((string)(base.GetValue(MetraTech.Core.Workflows.AddAccountWorkflow.ARExtAccountIDProperty)));
            }
            set
            {
                base.SetValue(MetraTech.Core.Workflows.AddAccountWorkflow.ARExtAccountIDProperty, value);
            }
        }

        public static DependencyProperty ARExternalNameSpaceProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ARExternalNameSpace", typeof(string), typeof(MetraTech.Core.Workflows.AddAccountWorkflow));

        [Description("ARExternalNameSpace for this account on the AR/External system")]
        [Category("This is the category which will be displayed in the Property Browser")]
        [Browsable(true)]
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public string ARExternalNameSpace
        {
            get
            {
                return ((string)(base.GetValue(MetraTech.Core.Workflows.AddAccountWorkflow.ARExternalNameSpaceProperty)));
            }
            set
            {
                base.SetValue(MetraTech.Core.Workflows.AddAccountWorkflow.ARExternalNameSpaceProperty, value);
            }
        }

        public void codeActivity1_ExecuteCode(object sender, EventArgs e)
        {

            this.ARExtAccountID = In_Account.UserName;

            if (this.ARExtAccountID.Length >= 3)
            {
                string SubNameSpace = this.ARExtAccountID.Substring(0, 3);

                if (SubNameSpace == "CAN")
                {
                    ARExternalNameSpace = "ar/canada";
                }
                else if (SubNameSpace == "EUR")
                {
                    ARExternalNameSpace = "ar/europe";
                }
                else if (SubNameSpace == "NAR")
                {
                    ARExternalNameSpace = "";
                }
                else
                {
                    ARExternalNameSpace = "ar/external";
                }
            }
            else
            {
                ARExternalNameSpace = "ar/external";
            }

        }
    }
}
