using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.ServiceModel;

using MetraTech.Account.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Account.Metratech_com_accountcreation;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Core.Metratech_com_billingcycle;
//using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSM;
//using MetraTech.DomainModel.Enums.GSM.Metratech_com_GSMReference;
using System.Diagnostics;
using DataGenerators;
using System.Data;
using System.Data.SqlClient;
using System.Threading;


namespace BaselineGUI
{


    public class FCAccountLoadService : FrameworkComponentBase, IFrameworkComponent
    {
        public DependencyQueue dq = new DependencyQueue();

        public int numThreads = 1;
        public AccountLoadServiceWorker[] workers;

        public DataTable threadStatus;



        public FCAccountLoadService()
        {
            name = "AcctLoadSvc";
            fullName = "Account Load Service";

            threadStatus = new DataTable();
            threadStatus.Columns.Add(new DataColumn("Thread", typeof(string)));
            threadStatus.Columns.Add(new DataColumn("Status", typeof(string)));
        }


        public void Bringup()
        {
            bringupState.message = "Start...";


            workers = new AccountLoadServiceWorker[numThreads];
            for (int ix = 0; ix < numThreads; ix++)
            {

                workers[ix] = new AccountLoadServiceWorker();
                workers[ix].workerNumber = ix;
                workers[ix].als = this;
                //workers[ix].statusLabel = statusLabel;
                workers[ix].statusRow = threadStatus.NewRow();
                threadStatus.Rows.Add(workers[ix].statusRow);
            }

            foreach (AccountLoadServiceWorker w in workers)
            {
                w.start();
                Thread.Sleep(20);
            }
            bringupState.message = string.Format("Started {0} threads", numThreads);
        }



        public void Teardown()
        {
            foreach (AccountLoadServiceWorker w in workers)
            {
                w.stop();
            }

        }


        public void Enqueue(Account acct, int seq, int predecessor, int corpAcctBin = 0)
        {
            dq.Enqueue(acct, seq, predecessor, corpAcctBin);
        }


        public int Dequeue(int maxWait = -1)
        {
            return dq.Dequeue(maxWait);
        }


        public void Cleanup()
        {
            dq.Cleanup();
        }


    }
}
