using System;
using System.Net.Sockets;
using MetraTech;


namespace VertexSocketService
{
  /// <summary>
  /// 
  /// </summary>
    class MessageHandler
    {
      private readonly Logger _logger = new Logger("[VertexSocketService.MessageHandler]");

      /// <summary>
      /// Handles the message.
      /// </summary>
      /// <param name="receiveSendEventArgs">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
      /// <param name="receiveSendToken">The receive send token.</param>
      /// <param name="remainingBytesToProcess">The remaining bytes to process.</param>
      /// <returns></returns>
      /// <remarks></remarks>
        public bool HandleMessage(SocketAsyncEventArgs receiveSendEventArgs, DataHoldingUserToken receiveSendToken, Int32 remainingBytesToProcess)
        {
            bool incomingTcpMessageIsReady = false;
            
            // Create the array where we'll store the complete message, 
            // if it has not been created on a previous receive op.
            if (receiveSendToken.receivedMessageBytesDoneCount == 0)
            {
                receiveSendToken.theDataHolder.dataMessageReceived = new Byte[receiveSendToken.lengthOfCurrentIncomingMessage];
            }
            
            if (remainingBytesToProcess + receiveSendToken.receivedMessageBytesDoneCount == receiveSendToken.lengthOfCurrentIncomingMessage)
            {
              _logger.LogInfo("Done receiving {0} bytes, which is the length of the message.",
                              receiveSendToken.lengthOfCurrentIncomingMessage);

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
                // Not a problem. In SocketListener.ProcessReceive we will just call
                // StartReceive to do another receive op to receive more data.
                Buffer.BlockCopy(receiveSendEventArgs.Buffer, receiveSendToken.receiveMessageOffset,
                                 receiveSendToken.theDataHolder.dataMessageReceived,
                                 receiveSendToken.receivedMessageBytesDoneCount, remainingBytesToProcess);
                
                receiveSendToken.receivedMessageBytesDoneCount += remainingBytesToProcess;
            }

            return incomingTcpMessageIsReady;
        }
    }
}
