using System;
using System.Collections.Generic;
using System.Net.Sockets;

namespace Framework.TaxManager.VertexQ
{
  /// <summary>
  /// Class BufferManager
  /// </summary>
  public class BufferManager
  {
    readonly Int32 _numBytes;
    byte[] _buffer;
    readonly Stack<int> _freeIndexPool;
    Int32 _currentIndex;
    readonly Int32 _bufferSize;

    /// <summary>
    /// Initializes a new instance of the <see cref="BufferManager"/> class.
    /// </summary>
    /// <param name="totalBytes">The total bytes.</param>
    /// <param name="bufferSize">Size of the buffer.</param>
    /// <remarks></remarks>
    public BufferManager(int totalBytes, Int32 bufferSize)
    {
      _numBytes = totalBytes;
      _currentIndex = 0;
      _bufferSize = bufferSize;
      _freeIndexPool = new Stack<int>();
    }

    /// <summary>
    /// Initializes the buffer.
    /// </summary>
    /// <remarks></remarks>
    internal void InitBuffer()
    {
      _buffer = new byte[_numBytes];
    }

    /// <summary>
    /// Sets the buffer.
    /// </summary>
    /// <param name="args">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    internal bool SetBuffer(SocketAsyncEventArgs args)
    {
      if(null == args)
        throw new ArgumentNullException("args");

      if (_freeIndexPool.Count > 0)
      {
        args.SetBuffer(_buffer, _freeIndexPool.Pop(), _bufferSize);
      }
      else
      {
        if ((_numBytes - _bufferSize) < _currentIndex)
        {
          return false;
        }
        args.SetBuffer(_buffer, _currentIndex, _bufferSize);
        _currentIndex += _bufferSize;
      }
      return true;
    }

    /// <summary>
    /// Frees the buffer.
    /// </summary>
    /// <param name="args">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    internal void FreeBuffer(SocketAsyncEventArgs args)
    {
      _freeIndexPool.Push(args.Offset);
      args.SetBuffer(null, 0, 0);
    }
  }
}

