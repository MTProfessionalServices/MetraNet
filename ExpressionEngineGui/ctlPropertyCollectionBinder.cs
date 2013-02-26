using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;

namespace PropertyGui
{
    public partial class ctlPropertyCollectionBinder : UserControl
    {
        #region Properties
        public bool AllowProperty { get; set; }
        public bool AllowConstant { get; set; }
        public bool AllowExpression { get; set; }
        public bool ShowBinderIcon { get; set; }
        public ctlValueBinder.BindingTypeEnum DefaultBindingType { get; set; }
        private PropertyCollection PropertyCollection;
        private List<ctlValueBinder> ValueBinders = new List<ctlValueBinder>();
        private TableLayoutPanel TableLayout = new TableLayoutPanel();
        #endregion

        #region Constructor
        public ctlPropertyCollectionBinder()
        {
            InitializeComponent();
            AllowProperty = true;
            AllowConstant = true;
            AllowExpression = true;
            ShowBinderIcon = true;
        }
        #endregion

        #region Methods
        public void Init(Context context, PropertyCollection propertyCollection)
        {
            PropertyCollection = propertyCollection;

            TableLayout.SuspendLayout();

            TableLayout.Parent = this;
            TableLayout.Dock = DockStyle.Fill;
            TableLayout.AutoSize = true;

            TableLayout.ColumnCount = 2;
            TableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));
            TableLayout.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));

            TableLayout.RowCount = propertyCollection.Count;

            int index = 0;
            foreach (var property in propertyCollection)
            {
                TableLayout.RowStyles.Add(new RowStyle(SizeType.Absolute, 25f));

                //Create the parameter's label
                var label = new Label();
                label.Text = property.Name + ":";
                TableLayout.Controls.Add(label, 0, index);
                label.TextAlign = ContentAlignment.MiddleRight;
                toolTip.SetToolTip(label, property.Description);
                
                //Create the parameter's value binder
                var valueBinder = new ctlValueBinder();
                valueBinder.DefaultBindingType = DefaultBindingType;
                valueBinder.AllowConstant = AllowConstant;
                valueBinder.AllowExpression = AllowExpression;
                valueBinder.AllowProperty = AllowProperty;
                valueBinder.ShowBinderIcon = ShowBinderIcon;
                valueBinder.Init(context, property);
                //valueBinder.OnGotMyFocus = _valueBinderGotFocus;
                TableLayout.Controls.Add(valueBinder, 1, index);
                ValueBinders.Add(valueBinder);
                index++;
            }

            TableLayout.ResumeLayout();
        }

        public void Clear()
        {
            TableLayout.Controls.Clear();
        }

        public void SetDefaultValues()
        {
            foreach (var binder in ValueBinders)
            {
                binder.SetDefaultValue();
            }
        }

        public void SyncToForm()
        {
            foreach (var binder in ValueBinders)
            {
                binder.SyncToForm();
            }
        }

        public void SyncToObject()
        {
            foreach (var binder in ValueBinders)
            {
                binder.SyncToObject();
            }
        }

        #endregion
    }
}
