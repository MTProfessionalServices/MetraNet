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

namespace MetraTech.ActivityServices.Activities
{
  [ActivityValidator(typeof(MTSetPageStateActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
	public class MTSetPageStateActivity : Activity
	{
		public MTSetPageStateActivity()
		{
		}

    public static DependencyProperty StateGuidProperty = System.Workflow.ComponentModel.DependencyProperty.Register("StateGuid", typeof(Guid), typeof(MTSetPageStateActivity));

    [Description("This is the Guid for the state to be set")]
    [Category("Inputs")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public Guid StateGuid
    {
      get
      {
        return ((Guid)(base.GetValue(MTSetPageStateActivity.StateGuidProperty)));
      }
      set
      {
        base.SetValue(MTSetPageStateActivity.StateGuidProperty, value);
      }
    }

    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      Activity rootActivity = this;

      while (rootActivity.Parent != null)
      {
        rootActivity = rootActivity.Parent;
      }

      if (rootActivity is MTStateMachineWorkflowActivity)
      {
        MTStateMachineWorkflowActivity workflow = rootActivity as MTStateMachineWorkflowActivity;

        foreach (Activity child in workflow.Activities)
        {
          if (child is MTPageStateActivity)
          {
            MTPageStateActivity mtPageState = child as MTPageStateActivity;

            if (mtPageState.PageInstanceId == StateGuid)
            {
              if (mtPageState.Name != workflow.CurrentStateName)
              {
                WorkflowQueuingService wqs = executionContext.GetService<WorkflowQueuingService>();

                WorkflowQueue queue = wqs.GetWorkflowQueue("SetStateQueue");

                SetStateEventArgs e = new SetStateEventArgs(mtPageState.Name);

                queue.Enqueue(e);
              }
            }
          }
        }
      }
      else
      {
      }

      return ActivityExecutionStatus.Closed;
    }
	}

  public class MTSetPageStateActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTSetPageStateActivity setPageActivity = obj as MTSetPageStateActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (setPageActivity.Parent == null)
      {
        return errors;
      }

      return errors;
    }
  }
}
