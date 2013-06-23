using System;
using System.Drawing;
using System.Windows.Forms;
using PropertyCollection = MetraTech.ExpressionEngine.MTProperties.PropertyCollection;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.Compoenents
{
    public partial class ctlPropertyBinder : UserControl
    {
        #region Properties
        public string Text {
            get { return cboProperty.Text; }
            set { cboProperty.Text = value; } }
        private PropertyCollection AvailableProperties;
        private MetraTech.ExpressionEngine.TypeSystem.Type Type;
        #endregion

        #region Constructor
        public ctlPropertyBinder()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(PropertyCollection availableProperties, MetraTech.ExpressionEngine.TypeSystem.Type type)
        {
            AvailableProperties = availableProperties;
            Type = type;
            cboProperty.Font = GuiHelper.ExpressionFont;
        }
        #endregion

        #region Events
        private void cboProperty_DropDown(object sender, EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.Items.Clear();
            cboProperty.DisplayMember = "FullName";
            var filteredProperties = AvailableProperties.GetFilteredProperties(Type);
            foreach (var property in filteredProperties)
            {
                cboProperty.Items.Add(property);
                var n = property.FullName;
            }
            cboProperty.Sorted = true;
            cboProperty.EndUpdate();
        }
        #endregion
    }
}
