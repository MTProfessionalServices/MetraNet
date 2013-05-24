using System;
using System.Diagnostics;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using MetraTech;

namespace VertexSocketService
{
  /// <summary>
  /// SocketListener
  /// </summary>
  /// <remarks></remarks>
  class SocketListener
  {
    private readonly Vertex _vertexWrapper = new Vertex();
    private static readonly Logger _logger = new Logger("[VertexSocketService.SocketListener]");

    // Total clients connected to the server, excluding backlog
    internal Int32 _numberOfAcceptedSockets;

    // Buffers for sockets are unmanaged by .NET. 
    // So memory used for buffers gets "pinned", which makes the
    // .NET garbage collector work around it, fragmenting the memory. 
    // Circumvent this problem by putting all buffers together 
    // in one block in memory. Then we will assign a part of that space 
    // to each SocketAsyncEventArgs object, and
    // reuse that buffer space each time we reuse the SocketAsyncEventArgs object.
    // Create a large reusable set of buffers for all socket operations.
    readonly BufferManager _bufferManager;

    /// <summary>
    /// The socket used to listen for incoming connection requests 
    /// </summary>
    Socket _listenSocket;

    /// <summary>
    /// Lightweight semaphore alternative.
    /// </summary>
    readonly SemaphoreSlim _maxConnectionsEnforcer;

    /// <summary>
    /// Socket settings.
    /// </summary>
    readonly SocketListenerSettings _socketListenerSettings;

    /// <summary>
    /// The Message Handler
    /// </summary>
    readonly MessageHandler _messageHandler;

    /// <summary>
    /// Pool of reusable SocketAsyncEventArgs objects for accept operations 
    /// </summary>
    readonly SocketAsyncEventArgsPool _poolOfAcceptEventArgs;

    /// <summary>
    /// Pool of reusable SocketAsyncEventArgs objects for receive and send socket operations 
    /// </summary>
    readonly SocketAsyncEventArgsPool _poolOfRecSendEventArgs;

    /// <summary>
    /// Initializes a new instance of the <see cref="SocketListener"/> class.
    /// </summary>
    /// <param name="theSocketListenerSettings">The socket listener settings.</param>
    /// <remarks></remarks>
    public SocketListener(SocketListenerSettings theSocketListenerSettings)
    {
      this._numberOfAcceptedSockets = 0;
      this._socketListenerSettings = theSocketListenerSettings;
      this._messageHandler = new MessageHandler();

      // Allocate memory for buffers. We are using a separate buffer space for
      // receive and send, instead of sharing the buffer space.
      this._bufferManager =
          new BufferManager(
              this._socketListenerSettings.BufferSize * this._socketListenerSettings.NumberOfSocketAsyncEventArgsForRecSend *
              this._socketListenerSettings.OpsToPreAllocate,
              this._socketListenerSettings.BufferSize * this._socketListenerSettings.OpsToPreAllocate);

      this._poolOfRecSendEventArgs = new SocketAsyncEventArgsPool(this._socketListenerSettings.NumberOfSocketAsyncEventArgsForRecSend);
      this._poolOfAcceptEventArgs = new SocketAsyncEventArgsPool(this._socketListenerSettings.MaxAcceptOps);

      // Create connections count enforcer
      this._maxConnectionsEnforcer = new SemaphoreSlim(this._socketListenerSettings.MaxConnections,
                                                         this._socketListenerSettings.MaxConnections);

      Init();
      StartListen();
    }

    /// <summary>
    /// Initializes the server by preallocating reusable buffers and
    /// context objects (SocketAsyncEventArgs objects).
    /// It is NOT mandatory that you preallocate them or reuse them. But, but it is
    /// done this way to illustrate how the API can
    /// easily be used to create reusable objects to increase server performance.
    /// </summary>
    /// <remarks></remarks>
    internal void Init()
    {
      // Allocate one large byte buffer block, which all I/O operations will 
      // use a piece of. This gaurds against memory fragmentation.
      this._bufferManager.InitBuffer();

      _logger.LogInfo("Starting creation of Accept SocketAsyncEventArgs pool...");

      // Preallocate pool of SocketAsyncEventArgs objects for accept operations           
      for (Int32 i = 0; i < this._socketListenerSettings.MaxAcceptOps; i++)
      {
        // Add SocketAsyncEventArg to the pool
        this._poolOfAcceptEventArgs.Push(CreateNewSocketAsyncEventArgsForAccept(_poolOfAcceptEventArgs));
      }
      _logger.LogInfo("Finished creating pool of Accept SocketAsyncEventArgs");

      _logger.LogInfo("Starting creation of receive/send SocketAsyncEventArgs pool...");
      // Create a separate pool that does recieve and send operations.
      for (Int32 i = 0; i < this._socketListenerSettings.NumberOfSocketAsyncEventArgsForRecSend; i++)
      {
        // Allocate the SocketAsyncEventArgs object for this loop, 
        // to go in its place in the stack which will be the pool
        // for receive/send operation context objects.
        SocketAsyncEventArgs eventArgObjectForPool = new SocketAsyncEventArgs();

        // Assign a byte buffer from the buffer block to 
        // this particular SocketAsyncEventArg object
        this._bufferManager.SetBuffer(eventArgObjectForPool);

        // Attach the SocketAsyncEventArgs object
        // to its event handler. Since this SocketAsyncEventArgs object is 
        // used for both receive and send operations, whenever either of those 
        // completes, the IO_Completed method will be called.
        eventArgObjectForPool.Completed += new EventHandler<SocketAsyncEventArgs>(IO_Completed);

        // We can store data in the UserToken property of SocketAsyncEventArgs object.
        DataHoldingUserToken tempReceiveSendUserToken = new DataHoldingUserToken(
          eventArgObjectForPool, eventArgObjectForPool.Offset,
          eventArgObjectForPool.Offset + this._socketListenerSettings.BufferSize);

        // Create dataholder that can be serialized.
        tempReceiveSendUserToken.CreateNewDataHolder();

        eventArgObjectForPool.UserToken = tempReceiveSendUserToken;

        // Add this SocketAsyncEventArg object to the pool.
        this._poolOfRecSendEventArgs.Push(eventArgObjectForPool);
      }
      _logger.LogInfo("Done creating socketasynceventargs pool for send/receive");

      // Load And Initialize Vertex
      if (!_vertexWrapper.IsVertexInitialized)
      {
        _vertexWrapper.LoadVertexSettings();
      }
      _logger.LogInfo("Initializing Vertex...");
      Stopwatch stopwatch = new Stopwatch();
      Console.WriteLine("Initializing vertex...");
      stopwatch.Start();
      _vertexWrapper.InitializeVertex();
      stopwatch.Stop();
      _logger.LogInfo("Done Initializing Vertex");
      Console.WriteLine("Done Initializing Vertex in {0} milliseconds", stopwatch.ElapsedMilliseconds);
    }

    /// <summary>
    /// This method is called when we need to create a new SocketAsyncEventArgs object to do
    /// accept operations.
    /// </summary>
    /// <param name="pool">The pool.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    internal SocketAsyncEventArgs CreateNewSocketAsyncEventArgsForAccept(SocketAsyncEventArgsPool pool)
    {
      // Allocate the SocketAsyncEventArgs object. 
      SocketAsyncEventArgs acceptEventArg = new SocketAsyncEventArgs();

      // Attach the event handler, which causes the calling of the 
      // AcceptEventArg_Completed object when the accept op completes.
      acceptEventArg.Completed += new EventHandler<SocketAsyncEventArgs>(AcceptEventArg_Completed);

      return acceptEventArg;
    }

    /// <summary>
    /// This method starts the socket server such that it is listening for 
    /// incoming connection requests.            
    /// </summary>
    /// <remarks></remarks>
    internal void StartListen()
    {
      _logger.LogInfo("StartListen method. Before Listen operation is started.");

      // Create the socket which listens for incoming connections
      _listenSocket = new Socket(this._socketListenerSettings.LocalEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);

      // Bind it to the port
      _listenSocket.Bind(this._socketListenerSettings.LocalEndPoint);
      _listenSocket.Listen(this._socketListenerSettings.Backlog);

      Console.WriteLine(
        "\r\n\r\n*************************\r\n** Server is listening **\r\n*************************\r\n\r\nAfter you are finished, type 'Z' and press\r\nEnter key to terminate the server process.\r\n\r\n");

      StartAccept();
    }

    /// <summary>
    /// Begins an operation to accept a connection request from the client       
    /// </summary>
    /// <remarks></remarks>
    internal void StartAccept()
    {
      SocketAsyncEventArgs acceptEventArg;

      // Get a SocketAsyncEventArgs object to accept the connection.                        
      // Get it from the pool if there is more than one in the pool.
      if (this._poolOfAcceptEventArgs.Count > 1)
      {
        try
        {
          acceptEventArg = this._poolOfAcceptEventArgs.Pop();
        }
        catch
        {
          // If we can't find a free object, create a new one
          acceptEventArg = CreateNewSocketAsyncEventArgsForAccept(_poolOfAcceptEventArgs);
        }
      }
      else
      {
        // Or make a new one.
        acceptEventArg = CreateNewSocketAsyncEventArgsForAccept(_poolOfAcceptEventArgs);
      }

      // Enter the semaphore by calling the WaitOne method.
      // This is a mechanism to prevent exceeding
      // the max # of connections we specified. We'll do this before
      // doing AcceptAsync. 
      this._maxConnectionsEnforcer.AvailableWaitHandle.WaitOne();

      // Pass the newly created acceptEventArg SAEA object to the accepting socket.
      bool willRaiseEvent = _listenSocket.AcceptAsync(acceptEventArg);

      // Socket.AcceptAsync returns true if the I/O operation is pending, i.e. is 
      // working asynchronously. The SocketAsyncEventArgs.Completed event on the acceptEventArg parameter 
      // will be raised upon completion of accept op.
      // AcceptAsync will call the AcceptEventArg_Completed
      // method when it completes, because when we created this SocketAsyncEventArgs
      // object before putting it in the pool, we set the event handler to do it.
      // AcceptAsync returns false if the I/O operation completed synchronously.            
      // The SocketAsyncEventArgs.Completed event on the acceptEventArg 
      // parameter will NOT be raised when AcceptAsync returns false.
      if (!willRaiseEvent)
      {
        // The code in this if (!willRaiseEvent) statement only runs 
        // when the operation was completed synchronously. It is needed because 
        // when Socket.AcceptAsync returns false, 
        // it does NOT raise the SocketAsyncEventArgs.Completed event.
        // And we need to call ProcessAccept and pass it the SocketAsyncEventArgs object.
        // This is only when a new connection is being accepted.
        // Probably only relevant in the case of a socket error.
        ProcessAccept(acceptEventArg);
      }
    }

    /// <summary>
    /// This method is the callback method associated with Socket.AcceptAsync 
    // operations and is invoked when an async accept operation completes.
    // This is only when a new connection is being accepted.
    // Notice that Socket.AcceptAsync is returning a value of true, and
    // raising the Completed event when the AcceptAsync method completes.
    /// </summary>
    /// <param name="sender">The source of the event.</param>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void AcceptEventArg_Completed(object sender, SocketAsyncEventArgs e)
    {
      ProcessAccept(e);
    }

    /// <summary>
    /// Processes the accept.
    /// </summary>
    /// <param name="acceptEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessAccept(SocketAsyncEventArgs acceptEventArgs)
    {
      if (acceptEventArgs.SocketError != SocketError.Success)
      {
        // Loop back to post another accept op.
        StartAccept();

        // Let's destroy this socket, since it could be bad.
        HandleBadAccept(acceptEventArgs);

        return;
      }

      Int32 max = Program.maxSimultaneousClientsThatWereConnected;
      // TODO : Performance Issues ???
      Int32 numberOfConnectedSockets = Interlocked.Increment(ref this._numberOfAcceptedSockets);
      if (numberOfConnectedSockets > max)
      {
        // TODO : Performance Issues ???
        Interlocked.Increment(ref Program.maxSimultaneousClientsThatWereConnected);
      }

      // Now that the accept operation completed, we can start another
      // accept operation, which will do the same. 
      StartAccept();

      // Get a SocketAsyncEventArgs object from the pool of receive/send op 
      // SocketAsyncEventArgs objects
      SocketAsyncEventArgs receiveSendEventArgs = this._poolOfRecSendEventArgs.Pop();

      // Create sessionId in UserToken.
      ((DataHoldingUserToken)receiveSendEventArgs.UserToken).CreateSessionId();

      // Pass socket info from Accepted socket to Recieving/Sending socket.
      receiveSendEventArgs.AcceptSocket = acceptEventArgs.AcceptSocket;

      // We have handed off the connection info from the
      // accepting socket to the receiving socket. So, now we can
      // put the SocketAsyncEventArgs object that did the accept operation 
      // back in the pool for them. 
      acceptEventArgs.AcceptSocket = null;
      this._poolOfAcceptEventArgs.Push(acceptEventArgs);

      StartReceive(receiveSendEventArgs);
    }

    /// <summary>
    /// Set the receive buffer and post a receive op.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void StartReceive(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;

      // Set the buffer for the receive operation.
      receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetReceive, this._socketListenerSettings.BufferSize);

      // Post async receive operation on the socket.
      bool willRaiseEvent = receiveSendEventArgs.AcceptSocket.ReceiveAsync(receiveSendEventArgs);

      // Socket.ReceiveAsync returns false if I/O operation completed synchronously. 
      if (!willRaiseEvent)
      {
        // If the op completed synchronously, we need to call ProcessReceive 
        // method directly.
        ProcessReceive(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// This method is called whenever a receive or send operation completes.
    /// Here "e" represents the SocketAsyncEventArgs object associated 
    /// with the completed receive or send operation
    /// </summary>
    /// <param name="sender">The source of the event.</param>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    void IO_Completed(object sender, SocketAsyncEventArgs e)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)e.UserToken;

      // Determine which type of operation just completed and call the associated handler
      switch (e.LastOperation)
      {
        case SocketAsyncOperation.Receive:
          _logger.LogInfo("IO_Completed method in Receive. SessionID = {0}", receiveSendToken.SessionId);
          ProcessReceive(e);
          break;

        case SocketAsyncOperation.Send:
          _logger.LogInfo("IO_Completed method in Send. SessionID = {0}", receiveSendToken.SessionId);
          ProcessSend(e);
          break;

        default:
          // This exception will occur if you code the Completed event of some
          // operation to come to this method, by mistake.
          throw new ArgumentException("The last operation completed on the socket was not a receive or send");
      }
    }

    /// <summary>
    /// This method is invoked by the IO_Completed method
    /// when an asynchronous receive operation completes. 
    /// If the remote host closed the connection, then the socket is closed.
    /// Otherwise, we process the received data. And if a complete message was
    /// received, then we do some additional processing, to 
    /// respond to the client.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessReceive(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      // If there was a socket error, close the connection. 
      if (receiveSendEventArgs.SocketError != SocketError.Success)
      {
        receiveSendToken.Reset();
        CloseClientSocket(receiveSendEventArgs);
        return;
      }

      // If no data was received, close the connection. This is a NORMAL
      // situation that shows when the client has finished sending data.
      if (receiveSendEventArgs.BytesTransferred == 0)
      {
        _logger.LogInfo("ProcessReceive NO DATA, receiveSendToken id " + receiveSendToken.SessionId);

        receiveSendToken.Reset();
        CloseClientSocket(receiveSendEventArgs);
        return;
      }

      Int32 remainingBytesToProcess = receiveSendEventArgs.BytesTransferred;
      _logger.LogInfo("ProcessReceive " + receiveSendToken.SessionId + ". remainingBytesToProcess = " + remainingBytesToProcess);

      if (remainingBytesToProcess == 0)
      {
        // We need to do another receive op, since we do not have
        // the message yet, but remainingBytesToProcess == 0.
        StartReceive(receiveSendEventArgs);
        return;
      }

      receiveSendToken.lengthOfCurrentIncomingMessage = receiveSendEventArgs.BytesTransferred;

      // If we have processed the prefix, we can work on the message now.
      // We'll arrive here when we have received enough bytes to read
      // the first byte after the prefix.
      bool incomingTcpMessageIsReady = _messageHandler.HandleMessage(receiveSendEventArgs, receiveSendToken, remainingBytesToProcess);

      if (incomingTcpMessageIsReady == true)
      {
        _logger.LogInfo(receiveSendToken.SessionId + ", Message in DataHolder = " +
                                     Encoding.ASCII.GetString(receiveSendToken.theDataHolder.dataMessageReceived) +
                                     "\r\n");

        // Pass the DataHolder object to the Mediator here.                       
        receiveSendToken.theMediator.HandleData(receiveSendToken.theDataHolder);

        // Create a new DataHolder for next message.
        receiveSendToken.CreateNewDataHolder();

        receiveSendToken.Reset();

        receiveSendToken.theMediator.PrepareOutgoingData();
        StartSend(receiveSendToken.theMediator.GiveBack());
      }
      else
      {
        // Since we have NOT gotten enough bytes for the whole message,
        // we need to do another receive op. 
        receiveSendToken.receiveMessageOffset = receiveSendToken.bufferOffsetReceive;

        StartReceive(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// Starts the send.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void StartSend(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      _logger.LogInfo("StartSend, id " + receiveSendToken.SessionId);

      if (receiveSendToken.sendBytesRemainingCount <= this._socketListenerSettings.BufferSize)
      {
        receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetSend, receiveSendToken.sendBytesRemainingCount);
        // Copy the bytes to the buffer associated with this SocketAsyncEventArgs object.
        Buffer.BlockCopy(receiveSendToken.dataToSend, receiveSendToken.bytesSentAlreadyCount,
                         receiveSendEventArgs.Buffer, receiveSendToken.bufferOffsetSend,
                         receiveSendToken.sendBytesRemainingCount);
      }
      else
      {
        // We cannot try to set the buffer any larger than its size.
        // So since receiveSendToken.sendBytesRemainingCount > BufferSize, we just
        // set it to the maximum size, to send the most data possible.
        receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetSend, this._socketListenerSettings.BufferSize);
        // Copy the bytes to the buffer associated with this SocketAsyncEventArgs object.
        Buffer.BlockCopy(receiveSendToken.dataToSend, receiveSendToken.bytesSentAlreadyCount,
                         receiveSendEventArgs.Buffer, receiveSendToken.bufferOffsetSend,
                         this._socketListenerSettings.BufferSize);
      }

      // Post asynchronous send operation
      bool willRaiseEvent = receiveSendEventArgs.AcceptSocket.SendAsync(receiveSendEventArgs);

      if (willRaiseEvent) return;
      _logger.LogInfo("StartSend in if (!willRaiseEvent), receiveSendToken id " + receiveSendToken.SessionId);
      ProcessSend(receiveSendEventArgs);
    }

    /// <summary>
    /// This method is called by I/O Completed() when an asynchronous send completes.  
    /// If all of the data has been sent, then this method calls StartReceive
    /// to start another receive op on the socket to read any additional 
    /// data sent from the client. If all of the data has NOT been sent, then it 
    /// calls StartSend to send more data.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessSend(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      _logger.LogInfo("ProcessSend, id " + receiveSendToken.SessionId);

      if (receiveSendEventArgs.SocketError == SocketError.Success)
      {
        receiveSendToken.sendBytesRemainingCount = receiveSendToken.sendBytesRemainingCount - receiveSendEventArgs.BytesTransferred;

        if (receiveSendToken.sendBytesRemainingCount == 0)
        {
          // Send complete. Start receive again.
          StartReceive(receiveSendEventArgs);
        }
        else
        {
          // Still not done sending message....
          receiveSendToken.bytesSentAlreadyCount += receiveSendEventArgs.BytesTransferred;
          StartSend(receiveSendEventArgs);
        }
      }
      else
      {
        // Handle socket error
        _logger.LogInfo("Socket Error. Closing this socket.");

        // We'll just close the socket if there was a
        // socket error when receiving data from the client.
        receiveSendToken.Reset();
        CloseClientSocket(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// Does the normal destroying of sockets after 
    /// we finish receiving and sending on a connection.       
    /// </summary>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void CloseClientSocket(SocketAsyncEventArgs e)
    {
      var receiveSendToken = (e.UserToken as DataHoldingUserToken);

      if (receiveSendToken != null)
      {
        _logger.LogInfo("Closing client socket. session id = {0}", receiveSendToken.SessionId);

        try
        {
          e.AcceptSocket.Shutdown(SocketShutdown.Both);
        }
        catch (Exception ex)
        {
          // Throws if socket was already closed
          _logger.LogException("Exception while trying to shutdown socket. This may be bacause the socket has already been shutdown.", ex);
        }
      }

      // This method closes the socket and releases all resources, both
      // managed and unmanaged. It internally calls Dispose.
      e.AcceptSocket.Close();

      // Make sure the new DataHolder has been created for the next connection.
      // If it has, then dataMessageReceived should be null.
      if (receiveSendToken != null && receiveSendToken.theDataHolder.dataMessageReceived != null)
      {
        receiveSendToken.CreateNewDataHolder();
      }

      // Put the SocketAsyncEventArg back into the pool,
      // to be used by another client. This 
      this._poolOfRecSendEventArgs.Push(e);

      // Decrement the counter keeping track of the total number of clients 
      // connected to the server.
      // TODO : Performance Issues ???
      Interlocked.Decrement(ref this._numberOfAcceptedSockets);
      if (receiveSendToken != null)
        _logger.LogInfo(receiveSendToken.SessionId + " disconnected. " + this._numberOfAcceptedSockets + " client(s) connected.");

      // Release Semaphore so that its connection counter will be decremented.
      // This must be done AFTER putting the SocketAsyncEventArg back into the pool,
      // or you can run into problems.
      try
      {
        if (this._maxConnectionsEnforcer.CurrentCount < this._socketListenerSettings.MaxConnections)
          this._maxConnectionsEnforcer.Release();
      }
      catch (SemaphoreFullException ex)
      {
        _logger.LogException("Caught semaphore full exception", ex);
      }
    }

    /// <summary>
    /// Handles the bad accept.
    /// </summary>
    /// <param name="acceptEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void HandleBadAccept(SocketAsyncEventArgs acceptEventArgs)
    {
      _logger.LogInfo("Closing bad socket and creating new one");
      acceptEventArgs.AcceptSocket.Close();
      // Put the SocketAsyncEventArgs back in the pool.
      _poolOfAcceptEventArgs.Push(acceptEventArgs);
    }

    /// <summary>
    /// Cleans up on exit.
    /// </summary>
    /// <remarks></remarks>
    internal void CleanUpOnExit()
    {
      DisposeAllSocketAsyncEventArgsObjects();
    }

    /// <summary>
    /// Disposes all saea objects.
    /// </summary>
    /// <remarks></remarks>
    private void DisposeAllSocketAsyncEventArgsObjects()
    {
      SocketAsyncEventArgs eventArgs;
      while (this._poolOfAcceptEventArgs.Count > 0)
      {
        eventArgs = _poolOfAcceptEventArgs.Pop();
        eventArgs.Dispose();
      }
      while (this._poolOfRecSendEventArgs.Count > 0)
      {
        eventArgs = _poolOfRecSendEventArgs.Pop();
        eventArgs.Dispose();
      }
    }
  }
}
