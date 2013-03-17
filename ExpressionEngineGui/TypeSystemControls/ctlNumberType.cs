using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Components;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlNumberType : ctlBaseType
    {
        #region Properties
        private NumberType NumberType;
        #endregion

        #region Constructor
        public ctlNumberType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
            base.Init(property, context);
            NumberType = (NumberType)property.Type;

            GuiHelper.LoadEnum<UnitOfMeasureMode>(cboUnitOfMeasureMode);
            //cboUnitOfMeasureCategory.BeginUpdate();
            //cboUnitOfMeasureCategory.DropDownStyle = ComboBoxStyle.DropDownList;
            //cboUnitOfMeasureCategory.Items.Add(Enum.GetValues(typeof (UnitOfMeasureMode)));
            //cboUnitOfMeasureCategory.EndUpdate();
        }

        public override void SyncToForm()
        {
            cboUnitOfMeasureMode.SelectedItem = NumberType.UnitOfMeasureMode;
        }
        public override void SyncToObject()
        {
        }
        #endregion

        #region Events
        private void cboUnitOfMeasureCategory_SelectedValueChanged(object sender, System.EventArgs e)
        {
            NumberType.UnitOfMeasureMode = (UnitOfMeasureMode) cboUnitOfMeasureMode.SelectedItem;
            bool showQualifier = false;
            bool showUnitOfMeasure = false;
            bool showAddButton = false;
            switch (NumberType.UnitOfMeasureMode)
            {
                case UnitOfMeasureMode.None:
                case UnitOfMeasureMode.ContextDriven:
                    showQualifier = false;
                    showUnitOfMeasure = false;
                    break;
                case UnitOfMeasureMode.PropertyDriven:
                    showQualifier = true;
                    showUnitOfMeasure = false;
                    showAddButton = string.IsNullOrEmpty(cboUomQualifier.Text);
                    lblUomQualifier.Text = "Unit of Measure Property:";
                    GuiHelper.LoadProperties(cboUomQualifier, TypeFactory.CreateString(), Property.PropertyCollection);
                    break;
                case UnitOfMeasureMode.FixedCategory:
                case UnitOfMeasureMode.FixedUnitOfMeasure:
                    showQualifier = true;
                    lblUomQualifier.Text = "Unit of Measure Category:";
                    cboUomQualifier.Text = BasicHelper.GetNamespaceFromFullName(NumberType.FixedUnitOfMeasure);
                    cboUnitOfMeasure.Text = BasicHelper.GetNameFromFullName(NumberType.FixedUnitOfMeasure);
                    showUnitOfMeasure = (NumberType.UnitOfMeasureMode == UnitOfMeasureMode.FixedUnitOfMeasure);
                    GuiHelper.LoadUnitOfMeasureCategories(cboUomQualifier, Context);
                    break;
            }
            lblUomQualifier.Visible = showQualifier;
            cboUomQualifier.Visible = showQualifier;
            lblUnitOfMeasure.Visible = showUnitOfMeasure;
            cboUnitOfMeasure.Visible = showUnitOfMeasure;
            btnAddProperty.Visible = showAddButton;
        }
        #endregion

        #region Events

        private void cboUnitOfMeasure_DropDown(object sender, System.EventArgs e)
        {
            var uomCategory = (EnumCategory) cboUomQualifier.SelectedItem;
            GuiHelper.LoadUnitsOfMeasure(cboUnitOfMeasure, uomCategory);
        }

        private void btnAddProperty_Click(object sender, System.EventArgs e)
        {
            var name = Property.Name + "UnitOfMeasure";
            NumberType.UnitOfMeasureProperty = name;
            var description = string.Format("Unit of Measure for the {0} property", name);
            var uomProperty = PropertyFactory.Create(name, TypeFactory.CreateString(), true, description);
            Property.PropertyCollection.Add(uomProperty);
            
            
        }
        #endregion

        private void cboUomQualifier_DropDown(object sender, System.EventArgs e)
        {

        }
    }
}
