using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
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

            ctlQuantityProperty.Init(ChargeType.GetQuantityPropertyLink(), "Quantity", Property.PropertyBag, OnPropertyCreated);
            ctlPriceProperty.Init(ChargeType.GetPricePropertyLink(), "Price", Property.PropertyBag, OnPropertyCreated); 
            ctlProductProperty.Init(ChargeType.GetProductPropertyLink(), "Product", Property.PropertyBag, OnPropertyCreated);
            ctlStartProperty.Init(ChargeType.GetStartPropertyLink(), "Start", Property.PropertyBag, OnPropertyCreated);
            ctlEndProperty.Init(ChargeType.GetEndPropertyLink(), "End", Property.PropertyBag, OnPropertyCreated);
        }

        public override void SyncToForm()
        {
            Visible = !Property.IsCore || ((ProductViewEntity)Property.PropertyCollection.PropertyBag).GetCharges(false).Count == 0;
            ctlQuantityProperty.SyncToForm();
            ctlPriceProperty.SyncToForm();
            ctlProductProperty.SyncToForm();
            ctlStartProperty.SyncToForm();
            ctlEndProperty.SyncToForm();
        }

        public override void SyncToObject()
        {
            ctlQuantityProperty.SyncToObject();
            ctlPriceProperty.SyncToObject();
            ctlProductProperty.SyncToObject();
            ctlStartProperty.SyncToObject();
            ctlEndProperty.SyncToObject();
        }
        #endregion
    }
}
