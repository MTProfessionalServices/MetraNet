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
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public partial class frmLaunch : Form
    {
        #region Connstructor

        public frmLaunch()
        {
            InitializeComponent();
            MinimizeBox = false;

            LoadConfigComboBox(cboContext1, DemoLoader.TopLevelDataDir);
            LoadConfigComboBox(cboContext2, DemoLoader.TopLevelDataDir);

            cboContext1.Text = "Metanga";
            //cboContext2.Text = "Cloud";

            SyncToForm();
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

            //So that we can look things up in the next form, set the master context (creats a cycle, but shouldn't hurt anything)
            context.MasterContext = context;

            //If we had some loading issues, let the user know
            if (context.DeserilizationMessages.Count != 0)
            {
                var dialog = new frmValidationMessages(context.DeserilizationMessages, contextName);
                dialog.ShowDialog();
            }

            return context;
        }

        private void SyncToObject()
        {
            UserContext.Settings.DefaultEqualityOperator = cboEqualityOperator.Text;
            UserContext.Settings.DefaultInequalityOperator = cboInequalityOperator.Text;
            UserContext.Settings.ShowActualMappings = chkShowAcutalMappings.Checked;
            UserContext.Settings.AutoSelectInsertedSnippets = chkAutoSelectInsertedSnippets.Checked;
            UserContext.Settings.NewSyntax = chkNewSyntax.Checked;
        }

        private void SyncToForm()
        {
            cboEqualityOperator.Text = UserContext.Settings.DefaultEqualityOperator;
            cboInequalityOperator.Text = UserContext.Settings.DefaultInequalityOperator;
            chkShowAcutalMappings.Checked = UserContext.Settings.ShowActualMappings;
            chkAutoSelectInsertedSnippets.Checked = UserContext.Settings.AutoSelectInsertedSnippets;
            chkNewSyntax.Checked = UserContext.Settings.NewSyntax;
        }
        #endregion

        #region Events
        private void btnLoad_Click(object sender, EventArgs e)
        {
            SyncToObject();

            var context1 = GetContext(cboContext1.Text);
            var context2 = GetContext(cboContext2.Text);

            var dialog = new frmCompare(context1, cboContext1.Text, context2, cboContext2.Text);
            dialog.ShowDialog();
        }
        #endregion

        private void btnEditCompute_Click(object sender, EventArgs e)
        {
            var context = Context.LoadMetanga(@"C:\ExpressionEngine\Data\Metanga");
            context.AddEnumCategory(new EnumCategory(BaseType.UnitOfMeasure, "Scott", "DigitalInformation", 0, "Just a sample overlap"));
            var compute = ProductViewEntity.CreateCompute();
            context.AddPropertyBag(compute);
            var dialog = new frmPropertyBag(context, compute);
            dialog.ShowDialog();
        }

        private void btnInterCall_Click(object sender, EventArgs e)
        {
            var context = DemoLoader.CreateContext(ProductType.MetraNet, "InterCall");
            context.GlobalComponentCollection.Load();
            //var pv = (ProductViewEntity)context.GlobalComponentCollection.Get("intercall.com.ProductViews.Comm_InterCallConnection");
            //var pv = (ProductViewEntity)context.GlobalComponentCollection.Get("intercall.com.ProductViews.InterCallConnection");
            var pv = (ProductViewEntity)context.GlobalComponentCollection.Get("intercall.com.ProductViews.InterCallFeature");
            var dialog = new frmPropertyBag(context, pv);
            dialog.ShowDialog();
        }

    }
}
