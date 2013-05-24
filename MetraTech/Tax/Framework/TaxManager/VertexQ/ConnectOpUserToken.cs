using System;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class ConnectOpUserToken
  /// </summary>
  class ConnectOpUserToken
  {
    internal OutgoingMessageHolder outgoingMessageHolder;
    private readonly Random random = new Random();
    private Int32 id;

    /// <summary>
    /// Initializes a new instance of the <see cref="ConnectOpUserToken" /> class.
    /// </summary>
    public ConnectOpUserToken()
    {
      id = random.Next(0, Int32.MaxValue);
    }

    /// <summary>
    /// Gets the token id.
    /// </summary>
    /// <value>The token id.</value>
    public Int32 TokenId
    {
      get { return id; }
    }
  }
}