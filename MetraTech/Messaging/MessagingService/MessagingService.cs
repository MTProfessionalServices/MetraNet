using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using MetraTech.Messaging.Framework;

namespace MetraTech.Messaging.MessagingService
{
  public class MessagingService : ServiceBase
  {
    MessageProcessor processor = null;

    public MessagingService()
    {
      //InitializeComponent();
      ServiceName = "MessagingServer";

      CanHandlePowerEvent = false;
      CanPauseAndContinue = false;
      CanShutdown = false;
      CanStop = true;
    }

    protected override void OnStart(string[] args)
    {
      //Debugger.Launch();
      try
      {
        processor = new MessageProcessor();
        processor.Start();
      }
      catch (Exception ex)
      {
        Logger logger = new Logger("[MessagingService]");
        logger.LogException("Exception starting message processor", ex);
        ExitCode = 1;
        throw;
      }
    }

    protected override void OnStop()
    {
      try
      {
        if (processor != null)
        {
          processor.Stop();
        }
      }
      catch (Exception ex)
      {
        Logger logger = new Logger("[MessagingService]");
        logger.LogException("Exception stopping message processor", ex);
        ExitCode = 1;
        throw;
      }
    }
  }
}
