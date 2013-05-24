using System;
using System.Net.Sockets;
using MetraTech;

namespace VertexSocketService
{
  /// <summary>
  /// OutgoingDataPreparer
  /// </summary>
  /// <remarks></remarks>
  class OutgoingDataPreparer
  {
    private static readonly Logger _logger = new Logger("[VertexSocketService.OutgoingDataPreparer]");
    private DataHolder _outgoingDataHolder;

    /// <summary>
    /// Prepares the outgoing data.
    /// </summary>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <param name="handledDataHolder">The handled data holder.</param>
    /// <remarks></remarks>
    internal void PrepareOutgoingData(SocketAsyncEventArgs e, DataHolder handledDataHolder)
    {
      DataHoldingUserToken dataHoldingUserToken = e.UserToken as DataHoldingUserToken;

      if (null == dataHoldingUserToken)
        throw new ArgumentNullException("e");

      try
      {
        dataHoldingUserToken = (DataHoldingUserToken)e.UserToken;
      }
      catch (InvalidCastException invalidCastException)
      {
        _logger.LogException("Caught InvalidCastException when trying to cast UserToken to DataHoldingUserToken",
                             invalidCastException);
        throw;
      }

      _outgoingDataHolder = handledDataHolder;

      // Determine the length of all the data that we will send back.
      Int32 lengthOfCurrentOutgoingMessage = _outgoingDataHolder.dataMessageReceived.Length;

      // Create the byte array to send.
      dataHoldingUserToken.dataToSend = new Byte[lengthOfCurrentOutgoingMessage];

      // The message that the client sent is already in a byte array, in DataHolder.
      Buffer.BlockCopy(_outgoingDataHolder.dataMessageReceived, 0, dataHoldingUserToken.dataToSend, 0,
                       _outgoingDataHolder.dataMessageReceived.Length);

      dataHoldingUserToken.sendBytesRemainingCount = lengthOfCurrentOutgoingMessage;
      dataHoldingUserToken.bytesSentAlreadyCount = 0;

      _logger.LogInfo("Sending {0} bytes", dataHoldingUserToken.sendBytesRemainingCount);
    }
  }
}
