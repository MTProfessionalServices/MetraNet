using System.Net.Sockets;


namespace VertexSocketService
{
  /// <summary>
  /// 
  /// </summary>
  class Mediator
  {
    private readonly IncomingDataPreparer _incomingDataPreparer;
    private readonly OutgoingDataPreparer _outgoingDataPreparer;
    private DataHolder _dataHolder;
    private readonly SocketAsyncEventArgs _socketAsyncEventArgsObject;

    /// <summary>
    /// Initializes a new instance of the <see cref="Mediator"/> class.
    /// </summary>
    /// <param name="e">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    public Mediator(SocketAsyncEventArgs e)
    {
      this._socketAsyncEventArgsObject = e;
      this._incomingDataPreparer = new IncomingDataPreparer(_socketAsyncEventArgsObject);
      this._outgoingDataPreparer = new OutgoingDataPreparer();
    }

    /// <summary>
    /// Handles the data.
    /// </summary>
    /// <param name="incomingDataHolder">The incoming data holder.</param>
    /// <remarks></remarks>
    internal void HandleData(DataHolder incomingDataHolder)
    {
      _dataHolder = _incomingDataPreparer.HandleReceivedData(incomingDataHolder, this._socketAsyncEventArgsObject);
    }

    /// <summary>
    /// Prepares the outgoing data.
    /// </summary>
    /// <remarks></remarks>
    internal void PrepareOutgoingData()
    {
      // This data holder will have the tax results xml 
      _outgoingDataPreparer.PrepareOutgoingData(_socketAsyncEventArgsObject, _dataHolder);
    }

    /// <summary>
    /// Gives back the socketasynceventargs object.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    internal SocketAsyncEventArgs GiveBack()
    {
      return _socketAsyncEventArgsObject;
    }
  }
}
