using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using PropertyGui.TypeSystemControls;

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
        public ctlBaseType CurrentTypeControl = null;
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

            GuiHelper.LoadBaseTypes(cboDataType);
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
            txtDefaultValue.Text = Property.DefaultValue;
            txtDescription.Text = Property.Description;

            Enabled = !Property.IsCore;
            IgnoreChanges = false;
            UpdateGui();
        }

        public void SyncToObject()
        {
            Property.Name = txtName.Text;
            Property.Required = chkIsRequired.Checked;
            Property.DefaultValue = txtDefaultValue.Text;
            Property.Description = txtDescription.Text;
            var baseType = (BaseType) cboDataType.SelectedItem;
            if (Property.Type.BaseType != baseType)
                Property.Type = TypeFactory.Create(baseType);
        }

        private void UpdateGui()
        {

        }

        private ctlBaseType TypeControlFactory()
        {
            switch (Property.Type.BaseType)
            {
                case BaseType.Charge:
                    return new ctlChargeType();
                case BaseType.Enumeration:
                    return new ctlEnumerationType();
                case BaseType.Money:
                    return new ctlMoneyType();
                case BaseType.String:
                    return new ctlStringType();
                default:
                    if (Property.Type is NumberType)
                        return new ctlNumberType();
                    return null;
            }
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


        private void cboDataType_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (IgnoreChanges)
                return;

            if (CurrentTypeControl != null)
            {
                CurrentTypeControl.SyncToObject();
                CurrentTypeControl.Dispose();
            }

            Property.Type = TypeFactory.Create((BaseType) cboDataType.SelectedItem);
            CurrentTypeControl = TypeControlFactory();
            if (CurrentTypeControl != null)
            {
                CurrentTypeControl.Parent = this;
                CurrentTypeControl.Top = panel1.Top;
                CurrentTypeControl.Left = panel1.Left;
                CurrentTypeControl.Init(Property, Context);
                CurrentTypeControl.SyncToForm();
            }
        }
        #endregion
    }
}
