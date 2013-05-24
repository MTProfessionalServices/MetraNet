using System;
using System.Collections.Generic;
using System.Globalization;
using System.Net.Sockets;

namespace VertexSocketService
{
  /// <summary>
  /// This class creates a single large buffer which can be divided up 
  /// and assigned to SocketAsyncEventArgs objects for use with each 
  /// socket I/O operation.  
  /// This enables buffers to be easily reused and guards against 
  /// fragmenting heap memory. 
  /// This buffer is a byte array which the Windows TCP buffer can copy its data to.
  /// </summary>
  /// <remarks></remarks>
  class BufferManager
  {
    // The total number of bytes controlled by the buffer pool
    public readonly Int32 _totalBytesInBufferBlock;

    // Byte array maintained by the Buffer Manager.
    byte[] _bufferBlock;
    public readonly Stack<int> _freeIndexPool;
    Int32 _currentIndex;
    readonly Int32 _bufferBytesAllocatedForEachSocketAsyncEventArgs;

    /// <summary>
    /// Initializes a new instance of the <see cref="BufferManager"/> class.
    /// </summary>
    /// <param name="totalBytes">The total bytes.</param>
    /// <param name="totalBufferBytesInEachSocketAsyncEventArgsObject">The total buffer bytes in each socket async event args object.</param>
    /// <remarks></remarks>
    public BufferManager(Int32 totalBytes, Int32 totalBufferBytesInEachSocketAsyncEventArgsObject)
    {
      if (totalBytes <= 0)
        throw new ArgumentException("Invalid value for Total bytes for Buffer",
                                    totalBytes.ToString(CultureInfo.InvariantCulture));

      if (totalBufferBytesInEachSocketAsyncEventArgsObject <= 0)
        throw new ArgumentException("Invalid value for TotalBufferBytesInEachSocketAsyncEventArgsObject",
                                    totalBufferBytesInEachSocketAsyncEventArgsObject.ToString(
                                      CultureInfo.InvariantCulture));
      _totalBytesInBufferBlock = totalBytes;
      this._currentIndex = 0;
      this._bufferBytesAllocatedForEachSocketAsyncEventArgs = totalBufferBytesInEachSocketAsyncEventArgsObject;
      this._freeIndexPool = new Stack<int>();
    }

    /// <summary>
    /// Allocates buffer space used by the buffer pool.
    /// </summary>
    /// <remarks></remarks>
    internal void InitBuffer()
    {
      // Create one large buffer block.
      this._bufferBlock = new byte[_totalBytesInBufferBlock];
    }

    /// <summary>
    /// Divide that one large buffer block out to each SocketAsyncEventArg object.
    /// Assign a buffer space from the buffer block to the 
    /// specified SocketAsyncEventArgs object.
    /// Returns true if the buffer was successfully set, else false
    /// </summary>
    /// <param name="args">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <returns></returns>
    /// <remarks></remarks>
    internal bool SetBuffer(SocketAsyncEventArgs args)
    {
      if (null == args)
        throw new ArgumentNullException("args");

      if (this._freeIndexPool.Count > 0)
      {
        // This if-statement is only true if you have called the FreeBuffer
        // method previously, which would put an offset for a buffer space 
        // back into this stack.
        args.SetBuffer(this._bufferBlock, this._freeIndexPool.Pop(), this._bufferBytesAllocatedForEachSocketAsyncEventArgs);
      }
      else
      {
        // Inside this else-statement is the code that is used to set the 
        // buffer for each SocketAsyncEventArgs object when the pool of SocketAsyncEventArgs objects is built
        // in the Init method.
        if ((_totalBytesInBufferBlock - this._bufferBytesAllocatedForEachSocketAsyncEventArgs) < this._currentIndex)
        {
          return false;
        }
        args.SetBuffer(this._bufferBlock, this._currentIndex, this._bufferBytesAllocatedForEachSocketAsyncEventArgs);
        this._currentIndex += this._bufferBytesAllocatedForEachSocketAsyncEventArgs;
      }
      return true;
    }
     
    /// <summary>
    /// Removes the buffer from a SocketAsyncEventArg object. This frees the
    /// buffer back to the buffer pool. Used when there is an exception and 
    /// you need to destroy and reclaim the buffer space used by the 
    /// current SocketAsyncEventArgs object.
    /// </summary>
    /// <param name="args">The <see cref="System.Net.Sockets.SocketAsyncEventArgs"/> instance containing the event data.</param>
    /// <remarks></remarks>
    internal void FreeBuffer(SocketAsyncEventArgs args)
    {
      this._freeIndexPool.Push(args.Offset);
      args.SetBuffer(null, 0, 0);
    }
  }
}
