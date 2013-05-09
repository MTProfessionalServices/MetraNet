using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Data.Linq;
using System.Data.SqlClient;
using System.IO;

namespace Linqify
{
    public partial class FormMain : Form
    {

        public FormMain()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            NetMeterBuilder builder = new NetMeterBuilder();
            textBoxCode.Text = builder.buildFile().ToString();

            NetMeterCodeDom.buildIt();
        } 
    }
}
