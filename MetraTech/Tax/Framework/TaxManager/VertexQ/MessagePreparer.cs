using System;
using System.Net.Sockets;
using System.Text;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class MessagePreparer
  /// </summary>
  class MessagePreparer
  {
    /// <summary>
    /// Gets the data to send.
    /// </summary>
    /// <param name="e">The <see cref="SocketAsyncEventArgs" /> instance containing the event data.</param>
    internal void GetDataToSend(SocketAsyncEventArgs e)
    {
      DataHoldingUserToken dataHoldingUserToken = (DataHoldingUserToken)e.UserToken;
      DataHolder dataHolder = dataHoldingUserToken.theDataHolder;

      // Determine the length of the message that we will send.
      Int32 lengthOfCurrentOutgoingMessage =
        dataHolder.arrayOfVertexParamsXMLToSend[dataHolder.NumberOfMessagesSent].Length;

      // Convert the message to byte array
      Byte[] arrayOfBytesInMessage =
        Encoding.ASCII.GetBytes(dataHolder.arrayOfVertexParamsXMLToSend[dataHolder.NumberOfMessagesSent]);

      // Create the byte array to send.
      dataHoldingUserToken.dataToSend = new Byte[lengthOfCurrentOutgoingMessage];

      // Now copy the 2 things to the theUserToken.dataToSend.
      Buffer.BlockCopy(arrayOfBytesInMessage, 0, dataHoldingUserToken.dataToSend, 0, lengthOfCurrentOutgoingMessage);

      dataHoldingUserToken.sendBytesRemaining = lengthOfCurrentOutgoingMessage;
      dataHoldingUserToken.bytesSentAlready = 0;
    }
  }
}
