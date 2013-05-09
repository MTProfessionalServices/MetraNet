using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using MetraTech.BusinessEntity.DataAccess.Metadata;
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
    public class AMRetrieveBmeCallLogEntryViaMasTelmore : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMRetrieveBmeCallLogEntryViaMasTelmore));
        RepositoryService_LoadInstances_Client m_saveInstanceClient;

        public AMRetrieveBmeCallLogEntryViaMasTelmore()
        {
            group = "BME";

            name = "retrievedBmeCallLogEntryViaMasTelmore";
            fullName = "Retrieve BME Call Log Entry via MAS Telmore";
            statistic = useStatistic(name);

            commands.Add("go", cmdGo);
        }

        public void setup()
        {
            m_saveInstanceClient = new RepositoryService_LoadInstances_Client();
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

            int idAcc1 = Framework.netMeter.pickModifiableAccountID();
            int idAcc2 = Framework.netMeter.pickModifiableAccountID();
            int idAcc3 = Framework.netMeter.pickModifiableAccountID();
            int idAcc4 = Framework.netMeter.pickModifiableAccountID();
            int idAcc5 = Framework.netMeter.pickModifiableAccountID();

            MTList<DataObject> resultList = new MTList<DataObject>();

            resultList.CurrentPage = 1;
            resultList.PageSize = 10;
            resultList.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, idAcc1));
            resultList.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, idAcc2));
            resultList.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, idAcc3));
            resultList.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, idAcc4));
            resultList.Filters.Add(new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, idAcc5));
            m_saveInstanceClient.In_entityName = typeof(CallLogEntry).FullName;
            m_saveInstanceClient.InOut_dataObjects = resultList;

            watch.Restart();
            m_saveInstanceClient.Invoke();
            watch.Stop();

            resultList = m_saveInstanceClient.InOut_dataObjects as MTList<DataObject>;

            log.DebugFormat("resultList.Items.Count={0}", resultList.Items.Count);

            statistic.addSample(watch.ElapsedMilliseconds);
        }

    }
}
