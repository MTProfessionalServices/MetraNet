using System;
using System.Collections.Generic;
using System.Net.Sockets;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class SocketAsyncEventArgsPool
  /// </summary>
  internal sealed class SocketAsyncEventArgsPool
  {
    readonly Stack<SocketAsyncEventArgs> pool;

    /// <summary>
    /// Initializes a new instance of the <see cref="SocketAsyncEventArgsPool"/> class.
    /// </summary>
    /// <param name="capacity">The capacity.</param>
    /// <remarks></remarks>
    internal SocketAsyncEventArgsPool(Int32 capacity)
    {
      this.pool = new Stack<SocketAsyncEventArgs>(capacity);
    }

    /// <summary>
    /// Gets the count.
    /// </summary>
    /// <remarks></remarks>
    internal Int32 Count
    {
      get { return this.pool.Count; }
    }

    /// <summary>
    /// Pops this instance.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    internal SocketAsyncEventArgs Pop()
    {
      lock (this.pool)
      {
        return this.pool.Count > 0 ? this.pool.Pop() : null;
      }
    }

    /// <summary>
    /// Pushes the specified item.
    /// </summary>
    /// <param name="item">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    internal void Push(SocketAsyncEventArgs item)
    {
      if (item == null)
      {
        throw new ArgumentNullException("item");
      }
      lock (this.pool)
      {
        this.pool.Push(item);
      }
    }
  }
}
