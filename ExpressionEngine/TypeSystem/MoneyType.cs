using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract (Namespace = "MetraTech")]
    public class MoneyType : Type
    {
        #region Constants
        private const string FixedCurrencyPropertyName = "FixedCurrency";
        private const string CurrencyPropertyPropertyName = "CurrencyProperty";
        #endregion

        #region Properties

        /// <summary>
        /// Indicates how the FixedCurrency is determine
        /// </summary>
        [DataMember]
        public CurrencyMode CurrencyMode { get; set; }

        /// <summary>
        /// The currency. Only valid when CurrencyMode=FixedUnitOfMeasure.
        /// </summary>
        [DataMember]
        public string FixedCurrency { get; set; }

        /// <summary>
        /// The property that drives the currency. Only valid when CurrencyMode=PropertyDriven.
        /// </summary>
        [DataMember]
        public string CurrencyProperty { get; set; }

        #endregion
      
        #region Constructors
        public MoneyType():base(BaseType.Money)
        {
        }
        protected MoneyType(BaseType baseType) : base(baseType)
        {
        }
        #endregion

        #region Methods

        public override ComponentLinkCollection GetComponentLinks()
        {
            var links = new ComponentLinkCollection();
            switch (CurrencyMode)
            {
                case CurrencyMode.Fixed:
                    links.Add(GetFixedCurrencyLink());
                    break;
                case CurrencyMode.PropertyDriven:
                    links.Add(GetCurrencyPropertyLink());
                    break;
            }
            return links;
        }
        public ComponentLink GetFixedCurrencyLink()
        {
            return new ComponentLink(ComponentType.Currency, this, FixedCurrencyPropertyName, true, Localization.FixedCurrency);
        }
        public ComponentLink GetCurrencyPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateCurrency(), this, CurrencyPropertyPropertyName, true, Localization.FixedCurrency);
        }
        public new MoneyType Copy()
        {
            var type = (MoneyType)base.Copy();
            InternalCopy(type);
            return type;
        }
        #endregion
    }
}
