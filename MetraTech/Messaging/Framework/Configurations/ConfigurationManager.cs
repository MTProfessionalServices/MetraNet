using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using MetraTech.Xml;
using MetraTech.Interop.RCD;

namespace MetraTech.Messaging.Framework.Configurations
{
  public class ConfigurationManager
  {
    // Static methods
    private static Logger logger = new Logger("[ConfigurationManager]");
    private static ConfigurationManager mInstance = null;
    private static ConfigurationManager Instance
    {
      get
      {
        if (mInstance == null)
        {
          mInstance = new ConfigurationManager();
        }
        return mInstance;
      }
    }

    public static Configuration ReadFromXml()
    {
      IMTRcd rcd = (IMTRcd)new MTRcd();
      string ConfigDir = rcd.ConfigDir;
      string ConfigFileName = ConfigDir + @"Messaging\MessagingService.xml";
      logger.LogDebug("Reading configuration from {0}", ConfigFileName);
      return Instance.ReadFromXmlFile(ConfigFileName);
    }

    public static Configuration ReadFromXml(string ConfigFileName)
    {
      return Instance.ReadFromXmlFile(ConfigFileName);
    }

    // Non static methods
    private Configuration ReadFromXmlFile(string ConfigFileName)
    {
      Configuration config = new Configuration();
      MTXmlDocument doc = new MTXmlDocument();
      doc.Load(ConfigFileName);
      config.TimeoutRequestInSeconds = doc.GetNodeValueAsInt("xmlconfig/TimeoutRequestSeconds", 30);
      config.ArchiveRequestInMinutes = doc.GetNodeValueAsInt("xmlconfig/ArchiveRequestInMinutes", 30);
      config.RequestPersistenceFolder = doc.GetNodeValueAsString("xmlconfig/RequestPersistenceFolder");
      config.RequestQueue.Name = doc.GetNodeValueAsString("xmlconfig/RequestQueue/Name", "MTRequest");
      config.ErrorQueue.Name = doc.GetNodeValueAsString("xmlconfig/ErrorQueue/Name", "MTError");
      config.ResponseQueue.Name = doc.GetNodeValueAsString("xmlconfig/ResponseQueue/Name", "MTResponse"); // + "@" + System.Net.Dns.GetHostName();
      config.MessagingServerUniqueIdentifier = doc.GetNodeValueAsString("xmlconfig/MessagingServerUniqueIdentifier", System.Net.Dns.GetHostName());
      config.ThreadPool.MaxRequestPoolThreads = doc.GetNodeValueAsInt("xmlconfig/ThreadPool/MaxRequestPoolThreads");
      config.ThreadPool.MaxResponsePoolThreads = doc.GetNodeValueAsInt("xmlconfig/ThreadPool/MaxResponsePoolThreads");

      config.RequestPrefetchCount = doc.GetNodeValueAsInt("xmlconfig/RequestPrefetchCount", 100);
      config.ResponsePrefetchCount = doc.GetNodeValueAsInt("xmlconfig/ResponsePrefetchCount", 100);

      //Read server entry from servers.xml
      config.Server = ReadRabbitMQServerConfig("RabbitMQMessagingServer");

      config.MessageTypeRules = ReadMessageTypeRules(doc);

      return config;
    }

    private RabbitMQServerConfig ReadRabbitMQServerConfig(string serverType)
    {
      // Retrive credentials
      RabbitMQServerConfig server = new RabbitMQServerConfig();

      try
      {
        MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet sa = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
        sa.Initialize();
        MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
        accessData = sa.FindAndReturnObject(serverType);
        server.Address = accessData.ServerName;
        server.UserName = accessData.UserName;
        server.Password = accessData.Password;
        server.Port = accessData.PortNumber;
        server.UseSSL = (accessData.Secure == 1);
      }
      catch (Exception ex)
      {
        //throw new Exception(string.Format("Unable to retrieve credentials for '{0}'. Entry for '{0}' must exist in one of the servers.xml files.", serverType), ex);
        logger.LogException(String.Format("Unable to retrieve credentials for '{0}'. Entry for '{0}' should exist in one of the servers.xml files when running as a service.", serverType), ex);
      }

      
      return server;
    }

    private Dictionary<string, MessageTypeRule> ReadMessageTypeRules(MTXmlDocument doc)
    {
      Dictionary<string, MessageTypeRule> rules = new Dictionary<string, MessageTypeRule>();
      XmlNodeList messageTypes = doc.SelectNodes("/xmlconfig/SupportedMessageTypes/MessageType");
      if (messageTypes.Count == 0)
        throw new Exception("No MessageTypes defined in the config file");
      foreach (XmlNode messageType in messageTypes)
      {
        MessageTypeRule rule = ReadMessageTypeRule(messageType);
        rules.Add(rule.MessageType, rule);
      }
      return rules;
    }

    private MessageTypeRule ReadMessageTypeRule(XmlNode messageType)
    {
      MessageTypeRule rule = new MessageTypeRule();
      // read type
      XmlNode typeNode = messageType.SelectSingleNode("Type");
      if (typeNode == null) throw new Exception("No Type found in");
      string type = typeNode.InnerText.Trim();
      if (type == "") throw new Exception("Type can not be empty");
      rule.MessageType = type;
      // read forward to queue
      XmlNode forwardQueueNode = messageType.SelectSingleNode("ForwardToQueue");
      if (forwardQueueNode == null) throw new Exception("No ForwardToQueue found in");
      rule.ForwardToQueue.Name = forwardQueueNode.InnerText.Trim();
      if (rule.ForwardToQueue.Name == "") throw new Exception("No name for ForwardToQueue");

      return rule;
    }

    /// <summary>
    /// Method to check/validate the configuration, independent of loading the configuration.
    /// Note that in the future, ICE would use something similar to validate configuration although
    /// the list returned would most likely be updated to include Error/Warning/Information type items.
    /// </summary>
    /// <param name="config">The messaging configuration to be validated</param>
    /// <returns>Returns a list of validation issues (empty list if there are no issues)</returns>
    public static List<string> ValidateConfiguration(Configuration config)
    {
      return ValidateConfiguration(config, false);
    }

    /// <summary>
    /// Method to check/validate the configuration, independent of loading the configuration.
    /// Note that in the future, ICE would use something similar to validate configuration although
    /// the list returned would most likely be updated to include Error/Warning/Information type items.
    /// </summary>
    /// <param name="config">The messaging configuration to be validated</param>
    /// <param name="throwException">Indicates if an exception should be thrown if issues are found</param>
    /// <returns>Returns a list of validation issues (empty list if there are no issues)</returns>
    public static List<string> ValidateConfiguration(Configuration config, bool throwException)
    {
      List<string> results = new List<string>();

      if (config.Server == null)
        results.Add("RabbitMq Server information not specified");
      else
      {
        if (string.IsNullOrWhiteSpace(config.Server.Address))
          results.Add("RabbitMQ server address must be specified for Messaging Server");

        if (string.IsNullOrWhiteSpace(config.Server.UserName))
          results.Add("RabbitMQ User Name must be specified for Messaging Server");

        if (string.IsNullOrWhiteSpace(config.Server.Password))
          results.Add("RabbitMQ password must be specified for Messaging Server");

        try
        {
          int testRequestPrefetchCount;
          testRequestPrefetchCount = Convert.ToUInt16(config.RequestPrefetchCount);
        }
        catch (Exception)
        {
          results.Add(string.Format("RequestPrefetchCount is {0} but must be a valid value between 0 [no limit] and {1}", config.RequestPrefetchCount, ushort.MaxValue));
        }

        try
        {
          int testResponsePrefetchCount;
          testResponsePrefetchCount = Convert.ToUInt16(config.ResponsePrefetchCount);
        }
        catch (Exception)
        {
          results.Add(string.Format("ResponsePrefetchCount is {0} but must be a valid value between 0 [no limit] and {1}", config.RequestPrefetchCount, ushort.MaxValue));
        }
      }



      if (results.Count>1)
      {
        results.Add("Check the MessagingService.xml and that there is a valid 'RabbitMQMessagingServer' entry in servers.xml");

        if (throwException)
        {
          string message = "Invalid Messaging Server configuration: ";
          foreach (string issue in results)
            message += issue + System.Environment.NewLine;

          throw new Exception(message);
        }
      }

      return results;
    }

    //throw new Exception(string.Format("Unable to retrieve credentials for '{0}'. Entry for '{0}' must exist in one of the servers.xml files.", serverType), ex);

    /// <summary>
    /// For testing only
    /// </summary>
    /// <returns></returns>
    private Configuration DefaultConfig()
    {
      Configuration config = new Configuration();
      config.Server = new RabbitMQServerConfig() { Address = "localhost", UserName = "guest", Password = "guest", Port = 5672 };
      config.RequestQueue = new QueueConfig { Name = "MTRequest" };
      config.ResponseQueue = new QueueConfig { Name = "MTResponse@" + System.Net.Dns.GetHostName() };
      config.ErrorQueue = new QueueConfig { Name = "MTError" };
      config.ThreadPool = new ThreadPoolConfig { MaxRequestPoolThreads = 5, MaxResponsePoolThreads = 5 };
      config.TimeoutRequestInSeconds = 30;
      config.ArchiveRequestInMinutes = 30;
      return config;
    }

  }
}
