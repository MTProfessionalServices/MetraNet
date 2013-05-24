using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using NHibernate.Cfg;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public static class NHibernateConfig
  {
      static NHibernateConfig()
      {
          ConnectionInfoList = new List<ConnectionInfo>();
          ConnectionInfo connectionInfo;
              
          // Set the NHibernate properties using the contents of RMP\config\serveraccess\servers.xml
          serversXml = SystemConfig.GetServersXml();

          foreach (string serverXml in serversXml)
          {
              logger.Debug(String.Format("Loading connection info from file '{0}'", serverXml));

              // Get all <server> elements which have a <hasBme> element with a value of 'true' and
              // NetMeter
              var servers = from s in XElement.Load(serverXml).Elements("server")
                            where (s.Element("hasBme") != null && s.Element("hasBme").Value == "true") ||
                                  (s.Element("servertype").Value.ToLower() == "netmeter")
                            select s;

              foreach (XElement xElement in servers)
              {
                  connectionInfo = ConnectionInfo.CreateConnectionInfo(xElement);
                  ConnectionInfoList.Add(connectionInfo);
                  logger.Debug(String.Format("Added BME database connection info '{0}'", connectionInfo));
              }
          }
          
          connectionInfo = ConnectionInfoList.Find(c => c.ServerType == "NetMeter");
          Check.Require(connectionInfo != null,
                        String.Format("Cannot find <servertype> element with a value of 'NetMeter' in file '{0}'",
                                      serversXml));

      }

    public static List<string> GetDatabaseNames()
    {
      return ConnectionInfoList.ConvertAll(c => c.ServerType);
    }

    public static Configuration GetConfiguration(string databaseName)
    {
      return GetConnectionInfo(databaseName).Configuration;
    }

    public static Configuration GetNewConfiguration(string databaseName)
    {
      return GetConnectionInfo(databaseName).GetNewConfiguration();
    }

    public static ConnectionInfo GetConnectionInfo(string databaseName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");

      var connectionInfo = ConnectionInfoList.Find(c => c.ServerType.ToLower() == databaseName.ToLower());
      Check.Require(connectionInfo != null, 
                    String.Format("Cannot find ConnectionInfo element for database name '{0}'", databaseName));

      Check.Require(connectionInfo.Configuration != null,
                    String.Format("NHibernate Configuration for database '{0}' has not been created", databaseName));

      return connectionInfo;
    }

    public static bool IsBmeDatabase(string databaseName)
    {
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");

      var connectionInfo = ConnectionInfoList.Find(c => c.ServerType.ToLower() == databaseName.ToLower());
      return connectionInfo != null;
    }

    public static bool IsOracle(string databaseName)
    {
      ConnectionInfo connectionInfo =
        ConnectionInfoList.Find(c => c.ServerType.ToLower() == databaseName.ToLower());

      Check.Require(connectionInfo != null, String.Format("Cannot find ConnectionInfo for database '{0}'", databaseName));

      return connectionInfo.IsOracle;
    }

    
    #region Private Methods
   
    #endregion

    #region Private Properties
    /// <summary>
    ///    Store each ConnectionInfo by ConnectionInfo.ServerType
    /// </summary>
    internal static List<ConnectionInfo> ConnectionInfoList;
    #endregion


    #region Data
    private static readonly ILog logger = LogManager.GetLogger("NHibernateConfig");
    private static readonly List<string> serversXml;
    #endregion
  }
}
