using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASEventService
  {
    #region Members
    private string m_InterfaceName;
    private string m_DataTypeName;
    private bool m_AllowMultiple = false;
    private bool m_IsPageNav = false;

    private CMASWorkflowType m_WorkflowType = new CMASWorkflowType();
    private Dictionary<string, CMASEventMethod> m_EventMethods = new Dictionary<string, CMASEventMethod>();
    private List<CMASEndPoint> m_WCFEndpoints = new List<CMASEndPoint>();
    private CMASSupportedChildTypes m_ChildTypes = new CMASSupportedChildTypes();
    #endregion

    #region Constructor
    public CMASEventService()
    {
    }
    #endregion

    #region Parsing
    public static CMASEventService Parse(XmlNode interfaceNode, Logger logger)
    {
      CMASEventService interfaceDef = new CMASEventService();
      CMASEndPoint endPoint;
      CMASEventMethod methodDef;

      interfaceDef.InterfaceName = interfaceNode.Attributes["Name"].Value;

      if (interfaceNode.Attributes["AllowMultiple"] != null)
      {
        interfaceDef.AllowMultiple = bool.Parse(interfaceNode.Attributes["AllowMultiple"].Value);
      }

      if (interfaceNode.Attributes["IsPageNav"] != null)
      {
        interfaceDef.IsPageNav = bool.Parse(interfaceNode.Attributes["IsPageNav"].Value);
      }

      logger.LogDebug("Parse Interface Definition: {0}", interfaceDef.InterfaceName);

      foreach (XmlNode interfaceChildNode in interfaceNode.ChildNodes)
      {
        switch (interfaceChildNode.Name)
        {
          case "DataTypeName":
            interfaceDef.DataTypeName = interfaceChildNode.InnerText;
            break;

          case "WorkflowType":
            interfaceDef.WorkflowType = CMASWorkflowType.Parse(interfaceChildNode, logger);
            break;

          case "EventMethods":
            foreach (XmlNode childNode in interfaceChildNode.ChildNodes)
            {
              if (childNode.Name == "EventMethod")
              {
                methodDef = CMASEventMethod.Parse(childNode, logger);

                interfaceDef.EventMethods.Add(methodDef.MethodName, methodDef);
              }
            }
            break;

          case "WCFEndpoints":
            foreach (XmlNode wcfEndpoint in interfaceChildNode.ChildNodes)
            {
              if (wcfEndpoint.Attributes != null)
              {
                endPoint = CMASEndPoint.Parse(wcfEndpoint, logger);

                interfaceDef.WCFEndPoints.Add(endPoint);
              }
            }

            break;

          case "SupportedChildTypes":
            interfaceDef.m_ChildTypes = CMASSupportedChildTypes.Parse(interfaceChildNode, logger);
            break;

        };
      }

      return interfaceDef;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Interface Definition: {0}", m_InterfaceName);

      XmlNode interfaceNode = outputDoc.CreateElement("MASEventService");
      
      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_InterfaceName;
      interfaceNode.Attributes.Append(nameAttrib);

      XmlAttribute allowMultAttrib = outputDoc.CreateAttribute("AllowMultiple");
      allowMultAttrib.Value = m_AllowMultiple.ToString();
      interfaceNode.Attributes.Append(allowMultAttrib);

      if (IsPageNav)
      {
        XmlAttribute isPageNavAttrib = outputDoc.CreateAttribute("IsPageNav");
        isPageNavAttrib.Value = m_IsPageNav.ToString();
        interfaceNode.Attributes.Append(isPageNavAttrib);
      }

      XmlNode dataTypeNode = outputDoc.CreateElement("DataTypeName");
      dataTypeNode.InnerText = m_DataTypeName;
      interfaceNode.AppendChild(dataTypeNode);

      m_WorkflowType.Write(ref outputDoc, ref interfaceNode, logger);

      XmlNode eventMethods = outputDoc.CreateElement("EventMethods");
      foreach (CMASEventMethod eventMethod in m_EventMethods.Values)
      {
        eventMethod.Write(ref outputDoc, ref eventMethods, logger);
      }
      interfaceNode.AppendChild(eventMethods);

      if (m_WCFEndpoints.Count > 0)
      {
        XmlNode endPoints = outputDoc.CreateElement("WCFEndpoints");
        foreach (CMASEndPoint wcfEndPoint in m_WCFEndpoints)
        {
          wcfEndPoint.Write(ref outputDoc, ref endPoints, logger);
        }
        interfaceNode.AppendChild(endPoints);
      }

      m_ChildTypes.Write(ref outputDoc, ref interfaceNode, logger);

      parentNode.AppendChild(interfaceNode);
    }
    #endregion

    #region Properties
    public string InterfaceName
    {
      get { return m_InterfaceName; }
      set { m_InterfaceName = value; }
    }

    public string DataTypeName
    {
      get { return m_DataTypeName; }
      set { m_DataTypeName = value; }
    }

    public bool AllowMultiple
    {
      get { return m_AllowMultiple; }
      set { m_AllowMultiple = value; }
    }

    public bool IsPageNav
    {
      get { return m_IsPageNav; }
      set { m_IsPageNav = value; }
    }

    public CMASWorkflowType WorkflowType
    {
      get { return m_WorkflowType; }
      set { m_WorkflowType = value; }
    }

    public Dictionary<string, CMASEventMethod> EventMethods
    {
      get { return m_EventMethods; }
    }

    public List<CMASEndPoint> WCFEndPoints
    {
      get { return m_WCFEndpoints; }
    }

    public List<string> SupportedChildTypes
    {
      get { return m_ChildTypes.SupportedChildTypes; }
    }
    #endregion
  }
}
