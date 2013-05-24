using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;


namespace MetraTech.Messaging.Framework.Worker
{
  using Persistence;

  public class ArchiveWorker : BaseWorker
  {
    //Create the event/signal that the archive worker will wait on/check for indication it should
    //check for and archive (delete) old messages. Initially not signalled.
    private EventWaitHandle mre = new EventWaitHandle(false, EventResetMode.AutoReset);

    public ArchiveWorker()
    {
      logger = new Logger("[ArchiveWorker]");
    }

    public void ArchiveWorkerThreadStart()
    {
      logger.LogDebug("Archive Workers Thread started");
      while (true)
      {
        if (HaltProcessingCallback.IsShuttingDown) break;
        if (mre.WaitOne(1000))
        {
          ArchiveOldMessages();
        }
      }
      logger.LogDebug("Archive Workers Thread ended");
    }

    private void ArchiveOldMessages()
    {
      int ArchiveMinutes = SharedStructures.Configuration.ArchiveRequestInMinutes;
      DateTime archiveDate = MetraTime.Now.AddMinutes(-ArchiveMinutes);
      logger.LogTrace("Archiving messages older than {0} [Start]...", archiveDate);
      try
      {
        SharedStructures.Repository.ArchiveOldRequests(archiveDate);
        logger.LogTrace("Archiving messages older than {0} [End]", archiveDate);
      }
      catch (Exception ex)
      {
        logger.LogException("Error while ArchivingOldRequests", ex);
      }
    }

    public void BeginArchive()
    {
      mre.Set();
    }

  }
}
