using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components.Enumerations;
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

            cboCurrencyMode.BeginUpdate();
            cboCurrencyMode.DropDownStyle = ComboBoxStyle.DropDownList;
            cboCurrencyMode.Items.Add(CurrencyMode.Fixed);
            cboCurrencyMode.Items.Add(CurrencyMode.None);
            cboCurrencyMode.Items.Add(CurrencyMode.PropertyDriven);
            //cboCurrencyMode.Items.Add(CurrencyMode.ContextDriven);
            cboCurrencyMode.Sorted = true;
            cboCurrencyMode.EndUpdate();

            ctlPropertyReference.Init(Property, TypeFactory.CreateCurrency(), "Currency", PropertyCreated);

            ctlPropertyReference.Top = cboCurrency.Top;
            ctlPropertyReference.Left = cboCurrency.Left;
        }

        public override void SyncToForm()
        {
            cboCurrencyMode.SelectedItem = MoneyType.CurrencyMode;
            cboCurrency.Text = MoneyType.FixedCurrency;
            ctlPropertyReference.PropertyName = MoneyType.CurrencyProperty;
        }
        public override void SyncToObject()
        {
            MoneyType.CurrencyMode = (CurrencyMode)cboCurrencyMode.SelectedItem;
            MoneyType.FixedCurrency = cboCurrency.Text;
            MoneyType.CurrencyProperty = ctlPropertyReference.PropertyName;
        }
        #endregion

        #region Events

        private void cboCurrencyMode_SelectedValueChanged(object sender, EventArgs e)
        {
            var mode = (CurrencyMode) cboCurrencyMode.SelectedItem;
            switch (mode)
            {
                //case CurrencyMode.ContextDriven:
                case CurrencyMode.None:
                    break;
                case CurrencyMode.Fixed:
                    lblCurrencyModifier.Text = "Fixed Currency:";
                    break;
                case CurrencyMode.PropertyDriven:
                    lblCurrencyModifier.Text = "Currency Property:";
                    break;
            }
            lblCurrencyModifier.Visible = (mode == CurrencyMode.PropertyDriven || mode == CurrencyMode.Fixed);
            cboCurrency.Visible = (mode == CurrencyMode.Fixed);
            ctlPropertyReference.Visible = (mode == CurrencyMode.PropertyDriven);
        }

        private void cboCurrencyMode_DropDown(object sender, EventArgs e)
        {
            GuiHelper.LoadCurrencies(cboCurrency, Context);
        }

        #endregion
    }
}
