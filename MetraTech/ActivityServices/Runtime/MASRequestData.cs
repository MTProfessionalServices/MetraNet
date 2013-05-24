using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.ActivityServices.Runtime
{
  internal class CMASRequestData
  {
    #region Members
    private Dictionary<string, object> m_InputData = new Dictionary<string, object>();
    private Dictionary<string, object> m_OutputData = null;

    private string m_XomlFile;
    
    private string m_WorkflowTypeName;
    private string m_WorkflowAssembly;
    #endregion

    #region Properties
    public string WorkflowTypeName
    {
      get { return m_WorkflowTypeName; }
      set { m_WorkflowTypeName = value; }
    }

    public string WorkflowAssembly
    {
      get { return m_WorkflowAssembly; }
      set { m_WorkflowAssembly = value; }
    }

    public string XomlFile
    {
      get { return m_XomlFile; }
      set { m_XomlFile = value; }
    }

    public Dictionary<string, object> InputData
    {
      get { return m_InputData; }
    }

    public Dictionary<string, object> OutputData
    {
      set { m_OutputData = value; }
    }
    #endregion

    #region Methods
    public object GetInputItem(string key)
    {
      object retval = null;

      if (m_InputData.ContainsKey(key))
      {
        retval = m_InputData[key];
      }

      return retval;
    }

    public void SetInputItem(string key, object val)
    {
      if (m_InputData.ContainsKey(key))
      {
        m_InputData[key] = val;
      }
      else
      {
        m_InputData.Add(key, val);
      }
    }

    public object GetOutputItem(string key)
    {
      object retval = null;

      if (m_OutputData.ContainsKey(key))
      {
        retval = m_OutputData[key];
      }

      return retval;
    }
    #endregion
  }
}
