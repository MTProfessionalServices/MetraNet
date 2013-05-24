using System;
using System.Collections.Generic;
using System.Net.Sockets;

// TODO : Create id for pool

namespace VertexSocketService
{
  /// <summary>
  /// SocketAsyncEventArgsPool 
  /// </summary>
  /// <remarks></remarks>
  internal sealed class SocketAsyncEventArgsPool
  {
    // Pool of reusable SocketAsyncEventArgs objects.        
    readonly Stack<SocketAsyncEventArgs> _pool;

    // Initializes the object pool to the specified size.
    // "capacity" = Maximum number of SocketAsyncEventArgs objects
    internal SocketAsyncEventArgsPool(Int32 capacity)
    {
      this._pool = new Stack<SocketAsyncEventArgs>(capacity);
    }

    // The number of SocketAsyncEventArgs instances in the pool.         
    internal Int32 Count
    {
      get { return this._pool.Count; }
    }

    // Removes a SocketAsyncEventArgs instance from the pool.
    // returns SocketAsyncEventArgs removed from the pool.
    internal SocketAsyncEventArgs Pop()
    {
      lock (this._pool)
      {
        return this._pool.Pop();
      }
    }

    // Add a SocketAsyncEventArg instance to the pool. 
    // "item" = SocketAsyncEventArgs instance to add to the pool.
    internal void Push(SocketAsyncEventArgs item)
    {
      if (item == null)
      {
        throw new ArgumentNullException("item");
      }
      lock (this._pool)
      {
        this._pool.Push(item);
      }
    }
  }
}
