using System;
using System.Diagnostics;
using System.ComponentModel;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.Runtime;
using System.Reflection;

namespace MetraTech.ActivityServices.Activities
{
  [ActivityValidator(typeof(MTEventHandlerActivityValidator))]
  [ToolboxItem(typeof(ActivityToolboxItem))]
  public class MTHandleEventActivity : Activity, IEventActivity, IActivityEventListener<QueueEventArgs>
  {
    public static DependencyProperty EventNameProperty = 
      DependencyProperty.Register("EventName", 
                                  typeof(string), 
                                  typeof(MTHandleEventActivity),
                                  new PropertyMetadata(DependencyPropertyOptions.Metadata));

    [Description("Name of the event that is being handled")]
    [Category("Event Name")]
    [Browsable(true)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
    public string EventName
    {
      get
      {
        return ((string)(base.GetValue(MTHandleEventActivity.EventNameProperty)));
      }
      set
      {
        base.SetValue(MTHandleEventActivity.EventNameProperty, value);
      }
    }

    #region IEventActivity implementation
    public IComparable QueueName 
    {
      //get { return base.QualifiedName; }
      get { return EventName; }
    }

    public void Subscribe(ActivityExecutionContext parentContext, IActivityEventListener<QueueEventArgs> parentEventHandler)
    {
      WorkflowQueue workflowQueue = GetWorkflowQueue(parentContext);
      workflowQueue.RegisterForQueueItemAvailable(parentEventHandler);
    }

    public void Unsubscribe(ActivityExecutionContext parentContext, IActivityEventListener<QueueEventArgs> parentEventHandler)
    {
      WorkflowQueue workflowQueue = GetWorkflowQueue(parentContext);
      workflowQueue.UnregisterForQueueItemAvailable(parentEventHandler);
      // DeleteQueue(parentContext);
    }

    #endregion

    #region IActivityEventListener implementation
    void IActivityEventListener<QueueEventArgs>.OnEvent(object sender, QueueEventArgs e)
    {
      // If activity is not scheduled for execution, do nothing
      if (ExecutionStatus == ActivityExecutionStatus.Executing)
      {
        ActivityExecutionContext context = sender as ActivityExecutionContext;
        if (this.ProcessQueueItem(context))
        {
          context.CloseActivity();
        }
      }
    }
    #endregion

    #region Activity Overrides
    protected override void Initialize(IServiceProvider provider)
    {
      base.Initialize(provider);
      WorkflowQueuingService workflowQueuingService =
        (WorkflowQueuingService)provider.GetService(typeof(WorkflowQueuingService));
      Debug.Assert(workflowQueuingService != null);
      CreateQueue(workflowQueuingService);
    }

    protected override void Uninitialize(IServiceProvider provider)
    {
      base.Uninitialize(provider);

      // Remove the queue created in Initialize
      WorkflowQueuingService workflowQueuingService =
        (WorkflowQueuingService)provider.GetService(typeof(WorkflowQueuingService));

     // DeleteQueue(workflowQueuingService);
    }

    protected override ActivityExecutionStatus Execute(ActivityExecutionContext context)
    {
      if (this.ProcessQueueItem(context))
      {
        return ActivityExecutionStatus.Closed;
      }

      this.Subscribe(context, this);
      return ActivityExecutionStatus.Executing;
    }
    #endregion

    #region Private Methods
    /// <summary>
    ///   Create a queue with QueueName if one doesn't exist
    /// </summary>
    /// <param name="workflowQueuingService"></param>
    /// <returns></returns>
    private WorkflowQueue CreateQueue(WorkflowQueuingService workflowQueuingService)
    {
      WorkflowQueue workflowQueue = null;

      if (workflowQueuingService.Exists(QueueName))
      {
        workflowQueue = workflowQueuingService.GetWorkflowQueue(QueueName);
      }
      else
      {
        workflowQueue = workflowQueuingService.CreateWorkflowQueue(QueueName, true);
      }

      return workflowQueue;
    }

    /// <summary>
    ///   Delete the queue with QueueName if it exists.
    /// </summary>
    /// <param name="workflowQueuingService"></param>
    private void DeleteQueue(WorkflowQueuingService workflowQueuingService)
    {
      if (workflowQueuingService.Exists(QueueName))
      {
        workflowQueuingService.DeleteWorkflowQueue(QueueName);
      }
    }

    /// <summary>
    ///   Get a queue with QueueName. Creates one if it doesn't exist.
    /// </summary>
    /// <param name="context"></param>
    /// <returns></returns>
    private WorkflowQueue GetWorkflowQueue(ActivityExecutionContext context)
    {
      WorkflowQueue workflowQueue = null;
      WorkflowQueuingService workflowQueuingService = context.GetService<WorkflowQueuingService>();
      if (workflowQueuingService.Exists(QueueName))
      {
        workflowQueue = workflowQueuingService.GetWorkflowQueue(QueueName);
      }
      else
      {
        workflowQueue = CreateQueue(workflowQueuingService);
      }
      return workflowQueue;
    }

    private bool ProcessQueueItem(ActivityExecutionContext context)
    {
      WorkflowQueue queue = GetWorkflowQueue(context);

      // If the queue has messages, then process the first one
      if (queue == null || queue.Count == 0)
      {
        return false;
      }

      Dictionary<string, object> inputData = (Dictionary<string, object>)queue.Dequeue();
      Activity rootActivity = this;

      while (rootActivity.Parent != null)
      {
        rootActivity = rootActivity.Parent;
      }

      Type rootType = rootActivity.GetType();
      PropertyInfo[] propInfos = rootType.GetProperties(BindingFlags.Instance | BindingFlags.Public );
      object[] customAttribs;

      foreach (PropertyInfo propInfo in propInfos)
      {
        customAttribs = propInfo.GetCustomAttributes(typeof(EventInputArgAttribute), false);

        foreach (EventInputArgAttribute customAttrib in customAttribs)
        {
          if (customAttrib.EventName == this.EventName)
          {
            if (inputData.ContainsKey(propInfo.Name))
            {
              object data = inputData[propInfo.Name];

              propInfo.SetValue(rootActivity, data, null);
            }

            break;
          }
        }
      }

      return true;
    }
    #endregion
  }

  public class MTEventHandlerActivityValidator : ActivityValidator
  {
    public override ValidationErrorCollection Validate(ValidationManager manager, object obj)
    {
      ValidationErrorCollection errors = base.Validate(manager, obj);
      MTHandleEventActivity eventHandlerActivity = obj as MTHandleEventActivity;

      // Don't want this validator to run unless this activity is a part of a workflow
      if (eventHandlerActivity.Parent == null)
      {
        return errors;
      }

      // Must specify event name
      if (String.IsNullOrEmpty(eventHandlerActivity.EventName))
      {
        errors.Add(ValidationError.GetNotSetValidationError("EventName"));
      }

      if (!(eventHandlerActivity.Parent is EventDrivenActivity))
      {
        errors.Add(new ValidationError("MTHandleEventActivity must be a child of EventDrivenActivity", 1));
      }

      return errors;
    }
  }
}
