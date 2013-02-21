using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using System.Globalization;
using System.Collections.ObjectModel;
using System.Diagnostics.Contracts;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Implements a rich data type object to span MetraNet (MSIX, BMEs, MTSQL, etc.), Metanga and databases (SQL Server and Oracle).
    /// TO DO:
    /// *Come up with a better name for the class
    /// *Implement UoM and Currency!!! this is critical
    /// *Finish the IsMatch() method
    /// *Unit tests
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class DataTypeInfo
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

        public enum ListTypeEnum { 
            None,   //Scalar
            List,   //Enumerable
            KeyList //Dictionary
        }

        #endregion

        #region Static properties

        //public static DataTypeInfo[] AllTypes;
        public static readonly DataTypeInfo[] AllTypes;

        /// <summary>
        /// BaseTypes supported by MSIX entities (e.g., Service Definitoins, ProductViews, etc.).
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly IEnumerable<BaseType> MsixBaseTypes;

        /// <summary>
        /// BaseTypes that exist as native database types (e.g., string, int, etc.). In other words, there is a 1:1 mapping.
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly IEnumerable<BaseType> DatabaseBaseTypes;

        /// <summary>
        /// Create a not read only copy of the existing DataTypeInfo object
        /// </summary>
        public static DataTypeInfo CopyFrom(DataTypeInfo other)
        {
            if (other == null)
                throw new ArgumentNullException("other");

            var type = new DataTypeInfo(other.BaseType);
            type.EnumSpace = other.EnumSpace;
            type.EnumType = other.EnumType;
            type.Length = other.Length;
            type.ComplexType = other.ComplexType;
            return type;
        }

        /// <summary>
        /// Maps the integer data type IDs in metranet to a BaseType
        /// </summary>
        public static Dictionary<int, BaseType> PropertyTypeId_BaseTypeMapping = new Dictionary<int, BaseType>();
        #endregion

        #region Properties

        /// <summary>
        /// The type of list 
        /// </summary>
        [DataMember]
        public ListTypeEnum ListType { get; set; }

        /// <summary>
        /// The underlying type (e.g, string, int32, int64, etc.)
        /// </summary>
        [DataMember]
        public BaseType BaseType { get; set; }

        /// <summary>
        /// Returns the suffix assoicated with the ListType
        /// </summary>
        public string ListSuffix
        {
            get
            {
                if (ListType == ExpressionEngine.DataTypeInfo.ListTypeEnum.List)
                    return "[]";
                else if (ListType == ExpressionEngine.DataTypeInfo.ListTypeEnum.KeyList)
                    return "<>";
                return null;
            }
        }

        /// <summary>
        /// Indicates if compatible with MSIX entities (e.g., Service Definitions, Product Views, etc.)
        /// </summary>
        public bool IsMsixCompatible { get { return MsixBaseTypes.Contains(BaseType); } }

        /// <summary>
        /// Returns a string that can be used to determine if two types are directly compatible (which is differnt than castable)
        /// </summary>
        /// <returns></returns>
        public string CompatibleKey
        {
            get
            {
                switch (BaseType)
                {
                    case BaseType.Enumeration:
                        return string.Format(CultureInfo.InvariantCulture, "{0}|{1}|{2}", BaseType, EnumSpace, EnumType);
                    case BaseType.ComplexType:
                        return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", BaseType, ComplexType);
                    default:
                        return BaseType.ToString();
                }
            }
        }


        #region EnumProperties
        /// <summary>
        /// EnumSpace is only valid for enums
        /// </summary>
        [DataMember]
        public string EnumSpace { get; set; }

        /// <summary>
        /// EnumType is only valid for enums
        /// </summary>
        [DataMember]
        public string EnumType { get; set; }
        #endregion

        #region String Properties
        /// <summary>
        /// Only valid when BaseType is String
        /// </summary>
        [DataMember]
        public int Length { get; set; }
        #endregion

        #region ComplexType Properties
        /// <summary>
        /// The type of Entity. Only valid when BaseType=Entity
        /// </summary>
        [DataMember]
        public ComplexType.ComplexTypeEnum ComplexType { get; set; }

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

        #endregion

        #region Numeric Properties
        /// <summary>
        /// Indicates the unit of measure mode (fixed or driven by other property). Only valid for when IsNumeric is true. 
        /// </summary>
        [DataMember]
        public UnitOfMeasureModeType UnitOfMeasureMode { get; set; }

        /// <summary>
        /// Depending on the UomMode, specifies a fixed UoM, a UoM category or the name of the property that determines the UOM.
        /// </summary>
        [DataMember]
        public string UnitOfMeasureQualifier { get; set; }

        #endregion

        #region Charge Properties
        [DataMember]
        public string UnitsProperty { get; set; }
        #endregion

        #endregion

        #region Static Constructor
        static DataTypeInfo()
        {
            var baseTypes = Enum.GetValues(typeof(BaseType));
            AllTypes = new DataTypeInfo[baseTypes.Length];

            int index = 0;
            foreach (var value in baseTypes)
            {
                AllTypes[index++] = new DataTypeInfo((BaseType)value);
            }

            MsixBaseTypes = new BaseType[] 
            {
              BaseType.Boolean, 
              BaseType.Decimal,
              BaseType.Double,
              BaseType.Enumeration, 
              BaseType.Guid, 
              BaseType.Integer32, 
              BaseType.Integer64, 
              BaseType.String,
              BaseType.DateTime
            };

            DatabaseBaseTypes = new BaseType[] 
          {
              BaseType.Boolean, 
              BaseType.Decimal,
              BaseType.Double,
              BaseType.Guid, 
              BaseType.Integer32, 
              BaseType.Integer64, 
              BaseType.String,
              BaseType.DateTime
            };

            PropertyTypeId_BaseTypeMapping.Add(0, BaseType.String);
            PropertyTypeId_BaseTypeMapping.Add(2, BaseType.Integer32);
            PropertyTypeId_BaseTypeMapping.Add(3, BaseType.DateTime);
            PropertyTypeId_BaseTypeMapping.Add(5, BaseType.Decimal); ///this is showing up a numeric(18,6)
            PropertyTypeId_BaseTypeMapping.Add(7, BaseType.Decimal);
            PropertyTypeId_BaseTypeMapping.Add(8, BaseType.Enumeration);
            PropertyTypeId_BaseTypeMapping.Add(9, BaseType.Boolean);
            PropertyTypeId_BaseTypeMapping.Add(11, BaseType.Integer64);
        }
        #endregion

        #region Constructors
        private DataTypeInfo()
        {
            ListType = ListTypeEnum.None; 
        }

        /// <summary>
        /// Default constructor
        /// </summary>
        /// <param name="type"></param>
        public DataTypeInfo(BaseType type)
            : this()
        {
            BaseType = type;
        }

        /// <summary>
        /// Constructor for an enum
        /// </summary>
        /// <param name="enumSpace"></param>
        /// <param name="enumType"></param>
        public DataTypeInfo(string enumSpace, string enumType)
            : this()
        {
            BaseType = BaseType.Enumeration;
            this.EnumSpace = enumSpace;
            this.EnumType = enumType;
        }

        /// <summary>
        /// Constructor for a string with a length (i.e., an MSIX or database property)
        /// </summary>
        /// <param name="length"></param>
        public DataTypeInfo(int length)
            : this()
        {
            BaseType = BaseType.String;
            Length = length;
        }

        //public DataTypeInfo(BMEProperty prop)
        //    : this()
        //{
        //    switch (prop.PropertyType)
        //    {
        //        case MetraTech.BusinessEntity.Core.PropertyType.Boolean:
        //            BaseType = BaseType._boolean;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.DateTime:
        //            BaseType = BaseType._timestamp;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Decimal:
        //            BaseType = BaseType._decimal;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Double:
        //            BaseType = BaseType._double;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Enum:
        //            BaseType = BaseType._enum;
        //            this.EnumSpace = prop.EnumType.Namespace;
        //            this.EnumType = prop.EnumType.Name;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Int32:
        //            BaseType = BaseType._int32;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Int64:
        //            BaseType = BaseType._int64;
        //            break;
        //        case MetraTech.BusinessEntity.Core.PropertyType.Guid:
        //        case MetraTech.BusinessEntity.Core.PropertyType.String:
        //            BaseType = BaseType._string;
        //            Length = 255; //TODO: Need to support length on BE strings
        //            break;
        //    }
        //}

        #endregion

        #region Static Create Methods

        public static DataTypeInfo CreateBoolean()
        {
            return new DataTypeInfo(BaseType.Boolean);
        }
        public static DataTypeInfo CreateEnum(string enumSpace, string enumType)
        {
            var type = new DataTypeInfo(BaseType.Enumeration);
            type.EnumSpace = enumSpace;
            type.EnumType = enumType;
            return type;
        }

        public static DataTypeInfo CreateEntity(ComplexType.ComplexTypeEnum entityType, string subtype)
        {
            var dataType = new DataTypeInfo(BaseType.ComplexType);
            dataType.ComplexType = entityType;
            dataType.ComplexSubtype = subtype;
            return dataType;
        }

        public static DataTypeInfo CreatesString()
        {
            return CreateString(0);
        }
        public static DataTypeInfo CreateString(int length)
        {
            var type = new DataTypeInfo(BaseType.String);
            type.Length = length;
            return type;
        }




        /// <summary>
        /// Returns a DataTypeInfo based on a DataType string. For example, "int32" or "string". Note that
        /// for datatypes such as record, enum etc. that additional properties must be set elsewhere.
        /// </summary>
        /// <param name="theType"></param>
        /// <returns></returns>
        public static DataTypeInfo CreateFromDataTypeString(string theType)
        {
            return new DataTypeInfo(GetDataTypeEnum(theType));
        }

        #endregion

        #region To Methods
        /// <summary>
        /// Returns a formatted version of the type
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            return ToUserString(true);
        }


        public string ToUserString(bool robustMode)
        {
            string baseStr = null;
            switch (BaseType)
            {
                case BaseType.Any:
                    return "Any";
                case BaseType.Boolean:
                    return "Boolean";
                case BaseType.Binary:
                    if (robustMode)
                        return string.Format(CultureInfo.InvariantCulture, "Binary({0})", ComplexType);
                    return "Binary";
                case BaseType.Charge:
                    baseStr = "Charge";
                    break;
                case BaseType.DateTime:
                    return "DateTime"; ;
                case BaseType.Decimal:
                    baseStr = "Decimal";
                    break;
                case BaseType.Double:
                    baseStr = "Double";
                    break;
                case BaseType.Enumeration:
                    if (robustMode)
                        return string.Format(CultureInfo.InvariantCulture, "Enum.{0}.{1}", EnumSpace, EnumType);
                    return "Enum";
                case BaseType.Integer:
                    baseStr = "Integer";
                    break;
                case BaseType.Integer32:
                    baseStr = "Integer32";
                    break;
                case BaseType.Integer64:
                    baseStr = "Integer64";
                    break;
                case BaseType.String:
                    if (robustMode && Length > 0)
                        return string.Format(CultureInfo.InvariantCulture, "String({0})", Length.ToString(CultureInfo.InvariantCulture));
                    return "String";
                case BaseType.Guid:
                    return "Guid";
                case BaseType.UniqueIdentifier:
                    return "UniqueIdentifier";
                case BaseType.Unknown:
                    return "Unknown";
                case BaseType.Float:
                    baseStr = "Float";
                    break;
                case BaseType.Numeric:
                    baseStr = "Numeric";
                    break;
                case BaseType.ComplexType:
                    //return string.Format("ComplexSubType");
                    return string.Format(CultureInfo.InvariantCulture, "{0}: {1}", ComplexType, ComplexSubtype);
                default:
                    throw new ApplicationException("Unhandled data type: " + BaseType.ToString());
            }

            if (!robustMode)
                return baseStr;

            return string.Format(CultureInfo.InvariantCulture, "{0} ({1})", baseStr, GetUnitOfMeasureDecoration());
        }

        public string GetUnitOfMeasureDecoration()
        {
            switch (UnitOfMeasureMode)
            {
                case UnitOfMeasureModeType.None:
                    if (BaseType == ExpressionEngine.BaseType.Charge)
                        return "No Currency";
                    return "No UoM";
                case UnitOfMeasureModeType.Fixed:
                    return UnitOfMeasureQualifier;
                case UnitOfMeasureModeType.Category:
                    return UnitOfMeasureQualifier;
                case UnitOfMeasureModeType.Context:
                    return "Context";
                case UnitOfMeasureModeType.Property:
                    return string.Format("UoM Property: {0}", UnitOfMeasureQualifier);
                default:
                    return null;
            }
        }

        /// <summary>
        /// Returns a MTSQL version of the type
        /// </summary>
        /// <returns></returns>
        public string ToMtsqlString()
        {
            switch (BaseType)
            {
                case BaseType.Boolean:
                    return "BOOLEAN";
                case BaseType.Decimal:
                    return "DECIMAL";
                case BaseType.Double:
                    return "DOUBLE";
                case BaseType.Enumeration:
                    return "ENUM";
                case BaseType.Integer32:
                    return "INTEGER";
                case BaseType.Integer64:
                    return "BIGINT";
                case BaseType.String:
                    return "NVARCHAR";
                case BaseType.DateTime:
                    return "DATETIME";
                case BaseType.Binary:
                    return "BINARY";
                default:
                    throw new ApplicationException("Unhandled data type: " + BaseType.ToString());
            }
        }

        public string ToBmeString()
        {
            switch (BaseType)
            {
                case BaseType.String:
                    return "String";
                case BaseType.Integer32:
                    return "Int32";
                case BaseType.Integer64:
                    return "Int64";
                case BaseType.DateTime:
                    return "DateTime";
                case BaseType.Enumeration:
                    return "Enum"; //I'm totally unsure about this here.
                case BaseType.Decimal:
                    return "Decimal";
                case BaseType.Float:
                case BaseType.Double:
                    return "Double";
                case BaseType.Boolean:
                    return "Boolean";
                default:
                    throw new ApplicationException("Unhandled data type: " + BaseType.ToString());
            }
        }
        public static string ToCSharpString(BaseType type)
        {
            return DataTypeInfo.ToCSharpType(type).ToString();
        }


        public string ToCSharpString()
        {
            //Tried using ToCSharpType and using it's Name or ToString() but that didn't work.
            switch (BaseType)
            {
                case BaseType.Boolean:
                    return "bool";
                case BaseType.Decimal:
                    return "decimal";
                case BaseType.Double:
                    return "double";
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //return MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(EnumSpace, EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory).ToString();
                case BaseType.Integer32:
                    return "int";
                case BaseType.Integer64:
                    return "Int64";
                case BaseType.String:
                    return "string";
                case BaseType.DateTime:
                    return "DateTime";
                default:
                    throw new Exception("Unhandled DataType: " + BaseType.ToString());
            }
        }


        /// <summary>
        /// Returns a C# version of the type
        /// </summary>
        /// <returns></returns>
        public Type ToCSharpType()
        {
            return DataTypeInfo.ToCSharpType(BaseType);
        }
        public static Type ToCSharpType(BaseType type)
        {
            switch (type)
            {
                case BaseType.Boolean:
                    return typeof(bool);
                case BaseType.Decimal:
                    return typeof(decimal);
                case BaseType.Double:
                    return typeof(double);
                case BaseType.Enumeration: //Not sure about this one!
                    return typeof(EnumHelper); //typeof(Int32)
                case BaseType.Integer32:
                    return typeof(int);
                case BaseType.Integer64:
                    return typeof(Int64);
                case BaseType.String:
                    return typeof(string);
                case BaseType.DateTime:
                    return typeof(DateTime);
                default:
                    throw new Exception("Unhandled Data Type: " + type.ToString());
            }
        }

        /// <summary>
        /// Used to force special data types to the top of combo boxes etc.
        /// </summary>
        public string FilterString { get { return ToFilterString(); } }
        public string ToFilterString()
        {
            var value = ToUserString(false);
            switch (BaseType)
            {
                case BaseType.Any:
                case BaseType.Numeric:
                    return string.Format(CultureInfo.InvariantCulture, "<{0}>", value);
                default:
                    return value;
            }
        }
        #endregion

        #region Validation Methods

        public void Validate(string prefix, ValidationMessageCollection messages)
        {
            if (messages == null)
                throw new ArgumentNullException("messages");

            string errorMsg = null;
            switch (BaseType)
            {
                case ExpressionEngine.BaseType.Enumeration:
                    errorMsg = CheckEnum();
                    break;
                case ExpressionEngine.BaseType.ComplexType:
                    throw new NotImplementedException();
                case ExpressionEngine.BaseType.String:
                    throw new NotImplementedException();
            }

            if (errorMsg == null)
                return;

            messages.Error(prefix + errorMsg);
        }

        /// <summary>
        /// Determines if the specified value is valid for the type
        /// </summary>
        /// <param name="value">The value to be checked</param>
        /// <param name="allowEmpty">Indicates if empty string and null values are allowed</param>
        /// <returns></returns>
        public bool ValueIsValid(string value, bool allowEmpty)
        {
            //Check for null and empty string
            if (string.IsNullOrEmpty(value))
                return allowEmpty;

            //Try a conversion to see if it works
            switch (BaseType)
            {
                case BaseType.Unknown:
                    return true;//Not sure if this is best behavior...
                case BaseType.String:
                    //Nothing to check
                    return true;
                case BaseType.Integer32:
                    Int32 the32;
                    return System.Int32.TryParse(value, out the32);
                case BaseType.Integer64:
                    Int64 the64;
                    return System.Int64.TryParse(value, out the64);
                case BaseType.DateTime:
                    DateTime theDT;
                    return System.DateTime.TryParse(value, out theDT);
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //return Config.Instance.EnumerationConfig.ValueExists(EnumSpace, EnumType, value);
                case BaseType.Decimal:
                    Decimal theDecimal;
                    return System.Decimal.TryParse(value, out theDecimal);
                case BaseType.Float:
                    float theFloat;
                    return float.TryParse(value, out theFloat);
                case BaseType.Boolean:
                    return (Helper.ParseBool(value) != null);
                case BaseType.Double:
                    Double theDouble;
                    return double.TryParse(value, out theDouble);
                default:
                    throw new ApplicationException(" Unknown data type '" + BaseType.ToString());
            }
        }


        /// <summary>
        /// Determines if the EnumSpace and EnumType exist. If so, null is returned. Otherwise an error string is returned.
        /// </summary>
        /// <returns></returns>
        private string CheckEnum()
        {
            ThrowExcpetionIfWrongType(BaseType.Enumeration);

            //Check if the EnumSpace was specified
            if (string.IsNullOrEmpty(EnumSpace))
                return Localization.EnumNamespaceNotSpecified;

            //Check if the NameSpace exists
            if (!EnumHelper.NameSpaceExists(EnumSpace))
                return string.Format(CultureInfo.InvariantCulture, Localization.UnableToFindEnumNamespace, EnumSpace);

            //Check if the EnumType was specified
            if (string.IsNullOrEmpty(this.EnumType))
                return Localization.EnumTypeNotSpecified;

            //Check if the EnumType exists
            if (!EnumHelper.TypeExists(EnumSpace, EnumType))
                return string.Format(CultureInfo.InvariantCulture, Localization.UnableToFindEnumType, EnumSpace + "." + EnumType);

            return null;
        }

        private void ThrowExcpetionIfWrongType(BaseType expected)
        {
            if (expected != BaseType)
                throw new ApplicationException(string.Format(CultureInfo.InvariantCulture, Localization.BaseTypeIncorrect, expected, BaseType));
        }

        #endregion

        #region Misc Methods

        /// <summary>
        /// Converts a string into a DataType Enum
        /// </summary>
        /// <param name="theType"></param>
        /// <returns></returns>
        public static BaseType GetDataTypeEnum(string theType)
        {
            if (theType == null)
                throw new ArgumentNullException("theType");

            switch (theType.ToLower(CultureInfo.InvariantCulture))
            {
                case "string":
                    return BaseType.String;
                case "id":
                case "int32":
                case "integer32":
                case "integer":
                    return BaseType.Integer32;
                case "bigint":
                case "long":
                case "int64":
                case "integer64":
                    return BaseType.Integer64;
                case "timestamp":
                case "datetime":
                    return BaseType.DateTime;
                case "enum":
                    return BaseType.Enumeration;
                case "decimal":
                    return BaseType.Decimal;
                case "float":
                    return BaseType.Float;
                case "double":
                    return BaseType.Double;
                case "boolean":
                case "bool":
                    return BaseType.Boolean;
                case "any":
                    return BaseType.Any;
                case "varchar":
                    return BaseType.String;
                case "nvarchar":
                    return BaseType.String;
                case "characters":
                    return BaseType.String;
                case "binary":
                    return BaseType.Binary;
                case "":
                case null:
                case "unknown":
                    return BaseType.Unknown;
                case "numeric":
                    return BaseType.Numeric;
                case "uniqueidentifier":
                    return BaseType.UniqueIdentifier;
                case "guid":
                    return BaseType.Guid;
                case "entity":
                    return BaseType.ComplexType;
                default:
                    throw new ArgumentException("Invalid internal data type string [" + theType + "]");
            }
        }


        /// <summary>
        /// Returns a deep copy.
        /// </summary>
        /// <returns></returns>
        public DataTypeInfo Copy()
        {
            return DataTypeInfo.CopyFrom(this);
        }
        /// <summary>
        /// Returns a somewhat random value for the data type. 
        /// If you need a really random value please update this method.
        /// </summary>
        /// <param name="randomNumber"></param>
        /// <returns></returns>
        public string GetRandomValue(Random randomNumber)
        {
            if (randomNumber == null)
                throw new ArgumentNullException("randomNumber");

            switch (BaseType)
            {
                case BaseType.Boolean:
                    if (Helper.IsEven(randomNumber.Next()))
                        return "True";
                    else
                        return "False";

                case BaseType.Decimal:
                case BaseType.Double:
                case BaseType.Float:
                    return System.Decimal.Round((Decimal)randomNumber.Next(1, 99) + (Decimal)randomNumber.NextDouble(), 2).ToString(CultureInfo.InvariantCulture);

                case BaseType.Enumeration:
                    var values = EnumHelper.GetValues(EnumSpace, EnumType);
                    return values[randomNumber.Next() % values.Count];

                case BaseType.Integer32:
                case BaseType.Integer64:
                    return randomNumber.Next(0, 10000).ToString(CultureInfo.InvariantCulture);

                case BaseType.String:
                    return Helper.GetRandomString(randomNumber, Math.Min(4, Length), Math.Min(15, Length), true);

                case BaseType.DateTime:
                    DateTime dt = System.DateTime.Now;
                    int offsetMinutes = randomNumber.Next(0, 100000);  //About 70 days
                    if (Helper.IsEven(randomNumber.Next()))            //Use odd/even to figure out if we're adding or subtracting
                        offsetMinutes *= -1;

                    dt = dt.AddMinutes(offsetMinutes);
                    return dt.ToString("MM-dd-yyyy hh:mm", CultureInfo.InvariantCulture);

                default:
                    return BaseType.ToString();
            }
        }

        public object GetDBSyntaxCheckValue()
        {
            return GetDBSyntaxCheckValue();
        }
        public static object GetDBSyntaxCheckValue(BaseType type)
        {
            switch (type)
            {
                case BaseType.Boolean:
                    return "TRUE";
                case BaseType.Decimal:
                    return "9.99";
                case BaseType.Double:
                    return "8.88";
                case BaseType.Float:
                    return "7.77";
                case BaseType.Enumeration:
                    return "555";
                case BaseType.Integer32:
                    return "111";
                case BaseType.Integer64:
                    return "99999999";
                case BaseType.String:
                case BaseType.DateTime:
                    return new DateTime(1900, 1, 1);
                case BaseType.UniqueIdentifier:
                    return "3AAAAAAA-BBBB-CCCC-DDDD-2EEEEEEEEEEE";
                case BaseType.Guid:
                    return "0xAbcd";
                default:
                    throw new ArgumentException("Unhandled data type: " + type.ToString());
            }
        }
        #endregion

        #region Is data type properties

        public bool IsAny { get { return BaseType == ExpressionEngine.BaseType.Any; } }
        public bool IsBinary { get { return BaseType == ExpressionEngine.BaseType.Binary; } }
        public bool IsBoolean { get { return BaseType == ExpressionEngine.BaseType.Boolean; } }
        public bool IsCharge { get { return BaseType == ExpressionEngine.BaseType.Charge; } }

        /// <summary>
        /// Determines if the data type is a DateTime
        /// </summary>
        public bool IsDateTime { get { return BaseType == ExpressionEngine.BaseType.DateTime; } }

        /// <summary>
        /// Determines if the data type is Enum
        /// </summary>
        public bool IsEnum { get { return (BaseType == BaseType.Enumeration); } }

        public bool IsComplexType { get { return BaseType == ExpressionEngine.BaseType.ComplexType; } }

        /// <summary>
        /// Determines if the type is numeric
        /// </summary>
        /// <returns></returns>
        public bool IsNumeric
        {
            get
            {
                switch (BaseType)
                {
                    case BaseType.Decimal:
                    case BaseType.Double:
                    case BaseType.Float:
                    case BaseType.Integer:
                    case BaseType.Integer32:
                    case BaseType.Integer64:
                    case BaseType.Charge:
                        return true;
                    default:
                        return false;
                }
            }
        }

        #endregion

        #region Type comparision and filtering

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

        public bool IsMatch(DataTypeInfo type2, MatchType minimumMatchType)
        {
            var result = CompareType(type2);
            return (result >= minimumMatchType);
        }

        public MatchType CompareType(DataTypeInfo type2)
        {
            if (type2 == null)
                throw new ArgumentNullException("type2");


            //Any match only works one way
            if (BaseType == ExpressionEngine.BaseType.Any)
                return MatchType.Any;

            //Enum
            if (BaseType == ExpressionEngine.BaseType.Enumeration)
            {
                if (type2.BaseType != ExpressionEngine.BaseType.Enumeration)
                    return MatchType.None;
                if (EnumSpace == type2.EnumSpace && EnumType == type2.EnumType)
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


        public bool IsBaseTypeFilterMatch(DataTypeInfo type)
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

        public bool CanBeImplicitlyCastTo(DataTypeInfo target)
        {
            return DataTypeInfo.IsImplicitCast(this, target);
        }

        public static bool IsImplicitCast(DataTypeInfo start, DataTypeInfo end)
        {
            if (start == null || end == null)
                throw new ArgumentNullException("start and end arguments can't be null");
            if (!start.IsNumeric || !end.IsNumeric)
                throw new ArgumentException("Arguments must be numeric");

            if (start.BaseType == end.BaseType)
                return true;
            return false;
        }
        #endregion

        #region Convert to constant
        /// <summary>
        /// Converts an explicit value its MTSQL representation (i.e., strings are quoted, enums are fully qualified, etc.)
        /// </summary>
        /// <param name="type"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        ///
        public static string ConvertValueToMtsqlConstant(DataTypeInfo dtInfo, string value)
        {
            if (dtInfo == null)
                throw new ArgumentNullException("dtInfo");
            if (value == null)
                throw new ArgumentNullException("value");

            switch (dtInfo.BaseType)
            {
                //Decimals must have a decimal place
                case BaseType.Decimal:
                    if (value.StartsWith("."))
                        return "0" + value;
                    else if (!value.Contains('.'))
                        return value + ".0";
                    else
                        return value;

                case BaseType.String:
                    return "N'" + value + "'";

                case BaseType.DateTime:
                    return "'" + value + "'";

                case BaseType.Enumeration:
                    return string.Format(CultureInfo.InvariantCulture, "#{0}/{1}/{2}#", dtInfo.EnumSpace, dtInfo.EnumType, value);

                //Don't do anything special
                default:
                    return value;
            }
        }

        public static string ConvertValueStringToCSharpConstant(DataTypeInfo dtInfo, string value)
        {
            if (dtInfo == null)
                throw new ArgumentNullException("dtInfo");
            if (value == null)
                throw new ArgumentNullException("value");

            switch (dtInfo.BaseType)
            {
                //Strings and timestamps must be enclosed in quotes
                case BaseType.String:
                case BaseType.DateTime:
                    return '"' + value + '"';
                case BaseType.Decimal:
                    return value + "M";
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //Type enumType = EnumHelper.GetGeneratedEnumType(dtInfo.EnumSpace, dtInfo.EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory);
                //object enumValue = EnumHelper.GetGeneratedEnumByEntry(enumType, value);
                //string enumValueName = System.Enum.GetName(enumType, enumValue);
                //return enumType.FullName + "." + enumValueName;
                default:
                    return value;
            }
        }

        public object ConvertValueToNativeValue(string value)
        {
            return DataTypeInfo.ConvertValueToNativeValue(this, value, true);
        }

        public static object ConvertValueToNativeValue(DataTypeInfo type, string value, bool useInvariantCulture)
        {
            if (type == null)
                throw new ArgumentNullException("type");
            if (value == null)
                return null;

            var cultureInfo = useInvariantCulture ? CultureInfo.InvariantCulture : CultureInfo.CurrentUICulture;

            switch (type.BaseType)
            {
                case BaseType.Boolean:
                    return Helper.GetBoolean(value);
                case BaseType.Decimal:
                    return decimal.Parse(value, cultureInfo);
                case BaseType.Double:
                    return double.Parse(value, cultureInfo);
                case BaseType.Enumeration:
                    return EnumHelper.GetMetraNetIntValue(type, value);
                case BaseType.Float:
                    return float.Parse(value, cultureInfo);
                case BaseType.Integer32:
                    return int.Parse(value, cultureInfo);
                case BaseType.Integer64:
                    return long.Parse(value, cultureInfo);
                case BaseType.String:
                    return value;
                //case DataType._timestamp:
                //    return new DateTime.Parse(value);
                default:
                    throw new ArgumentException("Unhandled DataType " + type.BaseType.ToString());
            }
        }
        #endregion

    }
}
