using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract]
    public class EnumerationType : Type
    {
        #region Properties
        /// <summary>
        /// The namespace; used to prevent name collisions
        /// </summary>
        [DataMember]
        public string EnumSpace { get; set; }

        /// <summary>
        /// The type of enum
        /// </summary>
        [DataMember]
        public string EnumType { get; set; }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public override string CompatibleKey
        {
            get
            {
             return string.Format(CultureInfo.InvariantCulture, "{0}|{1}|{2}", BaseType, EnumSpace, EnumType);
            }
        }
        #endregion

        #region Constructor
        public EnumerationType(string enumSpace, string enumType):base(BaseType.Enumeration)
        {
            EnumSpace = enumSpace;
            EnumType = enumType;
        }
        #endregion

        #region Methods
        public override string ToString(bool robust)
        {
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}.{2}", BaseType, EnumSpace, EnumType);
            else
                return BaseType.ToString();
        }
        #endregion

    }
}
