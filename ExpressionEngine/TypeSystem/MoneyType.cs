using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
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

        public override List<PropertyReference> GetPropertyReferences()
        {
            var references = new List<PropertyReference>();
            if (CurrencyMode == CurrencyMode.PropertyDriven && !string.IsNullOrEmpty(CurrencyProperty))
                references.Add(new PropertyReference(CurrencyProperty, TypeFactory.CreateEnumeration(null), true));
            return references;
        }
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
