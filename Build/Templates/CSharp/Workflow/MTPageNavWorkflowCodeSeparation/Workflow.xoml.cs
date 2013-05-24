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

namespace $rootnamespace$
{
  public partial class $safeitemname$ : MTStateMachineWorkflowActivity
	{
    public static DependencyProperty PageStateGuidProperty = System.Workflow.ComponentModel.DependencyProperty.Register("PageStateGuid", typeof(Guid), typeof($safeitemname$));

    [Description("This stores the page state guid for the SetState Event")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Guid PageStateGuid
    {
      get
      {
        return ((Guid)(base.GetValue($safeitemname$.PageStateGuidProperty)));
      }
      set
      {
        base.SetValue($safeitemname$.PageStateGuidProperty, value);
      }
    }
	}

}
