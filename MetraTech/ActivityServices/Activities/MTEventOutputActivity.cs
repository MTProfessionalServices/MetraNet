using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Reflection;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;

namespace MetraTech.ActivityServices.Activities
{
  [ExternalDataExchange]
  public interface IMASEventOutput
  {
    void ReportResults(Guid workflowId, Dictionary<string, object> outputs);
  }

  [ActivityValidator(typeof(MTEventOutputActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
	public class MTEventOutputActivity : Activity
  {
    #region Constructor
    public MTEventOutputActivity()
		{
    }
    #endregion

    #region Dependency Properties
    public static DependencyProperty EventNameProperty =
      DependencyProperty.Register("EventName",
                                  typeof(string),
                                  typeof(MTEventOutputActivity),
                                  new PropertyMetadata(DependencyPropertyOptions.Metadata));
    #endregion

    #region Public Properties
    [Description("Name of the event whose data is being output")]
    [Category("Event")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string EventName
    {
      get
      {
        return ((string)(base.GetValue(MTEventOutputActivity.EventNameProperty)));
      }
      set
      {
        base.SetValue(MTEventOutputActivity.EventNameProperty, value);
      }
    }
    #endregion

    #region Activity Overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      IMASEventOutput outputSvc = executionContext.GetService<IMASEventOutput>();
      Debug.Assert(outputSvc != null);

      if (outputSvc != null)
      {
        Activity rootActivity = this;
        Dictionary<string, object> outputData = new Dictionary<string, object>();

        while (rootActivity.Parent != null)
        {
          rootActivity = rootActivity.Parent;
        }

        Type rootType = rootActivity.GetType();
        PropertyInfo[] propInfos = rootType.GetProperties(BindingFlags.Instance | BindingFlags.Public);
        object[] customAttribs;

        foreach (PropertyInfo propInfo in propInfos)
        {
          customAttribs = propInfo.GetCustomAttributes(typeof(EventOutputArgAttribute), false);

          foreach (EventOutputArgAttribute customAttrib in customAttribs)
          {
            if (customAttrib.EventName == this.EventName)
            {
              object data = propInfo.GetValue(rootActivity, null);

              if (!outputData.ContainsKey(propInfo.Name))
              {
                outputData.Add(propInfo.Name, data);
              }
              else
              {
                outputData[propInfo.Name] = data;
              }

              break;
            }
          }
        }

        outputSvc.ReportResults(WorkflowInstanceId, outputData);
      }
      else
      {
        throw new ApplicationException("IMASEventOutput service is not available");
      }

      return ActivityExecutionStatus.Closed;
    }
    #endregion
  }

  public class MTEventOutputActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTEventOutputActivity eventHandlerOutputActivity = obj as MTEventOutputActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (eventHandlerOutputActivity.Parent == null)
      {
        return errors;
      }

      // Must specify event name
      if (String.IsNullOrEmpty(eventHandlerOutputActivity.EventName))
      {
        errors.Add(ValidationError.GetNotSetValidationError("EventName"));
      }

      if (!(eventHandlerOutputActivity.Parent is EventDrivenActivity))
      {
        errors.Add(new ValidationError("MTEventOutputActivity must be a child of EventDrivenActivity", 1));
      }

      return errors;
    }
  }
}
