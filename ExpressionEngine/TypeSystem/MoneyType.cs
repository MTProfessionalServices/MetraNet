using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract (Namespace = "MetraTech")]
    public class MoneyType : Type
    {
        #region Properties

        /// <summary>
        /// Indicates how the FixedCurrency is determine
        /// </summary>
        [DataMember]
        public CurrencyMode CurrencyMode { get; set; }

        /// <summary>
        /// The currency. Only valid when CurrencyMode=Fixed.
        /// ???Should this be renamed to FixedCurrency???
        /// </summary>
        [DataMember]
        public string FixedCurrency { get; set; }

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
            //Error if FixedCurrency not specified
            //Error if FixedCurrency doesn't exist
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
