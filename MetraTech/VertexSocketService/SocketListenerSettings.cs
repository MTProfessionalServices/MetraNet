using System;
using System.Globalization;
using System.Net;

namespace VertexSocketService
{
  /// <summary>
  /// Socket Listener settings
  /// </summary>
  /// <remarks></remarks>
  class SocketListenerSettings
  {
    // The maximum number of connections the sample is designed to handle simultaneously 
    private readonly Int32 _maxConnections;

    // This variable allows us to create some SocketAsyncEventArgs objects for the pool
    private readonly Int32 _numberOfSocketAsyncEventArgsForRecSend;

    // Max # of pending connections the listener can hold in queue
    private readonly Int32 _backlog;

    // Tells us how many objects to put in pool for accept operations
    private readonly Int32 _maxSimultaneousAcceptOps;

    // Buffer size to use for each socket receive operation
    private readonly Int32 _receiveBufferSize;

    // Receive and Send 
    private readonly Int32 _opsToPreAllocate;

    // Endpoint for the listener.
    private readonly IPEndPoint _localEndPoint;

    /// <summary>
    /// Initializes a new instance of the <see cref="SocketListenerSettings"/> class.
    /// </summary>
    /// <param name="maxConnections">The max connections.</param>
    /// <param name="excessSocketAsyncEventArgsObjectsInPool">The excess socket async event args objects in pool.</param>
    /// <param name="backlog">The backlog.</param>
    /// <param name="maxSimultaneousAcceptOps">The max simultaneous accept ops.</param>
    /// <param name="receiveBufferSize">Size of the receive buffer.</param>
    /// <param name="opsToPreAlloc">The ops to pre alloc.</param>
    /// <param name="theLocalEndPoint">The local end point.</param>
    /// <remarks></remarks>
    public SocketListenerSettings(Int32 maxConnections, Int32 excessSocketAsyncEventArgsObjectsInPool, Int32 backlog,
      Int32 maxSimultaneousAcceptOps, Int32 receiveBufferSize, Int32 opsToPreAlloc, IPEndPoint localEndPoint)
    {
      ValidateInput(maxConnections, excessSocketAsyncEventArgsObjectsInPool, backlog, maxSimultaneousAcceptOps,
                    receiveBufferSize,
                    opsToPreAlloc, localEndPoint);

      this._maxConnections = maxConnections;
      this._numberOfSocketAsyncEventArgsForRecSend = maxConnections + excessSocketAsyncEventArgsObjectsInPool;
      this._backlog = backlog;
      this._maxSimultaneousAcceptOps = maxSimultaneousAcceptOps;
      this._receiveBufferSize = receiveBufferSize;
      this._opsToPreAllocate = opsToPreAlloc;
      this._localEndPoint = localEndPoint;
    }

    /// <summary>
    /// Validates the input.
    /// </summary>
    /// <param name="maxConnections">The max connections.</param>
    /// <param name="excessSocketAsyncEventArgsObjectsInPool">The excess socket async event args objects in pool.</param>
    /// <param name="backlog">The backlog.</param>
    /// <param name="maxSimultaneousAcceptOps">The max simultaneous accept ops.</param>
    /// <param name="receiveBufferSize">Size of the receive buffer.</param>
    /// <param name="opsToPreAlloc">The ops to pre alloc.</param>
    /// <param name="localEndPoint">The local end point.</param>
    private static void ValidateInput(int maxConnections, int excessSocketAsyncEventArgsObjectsInPool, int backlog, int maxSimultaneousAcceptOps,
      int receiveBufferSize, int opsToPreAlloc, IPEndPoint localEndPoint)
    {
      if (maxConnections <= 0)
        throw new ArgumentException("Invalid value for MaxConnections",
                                    maxConnections.ToString(CultureInfo.InvariantCulture));

      if (excessSocketAsyncEventArgsObjectsInPool < 0)
        throw new ArgumentException("Invalid value for ExcessSocketAsyncEventArgsObjectsInPool",
                                    excessSocketAsyncEventArgsObjectsInPool.ToString(CultureInfo.InvariantCulture));

      if (backlog < 0)
        throw new ArgumentException("Invalid value for Backlog",
                                    backlog.ToString(CultureInfo.InvariantCulture));

      if (maxSimultaneousAcceptOps <= 0)
        throw new ArgumentException("Invalid value for MaxSimultaneousAcceptOps",
                                    maxSimultaneousAcceptOps.ToString(CultureInfo.InvariantCulture));

      if (receiveBufferSize <= 0)
        throw new ArgumentException("Invalid value for BufferSize",
          receiveBufferSize.ToString(CultureInfo.InvariantCulture));

      if (opsToPreAlloc < 0)
        throw new ArgumentException("Invalid value for OpsToPreAlloc",
          opsToPreAlloc.ToString(CultureInfo.InvariantCulture));

      if (null == localEndPoint)
        throw new ArgumentException("Invalid value for EndPoint");
    }

    /// <summary>
    /// Gets the max connections.
    /// </summary>
    /// <remarks></remarks>
    public Int32 MaxConnections
    {
      get { return this._maxConnections; }
    }

    /// <summary>
    /// Gets the number of socket async event args for rec send.
    /// </summary>
    /// <remarks></remarks>
    public Int32 NumberOfSocketAsyncEventArgsForRecSend
    {
      get { return this._numberOfSocketAsyncEventArgsForRecSend; }
    }

    /// <summary>
    /// Gets the backlog.
    /// </summary>
    /// <remarks></remarks>
    public Int32 Backlog
    {
      get { return this._backlog; }
    }

    /// <summary>
    /// Gets the max accept ops.
    /// </summary>
    /// <remarks></remarks>
    public Int32 MaxAcceptOps
    {
      get { return this._maxSimultaneousAcceptOps; }
    }

    /// <summary>
    /// Gets the size of the buffer.
    /// </summary>
    /// <remarks></remarks>
    public Int32 BufferSize
    {
      get { return this._receiveBufferSize; }
    }

    /// <summary>
    /// Gets the ops to pre allocate.
    /// </summary>
    /// <remarks></remarks>
    public Int32 OpsToPreAllocate
    {
      get { return this._opsToPreAllocate; }
    }

    /// <summary>
    /// Gets the local end point.
    /// </summary>
    /// <remarks></remarks>
    public IPEndPoint LocalEndPoint
    {
      get { return this._localEndPoint; }
    }
  }
}
