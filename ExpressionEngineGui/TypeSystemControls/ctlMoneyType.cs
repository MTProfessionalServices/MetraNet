using System;
using System.Windows.Forms;
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

            cboCurrencyMode.BeginUpdate();
            cboCurrencyMode.DropDownStyle = ComboBoxStyle.DropDownList;
            cboCurrencyMode.Items.Add(CurrencyMode.Fixed);
            cboCurrencyMode.Items.Add(CurrencyMode.None);
            cboCurrencyMode.Items.Add(CurrencyMode.PropertyDriven);
            cboCurrencyMode.Items.Add(CurrencyMode.ContextDriven);
            cboCurrencyMode.Sorted = true;
            cboCurrencyMode.EndUpdate();
        }

        public override void SyncToForm()
        {
            cboCurrencyMode.SelectedItem = MoneyType.CurrencyMode;
        }
        public override void SyncToObject()
        {
            MoneyType.CurrencyMode = (CurrencyMode)cboCurrencyMode.SelectedItem;
        }
        #endregion

        #region Events
        #endregion

        private void cboCurrencyMode_SelectedValueChanged(object sender, EventArgs e)
        {
            bool showQualifier = true;
            switch ((CurrencyMode)cboCurrencyMode.SelectedItem)
            {
                case CurrencyMode.ContextDriven:
                case CurrencyMode.None:
                    showQualifier = false;
                    break;
                case CurrencyMode.Fixed:
                    GuiHelper.LoadCurrencies(cboCurrencyModifier, Context);
                    lblCurrencyModifier.Text = "Fixed Currency:";
                    break;
                case CurrencyMode.PropertyDriven:
                    GuiHelper.LoadProperties(cboCurrencyModifier, TypeFactory.CreateString(), Property.PropertyCollection);
                    lblCurrencyModifier.Text = "Currency Property:";
                    break;
            }
            lblCurrencyModifier.Visible = showQualifier;
            cboCurrencyModifier.Visible = showQualifier;
        }
    }
}
