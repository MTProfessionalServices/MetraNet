using System.Runtime.Serialization;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// A string data type.
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class StringType : Type
    {
        #region Properties
        /// <summary>
        /// The length of the string. This is only relevant when stored in the database.
        /// </summary>
        [DataMember]
        public int Length { get; set; }
        #endregion

        #region Constructor
        public StringType() : this(0)
        { }
        public StringType(int length):base(BaseType.String)
        {
            Length = length;
        }
        #endregion

        #region Methods
        public override string ToString(bool robust)
        {
            if (robust && Length > 0)
                return string.Format(CultureInfo.InvariantCulture, "{0}({1})", BaseType.ToString(), Length.ToString(CultureInfo.InvariantCulture));
            return BaseType.ToString();
        }

        public new StringType Copy()
        {
            var type = (StringType)base.Copy();
            type.Length = Length;
            return type;
        }
        #endregion

    }
}
