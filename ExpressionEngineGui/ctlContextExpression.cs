using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace PropertyGui
{
    public partial class ctlContextExpression : ctlContextBase
    {
        #region Constructor
        public ctlContextExpression()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public override void Init(MetraTech.ExpressionEngine.Context context)
        {
            base.Init(context);
            ctlExpression.Init(context, null);
        }

        #region Methods
        public override void InsertSnippet(string snippet)
        {
            ctlExpression.InsertSnippet(snippet);
        }

        public override void HandleTreeEvent(MetraTech.ExpressionEngine.IExpressionEngineTreeNode item, string value)
        {
            ctlExpression.HandleTreeEvent(item, value);
        }
        #endregion

        #endregion
    }
}
