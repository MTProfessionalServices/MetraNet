using System;
using System.IO;
using System.Net;

using MetraTech;
using MetraTech.Interop.RCD;
using MetraTech.Tax.Framework;
using MetraTech.Xml;


namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// 
  /// </summary>
  /// <remarks></remarks>
  public class VertexQConfiguration
  {
    private static readonly Logger m_Logger = new Logger("[TaxManager.VertexQConfiguration]");

    // General Vertex config file. 
    private readonly string m_ConfigFile = "";
    public int m_MaxNumOfSimultaneousClientConnections { get; set; }

    public int m_MaxSimultaneousConnectOps { get; set; }

    // Max Client sockets that needs to be opened.
    // This should be less than or equal to the number
    // of MaxSimultaneousConnections at the server
    public int m_NumClientSockets { get; set; }

    /// <summary>
    /// Gets or sets the m_ server address.
    /// </summary>
    /// <value>The m_ server address.</value>
    /// <remarks></remarks>
    public string m_ServerAddress { get; set; }

    /// <summary>
    /// Gets or sets the m_ port.
    /// </summary>
    /// <value>The m_ port.</value>
    /// <remarks></remarks>
    public int m_Port { get; set; }

    public int m_BufferSize { get; set; }


    /// <summary>
    /// Initializes a new instance of the <see cref="VertexQConfiguration"/> class.
    /// </summary>
    /// <remarks></remarks>
    public VertexQConfiguration()
    {
      try
      {
        IMTRcd rcd = new MTRcd();
        m_ConfigFile = Path.Combine(rcd.ExtensionDir, @"VertexQ\config\VertexQClientConfig.xml"); // RMP\Extensions\VertexQ\config\VertexQConfig.xml

        if (!File.Exists(m_ConfigFile))
        {
          string err = System.Reflection.MethodBase.GetCurrentMethod().Name +
              ": config file " + m_ConfigFile + " does not exist";
          m_Logger.LogError(err);
          throw new TaxException(err);
        }

        MTXmlDocument configDoc = new MTXmlDocument();
        configDoc.Load(m_ConfigFile);

        try
        {
          m_NumClientSockets = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/NumClientSockets");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve NumClientSockets from {1}, using 10, {2}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, e.Message);
          m_NumClientSockets = 10;
        }

        try
        {
          m_ServerAddress = configDoc.GetNodeValueAsString("/xmlconfig/VertexQ/ServerAddress");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve server address from {1}, using '{2}', {3}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, "127.0.0.1", e.Message);
          m_ServerAddress = Dns.GetHostName();
        }

        try
        {
          m_Port = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/ListeningPort");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve listening port from {1}, using '{2}', {3}",
              System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, "4444", e.Message);
          m_Port = 4444;
        }

        try
        {
          m_BufferSize = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/BufferSize");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve buffer size from {1}, using '{2}', {3}",
              System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, "25000", e.Message);
          m_BufferSize = 25000;
        }

        try
        {
          m_MaxNumOfSimultaneousClientConnections = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/MaxNumberOfSimultaneousClientConnections");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve MaxNumberOfSimultaneousClientConnections from {1}, using 10, {2}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, e.Message);
          m_MaxNumOfSimultaneousClientConnections = 10;
        }

        try
        {
          m_MaxSimultaneousConnectOps = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/MaxSimultaneousConnectOps");
        }
        catch (Exception e)
        {
          m_Logger.LogError("{0}: failed to retrieve MaxSimultaneousConnectOps from {1}, using 10, {2}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name, m_ConfigFile, e.Message);
          m_MaxSimultaneousConnectOps = 10;
        }

      }
      catch (Exception ex)
      {
        m_Logger.LogException(@"Please check your Taxmanager\Vendor\VertexQ configuration file", ex);
        throw ex;
      }
    }
  }
}
