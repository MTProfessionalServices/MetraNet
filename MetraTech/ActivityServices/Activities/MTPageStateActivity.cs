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
  [ActivityValidator(typeof(MTPageStateActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
	public partial class MTPageStateActivity: StateActivity
	{
		public MTPageStateActivity()
		{
      this.SetReadOnlyPropertyValue(PageInstanceIdProperty, Guid.NewGuid());
		}

    public static DependencyProperty PageNameProperty = DependencyProperty.Register("PageName", typeof(string), typeof(MTPageStateActivity), new PropertyMetadata(DependencyPropertyOptions.Metadata));

    [Description("This stores the name of the UI page that this state represents")]
    [Category("UI Page Info")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string PageName
    {
      get { return (string)base.GetValue(MTPageStateActivity.PageNameProperty); }
      set { base.SetValue(MTPageStateActivity.PageNameProperty, value); }
    }

    public static DependencyProperty PageInstanceIdProperty = DependencyProperty.Register("PageInstanceId", typeof(Guid), typeof(MTPageStateActivity), new PropertyMetadata(DependencyPropertyOptions.ReadOnly | DependencyPropertyOptions.Metadata));

    [Description("This generates a unique Id for the page instance")]
    [Category("UI Page Info")]
    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public Guid PageInstanceId
    {
      get { return (Guid)base.GetValue(MTPageStateActivity.PageInstanceIdProperty); }
    }
	}

  public class MTPageStateActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTPageStateActivity pageStateActivity = obj as MTPageStateActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (pageStateActivity.Parent == null)
      {
        return errors;
      }

      // Must specify event name
      if (String.IsNullOrEmpty(pageStateActivity.PageName))
      {
        errors.Add(ValidationError.GetNotSetValidationError("PageName"));
      }

      //  6/22/2012 jchung
      //  Replaced the line containing a call to IsSubclassOf() with a check of parentType.BaseType.Name because 
      //  the former was not working as expected for SubscriptionsWorkflow.  Consequently, ICE validation 
      //  of the PageNav extension, which contains the Subscriptions workflow, was generating an error message.
      //if (!(pageStateActivity.Parent.GetType().IsSubclassOf(typeof(MTStateMachineWorkflowActivity))))
      Type parentType = pageStateActivity.Parent.GetType();
      if ((parentType == null) || (parentType.BaseType == null) || parentType.BaseType.Name != "MTStateMachineWorkflowActivity")
      {
        errors.Add(new ValidationError("MTPageStateActivity must be a child of MTStateMachineWorkflowActivity", 1));
      }

      return errors;
    }
  }

}
