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
    public partial class ctlContextPageLayout : ctlContextBase
    {
        #region Properties
        public ctlContextPageLayout()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void InsertSnippet(string snippet)
        {
            //Do nothing
        }

        public override void HandleTreeEvent(MetraTech.ExpressionEngine.IExpressionEngineTreeNode item, string value)
        {
            //Do nothing
        }
        #endregion
    }
}
