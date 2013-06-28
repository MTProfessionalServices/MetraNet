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

            ctlQuantityProperty.Init(ChargeType.GetQuantityPropertyLink(), property.Name + "Quantity", Property.PropertyBag, OnPropertyCreated);
            ctlPriceProperty.Init(ChargeType.GetPricePropertyLink(), property.Name + "Price", Property.PropertyBag, OnPropertyCreated); 
            ctlProductProperty.Init(ChargeType.GetProductPropertyLink(), property.Name + "Product", Property.PropertyBag, OnPropertyCreated);
            ctlStartProperty.Init(ChargeType.GetStartPropertyLink(), property.Name + "Start", Property.PropertyBag, OnPropertyCreated);
            ctlEndProperty.Init(ChargeType.GetEndPropertyLink(), property.Name + "End", Property.PropertyBag, OnPropertyCreated);
        }

        public override void SyncToForm()
        {
            var numCharges = ((ProductViewEntity) Property.PropertyCollection.PropertyBag).GetCharges(false).Count;
            Visible = !(Property.IsCore && numCharges > 0);
            txtAlias.Text = ChargeType.Alias;
            ctlQuantityProperty.SyncToForm();
            ctlPriceProperty.SyncToForm();
            ctlProductProperty.SyncToForm();
            ctlStartProperty.SyncToForm();
            ctlEndProperty.SyncToForm();
        }

        public override void SyncToObject()
        {
            ChargeType.Alias = txtAlias.Text;
            ctlQuantityProperty.SyncToObject();
            ctlPriceProperty.SyncToObject();
            ctlProductProperty.SyncToObject();
            ctlStartProperty.SyncToObject();
            ctlEndProperty.SyncToObject();
        }
        #endregion
    }
}
