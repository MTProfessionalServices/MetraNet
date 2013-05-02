using System;
using System.Collections;
using System.IO;
using System.Xml;
using System.Runtime.InteropServices;

using MetraTech.Utils;
using MetraTech.Interop.MTPipelineLib;
using MetraTech.Interop.PipelineControl;
using MetraTech.Interop.PropSet;

namespace MetraTech.Pipeline.Plugins.Test
{
  public enum PropertyType 
  {
    Int32,
    Int64,
    String,
    DateTime,
    Enum,
    Decimal,
    Bool,
    Double
  }

	/// <summary>
	/// Summary description for PluginTestLib.
	/// </summary>
	public class PluginTestLib
	{
    #region Public Methods
		public PluginTestLib(string serviceName)
		{
      // Initialize sysContext
      sysContext = 
        (MetraTech.Interop.MTPipelineLib.IMTSystemContext)
				  new MetraTech.Interop.SysContext.MTSystemContext();

      // sysContext.ExtensionName = extensionName;

      // Initialize pipeline
      pipeline = new MetraTech.Interop.PipelineControl.MTPipeline();

      // Initialize sessionServer
      sessionServer = pipeline.SessionServer;

      nameId = sysContext.GetNameID();
      serviceId = nameId.GetNameID(serviceName);

		IMTLog logger = sysContext.GetLog();
		logger.Init("logging", "[PlugIn]");

      // create an object owner
      owner =
        (MetraTech.Interop.MTPipelineLib.IMTObjectOwner)
          sessionServer.CreateObjectOwner();

      // this is a harmless way to initialize the object
      owner.InitForNotifyStage(0, 0);
      // set the (encoded) ID
      // 0->-2, 1->-3
      encodedOwnerId = (- owner.id) - 2;

      InitializePropertyTypeLookup();
		}

    public Plugin CreatePlugin(string progId, string configuration) 
    {
      Plugin plugin = null;

      try
      {
        Type pluginType = Type.GetTypeFromProgID(progId, true);
        if (pluginType != null)
        {
          IMTPipelinePlugIn mTPipelinePlugIn = (IMTPipelinePlugIn)Activator.CreateInstance(pluginType);
          ConfigurePlugin(configuration, mTPipelinePlugIn);
          plugin = new Plugin(this, mTPipelinePlugIn);
        }
        else
        {
          throw new ApplicationException("Unable to get type from prog id " + progId);
        }
      }
      catch (Exception e)
      {
        throw new ApplicationException("Unable to create plugin with error: " + e.Message);
      }

      return plugin;
    }

    public MetraTech.Interop.MTPipelineLib.IMTSessionSet 
      CreateSessionSet() 
    {
      MetraTech.Interop.MTPipelineLib.IMTSessionSet sessionSet = null;

      // Create the session set
      sessionSet =
        (MetraTech.Interop.MTPipelineLib.IMTSessionSet) sessionServer.CreateSessionSet();

      return sessionSet;

    }

    public MetraTech.Interop.MTPipelineLib.IMTSessionSet 
      CreateSessionSet(string sessionData) 
    {
      MetraTech.Interop.MTPipelineLib.IMTSessionSet sessionSet = null;

      // Create the session set
      sessionSet =
        (MetraTech.Interop.MTPipelineLib.IMTSessionSet) sessionServer.CreateSessionSet();

      XmlDocument doc = new XmlDocument();
      doc.Load(new StringReader(sessionData));

      XmlNodeList sessionNodeList;
      XmlNodeList propertyNodeList;
      XmlElement root = doc.DocumentElement;
      sessionNodeList = root.GetElementsByTagName("session");
      
      if (sessionNodeList.Count == 0) 
      {
        throw new ApplicationException("No Session Data");
      }

      foreach (XmlNode sessionNode in sessionNodeList)
      {
        propertyNodeList = sessionNode.ChildNodes; 
        CreateSession(propertyNodeList, sessionSet);
      }

      return sessionSet;
    }

    // Creates a session, and adds it to the sessionSet
    public MetraTech.Interop.MTPipelineLib.IMTSession CreateSession
      (MetraTech.Interop.MTPipelineLib.IMTSessionSet sessionSet) 
    {
      // generate a UID
      string uidStr = MSIXUtils.CreateUID();
      byte [] uid = MSIXUtils.DecodeUID(uidStr);

      // create the session object
      MetraTech.Interop.MTPipelineLib.IMTSession session =
        (MetraTech.Interop.MTPipelineLib.IMTSession)
        sessionServer.CreateSession(uid, serviceId);

      // connect up to the owner
      session.ObjectOwnerID = encodedOwnerId;

      // add session to the session set
      sessionSet.AddSession(session.SessionID, session.ServiceID);

      owner.IncreaseSharedRefCount();

      return session;
    }

    public void SetSessionProperty
      (MetraTech.Interop.MTPipelineLib.IMTSession session,
       string propertyName,
       object propertyValue,
       PropertyType propertyType)
    {
      int id = nameId.GetNameID(propertyName);

      switch (propertyType)
      {
        case PropertyType.Int32:
          {
            session.SetLongProperty(id, Convert.ToInt32(propertyValue));
            break;
          }
        case PropertyType.Int64:
          {
            session.SetLongLongProperty(id, Convert.ToInt64(propertyValue));
            break;
          }
        case PropertyType.String:
          {
            session.SetStringProperty(id, Convert.ToString(propertyValue));
            break;
          }
        case PropertyType.DateTime:
          {
            if (propertyValue.Equals("[metratime]"))
            {
              session.SetOLEDateProperty(id, MetraTech.MetraTime.Now);
            }
            else
            {
              session.SetOLEDateProperty(id, Convert.ToDateTime(propertyValue));
            }

            break;
          }
        case PropertyType.Enum:
          {
            session.SetEnumProperty(id, Convert.ToInt32(propertyValue));
            break;
          }
        case PropertyType.Decimal:
          {
            session.SetDecimalProperty(id, Convert.ToDecimal(propertyValue));
            break;
          }
        case PropertyType.Bool:
          {
            if (propertyValue.Equals("1") || propertyValue.Equals("Y"))
            {
              session.SetBoolProperty(id, true);
            }
            else if (propertyValue.Equals("0") || propertyValue.Equals("N"))
            {
              session.SetBoolProperty(id, false);
            }
            else
            {
              throw new ApplicationException("Bad Boolean Data: " + propertyValue);
            }

            break;
          }
        case PropertyType.Double:
          {
            session.SetDoubleProperty(id, Convert.ToDouble(propertyValue));
            break;
          }
        default:
          {
            throw new ApplicationException("Unknown property Type: " + propertyType);
          }
      }
    }

    public object GetSessionProperty(MetraTech.Interop.MTPipelineLib.IMTSession session,
                                     string propertyName, 
                                     PropertyType propertyType) 
    {
      int id = nameId.GetNameID(propertyName);
      object value = null;

      switch(propertyType) 
      {
        case PropertyType.Int32: 
        {
          value = session.GetLongProperty(id);
          break;
        }
        case PropertyType.Int64: 
        {
          value = session.GetLongLongProperty(id);
          break;
        }
        case PropertyType.String: 
        {
          value = session.GetStringProperty(id);
          break;
        }
        case PropertyType.DateTime: 
        {
          
          value = session.GetOLEDateProperty(id);
          break;
        }
        case PropertyType.Enum: 
        {
          value = session.GetEnumProperty(id);
          break;
        }
        case PropertyType.Decimal: 
        {
          value = session.GetDecimalProperty(id);
          break;
        }
        case PropertyType.Bool: 
        {
          value = session.GetBoolProperty(id);
          break;
        }
        case PropertyType.Double:
        {
          value = session.GetDoubleProperty(id);
          break;
        }
        default: 
        {
          throw new ApplicationException("Unknown property Type: " + propertyType);
        }
      }

      return value;
    }

    #endregion

    #region Properties
    public IMTNameID NameId 
    {
      get 
      {
        return nameId;
      }
    }
    #endregion


    #region Private Methods
    private bool ValidateConfiguration
      (MetraTech.Interop.PropSet.IMTConfigPropSet propertySet) 
    {
      bool isValid = true;

      return isValid;
    }

    private void ConfigurePlugin(string configuration, IMTPipelinePlugIn plugin) 
    {
      MetraTech.Interop.PropSet.IMTConfig propset = 
        new MetraTech.Interop.PropSet.MTConfig();

      bool match;

      MetraTech.Interop.PropSet.IMTConfigPropSet xmlConfigData =
        propset.ReadConfigurationFromString(configuration, out match);

      MetraTech.Interop.PropSet.IMTConfigPropSet mtConfigData =
        xmlConfigData.NextSetWithName("mtconfigdata");

      if (mtConfigData == null)
      {
        throw new ApplicationException("Unable to find <mtconfigdata> in the configuration " + configuration);
      }

      MetraTech.Interop.PropSet.IMTConfigPropSet processor =
        mtConfigData.NextSetWithName("processor");

      if (processor == null)
      {
        throw new ApplicationException("Unable to find <processor> in the configuration " + configuration);
      }

      MetraTech.Interop.PropSet.IMTConfigPropSet configData =
        processor.NextSetWithName("configdata");

      if (configData == null)
      {
        throw new ApplicationException("Unable to find <configdata> in the configuration " + configuration);
      }


      if (!ValidateConfiguration(configData)) 
      {
        throw new ApplicationException("Invalid plugin configuration");
      }

      plugin.Configure(sysContext, (MetraTech.Interop.MTPipelineLib.IMTConfigPropSet)configData);
    }

    // Creates a session, initializes it with the properties passed in
    // the propertyNodeList and adds the session to the sessionSet
    private void CreateSession
      (XmlNodeList propertyNodeList,
       MetraTech.Interop.MTPipelineLib.IMTSessionSet sessionSet) 
    {
      // generate a UID
      string uidStr = MSIXUtils.CreateUID();
      byte [] uid = MSIXUtils.DecodeUID(uidStr);

      // create the session object
      MetraTech.Interop.MTPipelineLib.IMTSession session =
        (MetraTech.Interop.MTPipelineLib.IMTSession)
          sessionServer.CreateSession(uid, serviceId);

      // connect up to the owner
      session.ObjectOwnerID = encodedOwnerId;

      // set the session properties
      foreach(XmlNode node in propertyNodeList) 
      {
        SetSessionProperty(session, node);
      }

      // add session to the session set
      sessionSet.AddSession(session.SessionID, session.ServiceID);

      owner.IncreaseSharedRefCount();
    }

    private void SetSessionProperty
      (MetraTech.Interop.MTPipelineLib.IMTSession session,
       XmlNode propertyNode) 
    {
      string name = propertyNode["name"].InnerText;
      string type = propertyNode["type"].InnerText;
      string propertyValue = propertyNode["value"].InnerText;

      PropertyType propertyType = (PropertyType)propertyTypeLookup[type];

      SetSessionProperty(session, name, propertyValue, propertyType);
    }

    private void InitializePropertyTypeLookup() 
    {
      propertyTypeLookup = new Hashtable();
      propertyTypeLookup["long"] = PropertyType.Int32;
      propertyTypeLookup["longlong"] = PropertyType.Int64;
      propertyTypeLookup["string"] = PropertyType.String;
      propertyTypeLookup["timestamp"] = PropertyType.DateTime;
      propertyTypeLookup["enum"] = PropertyType.Enum;
      propertyTypeLookup["decimal"] = PropertyType.Decimal;
      propertyTypeLookup["bool"] = PropertyType.Bool;
      propertyTypeLookup["double"] = PropertyType.Double;
    }

    #endregion

    // Data
    private MetraTech.Interop.MTPipelineLib.IMTSystemContext sysContext;
    private MetraTech.Interop.PipelineControl.IMTPipeline pipeline;
    private MetraTech.Interop.PipelineControl.IMTSessionServer sessionServer;
    private MetraTech.Interop.MTPipelineLib.IMTNameID nameId;
    private MetraTech.Interop.MTPipelineLib.IMTObjectOwner owner;
    private int serviceId;
    private int encodedOwnerId;

    private Hashtable propertyTypeLookup;

    private const string TAG_MT_CONFIG_DATA = "mtconfigdata";
    private const string TAG_PROCESSOR = "processor";
    private const string TAG_CONFIG_DATA = "configdata";
	}
}
