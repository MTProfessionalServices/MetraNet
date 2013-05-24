using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.ServiceProcess;
using System.Text;

namespace MetraTech.MetraPay
{
    public partial class CMetraPayService : ServiceBase
    {
        CMetraPayHost m_Host;

        public CMetraPayService()
        {

            CanHandlePowerEvent = false;
            CanPauseAndContinue = false;
            CanShutdown = false;
            CanStop = true;
        }

        protected override void OnStart(string[] args)
        {
            // Give ourselves two minutes to get started
            RequestAdditionalTime(120000);

            m_Host = new CMetraPayHost();

            if(!m_Host.StartHost())
            {
                throw new ApplicationException("Failed to start MetraPay Host");
            }
        }

        protected override void OnStop()
        {
            // Give ourselves two minutes to get started
            RequestAdditionalTime(120000);

            m_Host.StopHost();
        }
    }
}
