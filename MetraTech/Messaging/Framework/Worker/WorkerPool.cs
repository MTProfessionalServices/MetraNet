using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Threading;
using RabbitMQ;
using RabbitMQ.Client;

namespace MetraTech.Messaging.Framework.Worker
{
  using Configurations;

  public class WorkerPool<T>
    where T : ListenerWorker, new() 
  {
    public Configurations.QueueConfig QueueConfig;
    public Configuration Configuration;

    private int mWorkerCount;
    List<Thread> mWorkerThreadList;
    List<T> mWorkerObjectList = new List<T>();

    public WorkerPool(int workerCount)
    {
      // TODO: Complete member initialization
      this.mWorkerCount = workerCount;
      mWorkerThreadList = new List<Thread>(mWorkerCount);
      mWorkerObjectList = new List<T>(mWorkerCount);
    }

    private void CreateWorker(int i)
    {
      T worker = new T();
      worker.Initialize(i, QueueConfig);
      Thread workerThread = new Thread(new ThreadStart(worker.ReceiveMessagesThreadStart));
      workerThread.Start();
      mWorkerThreadList.Add(workerThread);
      mWorkerObjectList.Add(worker);
    }

    internal void CreateWorkers()
    {
      for (int i = 0; i++ < mWorkerCount; )
        CreateWorker(i);
    }

    public void SetAcknowledgeFlag()
    {
      foreach (T worker in mWorkerObjectList)
      {
        worker.NeedToAcknowledge = true;
      }
    }

    public void Join()
    {
      foreach (Thread thread in mWorkerThreadList)
      {
        thread.Join();
      }
    }
  }
}
