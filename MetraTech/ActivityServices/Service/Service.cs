using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;
using MetraTech.ActivityServices.Runtime;

namespace MetraTech.ActivityServices.Service
{
  partial class MASService : ServiceBase
  {
    private CMASHost m_MASHost;

    public MASService()
    {
      ServiceName = "MASHost";

      CanHandlePowerEvent = false;
      CanPauseAndContinue = false;
      CanShutdown = false;
      CanStop = true;
    }

    protected override void OnStart(string[] args)
    {
      // Give ourselves seven minutes to get started
      // in repsonse to CORE-2505 
      RequestAdditionalTime(420000);

      m_MASHost = new CMASHost();
      if (!m_MASHost.StartMASHost())
      {
        throw new ApplicationException("Failed to start MAS Host");
      }
    }

    protected override void OnStop()
    {
      // Give ourselves two minues to shut down
      RequestAdditionalTime(120000);

      m_MASHost.StopMASHost();
    }


  }
}
