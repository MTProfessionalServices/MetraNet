using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui
{
    public partial class frmAddProperty : Form
    {
        #region Properties
        public Property NewProperty { get; private set; }
        private PropertyCollection Properties;
        private Type Type;
        private bool UserDrivenType;
        #endregion

        #region Contructor
        public frmAddProperty(PropertyCollection properties, Type type, string suggestedName)
        {
            InitializeComponent();
            DialogResult = DialogResult.Cancel;

            if (properties == null)
                throw new ArgumentException("properties is null");
            Properties = properties;
            Type = type;
            txtName.Text = suggestedName;

            UserDrivenType = TypeHelper.BaseTypeFilterSupportsMultipleBaseTypes(type.BaseType);
            if (!UserDrivenType)
            {
                cboType.Items.Add(Type);
                cboType.SelectedItem = Type;
                cboType.Enabled = false;
            }
            else
            {
                cboType.BeginUpdate();
                foreach (var allType in TypeHelper.AllTypes)
                {
                    if (Type.BaseType == BaseType.Numeric && TypeHelper.IsNumeric(allType.BaseType))
                        cboType.Items.Add(allType.BaseType);
                    else if (Type.BaseType == BaseType.Any)
                        cboType.Items.Add(allType.BaseType);
                }
                cboType.EndUpdate();
            }

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
            if (Properties.Get(name) != null)
            {
                MessageBox.Show("Property name already exists", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            
            var baseType = (BaseType)cboType.SelectedItem;
            if (baseType == null)
            {
                MessageBox.Show("Type not specified", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            NewProperty = PropertyFactory.Create(Properties.PropertyBagTypeName, name, TypeFactory.Create(baseType), true, null);
            DialogResult = DialogResult.OK;
            Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            NewProperty = null;
            DialogResult = DialogResult.Cancel;
            Close();
        }
        #endregion
    }
}
