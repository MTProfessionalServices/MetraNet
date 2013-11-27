using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Windows.Forms;
using log4net;

namespace BaselineGUI
{
    public class ControlAM : UserControl, ISupportInitialize
    {
        GroupBox wrapper;
        AppMethodI appMethod;

        TextBox status1;
        TextBox status2;
        CheckBox runForever;

        private static readonly ILog log = LogManager.GetLogger(typeof(ControlAM));

        List<Button> ctlButtons = new List<Button>();
        List<ControlStatistic> ctlStats = new List<ControlStatistic>();

        private System.ComponentModel.BackgroundWorker backgroundWorker;

        private String _am_methodName;
        public string am_methodName
        {
            set { _am_methodName = value; foobar(); }
            get { return _am_methodName; }
        }


        private class MyArgs
        {
            public string what;
            public bool runForever;

            public MyArgs(string s, bool runForever)
            {
                what = s;
                this.runForever = runForever;
            }
        }


        public ControlAM()
        {
            InitializeWrapper();
        }

        public void BeginInit()
        {
        }

        public void EndInit()
        {
        }

        private void InitializeWrapper()
        {
            this.Controls.Clear();

            // 
            // backgroundWorker
            //
            this.backgroundWorker = new BackgroundWorker();
            this.backgroundWorker.DoWork += new System.ComponentModel.DoWorkEventHandler(this.backgroundWorker_DoWork);
            this.backgroundWorker.RunWorkerCompleted += new System.ComponentModel.RunWorkerCompletedEventHandler(this.backgroundWorker_RunWorkerCompleted);


            this.Size = new System.Drawing.Size(600, 400);

            // 
            // Group Box
            // 
            this.wrapper = new GroupBox();
            this.wrapper.Location = new System.Drawing.Point(38, 22);
            this.wrapper.Name = "textBox2";
            this.wrapper.Size = new System.Drawing.Size(100, 20);
            this.wrapper.TabIndex = 0;
            this.wrapper.Text = "Default App Method Name";

            this.Controls.Add(this.wrapper);

            this.Layout += new System.Windows.Forms.LayoutEventHandler(this.doLayout);

            this.ResumeLayout();
            this.PerformLayout();
        }



        private void foobar()
        {
            appMethod = AppMethodFactory.find(am_methodName);
            if (appMethod == null)
                return;

            wrapper.Text = appMethod.fullName;


            // Status
            this.status1 = new TextBox();
            status1.ReadOnly = true;
            this.status2 = new TextBox();
            status2.ReadOnly = true;
            appMethod.OnModelChangeEvent += new EventHandler<AppEventData>(this.onModelChangeEvent);
            this.wrapper.Controls.Add(status1);
            this.wrapper.Controls.Add(status2);

            // Run Forever
            this.runForever = new CheckBox();
            this.runForever.Checked = false;
            this.runForever.Text = "Forever";
            this.wrapper.Controls.Add(this.runForever);

            this.ctlStats = new List<ControlStatistic>();
            foreach (Statistic stat in appMethod.statistics)
            {
                ControlStatistic ctl = new ControlStatistic();
                ctlStats.Add(ctl);
                ctl.setStatistic(stat.Name, stat.Name);
                this.wrapper.Controls.Add(ctl);
            }


            // 
            // buttons
            //

            foreach (var kvp in appMethod.commands)
            {
                Button button = new Button();
                ctlButtons.Add(button);
                button.Location = new System.Drawing.Point(13, 118);
                button.Name = kvp.Key;
                button.Size = new System.Drawing.Size(45, 24);
                button.TabIndex = 0;
                button.Text = kvp.Key;
                button.UseVisualStyleBackColor = true;
                button.Click += new System.EventHandler(this.buttonClick);
                this.wrapper.Controls.Add(button);
            }
            setButtonsToIdle();

            this.Layout += new System.Windows.Forms.LayoutEventHandler(this.doLayout);

            this.ResumeLayout();
            this.PerformLayout();
        }

        private void doLayout(object sender, LayoutEventArgs e)
        {
            if (appMethod == null)
                return;

            int x, y, ux, uy;


            // buttons
            x = 8;
            y = 20;
            ux = 0;

            foreach (var ctl in ctlButtons)
            {
                ctl.Location = new System.Drawing.Point(x, y);
                y = ctl.Bottom + 4;
                ux = Math.Max(ux, ctl.Right);
            }

            //textBox2.SetBounds(40, 80, 400, 32);
            //Layout the statistics

            x = ux + 8;
            y = 20;
            foreach (var ctl in ctlStats)
            {
                ctl.Location = new System.Drawing.Point(x, y);
                y = ctl.Bottom + 4;
                ux = Math.Max(ux, ctl.Right);
            }

            runForever.Location = new System.Drawing.Point(x, y);
            y = runForever.Bottom + 4;

            x = 8;
            status1.Location = new System.Drawing.Point(x, y);
            status1.Size = new System.Drawing.Size(ux - x, 21);
            y = status1.Bottom + 4;
            status2.Location = new System.Drawing.Point(x, y);
            status2.Size = new System.Drawing.Size(ux - x, 21);

            //Overall bounding boxes
            ux = -1;
            uy = -1;
            foreach (Control ctl in wrapper.Controls)
            {
                ux = Math.Max(ux, ctl.Right);
                uy = Math.Max(uy, ctl.Bottom);
            }

            wrapper.SetBounds(2, 2, ux + 2, uy + 2);
            this.Size = new System.Drawing.Size(wrapper.Right + 2, wrapper.Bottom + 2);

        }


        private void buttonClick(object sender, EventArgs e)
        {
            if (sender is Button)
            {
                Button b = (Button)sender;
                if (b.Name == "stop")
                {
                    appMethod.executeCommand("stop");
                }
                else
                {
                    setButtonsToRunning();
                    backgroundWorker.RunWorkerAsync(new MyArgs(b.Name, runForever.Checked));
                }
            }
        }


        private void backgroundWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            log.Debug("Background Worker: Do work");
            if (e.Argument is MyArgs)
            {
                MyArgs args = (MyArgs)(e.Argument);
                string what = args.what;
                log.DebugFormat("operation {0}", what);
                appMethod.runForever = args.runForever;
                appMethod.executeCommand(what);
            }
        }

        private void backgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            log.Debug("Background Worker: completed");
            setButtonsToIdle();
        }


        void setButtonsToIdle()
        {
            foreach (var button in ctlButtons)
            {
                if (button.Name == "stop")
                {
                    button.Enabled = false;
                }
                else
                    button.Enabled = true;
            }
        }

        void setButtonsToRunning()
        {
            foreach (var button in ctlButtons)
            {
                if (button.Name == "stop")
                {
                    button.Enabled = true;
                }
                else
                    button.Enabled = false;
            }
        }

        delegate void callback(Object sender, AppEventData data);
        void onModelChangeEvent(object sender, AppEventData data)
        {
            if (InvokeRequired)
            {
                callback cb = new callback(onModelChangeEvent);
                Invoke(cb, new object[] { sender, data });
            }
            else
            {
                status1.Text = appMethod.status1;
                status2.Text = appMethod.status2;
                this.Update();
            }
        }


    }
}
