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
using System.Runtime.Serialization;
using System.Xml;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.Placeholders;

namespace PropertyGui
{
    public partial class frmMain : Form
    {
        #region Constructor
        public frmMain()
        {
            InitializeComponent();

            cboContext.BeginUpdate();
            cboContext.DropDownStyle = ComboBoxStyle.DropDownList;
            var dirInfo = new DirectoryInfo(Path.Combine(DemoLoader.TopLevelDataDir));
            foreach (var dir in dirInfo.GetDirectories())
            {
                cboContext.Items.Add(dir.Name);

            }
            cboContext.SelectedIndex = 0;
            cboContext.EndUpdate();

            LoadCombo(cboEqualityOperator, ExpressionHelper.EqualityOperators);
            cboEqualityOperator.Text = UserContext.Settings.DefaultEqualityOperator;
            LoadCombo(cboInequalityOperator, ExpressionHelper.InequalityOperators);
            cboInequalityOperator.Text = UserContext.Settings.DefaultInequalityOperator;
            chkShowAcutalMappings.Checked = UserContext.Settings.ShowActualMappings;
            chkAutoSelectInsertedSnippets.Checked = UserContext.Settings.AutoSelectInsertedSnippets;
            chkNewSyntax.Checked = UserContext.Settings.NewSyntax;
        }

        private void LoadCombo<T>(ComboBox cbo, IEnumerable<T> items)
        {
           foreach (var item in items)
           {
               cbo.Items.Add(item);
           }
        }

        private void LoadContext()
        {
            ProductType product;
            if (cboContext.Text == "Metanga")
                product = ProductType.Metanga;
            else
                product = ProductType.MetraNet;

            DemoLoader.LoadGlobalContext(product, cboContext.Text);

            SetItems(cboAqgs, btnAQG, DemoLoader.GlobalContext.Aqgs.Values.ToArray<Aqg>());
            SetItems(cboUqgs, btnUQG, DemoLoader.GlobalContext.Uqgs.Values.ToArray<Uqg>());
            SetItems(cboExpressions, btnExpression, DemoLoader.GlobalContext.Expressions.Values.ToArray<Expression>());
            SetItems(cboEmailTemplates, btnEmailTemplates, DemoLoader.GlobalContext.EmailInstances.Values.ToArray<EmailInstance>());
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
            UserContext.Settings.DefaultEqualityOperator = cboEqualityOperator.Text;
            UserContext.Settings.DefaultInequalityOperator = cboInequalityOperator.Text;
            UserContext.Settings.ShowActualMappings = chkShowAcutalMappings.Checked;
            UserContext.Settings.AutoSelectInsertedSnippets = chkAutoSelectInsertedSnippets.Checked;
            UserContext.Settings.NewSyntax = chkNewSyntax.Checked;
        }

        private void SyncToForm()
        {
            chkNewSyntax.Checked = UserContext.Settings.NewSyntax;
        }

        private void ShowExpression(Expression expression, bool isPageLayout=false)
        {
            SyncToObject();
            var dialog = new frmExpressionEngine();
            var context = new Context(expression);
            dialog.Init(context, isPageLayout);
            dialog.ShowDialog();
        }
        #endregion

        #region Events
        private void btnAQG_Click(object sender, EventArgs e)
        {
            var aqg = (Aqg)cboAqgs.SelectedItem;
            ShowExpression(aqg.Expression);
        }


        private void btnUQG_Click(object sender, EventArgs e)
        {
            var uqg = (Uqg)cboUqgs.SelectedItem;
            ShowExpression(uqg.Expression);
        }

        private void btnExplorer_Click(object sender, EventArgs e)
        {
            var dialog = new frmGlobalExplorer();
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

        private void btnPageLayout_Click(object sender, EventArgs e)
        {
            ShowExpression(new Expression(ExpressionType.Email, "", null), true);
        }

        private void btnEmailTemplates_Click(object sender, EventArgs e)
        {
            var emailInstance = (EmailInstance)cboEmailTemplates.SelectedItem;
            emailInstance.UpdateEntityParameters();
            var dialog = new frmExpressionEngine();
            var context = new Context(emailInstance.BodyExpression, emailInstance);
            dialog.Init(context, emailInstance);
            dialog.ShowDialog();
        }

        #endregion


        private void btnSendEvent_Click(object sender, EventArgs e)
        {
            var dialog = new frmSendEvent();
            dialog.Init(DemoLoader.GlobalContext);
            dialog.ShowDialog();
        }

        private void btnValidate_Click(object sender, EventArgs e)
        {
            var messages = DemoLoader.GlobalContext.Validate();
            var dialog = new frmValidationMessages(messages);
            dialog.ShowDialog();
        }


    }
}
