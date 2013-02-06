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
            _DemoLoader.LoadGlobalContext();

            cboAqgs.DisplayMember = "Name";
            cboAqgs.Items.AddRange(_DemoLoader.GlobalContext.AQGs.Values.ToArray<AQG>());
            if (cboAqgs.Items.Count > 0)
                cboAqgs.SelectedIndex = 0;

            cboUqgs.DisplayMember = "Name";
            cboUqgs.Items.AddRange(_DemoLoader.GlobalContext.UQGs.Values.ToArray<UQG>());
            if (cboUqgs.Items.Count > 0)
                cboUqgs.SelectedIndex = 0;

            cboExpressions.DisplayMember = "Name";
            cboExpressions.Items.AddRange(_DemoLoader.GlobalContext.Expressions.Values.ToArray<Expression>());
            if (cboExpressions.Items.Count > 0)
                cboExpressions.SelectedIndex = 0;
        }
        #endregion

        #region Methods
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
        #endregion

        private void btnExpression_Click(object sender, EventArgs e)
        {
            var exp = (Expression)cboExpressions.SelectedItem;
            ShowExpression(exp);
        }

    }
}
