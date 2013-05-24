using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASWorkflowType
  {
    #region Members
    private string m_XOMLPath = null;
    private string m_AssemblyName = null;
    private string m_FullTypeName = null;
    #endregion

    #region Constructor
    public CMASWorkflowType()
    {
    }
    #endregion

    #region Parsing
    public static CMASWorkflowType Parse(XmlNode workflowNode, Logger logger)
    {
      logger.LogDebug("Parse Workflow Type");

      CMASWorkflowType workflowType = new CMASWorkflowType();

      foreach (XmlNode wfTypeNode in workflowNode.ChildNodes)
      {
        switch (wfTypeNode.Name)
        {
          case "XomlFile":
            workflowType.XOMLFile = wfTypeNode.InnerText;
            break;
          case "AssemblyName":
            workflowType.AssemblyName = wfTypeNode.InnerText;
            break;
          case "FullTypeName":
            workflowType.FullTypeName = wfTypeNode.InnerText;
            break;
        };
      }

      if (workflowType.XOMLFile != null && workflowType.FullTypeName != null)
      {
        throw new ApplicationException("Cannot configure workflow type with both assembly/type name and XOML file path");
      }

      return workflowType;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Workflow Mapping");

      XmlNode workflowNode = outputDoc.CreateElement("WorkflowType");

      if (m_AssemblyName != null)
      {
        XmlNode assemblyName = outputDoc.CreateElement("AssemblyName");
        assemblyName.InnerText = m_AssemblyName;
        workflowNode.AppendChild(assemblyName);
      }

      if (m_XOMLPath != null)
      {
        XmlNode xomlPath = outputDoc.CreateElement("XomlFile");
        xomlPath.InnerText = m_XOMLPath;
        workflowNode.AppendChild(xomlPath);
      }

      if (m_FullTypeName != null)
      {
        XmlNode typeName = outputDoc.CreateElement("FullTypeName");
        typeName.InnerText = m_FullTypeName;
        workflowNode.AppendChild(typeName);
      }

      parentNode.AppendChild(workflowNode);
    }
    #endregion

    #region Properties
    public string XOMLFile
    {
      get { return m_XOMLPath; }
      set { m_XOMLPath = value; }
    }

    public string AssemblyName
    {
      get { return m_AssemblyName; }
      set { m_AssemblyName = value; }
    }

    public string FullTypeName
    {
      get { return m_FullTypeName; }
      set { m_FullTypeName = value; }
    }
    #endregion
  }
}
