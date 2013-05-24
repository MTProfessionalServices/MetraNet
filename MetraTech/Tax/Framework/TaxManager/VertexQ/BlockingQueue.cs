using System.Collections.Generic;
using System.Threading;

namespace Framework.TaxManager.VertexQ
{
  // NOTE : The only reason to use a custom queue is for performance here
  // Queue+lock performs better than a SynchronizedQueue or ConcurrentQueue
  // http://stackoverflow.com/questions/4818202/is-queue-synchronized-faster-than-using-a-lock
  /// <summary>
  /// 
  /// </summary>
  /// <typeparam name="T"></typeparam>
  /// <remarks></remarks>
  class BlockingQueue<T>
  {
    private readonly Queue<T> _dataQueue;

    /// <summary>
    /// Initializes a new instance of the <see cref="BlockingQueue{T}" /> class.
    /// </summary>
    /// <param name="theQueueOfMessages">The queue of messages.</param>
    public BlockingQueue(Queue<T> theQueueOfMessages)
    {
      this._dataQueue = theQueueOfMessages;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="BlockingQueue{T}" /> class.
    /// </summary>
    public BlockingQueue()
    {
      this._dataQueue = new Queue<T>();
    }
    
    /// <summary>
    /// Pushes the specified item.
    /// </summary>
    /// <param name="item">The item.</param>
    /// <remarks></remarks>
    public void Enqueue(T item)
    {
      lock (_dataQueue)
      {
        _dataQueue.Enqueue(item);
        if (_dataQueue.Count == 1)
        {
          // This means we have gone from empty stack to stack with 1 item.
          // So, wake Pop().
          Monitor.PulseAll(_dataQueue);
        }
      }
    }

    /// <summary>
    /// Dequeues this instance.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    public T Dequeue()
    {
      lock (_dataQueue)
      {
        if (_dataQueue.Count == 0)
        {
          //Stack is empty. Wait until Pulse is received from Push().
          Monitor.Wait(_dataQueue);
        }
        T item = _dataQueue.Dequeue();
        return item;
      }
    }

    /// <summary>
    /// Peek.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    public T Peek()
    {
      lock (_dataQueue)
      {
        if (_dataQueue.Count == 0)
        {
          // Stack is empty. Wait until Pulse is received from Push().
          Monitor.Wait(_dataQueue);
        }
        T item = _dataQueue.Peek();
        return item;
      }
    }

    /// <summary>
    /// Dequeues this instance.
    /// </summary>
    /// <returns></returns>
    /// <remarks></remarks>
    public int Count()
    {
      lock (_dataQueue)
      {
        return _dataQueue.Count;
      }
    }
  }
}


