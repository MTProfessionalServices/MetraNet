using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  class CMASSupportedChildTypes
  {
    #region Members
    private List<string> m_SupportedChildTypes = new List<string>();
    #endregion

    #region Constructor
    #endregion

    #region Parsing
    public static CMASSupportedChildTypes Parse(XmlNode parameterNode, Logger logger)
    {
      CMASSupportedChildTypes childTypes = new CMASSupportedChildTypes();

      foreach (XmlNode childNode in parameterNode.ChildNodes)
      {
        if (childNode.Name == "ChildType")
        {
          childTypes.SupportedChildTypes.Add(childNode.InnerText);
        }
      }

      return childTypes;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Supported Child Types");

      XmlNode childTypes  = outputDoc.CreateElement("SupportedChildTypes");
      XmlNode childType;
      
      foreach (string childTypeStr in m_SupportedChildTypes)
      {
        childType = outputDoc.CreateElement("ChildType");
        childType.InnerText = childTypeStr;

        childTypes.AppendChild(childType);
      }

      parentNode.AppendChild(childTypes);
    }
    #endregion

    #region Properties
    public List<string> SupportedChildTypes
    {
      get { return m_SupportedChildTypes; }
    }
    #endregion
  }
}
