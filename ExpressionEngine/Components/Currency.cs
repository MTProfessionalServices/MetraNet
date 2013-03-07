using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Components
{
    /// <summary>
    /// A currency, typically used in combination with a Money or 
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class Currency : EnumValue
    {
        #region Properties

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

        #region Constructor

        public Currency(EnumCategory enumCategory, string name, int id, string description)
            : base(enumCategory, name, id, description)
        {
        }
        #endregion
    }
}
