using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.ServiceModel;
using AppRefData;
using MetraTech.ActivityServices.Services.Common;
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
    public class AMMeterUsage : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMMeterUsage));
        private AccountServiceClient serviceClient = null;        
#if false
      private static PipelineMeteringHelperCache m_cache = new PipelineMeteringHelperCache("metratech.com/Payment", "PaymentID",
                                                      typeof (string), new string[] {"metratech.com/paymentdetails"});
#endif

        private static PipelineMeteringHelperCache m_cache = new PipelineMeteringHelperCache("metratech.com/NonStandardCharge");

        public AMMeterUsage()
        {
            group = "Meter";
            name = "meterUsage";
            fullName = "Meter Usage";
            statistic = useStatistic(name);
            commands.Add("go", cmdGo);
            m_cache.PollingInterval = 100;
        }

        public void setup()
        {
            acquireClient(out serviceClient);
        }

        public void teardown()
        {
            releaseClient(serviceClient);
        }

        public void dispose()
        {
            disposeClient(serviceClient);
            serviceClient = null;
        }
        public void cmdGo()
        {
            Stopwatch watch = new Stopwatch();
            int id_acc = Framework.netMeter.pickModifiableAccountID();
            
            // Find acc_id for "admin"
            MTList<Account> tmpAccounts = new MTList<Account>();
            tmpAccounts.Filters.Add(new MTFilterElement("username", MTFilterElement.OperationType.Equal, "admin"));
            List<int> accountIds = new List<int>();
            serviceClient.GetAccountIdList(DateTime.Now, ref tmpAccounts, false, out accountIds);
            int adminIdAcc = 137;
            if (accountIds.Count == 1)
            {
                adminIdAcc = accountIds[0];
            }
            adminIdAcc = 129;

            Stopwatch watchLocal = new Stopwatch();

            watch.Restart();
            try
            {
                watchLocal.Start();
                PipelineMeteringHelper pipelineMeteringHelper = m_cache.GetMeteringHelper();
                watchLocal.Stop();
                log.Debug(string.Format("Got a meteringhelper in {0} ms", watchLocal.ElapsedMilliseconds));
                watchLocal.Restart();
                DataRow nonStandardChargeRow = pipelineMeteringHelper.CreateRowForServiceDef("metratech.com/NonStandardCharge");
                watchLocal.Stop();
                log.Debug(string.Format("Created new row for service def in {0} ms", watchLocal.ElapsedMilliseconds));

#if false
                nonStandardChargeRow["_AccountId"] = id_acc;
                nonStandardChargeRow["_Amount"] = 123.45;
                nonStandardChargeRow["EventDate"] = DateTime.Now;
                nonStandardChargeRow["Source"] = "MT";
                nonStandardChargeRow["ReferenceID"] = null;
                nonStandardChargeRow["PaymentTxnID"] = 12345;
                nonStandardChargeRow["PaymentID"] = Guid.NewGuid().ToString();
#endif
                //nonStandardChargeRow["EventDate"] = DateTime.Now;
                nonStandardChargeRow["_AccountId"] = id_acc;
                nonStandardChargeRow["NumUnits"] = 1;
                nonStandardChargeRow["Rate"] = 33.33;
                nonStandardChargeRow["AdditionalRate"] = 1.0;
                nonStandardChargeRow["IssuerAccountId"] = adminIdAcc;
                nonStandardChargeRow["AccountNameSpace"] = "system_user";
                nonStandardChargeRow["ReasonCode"] =
                    (MetraTech.DomainModel.Enums.Core.Metratech_com_NonStandardCharge.NonStandardChargeReason)0;
                nonStandardChargeRow["_Currency"] = "USD";
                //nonStandardChargeRow["AdditionalRate"] = 1.0M;
                nonStandardChargeRow["AdditionalCode"] =
                    (MetraTech.DomainModel.Enums.Core.Metratech_com_NonStandardCharge.AdditionalCode)0;

                nonStandardChargeRow["ResolveWithAccountIDFlag"] = true;
                nonStandardChargeRow["Status"] = "A";
                nonStandardChargeRow["ExternalChargeId"] = -1;
                nonStandardChargeRow["InternalChargeId"] = -1;
                nonStandardChargeRow["GuideIntervalID"] = 1031274529;
                nonStandardChargeRow["IssueTime"] = DateTime.Now;

                watchLocal.Restart();
                pipelineMeteringHelper.Meter("su", "mt", "su123");
                watchLocal.Stop();
                log.Debug(string.Format("Done metering in {0} ms", watchLocal.ElapsedMilliseconds));

                watch.Stop();
                statistic.addSample(watch.ElapsedMilliseconds);
                if (pipelineMeteringHelper.WasMeterSuccessful())
                {
                    Console.WriteLine("Meter Ok");
                }
                else
                {
                    Console.WriteLine("Meter Failed");
                }

                m_cache.Release(pipelineMeteringHelper);
            }
            catch (Exception e)
            {
                log.ErrorFormat("exception {0}, {1}, {2}", e.InnerException, e.Message, e.StackTrace);
                throw;
            }
        }
    }
}
