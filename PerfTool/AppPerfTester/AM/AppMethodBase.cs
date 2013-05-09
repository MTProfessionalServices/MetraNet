using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Core.Services.ClientProxies;

using System.ServiceModel;
using System.ServiceModel.Channels;
using log4net;

namespace BaselineGUI
{
    public class AppEventData : EventArgs
    {
        public AppMethodI sender;
    }

    public class AppMethodBase
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(AppMethodBase));
        public string group { get; set; }

        public string name { get; set; }
        public string fullName { get; set; }

        public bool stressEnabled { get; set; }
        public double stressRate { get; set; }

        public static string authName { get { return PrefRepo.active.actSvcs.authName; } }
        public static string authPwd { get { return PrefRepo.active.actSvcs.authPassword; } }

        public MsgLogger msgLogger { get; set; }

        public string _status1;
        public string status1
        {
            get { return _status1; }
            set { _status1 = value; RaiseModelChange(); }
        }

        public string _status2;
        public string status2
        {
            get { return _status2; }
            set { _status2 = value; RaiseModelChange(); }
        }

        public bool runForever { set; get; }

        public Dictionary<string, AppCommand> commands { set; get; }

        public List<Statistic> statistics { set; get; }

        public event EventHandler<AppEventData> OnModelChangeEvent;

        public volatile bool stopFlag;


        public AppMethodBase()
        {
            group = "other";

            commands = new Dictionary<string, AppCommand>();
            commands.Add("stop", cmdStop);

            statistics = new List<Statistic>();
        }


        public Statistic useStatistic(string name)
        {
            Statistic statistic;
            statistic = StatisticFactory.find(name);
            statistics.Add(statistic);
            return statistic;
        }

        public void RaiseModelChange()
        {
            if (this is AppMethodI)
            {
                AppMethodI appMethod = (AppMethodI)this;
                EventHandler<AppEventData> handler = OnModelChangeEvent;
                if (handler != null)
                {
                    AppEventData d = new AppEventData();
                    d.sender = appMethod;
                    handler(this, d);
                }
            }
        }

        // These are yucky as there is no common base class
        public void acquireClient(out AccountServiceClient client)
        {
            ActSvcClientPool.acquire<AccountServiceClient>(out client);
         }

        public void acquireClient(out AuditLogServiceClient client)
        {
            ActSvcClientPool.acquire<AuditLogServiceClient>(out client);
        }

        public void acquireClient(out SubscriptionServiceClient client)
        {
            ActSvcClientPool.acquire<SubscriptionServiceClient>(out client); 
        }

        public void acquireClient(out UsageHistoryServiceClient client)
        {
            ActSvcClientPool.acquire<UsageHistoryServiceClient>(out client); 
        }

        public void acquireClient(out MAMHierarchyWebSvcSoapClient client)
        {
            ActSvcClientPool.acquire<MAMHierarchyWebSvcSoapClient>(out client);
        }



        public void releaseClient(ICommunicationObject client)
        {
            ActSvcClientPool.release(client);
        }

        public void disposeClient(ICommunicationObject client)
        {
            ActSvcClientPool.dispose(client);
        }


        public void executeOnce(string what)
        {
            AppCommand cmd = commands[what];
            cmd();
        }

        public void executeCommand(string what)
        {
            log.DebugFormat("XXXXX executeCommand {0}", what);
            // Intercept certain commands to provide
            // common processing

            AppCommand cmd = commands[what];
            // Now execute the command
            if (what == "stop" || what == "reset")
            {
                cmd();
            }
            else
            {
                AppMethodI am = (AppMethodI)this;

                am.setup();
                stopFlag = false;
                int loopCnt = Convert.ToInt32(PrefRepo.active.runLmt.numPasses);
                DateTime endTime = DateTime.Now.AddSeconds(Convert.ToInt32(PrefRepo.active.runLmt.maxRunTime));

                while (!stopFlag)
                {
                    if (!runForever)
                    {
                        if (loopCnt <= 0)
                            break;
                        loopCnt--;
                        if (DateTime.Now > endTime)
                            break;
                    }

                    try
                    {
                        cmd();
                    }
                    catch (Exception ex)
                    {
                        am.dispose();
                        stopFlag = true;
                        status2 = ex.ToString();
                        log.ErrorFormat(ex.ToString());
                    }
                }
                am.teardown();
            }

        }


        public void cmdStop()
        {
            stopFlag = true;
        }

        public void cmdReset()
        {
            foreach (Statistic stat in statistics)
            {
                stat.reset();
            }
        }

        public string ProcessMASErrorDetail(FaultException<MASBasicFaultDetail> fd)
        {
            string s = string.Empty;
            s += fd.Message + "\n";
            foreach (string s1 in fd.Detail.ErrorMessages)
                s += s1 + "\n";
            s += fd.StackTrace;
            return s;
        }
    }


}
