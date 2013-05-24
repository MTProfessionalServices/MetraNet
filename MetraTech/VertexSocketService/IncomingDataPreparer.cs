using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using MetraTech;

namespace VertexSocketService
{
  /// <summary>
  /// 
  /// </summary>
  /// <remarks></remarks>
  class IncomingDataPreparer
  {
    readonly Vertex _vertex = new Vertex();
    private DataHolder _dataHolder;
    private readonly SocketAsyncEventArgs _socketAsyncEventArgsObject;
    private static readonly Logger _logger = new Logger("[VertexSocketService.IncomingDataPreparer]");

    /// <summary>
    /// Initializes a new instance of the <see cref="IncomingDataPreparer"/> class.
    /// </summary>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    public IncomingDataPreparer(SocketAsyncEventArgs e)
    {
      this._socketAsyncEventArgsObject = e;
    }

    /// <summary>
    /// Gets the remote endpoint.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    private EndPoint GetRemoteEndpoint()
    {
      return this._socketAsyncEventArgsObject.AcceptSocket.RemoteEndPoint;
    }

    /// <summary>
    /// Handles the received data.
    /// </summary>
    /// <param name="incomingDataHolder">The incoming data holder.</param>
    /// <param name="socketAsyncEventArgsObject">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    internal DataHolder HandleReceivedData(DataHolder incomingDataHolder, SocketAsyncEventArgs socketAsyncEventArgsObject)
    {
      DataHoldingUserToken receiveToken = (DataHoldingUserToken)socketAsyncEventArgsObject.UserToken;
      _dataHolder = incomingDataHolder;
      _dataHolder.sessionId = receiveToken.SessionId;
      _dataHolder.remoteEndpoint = this.GetRemoteEndpoint();

      // Wrapping the byte[] into a string
      _dataHolder.dataMessageReceived = Encoding.Convert(Encoding.GetEncoding("iso-8859-1"), Encoding.UTF8,
                                                           _dataHolder.dataMessageReceived);
      string tempString = Encoding.UTF8.GetString(_dataHolder.dataMessageReceived, 0,
                                                  _dataHolder.dataMessageReceived.Length);

      string vertexResultString;
      try
      {
        vertexResultString = _vertex.CalculateTaxes(tempString);
      }
      catch (Exception ex)
      {
        _logger.LogException("Caught exception while trying to calculate taxes.", ex);
        throw;
      }
      // Convert string to byte array
      _dataHolder.dataMessageReceived = Encoding.ASCII.GetBytes(vertexResultString);

      return _dataHolder;
    }
  }
}
