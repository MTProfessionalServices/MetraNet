using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace PropertyGui.Compoenents
{
    public partial class ctlPropertyReference : UserControl
    {
        #region Properties
        public string PropertyName
        {
            get { return cboProperty.Text; }
            set { cboProperty.Text = value; }
        }

        private string DefaultName;

        private PropertyCollection Properties;
        private Type Type;
        #endregion

        #region Constructor
        public ctlPropertyReference()
        {
            InitializeComponent();
            Height = cboProperty.Height;
        }
        #endregion

        #region Methods
        public void Init(PropertyCollection properties, Type type, string defaultName)
        {
            if (properties == null)
                throw new ArgumentException("properties is null");
            if (type == null)
                throw new ArgumentException("type is null");
            Properties = properties;
            Type = type;
            DefaultName = defaultName;
        }
        #endregion

        #region Events
        private void cboProperty_DropDown(object sender, EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.Items.Clear();
            cboProperty.DisplayMember = "Name";
            var filteredProperties = Properties.GetFilteredProperties(Type);
            foreach (var property in filteredProperties)
            {
                cboProperty.Items.Add(property);
            }
            cboProperty.Sorted = true;
            cboProperty.EndUpdate();
        }

        private void btnAddProperty_Click(object sender, EventArgs e)
        {
            var dialog = new frmAddProperty(Properties, Type, DefaultName);
            if (dialog.ShowDialog() == DialogResult.Cancel)
                return;

            cboProperty.Text = dialog.NewProperty.Name;
            Properties.Add(dialog.NewProperty);
            //Want to refresh the tree!
        }
        #endregion
    }
}
