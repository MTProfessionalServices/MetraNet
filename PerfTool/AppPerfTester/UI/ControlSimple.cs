using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using log4net;

namespace BaselineGUI
{
    public partial class ControlSimple : UserControl
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlSimple));

        AppMethodI method;

        public ControlSimple()
        {
            InitializeComponent();
        }

        public void setMethod(string name)
        {
            log.DebugFormat("Setting method to {0}", name);
            method = AppMethodFactory.find( name);
            statistics.setStatistic(name, method.fullName);

            groupBox1.Text = method.fullName;
        }


        private class MyArgs
        {
            public string what;

            public MyArgs(string s)
            {
                what = s;
            }
        }

        private void buttonGo_Click(object sender, EventArgs e)
        {
            this.buttonGo.Enabled = false;
            this.buttonStop.Enabled = true;
            //this.buttonReset.Enabled = false;
            backgroundWorker.RunWorkerAsync(new MyArgs("go"));
        }

        private void backgroundWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            log.Debug("Background Worker: Do work");
            if (e.Argument is MyArgs)
            {
                MyArgs args = (MyArgs)(e.Argument);
                string what = args.what;
                log.DebugFormat("operation {0}", what);
                method.executeCommand(what);
            }
        }

        private void backgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            log.Debug("Background Worker: completed");
            this.buttonGo.Enabled = true;
            this.buttonStop.Enabled = false;
            //this.buttonReset.Enabled = true;
        }

        private void buttonStop_Click(object sender, EventArgs e)
        {
            method.executeCommand("stop");
        }


    }
}
