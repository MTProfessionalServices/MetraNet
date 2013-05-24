#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.Interop.MTAuth;
using System.ServiceModel;
using System.Workflow.Runtime;
using System.Diagnostics;
using MetraTech.ActivityServices.Activities;
using System.IO;
using System.Xml;
using System.Workflow.Runtime.Hosting;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel;

namespace MetraTech.ActivityServices.Services.Common
{
  public class WorkflowExecutor
  {
    private Logger mLogger = new Logger("[WorkflowExecutor]");
    private static WorkflowRuntime m_WorkflowRuntime = null;
    private static ManualWorkflowSchedulerService m_Scheduler = null;

    private WorkflowInstance m_WorkflowInstance = null;
    private Type m_WorkflowType = null;
    
    static WorkflowExecutor()
    {
      m_WorkflowRuntime = new WorkflowRuntime();
      
      m_Scheduler = new ManualWorkflowSchedulerService();
      m_WorkflowRuntime.AddService(m_Scheduler);
      
      //m_WorkflowLoader = new MASWorkflowLoader();
      //m_WorkflowRuntime.AddService(m_WorkflowLoader);

      MASLogFileTrackingService fileTrackingService =
        new MASLogFileTrackingService(Environment.CurrentDirectory, "WFExecutorTracking");
      m_WorkflowRuntime.AddService(fileTrackingService);

      m_WorkflowRuntime.StartRuntime();
    }

    public WorkflowExecutor(Type workflowType, Dictionary<string, object> inputs)
    {
      m_WorkflowInstance = m_WorkflowRuntime.CreateWorkflow(workflowType, inputs);

      m_WorkflowType = m_WorkflowInstance.GetWorkflowDefinition().GetType();
      System.Diagnostics.Debug.Assert(m_WorkflowType.IsSubclassOf(typeof(MTSequentialWorkflowActivity)), "WorkflowExecutor only supports workflows derived from MTSequentialWorkflowActivity");
    }

    public WorkflowExecutor(string xomlFilePath, string ruleFilePath, Dictionary<string, object> inputs)
    {
      if (!File.Exists(xomlFilePath))
      {
        throw new ArgumentException("Specified XOML file is invalid");
      }

      XmlTextReader xomlReader = null;
      XmlTextReader rulesReader = null;

      try
      {
        xomlReader = new XmlTextReader(xomlFilePath);
        if (File.Exists(ruleFilePath))
        {
          rulesReader = new XmlTextReader(ruleFilePath);
        }

        m_WorkflowInstance = m_WorkflowRuntime.CreateWorkflow(xomlReader, rulesReader, inputs);

        m_WorkflowType = m_WorkflowInstance.GetWorkflowDefinition().GetType();
        System.Diagnostics.Debug.Assert(m_WorkflowType.IsSubclassOf(typeof(MTSequentialWorkflowActivity)), "WorkflowExecutor only supports workflows derived from MTSequentialWorkflowActivity");
      }
      catch (WorkflowValidationFailedException e)
      {
        mLogger.LogException("Workflow validation exception loading XOML workflow", e);

        foreach (ValidationError validationError in e.Errors)
        {
          mLogger.LogError("Validation error: {0}", validationError.ErrorText);
        }

        throw e;
      }
      finally
      {
        if (xomlReader != null)
        {
          xomlReader.Close();
        }

        if (rulesReader != null)
        {
          rulesReader.Close();
        }
      }
    }

    public WorkflowExecutor(MemoryStream xomlFile, MemoryStream rulesFile, Dictionary<string, object> inputs)
    {
        System.Diagnostics.Debug.Assert(xomlFile != null, "Invalid XOML file specified");

      XmlTextReader xomlReader = new XmlTextReader(xomlFile);

      XmlTextReader rulesReader = null;

      if (rulesFile != null)
      {
        rulesReader = new XmlTextReader(rulesFile);
      }

      m_WorkflowInstance = m_WorkflowRuntime.CreateWorkflow(xomlReader, rulesReader, inputs);

      m_WorkflowType = m_WorkflowInstance.GetWorkflowDefinition().GetType();
      System.Diagnostics.Debug.Assert(m_WorkflowType.IsSubclassOf(typeof(MTSequentialWorkflowActivity)), "WorkflowExecutor only supports workflows derived from MTSequentialWorkflowActivity");
    }

    public void ExecuteWorkflow(out Dictionary<string, object> outputs)
    {
      outputs = null;

      Dictionary<string, object> outValues = null;

      EventHandler<WorkflowCompletedEventArgs> completeHandler = delegate(object sender, WorkflowCompletedEventArgs e)
      {
        if (WorkflowInstance.ReferenceEquals(m_WorkflowInstance, e.WorkflowInstance))
        {
          outValues = e.OutputParameters;
        }
      };

      Exception wfError = null;
      EventHandler<WorkflowTerminatedEventArgs> terminatedHandler = delegate(object sender, WorkflowTerminatedEventArgs e)
        {
          if (WorkflowInstance.ReferenceEquals(m_WorkflowInstance, e.WorkflowInstance))
          {
            if (e.Exception != null)
            {
              wfError = e.Exception;
            }
          }
        };

      m_WorkflowRuntime.WorkflowCompleted += completeHandler;
      m_WorkflowRuntime.WorkflowTerminated += terminatedHandler;

      m_WorkflowInstance.Start();

      m_Scheduler.RunWorkflow(m_WorkflowInstance.InstanceId);

      m_WorkflowRuntime.WorkflowCompleted -= completeHandler;
      m_WorkflowRuntime.WorkflowTerminated -= terminatedHandler;

      if (wfError == null)
      {
        outputs = outValues;
      }
      else
      {
        mLogger.LogException("Exception executing workflow", wfError);
        throw wfError;
      }
    }

    public Type WorkflowType
    {
      get { return m_WorkflowType; }
    }
  }
}
