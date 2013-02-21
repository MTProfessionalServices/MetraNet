using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Globalization;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    /// <summary>
    /// The root class for all types
    /// </summary>
    public class Type
    {
        #region Enums
        /// <summary>
        /// Indicates how the UoM is determined. Only valid for numeric data types.
        /// </summary>
        public enum UnitOfMeasureModeType
        {
            None,     // Either not a numeric or it's unknown
            Context,  // Implied by the context which is up to the developer.
            Fixed,    // Always the same (i.e., hours or inches). Specified in the UomQualifier field
            Category, // Always within a UomCategory (i.e., time or length). Specified in the UomQualifier field
            Property  // Determined via a property within the same property collection. Property name specified in the UomQualifier property.
        }

        public enum ListTypeEnum
        {
            None,   //Scalar
            List,   //Enumerable
            KeyList //Dictionary
        }
        #endregion

        #region Properties

        /// <summary>
        /// The underlying type (e.g, string, int32, int64, etc.)
        /// </summary>
        [DataMember]
        public readonly BaseType BaseType;

        /// <summary>
        /// The type of list 
        /// </summary>
        [DataMember]
        public ListTypeEnum ListType { get; set; }

        /// <summary>
        /// Returns the suffix assoicated with the ListType
        /// </summary>
        public string ListSuffix
        {
            get
            {
                if (ListType == ListTypeEnum.List)
                    return "[]";
                else if (ListType == ListTypeEnum.KeyList)
                    return "<>";
                return null;
            }
        }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public virtual string CompatibleKey
        {
            get { return BaseType.ToString(); }}

        #endregion

        #region Constructor

        public Type(BaseType baseType)
        {
            BaseType = baseType;
        }

        #endregion

        #region To Methods
        /// <summary>
        /// Returns a formatted version of the type
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return ToString(true);
        }

        public virtual string ToString(bool robust)
        {
            return BaseType.ToString();
        }
        #endregion

        #region IsType methods
        public bool IsAny { get { return BaseType == ExpressionEngine.BaseType.Any; } }
        public bool IsBinary { get { return BaseType == ExpressionEngine.BaseType.Binary; } }
        public bool IsBoolean { get { return BaseType == ExpressionEngine.BaseType.Boolean; } }
        public bool IsCharge { get { return BaseType == ExpressionEngine.BaseType.Charge; } }
        public bool IsDateTime { get { return BaseType == ExpressionEngine.BaseType.DateTime; } }
        public bool IsDecimal { get { return BaseType == ExpressionEngine.BaseType.Decimal; } }
        public bool IsDouble { get { return BaseType == ExpressionEngine.BaseType.Double; } }
        public bool IsComplexType { get { return BaseType == ExpressionEngine.BaseType.ComplexType; } }
        public bool IsEnum { get { return (BaseType == BaseType.Enumeration); } }
        public bool IsFloat { get { return BaseType == ExpressionEngine.BaseType.Float; } }
        public bool IsGuid { get { return BaseType == ExpressionEngine.BaseType.Guid; } }
        public bool IsInteger { get { return BaseType == ExpressionEngine.BaseType.Integer; } }
        public bool IsInteger32 { get { return BaseType == ExpressionEngine.BaseType.Integer32; } }
        public bool IsInteger64 { get { return BaseType == ExpressionEngine.BaseType.Integer64; } }
        public bool IsMoney { get { return BaseType == ExpressionEngine.BaseType.Money; } }
        public bool IsNumeric { get { return TypeHelper.IsNumeric(BaseType); } }
        public bool IsString { get { return BaseType == ExpressionEngine.BaseType.String; } }
        public bool IsUniqueIdentifier { get { return BaseType == ExpressionEngine.BaseType.UniqueIdentifier; } }
        public bool IsUnknown { get { return BaseType == ExpressionEngine.BaseType.Unknown; } }
        #endregion
    }
}
