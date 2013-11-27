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
    public partial class FormMain : Form
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(FormMain));

        ControlAMTabPage myTabPage;

        public FormMain()
        {
            statisticAccountLoad = new ControlStatistic();

            InitializeComponent();

            foreach (string groupName in AppMethodFactory.getAllGroupNames())
            {
                myTabPage = new ControlAMTabPage(groupName);
                myTabPage.Text = groupName;
                this.tabMain.Controls.Add(this.myTabPage);
            }

            ControlStressTabPage stress = new ControlStressTabPage();
            this.tabMain.Controls.Add(stress);
        }



        private void Form1_Load(object sender, EventArgs e)
        {
            statisticAccountLoad.setStatistic("accountLoadService", "Create Account");

            connectToModel();
        }

        public void connectToModel()
        {
            // Bring up models to the UI
            GridViewAccountLoader.DataSource = Framework.accountLoadService.threadStatus;
            GridViewAccountLoader.Columns["Thread"].MinimumWidth = 100;
            GridViewAccountLoader.Columns["Status"].MinimumWidth = 100;

            GridViewRingState.DataSource = Framework.accountLoadService.dq.ringState;
            GridViewRingState.Columns["Queued"].DefaultCellStyle.Format = "hh:mm:ss";
            GridViewRingState.Columns["Completion"].DefaultCellStyle.Format = "hh:mm:ss";

            GridViewEnumData.DataSource = Framework.EnumRepo.tabularModel;

        }

        private void ButtonMASAccount_Click(object sender, EventArgs e)
        {
            TextBoxGenerateStatus.Clear();
            // DbAccount acct = new DbAccount();
            int num = int.Parse(TextBoxNumberToGenerate.Text);
            Framework.worker.generateAccounts += num;
        }

        private void buttonGoUsage_Click(object sender, EventArgs e)
        {
            Framework.worker.generateUsage = true;

        }

        private void buttonStopUsage_Click(object sender, EventArgs e)
        {
            Framework.worker.generateUsage = false;
        }


        private void FileExit_Click(object sender, EventArgs e)
        {
            Framework.stop();
            this.Close();
        }


        public LiveStatus getLiveStatus(string s)
        {
            switch (s)
            {
                case "Account":
                    return new LiveStatus(this, TextBoxGenerateStatus, LabelGenerateStatus);
                case "Usage":
                    return new LiveStatus(this, TextBoxUsageStatus, LabelUsageStatus);
            }
            return null;
        }


        // Subscriptions

        private class MyArgs
        {
            public string what;

            public MyArgs(string s)
            {
                what = s;
            }
        }

        private void buttonGenerateUsage_Click(object sender, EventArgs e)
        {
            //GsmSvcDef sdef = new GsmSvcDef();
            //sdef.doit();
        }

        private void buttonGenerateCorpAccts_Click(object sender, EventArgs e)
        {
            MASAccount acctSvc = new MASAccount();
            acctSvc.GenerateCorporate();
        }


        private void buttonOpen_Click(object sender, EventArgs e)
        {
            this.buttonClose.Enabled = true;
            this.buttonOpen.Enabled = false;
            Framework.worker.doOpenWriters = true;
        }

        private void buttonClose_Click(object sender, EventArgs e)
        {
            this.buttonClose.Enabled = false;
            this.buttonOpen.Enabled = true;
            Framework.worker.doCloseWriters = true;
        }

        private void writeCurrentStatisticsReportToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new SaveFileDialog();

            sfd.InitialDirectory = Application.StartupPath + @"\Reports";
            sfd.FileName = "Statistics.csv";
            sfd.ShowHelp = false;
            sfd.RestoreDirectory = true;
            sfd.CheckPathExists = true;

            if (sfd.ShowDialog() == DialogResult.Cancel)
                return;

            try
            {
                StatisticFactory.writeCSV(sfd.FileName);
            }
            catch (Exception)
            {
                MessageBox.Show("Error opening file", "File Error",
                MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }

        private void aboutPerfToolToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Form form = new AboutBox();
            form.ShowDialog();
        }

        private void subscriptionsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogSubscriptionPrefs form = new DialogSubscriptionPrefs();
            DialogResult result = form.ShowDialog(this);
            if (result == DialogResult.OK)
            {
                form.pushControlToModel();
            }
        }

        private void saveToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            PrefRepo.Store(PrefRepo.active);
        }

        private void saveAsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SaveFileDialog sfd = new SaveFileDialog();

            string dir = Path.GetDirectoryName(PrefRepo.preferencesFile);
            string fileName = Path.GetFileName(PrefRepo.preferencesFile);

            sfd.InitialDirectory = dir;
            sfd.FileName = fileName;
            sfd.ShowHelp = false;
            sfd.RestoreDirectory = true;
            sfd.CheckPathExists = true;

            DialogResult result = sfd.ShowDialog();
            if (result == DialogResult.Cancel)
                return;

            PrefRepo.preferencesFile = sfd.FileName;
            PrefRepo.Store(PrefRepo.active);

        }

        private void loadToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            OpenFileDialog ofd = new OpenFileDialog();

            string dir = Path.GetDirectoryName(PrefRepo.preferencesFile);
            string fileName = Path.GetFileName(PrefRepo.preferencesFile);

            ofd.InitialDirectory = dir;
            ofd.FileName = fileName;
            ofd.ShowHelp = false;
            ofd.RestoreDirectory = true;
            ofd.CheckPathExists = true;

            DialogResult result = ofd.ShowDialog();
            if (result == DialogResult.Cancel)
                return;
            PrefRepo.preferencesFile = ofd.FileName;
            PrefRepo.active = PrefRepo.Fetch();
            UserInterface.pushModelToControl();
        }

        private void stressToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogStressPrefs dialog = new DialogStressPrefs();
            DialogResult result = dialog.ShowDialog();
            if (result == DialogResult.Cancel)
                return;
            dialog.pushControlToModel();
        }

        private void runtimeLimitsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogRuntime dialog = new DialogRuntime();
            DialogResult result = dialog.ShowDialog();
            if (result == DialogResult.Cancel)
                return;
            dialog.pushControlToModel();
        }

        private void helpToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            Help.ShowHelp(this, @"assets\perftool.chm");
        }

        private void encryptionToolStripMenuItem_Click(object sender, EventArgs e)
        {
          DialogEncryption dialog = new DialogEncryption();
          DialogResult result = dialog.ShowDialog();
          if (result == DialogResult.Cancel)
            return;
          dialog.pushControlToModel();
        }


    }


}
