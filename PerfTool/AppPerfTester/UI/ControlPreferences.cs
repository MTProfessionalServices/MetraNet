using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
using log4net;

namespace BaselineGUI
{
    public partial class ControlPreferences : UserControl
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlPreferences));

        public ControlPreferences()
        {
            InitializeComponent();
            textBox1.Text = PrefRepo.preferencesFile;
        }

        private void buttonSave_Click(object sender, EventArgs e)
        {
            log.Debug("Save");
            try
            {
                PrefRepo.preferencesFile = textBox1.Text;
                UserInterface.pushControlToModel();
                PrefRepo.Store(PrefRepo.active, PrefRepo.preferencesFile);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error Saving", MessageBoxButtons.OK, MessageBoxIcon.Error);
                throw;
            }

        }

        private void buttonLoad_Click(object sender, EventArgs e)
        {
            log.Debug("Load");
            try
            {
                PrefRepo.preferencesFile = textBox1.Text;
                PrefRepo.active = PrefRepo.Fetch(PrefRepo.preferencesFile);
                UserInterface.pushModelToControl();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error Restoring", MessageBoxButtons.OK, MessageBoxIcon.Error);
                throw;
            }

        }
    }
}
