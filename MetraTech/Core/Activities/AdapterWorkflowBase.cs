using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.ActivityServices.Activities;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using System.Workflow.ComponentModel;
using System.ComponentModel;

namespace MetraTech.Core.Activities
{
	public partial class MTAdapterWorkflowBase : MTSequentialWorkflowActivity
	{
    public static DependencyProperty EventNameProperty = System.Workflow.ComponentModel.DependencyProperty.Register("EventName", typeof(string), typeof(MTAdapterWorkflowBase));

    [Description("This is the name of the recurring event")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string EventName
    {
      get
      {
        return ((string)(base.GetValue(MTAdapterWorkflowBase.EventNameProperty)));
      }
      set
      {
        base.SetValue(MTAdapterWorkflowBase.EventNameProperty, value);
      }
    }

    public static DependencyProperty ConfigFileProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ConfigFile", typeof(string), typeof(MTAdapterWorkflowBase));

    [Description("This is the path to the configuration file")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string ConfigFile
    {
      get
      {
        return ((string)(base.GetValue(MTAdapterWorkflowBase.ConfigFileProperty)));
      }
      set
      {
        base.SetValue(MTAdapterWorkflowBase.ConfigFileProperty, value);
      }
    }

    public static DependencyProperty ExecutionContextProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ExecutionContext", typeof(IRecurringEventRunContext), typeof(MTAdapterWorkflowBase));

    [Description("This is the exeuction context that is passed to the adapter by UsageServer")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public IRecurringEventRunContext ExecutionContext
    {
      get
      {
        return ((IRecurringEventRunContext)(base.GetValue(MTAdapterWorkflowBase.ExecutionContextProperty)));
      }
      set
      {
        base.SetValue(MTAdapterWorkflowBase.ExecutionContextProperty, value);
      }
    }

    public static DependencyProperty SecurityContextProperty = System.Workflow.ComponentModel.DependencyProperty.Register("SecurityContext", typeof(IMTSessionContext), typeof(MTAdapterWorkflowBase));

    [Description("This is the security context given to the adapter by the UsageServer")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public IMTSessionContext SecurityContext
    {
      get
      {
        return ((IMTSessionContext)(base.GetValue(MTAdapterWorkflowBase.SecurityContextProperty)));
      }
      set
      {
        base.SetValue(MTAdapterWorkflowBase.SecurityContextProperty, value);
      }
    }
  }
}
