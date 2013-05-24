using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using MetraTech;

namespace Framework.TaxManager.VertexQ
{
  internal sealed class SocketClient
  {
    internal Int32 totalNumberOfConnectionRetries = 0;
    internal Int32 maxSimultaneousClientsThatWereConnected = 0;
    private object lockerForConnectionCount = new object();
    internal Int32 clientsNowConnectedCount = 0;

    Logger _logger = new Logger("[TaxManager.VertexQ.SocketClient]");

    // This is being used by the main VertexQ class to decide whether to start
    // dequeuing or not
    // if the socket client has not been initialized it is going to spin
    internal bool _isInitialized = false;

    // Create a large reusable set of buffers for all socket operations.
    BufferManager bufferManager;

    // Allows us to set the maximum number of client connections (that is, 
    // ports/sockets to open simultaneously.        
    SemaphoreSlim theMaxConnectionsEnforcer;

    private SocketClientSettings socketClientSettings;
    private static object locker = new object();
    internal BlockingQueue<string> incomingQueue;
    // change this to string type too
    internal BlockingQueue<OutgoingMessageHolder> outgoingQueue;
    MessageHandler messageHandler;

    // Pool of reusable SocketAsyncEventArgs objects
    SocketAsyncEventArgsPool poolOfConnectEventArgs;
    // pool of reusable SocketAsyncEventArgs objects for receive and send socket operations
    SocketAsyncEventArgsPool poolOfRecSendEventArgs;
    MessagePreparer messagePreparer;


    /// <summary>
    /// Initializes a new instance of the <see cref="SocketClient"/> class.
    /// </summary>
    /// <param name="theSocketClientSettings">The socket client settings.</param>
    /// <remarks></remarks>
    public SocketClient(SocketClientSettings theSocketClientSettings)
    {
      this.socketClientSettings = theSocketClientSettings;
      this.messageHandler = new MessageHandler();
      this.messagePreparer = new MessagePreparer();
      this.bufferManager = new BufferManager(
        this.socketClientSettings.BufferSize * this.socketClientSettings.NumberOfSocketAsyncEventArgsForRecSend *
        this.socketClientSettings.OpsToPreAllocate,
        this.socketClientSettings.BufferSize * this.socketClientSettings.OpsToPreAllocate);
      this.poolOfRecSendEventArgs = new SocketAsyncEventArgsPool(this.socketClientSettings.NumberOfSocketAsyncEventArgsForRecSend);
      this.poolOfConnectEventArgs = new SocketAsyncEventArgsPool(this.socketClientSettings.MaxConnectOps);

      this.theMaxConnectionsEnforcer = new SemaphoreSlim(this.socketClientSettings.MaxConnections, this.socketClientSettings.MaxConnections);
      this.incomingQueue = new BlockingQueue<string>();
      this.outgoingQueue = new BlockingQueue<OutgoingMessageHolder>();
      Init();
    }

    /// <summary>
    /// Initializes the client by preallocating reusable buffers and 
    /// context objects (SocketAsyncEventArgs objects).  
    /// </summary>
    /// <remarks></remarks>
    private void Init()
    {
      _logger.LogInfo("Creating Connect socket pool...");

      // Preallocate pool of SocketAsyncEventArgs objects for connect operations
      for (int i = 0; i < this.socketClientSettings.MaxConnectOps; i++)
      {
        SocketAsyncEventArgs connectEventArg = CreateNewSocketAsyncEventArgsForConnect(poolOfConnectEventArgs);

        // Add SocketAsyncEventArg to the pool
        this.poolOfConnectEventArgs.Push(connectEventArg);
      }
      _logger.LogInfo("Done adding {0} sockets to ConnectPool", this.socketClientSettings.MaxConnectOps);
      _logger.LogInfo("Initializing Buffer...");

      // Allocate one large byte buffer block, which all I/O operations will use a piece of.
      // This gaurds against memory fragmentation.
      this.bufferManager.InitBuffer();

      // The pool that we built ABOVE is for SocketAsyncEventArgs objects that do
      // connect operations. Now we will build a separate pool for 
      // SocketAsyncEventArgs objects that do receive/send operations. 
      // One reason to separate them is that connect
      // operations do NOT need a buffer, but receive/send operations do. 

      // Preallocate pool of SocketAsyncEventArgs for receive/send operations.
      _logger.LogInfo("Creating receive/send SocketAsyncEventArgs pool...");
      for (int i = 0; i < this.socketClientSettings.NumberOfSocketAsyncEventArgsForRecSend; i++)
      {
        // Allocate the SocketAsyncEventArgs object.
        SocketAsyncEventArgs eventArgObjectForPool = new SocketAsyncEventArgs();

        // Assign a byte buffer from the buffer block to 
        // this particular SocketAsyncEventArg object
        this.bufferManager.SetBuffer(eventArgObjectForPool);
        // Since we assigned a buffer like that, you can NOT just add more of
        // these send/receive SAEA objects if you run out of them.

        // Attach the receive/send-operation-SocketAsyncEventArgs object 
        // to its event handler. Since this SocketAsyncEventArgs object is used 
        // for both receive and send operations, whenever either of those 
        // completes, the IO_Completed method will be called.
        eventArgObjectForPool.Completed += new EventHandler<SocketAsyncEventArgs>(IO_Completed);

        Random random = new Random();
        // This dataholdingusertoken identifier the message we are going to send/recieve
        DataHoldingUserToken receiveSendToken = new DataHoldingUserToken(eventArgObjectForPool.Offset,
                                                                         eventArgObjectForPool.Offset +
                                                                         this.socketClientSettings.BufferSize);

        // Create an object that we can write data to, and remove as an object
        // from the UserToken, if we wish.
        receiveSendToken.CreateNewDataHolder();

        eventArgObjectForPool.UserToken = receiveSendToken;
        // Add this SocketAsyncEventArg object to the pool.
        this.poolOfRecSendEventArgs.Push(eventArgObjectForPool);
      }
      _logger.LogInfo("Object pools built.");

      if (_isInitialized) return;
      lock (locker)
      {
        _isInitialized = true;
      }
    }

    /// <summary>
    /// This method is called when we need to create a new SAEA object to do
    /// connect operations. The reason to put it in a separate method is so that
    /// we can easily add more objects to the pool if we need to.
    /// You can do that if you do NOT use a buffer in the SAEA object that does
    /// the connect operations.
    /// </summary>
    /// <param name="pool">The pool.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    private SocketAsyncEventArgs CreateNewSocketAsyncEventArgsForConnect(SocketAsyncEventArgsPool pool)
    {
      // Allocate the SocketAsyncEventArgs object. 
      SocketAsyncEventArgs connectEventArg = new SocketAsyncEventArgs();

      // Attach the event handler.  Since we'll be using this 
      // SocketAsyncEventArgs object to process connect ops,
      // what this does is cause the calling of the ConnectEventArg_Completed
      // object when the connect op completes.
      connectEventArg.Completed += new EventHandler<SocketAsyncEventArgs>(IO_Completed);

      ConnectOpUserToken theConnectingToken = new ConnectOpUserToken();
      connectEventArg.UserToken = theConnectingToken;

      return connectEventArg;
    }

    /// <summary>
    /// Handles the Completed event of the IO control.
    /// </summary>
    /// <param name="sender">The source of the event.</param>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void IO_Completed(object sender, SocketAsyncEventArgs e)
    {
      // Determine which type of operation just completed and call the associated handler
      switch (e.LastOperation)
      {
        case SocketAsyncOperation.Connect:
          ConnectOpUserToken theConnectingToken = (ConnectOpUserToken)e.UserToken;
          _logger.LogInfo("IO_Completed method In Connect, connect id = " + theConnectingToken.TokenId);
          ProcessConnect(e);
          break;

        case SocketAsyncOperation.Receive:
          ProcessReceive(e);
          break;

        case SocketAsyncOperation.Send:
          ProcessSend(e);
          break;

        case SocketAsyncOperation.Disconnect:
          ProcessDisconnectAndCloseSocket(e);
          break;

        default:
          throw new ArgumentException("Error in I/O Completed,");
      }
    }


    //internal void GetMessages(Stack<OutgoingMessageHolder> theStackOfOutgoingMessages)
    //{
    //  if (Program.watchProgramFlow == true)   //for testing
    //  {
    //    Program.testWriter.WriteLine("GetMessages");
    //  }
    //  this.stackOfOutgoingMessages = new BlockingStack<OutgoingMessageHolder>(theStackOfOutgoingMessages);

    //  //In this case the stack contains only one OutgoingMessageHolder which will be reused
    //  //by the CheckStack method.
    //  if (Program.runLongTest == true)
    //  {
    //    this.outgoingMessageHolderForLongTest = this.stackOfOutgoingMessages.Pop();
    //  }

    //  this.startTime = DateTime.Now.Ticks;
    //  Thread t = new Thread(CheckStack);
    //  t.Start();
    //}


    /// <summary>
    /// Checks the outgoing queue.
    /// </summary>
    /// <remarks></remarks>
    private void CheckOutgoingQueue()
    {
      _logger.LogInfo("Checking Outgoing Queue for messages to send");

      int count = outgoingQueue.Count();
      if (count > 0)
      {
        _logger.LogInfo("Found {0} messages in outgoing queue", count);
        _logger.LogInfo("Sending messages...");
      }


      OutgoingMessageHolder outgoingMessageHolder;
      outgoingMessageHolder = outgoingQueue.Dequeue();
      // Only relevant when the test has finished.
      if (count == 0)
        return;

      this.theMaxConnectionsEnforcer.AvailableWaitHandle.WaitOne();

      PushMessageArray(outgoingQueue.Dequeue());
    }

    //____________________________________________________________________________
    //
    private void PushMessageArray(OutgoingMessageHolder taxXMLToSend)
    {
      SocketAsyncEventArgs connectEventArgs;

      // Get a SocketAsyncEventArgs object to connect with.
      // Get it from the pool if there is more than one.
      connectEventArgs = this.poolOfConnectEventArgs.Pop();
      // or make a new one.            
      if (connectEventArgs == null)
      {
        connectEventArgs = CreateNewSocketAsyncEventArgsForConnect(poolOfConnectEventArgs);
      }

      ConnectOpUserToken theConnectingToken = (ConnectOpUserToken)connectEventArgs.UserToken;
      theConnectingToken.outgoingMessageHolder = taxXMLToSend;

      StartConnect(connectEventArgs);
      // Loop back to get message(s) for next connection.           
      CheckOutgoingQueue();
    }

    /// <summary>
    /// Starts the connect.
    /// </summary>
    /// <param name="connectEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void StartConnect(SocketAsyncEventArgs connectEventArgs)
    {
      ConnectOpUserToken theConnectingToken = (ConnectOpUserToken)connectEventArgs.UserToken;
      _logger.LogInfo("Connecting Token ID {0}", theConnectingToken.TokenId);

      // SocketAsyncEventArgs object that do connect operations on the client
      // are different from those that do accept operations on the server.
      // On the server the listen socket had EndPoint info. And that info was
      // passed from the listen socket to the SocketAsyncEventArgs object 
      // that did the accept operation.
      // But on the client there is no listen socket. The connect socket 
      // needs the info on the Remote Endpoint.
      connectEventArgs.RemoteEndPoint = this.socketClientSettings.ServerEndPoint;
      connectEventArgs.AcceptSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

      // Post the connect operation on the socket.
      // A local port is assigned by the Windows OS during connect op.            
      bool willRaiseEvent = connectEventArgs.AcceptSocket.ConnectAsync(connectEventArgs);
      if (!willRaiseEvent)
      {
        ProcessConnect(connectEventArgs);
      }
    }

    /// <summary>
    /// Pass the connection info from the connecting object to the object
    /// that will do send/receive. And put the connecting object back in the pool.
    /// </summary>
    /// <param name="connectEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessConnect(SocketAsyncEventArgs connectEventArgs)
    {
      ConnectOpUserToken theConnectingToken = (ConnectOpUserToken)connectEventArgs.UserToken;

      if (connectEventArgs.SocketError == SocketError.Success)
      {
        lock (this.lockerForConnectionCount)
        {
          this.clientsNowConnectedCount++;
          if (this.clientsNowConnectedCount > this.maxSimultaneousClientsThatWereConnected)
          {
            this.maxSimultaneousClientsThatWereConnected++;
          }
        }

        SocketAsyncEventArgs receiveSendEventArgs = this.poolOfRecSendEventArgs.Pop();
        receiveSendEventArgs.AcceptSocket = connectEventArgs.AcceptSocket;

        // Earlier, in the UserToken of connectEventArgs we put an array 
        // of messages to send. Now we move that array to the DataHolder in
        // the UserToken of receiveSendEventArgs.
        DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
        receiveSendToken.theDataHolder.PutMessagesToSend(
          theConnectingToken.outgoingMessageHolder.vertexTaxParamsXMLArray);
        _logger.LogInfo("ProcessConnect connect id " + theConnectingToken.TokenId +
                        ", local endpoint = " +
                        IPAddress.Parse(((IPEndPoint)connectEventArgs.AcceptSocket.LocalEndPoint).Address.ToString()) +
                        ": " + ((IPEndPoint)connectEventArgs.AcceptSocket.LocalEndPoint).Port.ToString(CultureInfo.InvariantCulture) +
                        ". Clients connected to server from this machine = " + this.clientsNowConnectedCount);

        messagePreparer.GetDataToSend(receiveSendEventArgs);
        StartSend(receiveSendEventArgs);

        // Release connectEventArgs object back to the pool.
        connectEventArgs.AcceptSocket = null;
        this.poolOfConnectEventArgs.Push(connectEventArgs);
        _logger.LogInfo("Back to pool for connection object " + theConnectingToken.TokenId);
      }
      else
      {
        // This else statement is when there was a socket error
        ProcessConnectionError(connectEventArgs);
      }
    }

    /// <summary>
    /// Processes the connection error.
    /// </summary>
    /// <param name="connectEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    internal void ProcessConnectionError(SocketAsyncEventArgs connectEventArgs)
    {
      ConnectOpUserToken theConnectingToken = (ConnectOpUserToken)connectEventArgs.UserToken;
      _logger.LogInfo("ProcessConnectionError() id = " + theConnectingToken.TokenId + ". ERROR: " + connectEventArgs.SocketError.ToString());

      // If connection was refused by server or timed out or not reachable, then we'll keep this socket.
      // If not, then we'll destroy it.
      if ((connectEventArgs.SocketError != SocketError.ConnectionRefused) &&
        (connectEventArgs.SocketError != SocketError.TimedOut) &&
        (connectEventArgs.SocketError != SocketError.HostUnreachable))
      {
        CloseSocket(connectEventArgs.AcceptSocket);
      }

      // Since we did not send the messages, let's put them back in the stack.
      // We cannot leave them in the SAEA for connect ops, because the SocketAsyncEventArgs 
      // could get pushed down in the stack and not reached.
      outgoingQueue.Enqueue(theConnectingToken.outgoingMessageHolder);
      this.poolOfConnectEventArgs.Push(connectEventArgs);

      this.theMaxConnectionsEnforcer.Release();
    }



    /// <summary>
    /// Set the send buffer and post a send op
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void StartSend(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;

      if (receiveSendToken.sendBytesRemaining <= this.socketClientSettings.BufferSize)
      {
        receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetSend, receiveSendToken.sendBytesRemaining);
        // Copy the bytes to the buffer associated with this SAEA object.
        Buffer.BlockCopy(receiveSendToken.dataToSend, receiveSendToken.bytesSentAlready, receiveSendEventArgs.Buffer,
                         receiveSendToken.bufferOffsetSend, receiveSendToken.sendBytesRemaining);
      }
      else
      {
        // We cannot try to set the buffer any larger than its size.
        // So since receiveSendToken.sendBytesRemaining > its size, we just
        // set it to the maximum size, to send the most data possible.
        receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetSend, this.socketClientSettings.BufferSize);
        // Copy the bytes to the buffer associated with this SAEA object.
        Buffer.BlockCopy(receiveSendToken.dataToSend, receiveSendToken.bytesSentAlready, receiveSendEventArgs.Buffer,
                         receiveSendToken.bufferOffsetSend, this.socketClientSettings.BufferSize);
      }

      // Post the send
      bool willRaiseEvent = receiveSendEventArgs.AcceptSocket.SendAsync(receiveSendEventArgs);
      if (!willRaiseEvent)
      {
        ProcessSend(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// Processes the send.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessSend(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;

      if (receiveSendEventArgs.SocketError == SocketError.Success)
      {
        receiveSendToken.sendBytesRemaining = receiveSendToken.sendBytesRemaining - receiveSendEventArgs.BytesTransferred;
        // If this if statement is true, then we have sent all of the
        // bytes in the message. Otherwise, at least one more send
        // operation will be required to send the data.
        if (receiveSendToken.sendBytesRemaining == 0)
        {
          // Incrementing count of messages sent on this connection                
          receiveSendToken.theDataHolder.NumberOfMessagesSent++;
          StartReceive(receiveSendEventArgs);
        }
        else
        {
          // So since (receiveSendToken.sendBytesRemaining == 0) is false,
          // we have more bytes to send for this message. So we need to 
          // call StartSend, so we can post another send message.
          receiveSendToken.bytesSentAlready += receiveSendEventArgs.BytesTransferred;
          StartSend(receiveSendEventArgs);
        }
      }
      else
      {
        // Socket error.
        _logger.LogInfo("ProcessSend ERROR");

        // We'll just close the socket if there was a socket error when receiving data from the client.
        receiveSendToken.Reset();
        StartDisconnect(receiveSendEventArgs);
      }
    }


    /// <summary>
    /// Set the receive buffer and post a receive op.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void StartReceive(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      // Set buffer for receive.          
      receiveSendEventArgs.SetBuffer(receiveSendToken.bufferOffsetReceive, this.socketClientSettings.BufferSize);
      _logger.LogInfo("StartReceive");

      bool willRaiseEvent = receiveSendEventArgs.AcceptSocket.ReceiveAsync(receiveSendEventArgs);
      if (!willRaiseEvent)
      {
        _logger.LogInfo("StartReceive in if (!willRaiseEvent)");
        ProcessReceive(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// Processes the receive.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessReceive(SocketAsyncEventArgs receiveSendEventArgs)
    {
      // Load this data onto the IncomingQueue
      // This would ideally be in the format of <TaxResults>.... </TaxResults>
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      // If there was a socket error, close the connection.
      if (receiveSendEventArgs.SocketError != SocketError.Success)
      {
        _logger.LogInfo("ProcessReceive ERROR " + receiveSendEventArgs.SocketError.ToString());

        receiveSendToken.Reset();
        StartDisconnect(receiveSendEventArgs);
        return;
      }

      // If no data was received, close the connection.
      if (receiveSendEventArgs.BytesTransferred == 0)
      {
        receiveSendToken.Reset();
        StartDisconnect(receiveSendEventArgs);
        return;
      }

      Int32 remainingBytesToProcess = receiveSendEventArgs.BytesTransferred;
      // This happens when nothing was received while waiting for a message
      if (remainingBytesToProcess == 0)
      {
        // We need to do another receive op, since we do not have the message yet.
        StartReceive(receiveSendEventArgs);
        return;
      }

      receiveSendToken.lengthOfCurrentIncomingMessage = receiveSendEventArgs.BytesTransferred;
      // We'll arrive here when we have received enough bytes to read
      bool incomingTcpMessageIsReady = messageHandler.HandleMessage(receiveSendEventArgs, receiveSendToken, remainingBytesToProcess);

      if (incomingTcpMessageIsReady == true)
      {
        // In the design of our SocketClient used for testing the
        // DataHolder can contain data for multiple messages. That is 
        // different from the server design, where we have one DataHolder
        // for one message.
        string messageString = AssembleMessage(receiveSendToken);
        incomingQueue.Enqueue(messageString);

        // Null out the byte array, for the next message
        receiveSendToken.theDataHolder.dataMessageReceived = null;

        // Reset the variables in the UserToken, to be ready for the
        // next message that will be received on the socket in this
        // SocketAsyncEventArgs object.
        receiveSendToken.Reset();

        // If we have not sent all the messages, get the next message, and
        // loop back to StartSend.
        // if (receiveSendToken.theDataHolder.NumberOfMessagesSent < this.socketClientSettings.NumberOfMessages)
        if (outgoingQueue.Count() > 0)
        {
          // No need to reset the buffer for send here.
          // It is reset in the StartSend method.
          messagePreparer.GetDataToSend(receiveSendEventArgs);
          StartSend(receiveSendEventArgs);
        }
        else
        {
          // Since we have sent all the messages that we planned to send,
          // time to disconnect.                    
          StartDisconnect(receiveSendEventArgs);
        }
      }
      else
      {
        // Since we have NOT gotten enough bytes for the whole message,
        // we need to do another receive op. Reset some variables first.

        // All of the data that we receive in the next receive op will be
        // message. None of it will be prefix. So, we need to move the 
        // receiveSendToken.receiveMessageOffset to the beginning of the 
        // buffer space for this SAEA.
        receiveSendToken.receiveMessageOffset = receiveSendToken.bufferOffsetReceive;

        StartReceive(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="receiveSendToken"></param>
    /// <returns></returns>
    private string AssembleMessage(DataHoldingUserToken receiveSendToken)
    {
      Byte[] buf = new byte[receiveSendToken.lengthOfCurrentIncomingMessage];
      buf = Encoding.Convert(Encoding.GetEncoding("iso-8859-1"), Encoding.UTF8,
                             receiveSendToken.theDataHolder.dataMessageReceived);
      string vertexResult = Encoding.UTF8.GetString(buf, 0, receiveSendToken.lengthOfCurrentIncomingMessage);

      return vertexResult;
    }

    /// <summary>
    /// Disconnect from the host.         
    /// </summary>
    /// <param name="receiveSendEventArgs"></param>
    private void StartDisconnect(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;
      _logger.LogInfo("StartDisconnect()");

      receiveSendEventArgs.AcceptSocket.Shutdown(SocketShutdown.Both);
      bool willRaiseEvent = receiveSendEventArgs.AcceptSocket.DisconnectAsync(receiveSendEventArgs);
      if (!willRaiseEvent)
      {
        ProcessDisconnectAndCloseSocket(receiveSendEventArgs);
      }
    }

    /// <summary>
    /// Processes the disconnect and close socket.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    private void ProcessDisconnectAndCloseSocket(SocketAsyncEventArgs receiveSendEventArgs)
    {
      DataHoldingUserToken receiveSendToken = (DataHoldingUserToken)receiveSendEventArgs.UserToken;

      if (receiveSendEventArgs.SocketError != SocketError.Success)
      {
        _logger.LogInfo("ProcessDisconnect ERROR");
      }

      // This method closes the socket and releases all resources, both
      // managed and unmanaged. It internally calls Dispose.
      receiveSendEventArgs.AcceptSocket.Close();

      // for testing
      Int32 sCount = receiveSendToken.theDataHolder.NumberOfMessagesSent;

      //create an object that we can write data to.
      receiveSendToken.CreateNewDataHolder();

      // It is time to release this SAEA object.
      this.poolOfRecSendEventArgs.Push(receiveSendEventArgs);

      // Count down the number of connected clients as they disconnect.
      Interlocked.Decrement(ref this.clientsNowConnectedCount);

      this.theMaxConnectionsEnforcer.Release();

      _logger.LogInfo(sCount + " = sent message count. " + this.clientsNowConnectedCount +
                                   " client connections to server from this machine. ");
    }

    /// <summary>
    /// 
    /// </summary>
    /// <param name="receiveSendToken"></param>
    /// <returns></returns>
    private string ShowData(DataHoldingUserToken receiveSendToken)
    {
      Int32 count = receiveSendToken.theDataHolder.listOfMessagesReceived.Count;
      Int32 lengthOfMessage = 0;

      StringBuilder sb = new StringBuilder();
      sb.Append(" received ");
      sb.Append(count);
      sb.Append(" messages:\r\n");
      for (int i = 0; i < count; i++)
      {
        lengthOfMessage = receiveSendToken.theDataHolder.listOfMessagesReceived[i].Length;
        // The server sent back its receivedTransmissionId value.
        // It is Int32, which is 4 bytes.
        Int32 transMissionIdOfServer = BitConverter.ToInt32(receiveSendToken.theDataHolder.listOfMessagesReceived[i], 0);
        sb.Append(transMissionIdOfServer.ToString());
        sb.Append(", ");
        sb.Append(Encoding.ASCII.GetString(receiveSendToken.theDataHolder.listOfMessagesReceived[i], 0, lengthOfMessage));
        sb.Append("\r\n");
      }
      sb.Append("\r\n");
      return sb.ToString();
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
    /// Disposes all socket async event args objects.
    /// </summary>
    /// <remarks></remarks>
    private void DisposeAllSocketAsyncEventArgsObjects()
    {
      SocketAsyncEventArgs eventArgs;
      while (this.poolOfConnectEventArgs.Count > 0)
      {
        eventArgs = poolOfConnectEventArgs.Pop();
        eventArgs.Dispose();
      }
      while (this.poolOfRecSendEventArgs.Count > 0)
      {
        eventArgs = poolOfRecSendEventArgs.Pop();
        eventArgs.Dispose();
      }
    }

    /// <summary>
    /// Closes the socket.
    /// </summary>
    /// <param name="theSocket">The socket.</param>
    /// <remarks></remarks>
    private void CloseSocket(Socket theSocket)
    {
      try
      {
        theSocket.Shutdown(SocketShutdown.Both);
      }
      catch
      {
        _logger.LogError("Caught exception while trying to Shutdown socket");
      }
      finally
      {
        if (null != theSocket)
        {
          theSocket.Close();
          theSocket.Dispose();
        }
      }
    }
  }
}



