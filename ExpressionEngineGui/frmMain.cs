using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using System.IO;

namespace PropertyGui
{
    public partial class frmMain : Form
    {
        #region Properties
        private Context Context;
        #endregion

        #region Constructor
        public frmMain()
        {
            InitializeComponent();

            cboContext.BeginUpdate();
            cboContext.DropDownStyle = ComboBoxStyle.DropDownList;
            var dirInfo = new DirectoryInfo(Path.Combine(_DemoLoader.TopLevelDataDir));
            foreach (var dir in dirInfo.GetDirectories())
            {
                cboContext.Items.Add(dir.Name);

            }
            cboContext.SelectedIndex = 0;
            cboContext.EndUpdate();
        }

        private void LoadContext()
        {
            Context.ProductTypeEnum product;
            if (cboContext.Text == "Metanga")
                product = Context.ProductTypeEnum.Metanga;
            else
                product = Context.ProductTypeEnum.MetraNet;

            _DemoLoader.LoadGlobalContext(product, cboContext.Text);

            SetItems(cboAqgs, btnAQG, _DemoLoader.GlobalContext.AQGs.Values.ToArray<AQG>());
            SetItems(cboUqgs, btnUQG, _DemoLoader.GlobalContext.UQGs.Values.ToArray<UQG>());
            SetItems(cboExpressions, btnExpression, _DemoLoader.GlobalContext.Expressions.Values.ToArray<Expression>());
        }
        #endregion

        #region Methods

        private void SetItems(ComboBox cbo, Button btn, object[] list)
        {
            cbo.Items.Clear();
            cbo.Text = String.Empty;
            cbo.DisplayMember = "Name";
            cbo.Items.AddRange(list);
            if (cbo.Items.Count > 0)
                cbo.SelectedIndex = 0;
            btn.Enabled = cbo.Items.Count > 0;
        }

        private void SyncToObject()
        {
            Settings.NewSyntax = chkNewSyntax.Checked;
        }

        private void SyncToForm()
        {
            chkNewSyntax.Checked = Settings.NewSyntax;
        }

        private void ShowExpression(Expression expression)
        {
            SyncToObject();
            var dialog = new frmExpressionEngine();
            var context = new Context(expression);
            dialog.Init(context);
            dialog.ShowDialog();
        }
        #endregion

        #region Events
        private void btnAQG_Click(object sender, EventArgs e)
        {
            var aqg = (AQG)cboAqgs.SelectedItem;
            ShowExpression(aqg.Expression);
        }


        private void btnUQG_Click(object sender, EventArgs e)
        {
            var uqg = (UQG)cboUqgs.SelectedItem;
            ShowExpression(uqg.Expression);
        }

        private void btnExplorer_Click(object sender, EventArgs e)
        {
            var dialog = new frmExplorer();
            dialog.ShowDialog();
        }

        private void btnExpression_Click(object sender, EventArgs e)
        {
            var exp = (Expression)cboExpressions.SelectedItem;
            ShowExpression(exp);
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            LoadContext();
        }
        #endregion

        private void btnSave_Click(object sender, EventArgs e)
        {
            _DemoLoader.GlobalContext.Save();
        }


    }
}
