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
    public partial class ControlSvcDef : UserControl
    {
        private static readonly ILog log = LogManager.GetLogger(typeof(ControlSvcDef));

        public ControlSvcDef()
        {
            InitializeComponent();
        }

        private void ControlSvcDef_Load(object sender, EventArgs e)
        {
            log.Info("Loading");
            foreach (string key in Framework.SvcDefRepo.svcDefs.Keys)
            {
                ServiceDefn svcDef = Framework.SvcDefRepo.svcDefs[key];
                this.checkedListBoxServiceDef.Items.Add(svcDef.fullName);
            }
        }

        private void ButtonSvcDefGenDomain_Click(object sender, EventArgs e)
        {
            foreach (string key in this.checkedListBoxServiceDef.CheckedItems)
            {
                ServiceDefn sdef = Framework.SvcDefRepo.svcDefs[key];
                string folder = PrefRepo.active.folders.visualStudioProject;

                string fn = folder + @"\SvcDef" + sdef.shortName() + "Base.cs";
                StreamWriter writer = new StreamWriter(fn);
                sdef.generateDomainModel(writer);
                writer.Close();
            }
        }

        private void buttonGenerateFLSScripts_Click(object sender, EventArgs e)
        {
            log.Info("Generating FLS scripts");
            foreach (string key in this.checkedListBoxServiceDef.CheckedItems)
            {
                ServiceDefn sdef = Framework.SvcDefRepo.svcDefs[key];

                string fn = @"c:\temp\" + sdef.shortName() + ".mfs";

                StreamWriter writer = new StreamWriter(fn);
                sdef.generateMetraFlowScript(writer);
                writer.Close();
            }
        }

        private void button3_Click(object sender, EventArgs e)
        {

        }


    }
}
