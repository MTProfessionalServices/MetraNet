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
        private const string PricePropertyPropertyName = "PriceProperty";
        private const string ProductPropertyPropertyName = "ProductProperty";
        private const string StartPropertyPropertyName = "StartProperty";
        private const string EndPropertyPropertyName = "EndProperty";
        #endregion

        #region Properties

        [DataMember]
        public string Alias { get; set; }

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
        [DataMember(EmitDefaultValue = false)]
        public string ProductProperty { get; set; }

        /// <summary>
        /// The property that containss the start date. Used for revenue requsition.
        /// </summary>
        [DataMember(EmitDefaultValue = false)]
        public string StartProperty { get; set; }

        /// <summary>
        /// The property that contains the end date. Used for revenue requsition.
        /// </summary>
        [DataMember(EmitDefaultValue = false)]
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
                variable = string.Format("USAGE.{0} := ", chargeProperty.DatabaseColumnName);
            if (chargeProperty.Name == "EventCharge")
            {
                var sb = new StringBuilder(variable);
                foreach (var charge in ((ProductViewEntity) chargeProperty.PropertyCollection.Parent).GetCharges(false))
                {
                    if (sb.Length > variable.Length)
                        sb.Append(" + ");
                    sb.Append("USAGE." + charge.DatabaseColumnName);
                }
                return sb.ToString();
            }

            return string.Format(CultureInfo.InvariantCulture, "{0} * SOMETHING", chargeProperty.DatabaseColumnName);
        }
        #endregion

        #region Link Methods
        public override ComponentLinkCollection GetComponentLinks()
        {
            var links = new ComponentLinkCollection();
            links.Add(GetQuantityPropertyLink());
            links.Add(GetPricePropertyLink());
            links.Add(GetProductPropertyLink());
            links.Add(GetStartPropertyLink());
            links.Add(GetEndPropertyLink());
            return links;
        }
        public PropertyLink GetQuantityPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateNumeric(), this, QuantityPropertyPropertyName, true, Localization.QuantityProperty);
        }
        public PropertyLink GetPricePropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateMoney(), this, PricePropertyPropertyName, true, "Price Property");
        }
        public PropertyLink GetProductPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateInteger32(), this, ProductPropertyPropertyName, true, "Product Property");
        }
        public PropertyLink GetStartPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateDateTime(), this, StartPropertyPropertyName, true, "Start Property");
        }
        public PropertyLink GetEndPropertyLink()
        {
            return new PropertyLink(TypeFactory.CreateDateTime(), this, EndPropertyPropertyName, true, "End Property");
        }
        #endregion
    }
}
