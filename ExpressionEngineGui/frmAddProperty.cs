using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui
{
    public partial class frmAddProperty : Form
    {
        #region Properties
        public Property Property;
        private string PropertyBagTypeName;
        #endregion

        #region Contructor
        public frmAddProperty(Property property, string propertyBagTypeName)
        {
            InitializeComponent();

            if (property == null)
                throw new ArgumentException("property is null");
            Property = property;
            PropertyBagTypeName = propertyBagTypeName;
            DialogResult = DialogResult.Cancel;
        }
        #endregion

        #region Events
        private void btnOK_Click(object sender, EventArgs e)
        {
            var name = txtName.Text;
            if (!Property.NameIsValid(name))
            {
                MessageBox.Show("Name is not valid", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            if (Property.PropertyCollection.Get(name) != null)
            {
                MessageBox.Show("Property name already exists", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            var type = (Type)cboType.SelectedItem;
            Property = PropertyFactory.Create(PropertyBagTypeName, name, type, true, null);
            DialogResult = DialogResult.OK;
            Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            Property = null;
            DialogResult = DialogResult.Cancel;
            Close();
        }
        #endregion
    }
}
