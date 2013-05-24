using System;
using System.Collections.Generic;
using System.Xml.Linq;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Security.Crypto;
using NHibernate.Cfg;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class ConnectionInfo
  {
    #region Public Methods
    public ConnectionInfo()
    {
      NHibernateConfigProperties = new Dictionary<string, string>();
    }

    public static ConnectionInfo CreateConnectionInfo(XElement serverElement)
    {
      #region Notes
      // The NHibernate SqlServer properties like the following:

      // <property name="connection.provider">NHibernate.Connection.DriverConnectionProvider, NHibernate</property>
      // <property name="connection.driver_class">NHibernate.Driver.SqlClientDriver</property>
      // <property name="connection.connection_string">
      //   Server=(local);initial catalog=NetMeter;User Id=nmdbo;Password=MetraTech1;
      // </property>
      // <property name="adonet.batch_size">100</property>
      // <property name="show_sql">true</property>
      // <property name="dialect">NHibernate.Dialect.MsSql2005Dialect</property>
      // <property name="proxyfactory.factory_class">NHibernate.ByteCode.Castle.ProxyFactoryFactory, NHibernate.ByteCode.Castle</property>

      // The corresponding entry in RMP\config\serveraccess\servers.xml looks like the following:
      //  <server>
      //    <servertype>NetMeter</servertype>
      //    <servername>localhost</servername>
      //    <databasename>NetMeter</databasename>
      //    <databasedriver>{SQL Server}</databasedriver>
      //    <databasetype>{Sql Server}</databasetype>
      //    <username>nmdbo</username>
      //    <password encrypted="true">cbb23d8d-8189-4039-a575-a7388c369d99s3sB9PwdhdpHUFYAzRN/fUwcL7h/7iMdlYIMp0HaJRA=</password>
      //  </server>

      // The NHibernate Oracle properties looks like the following:
      // <property name="connection.provider">NHibernate.Connection.DriverConnectionProvider, NHibernate</property>
      // <property name="connection.driver_class">NHibernate.Driver.OracleClientDriver</property>
      // <property name="connection.connection_string">
      //   Data Source=DEV-RAC1;User Id=sudip;Password=sudip;
      // </property>
      // <property name="show_sql">true</property>
      // <property name="dialect">NHibernate.Dialect.Oracle10gDialect</property>
      // <property name="proxyfactory.factory_class">NHibernate.ByteCode.Castle.ProxyFactoryFactory, NHibernate.ByteCode.Castle</property>
      // <property name="hbm2ddl.keywords">none</property>

      // The corresponding entry in RMP\config\serveraccess\servers.xml looks like the following:
      //  <server>
      //    <servertype>NetMeter</servertype>
      //    <servername>DEV-RAC1</servername>
      //    <databasename>sudip</databasename>
      //    <databasedriver>{Oracle in OraHome}</databasedriver>
      //    <databasetype>{Oracle}</databasetype>
      //    <username>sudip</username>
      //    <password encrypted="true">cbb23d8d-8189-4039-a575-a7388c369d992MUVy5QgOBfPqH3W05hg4eDHOXnEykPRgUEscxzI7Pg=</password>
      //  </server>
      #endregion

      Check.Require(serverElement != null, "serverElement cannot be null");

      Check.Require(serverElement.Element("servertype") != null,
                    String.Format("Expected to find <servertype> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("servername") != null,
                    String.Format("Expected to find <servername> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("databasename") != null,
                    String.Format("Expected to find <databasename> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("databasedriver") != null,
                    String.Format("Expected to find <databasedriver> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("databasetype") != null,
                    String.Format("Expected to find <databasetype> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("username") != null,
                    String.Format("Expected to find <username> serverElement in '{0}'", serverElement));
      Check.Require(serverElement.Element("password") != null,
                    String.Format("Expected to find <password> serverElement in '{0}'", serverElement));

      var connectionInfo = new ConnectionInfo();
      connectionInfo.ServerType = serverElement.Element("servertype").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.ServerType),
                    String.Format("The value of <servertype> serverElement cannot be null or empty in '{0}'", serverElement));

      connectionInfo.ServerName = serverElement.Element("servername").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.ServerName),
                    String.Format("The value of <servername> serverElement cannot be null or empty in '{0}'", serverElement));

      connectionInfo.DatabaseName = serverElement.Element("databasename").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.DatabaseName),
                    String.Format("The value of <databasename> serverElement cannot be null or empty in '{0}'", serverElement));

      connectionInfo.DatabaseDriver = serverElement.Element("databasedriver").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.DatabaseDriver),
                    String.Format("The value of <databasedriver> serverElement cannot be null or empty in '{0}'", serverElement));

      connectionInfo.DatabaseType = serverElement.Element("databasetype").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.DatabaseType),
                    String.Format("The value of <databasetype> serverElement cannot be null or empty in '{0}'", serverElement));

      connectionInfo.UserName = serverElement.Element("username").Value;
      Check.Require(!String.IsNullOrEmpty(connectionInfo.UserName),
                    String.Format("The value of <username> serverElement cannot be null or empty in '{0}'", serverElement));


      // Check that the encrypted attribute is set to true
      XAttribute encryptedAttribute = serverElement.Element("password").Attribute("encrypted");
      Check.Require(encryptedAttribute != null, String.Format("encrypted attribute cannot be null in servers.xml"));
      Check.Require(encryptedAttribute.Value == "true", String.Format("encrypted attribute cannot be 'false' in servers.xml"));

      string password = serverElement.Element("password").Value;
      Check.Require(!String.IsNullOrEmpty(password),
                    String.Format("The value of <password> serverElement cannot be null or empty in '{0}'", serverElement));

      if (CryptoManager == null)
      {
        CryptoManager = new CryptoManager();
      }

      connectionInfo.Password = CryptoManager.Decrypt(CryptKeyClass.DatabasePassword, password);

      if (connectionInfo.DatabaseType == "{Oracle}")
      {
        connectionInfo.ConnectionString =
          "Data Source=" + connectionInfo.ServerName + ";" +
          "User Id=" + connectionInfo.UserName + ";" +
          "Password=" + connectionInfo.Password + ";"; // +
          // "Promotable Transaction=local;";

        connectionInfo.NHibernateConfigProperties.Add(driverClassPropertyName, driverClassOraclePropertyValue);
        connectionInfo.NHibernateConfigProperties.Add(dialectPropertyName, dialectOraclePropertyValue);

      }
      else if (connectionInfo.DatabaseType == "{Sql Server}")
      {
        connectionInfo.ConnectionString =
          "Server=" + connectionInfo.ServerName + ";" +
          "initial catalog=" + connectionInfo.DatabaseName + ";" +
          "User Id=" + connectionInfo.UserName + ";" +
          "Password=" + connectionInfo.Password + ";";

        connectionInfo.NHibernateConfigProperties.Add(driverClassPropertyName, driverClassSqlServerPropertyValue);
        connectionInfo.NHibernateConfigProperties.Add(dialectPropertyName, dialectSqlServerPropertyValue);
      }
      else
      {
        throw new DataAccessException
          (String.Format("Cannot recognize database type '{0}' in file severs.xml",
                         connectionInfo.DatabaseType));
               
      }

      connectionInfo.NHibernateConfigProperties.Add(connectionStringPropertyName, connectionInfo.ConnectionString);

      // Create the NHibernate Configuration
      connectionInfo.Configuration = new Configuration();
      connectionInfo.Configuration.Configure(SystemConfig.GetNhibernateConfigFile());
      connectionInfo.Configuration.AddProperties(connectionInfo.NHibernateConfigProperties);

      return connectionInfo;
    }

    public Configuration GetNewConfiguration()
    {
      var configuration = new Configuration();
      configuration.Configure(SystemConfig.GetNhibernateConfigFile());
      configuration.AddProperties(NHibernateConfigProperties);
      return configuration;
    }

    public override string ToString()
    {
      return String.Format
        ("ConnectionInfo: ServerType = '{0}', ServerName = '{1}', DatabaseName = '{2}', DatabaseDriver = '{3}', DatabaseType = '{4}', UserName = '{5}'",
                          ServerType, ServerName, DatabaseName, DatabaseDriver, DatabaseType, UserName);
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as ConnectionInfo;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.ServerType.ToLower() == ServerType.ToLower();
    }

    public override int GetHashCode()
    {
      return ServerType.ToLower().GetHashCode();
    }

    #endregion

    #region Public Properties
    public string ServerType { get; set; }
    public string ServerName { get; set; }
    public string DatabaseName { get; set; }
    public string DatabaseDriver { get; set; }
    public string DatabaseType { get; set; }
    public string UserName { get; set; }
    public string Password { get; set; }
    public string ConnectionString { get; set; }
    public bool IsOracle
    {
      get
      {
        return DatabaseType == "{Oracle}";
      }
    }

    public Configuration Configuration { get; set; }
    #endregion

    #region Private Properties
    internal Dictionary<string, string> NHibernateConfigProperties { get; set; }
    internal static CryptoManager CryptoManager { get; set; }
    #endregion

    #region Data
    private static readonly string driverClassPropertyName = "connection.driver_class";
    private static readonly string connectionStringPropertyName = "connection.connection_string";
    private static readonly string dialectPropertyName = "dialect";

    // OracleDataClientDriver is Oracle's client driver
    private static readonly string driverClassOraclePropertyValue = "NHibernate.Driver.OracleDataClientDriver";
    // OracleClientDriver is MS oracle client driver
    // private static readonly string driverClassOraclePropertyValue = "NHibernate.Driver.OracleClientDriver";

    private static readonly string driverClassSqlServerPropertyValue = "NHibernate.Driver.SqlClientDriver";

    private static readonly string dialectOraclePropertyValue = "NHibernate.Dialect.Oracle10gDialect";
    private static readonly string dialectSqlServerPropertyValue = "NHibernate.Dialect.MsSql2008Dialect";

    #endregion
  }
}
