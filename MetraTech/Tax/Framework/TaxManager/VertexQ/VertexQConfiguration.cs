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
    private static readonly Logger Logger = new Logger("[TaxManager.VertexQConfiguration]");

    /// <summary>
    /// Gets or sets the server address.
    /// </summary>
    /// <value>The server address.</value>
    /// <remarks></remarks>
    public string ServerAddress { get; set; }

    /// <summary>
    /// Gets or sets the port.
    /// </summary>
    /// <value>The port.</value>
    /// <remarks></remarks>
    public int Port { get; set; }

    /// <summary>
    /// Get or set Buffer Size
    /// </summary>
    public int BufferSize { get; set; }

    /// <summary>
    /// Initializes a new instance of the <see cref="VertexQConfiguration"/> class.
    /// </summary>
    /// <remarks></remarks>
    public VertexQConfiguration()
    {
      try
      {
        IMTRcd rcd = new MTRcd();
        var configFile = Path.Combine(rcd.ExtensionDir, @"VertexQ\config\VertexQClientConfig.xml"); // RMP\Extensions\VertexQ\config\VertexQConfig.xml

        if (!File.Exists(configFile))
        {
          var err = System.Reflection.MethodBase.GetCurrentMethod().Name +
              ": config file " + configFile + " does not exist";
          Logger.LogError(err);
          throw new TaxException(err);
        }

        var configDoc = new MTXmlDocument();
        configDoc.Load(configFile);

        try
        {
          ServerAddress = configDoc.GetNodeValueAsString("/xmlconfig/VertexQ/ServerAddress");
        }
        catch (Exception e)
        {
          Logger.LogError("{0}: failed to retrieve server address from {1}, using '{2}', {3}",
                            System.Reflection.MethodBase.GetCurrentMethod().Name, configFile, "127.0.0.1", e.Message);
          ServerAddress = Dns.GetHostName();
        }

        try
        {
          Port = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/ListeningPort");
        }
        catch (Exception e)
        {
          Logger.LogError("{0}: failed to retrieve listening port from {1}, using '{2}', {3}",
              System.Reflection.MethodBase.GetCurrentMethod().Name, configFile, "4444", e.Message);
          Port = 4444;
        }

        try
        {
          BufferSize = configDoc.GetNodeValueAsInt("/xmlconfig/VertexQ/BufferSize");
        }
        catch (Exception e)
        {
          Logger.LogError("{0}: failed to retrieve buffer size from {1}, using '{2}', {3}",
              System.Reflection.MethodBase.GetCurrentMethod().Name, configFile, "25000", e.Message);
          BufferSize = 25000;
        }
      }
      catch (Exception exc)
      {
        Logger.LogException(@"Please check your Taxmanager\Vendor\VertexQ configuration file", exc);
        throw;
      }
    }
  }
}
