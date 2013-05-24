using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASDataExchangeService
  {
    #region Members
    public string m_ServiceTypeName;
    public string m_ServiceAssembly;
    #endregion

    #region Constructor
    #endregion

    #region Parsing
    public static CMASDataExchangeService Parse(XmlNode svcNode, Logger logger)
    {
      CMASDataExchangeService exchngSvc = new CMASDataExchangeService();

      logger.LogDebug("Parse DataExchangeService");
      foreach (XmlNode svcDataNode in svcNode.ChildNodes)
      {
        switch (svcDataNode.Name)
        {
          case "ServiceTypeName":
            exchngSvc.ServiceTypeName = svcDataNode.InnerText;
            break;
          case "ServiceAssembly":
            exchngSvc.ServiceAssembly = svcDataNode.InnerText;
            break;
        };
      }

      return exchngSvc;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write DataExchangeService");

      XmlNode svcNode = outputDoc.CreateElement("DataExchangeService");

      XmlNode typeNode = outputDoc.CreateElement("ServiceTypeName");
      typeNode.InnerText = m_ServiceTypeName;
      svcNode.AppendChild(typeNode);

      XmlNode assemblyNode = outputDoc.CreateElement("ServiceAssembly");
      assemblyNode.InnerText = m_ServiceAssembly;
      svcNode.AppendChild(assemblyNode);

      parentNode.AppendChild(svcNode);
    }
    #endregion

    #region Properties
    public string ServiceTypeName
    {
      get { return m_ServiceTypeName; }
      set { m_ServiceTypeName = value; }
    }

    public string ServiceAssembly
    {
      get { return m_ServiceAssembly; }
      set { m_ServiceAssembly = value; }
    }
    #endregion

  }
}
