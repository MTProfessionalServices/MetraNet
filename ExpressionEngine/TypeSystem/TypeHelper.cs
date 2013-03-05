using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    public static class TypeHelper
    {
        #region Properties

        public static readonly IEnumerable<Type> AllTypes;

        /// <summary>
        /// BaseTypes supported by MSIX entities (e.g., Service Definitoins, ProductViews, etc.).
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly IEnumerable<BaseType> MsixBaseTypes;

        public static readonly IEnumerable<string> MsixEntityTypes;

        /// <summary>
        /// BaseTypes that exist as native database types (e.g., string, int, etc.). In other words, there is a 1:1 mapping.
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly IEnumerable<BaseType> DatabaseBaseTypes;

        /// <summary>
        /// Maps the integer data type IDs in metranet to a BaseType
        /// </summary>
        public static Dictionary<int, BaseType> PropertyTypeIdToBaseTypeMapping = new Dictionary<int, BaseType>();

        #endregion

        #region Static Constructor
        static TypeHelper()
        {
            var baseTypes = Enum.GetValues(typeof(BaseType));
            var allTypes = new Type[baseTypes.Length];

            int index = 0;
            foreach (var value in baseTypes)
            {
                allTypes[index++] = new Type((BaseType)value);
            }
            AllTypes = allTypes;

            MsixEntityTypes = new string[]
            {
                PropertyBagConstants.AccountView,
                PropertyBagConstants.BusinessModelingEntity,
                PropertyBagConstants.ParameterTable,
                PropertyBagConstants.ProductView,
                PropertyBagConstants.ServiceDefinition
            };

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

            PropertyTypeIdToBaseTypeMapping.Add(0, BaseType.String);
            PropertyTypeIdToBaseTypeMapping.Add(2, BaseType.Integer32);
            PropertyTypeIdToBaseTypeMapping.Add(3, BaseType.DateTime);
            PropertyTypeIdToBaseTypeMapping.Add(5, BaseType.Decimal); //this is showing up a numeric(18,6)
            PropertyTypeIdToBaseTypeMapping.Add(7, BaseType.Decimal);
            PropertyTypeIdToBaseTypeMapping.Add(8, BaseType.Enumeration);
            PropertyTypeIdToBaseTypeMapping.Add(9, BaseType.Boolean);
            PropertyTypeIdToBaseTypeMapping.Add(11, BaseType.Integer64);
        }
        #endregion

        #region Methods
        /// <summary>
        /// Indicates if compatible with MSIX entities (e.g., Service Definitions, Product Views, etc.)
        /// </summary>
        public static bool IsMsixCompatible(BaseType baseType)
        {
            return MsixBaseTypes.Contains(baseType);
        }

        public static BaseType GetBaseType(string value)
        {
            if (value == null || string.IsNullOrWhiteSpace(value))
                return BaseType.Unknown;

            switch (value.ToLower(CultureInfo.InvariantCulture))
            {
                case "str":
                case "string":
                case "varchar":
                case "nvarchar":
                case "characters":
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
                case "enumeration":
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
                case "binary":
                    return BaseType.Binary;
                case "numeric":
                    return BaseType.Numeric;
                case "uniqueidentifier":
                case "uniqueid":
                    return BaseType.UniqueIdentifier;
                case "guid":
                    return BaseType.Guid;
                case "entity":
                    return BaseType.PropertyBag;
                case "unknown":
                    return BaseType.Unknown;
                case "element":
                    return BaseType.String;
                default:
                    throw new ArgumentException("Invalid internal data type string [" + value + "]");
            }
        }



        /// <summary>
        /// Returns a MTSQL version of the type
        /// </summary>
        /// <returns></returns>
        public static string GetMtsqlString(BaseType baseType)
        {
            switch (baseType)
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
                    throw new ApplicationException("Unhandled data type: " + baseType.ToString());
            }
        }

        public static string GetBmeString(BaseType baseType)
        {
            switch (baseType)
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
                    throw new ApplicationException("Unhandled data type: " + baseType.ToString());
            }
        }

        public static string GetCSharpString(BaseType baseType)
        {
            //Tried using ToCSharpType and using it's Name or ToString() but that didn't work.
            switch (baseType)
            {
                case BaseType.Boolean:
                    return "bool";
                case BaseType.Decimal:
                    return "decimal";
                case BaseType.Double:
                    return "double";
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //return MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(EnumNamespace, EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory).ToString();
                case BaseType.Integer32:
                    return "int";
                case BaseType.Integer64:
                    return "Int64";
                case BaseType.String:
                    return "string";
                case BaseType.DateTime:
                    return "DateTime";
                default:
                    throw new Exception("Unhandled Base Type: " + baseType.ToString());
            }
        }


        public static System.Type GetCSharpType(BaseType type)
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
                //return typeof (Int32);
                case BaseType.Integer32:
                    return typeof(int);
                case BaseType.Integer64:
                    return typeof(Int64);
                case BaseType.String:
                    return typeof(string);
                case BaseType.DateTime:
                    return typeof(DateTime);
                default:
                    throw new ArgumentException("Unhandled Data Type: " + type.ToString());
            }
        }

        /// <summary>
        /// Determines if the specified value is valid for the type
        /// </summary>
        /// <param name="value">The value to be checked</param>
        /// <param name="allowEmpty">Indicates if empty string and null values are allowed</param>
        /// <returns></returns>
        public static bool ValueIsValid(BaseType baseType, string value, bool allowEmpty)
        {
            //Check for null and empty string
            if (string.IsNullOrEmpty(value))
                return allowEmpty;

            //Try a conversion to see if it works
            switch (baseType)
            {
                case BaseType.Unknown:
                    return true;//Not sure if this is best behavior...
                case BaseType.String:
                    //Nothing to check
                    return true;
                case BaseType.Integer32:
                    Int32 the32;
                    return Int32.TryParse(value, out the32);
                case BaseType.Integer64:
                    Int64 the64;
                    return Int64.TryParse(value, out the64);
                case BaseType.DateTime:
                    DateTime theDt;
                    return DateTime.TryParse(value, out theDt);
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //return Config.Instance.EnumerationConfig.ValueExists(EnumNamespace, EnumType, value);
                case BaseType.Decimal:
                case BaseType.Money:
                    Decimal theDecimal;
                    return Decimal.TryParse(value, out theDecimal);
                case BaseType.Float:
                    float theFloat;
                    return float.TryParse(value, out theFloat);
                case BaseType.Boolean:
                    return (ParseBool(value) != null);
                case BaseType.Double:
                    Double theDouble;
                    return double.TryParse(value, out theDouble);
                default:
                    throw new ApplicationException(" Unknown data type '" + baseType.ToString());
            }
        }


        public static bool? ParseBool(string value)
        {
            if (string.IsNullOrEmpty(value))
                return null;

            value = value.ToLower(CultureInfo.InvariantCulture);

            if (value.Equals("f") || value.Equals("false") || value.Equals("0") || value.Equals("no") || value.Equals("n"))
                return false;
            if (value.Equals("t") || value.Equals("true") || value.Equals("1") || value.Equals("yes") || value.Equals("y"))
                return true;

            return null;
        }


        //
        //Convert the MANY variants of boolean strings in the metadata to bool
        //
        public static bool GetBoolean(string value)
        {
            if (value == null)
                throw new ArgumentNullException("value");

            value = value.ToUpper(CultureInfo.InvariantCulture);

            if (value == "Y" || value == "YES" || value == "T" || value == "TRUE" || value == "1")
                return true;
            if (value == "N" || value == "NO" || value == "F" || value == "FALSE" || value == "0")
                return false;
            if (string.IsNullOrEmpty(value))
                throw new ArgumentException("A boolean value must be specified");
            throw new ArgumentException("Invalid boolean string [" + value + "]");
        }

        public static bool IsNumeric(BaseType baseType)
        {
            switch (baseType)
            {
                case BaseType.Decimal:
                case BaseType.Double:
                case BaseType.Float:
                case BaseType.Integer:
                case BaseType.Integer32:
                case BaseType.Integer64:
                case BaseType.Charge:
                case BaseType.Numeric:
                case BaseType.Money:
                    return true;
                default:
                    return false;
            }
        }

        #endregion

        #region Convert to constant
        /// <summary>
        /// Converts an explicit value its MTSQL representation (i.e., strings are quoted, enums are fully qualified, etc.)
        /// </summary>
        public static string ConvertValueToMtsqlConstant(Type type, string value)
        {
            if (type == null)
                throw new ArgumentNullException("type");
            if (value == null)
                throw new ArgumentNullException("value");

            switch (type.BaseType)
            {
                //Decimals must have a decimal place
                case BaseType.Decimal:
                    if (value.StartsWith("."))
                        return "0" + value;
                    if (!value.Contains('.'))
                        return value + ".0";
                    return value;

                case BaseType.String:
                    return "N'" + value + "'";

                case BaseType.DateTime:
                    return "'" + value + "'";

                case BaseType.Enumeration:
                    var enumType = (EnumerationType)type;
                    return string.Format(CultureInfo.InvariantCulture, "#{0}/{1}/{2}#", enumType.Namespace, enumType.Category, value);

                //Don't do anything special
                default:
                    return value;
            }
        }

        public static string ConvertValueStringToCSharpConstant(Type type, string value)
        {
            if (type == null)
                throw new ArgumentNullException("type");
            if (value == null)
                throw new ArgumentNullException("value");

            switch (type.BaseType)
            {
                //Strings and timestamps must be enclosed in quotes
                case BaseType.String:
                case BaseType.DateTime:
                    return '"' + value + '"';
                case BaseType.Decimal:
                    return value + "M";
                case BaseType.Enumeration:
                    throw new NotImplementedException();
                //Type enumType = EnumHelper.GetGeneratedEnumType(dtInfo.EnumNamespace, dtInfo.EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory);
                //object enumValue = EnumHelper.GetGeneratedEnumByEntry(enumType, value);
                //string enumValueName = System.Enum.GetName(enumType, enumValue);
                //return enumType.FullName + "." + enumValueName;
                default:
                    return value;
            }
        }

        public static object ConvertValueToNativeValue(Type type, string value, bool useInvariantCulture)
        {
            if (type == null)
                throw new ArgumentNullException("type");
            if (value == null)
                return null;

            var cultureInfo = useInvariantCulture ? CultureInfo.InvariantCulture : CultureInfo.CurrentUICulture;

            switch (type.BaseType)
            {
                case BaseType.Boolean:
                    return GetBoolean(value);
                case BaseType.Decimal:
                    return decimal.Parse(value, cultureInfo);
                case BaseType.Double:
                    return double.Parse(value, cultureInfo);
                //case BaseType.Enumeration:
                //    return EnumHelper.GetMetraNetId(type, value);
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
