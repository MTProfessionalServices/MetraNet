using System;
using System.Net;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class SocketClientSettings
  /// </summary>
  internal class SocketClientSettings
  {
    // total number of client connections that will be generated
    // by this test program.
    private readonly Int32 totalNumberOfClientConnectionsToRun;

    // tells us how many objects to put in pool for connect operations
    private readonly Int32 maxSimultaneousConnectOps;

    // tells us maximum number of open sockets
    private readonly Int32 maxSimultaneousConnections;

    // number of SAEA objects to put in the pool. This just allows us to
    // specify some excess objects above the value of maxSimultaneousConnections,
    // if we wish.
    private readonly Int32 numberOfSocketAsyncEventArgsForRecSend;

    // buffer size to use for each socket receive operation
    private readonly Int32 bufferSize;

    // See comments in buffer manager.
    private readonly Int32 opsToPreAllocate;

    private readonly IPEndPoint serverEndPoint;

    /// <summary>
    /// Initializes a new instance of the <see cref="SocketClientSettings" /> class.
    /// </summary>
    /// <param name="theServerEndPoint">The server end point.</param>
    /// <param name="totalNumberOfClientConnectionsToRun">The total number of client connections to run.</param>
    /// <param name="maxSimultaneousConnectOps">The max simultaneous connect ops.</param>
    /// <param name="maxConnections">The max connections.</param>
    /// <param name="bufferSize">Size of the buffer.</param>
    /// <param name="opsToPreAlloc">The ops to pre allocate.</param>
    public SocketClientSettings(IPEndPoint theServerEndPoint, Int32 totalNumberOfClientConnectionsToRun,
                                Int32 maxSimultaneousConnectOps, Int32 maxConnections,
                                Int32 bufferSize, Int32 opsToPreAlloc)
    {
      this.totalNumberOfClientConnectionsToRun = totalNumberOfClientConnectionsToRun;
      this.maxSimultaneousConnectOps = maxSimultaneousConnectOps;
      this.maxSimultaneousConnections = maxConnections;
      this.numberOfSocketAsyncEventArgsForRecSend = maxConnections + 1;
      this.bufferSize = bufferSize;
      this.opsToPreAllocate = opsToPreAlloc;
      this.serverEndPoint = theServerEndPoint;

      // Read from queue
      //this.numberOfMessagesPerConnection = numberOfMessages;
    }

    public Int32 ConnectionsToRun
    {
      get { return this.totalNumberOfClientConnectionsToRun; }
    }

    public Int32 MaxConnectOps
    {
      get { return this.maxSimultaneousConnectOps; }
    }

    public Int32 MaxConnections
    {
      get { return this.maxSimultaneousConnections; }
    }

    public Int32 NumberOfSocketAsyncEventArgsForRecSend
    {
      get { return this.numberOfSocketAsyncEventArgsForRecSend; }
    }

    public Int32 BufferSize
    {
      get { return this.bufferSize; }
    }

    public Int32 OpsToPreAllocate
    {
      get { return this.opsToPreAllocate; }
    }

    public IPEndPoint ServerEndPoint
    {
      get { return this.serverEndPoint; }
    }
  }
}