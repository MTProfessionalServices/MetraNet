using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using PropertyGui.Compoenents;
using PropertyCollection = MetraTech.ExpressionEngine.MTProperties.PropertyCollection;

namespace PropertyGui
{
    public partial class ctlBasicPropertyCollectionBinder : UserControl
    {
        #region Properties
        private PropertyCollection PropertyCollection;
        private List<ctlPropertyBinder> ValueBinders = new List<ctlPropertyBinder>();
        private TableLayoutPanel TableLayout;
        #endregion

        #region Constructor
        public ctlBasicPropertyCollectionBinder()
        {
            InitializeComponent();
        }        
        #endregion

        #region Methods
        public void Init(Context context, PropertyCollection propertyCollection, List<string> values, PropertyCollection availableProperties)
        {
            PropertyCollection = propertyCollection;

            TableLayout = new TableLayoutPanel();
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

                //Create the parameter's property binder
                var propertyBinder = new ctlPropertyBinder();
                propertyBinder.Width = 250;
                TableLayout.Controls.Add(propertyBinder, 1, index);
                propertyBinder.Init(availableProperties, property.Type);
                if (index < values.Count)
                    propertyBinder.Text = values[index];
                ValueBinders.Add(propertyBinder);
                index++;
            }

            TableLayout.ResumeLayout();
        }

        public void Clear()
        {
            TableLayout.Controls.Clear();
        }

        public List<string> GetValues()
        {
            var values = new List<string>();
            foreach (var ctlPropertyBinder in ValueBinders)
            {
                values.Add(ctlPropertyBinder.Text);
            }
            return values;
        }

        #endregion
    }
}
