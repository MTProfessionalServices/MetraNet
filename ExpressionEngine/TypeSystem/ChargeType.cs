using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
namespace MetraTech.ExpressionEngine.TypeSystem
{
  [DataContract(Namespace = "MetraTech")]
  public class ChargeType : MoneyType
    {
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
        public ChargeType() : base(BaseType.Charge)
        {      
        }
        protected ChargeType(BaseType baseType)
          : base(baseType)
        {
        }
         public ChargeType(string quantityProperty) : this()
        {
            QuantityProperty = quantityProperty;
        }
        #endregion

        #region Methods
        public override List<PropertyReference> GetPropertyReferences()
        {
            var references = new List<PropertyReference>();
            references.Add(new PropertyReference(this, "QuantityProperty", TypeFactory.CreateNumeric(), true));

            //references.Add(new PropertyReference(PriceProperty, TypeFactory.CreateMoney(), false));
            //references.Add(new PropertyReference(ProductProperty, TypeFactory.CreateInteger(), false));
            //references.Add(new PropertyReference(StartProperty, TypeFactory.CreateDateTime(), false));
            //references.Add(new PropertyReference(EndProperty, TypeFactory.CreateDateTime(), false));
            return references;
        }
        #endregion
    }
}
