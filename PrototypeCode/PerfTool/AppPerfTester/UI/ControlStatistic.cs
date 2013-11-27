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
    public partial class ControlStatistic : UserControl
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlStatistic));

        Statistic statistic;

        public ControlStatistic()
        {
            InitializeComponent();
        }

        public void setStatistic(string name, string displayName)
        {
            log.DebugFormat("Setting name to {0}", name);
            statistic = StatisticFactory.find(name);
            groupBox.Text = displayName;
            statistic.OnModelChangeEvent += OnModelChangeEvent;
        }


        delegate void callback(Object sender, Statistic.EventData data);
        public void OnModelChangeEvent(Object sender, Statistic.EventData data)
        {
            if (InvokeRequired)
            {
                callback cb = new callback(OnModelChangeEvent);
                Invoke(cb, new object[] { sender, data });
            }
            else
            {
                textBoxAverage.Text = string.Format("{0}", statistic.average);
                textBoxMin.Text = string.Format("{0}", statistic.myMin);
                textBoxMax.Text = string.Format("{0}", statistic.myMax);
                textBoxNumSamples.Text = string.Format("{0}", statistic.numSamples);
                textBoxConfidence.Text = string.Format("{0}", statistic.confidence);
                textBoxErrs.Text = string.Format("{0}", statistic.errCnt);

                this.Update();
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            statistic.reset();
        }


    }
}
