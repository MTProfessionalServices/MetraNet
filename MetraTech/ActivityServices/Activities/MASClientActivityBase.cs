using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using System.ComponentModel;

namespace MetraTech.ActivityServices.Activities
{
  public abstract class  CMASClientActivityBase : Activity
  {
    public CMASClientActivityBase()
    {
    }
  }

  public abstract class CMASEventClientActivityBase : CMASClientActivityBase
  {
    public CMASEventClientActivityBase()
    {
      StateInitOutputs = new Dictionary<string, object>();
    }

    #region StateInitOutputs Property
    public static DependencyProperty StateInitOutputsProperty = System.Workflow.ComponentModel.DependencyProperty.Register("StateInitOutputs", typeof(Dictionary<string,object>), typeof(CMASEventClientActivityBase));

    [Description("This is the collection of state initialzation outputs")]
    [Category("Activity Results")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Dictionary<string, object> StateInitOutputs
    {
      get
      {
        return ((Dictionary<string, object>)(base.GetValue(CMASEventClientActivityBase.StateInitOutputsProperty)));
      }
      set { this.SetValue(StateInitOutputsProperty, value); }
    }
    #endregion
  }

  public abstract class CMASEventMIClientActivityBase : CMASEventClientActivityBase
  {
    public CMASEventMIClientActivityBase()
    {
    }

    #region ProcessorInstanceId Property
    public static DependencyProperty ProcessorInstanceIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("ProcessorInstanceId", typeof(Guid), typeof(CMASEventMIClientActivityBase));

    [Description("This is the identifier of the workflow type instance to use")]
    [Category("Processor Instance")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Guid ProcessorInstanceId
    {
      get
      {
        return ((Guid)(base.GetValue(CMASEventMIClientActivityBase.ProcessorInstanceIdProperty)));
      }
      set
      {
        base.SetValue(CMASEventMIClientActivityBase.ProcessorInstanceIdProperty, value);
      }
    }
    #endregion
  }
}
