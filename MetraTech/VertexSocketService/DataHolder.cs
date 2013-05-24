using System;
using System.Net;

namespace VertexSocketService
{
  /// <summary>
  /// Used to hold data. 
  /// </summary>
  /// <remarks></remarks>
  class DataHolder
  {
    /// <summary>
    /// This holds the data byte array that stores the data transmitted in the buffer for 
    /// each SocketAsyncEventArgs object
    /// </summary>
    internal Byte[] dataMessageReceived;

    /// <summary>
    /// 
    /// </summary>
    internal Int64 sessionId;

    /// <summary>
    /// 
    /// </summary>
    internal EndPoint remoteEndpoint;
  }
}
