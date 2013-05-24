using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using System.Xml;

using MetraTech.DataAccess;
using QueryAdapter = MetraTech.Interop.QueryAdapter;
using MetraTech.ActivityServices.Activities;
using MetraTech.ActivityServices.Services.Common;
using RCD = MetraTech.Interop.RCD;
using MetraTech.ActivityServices.Common;
using System.Workflow.ComponentModel.Compiler;

namespace MetraTech.ActivityServices.Runtime
{
  internal sealed class WorkflowXoml
  {
    public MemoryStream XomlFile = null;
    public MemoryStream RulesFile = null;

    public bool TypeChecked = false;

    //public Type xomlType = null;
  }

  internal sealed class CMASEventProcessor : CMASProcessorBase
  {
    #region Static Members
    private static Logger m_Logger = null;

    private static QueryAdapter.IMTQueryAdapter m_QueryAdapter = new QueryAdapter.MTQueryAdapter();

    private static Dictionary<string, WorkflowXoml> m_XomlCache = new Dictionary<string, WorkflowXoml>();

    #endregion

    #region Members
    #endregion

    #region Constructors
    static CMASEventProcessor()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[MASEventProcessor]");

      m_QueryAdapter.Init("Queries\\ActivityServices");
    }

    public CMASEventProcessor()
    {
    }
    #endregion

    #region Public Methods
    public void Process(ref CMASEventData eventData, out Dictionary<string, object> stateInitOutput)
    {
      stateInitOutput = null;

      try
      {
        WorkflowInstance wfInstance = null;
        
        wfInstance = LocateWFInstance(ref eventData);

        if (wfInstance != null)
        {
          // Make sure that there is a event
          System.Diagnostics.Debug.Assert(!String.IsNullOrEmpty(eventData.EventName));

          // Queue workflowData
          try
          {
            m_EventOutputService.ClearEventResults(wfInstance.InstanceId);
            m_StateInitOutputService.ClearStateInitOutput(wfInstance.InstanceId);

            wfInstance.EnqueueItem(eventData.EventName, eventData.InputData, null, null);

            CMASEventData tmpData = eventData;

            EventHandler<WorkflowCompletedEventArgs> completeHandler = completeHandler = delegate(object sender, WorkflowCompletedEventArgs e)
              {
                if (WorkflowInstance.ReferenceEquals(wfInstance, e.WorkflowInstance))
                {
                  CleanupWFInstance(tmpData);
                }
              };

            Exception wfError = null;
            EventHandler<WorkflowTerminatedEventArgs> terminatedHandler = delegate(object sender, WorkflowTerminatedEventArgs e)
              {
                if (WorkflowInstance.ReferenceEquals(wfInstance, e.WorkflowInstance))
                {
                  CleanupWFInstance(tmpData);

                  if (e.Exception != null)
                  {
                    wfError = e.Exception;
                  }
                }
              };

            EventHandler<WorkflowEventArgs> abortedHandler = delegate(object sender, WorkflowEventArgs e)
            {
              if (WorkflowInstance.ReferenceEquals(wfInstance, e.WorkflowInstance))
              {
                CleanupWFInstance(tmpData);
              }
            };

            EventHandler<WorkflowEventArgs> idledHandler = delegate(object sender, WorkflowEventArgs e)
            {
              if (WorkflowInstance.ReferenceEquals(wfInstance, e.WorkflowInstance))
              {
                e.WorkflowInstance.Unload();
              }
            };

            m_WorkflowRuntime.WorkflowCompleted += completeHandler;
            m_WorkflowRuntime.WorkflowTerminated += terminatedHandler;
            m_WorkflowRuntime.WorkflowAborted += abortedHandler;
            m_WorkflowRuntime.WorkflowIdled += idledHandler;

            m_SchedulerService.RunWorkflow(wfInstance.InstanceId);

            m_WorkflowRuntime.WorkflowCompleted -= completeHandler;
            m_WorkflowRuntime.WorkflowTerminated -= terminatedHandler;
            m_WorkflowRuntime.WorkflowAborted -= abortedHandler;
            m_WorkflowRuntime.WorkflowIdled -= idledHandler;

            Exception reportedException = null;
            CMASProcessorBase.m_ExceptionService.GetException(wfInstance.InstanceId, out reportedException);

            if (wfError == null && reportedException == null)
            {
              Dictionary<string, object> outputData;
              m_EventOutputService.GetEventResults(wfInstance.InstanceId, out outputData);

              stateInitOutput = m_StateInitOutputService.GetStateInitOutputs(wfInstance.InstanceId);

              eventData.OutputData = outputData;
            }
            else
            {
              if (wfError != null)
              {
                throw wfError;
              }

              if (reportedException != null)
              {
                throw reportedException;
              }
            }
          }
          catch (MASBaseException)
          {
            throw;
          }
          catch (Exception exp)
          {
            m_Logger.LogException(string.Format("Failed to enqueue item: {0}", eventData.EventName), exp);

            throw new MASBasicException("Error occurred processing event");
          }
        }
        else
        {
          MASBasicException masBase = new MASBasicException("Failed to locate workflow instance");

          throw masBase;
        }
      }
      catch (MASBaseException masBase)
      {
        m_Logger.LogException("Error processing event", masBase);

        throw masBase;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Error in Process", e);

        throw new MASBasicException("Unhandled exception processing event message");
      }
    }
    #endregion

    #region Helper Methods
    private WorkflowInstance LocateWFInstance(ref CMASEventData eventData)
    {
        WorkflowInstance retval = null;
        Guid instanceId;

        try
        {
            if (eventData.AllowMultipleInstances && eventData.ProcessorInstanceId == Guid.Empty)
            {
                eventData.ProcessorInstanceId = Guid.NewGuid();
            }

            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                string queryName = "";

                if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
                {
                    queryName = "__LOCATE_ACCOUNT_WF_INSTANCE__";
                }
                else
                {
                    queryName = "__LOCATE_BE_WF_INSTANCE__";
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("Queries\\ActivityServices", queryName))
                {
                    stmt.AddParam("%%WORKFLOW_TYPE%%", (!string.IsNullOrEmpty(eventData.XomlFile) ? eventData.XomlFile : eventData.WorkflowTypeName));
                    stmt.AddParam("%%TYPE_INSTANCE_ID%%", eventData.ProcessorInstanceId.ToString());
                    stmt.AddParam("%%PK_COLUMN%%", eventData.GetIDColumnName());
                    stmt.AddParam("%%INSTANCE_TABLE_NAME%%", eventData.GetTableName());
                    stmt.AddParam("%%QUERY_PREDICATE%%", eventData.GetQueryPredicate(conn.ConnectionInfo.IsOracle), true);

                    using (IMTDataReader rdr = stmt.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            if (!rdr.IsDBNull(0))
                            {
                                if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
                                {
                                    eventData.AccountId = rdr.GetInt32(0);
                                }
                                else
                                {
                                    eventData.EntityKey = rdr.GetString(0);
                                }

                                if (!rdr.IsDBNull(1))
                                {
                                    string idVal = rdr.GetString(1);
                                    instanceId = new Guid(idVal);

                                    retval = m_WorkflowRuntime.GetWorkflow(instanceId);
                                }
                                else
                                {
                                    retval = CreateWFInstance(ref eventData);
                                }
                            }
                            else
                            {
                                throw new MASBasicException("Unable to locate data type instance");
                            }
                        }
                        else
                        {
                            throw new MASBasicException("Unable to locate data type instance");
                        }
                    }
                }
            }
        }
        catch (Exception e)
        {
            m_Logger.LogException("Error in LocateWFInstance", e);

            throw new MASBasicException("Error locating workflow type instance for account");
        }

        return retval;
    }

    private WorkflowInstance CreateWFInstance(ref CMASEventData eventData)
    {
      WorkflowInstance retval = null;

      try
      {
          if (eventData.XomlFile != null)
          {
              WorkflowXoml workflowSource = null;

              lock (m_XomlCache)
              {
                  if (m_XomlCache.ContainsKey(eventData.XomlFile))
                  {
                      m_Logger.LogDebug("Loading cached XOML file: {0}", eventData.XomlFile);
                      workflowSource = m_XomlCache[eventData.XomlFile];
                  }
                  else
                  {
                      m_Logger.LogDebug("Loading new XOML file: {0}", eventData.XomlFile);
                      RCD.IMTRcd rcd = new RCD.MTRcd();

                      string xomlFile = Path.Combine(rcd.ExtensionDir, eventData.XomlFile);
                      if (File.Exists(xomlFile))
                      {
                          workflowSource = new WorkflowXoml();

                          StreamReader rdr = new StreamReader(xomlFile);
                          byte[] bytes = new byte[rdr.BaseStream.Length + 1];
                          rdr.BaseStream.Read(bytes, 0, bytes.Length);

                          workflowSource.XomlFile = new MemoryStream(bytes);

                          rdr.Close();
                          rdr.Dispose();

                          string rulesFilename = Path.Combine(Path.GetDirectoryName(xomlFile), string.Format("{0}.rules", Path.GetFileNameWithoutExtension(xomlFile)));
                          if (File.Exists(rulesFilename))
                          {
                              rdr = new StreamReader(rulesFilename);
                              bytes = new byte[rdr.BaseStream.Length + 1];
                              rdr.BaseStream.Read(bytes, 0, bytes.Length);

                              workflowSource.RulesFile = new MemoryStream(bytes);

                              rdr.Close();
                              rdr.Dispose();
                          }

                          m_XomlCache.Add(eventData.XomlFile, workflowSource);
                      }
                      else
                      {
                          m_Logger.LogError("Failed to locate Xoml file at: {0}", eventData.XomlFile);

                          throw new MASBasicException("Unable to locate specified XOML file for workflow");
                      }
                      //string xomlFile = Path.Combine(rcd.ExtensionDir, eventData.XomlFile);

                      //if (File.Exists(xomlFile))
                      //{
                      //  XmlTextReader xamlTextReader = null, rulesTextReader = null;

                      //  xamlTextReader = new XmlTextReader(xomlFile);

                      //  string rulesFilename = Path.ChangeExtension(xomlFile, ".rules");

                      //  if (File.Exists(rulesFilename))
                      //  {
                      //    rulesTextReader = new XmlTextReader(rulesFilename);
                      //  }

                      //  retval = m_WorkflowRuntime.CreateWorkflow(xamlTextReader, rulesTextReader, null);

                      //  Activity wfActivity = retval.GetWorkflowDefinition();
                      //  workflowSource = new WorkflowXoml();
                      //  workflowSource.xomlType = wfActivity.GetType();

                      //  if (!workflowSource.xomlType.IsSubclassOf(typeof(MTStateMachineWorkflowActivity)))
                      //  {
                      //    MASBasicException masBase = new MASBasicException("Workflow type is not a MetraNet state machine workflow");

                      //    throw masBase;
                      //  }

                      //  retval.Start();

                      //  m_XomlCache.Add(eventData.XomlFile, workflowSource);
                      //}
                      //else
                      //{
                      //  m_Logger.LogError("Failed to locate Xoml file at: {0}", eventData.XomlFile);

                      //  throw new MASBasicException("Unable to locate specified XOML file for workflow");
                      //}
                  }
              }

              if (workflowSource != null)
              {
                  MemoryStream xomlStream = null, rulesStream = null;

                  lock (workflowSource)
                  {
                      workflowSource.XomlFile.Seek(0, SeekOrigin.Begin);

                      xomlStream = new MemoryStream();
                      workflowSource.XomlFile.WriteTo(xomlStream);

                      if (workflowSource.RulesFile != null)
                      {
                          workflowSource.RulesFile.Seek(0, SeekOrigin.Begin);

                          rulesStream = new MemoryStream();
                          workflowSource.RulesFile.WriteTo(rulesStream);
                      }
                  }

                  xomlStream.Seek(0, SeekOrigin.Begin);
                  XmlTextReader xamlTextReader = new XmlTextReader(xomlStream);

                  XmlTextReader rulesTextReader = null;
                  if (rulesStream != null)
                  {
                      rulesStream.Seek(0, SeekOrigin.Begin);
                      rulesTextReader = new XmlTextReader(rulesStream);
                  }

                  retval = m_WorkflowRuntime.CreateWorkflow(xamlTextReader, rulesTextReader, null);

                  retval.Start();

                  if (!workflowSource.TypeChecked)
                  {
                      lock (workflowSource)
                      {
                          if (!workflowSource.TypeChecked)
                          {
                              Activity root = retval.GetWorkflowDefinition();

                              if (!root.GetType().IsSubclassOf(typeof(MTStateMachineWorkflowActivity)))
                              {
                                  MASBasicException masBase = new MASBasicException("Workflow type is not a MetraNet state machine workflow");

                                  throw masBase;
                              }

                              workflowSource.TypeChecked = true;
                          }
                      }
                  }
              }
              else
              {
                  m_Logger.LogError("Failed to locate Xoml file at: {0}", eventData.XomlFile);

                  throw new MASBasicException("Unable to locate workflow");
              }
              //if (retval == null)
              //{
              //  retval = m_WorkflowRuntime.CreateWorkflow(workflowSource.xomlType);
              //  retval.Start();
              //}
          }
          else if (eventData.WorkflowAssembly != null && eventData.WorkflowTypeName != null)
          {
              Assembly wfAssembly = CMASHost.LoadAssembly(eventData.WorkflowAssembly);
              Type wfType = wfAssembly.GetType(eventData.WorkflowTypeName);

              if (!wfType.IsSubclassOf(typeof(MTStateMachineWorkflowActivity)))
              {
                  MASBasicException masBase = new MASBasicException("Workflow type is not a MetraNet state machine workflow");

                  throw masBase;
              }

              retval = m_WorkflowRuntime.CreateWorkflow(wfType);
              retval.Start();
          }

          if (retval != null)
          {
              WorkflowScheduler.RunWorkflow(retval.InstanceId);
          }
          else
          {
              m_Logger.LogError("Failed to create the workflow instance");

              throw new MASBasicException("Failed to create workflow instance");
          }

          // Associate WF instance with datatype instance
          using (IMTConnection conn = ConnectionManager.CreateConnection())
          {
              if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
              {
                  m_QueryAdapter.SetQueryTag("__INSERT_ACCOUNT_WF_INSTANCE__");
              }
              else
              {
                  m_QueryAdapter.SetQueryTag("__INSERT_BE_WF_INSTANCE__");
              }

              using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(m_QueryAdapter.GetQuery()))
              {
                  if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
                  {
                      stmt.AddParam(MTParameterType.Integer, eventData.AccountId);
                  }
                  else
                  {
                      stmt.AddParam(MTParameterType.String, eventData.EntityKey);
                  }

                  stmt.AddParam(MTParameterType.String, (!string.IsNullOrEmpty(eventData.XomlFile) ? eventData.XomlFile : eventData.WorkflowTypeName));
                  stmt.AddParam(MTParameterType.String, eventData.ProcessorInstanceId.ToString());
                  stmt.AddParam(MTParameterType.String, retval.InstanceId.ToString());

                  stmt.ExecuteNonQuery();
              }
          }
      }
      catch (WorkflowValidationFailedException e)
      {
          m_Logger.LogException("Workflow Validation Exception in CreateWFInstance", e);

          foreach (ValidationError err in e.Errors)
          {
              m_Logger.LogError("Error number {0}: {1}", err.ErrorNumber, err.ErrorText);
              if (!String.IsNullOrEmpty(err.PropertyName))
              {
                  m_Logger.LogError("Error occurred on property {0}", err.PropertyName);
              }
          }

          throw new MASBasicException("Error creating workflow instance");
      }
      catch (Exception e)
      {
          m_Logger.LogException("Exception in CreateWFInstance", e);

          throw new MASBasicException("Error creating workflow instance");
      }

      return retval;
    }

    private void CleanupWFInstance(CMASEventData eventData)
    {
        try
        {
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
                {
                    m_QueryAdapter.SetQueryTag("__DELETE_ACCOUNT_WF_INSTANCE__");
                }
                else
                {
                    m_QueryAdapter.SetQueryTag("__DELETE_BE_WF_INSTANCE__");
                }

                using (IMTPreparedStatement stmt = conn.CreatePreparedStatement(m_QueryAdapter.GetQuery()))
                {
                    if (string.Compare(eventData.DataTypeName, "Account", true) == 0)
                    {
                        stmt.AddParam(MTParameterType.Integer, eventData.AccountId);
                    }
                    else
                    {
                        stmt.AddParam(MTParameterType.String, eventData.EntityKey);
                    }

                    stmt.AddParam(MTParameterType.String, (!string.IsNullOrEmpty(eventData.XomlFile) ? eventData.XomlFile : eventData.WorkflowTypeName));
                    stmt.AddParam(MTParameterType.String, eventData.ProcessorInstanceId.ToString());

                    stmt.ExecuteNonQuery();
                }
            }
        }
        catch (Exception e)
        {
            m_Logger.LogException("Error in CleanupWFInstance", e);
        }
    }
    #endregion
  }
}
