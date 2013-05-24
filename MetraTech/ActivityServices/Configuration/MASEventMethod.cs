using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASEventMethod
  {
    #region Members
    private string m_MethodName;
    private string m_EventName;

    // Current version of MS Workflow Foundation does not support flowing transactions into workflows
    // Commenting out capability until they fix the problem.
    //private bool m_bAllowTransactionFlow = false;

    private string m_FaultType = "MASBasicFaultDetail";

    private Dictionary<string, CMASParameterDef> m_ParameterDefs = new Dictionary<string, CMASParameterDef>();

    private List<string> m_RequiredCapabilities = new List<string>();
    #endregion

    #region Constructor
    #endregion

    #region Parsing
    public static CMASEventMethod Parse(XmlNode eventMethodNode, Logger logger)
    {
      CMASEventMethod methodDef = new CMASEventMethod();
      CMASParameterDef paramDef;

      methodDef.MethodName = eventMethodNode.Attributes["Name"].Value;
      methodDef.EventName = eventMethodNode.Attributes["EventName"].Value;

      // Current version of MS Workflow Foundation does not support flowing transactions into workflows
      // Commenting out capability until they fix the problem.
      //if (eventMethodNode.Attributes["AllowTransactionFlow"] != null)
      //{
      //  methodDef.m_bAllowTransactionFlow = bool.Parse(eventMethodNode.Attributes["AllowTransactionFlow"].Value);
      //}

      if (eventMethodNode.Attributes["FaultType"] != null)
      {
        methodDef.m_FaultType = eventMethodNode.Attributes["FaultType"].Value;
      }

      logger.LogDebug("Parse EventMethod: {0}", methodDef.m_MethodName);

      foreach (XmlNode methodNode in eventMethodNode.ChildNodes)
      {
        if(methodNode.Name == "ParameterDefs")
        {            
            foreach (XmlNode parameterNode in methodNode.ChildNodes)
            {
              if (parameterNode.Name == "Parameter")
              {
                paramDef = CMASParameterDef.Parse(parameterNode, logger);
                
                methodDef.ParameterDefs.Add(paramDef.ParameterName, paramDef);
              }
            }
            break;
        }
        else if (methodNode.Name == "Capabilities")
        {
          foreach (XmlNode capNode in methodNode.ChildNodes)
          {
            if (capNode.Name == "MTCapability")
            {
              methodDef.m_RequiredCapabilities.Add(capNode.InnerText);
            }
          }
        }
      }

      return methodDef;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Event Method: {0}", m_MethodName);
      XmlNode methodNode = outputDoc.CreateElement("EventMethod");

      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_MethodName;
      methodNode.Attributes.Append(nameAttrib);

      nameAttrib = outputDoc.CreateAttribute("EventName");
      nameAttrib.Value = m_EventName;
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

      XmlNode paramMappings = outputDoc.CreateElement("ParameterDefs");
      foreach (CMASParameterDef paramDef in m_ParameterDefs.Values)
      {
        paramDef.Write(ref outputDoc, ref paramMappings, logger);
      }
      methodNode.AppendChild(paramMappings);

      parentNode.AppendChild(methodNode);
    }
    #endregion

    #region Properties
    public string EventName
    {
      get { return m_EventName; }
      set { m_EventName = value; }
    }

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

    public Dictionary<string, CMASParameterDef> ParameterDefs
    {
      get { return m_ParameterDefs; }
    }

    public List<string> RequiredCapabilities
    {
      get { return m_RequiredCapabilities; }
    }
    #endregion

  }
}
