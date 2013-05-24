using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASCodeService
  {
    #region Members
    private string m_ElementName;
    private string m_ServiceType;

    private List<CMASCodeInterface> m_Interfaces = new List<CMASCodeInterface>();
    #endregion

    #region Constructor
    public CMASCodeService()
    {
    }
    #endregion

    #region Parsing
    public static CMASCodeService Parse(XmlNode interfaceNode, Logger logger)
    {
      CMASCodeService codeService = new CMASCodeService();
      CMASCodeInterface codeInterface;

      codeService.ServiceType = interfaceNode.Attributes["Type"].Value;

      if (interfaceNode.Attributes["ElementName"] != null)
      {
        codeService.ElementName = interfaceNode.Attributes["ElementName"].Value;
      }

      logger.LogDebug("Parse Code Service Definition: {0}", codeService.ServiceType);

      foreach (XmlNode interfaceChildNode in interfaceNode.ChildNodes)
      {
        switch (interfaceChildNode.Name)
        {
          case "Interface":
            if (interfaceChildNode.Attributes != null)
            {
              codeInterface = CMASCodeInterface.Parse(interfaceChildNode, logger);
              codeService.Interfaces.Add(codeInterface);
            }
            break;
        }
      }

      return codeService;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Code Service Definition: {0}", m_ServiceType);

      XmlNode serviceNode = outputDoc.CreateElement("MASCodeService");

      XmlAttribute typeAttrib = outputDoc.CreateAttribute("Type");
      typeAttrib.Value = m_ServiceType;
      serviceNode.Attributes.Append(typeAttrib);

      if (!string.IsNullOrEmpty(m_ElementName))
      {
        XmlAttribute elementAttrib = outputDoc.CreateAttribute("ElementName");
        elementAttrib.Value = m_ElementName;
        serviceNode.Attributes.Append(elementAttrib);
      }

      foreach (CMASCodeInterface codeInterface in m_Interfaces)
      {
        codeInterface.Write(ref outputDoc, ref serviceNode, logger);
      }

      parentNode.AppendChild(serviceNode);
    }
    #endregion

    #region Properties
    public string ServiceType
    {
      get { return m_ServiceType; }
      set { m_ServiceType = value; }
    }

    public string ElementName
    {
      get { return m_ElementName; }
      set { m_ElementName = value; }
    }

    public List<CMASCodeInterface> Interfaces
    {
      get { return m_Interfaces; }
    }
    #endregion
  }
}
