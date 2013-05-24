using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Runtime;
using System.Workflow.Runtime.Hosting;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using MetraTech.ActivityServices.PersistenceService;
using MetraTech.ActivityServices.Configuration;
using System.Reflection;
using MetraTech.ActivityServices.Services.Common;

namespace MetraTech.ActivityServices.Runtime
{
  internal abstract class CMASProcessorBase
  {
    #region Static Members
    protected static WorkflowRuntime m_WorkflowRuntime;
    protected static MTWorkflowPersistenceService m_PersistenceService;
    protected static ManualWorkflowSchedulerService m_SchedulerService;
    protected static ExternalDataExchangeService m_ExchangeService;
    protected static MASWorkflowLoader m_WorkflowLoader;

    // Logging Service
    protected static CMASWorkflowLoggingService m_LoggingService;

    // Internal Call Service
    protected static CMASInternalMASCallService m_InternalCallService;

    // Exception Reporting Service
    protected static CMASExceptionReportingService m_ExceptionService;

    // State-Machine Output Services
    protected static CEventOutputService m_EventOutputService;
    protected static CStateInitOutputService m_StateInitOutputService;

    // Logger for child classes
    private static Logger m_Logger = null;
    #endregion

    #region Constructors
    static CMASProcessorBase()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[MASProcessorBase]");

      m_WorkflowRuntime = new WorkflowRuntime();

      m_WorkflowRuntime.WorkflowIdled += delegate(object sender, WorkflowEventArgs e)
      {
        m_Logger.LogDebug("Workflow {0} Idled", e.WorkflowInstance.InstanceId.ToString());
      };

      m_WorkflowRuntime.WorkflowCompleted += delegate(object sender, WorkflowCompletedEventArgs e)
      {
        m_Logger.LogDebug("Workflow {0} Completed", e.WorkflowInstance.InstanceId.ToString());
      };

      m_WorkflowRuntime.WorkflowAborted += delegate(object sender, WorkflowEventArgs e)
      {
        m_Logger.LogDebug("Workflow {0} Aborted", e.WorkflowInstance.InstanceId.ToString());
      };

      m_WorkflowRuntime.WorkflowTerminated += delegate(object sender, WorkflowTerminatedEventArgs e)
      {
        m_Logger.LogException(string.Format("Workflow {0} Terminated", e.WorkflowInstance.InstanceId.ToString()), e.Exception);
      };

      m_ExchangeService = new ExternalDataExchangeService();
      m_WorkflowRuntime.AddService(m_ExchangeService);

      m_LoggingService = new CMASWorkflowLoggingService();
      m_ExchangeService.AddService(m_LoggingService);

      m_EventOutputService = new CEventOutputService();
      m_ExchangeService.AddService(m_EventOutputService);

      m_StateInitOutputService = new CStateInitOutputService();
      m_ExchangeService.AddService(m_StateInitOutputService);

      m_InternalCallService = new CMASInternalMASCallService();
      m_ExchangeService.AddService(m_InternalCallService);

      m_ExceptionService = new CMASExceptionReportingService();
      m_ExchangeService.AddService(m_ExceptionService);

      m_SchedulerService = new ManualWorkflowSchedulerService();
      m_WorkflowRuntime.AddService(m_SchedulerService);

      m_PersistenceService = new MTWorkflowPersistenceService(false, new TimeSpan(1, 0, 0), new TimeSpan(0, 1, 0));
      m_WorkflowRuntime.AddService(m_PersistenceService);

      MASLogFileTrackingService fileTrackingService =
        new MASLogFileTrackingService(Environment.CurrentDirectory, "MASTracking");
      m_WorkflowRuntime.AddService(fileTrackingService);

      //m_WorkflowLoader = new MASWorkflowLoader();
      //m_WorkflowRuntime.AddService(m_WorkflowLoader);
    }
    #endregion

    #region Static Properties
    public static WorkflowRuntime WorkflowRuntime
    {
      get { return m_WorkflowRuntime; }
    }

    public static ManualWorkflowSchedulerService WorkflowScheduler
    {
      get { return m_SchedulerService; }
    }
    #endregion

    #region Static Methods
    public static void StartWorkflowRuntime()
    {
      m_WorkflowRuntime.StartRuntime();
    }

    public static void StopWorkflowRuntime()
    {
      m_WorkflowRuntime.StopRuntime();
    }

    public static void AddExchangeServices(List<CMASDataExchangeService> svcs)
    {
      foreach (CMASDataExchangeService svc in svcs)
      {
        try
        {
          Assembly svcAssembly = CMASHost.LoadAssembly(svc.ServiceAssembly);

          if (m_ExchangeService.GetService(svcAssembly.GetType(svc.ServiceTypeName)) == null)
          {
            object svcInst = svcAssembly.CreateInstance(svc.ServiceTypeName);

            m_Logger.LogInfo("Adding Data Exchange Service: {0}", svc.ServiceTypeName);
            m_ExchangeService.AddService(svcInst);
          }
        }
        catch (Exception e)
        {
          m_Logger.LogException("Error adding exchange service", e);
        }
      }
    }
    #endregion
  }
}
