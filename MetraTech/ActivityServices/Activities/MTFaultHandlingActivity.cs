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
using System.Diagnostics;

namespace MetraTech.ActivityServices.Activities
{
  [ActivityValidator(typeof(MTFaultHandlingActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
	public partial class MTFaultHandlingActivity: Activity
	{
		public MTFaultHandlingActivity()
		{
		}

    public static DependencyProperty ExceptionProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Exception", typeof(Exception), typeof(MTFaultHandlingActivity));

    [Description("This is the exception that caused the fault handlers to be called")]
    [Category("Fault Type")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Exception Exception
    {
      get
      {
        return ((Exception)(base.GetValue(MTFaultHandlingActivity.ExceptionProperty)));
      }
      set
      {
        base.SetValue(MTFaultHandlingActivity.ExceptionProperty, value);
      }
    }

    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
     IMASExceptionReportingService reportingSvc = executionContext.GetService<IMASExceptionReportingService>();
      Debug.Assert(reportingSvc != null);

      if (reportingSvc != null)
      {
        reportingSvc.ReportException(WorkflowInstanceId, Exception);

        string targetStateName = "";

        Activity parent = this;
        while (parent != null)
        {
          if (parent.GetType() == typeof(StateInitializationActivity))
          {
            Activity rootActivity = parent;

            while (rootActivity.Parent != null)
            {
              rootActivity = rootActivity.Parent;
            }

            StateMachineWorkflowActivity stateMachine = rootActivity as StateMachineWorkflowActivity;

            if (stateMachine != null)
            {
              targetStateName = stateMachine.PreviousStateName;
            }

            break;
          }
          else if (parent.GetType() == typeof(StateActivity))
          {
            targetStateName = parent.Name;
            
            break;
          }

          parent = parent.Parent;
        }

        if (!String.IsNullOrEmpty(targetStateName))
        {
          WorkflowQueuingService workflowQueuingService = executionContext.GetService<WorkflowQueuingService>();
          WorkflowQueue workflowQueue = workflowQueuingService.GetWorkflowQueue(StateMachineWorkflowActivity.SetStateQueueName);
          SetStateEventArgs setStateEventArgs = new SetStateEventArgs(targetStateName);
          workflowQueue.Enqueue(setStateEventArgs);
        }
      }
      else
      {
        throw Exception;
      }


      return ActivityExecutionStatus.Closed;
    }
	}

  public class MTFaultHandlingActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTFaultHandlingActivity faultHandlingActivity = obj as MTFaultHandlingActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (faultHandlingActivity.Parent == null)
      {
        return errors;
      }

      if (!(faultHandlingActivity.Parent is FaultHandlerActivity))
      {
        errors.Add(new ValidationError("MTFaultHandlingActivity must be a child of FaultHandlerActivity", 1));
      }

      return errors;
    }
  }
}
