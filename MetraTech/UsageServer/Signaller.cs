namespace MetraTech.UsageServer
{
  using System;
  using System.Net;
  using System.Net.Sockets;
  using System.Text;
  using System.Threading;

  using MetraTech.Xml;

  /// <summary> 
  /// This singleton class provides ability to send or receive messages 
  /// between processes on the same server or different servers.  Multicasting
  /// is the underlying communication mechanism.  A process can send a messages
  /// and all other processes that are listening  (waiting to receive) messages.
  /// A process may use this class to send or to receive but not both -- in other
  /// words, the process may send multicast messages or may receive multicast messages,
  /// but not both.
  /// 
  /// An example use: the user through a user interface screen 
  /// indicates that an adapter should be run.  The Billing
  /// Service is then signaled to check for adapters to run (rather than waiting a maximum
  /// of 15 minutes).  The signal is sent to all Billing Services, even if the service is
  /// running on a different server than the sender.
  /// </summary>

  public sealed class Signaller
  {
    /// <summary>
    /// Types of messages that can be sent and received.
    /// </summary>
    public enum SignallerMessage
    {
      Unknown,
      ProcessRecurringEvents,
      ConfigChanged,
      KillRecurringEvent
    }


    /// <summary>
    /// Get the singlton instance.
    /// </summary>
    /// <returns></returns>
    public static Signaller GetInstance
    {
      get 
      {
         if (m_instance == null) 
         {
            lock (m_syncRoot) 
            {
              if (m_instance == null) 
                  m_instance = new Signaller();
            }
         }

         return m_instance;
      }
    }

    /// <summary>
    /// Send the given message.  This method can throw an exception so
    /// use a try around the call.  The exception will have already been
    /// logged, so no need to log the message.
    /// </summary>
    /// <param name="message">Message to send.</param>
    public void Send(SignallerMessage message)
    {
      if (!m_isInitializedForSending)
      {
        InitializeForSending();
      }

      // Check to make sure initialization succeeded
      if (!m_isInitializedForSending)
      {
        m_logger.LogError("Cannot send the billing server message since failed to initialize for sending.");
        return;
      }

      string sendMsg = "" + message;

      SendString(sendMsg);

      // Take down socket.
      m_socket.Close();
      m_isInitializedForSending = false;
      m_logger.LogDebug("Closing USM multicast socket.");
    }

    /// <summary>
    /// Block until a message is received.
    /// </summary>
    /// <returns></returns>
    public SignallerMessage Receive()
    {
      SignallerMessage result = SignallerMessage.Unknown;

      if (!m_isIntializedForReceiving)
      {
        InitializeForReceiving();
      }

      // Check to make sure initialization succeeded
      if (!m_isIntializedForReceiving)
      {
        m_logger.LogError("Cannot receive billing server message since failed to initialize for receiving.");
        return result;
      }

      m_logger.LogDebug("Waiting for a multicast message to be received from address: " +
                       m_multicastAddress);

      byte[] b = new byte[1024];
      string got;

      try
      {
        m_socket.Receive(b);
        got = System.Text.Encoding.ASCII.GetString(b, 0, b.Length);
      }
      catch (Exception e)
      {
        m_logger.LogError("An error occurred attempting to receive a multicast message. Error: " +
                          e.Message);
        Thread.Sleep(60000);
        return result;
      }

      got = got.Trim();
      m_logger.LogInfo("Received billing server message: " + got+ " from multicast address: " + m_multicastAddress);

      if (got.StartsWith("" + SignallerMessage.ConfigChanged)) 
      { 
        result = SignallerMessage.ConfigChanged; 
      }
      else if (got.StartsWith("" + SignallerMessage.KillRecurringEvent)) 
      { 
        result = SignallerMessage.KillRecurringEvent; 
      }
      else if (got.StartsWith("" + SignallerMessage.ProcessRecurringEvents))
      {
        result = SignallerMessage.ProcessRecurringEvents;
      }
      else
      {
        m_logger.LogError("Received an unrecognized billing server message: " + got);
        result = SignallerMessage.Unknown;
      }

      return result;
    }

    /// <summary>
    /// Private constructor.
    /// </summary>
    private Signaller() 
    {
      LoadConfiguration();
    }

    /// <summary>
    /// Private descructor
    /// </summary>
    ~Signaller()
    {
      if (m_isIntializedForReceiving || m_isInitializedForSending)
      {
        m_socket.Close();
      }
    }

    /// <summary>
    /// Initialize form sending messages.
    /// </summary>
    private void InitializeForSending()
    {
      // Check if we've already initialized.
      if (m_isInitializedForSending)
      {
        return;
      }

      // Check if we've initialized for receiving.
      // If so, we aren't allowed to send.
      if (m_isIntializedForReceiving)
      {
        m_logger.LogError("This executable has already been set up for receiving " +
                          "multicast message, so it cannot be used for sending.");
        return;
      }

      string methodBeingAttempted = "";

      try
      {
        // Create a UDP socket.
        methodBeingAttempted = "new Socket";
        m_socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

        // Allow the same socket address be reused on the system.
        // On the same system one program can have the socket open for sending, another for rcv'ing.
        m_socket.SetSocketOption(SocketOptionLevel.Socket,
                          SocketOptionName.ReuseAddress, true);

        // Create an IP endpoint for the incoming data and bind that to the socket.
        m_ipEndPoint = new IPEndPoint(IPAddress.Any, m_multicastPort);
        m_socket.Bind(m_ipEndPoint);
        IPAddress ip = IPAddress.Parse(m_multicastAddress);

        // Join the multicast once we have joined it.
        methodBeingAttempted = "SetSocketOption/AddMembership";
        m_socket.SetSocketOption(SocketOptionLevel.IP,
                                 SocketOptionName.AddMembership,
                                 new MulticastOption(ip));


        // Set the time to live for the socket - this is very important in defining scope for the multicast data. 
        // Setting a value of 1 will mean the multicast data will not leave the local network, 
        // setting it to anything above this will allow the multicast data to pass through several routers, 
        // with each router decrementing the TTL by 1. Getting the TTL value right is important for bandwidth considerations.
        methodBeingAttempted = "SetSocketOption/TTL";
        m_socket.SetSocketOption(SocketOptionLevel.IP,
                                 SocketOptionName.MulticastTimeToLive,
                                 m_multicastTimeToLive);

        // Create an endpoint that allows us to send multicast data.
        methodBeingAttempted = "new IPEndPoint";
        IPEndPoint ipep = new IPEndPoint(ip, m_multicastPort);

        // Connect to the socket.  We are now a member of the multicast
        // and can send.
        methodBeingAttempted = "Connect";
        m_socket.Connect(ipep);

        m_logger.LogDebug("Opened USM multicast socket for sending.");
      }
      catch (Exception e)
      {
        m_logger.LogError("An error occurred attempting to initialize the sending of multicast billing server messages." +
                          " Method: " + methodBeingAttempted +
                          " Error: " + e.Message +
                          " Stack: " + e.StackTrace);
        m_logger.LogError("Multicast parameters: address(" + m_multicastAddress +
                          ") port(" + m_multicastPort + ") TTL(" + m_multicastTimeToLive + ")");
        return;
      }

      m_isInitializedForSending = true;
    }


    /// <summary>
    /// Notifies the remote BillingServers that 
    /// there are potential recurring events to process
    /// by broadcasting a message
    /// </summary>
    private void SendString(string message)
    {
      if (!m_isInitializedForSending)
      {
        m_logger.LogError("Cannot send billing server message since failed to initialize for sending.");
        return;
      }

      m_logger.LogInfo("Sent billing servers event " + message + 
                       "over multicast address  " + m_multicastAddress);

      byte[] sendBytes = Encoding.ASCII.GetBytes(message);

      try
      {
        m_socket.Send(sendBytes, sendBytes.Length, SocketFlags.None);
      }
      catch (Exception e)
      {
        m_logger.LogError("An error occurred attempting to send a multicast message. Error: " +
                          e.Message);
        throw e;
      }
    }

    /// <summary>
    /// Initialize for receiving multicast messages.
    /// </summary>
    private void InitializeForReceiving()
    {
      // Check if we've already initialized.
      if (m_isIntializedForReceiving)
      {
        return;
      }

      // Check if we've initialized for receiving.
      // If so, we aren't allowed to send.
      if (m_isInitializedForSending)
      {
        m_logger.LogError("This executable has already been set up for receiving " +
                          "multicast message, so it cannot be used for sending.");
        return;
      }

      try
      {
        m_socket = new Socket(AddressFamily.InterNetwork, SocketType.Dgram, ProtocolType.Udp);

        // Allow the same socket address be reused on the system.
        // On the same system one program can have the socket open for sending, another for rcv'ing.
        m_socket.SetSocketOption(SocketOptionLevel.Socket,
                          SocketOptionName.ReuseAddress, true);

        // Create an IP endpoint for the incoming data and bind that to the socket.
        m_ipEndPoint = new IPEndPoint(IPAddress.Any, m_multicastPort);
        m_socket.Bind(m_ipEndPoint);

        IPAddress ip = IPAddress.Parse(m_multicastAddress);

        m_socket.SetSocketOption(SocketOptionLevel.IP,
                          SocketOptionName.AddMembership,
                          new MulticastOption(ip, IPAddress.Any));

	

        m_logger.LogDebug("Opened USM multicast socket for receiving.");
      }
      catch (Exception e)
      {
        m_logger.LogError("An error occurred attempting to initialize the sending of multicast billing server messages. " +
                          "Error: " + e.Message);
        return;
      }

      m_isIntializedForReceiving = true;
    }

    /// <summary>
    /// Load configuration information into private variables.
    /// </summary>
    private void LoadConfiguration()
    {
      ConfigCrossServer config = ConfigCrossServerManager.GetConfig();

      m_multicastAddress = config.multicastAddress;
      m_multicastPort = config.multicastPort;
      m_multicastTimeToLive = config.multicastTimeToLive;
      m_logger.LogDebug("Billing server multicast configuration value: " +
                        "Multicast address: " + m_multicastAddress + " port: " + m_multicastPort + " ttl: " + m_multicastTimeToLive);
    }


    /// <summary>
    /// Multicast address.  Multicast IP addresses are within the Class D range of 224.0.0.0-239.255.255.255
    /// </summary>
    private string m_multicastAddress;
    const   string DEFAULT_MULTICAST_ADDRESS = "224.5.6.7";

    /// <summary>
    /// Port for communication.
    /// </summary>
    private int m_multicastPort;
    const   int DEFAULT_MULTICAST_PORT = 4567;

    /// <summary>
    /// TimeToLive (TTL) controls the live time of the datagram to avoid it being looped forever due to routing errors. 
    /// Routers decrement the TTL of every datagram as it traverses from one network to another and when its value 
    /// reaches 0 the packet is dropped.  The TTL in IPv4 multicasting has also the meaning of "threshold".  
    /// Routers have a TTL threshold assigned to each of its interfaces, and only datagrams with a TTL greater than 
    /// the interface's threshold are forwarded. Note that when a datagram traverses a router with a certain threshold 
    /// assigned, the datagram's TTL is not decremented by the value of the threshold. Only a comparison is made. 
    /// (As before, the TTL is decremented by 1 each time a datagram passes across a router).
    /// </summary>
    private int m_multicastTimeToLive;
    const   int DEFAULT_MULTICAST_TTL = 2;

    /// <summary>
    /// Hold singlton instance.
    /// </summary>
    private static volatile Signaller m_instance;

    /// <summary>
    /// Used for locking in singleton.
    /// </summary>
    private static object m_syncRoot = new Object();

    /// <summary>
    /// Have we initialized the instance for receiving?
    /// </summary>
    private bool m_isInitializedForSending = false;

    /// <summary>
    /// Have we initialized the instance for sending?
    /// </summary>
    private bool m_isIntializedForReceiving = false;

    /// <summary>
    /// Socket used for communication.
    /// </summary>
    Socket m_socket;

    /// <summary>
    /// Endpoint for multicast communication.
    /// </summary>
    IPEndPoint m_ipEndPoint;

    /// <summary>
    /// Used for logging.
    /// </summary>
    Logger m_logger = new Logger("[UsageServer]");
  }
}
