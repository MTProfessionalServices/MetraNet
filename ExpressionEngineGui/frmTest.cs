using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Expressions;
using MetraTech.ExpressionEngine.UserTest;

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

        private void SyncToForm()
        {
            ctlProperties.SyncToForm();
        }

        private void Run(bool compare)
        {
            ctlProperties.SyncToObject();     
            EmailEngine.EvaluateExpressions(Context.EmailInstance, Results.Parameters);
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
            SyncToForm();
            try
            {
                EmailEngine.Send(Results.Parameters);
                MessageBox.Show("Email sent", null, MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error: " + ex.Message, null, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }

        }

        private void btnLookup_Click(object sender, EventArgs e)
        {
            var data = new List<KeyValuePair<string, string>>();
            data.Add(new KeyValuePair<string, string>("Invoice.InvoiceNumber", "12812"));
            data.Add(new KeyValuePair<string, string>("Payer.FirstName", "12812"));
            data.Add(new KeyValuePair<string, string>("Invoice.Statement.EndingBalance", "235.34"));
            SyncToForm();
        }
        #endregion
    }
}
