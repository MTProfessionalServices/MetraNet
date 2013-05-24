using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASProceduralService
  {
    #region Members
    private string m_InterfaceName;
    
    private Dictionary<string, CMASProceduralMethod> m_ProceduralMethods = new Dictionary<string, CMASProceduralMethod>();
    
    private List<CMASEndPoint> m_WCFEndpoints = new List<CMASEndPoint>();
    private CMASSupportedChildTypes m_ChildTypes = new CMASSupportedChildTypes();
    #endregion

    #region Constructor
    public CMASProceduralService()
    {
    }
    #endregion

    #region Parsing
    public static CMASProceduralService Parse(XmlNode interfaceNode, Logger logger)
    {
      CMASProceduralService interfaceDef = new CMASProceduralService();
      CMASProceduralMethod methodDef;
      CMASEndPoint endPoint;

      interfaceDef.InterfaceName = interfaceNode.Attributes["Name"].Value;

      logger.LogDebug("Parse Interface Definition: {0}", interfaceDef.InterfaceName);

      foreach (XmlNode interfaceChildNode in interfaceNode.ChildNodes)
      {
        switch (interfaceChildNode.Name)
        {
          case "ProceduralMethods":
            foreach (XmlNode childNode in interfaceChildNode.ChildNodes)
            {
              if (childNode.Name == "ProceduralMethod")
              {
                methodDef = CMASProceduralMethod.Parse(childNode, logger);

                interfaceDef.ProceduralMethods.Add(methodDef.MethodName, methodDef);
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

      XmlNode interfaceNode = outputDoc.CreateElement("MASProceduralService");
      
      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_InterfaceName;
      interfaceNode.Attributes.Append(nameAttrib);

      XmlNode procMethods = outputDoc.CreateElement("ProceduralMethods");
      foreach (CMASProceduralMethod procMethod in m_ProceduralMethods.Values)
      {
        procMethod.Write(ref outputDoc, ref procMethods, logger);
      }
      interfaceNode.AppendChild(procMethods);

      if (m_WCFEndpoints.Count > 0)
      {
        XmlNode endPoints = outputDoc.CreateElement("WCFEndpoints");
        foreach (CMASEndPoint wcfEndPoint in m_WCFEndpoints)
        {
          wcfEndPoint.Write(ref outputDoc, ref endPoints, logger);
        }
        interfaceNode.AppendChild(endPoints);
      }

      if (m_ChildTypes.SupportedChildTypes.Count > 0)
      {
        m_ChildTypes.Write(ref outputDoc, ref interfaceNode, logger);
      }

      parentNode.AppendChild(interfaceNode);
    }
    #endregion

    #region Properties
    public string InterfaceName
    {
      get { return m_InterfaceName; }
      set { m_InterfaceName = value; }
    }

    public Dictionary<string, CMASProceduralMethod> ProceduralMethods
    {
      get { return m_ProceduralMethods; }
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
