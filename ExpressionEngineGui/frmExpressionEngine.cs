using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;

namespace PropertyGui
{
    public partial class frmExpressionEngine : Form
    {
        #region Properties
        private Context Context;
        private ctlContextBase ctlContextBase;
        #endregion

        #region Constructor
        public frmExpressionEngine()
        {
            InitializeComponent();
            ctlExpressionExplorer.OnS2DoubleClick = _OnS2DoubleClick;
            ctlExpressionExplorer.OnInsertSnippet = _OnInsertSnippet;
            WindowState = FormWindowState.Maximized;
        }
        #endregion

        #region Methods

        public void Init(Context context, EmailInstance emailTemplate)
        {
            var ctlEmail = new ctlContextEmail();
            ctlEmail.Init(context, emailTemplate);
            ctlContextBase = ctlEmail;
            internalInit(context, "Email Template");
        }

        public void Init(Context context, bool isPageLayout)
        {
            Context = context;
            ctlExpressionExplorer.Init(Context);

            string title;
            if (isPageLayout)
            {
                ctlContextBase = new ctlContextPageLayout();
                title = "Page Layout";
            }
            else
            {
                ctlContextBase = new ctlContextExpression();
                title = Context.Expression.Type.ToString();
                ctlContextBase.DoubleClick += new EventHandler(ctlContextBase_DoubleClick);
            }
            ctlContextBase.Init(Context);
            internalInit(context, title);
        }

        void ctlContextBase_DoubleClick(object sender, EventArgs e)
        {
            ctlContextBase.EditFunction();
        }


        private void internalInit(Context context, string title)
        {
            Context = context;
            ctlExpressionExplorer.Init(Context);
            ctlContextBase.Parent = panEdit;
            ctlContextBase.Dock = DockStyle.Fill;


            Text = string.Format("Expression Engine ({0})", title);
        }
        #endregion

        #region Events
        public void _OnS2DoubleClick(object item, string value)
        {
            ctlContextBase.HandleTreeEvent((IExpressionEngineTreeNode)item, value);
        }

        public void _OnInsertSnippet(string snippet)
        {
            ctlContextBase.InsertSnippet(snippet);
        }

        private void mnuContext_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem.Equals(mnuEditFunction))
                ctlContextBase.EditFunction();
        }

        private void ctlExpression_DoubleClick(object sender, EventArgs e)
        {
            ctlContextBase.EditFunction();
        }

        private void btnValidate_Click(object sender, EventArgs e)
        {
            ValidateExpression(true);
        }

        private bool ValidateExpression(bool showSucessMessage)
        {
            ExpressionParseResults results;
            if (Context.EmailInstance != null)
                results = Context.EmailInstance.ParseAndBindResults(Context);
            else
                results = Context.Expression.ParseAndBindResults(Context);

            if (results.Messages.ErrorCount == 0 && !showSucessMessage)
                return true;

            var icon = MvcAbstraction.GetMessageBoxIcon(results.Messages.HighestSeverity);

            string message;
            if (results.Messages.ErrorCount == 0)
                message = "Expression is valid."; //Localization.
            else
                message = results.Messages.GetSummary(true);

            MessageBox.Show(message, "Validation Results", MessageBoxButtons.OK, icon);
            return results.Messages.ErrorCount == 0;
        }
        private void btnTest_Click(object sender, EventArgs e)
        {
            if (!ValidateExpression(false))
                return;

            var dialog = new frmTest();
            dialog.Init(Context);
            dialog.ShowDialog();
        }
        #endregion

    }
}
