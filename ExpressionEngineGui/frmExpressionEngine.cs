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
        }
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;
            ctlExpressionExplorer.Init(Context);
            ctlExpression.Init(Context, mnuContext);

            Text = string.Format("Expression Engine ({0})", Context.Expression.Type.ToString());
        }

        #endregion

        #region Events
        public void _OnS2DoubleClick(object item)
        {
            ctlExpression.HandleTreeEvent((IExpressionEngineTreeNode)item);
            //var str = ((IExpressionEngineTreeNode)item).ToExpression;
            //ctlExpression.Paste(str);
        }

        private void btnFunction_Click(object sender, EventArgs e)
        {
            var funcName = ctlExpression.SelectedText;
            if (funcName == "In")
            {
                var func = new frmFuncIn();
                func.Init(Context, null, null);// "USAGE.c_DataCenterCountry", new List<string>() { "Germany" });
                if (DialogResult.OK == func.ShowDialog())
                    ctlExpression.Paste(func.GetValue());
                return;
            }

            var function = Context.TryGetFunction(funcName);
            if (function == null)
            {
                MessageBox.Show(string.Format("Unable to find function '{0}'", funcName));
                return;
            }

            var dialog = new frmFunctionBinder();
            dialog.Init(Context, function);
            if (DialogResult.OK == dialog.ShowDialog())
                ctlExpression.Paste(dialog.GetExpression());
        }
        #endregion

        private void mnuContext_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem.Equals(mnuEditFunction))
                ctlExpression.EditFunction();
        }

        private void ctlExpression_DoubleClick(object sender, EventArgs e)
        {
            ctlExpression.EditFunction();
        }

    }
}
