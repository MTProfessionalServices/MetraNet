using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    public class ChargeType : MoneyType
    {
        #region Properties

        /// <summary>
        /// The name of the property that specifes the quantity to calculate
        /// </summary>
        public string QuantityProperty { get; set; }

        /// <summary>
        /// The property that contains the product ID
        /// </summary>
        public string ProductIdProperty { get; set; }

        /// <summary>
        /// The property that containss the start date. Used for revenue requsition.
        /// </summary>
        public string StartProperty { get; set; }

        /// <summary>
        /// The property that contains the end date. Used for revenue requsition.
        /// </summary>
        public string EndProperty { get; set; }

        #endregion

        #region Constructor
        public ChargeType() : base(BaseType.Charge)
        {
            
        }
        #endregion
    }
}
