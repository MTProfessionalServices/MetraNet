using System;
using System.Collections.Generic;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class DataHolder
  /// </summary>
  public class DataHolder
  {
    // We'll just send a string message. And have one or more messages, so
    // we need an array.
    internal string[] arrayOfVertexParamsXMLToSend;

    /// <summary>
    /// 
    /// </summary>
    internal Byte[] dataMessageReceived;

    // Since we are creating a List<T> of message data, we'll
    // need to decode it later, if we want to read a string.
    internal List<byte[]> listOfMessagesReceived = new List<byte[]>();

    /// <summary>
    /// Gets or sets the number of messages sent.
    /// </summary>
    /// <value>The number of messages sent.</value>
    /// <remarks></remarks>
    public int NumberOfMessagesSent { get; set; }

    // Write the array of messages to send
    internal void PutMessagesToSend(string[] theArrayOfMessagesToSend)
    {
      this.arrayOfVertexParamsXMLToSend = theArrayOfMessagesToSend;
    }
  }
}

