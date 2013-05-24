using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public class CMASProceduralMethod
  {
    #region Members
    protected string m_MethodName;

    // Current version of MS Workflow Foundation does not support flowing transactions into workflows
    // Commenting out capability until they fix the problem.
    //private bool m_bAllowTransactionFlow = false;

    private string m_FaultType = "MASBasicFaultDetail";

    private CMASWorkflowType m_WorkflowType = new CMASWorkflowType();
    
    private bool m_IsOneWay = false;
    
    protected Dictionary<string, CMASParameterDef> m_ParameterDefs = new Dictionary<string, CMASParameterDef>();

    private List<string> m_RequiredCapabilities = new List<string>();
    #endregion

    #region Constructor
    #endregion

    #region Parsing
    public static CMASProceduralMethod Parse(XmlNode procMethodNode, Logger logger)
    {
      CMASProceduralMethod methodDef = new CMASProceduralMethod();
      CMASParameterDef paramDef;

      methodDef.MethodName = procMethodNode.Attributes["Name"].Value;

      // Current version of MS Workflow Foundation does not support flowing transactions into workflows
      // Commenting out capability until they fix the problem.
      //if (procMethodNode.Attributes["AllowTransactionFlow"] != null)
      //{
      //  methodDef.m_bAllowTransactionFlow = bool.Parse(procMethodNode.Attributes["AllowTransactionFlow"].Value);
      //}

      if (procMethodNode.Attributes["FaultType"] != null)
      {
        methodDef.m_FaultType = procMethodNode.Attributes["FaultType"].Value;
      }

      logger.LogDebug("Parse EventMethod: {0}", methodDef.m_MethodName);

      foreach (XmlNode methodNode in procMethodNode.ChildNodes)
      {
        switch (methodNode.Name)
        {
          case "WorkflowType":
            methodDef.WorkflowType = CMASWorkflowType.Parse(methodNode, logger);
            break;

          case "ParameterDefs":

            foreach (XmlNode parameterNode in methodNode.ChildNodes)
            {
              if (parameterNode.Name == "Parameter")
              {
                paramDef = CMASParameterDef.Parse(parameterNode, logger);

                methodDef.ParameterDefs.Add(paramDef.ParameterName, paramDef);
              }
            }
            break;

          case "Capabilities":
            foreach (XmlNode capNode in methodNode.ChildNodes)
            {
              if (capNode.Name == "MTCapability")
              {
                methodDef.m_RequiredCapabilities.Add(capNode.InnerText);
              }
            }
          break;
        };
      }

      return methodDef;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Procedural Method: {0}", m_MethodName);
      XmlNode methodNode = outputDoc.CreateElement("ProceduralMethod");

      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_MethodName;
      methodNode.Attributes.Append(nameAttrib);

      // Current version of MS Workflow Foundation does not support flowing transactions into workflows
      // Commenting out capability until they fix the problem.
      //if (m_bAllowTransactionFlow)
      //{
      //  XmlAttribute transFlowAttrib = outputDoc.CreateAttribute("AllowTransactionFlow");
      //  transFlowAttrib.Value = m_bAllowTransactionFlow.ToString();
      //  methodNode.Attributes.Append(transFlowAttrib);
      //}

      if (m_FaultType != "MASBasicFaultDetail")
      {
        XmlAttribute faultAttrib = outputDoc.CreateAttribute("FaultType");
        faultAttrib.Value = m_FaultType;
        methodNode.Attributes.Append(faultAttrib);
      }

      m_WorkflowType.Write(ref outputDoc, ref methodNode, logger);

      XmlNode paramMappings = outputDoc.CreateElement("ParameterDefs");
      foreach (CMASParameterDef paramDef in m_ParameterDefs.Values)
      {
        paramDef.Write(ref outputDoc, ref paramMappings, logger);
      }
      methodNode.AppendChild(paramMappings);

      if (m_RequiredCapabilities.Count > 0)
      {
        XmlNode caps = outputDoc.CreateElement("Capabilities");

        foreach (string cap in m_RequiredCapabilities)
        {
          XmlNode capNode = outputDoc.CreateElement("MTCapability");

          capNode.InnerText = cap;

          caps.AppendChild(capNode);
        }

        methodNode.AppendChild(caps);
      }

      parentNode.AppendChild(methodNode);
    }
    #endregion

    #region Properties
    public string MethodName
    {
      get { return m_MethodName; }
      set { m_MethodName = value; }
    }

    // Current version of MS Workflow Foundation does not support flowing transactions into workflows
    // Commenting out capability until they fix the problem.
    //public bool AllowTransactionFlow
    //{
    //  get { return m_bAllowTransactionFlow; }
    //  set { m_bAllowTransactionFlow = value; }
    //}

    public string FaultType
    {
      get { return m_FaultType; }
      set { m_FaultType = value; }
    }

    public CMASWorkflowType WorkflowType
    {
      get { return m_WorkflowType; }
      set { m_WorkflowType = value; }
    }

    public Dictionary<string, CMASParameterDef> ParameterDefs
    {
      get { return m_ParameterDefs; }
    }

    public List<string> RequiredCapabilities
    {
      get { return m_RequiredCapabilities; }
    }

    public bool IsOneWay 
    {
        get { return m_IsOneWay; }
        set { m_IsOneWay = value; }
    }
    #endregion

  }
}
