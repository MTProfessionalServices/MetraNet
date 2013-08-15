using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using MetraTech;

namespace Framework.TaxManager.VertexQ
{
  public class SocketClient
  {
    #region Member Variables

    private readonly VertexQConfiguration _configuration;
    private readonly Logger _logger;
    private string _excpMessage;

    #endregion

    // ManualResetEvent instances signal completion.
    private readonly ManualResetEvent _connectDone = new ManualResetEvent(false);
    private readonly ManualResetEvent _sendDone = new ManualResetEvent(false);
    private readonly ManualResetEvent _receiveDone = new ManualResetEvent(false);

    // The response from the remote device.
    private String _response = String.Empty;

    public SocketClient(Logger logger, VertexQConfiguration configuration)
    {
      _logger = logger;
      _configuration = configuration;
      _logger.LogInfo("CalcVertexTaxes.AsynchronousClient constructor called with Port - " +
                      _configuration.Port +
                      " And Server - " + 
                      _configuration.ServerAddress);
    }

    private string StartClient(string xmlStr)
    {
      // Connect to a remote device.
      try
      {
        _logger.LogDebug("VertexTaxes.AsynchronousClient StartClient Method");
        // Establish the remote endpoint for the socket.                                
        //IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName());
        var ipHostInfo = Dns.GetHostEntry(_configuration.ServerAddress);
        var ipAddress = ipHostInfo.AddressList[0];
        var remoteEp = new IPEndPoint(ipAddress, _configuration.Port);

        // Create a TCP/IP socket
        var client = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        _connectDone.Reset();
        // Connect to the remote endpoint.
        client.BeginConnect(remoteEp, ConnectCallback, client);
        _connectDone.WaitOne();

        if ("REMOTESOCKETERROR".Equals(_excpMessage))
        {
          // Release the socket.                        
          client.Close();
          return _excpMessage;
        }

        // Send data to the remote device.
        _sendDone.Reset();
        Send(client, xmlStr);
        _sendDone.WaitOne();

        // Receive the response from the remote device.
        _receiveDone.Reset();
        Receive(client);
        _receiveDone.WaitOne();
        _logger.LogDebug(String.Format(
          "CalcVertexTaxes.AsynchronousClient.StartClient Response received : {0}", _response));

        // Release the socket.
        client.Shutdown(SocketShutdown.Both);
        client.Close();
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.StartClient Exception : " + e.Message);
        //throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.StartClient Exception : {0}", e.Message));
      }
      return _response;
    }

    private void ConnectCallback(IAsyncResult ar)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient ConnectCallback Method");
        // Retrieve the socket from the state object.
        var client = (Socket) ar.AsyncState;
        var errored = client.Poll(100, SelectMode.SelectError);
        if (!errored)
        {
          // Complete the connection.
          client.EndConnect(ar);
          _logger.LogDebug(
            String.Format("CalcVertexTaxes.AsynchronousClient.ConnectCallback Socket connected to {0}", client.RemoteEndPoint));

          // Signal that the connection has been made.
          _connectDone.Set();
        }
        else
        {
          _excpMessage = "REMOTESOCKETERROR";
          _connectDone.Set();
        }

      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.ConnectCallback Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.ConnectCallback Exception : {0}",
                                          e.Message));
      }
    }

    #region Receive Data
    private void Receive(Socket client)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient Receive Method");
        // Create the state object.
        var state = new StateObject(_configuration.BufferSize, client);

        // Begin receiving the data from the remote device.
        client.BeginReceive(state.Buffer, 0, _configuration.BufferSize, 0, ReceiveCallback, state);
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.Receive Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.ConnectCallback Exception : {0}",
                                          e.Message));
      }
    }

    private void ReceiveCallback(IAsyncResult ar)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient ReceiveCallback Method");
        // Retrieve the state object and the client socket from the asynchronous state object.
        var state = (StateObject) ar.AsyncState;
        var client = state.WorkSocket;

        // Read data from the remote device.
        var bytesRead = client.EndReceive(ar);

        if (bytesRead > 0)
        {
          // There might be more data, so store the data received so far.
          state.Sb.Append(Encoding.ASCII.GetString(state.Buffer, 0, bytesRead));
          _response = state.Sb.ToString();
          if (_response.Contains("</Success>") || _response.Contains("</Error>"))
            _receiveDone.Set();
          else
            // Get the rest of the data.
            client.BeginReceive(state.Buffer, 0, _configuration.BufferSize, 0, ReceiveCallback, state);
        }
        else
        {
          // All the data has arrived; put it in response.
          if (state.Sb.Length > 1)
          {
            _response = state.Sb.ToString();
          }
          // Signal that all bytes have been received.
          _receiveDone.Set();
        }
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.ReceiveCallback Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.ReceiveCallback : Exception {0}",
                                          e.Message));
      }
    }
    #endregion

    #region Send Data
    private void Send(Socket client, String data)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient Send Method");
        // Convert the string data to byte data using ASCII encoding.
        var byteData = Encoding.ASCII.GetBytes(data);

        // Begin sending the data to the remote device.
        client.BeginSend(byteData, 0, byteData.Length, 0, SendCallback, client);
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.Send Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.Send : Exception : {0} ", e.Message));
      }
    }

    private void SendCallback(IAsyncResult ar)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient SendCallback Method");

        // Retrieve the socket from the state object.
        var client = (Socket) ar.AsyncState;

        // Complete sending the data to the remote device.
        var bytesSent = client.EndSend(ar);
        _logger.LogDebug(String.Format("CalcVertexTaxes.AsynchronousClient.SendCallback Sent {0} bytes to server.", bytesSent));

        // Signal that all bytes have been sent.
        _sendDone.Set();
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.SendCallback Exception :" + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.SendCallback Exception : {0} ",
                                          e.Message));
      }
    }
    #endregion

    public string InitiateTransaction(string CallType, string xmlStr)
    {
      string returnXmlStr;
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient InitiateTransaction Method");
        _excpMessage = null;
        returnXmlStr = StartClient(xmlStr);
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient.InitiateTransaction  Port :" + _configuration.Port +
                         " - Call to " + CallType + " Completed");
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.InitiateTransaction Exception :" + e.Message);
        throw new Exception(
          string.Format("CalcVertexTaxes.AsynchronousClient.InitiateTransaction Exception : {0} ", e.Message));
      }
      return returnXmlStr;
    }
  }

  public class StateObject
  {
    // Client socket.
    public Socket WorkSocket = null;
    // Receive buffer.
    public byte[] Buffer;
    // Received data string.
    public StringBuilder Sb = new StringBuilder();

    public StateObject(int buferSize, Socket workSoket)
    {
      Buffer = new byte[buferSize];
      WorkSocket = workSoket;
    }
  }
}