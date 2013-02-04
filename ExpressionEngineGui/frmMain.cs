using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;

namespace PropertyGui
{
    public partial class frmMain : Form
    {
        #region Properties
        #endregion

        #region Constructor
        public frmMain()
        {
            InitializeComponent();
         
        }
        #endregion

        private void btnApply_Click(object sender, EventArgs e)
        {
            Settings.NewSyntax = chkNewSyntax.Checked;
        }

    }
}
