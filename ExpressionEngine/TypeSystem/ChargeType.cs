using System.Globalization;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract(Namespace = "MetraTech")]
    public class ChargeType : MoneyType
    {
        #region Constants
        private const string QuantityPropertyPropertyName = "QuantityProperty";
        #endregion

        #region Properties

        /// <summary>
        /// The name of the property that specifes the quantity to calculate
        /// </summary>
        [DataMember]
        public string QuantityProperty { get; set; }

        /// <summary>
        /// The total price assoicated with the Charge. The Currency is in the parent
        /// MoneyType class. Unit price can be determined by dividing Price by the 
        /// value contained in QuantityProperty
        /// </summary>
        [DataMember]
        public string PriceProperty { get; set; }

        /// <summary>
        /// The property that contains the product ID
        /// </summary>
        [DataMember]
        public string ProductProperty { get; set; }

        /// <summary>
        /// The property that containss the start date. Used for revenue requsition.
        /// </summary>
        [DataMember]
        public string StartProperty { get; set; }

        /// <summary>
        /// The property that contains the end date. Used for revenue requsition.
        /// </summary>
        [DataMember]
        public string EndProperty { get; set; }

        #endregion

        #region Constructor
        public ChargeType()
            : base(BaseType.Charge)
        {
        }
        protected ChargeType(BaseType baseType)
            : base(baseType)
        {
        }
        public ChargeType(string quantityProperty)
            : this()
        {
            QuantityProperty = quantityProperty;
        }
        #endregion

        #region Methods
        public string GetChargeExpression(Property chargeProperty, bool includeAssignment)
        {
            string variable = string.Empty;
            if (includeAssignment)
                variable = string.Format("USAGE.{0} := ", chargeProperty.DatabaseName);
            if (chargeProperty.Name == "EventCharge")
            {
                var sb = new StringBuilder(variable);
                foreach (var charge in ((ProductViewEntity) chargeProperty.PropertyCollection.Parent).GetCharges(false))
                {
                    if (sb.Length > variable.Length)
                        sb.Append(" + ");
                    sb.Append("USAGE." + charge.DatabaseName);
                }
                return sb.ToString();
            }

            return string.Format(CultureInfo.InvariantCulture, "{0} * SOMETHING", chargeProperty.DatabaseName);
        }
        #endregion

        #region Link Methods
        public override ComponentLinkCollection GetComponentLinks()
        {
            var links = new ComponentLinkCollection();
            links.Add(GetQuantityPropertyLink());

            //references.Add(new PropertyReference(PriceProperty, TypeFactory.CreateMoney(), false));
            //references.Add(new PropertyReference(ProductProperty, TypeFactory.CreateInteger(), false));
            //references.Add(new PropertyReference(StartProperty, TypeFactory.CreateDateTime(), false));
            //references.Add(new PropertyReference(EndProperty, TypeFactory.CreateDateTime(), false));
            return links;
        }
        public ComponentLink GetQuantityPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateNumeric(), this, QuantityPropertyPropertyName, true, Localization.QuantityProperty);
        }

        #endregion
    }
}
