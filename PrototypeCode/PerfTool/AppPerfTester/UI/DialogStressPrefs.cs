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
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;

namespace BaselineGUI
{
    public class DialogStressPrefs : Form
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlStressTabPage));

        List<ControlAM> amCtls = new List<ControlAM>();
        Dictionary<string, Label> amLabels = new Dictionary<string, Label>();
        Dictionary<string, CheckBox> amEnabled = new Dictionary<string, CheckBox>();
        Dictionary<string, TextBox> amRate = new Dictionary<string, TextBox>();

        Button buttonOkay;
        Button buttonCancel;
        TextBox runtime, numThreads;
        Label labelRuntime, labelNumThreads;

        public DialogStressPrefs()
        {
            this.Text = "Stress";
            this.AutoScroll = true;

            buttonOkay = new Button();
            buttonOkay.Text = "Okay";
            buttonOkay.Name = "okay";
            buttonOkay.DialogResult = DialogResult.OK;
            this.Controls.Add(buttonOkay);

            buttonCancel = new Button();
            buttonCancel.Text = "Cancel";
            buttonCancel.Name = "cancel";
            buttonCancel.DialogResult = DialogResult.Cancel;
            this.Controls.Add(buttonCancel);

            this.AcceptButton = buttonOkay;
            this.CancelButton = buttonCancel;

            runtime = new TextBox();
            runtime.Text = "300";
            this.Controls.Add(runtime);

            labelRuntime = new Label();
            labelRuntime.Text = "Duration in seconds";
            labelRuntime.AutoSize = true;
            labelRuntime.PerformLayout();
            this.Controls.Add(labelRuntime);

            numThreads = new TextBox();
            numThreads.Text = "10";
            this.Controls.Add(numThreads);

            labelNumThreads = new Label();
            labelNumThreads.Text = "Number Of Threads";
            labelNumThreads.AutoSize = true;
            labelNumThreads.PerformLayout();
            this.Controls.Add(labelNumThreads);

            List<String> allGroups = AppMethodFactory.getAllGroupNames();
            foreach (string groupName in allGroups)
            {
                List<AppMethodI> ams = AppMethodFactory.getGroup(groupName);
                foreach (AppMethodI am in ams)
                {
                    string key = am.name.ToLower();

                    Label label = new Label();
                    label.Name = key;
                    label.Text = am.fullName;
                    label.AutoSize = true;
                    label.PerformLayout();
                    amLabels.Add(label.Name, label);
                    this.Controls.Add(label);

                    CheckBox checkBox = new CheckBox();
                    checkBox.Name = key;
                    checkBox.Text = null;
                    checkBox.AutoSize = true;
                    amEnabled.Add(checkBox.Name, checkBox);
                    this.Controls.Add(checkBox);

                    TextBox textBox = new TextBox();
                    textBox.Name = key;
                    amRate.Add(textBox.Name, textBox);
                    this.Controls.Add(textBox);
                }
            }

            this.Layout += new LayoutEventHandler(this.doLayout);

            pushModelToControl();

            this.ResumeLayout();
            this.PerformLayout();
        }

        public void doLayout(object sender, LayoutEventArgs e)
        {
            int x, y;
            int ux = -1;
            x = 8;
            y = 8;

            labelRuntime.Location = new Point(x, y);
            runtime.Location = new Point(labelRuntime.Right + 8, y);
            labelNumThreads.Location = new Point(x, runtime.Bottom + 8);
            numThreads.Location = new Point(labelNumThreads.Right + 8, runtime.Bottom + 8);
            y = numThreads.Bottom + 8;

            buttonOkay.Location = new Point(x, y);
            buttonCancel.Location = new Point(x + 100, y);
            y = buttonOkay.Bottom + 8;

            foreach (var kvp in amLabels)
            {
                string key = kvp.Key;
                var ctl = kvp.Value;
                ctl.Location = new Point(x, y);
                ux = Math.Max(ux, ctl.Right);
                y = ctl.Bottom + 8;
            }

            foreach (var kvp in amLabels)
            {
                string key = kvp.Key;
                var ctl = kvp.Value;

                y = ctl.Top;

                CheckBox cb = amEnabled[key];
                cb.Location = new Point(ux + 8, y);

                TextBox tb = amRate[key];
                tb.Location = new Point(cb.Right + 8, y);
            }

            int uy;
            ux = 0;
            uy = 0;
            foreach (Control ctl in this.Controls)
            {
                ux = Math.Max(ux, ctl.Right);
                uy = Math.Max(ux, ctl.Bottom);
            }
            this.Size = new Size(ux + 40, uy + 40);
        }


        public void pushModelToControl()
        {
            foreach (var kvp in amLabels)
            {
                string key = kvp.Key;

                AMPreferences pref = PrefRepo.active.findAMPreferences(key);
                amEnabled[key].Checked = pref.stressEnabled;
                amRate[key].Text = String.Format("{0}", pref.stressRate);
                runtime.Text = string.Format("{0}", PrefRepo.active.stress.maxRunTime);
                numThreads.Text = string.Format("{0}", PrefRepo.active.stress.numThreads);
            }
        }

        public void pushControlToModel()
        {
            foreach (var kvp in amLabels)
            {
                string key = kvp.Key;

                AMPreferences pref = PrefRepo.active.findAMPreferences(key);
                pref.stressEnabled = amEnabled[key].Checked;
                pref.stressRate = Double.Parse(amRate[key].Text);
                PrefRepo.active.stress.maxRunTime = Int32.Parse(runtime.Text);
                PrefRepo.active.stress.numThreads = Int32.Parse(numThreads.Text);
            }
        }
    }
}
