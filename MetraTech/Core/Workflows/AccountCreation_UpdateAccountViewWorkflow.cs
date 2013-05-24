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

namespace MetraTech.Core.Workflows
{
  public class UpdateAccountViewWorkflow : MTSequentialWorkflowActivity
	{
    public static DependencyProperty In_AccountProperty = DependencyProperty.Register("In_Account", typeof(MetraTech.DomainModel.BaseTypes.Account), typeof(MetraTech.Core.Workflows.UpdateAccountViewWorkflow));

    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    [BrowsableAttribute(true)]
    [CategoryAttribute("Account creation")]
    [Input]
    public MetraTech.DomainModel.BaseTypes.Account In_Account
    {
      get
      {
        return ((MetraTech.DomainModel.BaseTypes.Account)(base.GetValue(MetraTech.Core.Workflows.UpdateAccountViewWorkflow.In_AccountProperty)));
      }
      set
      {
        base.SetValue(MetraTech.Core.Workflows.UpdateAccountViewWorkflow.In_AccountProperty, value);
      }
    }
	}

}
