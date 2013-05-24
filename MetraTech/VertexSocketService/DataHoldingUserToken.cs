using System;
using System.Net.Sockets;
using System.Threading;

namespace VertexSocketService
{
  /// <summary>
  /// The DataholdingUserToken class.
  /// </summary>
  /// <remarks></remarks>
  class DataHoldingUserToken
  {
    internal Mediator theMediator;
    internal DataHolder theDataHolder;

    internal readonly Int32 bufferOffsetReceive;
    internal readonly Int32 permanentReceiveMessageOffset;
    internal readonly Int32 bufferOffsetSend;

    internal Int32 lengthOfCurrentIncomingMessage;

    // receiveMessageOffset is used to mark the byte position where the message
    // begins in the receive buffer.
    internal Int32 receiveMessageOffset;

    internal Int32 receivedMessageBytesDoneCount = 0;
    internal Int32 sendBytesRemainingCount;
    internal Byte[] dataToSend;
    internal Int32 bytesSentAlreadyCount;

    // The session ID correlates with all the data sent in a connected session.
    // It is different from the transmission ID in the DataHolder, which relates
    // to one TCP message. A connected session could have many messages, if you
    //set up your app to allow it.
    private Int64 sessionId;

    /// <summary>
    /// Initializes a new instance of the <see cref="DataHoldingUserToken"/> class.
    /// </summary>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <param name="rOffset">The r offset.</param>
    /// <param name="sOffset">The s offset.</param>
    /// <remarks></remarks>
    public DataHoldingUserToken(SocketAsyncEventArgs e, Int32 rOffset, Int32 sOffset)
    {
      // Create a Mediator that has a reference to the SocketAsyncEventArgs object.
      this.theMediator = new Mediator(e);
      this.bufferOffsetReceive = rOffset;
      this.bufferOffsetSend = sOffset;
      this.receiveMessageOffset = rOffset;
      this.permanentReceiveMessageOffset = this.receiveMessageOffset;
    }

    /// <summary>
    /// Creates the new data holder.
    /// </summary>
    /// <remarks></remarks>
    internal void CreateNewDataHolder()
    {
      theDataHolder = new DataHolder();
    }
    
    /// <summary>
    /// Used to create sessionId variable in DataHoldingUserToken.
    /// Called in ProcessAccept().
    /// </summary>
    /// <remarks></remarks>
    internal void CreateSessionId()
    {
      // TODO : Performance Issues ???
      sessionId = Interlocked.Increment(ref Program.mainSessionId);
    }

    /// <summary>
    /// Gets the session id.
    /// </summary>
    /// <remarks></remarks>
    public Int64 SessionId
    {
      get { return this.sessionId; }
    }

    /// <summary>
    /// Resets this instance.
    /// </summary>
    /// <remarks></remarks>
    public void Reset()
    {
      this.receivedMessageBytesDoneCount = 0;
      this.receiveMessageOffset = this.permanentReceiveMessageOffset;
    }
  }
}
