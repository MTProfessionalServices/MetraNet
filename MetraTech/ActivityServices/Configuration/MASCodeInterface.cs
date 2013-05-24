using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASCodeInterface
  {
    #region Members
    private string m_InterfaceName;
    private string m_ContractType;

    private List<CMASEndPoint> m_WCFEndpoints = new List<CMASEndPoint>();
    #endregion

    #region Constructor
    public CMASCodeInterface()
    {
    }
    #endregion

    #region Parsing
    public static CMASCodeInterface Parse(XmlNode interfaceNode, Logger logger)
    {
      CMASCodeInterface codeInterface = new CMASCodeInterface();
      CMASEndPoint endPoint;

      codeInterface.InterfaceName = interfaceNode.Attributes["Name"].Value;
      codeInterface.ContractType = interfaceNode.Attributes["ContractType"].Value;

      logger.LogDebug("Parse Code Interface Definition: {0}", codeInterface.InterfaceName);

      foreach (XmlNode interfaceChildNode in interfaceNode.ChildNodes)
      {
        switch (interfaceChildNode.Name)
        {
          case "WCFEndpoints":
            foreach (XmlNode wcfEndpoint in interfaceChildNode.ChildNodes)
            {
              if (wcfEndpoint.Attributes != null)
              {
                endPoint = CMASEndPoint.Parse(wcfEndpoint, logger);

                codeInterface.WCFEndPoints.Add(endPoint);
              }
            }

            break;
        };
      }

      return codeInterface;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Code Interface Definition: {0}", m_InterfaceName);

      XmlNode interfaceNode = outputDoc.CreateElement("Interface");

      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_InterfaceName;
      interfaceNode.Attributes.Append(nameAttrib);

      XmlAttribute contractAttrib = outputDoc.CreateAttribute("ContractType");
      contractAttrib.Value = m_ContractType;
      interfaceNode.Attributes.Append(contractAttrib);

      if (m_WCFEndpoints.Count > 0)
      {
        XmlNode endPoints = outputDoc.CreateElement("WCFEndpoints");
        foreach (CMASEndPoint wcfEndPoint in m_WCFEndpoints)
        {
          wcfEndPoint.Write(ref outputDoc, ref endPoints, logger);
        }
        interfaceNode.AppendChild(endPoints);
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

    public string ContractType
    {
      get { return m_ContractType; }
      set { m_ContractType = value; }
    }

    public List<CMASEndPoint> WCFEndPoints
    {
      get { return m_WCFEndpoints; }
    }
    #endregion
  }
}
