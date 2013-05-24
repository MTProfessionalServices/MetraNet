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

using MetraTech;
using MetraTech.Events;
using MetraTech.Interop.MTAuth;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.ActivityServices.Services.Common;

namespace MetraTech.Core.Activities
{
	public partial class InfoMessageActivity: BaseActivity
	{

    public static DependencyProperty EventIdProperty = System.Workflow.ComponentModel.DependencyProperty.Register("EventId", typeof(string), typeof(InfoMessageActivity));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string EventId
    {
      get
      {
        return ((string)(base.GetValue(InfoMessageActivity.EventIdProperty)));
      }
      set
      {
        base.SetValue(InfoMessageActivity.EventIdProperty, value);
      }
    }

    public static DependencyProperty MessageProperty = System.Workflow.ComponentModel.DependencyProperty.Register("Message", typeof(string), typeof(InfoMessageActivity));

    [Description("This is the description which appears in the Property Browser")]
    [Category("This is the category which will be displayed in the Property Browser")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string Message
    {
      get
      {
        return ((string)(base.GetValue(InfoMessageActivity.MessageProperty)));
      }
      set
      {
        base.SetValue(InfoMessageActivity.MessageProperty, value);
      }
    }

		public InfoMessageActivity()
		{
		}

    public static DependencyProperty UserProperty = DependencyProperty.Register("User", typeof(string), typeof(InfoMessageActivity));

    [DescriptionAttribute("User")]
    [CategoryAttribute("User Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    public string User
    {
      get
      {
        return ((string)(base.GetValue(InfoMessageActivity.UserProperty)));
      }
      set
      {
        base.SetValue(InfoMessageActivity.UserProperty, value);
      }
    }


    public static DependencyProperty NameSpaceProperty = DependencyProperty.Register("NameSpace", typeof(string), typeof(InfoMessageActivity));

    [DescriptionAttribute("NameSpace")]
    [CategoryAttribute("User Category")]
    [BrowsableAttribute(true)]
    [DesignerSerializationVisibilityAttribute(DesignerSerializationVisibility.Visible)]
    public string NameSpace
    {
      get
      {
        return ((string)(base.GetValue(InfoMessageActivity.NameSpaceProperty)));
      }
      set
      {
        base.SetValue(InfoMessageActivity.NameSpaceProperty, value);
      }
    }

    protected override ActivityExecutionStatus Execute(ActivityExecutionContext executionContext)
    {
      try
      {
        InfoMessage msg = new InfoMessage(EventId, Message);
        using (EventManager eventManager = new EventManager())
        {
          eventManager.Send(User, NameSpace, msg);
        }
      }
      catch (Exception e)
      {
        Logger.LogException(String.Format("Error adding InfoMessage {0} {1} for user {2}", EventId, Message, User), e);
      }

      return base.Execute(executionContext);
    }
	}
}
