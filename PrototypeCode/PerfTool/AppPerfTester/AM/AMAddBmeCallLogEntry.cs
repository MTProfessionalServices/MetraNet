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
using MetraTech.BusinessEntity.DataAccess.Persistence;


namespace BaselineGUI
{
    public class AMAddBmeCallLogEntry : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMAddBmeCallLogEntry));

        public AMAddBmeCallLogEntry()
        {
            group = "BME";

            name = "addBmeCallLogEntry";
            fullName = "Add BME Call Log Entry";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            RepositoryAccess.Instance.Initialize();
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

            IStandardRepository standardRepository = RepositoryAccess.Instance.GetRepository();

            // Determine how many callLogs exist for this accountId so that we
            // can make sure the count increases after this insert
            var callLogsForAccount = new MetraTech.ActivityServices.Common.MTList<CallLogEntry>();
            callLogsForAccount.Filters.Add(
                new MetraTech.ActivityServices.Common.MTFilterElement("EntityId",
                MetraTech.ActivityServices.Common.MTFilterElement.OperationType.Equal, id_acc));
            standardRepository.LoadInstances(ref callLogsForAccount);
            int numCallLogsBefore = callLogsForAccount.Items.Count;

            // add a new callLog
            var callLogEntry = new CallLogEntry();
            callLogEntry.CallLogReasonId = 77;
            callLogEntry.CallReasonEntryType = 33;
            callLogEntry.EntityId = id_acc;
            callLogEntry.OccurrenceTime = DateTime.Now;

            watch.Restart();
            callLogEntry.Save();
            watch.Stop();

            var callLogsForAccountAfter = new MetraTech.ActivityServices.Common.MTList<CallLogEntry>();
            callLogsForAccountAfter.Filters.Add(
                new MetraTech.ActivityServices.Common.MTFilterElement("EntityId",
                MetraTech.ActivityServices.Common.MTFilterElement.OperationType.Equal, id_acc));
            standardRepository.LoadInstances(ref callLogsForAccountAfter);
            int numCallLogsAfter = callLogsForAccountAfter.Items.Count;

            if (numCallLogsAfter <= numCallLogsBefore)
            {
                throw new InvalidOperationException(
                    String.Format("expected numCallLogsAfter {0}, to be greater than numCallLogsBefore {1}",
                    numCallLogsAfter, numCallLogsBefore));
            }

            statistic.addSample(watch.ElapsedMilliseconds);

        }

    }
}
