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
    public class AMMeterUsageAddCharge : AppMethodBase, AppMethodI
    {
        Statistic statistic;
        private static readonly ILog log = LogManager.GetLogger(typeof(AMMeterUsageAddCharge));
        private AccountServiceClient serviceClient = null;

        private static PipelineMeteringHelperCache m_cache = new PipelineMeteringHelperCache("metratech.com/AddCharge");

        public AMMeterUsageAddCharge()
        {
            group = "Meter";
            name = "meterUsageAddCharge";
            fullName = "Meter Usage - Add Charge";
            statistic = useStatistic(name);
            commands.Add("go", cmdGo);
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
                //   watchLocal.Start();
                PipelineMeteringHelper pipelineMeteringHelper = m_cache.GetMeteringHelper();
                //     watchLocal.Stop();
                //      log.Debug(string.Format("Got a meteringhelper in {0} ms", watchLocal.ElapsedMilliseconds));
                //      watchLocal.Restart();

                for (int i = 0; i < 1000; ++i)
                {
                    DataRow row = pipelineMeteringHelper.CreateRowForServiceDef("metratech.com/AddCharge");
                    //       watchLocal.Stop();
                    //        log.Debug(string.Format("Created new row for service def in {0} ms", watchLocal.ElapsedMilliseconds));
                    string paymentID = Guid.NewGuid().ToString();

                    row["Namespace"] = DBNull.Value;
                    row["_AccountID"] = id_acc;
                    row["_Amount"] = 5;
                    row["ChargeDate"] = DateTime.Now;
                    row["ChargeType"] = MetraTech.DomainModel.Enums.Core.Metratech_com_addCharge.ChargeType.Other;
                    row["_Currency"] = "USD";
                    row["Issuer"] = 123;
                    row["RelateToPreviousCharge"] = "";
                    row["Invoicecomment"] = "Invoice Comment";
                    row["Internalcomment"] = "Internal Comment";
                }

                    watchLocal.Restart();
                    pipelineMeteringHelper.Meter("su", "mt", "su123");
                    watchLocal.Stop();
                 //   log.Debug(string.Format("Done metering in {0} ms", watchLocal.ElapsedMilliseconds));

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

