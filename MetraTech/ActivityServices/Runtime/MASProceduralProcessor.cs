using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Reflection;
using System.IO;
using System.Workflow.Runtime;
using System.Workflow.ComponentModel.Compiler;
using System.Xml;

using MetraTech.ActivityServices.Activities;
using RCD = MetraTech.Interop.RCD;
using System.CodeDom.Compiler;
using MetraTech.ActivityServices.Services.Common;
using MetraTech.ActivityServices.Common;
using System.Workflow.ComponentModel;

namespace MetraTech.ActivityServices.Runtime
{
  internal sealed class CMASProceduralProcessor : CMASProcessorBase
  {
    #region Static Members
    private static Logger m_Logger = null;

    private static Dictionary<string, WorkflowXoml> m_XomlCache = new Dictionary<string, WorkflowXoml>();
    #endregion

    #region Constructors
    static CMASProceduralProcessor()
    {
      m_Logger = new Logger("Logging\\ActivityServices", "[MASProceduralProcessor]");
    }

    public CMASProceduralProcessor()
    {
    }
    #endregion

    #region Public Methods
    public void Process(ref CMASRequestData reqData)
    {
      try
      {
        Dictionary<string, object> outData = null;

        WorkflowInstance instance = CreateWFInstance(ref reqData);

        if (instance != null)
        {
            EventHandler<WorkflowCompletedEventArgs> completeHandler = delegate(object sender, WorkflowCompletedEventArgs e)
            {
              if (WorkflowInstance.ReferenceEquals(instance, e.WorkflowInstance))
              {
                outData = e.OutputParameters;
              }
            };

            Exception wfError = null;
            EventHandler<WorkflowTerminatedEventArgs> terminatedHandler = delegate(object sender, WorkflowTerminatedEventArgs e)
              {
                if (WorkflowInstance.ReferenceEquals(instance, e.WorkflowInstance))
                {
                  if (e.Exception != null)
                  {
                    wfError = e.Exception;
                  }
                }
              };

            m_WorkflowRuntime.WorkflowCompleted += completeHandler;
            m_WorkflowRuntime.WorkflowTerminated += terminatedHandler;

            instance.Start();

            WorkflowScheduler.RunWorkflow(instance.InstanceId);

            Exception reportedException = null;
            CMASProcessorBase.m_ExceptionService.GetException(instance.InstanceId, out reportedException);
            
            if (wfError == null && reportedException == null)
            {
              reqData.OutputData = outData;
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

            m_WorkflowRuntime.WorkflowCompleted -= completeHandler;
            m_WorkflowRuntime.WorkflowTerminated -= terminatedHandler;
        }
        else
        {
          MASBasicException masBasic = new MASBasicException("Failed to create workflow instance");

          throw masBasic;
        }
      }
      catch (MASBaseException masBase)
      {
        m_Logger.LogException("Error in procedural processing", masBase);

        throw masBase;
      }
      catch (Exception e)
      {
        m_Logger.LogException("Exception in Process", e);

       throw new MASBasicException(e.Message);
      }
    }
    #endregion

    #region Helper Methods
    private WorkflowInstance CreateWFInstance(ref CMASRequestData reqData)
    {
      WorkflowInstance retval = null;

      try
      {
        if (reqData.XomlFile != null)
        {
          WorkflowXoml workflowSource = null;

          lock (m_XomlCache)
          {
            if (m_XomlCache.ContainsKey(reqData.XomlFile))
            {
              m_Logger.LogDebug("Loading cached XOML file: {0}", reqData.XomlFile);
              workflowSource = m_XomlCache[reqData.XomlFile];
            }
            else
            {
              m_Logger.LogDebug("Loading new XOML file: {0}", reqData.XomlFile);
              RCD.IMTRcd rcd = new RCD.MTRcd();

              string xomlFile = Path.Combine(rcd.ExtensionDir, reqData.XomlFile);
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

                m_XomlCache.Add(reqData.XomlFile, workflowSource);
              }
              else
              {
                m_Logger.LogError("Failed to locate Xoml file at: {0}", reqData.XomlFile);

                throw new MASBasicException("Unable to locate specified XOML file for workflow");
              }
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

            retval = m_WorkflowRuntime.CreateWorkflow(xamlTextReader, rulesTextReader, reqData.InputData);

            if (!workflowSource.TypeChecked)
            {
              lock (workflowSource)
              {
                if (!workflowSource.TypeChecked)
                {
                  Activity root = retval.GetWorkflowDefinition();

                  if (!root.GetType().IsSubclassOf(typeof(MTSequentialWorkflowActivity)))
                  {
                    MASBasicException masBasic = new MASBasicException("Workflow type is not a MetraNet sequential workflow");

                    throw masBasic;
                  }

                  workflowSource.TypeChecked = true;
                }
              }
            }
          }
          else
          {
            m_Logger.LogError("Failed to locate Xoml file at: {0}", reqData.XomlFile);

            throw new MASBasicException("Unable to locate workflow");
          }
        }
        else if (reqData.WorkflowAssembly != null && reqData.WorkflowTypeName != null)
        {
          Assembly wfAssembly = CMASHost.LoadAssembly(reqData.WorkflowAssembly);
          Type wfType = wfAssembly.GetType(reqData.WorkflowTypeName);

          if (!wfType.IsSubclassOf(typeof(MTSequentialWorkflowActivity)))
          {
            MASBasicException masBasic = new MASBasicException("Workflow type is not a MetraNet sequential workflow");

            throw masBasic;
          }

          retval = m_WorkflowRuntime.CreateWorkflow(wfType, reqData.InputData);
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

        retval = null;
      }

      return retval;
    }
    #endregion
  }
}
