using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// A currency, typically used in combination with a Money or 
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class Currency : EnumItem
    {
        #region Properties
        public override ComponentType ComponentType { get { return ComponentType.Currency; } }

        /// <summary>
        /// The symbol (i.e., $) I assume these aren't localized
        /// </summary>
        [DataMember]
        public string Symbol { get; set; }

        /// <summary>
        /// Some standards based code (i.e., USD). I assume that these aren't localized
        /// </summary>
        [DataMember]
        public string Code { get; set; }

        #endregion

        #region GUI Support Properties (should be moved in future)
        public override string Image { get { return "Currency.png"; } }
        #endregion

        #region Constructor

        public Currency(EnumCategory enumCategory, string name, int id, string description)
            : base(enumCategory, name, id, description)
        {
        }
        #endregion
    }
}
