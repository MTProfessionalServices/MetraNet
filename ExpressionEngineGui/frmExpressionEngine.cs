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
    public partial class frmExpressionEngine : Form
    {
        #region Properties
        private Context Context;
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
        public void Init(Context context)
        {
            Context = context;
            ctlExpressionExplorer.Init(Context);
            ctlExpression.Init(Context, mnuExpressionContext);

            if (context.Expression.Type == Expression.ExpressionTypeEnum.Email)
            {
                panEmail.Visible = true;
                ctlExpression.Top = panEmail.Bottom;
                txtTo.Text = "Invoice.Payer.Email";
                txtCc.Text = "Invoice.Payer.AccountManager.Email";
                txtSubject.Text = "Late payment for invoice {Invoice.InvoiceNumber}";
            }
            else
            {
                panEmail.Visible = false;
                ctlExpression.Top = btnCheckSyntax.Bottom + 5;
            }

            Text = string.Format("Expression Engine ({0})", Context.Expression.Type.ToString());
        }

        #endregion

        #region Events
        public void _OnS2DoubleClick(object item, string value)
        {
            ctlExpression.HandleTreeEvent((IExpressionEngineTreeNode)item, value);
        }

        public void _OnInsertSnippet(string snippet)
        {
            ctlExpression.InsertSnippet(snippet);
        }
        
        private void btnFunction_Click(object sender, EventArgs e)
        {
            //var funcName = ctlExpression.SelectedText;
            //if (funcName == "In")
            //{
            //    var func = new frmFuncIn();
            //    func.Init(Context, null, null);
            //    if (DialogResult.OK == func.ShowDialog())
            //        ctlExpression.Paste(func.GetValue());
            //    return;
            //}

            //var function = Context.TryGetFunction(funcName);
            //if (function == null)
            //{
            //    MessageBox.Show(string.Format("Unable to find function '{0}'", funcName));
            //    return;
            //}

            //var dialog = new frmFunctionBinder();
            //dialog.Init(Context, function);
            //if (DialogResult.OK == dialog.ShowDialog())
            //    ctlExpression.Paste(dialog.GetExpression());
        }

        private void mnuContext_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem.Equals(mnuEditFunction))
                ctlExpression.EditFunction();
        }

        private void ctlExpression_DoubleClick(object sender, EventArgs e)
        {
            ctlExpression.EditFunction();
        }


        private void btnCheckSyntax_Click(object sender, EventArgs e)
        {
            MessageBox.Show("According to Jonah, you're a wimp if you clicked on this button... 'Cowboy up and get it right the first time'");
        }
        #endregion

    }
}
