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
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public partial class frmFuncIn : Form
    {
        #region Properties
        private Context Context;
        private List<string> InititalValues;
        #endregion

        #region Constructor
        public frmFuncIn()
        {
            InitializeComponent();
            MinimizeBox = false;
            MaximizeBox = false;
        }
        #endregion

        #region Methods
        public string GetValue()
        {
            var sb = new StringBuilder();
            sb.Append(string.Format("In({0}", ctlProp.Text));

            foreach (var value in lstSelected.Items)
            {
                sb.Append(string.Format(", {0}", value));
            }
            sb.Append(")");

            return sb.ToString();
        }
        public void Init(Context context, string propertyName, List<string> values)
        {
            Context = context;
            InititalValues = values;

            ctlProp.AllowConstant = false;
            ctlProp.AllowExpression = false;
            ctlProp.MinimumMatchType = MatchType.BaseTypeWithDiff;
            ctlProp.Init(Context, Property.CreateEnum(null, true, null, null));
            ctlProp.OnMyChange = OnMyChange;

            if (!string.IsNullOrWhiteSpace(propertyName))
                ctlProp.Text = propertyName;
        }

        public void LoadValues(EnumCategory enumType)
        {
            lstAvailable.Items.Clear();
            lstSelected.Items.Clear();
            if (enumType == null)
                return;

            foreach (var value in enumType.Items)
            {
                if (InititalValues != null && InititalValues.Contains(value.Name))
                    lstSelected.Items.Add(value.Name);
                else
                    lstAvailable.Items.Add(value.Name);
            }
        }

        private void MoveItems(ListBox from, ListBox to)
        {
            var remove = new List<object>();
            foreach (var value in from.SelectedItems)
            {
                to.Items.Add(value);
                remove.Add(value);
            }

            foreach (var value in remove)
            {
                from.Items.Remove(value);
            }
        }
        #endregion

        #region Events
        private void btnCancel_Click(object sender, EventArgs e)
        {
            DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.Close();
        }

        private void btnOK_Click(object sender, EventArgs e)
        {
            DialogResult = System.Windows.Forms.DialogResult.OK;
            this.Close();
        }

        public void OnMyChange()
        {
            Property property;
            if (!Context.TryGetPropertyFromAllProperties(ctlProp.Text, out property))
            {
                LoadValues(null);
                return;
            }

            var enumCategory = Context.GetEnumCategory((EnumerationType)property.Type);
            LoadValues(enumCategory);
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            MoveItems(lstAvailable, lstSelected);
        }

        private void btnRemove_Click(object sender, EventArgs e)
        {
            MoveItems(lstSelected, lstAvailable);
        }
        #endregion
    }
}
