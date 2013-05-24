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
  public interface IMASStateInitOutput
  {
    void PostOutputs(Guid workflowId, Dictionary<string,object> outputData);
  }

  [ActivityValidator(typeof(MTStateInitOutputActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
	public class MTStateInitOutputActivity : Activity
  {
    #region Constructor
    public MTStateInitOutputActivity()
		{
    }
    #endregion

    #region Activity Overrides
    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      IMASStateInitOutput outputSvc = executionContext.GetService<IMASStateInitOutput>();
      Debug.Assert(outputSvc != null);

      if (outputSvc != null)
      {
        Activity rootActivity = this;
        StateActivity parentState = null;
        Dictionary<string, object> outputData = new Dictionary<string, object>();

        while (rootActivity.Parent != null)
        {
          rootActivity = rootActivity.Parent;
        }

        Activity parent = this;
        while (parentState == null && parent != null)
        {
          parentState = parent.Parent as StateActivity;
          parent = parent.Parent;
        }

        if (parentState != null)
        {
          Type rootType = rootActivity.GetType();
          PropertyInfo[] propInfos = rootType.GetProperties(BindingFlags.Instance | BindingFlags.Public);
          object[] customAttribs;

          if (parentState is MTPageStateActivity)
          {
            outputData.Add("PageName", ((MTPageStateActivity)parentState).PageName);
            outputData.Add("PageInstanceId", ((MTPageStateActivity)parentState).PageInstanceId);
          }

          foreach (PropertyInfo propInfo in propInfos)
          {
            customAttribs = propInfo.GetCustomAttributes(typeof(StateInitOutputAttribute), false);

            foreach (StateInitOutputAttribute customAttrib in customAttribs)
            {
              if (customAttrib.StateName == parentState.Name)
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

          outputSvc.PostOutputs(WorkflowInstanceId, (outputData.Count > 0 ? outputData : null));
        }
      }
      else
      {
        throw new ApplicationException("IMASStateInitOutput service is not available");
      }

      return ActivityExecutionStatus.Closed;
    }
    #endregion
  }

  public class MTStateInitOutputActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTStateInitOutputActivity stateInitOutputActivity = obj as MTStateInitOutputActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (stateInitOutputActivity.Parent == null)
      {
        return errors;
      }

      if (!(stateInitOutputActivity.Parent is StateInitializationActivity))
      {
        errors.Add(new ValidationError("MTStateInitOutputActivity must be a child of StateInitializationActivity", 1));
      }

      return errors;
    }
  }
}
