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
    public class MtType
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

        /// <summary>
        /// The level to which two DataTypeInfos match. Note that order is important
        /// because the higher number indicates a better match
        /// </summary>
        public enum MatchType
        {
            None = 0,                 //For example, String and Integer32
            BaseTypeWithDiff = 1,     //The BaseTypes match but there is some difference (i.e., two enums with differnt enumtypes)
            Convertible = 2,          //The base types are compatiable, but a UoM or Curency conversion must be performed. Only applies to numerics. 
            ImplicitCast = 3,         //The start type can be implicitly cast to the end type. Only applies to numerics (i.e., Integer32 can be implicitly cast to Integer64 but the coversion isn't true)
            Any = 4,            //Note that Any only works one way
            Exact = 5           // Integer32 and Integer32 or two enums with the same enumspace and enumtype 
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

        public MtType(BaseType baseType)
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

        #region Type comparision and filtering

        public bool IsMatch(MtType type2, MatchType minimumMatchType)
        {
            var result = CompareType(type2);
            return (result >= minimumMatchType);
        }

        public MatchType CompareType(MtType type2)
        {
            if (type2 == null)
                throw new ArgumentNullException("type2");


            //Any match only works one way
            if (BaseType == ExpressionEngine.BaseType.Any)
                return MatchType.Any;

            //Enum MOVE THIS TO SUB CLASS
            if (BaseType == ExpressionEngine.BaseType.Enumeration)
            {
                if (type2.BaseType != ExpressionEngine.BaseType.Enumeration)
                    return MatchType.None;
                var enumType = (EnumerationType)this;
                var enumType2 = (EnumerationType)type2;
                if (enumType.Namespace == enumType2.Namespace && enumType.Category == enumType2.Category)
                    return MatchType.Exact;
                return MatchType.BaseTypeWithDiff;
            }

            if (IsNumeric)
            {
                if (!type2.IsNumeric)
                    return MatchType.None;

                if (IsImplicitCast(this, type2))
                    return MatchType.ImplicitCast;

                return MatchType.Convertible;
            }

            if (BaseType == type2.BaseType)
                return MatchType.Exact;
            return MatchType.None;

            //Not dealing with UoM or Currencies
        }


        public bool IsBaseTypeFilterMatch(MtType type)
        {
            if (type == null)
                throw new ArgumentNullException("type");

            switch (type.BaseType)
            {
                case ExpressionEngine.BaseType.Any:
                    return true;
                case ExpressionEngine.BaseType.Numeric:
                    return IsNumeric;
                default:
                    return type.BaseType == BaseType;
            }
        }

        public bool CanBeImplicitlyCastTo(MtType target)
        {
            throw new NotImplementedException();
           // return Type.IsImplicitCast(this, target);
        }

        public static bool IsImplicitCast(MtType start, MtType end)
        {
            if (start == null || end == null)
                throw new ArgumentNullException("start and end arguments can't be null");
            if (!start.IsNumeric || !end.IsNumeric)
                throw new ArgumentException("Arguments must be numeric");

            if (start.BaseType == end.BaseType)
                return true;
            return false;
        }

        public MtType Copy()
        {
            throw new NotImplementedException();
        }

        #endregion


        #region Methods
        public void Validate(string prefix, ValidationMessageCollection messages)
        {
            if (messages == null)
                throw new ArgumentNullException("messages");

        }

        #endregion
    }
}
