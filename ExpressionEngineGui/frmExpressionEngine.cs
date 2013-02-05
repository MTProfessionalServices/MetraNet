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
            ctlExpression.Init(Context);

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
            if (ctlExpression.SelectedText == "In")
            {
                var func = new frmFuncIn();
                func.Init(Context, "USAGE.c_DataCenterCountry", new List<string>() { "Germany" });
                if (DialogResult == func.ShowDialog())
                    ctlExpression.Paste(func.GetValue());

            }
        }

        private void button3_Click(object sender, EventArgs e)
        {
            var dialog = new frmFunctionBinder();
            dialog.Init(Context, "DateAdd");
            dialog.ShowDialog();
        }
        #endregion

    }
}
