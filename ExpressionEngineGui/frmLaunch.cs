using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions.Enumerations;

namespace PropertyGui
{
    public partial class frmLaunch : Form
    {
        #region Connstructor

        public frmLaunch()
        {
            InitializeComponent();
            LoadConfigComboBox(cboContext1, DemoLoader.TopLevelDataDir);
            LoadConfigComboBox(cboContext2, DemoLoader.TopLevelDataDir);

            cboContext1.Text = "Metanga";
            //cboContext2.Text = "Cloud";
        }

        #endregion

        #region Methods
        private void LoadConfigComboBox(ComboBox cbo, string dirPath)
        {
            var dirInfo = new DirectoryInfo(dirPath);
            cbo.BeginUpdate();
            foreach (var subDirInfo in dirInfo.GetDirectories())
            {
                cbo.Items.Add(subDirInfo.Name);
            }

            cbo.EndUpdate();
        }

        private Context GetContext(string contextName)
        {
            if (string.IsNullOrEmpty(contextName))
                return null;
           
            ProductType productType;
            if (contextName == "Metanga")
                productType = ProductType.Metanga;
            else
                productType = ProductType.MetraNet;

            //Load the context
            var context = DemoLoader.CreateContext(productType, contextName);

            //If we had some loading issues, let the user know
            if (context.DeserilizationMessages.Count != 0)
            {
                var dialog = new frmValidationMessages(context.DeserilizationMessages, contextName);
                dialog.ShowDialog();
            }

            return context;
        }
        #endregion

        #region Events
        private void btnLoad_Click(object sender, EventArgs e)
        {
            var context1 = GetContext(cboContext1.Text);
            var context2 = GetContext(cboContext2.Text);

            var dialog = new frmCompare(context1, cboContext1.Text, context2, cboContext2.Text);
            dialog.ShowDialog();
        }
        #endregion
    }
}
