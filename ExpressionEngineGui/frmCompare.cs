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
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Placeholders;

namespace PropertyGui
{
    public partial class frmCompare : Form
    {
        #region Properties
        private bool IgnoreChanges = false;
        #endregion

        #region Constructor
        public frmCompare(string dirPath, string context1=null, string context2=null)
        {
            InitializeComponent();
            MinimizeBox = false;
            WindowState = FormWindowState.Maximized;
            Init(dirPath, context1, context2);
        }
        #endregion

        #region Methods

        private void Init(string dirPath, string context1=null, string context2=null)
        {
            IgnoreChanges = true;

            //Set the view modes
            cboViewMode.BeginUpdate();
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Entities);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Enumerations);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.AQGs);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.UQGs);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Emails);
            cboViewMode.Items.Add(MvcAbstraction.ViewModeType.Functions);
            cboViewMode.Sorted = true;
            cboViewMode.SelectedItem = MvcAbstraction.ViewModeType.Entities;
            cboViewMode.EndUpdate();

            //Set the entity types
            cboEntityTypeFilter.Text = PropertyBagConstants.AnyFilter;

            //Load the "Data Directories"
            LoadConfigComboBox(cboContext1, dirPath);
            LoadConfigComboBox(cboContext2, dirPath);

            IgnoreChanges = false;

            //if (!string.IsNullOrEmpty(context1))
            //    cboContext1.Text = context1;
            //if (!string.IsNullOrEmpty(context2))
            //    cboContext2.Text = context2;
        }

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

        #endregion

        #region Events
        private void cboContext_SelectedIndexChanged(object sender, EventArgs e)
        {
            var comboBox = (ComboBox)sender;

            ProductType productType;
            if (comboBox.Text == "Metanga")
                productType = ProductType.Metanga;
            else
                productType = ProductType.MetraNet;

            //Load the context
            //DemoLoader.LoadGlobalContext(productType, comboBox.Text);
            var context = DemoLoader.CreateContext(productType, comboBox.Text);

            //If we had some loading issues, let the user know
            if (context.DeserilizationMessages.Count != 0)
            {
                var dialog = new frmValidationMessages(context.DeserilizationMessages);
                dialog.ShowDialog();
            }

            //Update the appropriate tree
            ctlExpressionTree tree;
            if (comboBox.Equals(cboContext1))
                tree = treContext1;
            else
                tree = treContext2;

            tree.Tag = context;
            tree.Init(context, null);
            UpdateTree(tree);
        }

        private void UpdateTrees()
        {
            UpdateTree(treContext1);
            UpdateTree(treContext2);
        }
        public void UpdateTree(ctlExpressionTree tree)
        {
            tree.ViewMode = (MvcAbstraction.ViewModeType)cboViewMode.SelectedItem;
            tree.EntityTypeFilter = PropertyBagConstants.AnyFilter;// (string)cboEntityTypeFilter.SelectedItem.ToString();
            //tree.PropertyTypeFilter = (Type)cboPropertyTypeFilter.SelectedItem;
            tree.FunctionFilter = cboCategory.Text;
            tree.LoadTree();
        }
        #endregion


        #region Events

        private void cboViewMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!IgnoreChanges)
                UpdateTrees();
        }
        #endregion

        private void treContext1_NodeMouseDoubleClick(object sender, TreeNodeMouseClickEventArgs e)
        {
            var tag = e.Node.Tag;
            var c1 = (Context)e.Node.TreeView.Tag;
            DemoLoader.GlobalContext = c1;
            if (tag is EmailInstance)
            {
                var emailInstance = (EmailInstance) tag;
                emailInstance.UpdateEntityParameters();
                var dialog = new frmExpressionEngine();
                var context = new Context(ProductType.Metanga, emailInstance.BodyExpression, emailInstance);
                dialog.Init(context, emailInstance);
                dialog.ShowDialog();
            }
            else if (tag is Aqg)
            {
                ShowExpression(c1.ProductType, ((Aqg)tag).Expression);
            }
            else if (tag is Uqg)
            {
                ShowExpression(c1.ProductType, ((Uqg) tag).Expression);
            }

        }

        private void ShowExpression(ProductType productType, Expression expression, bool isPageLayout = false)
        {
            var dialog = new frmExpressionEngine();
            var context = new Context(productType, expression);
            dialog.Init(context, isPageLayout);
            dialog.ShowDialog();
        }
    }
}
