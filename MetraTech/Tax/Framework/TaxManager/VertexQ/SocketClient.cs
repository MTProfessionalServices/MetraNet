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
    private ManualResetEvent connectDone = new ManualResetEvent(false);
    private ManualResetEvent sendDone = new ManualResetEvent(false);
    private ManualResetEvent receiveDone = new ManualResetEvent(false);

    // The response from the remote device.
    private String response = String.Empty;

    public SocketClient(Logger logger, VertexQConfiguration configuration)
    {
      _logger = logger;
      _configuration = configuration;
      _logger.LogInfo("CalcVertexTaxes.AsynchronousClient constructor called with Port - " +
                      _configuration.m_Port +
                      " And Server - " + 
                      _configuration.m_ServerAddress);
    }

    private string StartClient(string xmlStr)
    {
      // Connect to a remote device.
      try
      {
        _logger.LogDebug("VertexTaxes.AsynchronousClient StartClient Method");
        // Establish the remote endpoint for the socket.                                
        //IPHostEntry ipHostInfo = Dns.GetHostEntry(Dns.GetHostName());
        IPHostEntry ipHostInfo = Dns.GetHostEntry(_configuration.m_ServerAddress);
        IPAddress ipAddress = ipHostInfo.AddressList[0];
        var remoteEP = new IPEndPoint(ipAddress, _configuration.m_Port);

        // Create a TCP/IP socket
        Socket client = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        connectDone.Reset();
        // Connect to the remote endpoint.
        client.BeginConnect(remoteEP, new AsyncCallback(ConnectCallback), client);
        connectDone.WaitOne();

        if ("REMOTESOCKETERROR".Equals(_excpMessage))
        {
          // Release the socket.                        
          client.Close();
          return _excpMessage;
        }

        // Send data to the remote device.
        sendDone.Reset();
        Send(client, xmlStr);
        sendDone.WaitOne();

        // Receive the response from the remote device.
        receiveDone.Reset();
        Receive(client);
        receiveDone.WaitOne();
        _logger.LogDebug(String.Format(
          "CalcVertexTaxes.AsynchronousClient.StartClient Response received : {0}", response));

        // Release the socket.
        client.Shutdown(SocketShutdown.Both);
        client.Close();
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.StartClient Exception : " + e.Message);
        //throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.StartClient Exception : {0}", e.Message));
      }
      return response;
    }

    private void ConnectCallback(IAsyncResult ar)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient ConnectCallback Method");
        // Retrieve the socket from the state object.
        Socket client = (Socket) ar.AsyncState;
        bool Errored = client.Poll(100, SelectMode.SelectError);
        if (!Errored)
        {
          // Complete the connection.
          client.EndConnect(ar);
          _logger.LogDebug(
            String.Format("CalcVertexTaxes.AsynchronousClient.ConnectCallback Socket connected to {0}",
                          client.RemoteEndPoint.ToString()));

          // Signal that the connection has been made.
          connectDone.Set();
        }
        else
        {
          _excpMessage = "REMOTESOCKETERROR";
          connectDone.Set();
        }

      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.ConnectCallback Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.ConnectCallback Exception : {0}",
                                          e.Message));
      }
    }

    private void Receive(Socket client)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient Receive Method");
        // Create the state object.
        var state = new StateObject();
        state.workSocket = client;

        // Begin receiving the data from the remote device.
        client.BeginReceive(state.buffer, 0, StateObject.BufferSize, 0, new AsyncCallback(ReceiveCallback),
                            state);
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
        StateObject state = (StateObject) ar.AsyncState;
        Socket client = state.workSocket;

        // Read data from the remote device.
        int bytesRead = client.EndReceive(ar);

        if (bytesRead > 0)
        {
          // There might be more data, so store the data received so far.
          state.sb.Append(Encoding.ASCII.GetString(state.buffer, 0, bytesRead));

          // Get the rest of the data.
          client.BeginReceive(state.buffer, 0, StateObject.BufferSize, 0, new AsyncCallback(ReceiveCallback),
                              state);
        }
        else
        {
          // All the data has arrived; put it in response.
          if (state.sb.Length > 1)
          {
            response = state.sb.ToString();
          }
          // Signal that all bytes have been received.
          receiveDone.Set();
        }
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.ReceiveCallback Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.ReceiveCallback : Exception {0}",
                                          e.Message));
      }
    }

    private void Send(Socket client, String data)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient Send Method");
        // Convert the string data to byte data using ASCII encoding.
        byte[] byteData = Encoding.ASCII.GetBytes(data);

        // Begin sending the data to the remote device.
        client.BeginSend(byteData, 0, byteData.Length, 0, new AsyncCallback(SendCallback), client);
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.Send Exception : " + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.Send : Exception : {0} ",
                                          e.Message));
      }
    }

    private void SendCallback(IAsyncResult ar)
    {
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient SendCallback Method");
        // Retrieve the socket from the state object.
        Socket client = (Socket) ar.AsyncState;

        // Complete sending the data to the remote device.
        int bytesSent = client.EndSend(ar);
        _logger.LogDebug(
          String.Format("CalcVertexTaxes.AsynchronousClient.SendCallback Sent {0} bytes to server.", bytesSent));

        // Signal that all bytes have been sent.
        sendDone.Set();
      }
      catch (Exception e)
      {
        _logger.LogWarning("CalcVertexTaxes.AsynchronousClient.SendCallback Exception :" + e.Message);
        throw new Exception(string.Format("CalcVertexTaxes.AsynchronousClient.SendCallback Exception : {0} ",
                                          e.Message));
      }
    }

    public string InitiateTransaction(string CallType, string xmlStr)
    {
      string returnXmlStr = null;
      try
      {
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient InitiateTransaction Method");
        _excpMessage = null;
        returnXmlStr = StartClient(xmlStr);
        _logger.LogDebug("CalcVertexTaxes.AsynchronousClient.InitiateTransaction  Port :" + _configuration.m_Port +
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
    public Socket workSocket = null;
    // Size of receive buffer.
    public const int BufferSize = 2048;
    // Receive buffer.
    public byte[] buffer = new byte[BufferSize];
    // Received data string.
    public StringBuilder sb = new StringBuilder();
  }
}