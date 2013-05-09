using System;
using System.Data;
using System.Threading;
using System.IO;
using System.Diagnostics;
using MetraTech.Account.ClientProxies;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.AccountTypes;


namespace BaselineGUI
{
    public class AccountLoadServiceWorker
    {
        public FCAccountLoadService als;
        AccountCreationClient client = null;
        public TSLabel statusLabel;
        public DataRow statusRow;
        public Thread thread;
        public bool runFlag = true;
        public int workerNumber = 0;

        Statistic statistic;

        public AccountLoadServiceWorker()
        {
            statistic = StatisticFactory.find("accountLoadService");
            thread = new Thread(new ThreadStart(this.Work));
        }

        public void openClient()
        {
            if (client == null)
            {
                client = new AccountCreationClient();
				//client.ClientCredentials.UserName.UserName = "Admin";
				//client.ClientCredentials.UserName.Password = "123";
				client.ClientCredentials.UserName.UserName = PrefRepo.active.actSvcs.authName;
				client.ClientCredentials.UserName.Password = PrefRepo.active.actSvcs.authPassword;
				client.Open();
                lock (statusRow.Table)
                {
                    statusRow["Status"] = "Client open";
                }
            }
        }

        public void start()
        {
            thread.Start();
        }

        public void stop()
        {
            runFlag = false;
            thread.Join();
        }



        public void Work()
        {

            lock (statusRow.Table)
            {
                statusRow["Thread"] = string.Format("Worker {0}", workerNumber);
                statusRow["Status"] = string.Format("Idle");
            }

            openClient();
            lock (statusRow.Table)
            {
                statusRow["Thread"] = string.Format("Worker {0} connected", workerNumber);
            }


            while (runFlag)
            {
                int pos = als.Dequeue(500);
                if (pos >= 0)
                {


                    lock (statusRow.Table)
                    {
                        statusRow["Status"] = string.Format("Working on {0}", pos);
                    }

                    AccountLoadDesc ld = als.dq.at(pos);
                    Account tmp = ld.acct;

                    try
                    {
                        Stopwatch watch = new Stopwatch();
                        ld.message = "Calling";
                        watch.Restart();
                        client.AddAccount(ref tmp, false);
                        watch.Stop();
                        statistic.addSample(watch.ElapsedMilliseconds);

                        ld.state = 3;
                        ld.message = "Success";
                    }
                    catch (Exception e)
                    {
                        lock (statusRow.Table)
                        {
                            ld.message = string.Format("Failed: {1}", pos, e.Message);
                        }
                        ld.state = 4;
                    }

                    ld.timeOfCompletion = DateTime.Now;
                    als.Cleanup();
                    lock (statusRow.Table)
                    {
                        statusRow["Status"] = string.Format("Idle");
                    }
                }

            }
        }

    }

}
