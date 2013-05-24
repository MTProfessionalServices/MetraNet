#pragma warning disable 1591  // Disable XML Doc warning for now.
using System;
using System.Collections.Generic;
using System.Text;
using System.Workflow.Runtime.Hosting;
using System.Workflow.ComponentModel;

namespace MetraTech.ActivityServices.Services.Common
{

  public class MASWorkflowLoader : DefaultWorkflowLoaderService
  {
    private Dictionary<Type, Activity> m_CachedWorkflows = new Dictionary<Type, Activity>();

    protected override System.Workflow.ComponentModel.Activity CreateInstance(System.Xml.XmlReader workflowDefinitionReader, System.Xml.XmlReader rulesReader)
    {
      Activity retval = base.CreateInstance(workflowDefinitionReader, rulesReader);

      lock (m_CachedWorkflows)
      {
        if (!m_CachedWorkflows.ContainsKey(retval.GetType()))
        {
          m_CachedWorkflows.Add(retval.GetType(), retval);
        }
      }

      return retval;
    }

    protected override Activity CreateInstance(Type workflowType)
    {
      Activity retval = null;

      lock (m_CachedWorkflows)
      {
        if (m_CachedWorkflows.ContainsKey(workflowType))
        {
          retval = m_CachedWorkflows[workflowType].Clone();
        }
      }

      if (retval == null)
      {
        retval = base.CreateInstance(workflowType);
      }

      return retval;
    }
  }
}
