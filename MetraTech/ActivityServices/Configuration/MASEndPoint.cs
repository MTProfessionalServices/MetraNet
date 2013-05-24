using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASEndPoint
  {
    #region Members
    private string m_BindingType;
    private string m_BindingName;
    private int m_Port;
    #endregion

    #region Constructor
    public CMASEndPoint()
    {
    }
    #endregion

    #region Parsing
    public static CMASEndPoint Parse(XmlNode wcfEndPoint, Logger logger)
    {
      logger.LogDebug("Parse WCFEndPoint");
      CMASEndPoint endPoint = new CMASEndPoint();

      foreach (XmlAttribute attrib in wcfEndPoint.Attributes)
      {
        switch (attrib.Name)
        {
          case "Type":
            endPoint.BindingType = attrib.Value;
            break;
          case "BindingName":
            endPoint.BindingName = attrib.Value;
            break;
          case "Port":
            endPoint.Port = Int32.Parse(attrib.Value);
            break;
        };
      }

      return endPoint;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write WCFEndPoint");
      XmlNode endPoint = outputDoc.CreateElement("WCFEndpoint");

      XmlAttribute typeAttrib = outputDoc.CreateAttribute("Type");
      typeAttrib.Value = m_BindingType;
      endPoint.Attributes.Append(typeAttrib);

      XmlAttribute nameAttrib = outputDoc.CreateAttribute("BindingName");
      nameAttrib.Value = m_BindingName;
      endPoint.Attributes.Append(nameAttrib);

      XmlAttribute portAttrib = outputDoc.CreateAttribute("Port");
      portAttrib.Value = m_Port.ToString();
      endPoint.Attributes.Append(portAttrib);

      parentNode.AppendChild(endPoint);
    }
    #endregion

    #region Properties
    public string BindingType
    {
      get { return m_BindingType; }
      set { m_BindingType = value; }
    }

    public string BindingName
    {
      get { return m_BindingName; }
      set { m_BindingName = value; }
    }

    public int Port
    {
      get { return m_Port; }
      set { m_Port = value; }
    }
    #endregion
  }
}


