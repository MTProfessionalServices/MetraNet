using System;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class DataHoldingUserToken
  /// </summary>
  class DataHoldingUserToken
  {
    internal DataHolder theDataHolder;

    internal Int32 receivedMessageBytesDoneCount = 0;
    internal Int32 receiveMessageOffset;

    internal Int32 lengthOfCurrentIncomingMessage;
    internal readonly Int32 bufferOffsetReceive;
    internal readonly Int32 permanentReceiveMessageOffset;
    internal readonly Int32 bufferOffsetSend;
    internal Byte[] dataToSend;
    internal Int32 sendBytesRemaining;
    internal Int32 bytesSentAlready;

    /// <summary>
    /// Initializes a new instance of the <see cref="DataHoldingUserToken"/> class.
    /// </summary>
    /// <param name="rOffset">The r offset.</param>
    /// <param name="sOffset">The s offset.</param>
    /// <remarks></remarks>
    public DataHoldingUserToken(Int32 rOffset, Int32 sOffset)
    {
      this.bufferOffsetReceive = rOffset;
      this.bufferOffsetSend = sOffset;
      this.receiveMessageOffset = rOffset;
      this.permanentReceiveMessageOffset = this.receiveMessageOffset;
    }

    /// <summary>
    /// Creates the new data holder.
    /// </summary>
    internal void CreateNewDataHolder()
    {
      theDataHolder = new DataHolder();
    }

    /// <summary>
    /// Resets this instance.
    /// </summary>
    public void Reset()
    {
      this.receivedMessageBytesDoneCount = 0;
      this.receiveMessageOffset = this.permanentReceiveMessageOffset;
    }
  }
}
