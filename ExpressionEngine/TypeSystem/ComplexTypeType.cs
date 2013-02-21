using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    [DataContract]
    public class ComplexTypeType : Type
    {
        #region Enums
        public enum ComplexTypeEnum { None, ServiceDefinition, ProductView, ParameterTable, AccountType, AccountView, BusinessModelingEntity, Any, Metanga }
        #endregion

        #region Properties
        /// <summary>
        /// The type of complex type
        /// </summary>
        [DataMember]
        public ComplexTypeType.ComplexTypeEnum ComplexType { get; set; }

        /// <summary>
        /// The subtype of the Entity type. For example, a BME ma
        /// </summary>
        [DataMember]
        public string ComplexSubtype { get; set; }

        /// <summary>
        /// Indicates if the ComplexType is deemed an Entity
        /// </summary>
        [DataMember]
        public bool IsEntity { get; set; }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public virtual string CompatibleKey
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", BaseType, ComplexType);
            }
        }

        #endregion

        #region Constructor
        public ComplexTypeType(ComplexTypeEnum type, string subType, bool isEntity):base(BaseType.ComplexType)
        {
            ComplexType = type;
            ComplexSubtype = subType;
            IsEntity = IsEntity;
        }
        #endregion

        #region Methods
        //This isn't quite right
        public override string ToString(bool robust)
        {
            var type = IsEntity ? "Entity" : "ComplexType";
            if (robust)
                return string.Format(CultureInfo.InvariantCulture, "{0}: {1}", type, ComplexSubtype);
            return type;
        }

        #endregion
    }
}
