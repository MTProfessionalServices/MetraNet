using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace BaselineGUI
{
    public partial class FormPreferences : Form
    {

        public FormPreferences()
        {
            InitializeComponent();
        }

        public void connectToModel()
        {
        }

        public void pushModelToControl()
        {
            textBoxDbAddress.Text = PrefRepo.active.database.address;
            textBoxDbPort.Text = PrefRepo.active.database.port;
            textBoxDbUserName.Text = PrefRepo.active.database.userName;
            textBoxDbPassword.Text = PrefRepo.active.database.password;
            textBoxDbDatabase.Text = PrefRepo.active.database.database;

            textBoxFolderExtension.Text = PrefRepo.active.folders.extension;
            textBoxFolderFLS.Text = PrefRepo.active.folders.fileLandingService;

            textBoxAsUserName.Text = PrefRepo.active.actSvcs.authName ;
            textBoxAsPassword.Text = PrefRepo.active.actSvcs.authPassword ;

            checkSaveStatRpt.Checked = PrefRepo.active.rpt.saveStatsReport;
            checkAppendStatsRpt.Checked = PrefRepo.active.rpt.appendStatsReport;
            textRptFile.Text = PrefRepo.active.rpt.rptFilename;
        }

        public void pushControlToModel()
        {
            PrefRepo.active.database.address = textBoxDbAddress.Text;
            PrefRepo.active.database.port = textBoxDbPort.Text;
            PrefRepo.active.database.userName = textBoxDbUserName.Text;
            PrefRepo.active.database.password = textBoxDbPassword.Text;
            PrefRepo.active.database.database = textBoxDbDatabase.Text;

            PrefRepo.active.folders.extension = textBoxFolderExtension.Text;
            PrefRepo.active.folders.fileLandingService = textBoxFolderFLS.Text;

            PrefRepo.active.actSvcs.authName = textBoxAsUserName.Text;
            PrefRepo.active.actSvcs.authPassword = textBoxAsPassword.Text;

            PrefRepo.active.rpt.saveStatsReport = checkSaveStatRpt.Checked;
            PrefRepo.active.rpt.appendStatsReport = checkAppendStatsRpt.Checked;
            PrefRepo.active.rpt.rptFilename = textRptFile.Text;
        }

        private void buttonAccept_Click(object sender, EventArgs e)
        {
            pushControlToModel();
            this.Close();
        }


        private void browseExtension_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog op = new FolderBrowserDialog();

            if (op.ShowDialog() == DialogResult.Cancel)
                return;

            try
            {
                // extensionPath.Text = op.SelectedPath;
            }
            catch (Exception)
            {
                MessageBox.Show("Error opening file", "File Error",
                MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }
        }


        private void browseProject_Click(object sender, EventArgs e)
        {
            FolderBrowserDialog op = new FolderBrowserDialog();

            if (op.ShowDialog() == DialogResult.Cancel)
                return;

            try
            {
                // projectPath.Text = op.SelectedPath;
            }
            catch (Exception)
            {
                MessageBox.Show("Error opening file", "File Error",
                MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
            }

        }

        private void layoutNetMeterRow(Label label, TextBox textBox, ref int x1, ref int x2, ref int y)
        {
            label.Location = new Point(x1, y);
            textBox.Location = new Point(x2, y);
            textBox.Size = new Size(120, 21);
            y = Math.Max(label.Bottom, textBox.Bottom);
            x2 = Math.Max(x2, label.Right + 6);
            y += 8;
        }

        private void layoutNetMeter()
        {
            int x1, x2, y;
            x1 = 8;
            x2 = 10;
            y = 0;

            for (int ix = 0; ix < 2; ix++)
            {
                y = 20;
                layoutNetMeterRow(labelDbAddress, textBoxDbAddress, ref x1, ref x2, ref y);
                layoutNetMeterRow(labelDbPort, textBoxDbPort, ref x1, ref x2, ref y);
                layoutNetMeterRow(labelDbUserName, textBoxDbUserName, ref x1, ref x2, ref y); 
                layoutNetMeterRow(labelDbPassword, textBoxDbPassword, ref x1, ref x2, ref y);
                layoutNetMeterRow(labelDbDatabase, textBoxDbDatabase, ref x1, ref x2, ref y);
            }

            int ux = textBoxDbDatabase.Right;
            this.groupBoxNetMeter.Size = new Size(ux+6, y+2);
        }

        private void layoutAsRow(Label label, TextBox textBox, ref int x1, ref int x2, ref int y)
        {
            label.Location = new Point(x1, y);
            textBox.Location = new Point(x2, y);
            textBox.Size = new Size(120, 21);
            y = Math.Max(label.Bottom, textBox.Bottom);
            x2 = Math.Max(x2, label.Right + 6);
            y += 8;
        }

        private void layoutActSvcs()
        {
            int x1, x2, y;
            x1 = 8;
            x2 = 10;
            y = 0;

            for (int ix = 0; ix < 2; ix++)
            {
                y = 20;
                 layoutNetMeterRow(labelAsUserName, textBoxAsUserName, ref x1, ref x2, ref y);
                layoutNetMeterRow(labelAsPassword, textBoxAsPassword, ref x1, ref x2, ref y);
            }

            int ux = textBoxAsPassword.Right;
            this.groupBoxActSvcs.Size = new Size(ux + 6, y + 2);
        }

        private void layoutFolderRow(Label label, TextBox textBox, Button button, ref int x1, ref int x2, ref int y)
        {
            label.Location = new Point(x1, y);
            textBox.Location = new Point(x2, y);
            textBox.Size = new Size(300, 21);

            button.Location = new Point(textBox.Right + 6, y);

            y = Math.Max(label.Bottom, textBox.Bottom);
            x2 = Math.Max(x2, label.Right + 6);
            y += 8;
        }

        private void layoutFolders()
        {
            int x1, x2, y;
            x1 = 8;
            x2 = 10;
            y = 0;

            for (int ix = 0; ix < 2; ix++)
            {
                y = 20;
                layoutFolderRow(label6, textBoxFolderExtension, buttonFolderExtension, ref x1, ref x2, ref y);
                layoutFolderRow(label7, textBoxFolderFLS, buttonFolderFLS, ref x1, ref x2, ref y);
                layoutFolderRow(label8, textBoxVisualStudioProject, buttonFolderVisualStudio, ref x1, ref x2, ref y);
             }

            int ux = buttonFolderFLS.Right;
            this.groupBoxFolders.Size = new Size(ux + 6, y + 2);
        }

        private void checkSaveStatRpt_CheckedChanged(object sender, EventArgs e)
        {
            if (!checkSaveStatRpt.Checked)
                checkAppendStatsRpt.Checked = false;
        }

        private void checkAppendStatsRpt_CheckedChanged(object sender, EventArgs e)
        {
            if (checkAppendStatsRpt.Checked)
                checkSaveStatRpt.Checked = true;
        }

        private void FormPreferences_Layout(object sender, LayoutEventArgs e)
        {
			this.Location = new Point(10, 10);

			//// commented so I can see the layout in design mode
			//layoutNetMeter();
			//layoutFolders();
			//layoutActSvcs();

			//this.groupBoxNetMeter.Location = new Point(10, 10);
			//this.groupBoxActSvcs.Location = new Point(10, groupBoxNetMeter.Bottom + 20);
			//this.buttonAccept.Location = new Point(10, groupBoxActSvcs.Bottom + 20);

			//this.groupBoxFolders.Location = new Point(groupBoxNetMeter.Right+20, 10);
			//this.controlPreferences1.Location = new Point(groupBoxNetMeter.Right + 20, groupBoxFolders.Bottom + 20);
			//this.controlPreferences1.Size = new Size(this.groupBoxFolders.Size.Width, this.controlPreferences1.Size.Height);


        }

    }
}
