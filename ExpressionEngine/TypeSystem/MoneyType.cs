using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract (Namespace = "MetraTech")]
    public class MoneyType : Type
    {
        #region Properties

        /// <summary>
        /// Indicates how the Currency is determine
        /// </summary>
        [DataMember]
        public CurrencyMode CurrencyMode { get; set; }

        /// <summary>
        /// The currency. Only valid when CurrencyMode=Fixed.
        /// ???Should this be renamed to FixedCurrency???
        /// </summary>
        [DataMember]
        public string Currency { get; set; }

        /// <summary>
        /// The property that drives the currency. Only valid when CurrencyMode=Property.
        /// </summary>
        [DataMember]
        public string CurrencyProperty { get; set; }

        #endregion
      
        #region Constructor
        public MoneyType():base(BaseType.Money)
        {
        }
        #endregion

        #region Methods

        public override void Validate(string prefix, Validations.ValidationMessageCollection messages, Context context)
        {
            //Error if None
            //Error if Currency not specified
            //Error if Currency doesn't exist
        }

        public new MoneyType Copy()
        {
            var type = (MoneyType)base.Copy();
            InternalCopy(type);
            //type.UnitsProperty = UnitsProperty;
            return type;
        }
        #endregion
    }
}
