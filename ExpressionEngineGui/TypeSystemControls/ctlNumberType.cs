using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

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

            ctlUom.Init(Context.EnumManager);
            ctlUom.ShowCurrency = false;
            ctlUom.ShowItems = false;

            ctlProperty.Top = ctlUom.Top;
            ctlProperty.Left = ctlUom.Left;
            ctlProperty.Init(property.PropertyCollection, TypeFactory.CreateNumeric(), "SillyName");
        }

        public override void SyncToForm()
        {
            cboUnitOfMeasureMode.SelectedItem = NumberType.UnitOfMeasureMode;
        }
        public override void SyncToObject()
        {
            //Note that UnitOfMeasureMode set in change event
            NumberType.UnitOfMeasureProperty = ctlProperty.Text;
            NumberType.UnitOfMeasureCategory = ctlUom.EnumCategory;
            NumberType.FixedUnitOfMeasure = ctlUom.EnumFullName;

            NumberType.CleanProperties();
        }
        #endregion

        #region Events
        private void cboUnitOfMeasureCategory_SelectedValueChanged(object sender, System.EventArgs e)
        {
            NumberType.UnitOfMeasureMode = (UnitOfMeasureMode) cboUnitOfMeasureMode.SelectedItem;
            bool showProperty = false;
            bool showUomCategory = false;
            bool showUomItem = false;
            lblGeneric.Text = null;
            switch (NumberType.UnitOfMeasureMode)
            {
                case UnitOfMeasureMode.PropertyDriven:
                    showProperty = true;
                    lblGeneric.Text = "Unit of Measure Property:";
                    break;
                case UnitOfMeasureMode.FixedCategory:
                case UnitOfMeasureMode.FixedUnitOfMeasure:
                    showUomCategory = true;
                    lblGeneric.Text = "Unit of Measure Category:";
                    ctlUom.EnumCategory = BasicHelper.GetNamespaceFromFullName(NumberType.FixedUnitOfMeasure);
                    ctlUom.EnumItem = BasicHelper.GetNameFromFullName(NumberType.FixedUnitOfMeasure);
                    showUomItem = NumberType.UnitOfMeasureMode == UnitOfMeasureMode.FixedUnitOfMeasure;
                    ctlUom.SetItemComboBoxVisibility(showUomItem);
                    break;
            }
            ctlProperty.Visible = showProperty;
            ctlUom.Visible = showUomCategory;
            lblUnitOfMeasure.Visible = showUomItem;
        }
        #endregion

    }
}
