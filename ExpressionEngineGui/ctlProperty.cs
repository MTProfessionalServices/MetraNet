using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public delegate void ChangeEvent();

    public partial class ctlProperty : UserControl
    {
        #region Properties
        private bool IgnoreChanges = false;
        private Context Context;
        private Property Property;
        public ChangeEvent OnChangeEvent;
        #endregion
   
        #region Constructor
        public ctlProperty()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public void Init(Context context)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            Context = context;

            LoadDataTypes(cboDataType);
            LoadEnumerations(cboEnumeration);
        }

        public void SyncToForm(Property property)
        {
            if (property == null)
                throw new ArgumentException("property is null");
            Property = property;

            IgnoreChanges = true;
            txtName.Text = Property.Name;
            chkIsRequired.Checked = Property.Required;
            cboDataType.SelectedItem = Property.Type.BaseType;
            txtDescription.Text = Property.Description;

            switch (Property.Type.BaseType)
            {
                case BaseType.Enumeration:
                    cboEnumeration.Text = ((EnumerationType)Property.Type).Category;
                    break;
            }

            Enabled = !Property.IsCore;
            IgnoreChanges = false;
            UpdateGui();
        }

        public void SyncToObject()
        {
            Property.Name = txtName.Text;
            Property.Required = chkIsRequired.Checked;
            Property.Description = txtDescription.Text;
            var baseType = (BaseType)cboDataType.SelectedItem;
            if (Property.Type.BaseType != baseType)
                Property.Type = TypeFactory.Create(baseType);

            switch (Property.Type.BaseType)
            {
                case BaseType.Enumeration:
                    ((EnumerationType)Property.Type).Category = cboEnumeration.Text;
                    break;
            }
        }



        public void LoadDataTypes(ComboBox comboBox)
        {
            comboBox.BeginUpdate();
            comboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            foreach (var baseType in Enum.GetValues(typeof(BaseType)))
            {
                comboBox.Items.Add(baseType);
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        public void LoadEnumerations(ComboBox comboBox)
        {
            comboBox.BeginUpdate();
            foreach (var category in Context.EnumCategories)
            {
                foreach (var item in category.Items)
                {
                    comboBox.Items.Add(item.FullName);
                }
            }
            comboBox.Sorted = true;
            comboBox.EndUpdate();
        }

        private void UpdateGui()
        {
            cboEnumeration.Visible = Property.Type.IsEnum;
        }
        #endregion

        #region Events
        private void changeEvent(object sender, System.EventArgs e)
        {
            if (IgnoreChanges)
                return;
            
            SyncToObject();
            UpdateGui();

            if (OnChangeEvent != null)
                OnChangeEvent();
        }
        #endregion
    }
}
