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
    public class AMRetrieveBmeCallLogEntriesForAccount : AppMethodBase, AppMethodI
    {
        Statistic statistic;

        public AMRetrieveBmeCallLogEntriesForAccount()
        {
            group = "BME";

            name = "RetrieveBmeCallLogEntriesForAccount";
            fullName = "Retrieve BME Call Log Entries For Account";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            RepositoryAccess.Instance.Initialize();
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

            var callLogsForAccount = new MetraTech.ActivityServices.Common.MTList<CallLogEntry>();

            callLogsForAccount.PageSize = 10;
            callLogsForAccount.CurrentPage = 1;
            callLogsForAccount.Filters.Add(
                new MetraTech.ActivityServices.Common.MTFilterElement("EntityId",
                MetraTech.ActivityServices.Common.MTFilterElement.OperationType.Equal, id_acc));

            watch.Restart();
            standardRepository.LoadInstances(ref callLogsForAccount);
            watch.Stop();

            statistic.addSample(watch.ElapsedMilliseconds);

        }

    }
}
