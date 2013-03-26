using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
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
        public Property Property { get; private set; }
        public ChangeEvent OnChangeEvent;

        /// <summary>
        /// The current control being used to edit the type specific attributes. Note that many data types don't have
        /// a specific editor and that this value may be null
        /// </summary>
        public ctlBaseType CurrentTypeControl = null;
        #endregion

        #region Constructor
        public ctlProperty()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods

        public void Init(Context context, PropertyBag propertyBag)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (context == null)
                throw new AggregateException("propertyBag is null");
            Context = context;

            //TODO: MetraNet doesn't support all of the data types, need to filter them
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
            txtDefaultValue.Text = Property.DefaultValue;
            txtDescription.Text = Property.Description;

            cboDataType.SelectedItem = Property.Type.BaseType;
            CreateTypeEditor();

            //If it's core, disallow editing
            Enabled = !Property.IsCore;

            IgnoreChanges = false;
        }

        public void SyncToObject()
        {
            Property.Name = txtName.Text;
            Property.Required = chkIsRequired.Checked;
            Property.DefaultValue = txtDefaultValue.Text;
            Property.Description = txtDescription.Text;

            //Note that Property.Type is taken care of when cboDataType changes!
            
            if (CurrentTypeControl != null)
                CurrentTypeControl.SyncToObject();
        }

        #endregion

        #region Events

        private void cboDataType_SelectedValueChanged(object sender, EventArgs e)
        {
            if (IgnoreChanges)
                return;

            CreateTypeEditor();
            changeEvent(sender, e);
        }

        private void CreateTypeEditor()
        {
            var baseType = (BaseType)cboDataType.SelectedItem;

            //If the base type has changed, we need to create a new Type
            if (baseType != Property.Type.BaseType)
                Property.Type = TypeFactory.Create(baseType);

            if (CurrentTypeControl != null)
                CurrentTypeControl.Dispose();

            //Create the appropriate control
            CurrentTypeControl = ctlTypeFactory.Create(Property.Type.BaseType);
            if (CurrentTypeControl != null)
            {
                CurrentTypeControl.Parent = this;
                CurrentTypeControl.Top = lblDataType.Bottom + 12;
                CurrentTypeControl.Left = lblDataType.Left + 15;
                CurrentTypeControl.Init(Property, Context);
                CurrentTypeControl.SyncToForm();
                panBottom.Top = CurrentTypeControl.Bottom + 5;
            }
            else
            {
                panBottom.Top = lblDataType.Bottom + 5;
            }
        }

        private void changeEvent(object sender, System.EventArgs e)
        {
            if (IgnoreChanges)
                return;

            SyncToObject();

            if (OnChangeEvent != null)
                OnChangeEvent();
        }

        #endregion

    }
}
