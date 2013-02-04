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
        public void Init(Context context, string name)
        {
            Context = context;
            txtName.Text = name;

            Function = Context.TryGetFunction(name);
            if (Function == null)
                return;

            table.RowCount = Function.FixedParameters.Count;

            int index = 0;
            foreach (var parameter in Function.FixedParameters)
            {
                //table.RowStyles.Add(new RowStyle(SizeType.Absolute, 24), ;

                //Create the parameter's label
                var label = new Label();
                label.Text = parameter.Name + ":";
                table.Controls.Add(label, 0, index);
                label.TextAlign = ContentAlignment.MiddleRight;

                //Create the parameter's value binder
                var valueBinder = new ctlValueBinder();
                valueBinder.Init(Context, parameter);
                valueBinder.OnGotMyFocus = _valueBinderGotFocus;
                table.Controls.Add(valueBinder, 1, index);
                ValueBinders.Add(valueBinder);
                index++;
            }

            txtName_MouseClick(null, null);

            //if (Function.Parameters.Count > 0)
            //    firstBinder.SetFocus();
        }

        public string GetExpression()
        {
            var sb = new StringBuilder();
            sb.Append(string.Format("{0}(", Function.Name));
            return sb.ToString();
        }
        #endregion

        #region Events
        private void _valueBinderGotFocus(Property property)
        {
            lblHelp.Text = property.Name;
            txtParameterDescription.Text = property.Description;
        }
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

  

        private void txtName_MouseClick(object sender, MouseEventArgs e)
        {
            lblHelp.Text = Function.Name;
            txtParameterDescription.Text = Function.Description;
        }

        #endregion


    }
}
