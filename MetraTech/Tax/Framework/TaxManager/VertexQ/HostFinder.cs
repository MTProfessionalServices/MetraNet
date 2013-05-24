using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;

using MetraTech;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class HostFinder. Utility class to resolve host name.
  /// </summary>
  internal class HostFinder
  {
    internal string host;
    internal Int32 portOnHost;
    internal string portString;
    private Logger _logger = new Logger("[TaxManager.VertexQ.HostFinder]");

    /// <summary>
    /// Gets the valid host.
    /// </summary>
    /// <param name="theHost">The host.</param>
    /// <param name="thePortOnHost">The port on host.</param>
    /// <returns>IPEndPoint.</returns>
    public IPEndPoint GetValidHost(string theHost, Int32 thePortOnHost)
    {
      IPEndPoint hostEndPoint = null;

      this.host = theHost;
      this.portOnHost = thePortOnHost;
      this.portString = this.portOnHost.ToString(CultureInfo.InvariantCulture);

      IPAddress serverIPAddress;
      if (!IPAddress.TryParse(theHost, out serverIPAddress))
      {
        // Entered host name as server address 
        hostEndPoint = GetServerEndpointUsingMachineName(host, portOnHost);
      }
      else
      {
        // Entered server address was IP
        hostEndPoint = GetServerEndpointUsingIpAddress(host, portOnHost);
      }

      if (hostEndPoint != null)
      {
        TestConnection(hostEndPoint);
      }
      return hostEndPoint;
    }

    /// <summary>
    /// Tests the connection.
    /// </summary>
    /// <param name="theHostEndPoint">The host end point.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    public bool TestConnection(IPEndPoint theHostEndPoint)
    {
      bool connectedSuccessfully = false;
      IPEndPoint hostEndPoint = theHostEndPoint;
      Console.WriteLine("Testing connection to server.");

      Socket socket = new Socket(hostEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

      try
      {
        _logger.LogInfo("Connecting to {0} at port {1}.....", hostEndPoint.Address, hostEndPoint.Port);
        socket.Connect(hostEndPoint);
        connectedSuccessfully = true;
        _logger.LogInfo("Test connection to host is okay.");

        try
        {
          socket.Disconnect(false);
        }
        catch (SocketException ex)
        {
          _logger.LogError("Connected. But disconnect failed after test connection.");
          _logger.LogException(ex.Message, ex);
        }
      }
      catch (SocketException ex)
      {
        connectedSuccessfully = false;
        
        _logger.LogException(ex.Message, ex);
        _logger.LogInfo("Cannot connect to " + IPAddress.Parse(((IPEndPoint)hostEndPoint).Address.ToString()) + ": " +
                          ((IPEndPoint)hostEndPoint).Port.ToString(CultureInfo.InvariantCulture));
        _logger.LogInfo("Make sure that the host Endpoint is correct, and the server app is started.");
        _logger.LogInfo("And your firewalls on both client and server will need to allow the connection.");
        _logger.LogInfo("Restart the application, please.");
      }
      return connectedSuccessfully;
    }

    /// <summary>
    /// Gets the name of the server endpoint using machine.
    /// </summary>
    /// <param name="server">The server.</param>
    /// <param name="portOnServer">The port on server.</param>
    /// <returns>IPEndPoint.</returns>
    public IPEndPoint GetServerEndpointUsingMachineName(string server, Int32 portOnServer)
    {
      IPEndPoint serverEndPoint = null;

      try
      {
        IPHostEntry theIpHostEntry = Dns.GetHostEntry(server);
        // Address of the host.
        IPAddress[] serverAddressList = theIpHostEntry.AddressList;

        bool gotIpv4Address = false;

        Int32 count = -1;
        for (int i = 0; i < serverAddressList.Length; i++)
        {
          count++;
          AddressFamily addressFamily = serverAddressList[i].AddressFamily;
          if (addressFamily == AddressFamily.InterNetwork)
          {
            gotIpv4Address = true;
            i = serverAddressList.Length;
          }
        }

        if (gotIpv4Address == false)
        {
          _logger.LogInfo("Could not resolve name to IPv4 address. Need IP address. Failure!");
        }
        else
        {
          _logger.LogInfo("Server name resolved to IPv4 address.");
          // Instantiates the endpoint.
          serverEndPoint = new IPEndPoint(serverAddressList[count], portOnServer);
        }
      }
      catch (Exception ex)
      {
        _logger.LogException(ex.Message, ex);
        _logger.LogInfo("Could not resolve server address.");
        _logger.LogInfo("host = " + server);
      }

      return serverEndPoint;
    }

    /// <summary>
    /// Gets the server endpoint using ip address.
    /// </summary>
    /// <param name="server">The server.</param>
    /// <param name="portOnServer">The port on server.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    public IPEndPoint GetServerEndpointUsingIpAddress(string server, Int32 portOnServer)
    {
      IPEndPoint serverEndPoint = null;

      try
      {
        IPAddress theIpAddress = IPAddress.Parse(server);
        // Instantiates the Endpoint.
        serverEndPoint = new IPEndPoint(theIpAddress, portOnServer);
      }
      catch (ArgumentNullException e)
      {
        _logger.LogInfo("ArgumentNullException caught!!!");
        _logger.LogInfo("Source : " + e.Source);
        _logger.LogInfo("Message : " + e.Message);
        _logger.LogException(e.Message, e);
      }
      catch (FormatException e)
      {
        _logger.LogInfo("FormatException caught!!!");
        _logger.LogInfo("Source : " + e.Source);
        _logger.LogInfo("Message : " + e.Message);
        _logger.LogException(e.Message, e);
      }
      catch (Exception e)
      {
        _logger.LogInfo("Exception caught!!!");
        _logger.LogInfo("Source : " + e.Source);
        _logger.LogInfo("Message : " + e.Message);
        _logger.LogException(e.Message, e);
      }
      return serverEndPoint;
    }
  }
}

