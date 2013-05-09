using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Threading;
using log4net;

namespace BaselineGUI.UI
{
    public partial class ControlRefData : UserControl
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlRefData));

        AppRefData.AccountLoader accountLoader = new AppRefData.AccountLoader();
        AppRefData.UsageLoader usageLoader = new AppRefData.UsageLoader();
        AppRefData.SubLoader subLoader = new AppRefData.SubLoader();
        AppRefData.BMELoader bmeLoader = new AppRefData.BMELoader();


        public ControlRefData()
        {
            InitializeComponent();
        }

        private void buttonClick(object sender, EventArgs e)
        {
            log.Info("buttonClick entered");
            BackgroundArgs args = new BackgroundArgs();
            if (sender is Button)
            {
                Button b = (Button)sender;
                args.what = (string)b.Tag;

                log.InfoFormat("buttonClick {0}", args.what);
                try
                {
                    switch (args.what)
                    {
                        case "customer":
                            args.number = Int32.Parse(textBoxCustomerNumber.Text);
                            break;
                        case "customerModifiable":
                            args.number = Int32.Parse(textBoxModifiable.Text);
                            break;
                        case "usage":
                            args.number = Int32.Parse(textBoxUsage.Text);
                            break;
                        case "calllogreason":
                            args.number = Int32.Parse(textBoxCallLogReason.Text);
                            break;
                        case "calllogentry":
                            args.number = Int32.Parse(textBoxCallLogEntry.Text);
                            break;
                        case "subscriptions":
                            break;
                        default:
                            return;
                    }
                }
                catch
                {
                    return;
                }

                setButtonsToRunning();
                backgroundWorker.RunWorkerAsync(args);
            }
        }


        private class BackgroundArgs
        {
            public string what;
            public int number;
        }

        private void backgroundWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            log.Debug("Background Worker: Do work");
            if (e.Argument is BackgroundArgs)
            {
                BackgroundArgs args = (BackgroundArgs)(e.Argument);
                switch (args.what)
                {
                    case "customer":
                        accountLoader.numToLoad = args.number;
                        accountLoader.accountFlags.setToDefaults();
                        accountLoader.loadAccounts(Framework.conn);
                        break;
                    case "customerModifiable":
                        accountLoader.numToLoad = args.number;
                        accountLoader.accountFlags.setToDefaults();
                        accountLoader.accountFlags.isModifiable = true;
                        accountLoader.loadAccounts(Framework.conn);
                        break;
                    case "subscriptions":
                        subLoader.targetPO = Framework.productOffers.findPO("ldperfSimplePO");
                        subLoader.addSubscriptions(Framework.conn);
                        break;
                    case "usage":
                        usageLoader.targetPO = Framework.productOffers.findPO("ldperfSimplePO");
                        if (usageLoader.targetPO == null)
                            log.Info("Didn't find PO");
                        else
                            log.Info("Found the PO");

                        usageLoader.usagePerAccount = args.number;
                        usageLoader.loadUsage(Framework.conn);
                        break;
                    case "calllogentry":
                        bmeLoader.numToLoad = args.number;
                        bmeLoader.addCallLogEntries(Framework.conn);
                        break;
                    case "calllogreason":
                        bmeLoader.numToLoad = args.number;
                        bmeLoader.addCallLogReasons(Framework.conn);
                        break;
                    default:
                        break;
                }
            }
            Thread.Sleep(1000);
        }

        private void backgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            log.Debug("Background Worker: completed");
            setButtonsToIdle();
        }

        void setButtonsToIdle()
        {
            setAllButtonsToState(true);
        }

        void setButtonsToRunning()
        {
            setAllButtonsToState(false);
        }

        void setAllButtonsToState(bool state)
        {
            this.buttonCreateCorporate.Enabled = state;
            this.buttonCreateCustomer.Enabled = state;
            this.buttonCreateCustomerModifiable.Enabled = state;
            this.buttonAddUsage.Enabled = state;
            this.buttonSubs.Enabled = state;
        }        
    }
}
