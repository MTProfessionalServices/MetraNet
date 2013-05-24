using System;
using System.Net.Sockets;
using MetraTech;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class MessageHandler
  /// </summary>
  internal class MessageHandler
  {
    private Logger _logger = new Logger("[TaxManager.VertexQ.HostFinder]");

    /// <summary>
    /// Handles the message.
    /// </summary>
    /// <param name="receiveSendEventArgs">The <see cref="SocketAsyncEventArgs" /> instance containing the event data.</param>
    /// <param name="receiveSendToken">The receive send token.</param>
    /// <param name="remainingBytesToProcess">The remaining bytes to process.</param>
    /// <returns><c>true</c> if XXXX, <c>false</c> otherwise</returns>
    public bool HandleMessage(SocketAsyncEventArgs receiveSendEventArgs, DataHoldingUserToken receiveSendToken,
                              Int32 remainingBytesToProcess)
    {
      try
      {
        bool incomingTcpMessageIsReady = false;

        // Create the array where we'll store the complete message, 
        // if it has not been created on a previous receive op.
        if (receiveSendToken.receivedMessageBytesDoneCount == 0)
        {
          receiveSendToken.theDataHolder.dataMessageReceived = new Byte[receiveSendToken.lengthOfCurrentIncomingMessage];
        }

        // TODO : Performance analysis Array.Copy vs Buffer.BlockCopy
        if (remainingBytesToProcess + receiveSendToken.receivedMessageBytesDoneCount == receiveSendToken.lengthOfCurrentIncomingMessage)
        {
          // If we are inside this if-statement, then we got the end of the message.
          // Write/append the bytes received to the byte array in the 
          // DataHolder object that we are using to store our data.
          Buffer.BlockCopy(receiveSendEventArgs.Buffer, receiveSendToken.receiveMessageOffset,
                           receiveSendToken.theDataHolder.dataMessageReceived,
                           receiveSendToken.receivedMessageBytesDoneCount, remainingBytesToProcess);

          incomingTcpMessageIsReady = true;
        }
        else
        {
          // If we are inside this else-statement, then that means that we
          // need another receive op. We still haven't got the whole message,
          // even though we have examined all the data that was received.
          // We just do another receive op to receive more data.
          Buffer.BlockCopy(receiveSendEventArgs.Buffer, receiveSendToken.receiveMessageOffset,
                           receiveSendToken.theDataHolder.dataMessageReceived,
                           receiveSendToken.receivedMessageBytesDoneCount, remainingBytesToProcess);

          receiveSendToken.receivedMessageBytesDoneCount += remainingBytesToProcess;
        }

        return incomingTcpMessageIsReady;
      }
      catch (Exception ex)
      {
        _logger.LogException("Caught Exception while trying to HandleMessage", ex);
        throw;
      }
    }
  }
}

