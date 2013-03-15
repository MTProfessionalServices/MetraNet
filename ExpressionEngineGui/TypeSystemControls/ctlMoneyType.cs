using System;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlMoneyType : ctlBaseType
    {
        #region Properties
        private MoneyType MoneyType;
        #endregion

        #region Constructor
        public ctlMoneyType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
            base.Init(property, context);
            MoneyType = (MoneyType) property.Type;
        }

        public override void SyncToForm()
        {
        }
        public override void SyncToObject()
        {
        }
        #endregion

        #region Events
        private void cboCurrencyMode_DropDown(object sender, EventArgs e)
        {
            if ((CurrencyMode)cboCurrencyMode.SelectedItem == CurrencyMode.Fixed)
                GuiHelper.LoadCurrencies(cboCurrencyModifier, Context);
            else
                GuiHelper.LoadProperties(cboCurrencyModifier, TypeFactory.CreateString(), Property.PropertyCollection);

        }
        #endregion
    }
}
