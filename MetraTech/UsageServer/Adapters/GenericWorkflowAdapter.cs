using System;
using System.Collections.Generic;
using System.Text;
using MetraTech.UsageServer;
using MetraTech.Interop.MTAuth;
using System.Configuration;
using MetraTech.Interop.RCD;
using System.IO;
using MetraTech;
using System.Diagnostics;
using MetraTech.DataAccess;
using MetraTech.ActivityServices.Services.Common;
using System.Xml;

namespace MetraTech.UsageServer.Adapters
{
  public class GenericWorkflowAdapter : IRecurringEventAdapter2
  {
    #region Members
    private Logger mLogger = new Logger("[GenericWorkflowAdapter]");

    private string m_EventName;
    private string m_ConfigFile;
    private IMTSessionContext m_SessionContext = null;

    private GenericWorkflowAdapterConfig m_AdapterConfig;
    #endregion

    #region IRecurringEventAdapter2 Members

    #region MetaData Properties
    public bool AllowMultipleInstances
    {
      get { return m_AdapterConfig.AllowMultipleInstances; }
    }

    public BillingGroupSupportType BillingGroupSupport
    {
      get { return m_AdapterConfig.BillingGroupSupport; }
    }

    public ReverseMode Reversibility
    {
      get { return m_AdapterConfig.ReverseMode; }
    }

    public bool HasBillingGroupConstraints
    {
      get { return m_AdapterConfig.HasBillingGroupConstraints; }
    }

    public bool SupportsEndOfPeriodEvents
    {
      get { return m_AdapterConfig.SupportsEOPEvents; }
    }

    public bool SupportsScheduledEvents
    {
      get { return m_AdapterConfig.SupportsScheduledEvents; }
    }

    #endregion

    #region Adapter Methods
    public void Initialize(string eventName, string configFile, MetraTech.Interop.MTAuth.IMTSessionContext context, bool limitedInit)
    {
      mLogger = new Logger(string.Format("[GenericWorkflowAdapter:{0}]", eventName));

      m_EventName = eventName;
      m_ConfigFile = configFile;
      m_SessionContext = context;

      mLogger.LogInfo("Initializing GenericWorkflowAdapter for event {0} with config file {1}", m_EventName, m_ConfigFile);

      try
      {
        IMTRcd rcd = new MTRcdClass();

        string configFileName = (Path.IsPathRooted(m_ConfigFile) ? m_ConfigFile : Path.Combine(rcd.ExtensionDir, m_ConfigFile));

        m_AdapterConfig = new GenericWorkflowAdapterConfig(configFileName);
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception loading GenericWorkflowAdapter configuration", e);

        throw e;
      }
    }

    public void CreateBillingGroupConstraints(int intervalID, int materializationID)
    {
      Debug.Assert(HasBillingGroupConstraints);

      mLogger.LogInfo("Creating billing group constraints for interval {0} and materializationID {1}", intervalID, materializationID);

      if (!string.IsNullOrEmpty(m_AdapterConfig.BillingGroupConstraintQueryPath) &&
         !string.IsNullOrEmpty(m_AdapterConfig.BillingGroupConstraintQueryTag))
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(m_AdapterConfig.BillingGroupConstraintQueryPath, m_AdapterConfig.BillingGroupConstraintQueryTag))
              {
                  stmt.AddParamIfFound("%%ID_USAGE_INTERVAL%%", intervalID, true);
                  stmt.AddParamIfFound("%%ID_MATERIALIZATION%%", materializationID, true);

                  stmt.ExecuteNonQuery();
              }
          }
      }
      else
      {
        throw new ArgumentException("Billing group constraints are enabled, but the query details have not been specified");
      }
    }

    public string Execute(IRecurringEventRunContext context)
    {
      string info = string.Format("Executing {0} in context: {1}", m_EventName, context);
      mLogger.LogDebug(info);
      context.RecordInfo(info);

      try
      {
        Dictionary<string, object> wfInputs = new Dictionary<string, object>();

        wfInputs.Add("EventName", m_EventName);
        wfInputs.Add("ConfigFile", m_ConfigFile);
        wfInputs.Add("ExecutionContext", context);
        wfInputs.Add("SecurityContext", m_SessionContext);

        WorkflowExecutor wfExecutor = null;
        if (m_AdapterConfig.ExecuteWorkflow.EndsWith(".xoml", true, null))
        {
          IMTRcd rcd = new MTRcdClass();

          string path = (Path.IsPathRooted(m_AdapterConfig.ExecuteWorkflow) ? m_AdapterConfig.ExecuteWorkflow : Path.Combine(rcd.ExtensionDir, m_AdapterConfig.ExecuteWorkflow));

          mLogger.LogDebug("Executing XOML workflow.  Workflow path is: {0}", path);

          wfExecutor = new WorkflowExecutor(path, Path.ChangeExtension(path, ".rules"), wfInputs);
        }
        else
        {
          mLogger.LogDebug("Executing compiled workflow.  Type is {0}", m_AdapterConfig.ExecuteWorkflow);
          wfExecutor = new WorkflowExecutor(Type.GetType(m_AdapterConfig.ExecuteWorkflow), wfInputs);
        }

        Dictionary<string, object> wfOutputs;
        wfExecutor.ExecuteWorkflow(out wfOutputs);
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception executing adapter", e);

        throw e;
      }

      // return results
      info = "Success";
      mLogger.LogInfo(info);
      context.RecordInfo(info);
      return info;
    }

    public void SplitReverseState(int parentRunID, int parentBillingGroupID, int childRunID, int childBillingGroupID)
    {
      mLogger.LogInfo("Splitting reverse state for parent run: {0}, parent billing group: {1}, to child run: {2}, child billing group: {3}", parentRunID, parentBillingGroupID, childRunID, childBillingGroupID);

      if (!string.IsNullOrEmpty(m_AdapterConfig.SplitReverseStateQueryPath) &&
         !string.IsNullOrEmpty(m_AdapterConfig.SplitReverseStateQueryTag))
      {
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(m_AdapterConfig.SplitReverseStateQueryPath, m_AdapterConfig.SplitReverseStateQueryTag))
              {
                  stmt.AddParamIfFound("%%PARENT_RUN_ID%%", parentRunID, true);
                  stmt.AddParamIfFound("%%PARENT_BILLGROUP_ID%%", parentBillingGroupID, true);
                  stmt.AddParamIfFound("%%CHILD_RUN_ID%%", childRunID, true);
                  stmt.AddParamIfFound("%%CHILD_BILLGROUP_ID%%", childBillingGroupID, true);

                  stmt.ExecuteNonQuery();
              }
          }
      }
      else
      {
        throw new ArgumentException("Split Reverse State query details have not been specified");
      }
    }

    public string Reverse(IRecurringEventRunContext context)
    {
      string info = string.Format("Reversing {0} in context: {1}", m_EventName, context);
      mLogger.LogDebug(info);
      context.RecordInfo(info);

      try
      {
        if (string.IsNullOrEmpty(m_AdapterConfig.ReverseWorkflow))
        {
          throw new ArgumentException("Attempting to reverse adapter without speccifying workflow");
        }

        Dictionary<string, object> wfInputs = new Dictionary<string, object>();

        wfInputs.Add("EventName", m_EventName);
        wfInputs.Add("ConfigFile", m_ConfigFile);
        wfInputs.Add("ExecutionContext", context);
        wfInputs.Add("SecurityContext", m_SessionContext);

        WorkflowExecutor wfExecutor = null;
        if (m_AdapterConfig.ReverseWorkflow.EndsWith(".xoml", true, null))
        {
          IMTRcd rcd = new MTRcdClass();
          string path = (Path.IsPathRooted(m_AdapterConfig.ReverseWorkflow) ? m_AdapterConfig.ReverseWorkflow : Path.Combine(rcd.ExtensionDir, m_AdapterConfig.ReverseWorkflow));

          mLogger.LogDebug("Executing XOML workflow for reversal.  Workflow path is: {0}", path);

          wfExecutor = new WorkflowExecutor(path, Path.ChangeExtension(path, ".rules"), wfInputs);
        }
        else
        {
          mLogger.LogDebug("Executing compiled workflow for reversal.  Type is {0}", m_AdapterConfig.ExecuteWorkflow);
          
          wfExecutor = new WorkflowExecutor(Type.GetType(m_AdapterConfig.ReverseWorkflow), wfInputs);
        }

        Dictionary<string, object> wfOutputs;
        wfExecutor.ExecuteWorkflow(out wfOutputs);
      }
      catch (Exception e)
      {
        mLogger.LogException("Exception executing adapter", e);

        throw e;
      }

      // return results
      info = "Success";
      mLogger.LogInfo(info);
      context.RecordInfo(info);
      return info;
    }

    public void Shutdown()
    {
      mLogger.LogInfo("Shutting down adapter {0}", m_EventName);
    }
    #endregion

    #endregion
  }

  public class GenericWorkflowAdapterConfig
  {
    #region Members
    private bool m_AllowMultipleInstances = false;
    private BillingGroupSupportType m_BillingGroupSupport = BillingGroupSupportType.Interval;
    private bool m_HasBillingGroupConstraints = false;
    private string m_BillingGroupConstraintsQueryPath;
    private string m_BillingGroupConstraintsQueryTag;
    private ReverseMode m_ReverseMode = ReverseMode.Auto;
    private bool m_SupportsEOPEvents = false;
    private bool m_SupportsScheduledEvents = false;
    private string m_ExecuteWorkflow;
    private string m_ReverseWorkflow;
    private string m_SplitReverseStateQueryPath;
    private string m_SplitReverseStateQueryTag;
    #endregion

    public GenericWorkflowAdapterConfig(string configFilePath)
    {
      XmlDocument configFile = new XmlDocument();
      configFile.Load(configFilePath);

      XmlNode root = configFile.SelectSingleNode("//GenericWorkflowAdapter");

      foreach (XmlNode childNode in root.ChildNodes)
      {
        switch (childNode.Name)
        {
          case "AllowMultipleInstances":
            m_AllowMultipleInstances = bool.Parse(childNode.InnerText);
            break;
          case "BillingGroupSupport":
            m_BillingGroupSupport = (BillingGroupSupportType)Enum.Parse(typeof(BillingGroupSupportType), childNode.InnerText);
            break;
          case "HasBillingGroupConstraints":
            m_HasBillingGroupConstraints = bool.Parse(childNode.InnerText);
            break;
          case "BillingGroupConstraintQueryPath":
            m_BillingGroupConstraintsQueryPath = childNode.InnerText;
            break;
          case "BillingGroupConstraintQueryTag":
            m_BillingGroupConstraintsQueryTag = childNode.InnerText;
            break;
          case "ReverseMode":
            m_ReverseMode = (ReverseMode)Enum.Parse(typeof(ReverseMode), childNode.InnerText);
            break;
          case "SupportsEOPEvents":
            m_SupportsEOPEvents = bool.Parse(childNode.InnerText);
            break;
          case "SupportsScheduledEvents":
            m_SupportsScheduledEvents = bool.Parse(childNode.InnerText);
            break;
          case "ExecuteWorkflow":
            m_ExecuteWorkflow = childNode.InnerText;
            break;
          case "ReverseWorkflow":
            m_ReverseWorkflow = childNode.InnerText;
            break;
          case "SplitReverseStateQueryPath":
            m_SplitReverseStateQueryPath = childNode.InnerText;
            break;
          case "SplitReverseStateQueryTag":
            m_SplitReverseStateQueryTag = childNode.InnerText;
            break;
        }
      }
    }

    #region Properties
    public bool AllowMultipleInstances
    {
      get { return m_AllowMultipleInstances; }
    }

    public BillingGroupSupportType BillingGroupSupport
    {
      get { return m_BillingGroupSupport; }
    }

    public bool HasBillingGroupConstraints
    {
      get { return m_HasBillingGroupConstraints; }
    }

    public string BillingGroupConstraintQueryPath
    {
      get { return m_BillingGroupConstraintsQueryPath; }
    }

    public string BillingGroupConstraintQueryTag
    {
      get { return m_BillingGroupConstraintsQueryTag; }
    }

    public ReverseMode ReverseMode
    {
      get { return m_ReverseMode; }
    }

    public bool SupportsEOPEvents
    {
      get { return m_SupportsEOPEvents; }
    }

    public bool SupportsScheduledEvents
    {
      get { return m_SupportsScheduledEvents; }
    }

    public string ExecuteWorkflow
    {
      get { return m_ExecuteWorkflow; }
    }

    public string ReverseWorkflow
    {
      get { return m_ReverseWorkflow; }
    }

    public string SplitReverseStateQueryPath
    {
      get { return m_SplitReverseStateQueryPath; }
    }

    public string SplitReverseStateQueryTag
    {
      get { return m_SplitReverseStateQueryTag; }
    }
    #endregion
  }
}
