using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlChargeType : ctlBaseType
    {
        #region Properties
        private ChargeType ChargeType;
        #endregion

        #region Constructor
        public ctlChargeType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
            base.Init(property, context);
            ChargeType = (ChargeType)property.Type;

            ctlQuantityProperty.Init(Property, TypeFactory.CreateNumeric(), "Quantity");
        }

        public override void SyncToForm()
        {
            ctlQuantityProperty.PropertyName = ChargeType.QuantityProperty;
            cboPriceProperty.Text = ChargeType.PriceProperty;
            cboProductProperty.Text = ChargeType.ProductProperty;
            cboSartProperty.Text = ChargeType.StartProperty;
            cboEndProperty.Text = ChargeType.EndProperty;
        }
        public override void SyncToObject()
        {
            ChargeType.QuantityProperty = ctlQuantityProperty.PropertyName;
        }
        #endregion

    }
}
