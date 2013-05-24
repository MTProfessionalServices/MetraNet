using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.IO;
using MetraTech;

namespace MetraTech.ActivityServices.Configuration
{
  [Serializable]
  public sealed class CMASConfiguration
  {
    #region Members
    private Dictionary<string, CMASEventService> m_EventServiceDefs = new Dictionary<string, CMASEventService>();
    private Dictionary<string, CMASProceduralService> m_ProceduralServiceDefs = new Dictionary<string, CMASProceduralService>();
    private Dictionary<string, CMASCodeService> m_CodeServiceDefs = new Dictionary<string, CMASCodeService>();
    private List<CMASDataExchangeService> m_AdditionalExchangeServices = new List<CMASDataExchangeService>();

    private Logger m_Logger = new Logger("Logging\\ConfigLoader", "[MASConfiguration]");

    #endregion

    #region Constructor
    public CMASConfiguration()
    {
    }

    public CMASConfiguration(string configFilePath)
    {
      ReadConfig(configFilePath);
    }
    #endregion

    #region Public Methods
    public bool ReadConfig(string configFile)
    {
      bool retval = true;

      try
      {
        m_Logger.LogDebug("Start reading ActivityServices configuration from: {0}", configFile);

        m_EventServiceDefs = new Dictionary<string, CMASEventService>();
        m_ProceduralServiceDefs = new Dictionary<string, CMASProceduralService>();
        m_CodeServiceDefs = new Dictionary<string, CMASCodeService>();
        m_AdditionalExchangeServices = new List<CMASDataExchangeService>();

        StreamReader strRdr = new StreamReader(configFile);
        XmlDocument doc = new XmlDocument();
        doc.Load(strRdr);

        XmlNode root = doc.FirstChild.NextSibling;
        CMASEventService eventDef;
        CMASProceduralService procDef;
        CMASCodeService codeDef;
        CMASDataExchangeService exchngSvc;

        foreach (XmlNode childNode in root.ChildNodes)
        {
          if (childNode.Name == "MASServices")
          {
            #region Process CMASInterface Nodes
            foreach (XmlNode interfaceNode in childNode.ChildNodes)
            {
              if (interfaceNode.Name == "MASEventService")
              {
                eventDef = CMASEventService.Parse(interfaceNode, m_Logger);

                m_EventServiceDefs.Add(eventDef.InterfaceName, eventDef);
              }
              else if (interfaceNode.Name == "MASProceduralService")
              {
                procDef = CMASProceduralService.Parse(interfaceNode, m_Logger);

                m_ProceduralServiceDefs.Add(procDef.InterfaceName, procDef);
              }
              else if (interfaceNode.Name == "MASCodeService")
              {
                codeDef = CMASCodeService.Parse(interfaceNode, m_Logger);

                m_CodeServiceDefs.Add(codeDef.ServiceType, codeDef);
              }
            }
            #endregion
          }
          else if (childNode.Name == "AdditionalExchangeServices")
          {
            #region Process Additional Exchange Service Nodes
            foreach (XmlNode svcNode in childNode.ChildNodes)
            {
              exchngSvc = CMASDataExchangeService.Parse(svcNode, m_Logger);

              m_AdditionalExchangeServices.Add(exchngSvc);
            }
            #endregion
          }
        }

        m_Logger.LogInfo("ActivityServices configuration read from: {0}", configFile);
      }
      catch (Exception e)
      {
        m_Logger.LogException(string.Format("Exception reading ActivityServices Configuration file {0}", configFile), e);
        retval = false;
      }

      return retval;
    }

    public bool WriteConfig(string configFile)
    {
      bool retval = true;

      try
      {
        m_Logger.LogDebug("Start writing ActivityServices configuration to: {0}", configFile);
        XmlDocument outputDoc = new XmlDocument();

        XmlDeclaration decl = outputDoc.CreateXmlDeclaration("1.0", "utf-8", "");
        outputDoc.AppendChild(decl);

        XmlNode root = outputDoc.CreateElement("MASConfig");
        outputDoc.AppendChild(root);

        XmlNode interfacesNode = outputDoc.CreateElement("MASServices");
        foreach (CMASEventService dbmfInterface in m_EventServiceDefs.Values)
        {
          dbmfInterface.Write(ref outputDoc, ref interfacesNode, m_Logger);
        }

        foreach (CMASProceduralService dbmfInterface in m_ProceduralServiceDefs.Values)
        {
          dbmfInterface.Write(ref outputDoc, ref interfacesNode, m_Logger);
        }

        foreach (CMASCodeService codeService in m_CodeServiceDefs.Values)
        {
          codeService.Write(ref outputDoc, ref interfacesNode, m_Logger);
        }
        root.AppendChild(interfacesNode);

        if (m_AdditionalExchangeServices.Count > 0)
        {
          XmlNode exchgSvcs = outputDoc.CreateElement("AdditionalExchangeServices");
          foreach (CMASDataExchangeService svc in m_AdditionalExchangeServices)
          {
            svc.Write(ref outputDoc, ref exchgSvcs, m_Logger);
          }
          root.AppendChild(exchgSvcs);
        }

        XmlTextWriter xmlWriter = new XmlTextWriter(configFile, Encoding.UTF8);
        xmlWriter.Formatting = Formatting.Indented;

        outputDoc.WriteTo(xmlWriter);

        xmlWriter.Flush();
        xmlWriter.Close();

        m_Logger.LogInfo("ActivityServices configuration written to: {0}", configFile);
      }
      catch (Exception e)
      {
        m_Logger.LogException(string.Format("Exception writing ActivityServices Configuration file {0}", configFile), e);
        retval = false;
      }

      return retval;
    }
    #endregion

    #region Properties
    public Dictionary<string, CMASEventService> EventServiceDefs
    {
      get { return m_EventServiceDefs; }
    }

    public Dictionary<string, CMASProceduralService> ProceduralServiceDefs
    {
      get { return m_ProceduralServiceDefs; }
    }

    public Dictionary<string, CMASCodeService> CodeServiceDefs
    {
      get { return m_CodeServiceDefs; }
    }

    public List<CMASDataExchangeService> AdditionalExchangeServices
    {
      get { return m_AdditionalExchangeServices; }
    }
    #endregion
  }
}
