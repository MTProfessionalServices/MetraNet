using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace MetraTech.Messaging.Framework.Worker
{
  public class ControlWorker : BaseWorker
  {
    public WorkerPool<RequestWorker> RequestWorkerPool;
    public WorkerPool<ResponseWorker> ResponseWorkerPool;

    public ControlWorker()
    {
      logger = new Logger("[ControlWorker]");
    }

    public void ControlWorkersThreadStart()
    {
      logger.LogDebug("Control Workers Thread started");
      while (true)
      {
        if (HaltProcessingCallback.IsShuttingDown) break;

        Thread.Sleep(1000);

        //Flush records in repository
        Persistence.IRequestRepository repository = SharedStructures.Repository;
        if (repository != null)
        {
          repository.Flush();
          //Now that we have flushed to disk, requests are preserved so we can acknowledge the receipt of the messages
          RequestWorkerPool.SetAcknowledgeFlag();
          ResponseWorkerPool.SetAcknowledgeFlag();
        }

        //Check to see if we should delete messages in repository
        if (SharedStructures.Configuration.ArchiveRequestInMinutes != 0)
        {
          ArchiveWorker.BeginArchive();
        }

        //Check if there are timed out messages in repository
        TriggerTimeoutCheck();

      }

      logger.LogDebug("Control Workers Thread ended");
    }

    private void TriggerTimeoutCheck()
    {
      if (TimeoutWorker != null)
      {
        TimeoutWorker.BeginTimeout(); //Trigger the timeout event
      }
    }

    public ArchiveWorker ArchiveWorker { get; set; }

    public TimeoutWorker TimeoutWorker { get; set; }
  }
}
