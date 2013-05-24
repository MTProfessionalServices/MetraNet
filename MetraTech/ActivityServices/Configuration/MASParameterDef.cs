using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASParameterDef
  {
    public enum ParameterDirection
    {
      In,
      Out,
      InOut
    };

    #region Members
    private string m_ParameterType;
    private string m_ParameterName;

    private ParameterDirection m_ParameterDirection = ParameterDirection.In;

    private string m_InternalName = null;
    private bool m_IsInstanceIdentifier = false;
    #endregion

    #region Constructor
    #endregion

    #region Parsing
    public static CMASParameterDef Parse(XmlNode parameterNode, Logger logger)
    {
      CMASParameterDef paramDef = new CMASParameterDef();

      paramDef.ParameterName = parameterNode.Attributes["Name"].Value;

      logger.LogDebug("Parse Parameter Mapping", paramDef.ParameterName);

      paramDef.ParameterType = parameterNode.Attributes["Type"].Value;

      if (parameterNode.Attributes["Direction"] != null)
      {
        paramDef.ParamDirection = (ParameterDirection)Enum.Parse(typeof(ParameterDirection), parameterNode.Attributes["Direction"].Value);
      }

      if (parameterNode.Attributes["InstanceIdentifier"] != null)
      {
          paramDef.IsInstanceIdentifier = bool.Parse(parameterNode.Attributes["InstanceIdentifier"].Value);
      }

      foreach (XmlNode dataNode in parameterNode.ChildNodes)
      {
        switch (dataNode.Name)
        {
          case "InternalName":
            paramDef.InternalName = dataNode.InnerText;
            break;
        };
      }

      return paramDef;
    }
    #endregion

    #region Output
    public void Write(ref XmlDocument outputDoc, ref XmlNode parentNode, Logger logger)
    {
      logger.LogDebug("Write Parameter Mapping", ParameterName);

      XmlNode paramMapping = outputDoc.CreateElement("Parameter");

      XmlAttribute nameAttrib = outputDoc.CreateAttribute("Name");
      nameAttrib.Value = m_ParameterName;
      paramMapping.Attributes.Append(nameAttrib);

      XmlAttribute typeAttrib = outputDoc.CreateAttribute("Type");
      typeAttrib.Value = m_ParameterType;
      paramMapping.Attributes.Append(typeAttrib);

      XmlAttribute directionAttrib = outputDoc.CreateAttribute("Direction");
      directionAttrib.Value = m_ParameterDirection.ToString();
      paramMapping.Attributes.Append(directionAttrib);

      if (m_IsInstanceIdentifier)
      {
          XmlAttribute idAttrib = outputDoc.CreateAttribute("InstanceIdentifier");
          idAttrib.Value = m_IsInstanceIdentifier.ToString();
          paramMapping.Attributes.Append(idAttrib);
      }

      if (m_InternalName != null)
      {
        XmlNode internalName = outputDoc.CreateElement("InternalName");

        internalName.InnerText = m_InternalName;

        paramMapping.AppendChild(internalName);
      }

      
      parentNode.AppendChild(paramMapping);
    }
    #endregion

    #region Properties
    public string ParameterType
    {
      get { return m_ParameterType; }
      set { m_ParameterType = value; }
    }

    public string ParameterName
    {
      get { return m_ParameterName; }
      set { m_ParameterName = value; }
    }

    public ParameterDirection ParamDirection
    {
      get { return m_ParameterDirection; }
      set { m_ParameterDirection = value; }
    }

    public string InternalName
    {
      get { return m_InternalName; }
      set { m_InternalName = value; }
    }

    public bool IsInstanceIdentifier
    {
        get
        { 
            return m_IsInstanceIdentifier; 
        }
        set
        {
            m_IsInstanceIdentifier = value;
        }
    }
    #endregion
  }
}
