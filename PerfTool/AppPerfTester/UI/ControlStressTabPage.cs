using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.SqlClient;
using System.Threading;
using System.IO;
using log4net;
using System.Windows.Forms.DataVisualization.Charting;


namespace BaselineGUI
{
    public class ControlStressTabPage : TabPage
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlStressTabPage));

        Button buttonStart;
        Button buttonStop;
       
        BackgroundWorker worker = new BackgroundWorker();

        Stress stress;

        public ControlStressTabPage()
        {
            this.Text = "Stress";
            this.AutoScroll = true;

            this.worker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.runStress);
            this.worker.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.stressCompleted);

            buttonStart = new Button();
            buttonStart.Text = "Start";
            buttonStart.Name = "start";
            buttonStart.Click += buttonClick;
            this.Controls.Add(buttonStart);

            buttonStop = new Button();
            buttonStop.Text = "Stop";
            buttonStop.Name = "stop";
            buttonStop.Click += buttonClick;
            buttonStop.Enabled = false;
            this.Controls.Add(buttonStop);
           
            this.Layout += new LayoutEventHandler(this.doLayout);

            this.ResumeLayout();
            this.PerformLayout();
        }


        public void doLayout(object sender, LayoutEventArgs e)
        {
            int x, y;
            x = 8;
            y = 8;

 
            buttonStart.Location = new Point(x, y);
            buttonStop.Location = new Point(x + 100, y);
            y = buttonStart.Bottom + 8;
        }


        private void buttonClick(object sender, EventArgs e)
        {
            if (sender is Button)
            {
                Button button = (Button)sender;
                switch (button.Name)
                {
                    case "start":
                        buttonStart.Enabled = false;
                        buttonStop.Enabled = true;
                        if (stress == null)
                        {
                            stress = new Stress();
                        }
                        worker.RunWorkerAsync();
                        break;
                    case "stop":
                        buttonStop.Enabled = false;
                        stress.generator.runFlag = false;
                        break;
                }
            }
        }

        private void runStress(object sender, DoWorkEventArgs e)
        {
            log.Debug("Background Worker: starting stress");
            stress.setup();
            stress.run();
        }

        private void stressCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            log.Debug("Background Worker: completed");
            buttonStart.Enabled = true;
            buttonStop.Enabled = false;
        }

    }
}
