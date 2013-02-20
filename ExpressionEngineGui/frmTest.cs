using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Test;

namespace PropertyGui
{
    public partial class frmTest : Form
    {
        #region Properties
        private Context Context;
        private ExpressionParseResults Results;
        #endregion

        #region Constructor
        public frmTest()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context)
        {
            Context = context;
            Results = Context.GetExpressionParseResults();

            btnEmail.Enabled = Context.EmailInstance != null;

            ctlProperties.DefaultBindingType = ctlValueBinder.BindingTypeEnum.Constant;
            ctlProperties.AllowExpression = false;
            ctlProperties.AllowProperty = false;
            ctlProperties.ShowBinderIcon = false;
            ctlProperties.Init(context, Results.Parameters);
        }

        private void Run(bool compare)
        {
            ctlProperties.SyncToObject();     
            EmailEngine.EvalutateExpressions(Context.EmailInstance, Results.Parameters);
            ctlProperties.SyncToForm();
        }
        #endregion

        #region Events
        private void btnRun_Click(object sender, EventArgs e)
        {
            Run(false);
        }

        private void btnEmail_Click(object sender, EventArgs e)
        {
            EmailEngine.Send(Context.EmailInstance);
        }
        #endregion
    }
}
