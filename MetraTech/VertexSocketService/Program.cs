using System;
using System.Globalization;
using System.Net;
using System.Text;
using System.Configuration;
using MetraTech;


namespace VertexSocketService
{
  /// <summary>
  /// 
  /// </summary>
  class Program
  {
    /// <summary>
    /// 
    /// </summary>
    private static readonly AppSettingsReader appSettingsReader = new AppSettingsReader();

    /// <summary>
    /// 
    /// </summary>
    private static readonly Logger _logger = new Logger("[VertexSocketService]");

    // This variable determines the number of 
    // SocketAsyncEventArg objects put in the pool of objects for receive/send.
    public static Int32 maxNumberOfConnections;

    /// <summary>
    /// Port to listen at.
    /// </summary>
    public static Int32 port;

    /// <summary>
    /// Size of buffer to use to read messages.
    /// </summary>
    public static Int32 bufferSize;

    // This is the maximum number of asynchronous accept operations that can be 
    // posted simultaneously. This determines the size of the pool of 
    // SocketAsyncEventArgs objects that do accept operations. 
    public static Int32 maxSimultaneousAcceptOps;

    // The size of the queue of incoming connections for the listen socket.
    public static Int32 backlog;

    public const Int32 opsToPreAlloc = 2;    // 1 for receive, 1 for send

    // Allows excess SocketAsyncEventArgs objects in pool.
    public const Int32 excessSocketAsyncEventArgsObjectsInPool = 1;

    public static Int64 mainSessionId = 1000000000;

    // To keep a record of maximum number of simultaneous connections
    // that occur while the server is running. It will not be higher than the value that you set
    // for maxNumberOfConnections.
    public static Int32 maxSimultaneousClientsThatWereConnected = 0;

    // These strings are just for console interaction.
    public const string checkString = "C";
    public const string closeString = "Z";

    static void Main(String[] args)
    {
      ReadAndLoadAllValuesFromConfig();

      try
      {
        // Get endpoint for the listener.                
        IPEndPoint localEndPoint = new IPEndPoint(IPAddress.Any, port);

        WriteInfoToConsole(localEndPoint);

        // This object holds a lot of settings that we pass from Main method
        // to the SocketListener. 
        SocketListenerSettings theSocketListenerSettings = new SocketListenerSettings
            (maxNumberOfConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps, bufferSize,
             opsToPreAlloc, localEndPoint);

        SocketListener socketListener = new SocketListener(theSocketListenerSettings);

        BuildStringsForServerConsole();
        ManageClosing(socketListener);
      }
      catch (Exception ex)
      {
        Console.WriteLine("Error: " + ex.Message);
        Console.WriteLine(ex.StackTrace);
        Console.WriteLine(ex.TargetSite);
        if (null != ex.InnerException)
          Console.WriteLine(ex.InnerException.Message);
        Console.Read();

        _logger.LogException("Caught exception in the VertexSocketServer", ex);
      }
      finally
      {
        //TODO : cleanup ???
      }
    }

    /// <summary>
    /// Reads the and load all values from config.
    /// </summary>
    /// <remarks></remarks>
    private static void ReadAndLoadAllValuesFromConfig()
    {
      string totalNumberOfConnections = appSettingsReader.GetValue("MaxNumOfConnections", typeof(string)).ToString();
      if (!Int32.TryParse(totalNumberOfConnections, out maxNumberOfConnections))
      {
        _logger.LogInfo("Invalid value for MaxNumberOfConnections specified. Value of {0} is not valid. Using default value of 100",
                        totalNumberOfConnections);
        maxNumberOfConnections = 100;
      }

      string maxNumberOfAcceptOps = appSettingsReader.GetValue("MaxAcceptOps", typeof(string)).ToString();
      if (!Int32.TryParse(totalNumberOfConnections, out maxSimultaneousAcceptOps))
      {
        _logger.LogInfo("Invalid MaxAcceptOps value specified. {0} is not valid. Using default value of 10",
                       maxNumberOfAcceptOps);
        maxSimultaneousAcceptOps = 10;
      }

      string configPortValue = appSettingsReader.GetValue("Port", typeof(string)).ToString();
      if (!Int32.TryParse(configPortValue, out port))
      {
        _logger.LogInfo("Invalid Port specified. Port Number  {0} is not valid. Using default value of 4444.",
                        configPortValue);
        port = 4444;
      }

      string socketBacklogValue = appSettingsReader.GetValue("Backlog", typeof(string)).ToString();
      if (!Int32.TryParse(socketBacklogValue, out backlog))
      {
        _logger.LogInfo("Invalid backlog value specified. Backlog {0} is not valid. Using default value of 100.",
                        configPortValue);
        port = 100;
      }
      
      string serverBufferSize = appSettingsReader.GetValue("BufferSize", typeof(string)).ToString();
      if (!Int32.TryParse(serverBufferSize, out bufferSize))
      {
        _logger.LogInfo("Invalid Buffer Size specified. Buffer Size {0} is not valid. Using default value of 25000.",
                        serverBufferSize);
        bufferSize = 25000;
      }
    }
    
    /// <summary>
    /// Builds the strings for server console.
    /// </summary>
    /// <remarks></remarks>
    static void BuildStringsForServerConsole()
    {
      StringBuilder sb = new StringBuilder();
     
      sb.Append("\r\n");
      sb.Append("\r\n");
      sb.Append("To take any of the following actions type the \r\ncorresponding letter below and press Enter.\r\n");
      sb.Append(closeString);
      sb.Append(")  to close the program\r\n");
      sb.Append(checkString);
      sb.Append(")  to check current status\r\n");
      Console.WriteLine(sb.ToString());
      sb.Length = 0;
    }
    
    /// <summary>
    /// Writes the info to console.
    /// </summary>
    /// <param name="localEndPoint">The local end point.</param>
    /// <remarks></remarks>
    public static void WriteInfoToConsole(IPEndPoint localEndPoint)
    {
      Console.WriteLine("The following options can be changed for the server.");
      Console.WriteLine("server buffer size = " + bufferSize);
      Console.WriteLine("max connections = " + maxNumberOfConnections);
      Console.WriteLine("backlog variable value = " + backlog);
      Console.WriteLine();

      Console.WriteLine();
      Console.WriteLine("local endpoint = " + IPAddress.Parse(((IPEndPoint)localEndPoint).Address.ToString()) + ": " +
                        ((IPEndPoint)localEndPoint).Port.ToString(CultureInfo.InvariantCulture));
      Console.WriteLine("server machine name = " + Environment.MachineName);
      Console.WriteLine();
    }
    
    /// <summary>
    /// Manages the closing.
    /// </summary>
    /// <param name="socketListener">The socket listener.</param>
    /// <remarks></remarks>
    static void ManageClosing(SocketListener socketListener)
    {
      string stringToCompare = "";
      string theEntry = "";
      
      while (stringToCompare != closeString)
      {
        var readLine = Console.ReadLine();
        if (readLine != null) theEntry = readLine.ToUpper();

        switch (theEntry)
        {
          case checkString:
            Console.WriteLine("Number of current accepted connections = " + socketListener._numberOfAcceptedSockets);
            break;

          case closeString:
            stringToCompare = closeString;
            break;

          default:
            Console.WriteLine("Unrecognized entry");
            break;
        }
      }
      // TODO : Add method for stats
    }
  }
}
