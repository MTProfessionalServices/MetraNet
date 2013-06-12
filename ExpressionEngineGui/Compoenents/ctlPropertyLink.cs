using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui.Compoenents
{
    public partial class ctlPropertyLink : UserControl
    {
        #region Properties
        private PropertyLink PropertyLink;
        private string DefaultNewPropertyName;
        private PropertyBag PropertyBag;
        public PropertyCreated OnPropertyCreated;
        #endregion
        
        #region Constructor
        public ctlPropertyLink()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(PropertyLink propertyLink, string defaultNewPropertyName, PropertyBag propertyBag, PropertyCreated propertyCreatedEvent)
        {
            if (propertyLink == null)
                throw new ArgumentException("propertyLink is null");
            if (propertyBag == null)
                throw new ArgumentException("propertyBag is null");
            PropertyLink = propertyLink;
            DefaultNewPropertyName = defaultNewPropertyName;
            PropertyBag = propertyBag;
            OnPropertyCreated = propertyCreatedEvent;
        }

        public void SyncToForm()
        {
            cboProperty.Text = BasicHelper.GetNameFromFullName(PropertyLink.GetFullName());
        }


        public void SyncToObject()
        {
             PropertyLink.SetFullName(BasicHelper.GetFullName(PropertyBag.FullName, cboProperty.Text));
        }
        #endregion

        #region Events
        private void cboProperty_DropDown(object sender, EventArgs e)
        {
            cboProperty.BeginUpdate();
            cboProperty.Items.Clear();
            cboProperty.DisplayMember = "Name";
            var filteredProperties = PropertyBag.Properties.GetFilteredProperties(PropertyLink.ExpectedType);
            foreach (var property in filteredProperties)
            {
                cboProperty.Items.Add(property);
            }
            cboProperty.Sorted = true;
            cboProperty.EndUpdate();
        }

        private void btnAddProperty_Click(object sender, EventArgs e)
        {
            var defaultName = DefaultNewPropertyName;
            var dialog = new frmAddProperty(PropertyBag.Properties, PropertyLink.ExpectedType, defaultName);
            if (dialog.ShowDialog() == DialogResult.Cancel)
                return;

            cboProperty.Text = dialog.NewProperty.Name;
            PropertyBag.Properties.Add(dialog.NewProperty);

            if (OnPropertyCreated != null)
                OnPropertyCreated(dialog.NewProperty);
        }
        #endregion
    }
}
