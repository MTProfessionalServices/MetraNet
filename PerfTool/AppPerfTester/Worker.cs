using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using log4net;

namespace BaselineGUI
{
    public class Worker
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(Worker));

        public volatile bool runFlag = true;

        public int generateAccounts = 0;
        public bool generateUsage = false;

        //LiveStatus generateStatus;
        //LiveStatus usageStatus;

        public MASAccount accountGenerator;
        public volatile bool doOpenWriters = false;
        public volatile bool doCloseWriters = false;

        public void Work()
        {
            log.Debug("Starting");

            //generateStatus = UserInterface.bm.getLiveStatus("Account");
            //usageStatus = UserInterface.bm.getLiveStatus("Usage");

            accountGenerator = new MASAccount();

            while (runFlag)
            {
                //log.Debug("running");
                Thread.Sleep(100);
                //generateStatus.SetLabel("Idle");
                //usageStatus.SetLabel("Idle");

                if (doOpenWriters)
                {
                    doOpenWriters = false;
                    accountGenerator.openWriters();
                }
                if (doCloseWriters)
                {
                    doCloseWriters = false;
                    accountGenerator.closeWriters();
                }

            loop:
                if (generateAccounts > 0)
                {
                    if ((generateAccounts % 100) == 0)
                    {
                        //UserInterface.formMain.statusLabel.Text = string.Format("{0}", generateAccounts);
                    }
                        
                    accountGenerator.Generate();
                    generateAccounts--;
                    goto loop;
                }

            }

            log.Debug("Exitting");


        }
    }

}
