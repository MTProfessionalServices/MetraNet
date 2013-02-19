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


            cboEqualityOperator.Items.AddRange(Expression.EqualityOperators);
            cboEqualityOperator.Text = UserSettings.DefaultEqualityOperator;
            cboInequalityOperator.Items.AddRange(Expression.InequalityOperators);
            cboInequalityOperator.Text = UserSettings.DefaultInequalityOperator;
            chkShowAcutalMappings.Checked = UserSettings.ShowActualMappings;
            chkAutoSelectInsertedSnippets.Checked = UserSettings.AutoSelectInsertedSnippets;
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
            SetItems(cboEmailTemplates, btnEmailTemplates, _DemoLoader.GlobalContext.EmailTemplates.Values.ToArray<EmailTemplate>());
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
            UserSettings.DefaultEqualityOperator = cboEqualityOperator.Text;
            UserSettings.DefaultInequalityOperator = cboInequalityOperator.Text;
            UserSettings.ShowActualMappings = chkShowAcutalMappings.Checked;
            UserSettings.AutoSelectInsertedSnippets = chkAutoSelectInsertedSnippets.Checked;
            UserSettings.NewSyntax = chkNewSyntax.Checked;
        }

        private void SyncToForm()
        {
            chkNewSyntax.Checked = UserSettings.NewSyntax;
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
            ShowExpression(new Expression(Expression.ExpressionTypeEnum.Email, ""), true);
        }

        private void btnEmailTemplates_Click(object sender, EventArgs e)
        {
            var emailTemplate = (EmailTemplate)cboEmailTemplates.SelectedItem;
            var dialog = new frmExpressionEngine();
            var exp = new Expression(Expression.ExpressionTypeEnum.Email, null);
            exp.EntityParameters.AddRange(emailTemplate.EntityParameters.ToArray());
            var context = new Context(exp);
            dialog.Init(context, emailTemplate);
            dialog.ShowDialog();
        }

        #endregion

        private void button1_Click(object sender, EventArgs e)
        {
            var dirInfo = new DirectoryInfo(@"C:\Temp\Functions");
            if (!dirInfo.Exists)
                dirInfo.Create();
            foreach (var func in _DemoLoader.GlobalContext.Functions.Values)
            {
                var filePath = string.Format(@"{0}\{1}.xml", dirInfo.FullName, func.Name);
                var writer = new FileStream(filePath, FileMode.Create);
                var ser = new DataContractSerializer(typeof(Function));
                ser.WriteObject(writer, func);
                writer.Close();
            }
        }

    }
}
