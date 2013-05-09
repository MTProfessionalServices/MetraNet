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
    public class ControlAMTabPage : TabPage
    {
        List<ControlAM> amCtls = new List<ControlAM>();

        public ControlAMTabPage(string groupName)
        {
            this.Text = groupName;
            this.AutoScroll = true;

            List<AppMethodI> ams = AppMethodFactory.getGroup(groupName);
            foreach (AppMethodI am in ams)
            {
                ControlAM ctl = new ControlAM();
                amCtls.Add(ctl);
                ctl.BeginInit();
                ctl.am_methodName = am.name;
                ctl.EndInit();
                this.Controls.Add(ctl);
            }


            this.Layout += new LayoutEventHandler(this.doLayout);
            this.ResumeLayout();
            this.PerformLayout();
        }


        public void doLayout(object sender, LayoutEventArgs e)
        {
            int x, y;
            x = 8;
            y = 8;
            foreach (var ctl in amCtls)
            {
                ctl.Location = new Point(x, y);
                y = ctl.Bottom + 8;
            }
        }

    }
}
