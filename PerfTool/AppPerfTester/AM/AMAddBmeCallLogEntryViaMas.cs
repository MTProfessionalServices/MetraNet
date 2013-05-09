using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using ldperf.Auditing;
using log4net;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.DomainModel.Billing;
using MetraTech.BusinessEntity.Service.ClientProxies;


namespace BaselineGUI
{
    public class AMAddBmeCallLogEntryViaMas : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMAddBmeCallLogEntryViaMas));
        RepositoryService_SaveInstance_Client m_saveInstanceClient;

        public AMAddBmeCallLogEntryViaMas()
        {
            group = "BME";

            name = "addBmeCallLogEntryViaMas";
            fullName = "Add BME Call Log Entry via MAS";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            m_saveInstanceClient = new RepositoryService_SaveInstance_Client();
            m_saveInstanceClient.UserName = "su";
            m_saveInstanceClient.Password = "su123";
            log.DebugFormat("finished RepositoryAccess.Instance.Initialize()");
        }

        public void teardown()
        {
        }

        public void dispose()
        {   
        }

        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();

            int id_acc = Framework.netMeter.pickModifiableAccountID();

            // add a new callLog
            var callLogEntry = new CallLogEntry();
            callLogEntry.CallLogReasonId = 88;
            callLogEntry.CallReasonEntryType = 44;
            callLogEntry.EntityId = id_acc;
            callLogEntry.OccurrenceTime = DateTime.Now;
            m_saveInstanceClient.InOut_dataObject = callLogEntry;

            watch.Restart();
            m_saveInstanceClient.Invoke();
            watch.Stop();

            callLogEntry = m_saveInstanceClient.InOut_dataObject as CallLogEntry;

            statistic.addSample(watch.ElapsedMilliseconds);

        }

    }
}
