using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;

namespace PropertyGui
{
    public partial class frmFunctionBinder : Form
    {
        #region Properties
        private Context Context;
        private Function Function;
        private List<ctlValueBinder> ValueBinders = new List<ctlValueBinder>();
        #endregion

        #region Constructor
        public frmFunctionBinder()
        {
            InitializeComponent();
            MinimizeBox = false;
            MaximizeBox = false;
        }
        #endregion

        #region Methods
        public void Init(Context context, Function function)
        {
            Context = context;
            Function = function;

            txtName.Text = Function.Name;

            ctlParameters.Init(Context, Function.FixedParameters);
        }

        public string GetExpression()
        {
            var sb = new StringBuilder();
            sb.Append(string.Format("{0}(", Function.Name));

            for (int index=0; index < ValueBinders.Count; index++)
            {
                if (index > 0)
                    sb.Append(", ");
                sb.Append(ValueBinders[index].Text);
            }
            sb.Append(")");
            return sb.ToString();
        }
        #endregion

        #region Events

        private void btnOK_Click(object sender, EventArgs e)
        {
            DialogResult = System.Windows.Forms.DialogResult.OK;
            Close();
        }


        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = System.Windows.Forms.DialogResult.Cancel;
            Close();
        }

       #endregion

    }
}
