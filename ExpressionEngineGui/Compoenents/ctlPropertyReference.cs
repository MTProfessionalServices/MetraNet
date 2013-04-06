using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace PropertyGui.Compoenents
{
    public delegate void PropertyCreated(Property property);

    public partial class ctlPropertyReference : UserControl
    {
        #region Properties
        public string PropertyName
        {
            get { return cboProperty.Text; }
            set { cboProperty.Text = value; }
        }

        private string DefaultSuffix;

        private Property Property;
        private Type Type;

        public PropertyCreated OnPropertyCreated; 
        #endregion

        #region Constructor
        public ctlPropertyReference()
        {
            InitializeComponent();
            Height = cboProperty.Height;
        }
        #endregion

        #region Methods
        public void Init(Property property, Type type, string defaultSuffix, PropertyCreated propertyCreatedEvent)
        {
            if (property == null)
                throw new ArgumentException("property is null");
            if (type == null)
                throw new ArgumentException("type is null");
            Property = property;
            Type = type;
            DefaultSuffix = defaultSuffix;
            OnPropertyCreated = propertyCreatedEvent;
        }
        #endregion

        #region Events
        private void cboProperty_DropDown(object sender, EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.Items.Clear();
            cboProperty.DisplayMember = "Name";
            var filteredProperties = Property.PropertyCollection.GetFilteredProperties(Type);
            foreach (var property in filteredProperties)
            {
                cboProperty.Items.Add(property);
            }
            cboProperty.Sorted = true;
            cboProperty.EndUpdate();
        }

        private void btnAddProperty_Click(object sender, EventArgs e)
        {
            var defaultName = Property.Name + DefaultSuffix;
            var dialog = new frmAddProperty(Property.PropertyCollection, Type, defaultName);
            if (dialog.ShowDialog() == DialogResult.Cancel)
                return;

            cboProperty.Text = dialog.NewProperty.Name;
            Property.PropertyCollection.Add(dialog.NewProperty);

            if (OnPropertyCreated != null)
                OnPropertyCreated(dialog.NewProperty);
        }
        #endregion
    }
}
