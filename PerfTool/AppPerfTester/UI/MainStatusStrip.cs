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
    /// <summary>
    /// Provides the application-specific status strip.  The strip includes progress and preferences information
    /// </summary>
    public class MainStatusStrip : StatusStrip
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(MainStatusStrip));

        public ToolStripStatusLabel labelProgressWhat;
        public ToolStripProgressBar progressBar;
        public ToolStripStatusLabel progressPercent;
        public ToolStripStatusLabel labelPreferences;

        public MainStatusStrip()
        {
            InitializeComponent();

            PrefRepo.OnModelChangeEvent += handlePrefChange;
            ProgressableFactory.OnModelChangeEvent += handleProgressableFactoryChange;
        }

        void InitializeComponent()
        {
            this.labelProgressWhat = new ToolStripStatusLabel();
            this.progressBar = new ToolStripProgressBar();
            this.progressPercent = new ToolStripStatusLabel();
            this.labelPreferences = new ToolStripStatusLabel();

            this.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.labelProgressWhat,
            this.progressBar,
            this.progressPercent,
            this.labelPreferences});

            // 
            // labelProgressWhat
            // 
            this.labelProgressWhat.AutoSize = false;
            stylize(this.labelProgressWhat);
            this.labelProgressWhat.MergeAction = System.Windows.Forms.MergeAction.MatchOnly;
            this.labelProgressWhat.Name = "statusLabel";
            this.labelProgressWhat.Size = new System.Drawing.Size(150, 17);
            this.labelProgressWhat.Text = "idle";
            // 
            // toolStripProgressBar1
            // 
            this.progressBar.Name = "progressBar";
            this.progressBar.Size = new System.Drawing.Size(100, 17);
            this.progressBar.Minimum = 0;
            this.progressBar.Maximum = 100;
            this.progressBar.Value = 0;
            // 
            // progressPercent
            // 
            this.progressPercent.AutoSize = false;
            stylize(this.progressPercent);
            this.progressPercent.MergeAction = System.Windows.Forms.MergeAction.MatchOnly;
            this.progressPercent.Name = "progressPercent";
            this.progressPercent.Size = new System.Drawing.Size(60, 17);
            this.progressPercent.Text = "  0.0%";
            // 
            // labelPreferences
            // 
            this.labelPreferences.AutoSize = false;
            stylize(this.labelPreferences);
            this.labelPreferences.Name = "statusLabel1";
            this.labelPreferences.Size = new System.Drawing.Size(300, 17);

            updateProgress();
            updatePrefFileName();
        }


        private void stylize(ToolStripStatusLabel label)
        {
            label.BorderSides = ((System.Windows.Forms.ToolStripStatusLabelBorderSides)((((System.Windows.Forms.ToolStripStatusLabelBorderSides.Left
            | System.Windows.Forms.ToolStripStatusLabelBorderSides.Top)
            | System.Windows.Forms.ToolStripStatusLabelBorderSides.Right)
            | System.Windows.Forms.ToolStripStatusLabelBorderSides.Bottom)));
            label.BorderStyle = System.Windows.Forms.Border3DStyle.Sunken;
        }

        delegate void callback(Object sender, EventArgs data);

        #region Preferences File Changes

        private void updatePrefFileName()
        {
            labelPreferences.Text = "Preferences:" + PrefRepo.preferencesFile;
        }

        private void handlePrefChange(object sender, EventArgs e)
        {
            if (InvokeRequired)
            {
                callback cb = new callback(handlePrefChange);
                Invoke(cb, new object[] { sender, e });
            }
            else
            {
                log.Debug("Got a preference change event");
                updatePrefFileName();
            }
        }

        #endregion

        #region Progress Changes

        private void updateProgress()
        {
            Progressable p = ProgressableFactory.active;
            if (p != null && p.isRunning)
            {
                labelProgressWhat.Text = p.name;
                progressBar.Minimum = p.Minimum;
                progressBar.Maximum = p.Maximum;
                progressBar.Value = p.Value;

                double percent;
                if (p.Minimum >= p.Maximum)
                {
                    percent = 100.0;
                }
                else
                {
                    percent = 100.0 * (double)(p.Value - p.Minimum) / (double)(p.Maximum - p.Minimum);
                }

                progressPercent.Text = string.Format("{0:f1}%", percent);
            }
            else
            {
                labelProgressWhat.Text = "idle";
                progressPercent.Text = "";
                progressBar.Minimum = 0;
                progressBar.Maximum = 100;
                progressBar.Value = 0;
            }
        }


        private void handleProgressableFactoryChange(object sender, EventArgs e)
        {
            if (InvokeRequired)
            {
                callback cb = new callback(handleProgressableFactoryChange);
                Invoke(cb, new object[] { sender, e });
            }
            else
            {
                updateProgress();
                this.Update();
            }
        }

        #endregion


    }
}
