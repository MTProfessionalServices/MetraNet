///
/// Implements a data type. The primary purpose vs. just having just the prior C# enum is that
/// MetraNet enums can now be passed with one object as opposed to a C# enum plus two strings.
/// We could create subclass for each type or just for enums and strings. Enums require two strings
/// that the other types don't have and MSIX string defintions require a length. We shold discuss the
/// best way to model, but this is a big improvement over the old method. Once we determine the final 
/// approach we should consider refactoring the rest of ICE. Specfically, the Property class and Enum classes 
/// should use this. Not sure how much work to refactor.


using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using MetraTech.DataAccess;
using MetraTech.DataPersistenceLayer;
using MetraTech.DomainModel.Enums;
using MetraTech.ICE.TreeFlows;
using BMEProperty = MetraTech.BusinessEntity.DataAccess.Metadata.Property;

namespace MetraTech.ICE
{
    public class DataTypeInfo
    {
        #region Static properties
         /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Boolean = new DataTypeInfo(DataType._boolean) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Decimal = new DataTypeInfo(DataType._decimal) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Double = new DataTypeInfo(DataType._double) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Enum = new DataTypeInfo(DataType._enum) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Guid = new DataTypeInfo(DataType._guid) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Int32 = new DataTypeInfo(DataType._int32) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Int64 = new DataTypeInfo(DataType._int64) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo String = new DataTypeInfo(DataType._string) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo DateTime = new DataTypeInfo(DataType._timestamp) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Unistring = new DataTypeInfo(DataType._unistring) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Element = new DataTypeInfo(DataType._element) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo SqlSubstitution = new DataTypeInfo(DataType._sqlsubstitution) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo UniqueIdentifier = new DataTypeInfo(DataType._uniqueidentifier) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Int = new DataTypeInfo(DataType._int) { _readOnly = true };
        /// <summary>
        /// Do not make changes to this. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo Unknown = new DataTypeInfo(DataType._unknown) { _readOnly = true };


        /// <summary>
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo[] MSIXDataTypeInfos = new DataTypeInfo[] {
            Boolean, Decimal, Double, Enum, Guid, Int32, Int64, String, DateTime, Unistring
        };

        /// <summary>
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly List<DataType> MSIXDataTypes;

        /// <summary>
        /// Do not make changes to the objects in this array. Use CopyFrom to make a copy and make changes to the copy.
        /// </summary>
        public static readonly DataTypeInfo[] DatabaseDataTypeInfos = new DataTypeInfo[] {
            Boolean, Decimal, Double, Enum, Guid, Int32, Int64, String, DateTime, SqlSubstitution, UniqueIdentifier, Unknown
        };

        /// <summary>
        /// Create a not read only copy of the existing DataTypeInfo object
        /// </summary>
        public static DataTypeInfo CopyFrom(DataTypeInfo other)
        {
            return new DataTypeInfo
            {
                _enumSpace = other._enumSpace,
                _enumType = other._enumType,
                _length = other._length,
                _defaultStringFormat = other._defaultStringFormat,
                _type = other._type,
                _elementType = other._elementType,
                _name = other._name
            };
        }
        #endregion

        public enum DataTypeInfoFormat { MSIX, System, Oracle, SQL, MTSQL, RECORD, BME, User };

        #region variables
        private bool _readOnly = false;
        private string _enumSpace = null;
        private string _enumType = null;
        private int? _length = null;
        private ElementType? _elementType = null;
        private string _name = null;
        private DataType _type;
        private DataTypeInfoFormat _defaultStringFormat;
        #endregion

        #region properties

        public DataType Type
        {
            get
            {
                return _type;
            }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");

                _type = value;
            }
        }
        public DataTypeInfoFormat DefaultStringFormat
        {
            get
            {
                return _defaultStringFormat;
            }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");
                _defaultStringFormat = value;
            }
        }

        /// <summary>
        /// EnumSpace is only valid for enums
        /// </summary>
        public string EnumSpace
        {
            get { return _enumSpace; }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");
                if (!string.IsNullOrEmpty(value))
                    Contract.Ensure(Type == DataType._enum, "Only enum data types can have an EnumSpace");

                _enumSpace = value;
            }
        }

        /// <summary>
        /// EnumType is only valid for enums
        /// </summary>
        public string EnumType
        {
            get { return _enumType; }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");
                if (!string.IsNullOrEmpty(value))
                    Contract.Ensure(Type == DataType._enum, "Only enum data types can have an EnumType");

                _enumType = value;
            }
        }

        //Only used for MSIX and database types
        public int? Length
        {
            get { return _length; }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");

                if (value != null && value != -1)
                    Contract.Ensure(Type == DataType._string || Type == DataType._unistring, "Only string data types can have a length");

                _length = value;
            }
        }

        //Not an MSIX datatype!
        public ElementType? ElementType
        {
            get { return _elementType; }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");
                Contract.Ensure(Type == DataType._element, "Only Element data types can have a length");

                _elementType = value;
            }
        }

        public string Name
        {
            get { return _name; }
            set
            {
                Contract.Ensure(!_readOnly, "Attempt to modify read only DataTypeInfo");
                Contract.Ensure(Type == DataType._record || Type == DataType._bme, "Only Record or BME data types can have a name");

                _name = value;
            }
        }

        public string UserString { get { return ToUserString(false); } }

        #endregion

        #region Static Constructor
        static DataTypeInfo()
        {
          MSIXDataTypes = new List<DataType>();
          foreach (var dtInfo in MSIXDataTypeInfos)
          {
            MSIXDataTypes.Add(dtInfo.Type);
          }
        }
        #endregion

        #region construction
        private DataTypeInfo()
        {
            DefaultStringFormat = DataTypeInfoFormat.MSIX;
        }

        public DataTypeInfo(Property prop)
            : this()
        {
            Type = prop.Type;
            if (Type == DataType._enum &&
                !string.IsNullOrEmpty(prop.EnumSpace) &&
                !string.IsNullOrEmpty(prop.EnumType))
            {
                EnumSpace = prop.EnumSpace;
                EnumType = prop.EnumType;
            }
            else
            {
                _enumSpace = null;
                _enumType = null;
            }
        }
        public DataTypeInfo(MetraTech.ICE.AutoSdkEditor.SessionProperty prop)
            :this()
        {
            Type = prop.Type;
            if (prop.Type == DataType._enum)
            {
                if (!string.IsNullOrEmpty(prop.EnumSpace) &&
                    !string.IsNullOrEmpty(prop.EnumType))
                {
                    EnumSpace = prop.EnumSpace;
                    EnumType = prop.EnumType;
                }
                else if (prop.ReferenceProp != null
                    && !string.IsNullOrEmpty(prop.ReferenceProp.EnumSpace) &&
                    !string.IsNullOrEmpty(prop.ReferenceProp.EnumType))
                {
                    EnumSpace = prop.ReferenceProp.EnumSpace;
                    EnumType = prop.ReferenceProp.EnumType;
                }
            }
            else
            {
                _enumSpace = null;
                _enumType = null;
            }
        }

        /// <summary>
        /// Default constructor
        /// </summary>
        /// <param name="type"></param>
        public DataTypeInfo(DataType type)
            : this()
        {
            Type = type;
        }

        /// <summary>
        /// Constructor for an enum
        /// </summary>
        /// <param name="enumSpace"></param>
        /// <param name="enumType"></param>
        public DataTypeInfo(string enumSpace, string enumType)
            : this()
        {
            Type = DataType._enum;
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
            Type = DataType._string;

            if (Length < 0)
                this.Length = null;
            else
                this.Length = length;
        }

        public DataTypeInfo(ElementType elementType) 
            : this()
        {
            Type = DataType._element;
            ElementType = elementType;
        }

        public DataTypeInfo(DataType type, string name)
            : this()
        {
            Type = type;
            Name = name;
        }

        public DataTypeInfo(BMEProperty prop)
            : this()
        {
            switch (prop.PropertyType)
            {
                case MetraTech.BusinessEntity.Core.PropertyType.Boolean:
                    Type = DataType._boolean;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.DateTime:
                    Type = DataType._timestamp;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Decimal:
                    Type = DataType._decimal;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Double:
                    Type = DataType._double;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Enum:
                    Type = DataType._enum;
                    this.EnumSpace = prop.EnumType.Namespace;
                    this.EnumType = prop.EnumType.Name;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Int32:
                    Type = DataType._int32;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Int64:
                    Type = DataType._int64;
                    break;
                case MetraTech.BusinessEntity.Core.PropertyType.Guid:
                case MetraTech.BusinessEntity.Core.PropertyType.String:
                    Type = DataType._string;
                    Length = 255; //TODO: Need to support length on BE strings
                    break;
            }
        }

        #endregion

        /// <summary>
        /// Appends a "DataType" node to the specified node
        /// </summary>
        /// <param name="node"></param>
        public void WriteXmlNode(XmlNode node)
        {
            WriteXmlNode(node, "DataType");
        }
        public void WriteXmlNode(XmlNode node, string tagName)
        {
            XmlNode dtNode = XmlDocHelper.XmlNodeSetChildNode(node, tagName, this.ToMsixString());

            switch (Type)
            {
                case DataType._enum:
                    XmlDocHelper.XmlNodeSetAttribute(dtNode, "EnumSpace", EnumSpace);
                    XmlDocHelper.XmlNodeSetAttribute(dtNode, "EnumType", EnumType);
                    break;
                case DataType._string:
                    if (Length != null)
                        XmlDocHelper.XmlNodeSetAttribute(dtNode, "Length", Length.ToString());
                    break;
                case DataType._bme:
                case DataType._record:
                    XmlDocHelper.XmlNodeSetAttribute(dtNode, "Name", Name);
                    break;
            }
        }

        /// <summary>
        /// Deserializes the specified "DataType" node.
        /// </summary>
        /// <param name="node">The node that contains the "DataType" node to be deserialized.</DataType></param>
        /// <returns></returns>
        public static DataTypeInfo CreateFromDataTypeInfoXmlNode(XmlNode node)
        {
            return CreateFromDataTypeInfoXmlNode(node, "DataType");
        }
        public static DataTypeInfo CreateFromDataTypeInfoXmlNode(XmlNode node, string tagName)
        {
            XmlNode dtNode = XmlDocHelper.XmlNodeGetRequiredNode(node, tagName);
            DataType dt = GetDataTypeEnum(dtNode.InnerText);

            switch (dt)
            {
                case DataType._enum:
                    return new DataTypeInfo(XmlDocHelper.XmlNodeGetRequiredAttribute(dtNode, "EnumSpace"),
                                       XmlDocHelper.XmlNodeGetRequiredAttribute(dtNode, "EnumType"));
                case DataType._string:
                    int length = XmlDocHelper.XmlNodeGetOptionalIntAttribute(dtNode, "Length", -1);
                    if (length != -1)
                        return new DataTypeInfo(length);
                    return new DataTypeInfo(dt);
                case DataType._element:
                    return new DataTypeInfo(XmlDocHelper.XmlNodeGetRequiredEnumAttribute<ElementType>(dtNode, "ElementType")); 
                case DataType._record:
                case DataType._bme:
                    return new DataTypeInfo(dt, XmlDocHelper.XmlNodeGetRequiredAttribute(dtNode, "Name"));
                default:
                    return new DataTypeInfo(dt);
            }
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

        /// <summary>
        /// Converts a string into a DataType Enum
        /// </summary>
        /// <param name="theType"></param>
        /// <returns></returns>
        public static DataType GetDataTypeEnum(string theType)
        {
            switch (theType.ToLower())
            {
                case "string":
                    return DataType._string;
                case "unistring":
                    return DataType._unistring;
                case "id":
                case "int32":
                case "integer32":
                case "integer":
                    return DataType._int32;
                case "bigint":
                case "long":
                case "int64":
                case "integer64":
                    return DataType._int64;
                case "timestamp":
                case "datetime":
                    return DataType._timestamp;
                case "enum":
                    return DataType._enum;
                case "decimal":
                    return DataType._decimal;
                case "float":
                    return DataType._float;
                case "double":
                    return DataType._double;
                case "boolean":
                case "bool":
                    return DataType._boolean;
                case "element":
                    return DataType._element;
                case "any":
                    return DataType._any;
                case "varchar":
                    return DataType._string;
                case "nvarchar":
                    return DataType._string;
                case "characters":
                    return DataType._string;
              case "record":
                    return DataType._record;
              case "binary":
                    return DataType._binary;
                case "":
                case null:
                case "unknown":
                    return DataType._unknown;
                case "numeric":
                    return DataType._numeric;
                case "sqlsubstitution":
                case "substitution":
                    return DataType._sqlsubstitution;
                case "uniqueidentifier":
                    return DataType._uniqueidentifier;
                case "guid":
                    return DataType._guid;
                default:
                    throw new Exception("Invalid internal data type string [" + theType + "]");
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
        /// Returns a formatted version of the type
        /// </summary>
        /// <returns></returns>
        public override string ToString()
        {
            switch (DefaultStringFormat)
            {
                case DataTypeInfoFormat.MSIX:
                    return this.ToMsixString();
                case DataTypeInfoFormat.System:
                    return this.ToCSharpType().Name;
                case DataTypeInfoFormat.Oracle:
                    return this.ToOracleString();
                case DataTypeInfoFormat.SQL:
                    return this.ToSqlServerString();
                case DataTypeInfoFormat.MTSQL:
                    return this.ToMtsqlString();
                case DataTypeInfoFormat.RECORD:
                    return this.ToRecordString();
                case DataTypeInfoFormat.BME:
                    return this.ToBMEString();
                case DataTypeInfoFormat.User:
                    return this.ToUserString(false);
                default:
                    return string.Empty;
            }
        }

        public string ToUserString(bool robustMode)
        {
            switch (Type)
            {
                case DataType._boolean:
                    return "Boolean";
                case DataType._decimal:
                    return "Decimal";
                case DataType._double:
                    return "Double";
                case DataType._enum:
                    if (robustMode)
                        return string.Format ("Enum ({0}, {1})", EnumSpace, EnumType);
                    return "Enum";
                case DataType._int:
                    return "Int";
                case DataType._int32:
                    return "Integer32";
                case DataType._int64:
                    return "Integer64";
                case DataType._string:
                    if (robustMode && Length > 0)
                        return string.Format("String({0})", Length.ToString()); 
                    return "String";
                case DataType._timestamp:
                    return "DateTime";
                case DataType._element:
                    if (robustMode)
                        return string.Format("Element({0})", ElementType.ToString());
                    return "Element";
                case DataType._bme:
                    if (robustMode)
                        return string.Format("BME({0})", _name);
                    return "BME";
                case DataType._record:
                    if (robustMode)
                        return string.Format("Record({0})", _name);
                    return "Record";
                case DataType._binary:
                    if (robustMode)
                        return string.Format("Binary({0})", _name);
                    return "Binary";
                case DataType._sqlsubstitution:
                    return "SqlSubstitution";
                case DataType._guid:
                    return "Guid";
                case DataType._uniqueidentifier:
                    return "UniqueIdentifier";
              case DataType._unknown:
                    return "UNKNOWN";
              case DataType._any:
                    return "Any";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
            }
        }

        /// <summary>
        /// Returns a MTSQL version of the type
        /// </summary>
        /// <returns></returns>
        public string ToMtsqlString()
        {
            switch (Type)
            {
                case DataType._boolean:
                    return "BOOLEAN";
                case DataType._decimal:
                    return "DECIMAL";
                case DataType._double:
                    return "DOUBLE";
                case DataType._enum:
                    return "ENUM";
                case DataType._int32:
                    return "INTEGER";
                case DataType._int64:
                    return "BIGINT";
                case DataType._string:
                    return "NVARCHAR";
                case DataType._timestamp:
                    return "DATETIME";
                case DataType._binary:
                    return "BINARY";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
            }
        }

        public MTParameterType ToMTParameterType()
        {
          switch (Type)
          {
            case DataType._int64:
              return MTParameterType.BigInteger;
            case DataType._boolean:
              return MTParameterType.Boolean;
            case DataType._timestamp:
              return MTParameterType.DateTime;
            case DataType._decimal:
              return MTParameterType.Decimal;
            case DataType._guid:
              return MTParameterType.Guid;
            case DataType._enum:
            case DataType._int32:
              return MTParameterType.Integer;
            case DataType._string:
              return MTParameterType.String;
            case DataType._uniqueidentifier:
              return MTParameterType.Binary;
            default:
              throw new Exception(string.Format("Unhandled type: {0}", Type));
          }
        }

        /// <summary>
        /// Returns a MSIX version of the type
        /// </summary>
        /// <returns></returns>
        public string ToMsixString()
        {
            return DataTypeInfo.ToMsixStr(this.Type);
        }
        /// <summary>
        /// Returns a MSIX version of the type
        /// </summary>
        /// <returns></returns>
        public static string ToMsixStr(DataType type)
        {
            //Strip off the underscore
            return type.ToString().Substring(1);
        }
        public string ToBMEString()
        {
            switch (Type)
            {
                case DataType._unistring:
                case DataType._string:
                    return "String";
                case DataType._int32:
                    return "Int32";
                case DataType._int64:
                    return "Int64";
                case DataType._timestamp:
                    return "DateTime";
                case DataType._enum:
                    return "Enum"; //I'm totally unsure about this here.
                case DataType._decimal:
                    return "Decimal";
                case DataType._float:
                case DataType._double:
                    return "Double"; 
                case DataType._boolean:
                    return "Boolean";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
            }
        }
        public static string ToCSharpStr(DataType type)
        {
            return DataTypeInfo.ToCSharpType(type).ToString();
        }

        /// <summary>
        /// Returns an SQL Server version of the type
        /// </summary>
        /// <returns></returns>
        public string ToSqlServerString()
        {
            CheckLength();
            throw new ApplicationException("Not implemented yet");
        }

        /// <summary>
        /// Returns an Oracle version of the type
        /// </summary>
        /// <returns></returns>
        public string ToOracleString()
        {
            CheckLength();
            throw new ApplicationException("Not implemented yet");
        }

        /// <summary>
        /// Returns a RECORD version of the type
        /// </summary>
        /// <returns></returns>
        public string ToRecordString()
        {
            switch (Type)
            {
                case DataType._boolean:
                    return "BooleanFieldType";
                case DataType._decimal:
                    return "DecimalFieldType";
                case DataType._double:
                    return "DoubleFieldType";
                case DataType._enum:
                    return "MetraNetEnumeratedFieldType";
                case DataType._int32:
                    return "Int32FieldType";
                case DataType._int64:
                    return "Int64FieldType";
                case DataType._string:
                    return "NvarcharFieldType";
                case DataType._timestamp:
                    return "DatetimeFieldType";
                case DataType._float:
                    return "FloatFieldType";
                case DataType._binary:
                    return "BinaryFieldType";
                //case DataType.:
                //    return "VarcharFieldType";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
                //TODO: add VarcharFieldType
            }
        }

        public string ToRecordMtsqlString()
        {
            switch (Type)
            {
                case DataType._boolean:
                    return "boolean";
                case DataType._decimal:
                    return "decimal";
                case DataType._double:
                    return "double";
                case DataType._enum:
                    return "enum";
                case DataType._int32:
                    return "int32";
                case DataType._int64:
                    return "int64";
                case DataType._string:
                    return "nvarchar";
                case DataType._timestamp:
                    return "datetime";
                case DataType._float:
                    return "float";
                //case DataType.:
                //    return "VarcharFieldType";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
                //TODO: add VarcharFieldType
            }
        }

        /// <summary>
        /// Converts the datatype to a MetraFlow a default record format (note that there are many encodings)
        /// Useful for FileImport and FileExport
        /// </summary>
        /// <returns></returns>
        public string ToMetraFlowRecord()
        {
            switch (Type)
            {
                case DataType._boolean:
                    return "text_delimited_boolean";
                case DataType._decimal:
                    return "text_delimited_base10_decimal";
                case DataType._double:
                    return "";
                case DataType._enum:
                    return "text_delimited_enum";
                case DataType._int32:
                    return "text_delimited_base10_int32";
                case DataType._int64:
                    return "text_delimited_base10_int64";
                case DataType._binary:
                    return "text_fixed_hex_binary";
                case DataType._string:
                    return "text_delimited_nvarchar";
                case DataType._timestamp:
                    return "iso8601_datetime";
                case DataType._float:
                    return "";
                default:
                    throw new ApplicationException("Unhandled data type: " + Type.ToString());
            }
        }

        /// <summary>
        /// Returns the fully qualified name of the enum. If not an enum, an exception is generated
        /// </summary>
        /// <returns></returns>
        public string ToFullyQualifiedEnumName()
        {
            if (this.Type != DataType._enum)
                throw new Exception("Data type must be an enum for this action");

            return EnumerationConfiguration.GetFQNFromNamespaceAndType(EnumSpace, EnumType);
        }

        private void CheckLength()
        {
            if ((Type == DataType._string || Type == DataType._unistring) && Length == null)
                throw new ApplicationException("Length is null");
        }


        public string ToCodeString(MetraTech.ICE.TreeFlows.CodeGen.LanguageEnum lang)
        {
            switch (lang)
            {
                case MetraTech.ICE.TreeFlows.CodeGen.LanguageEnum.CSharp:
                    return ToCSharpString();
                case MetraTech.ICE.TreeFlows.CodeGen.LanguageEnum.Mtsql:
                    return ToMtsqlString();
                default:
                    throw new Exception("Unhandled language " + lang.ToString() + " passed to " + Helper.GetMethodName());
            }
        }

        public string ToCSharpString()
        {
            //Tried using ToCSharpType and using it's Name or ToString() but that didn't work.
            switch (Type)
            {
                case DataType._boolean:
                    return "bool";
                case DataType._decimal:
                    return "decimal";
                case DataType._double:
                    return "double";
                case DataType._enum:
                    return MetraTech.DomainModel.Enums.EnumHelper.GetGeneratedEnumType(EnumSpace, EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory).ToString();
                case DataType._int32:
                    return "int";
                case DataType._int64:
                    return "Int64";
                case DataType._string:
                    return "string";
                case DataType._timestamp:
                    return "DateTime";
              case DataType._record:
                    return Name;
                default:
                    throw new Exception("Unhandled DataType: " + Type.ToString());
            }
        }
        /// <summary>
        /// Returns a C# version of the type
        /// </summary>
        /// <returns></returns>
        public Type ToCSharpType()
        {
            return DataTypeInfo.ToCSharpType(Type);
        }
        public static Type ToCSharpType(DataType type)
        {
            switch (type)
            {
                case DataType._boolean:
                    return typeof(bool);
                case DataType._decimal:
                    return typeof(decimal);
                case DataType._double:
                    return typeof(double);
                case DataType._enum: //Not sure about this one!
                    return typeof(Enum); //typeof(Int32)
                case DataType._int32:
                    return typeof(int);
                case DataType._int64:
                    return typeof(Int64);
                case DataType._string:
                    return typeof(string);
                case DataType._timestamp:
                    return typeof(DateTime);
                default:
                    throw new Exception("Unhandled DataType: " + type.ToString());
            }
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
            switch (Type)
            {
              case DataType._unknown:
                return true;//Not sure if this is best behavior...
                case DataType._string:
                case DataType._unistring:
                    //Nothing to check
                    return true;
                case DataType._int32:
                    Int32 the32;
                    return System.Int32.TryParse(value, out the32);
                case DataType._int64:
                    Int64 the64;
                    return System.Int64.TryParse(value, out the64);
                case DataType._timestamp:
                    DateTime theDT;
                    return System.DateTime.TryParse(value, out theDT);
                case DataType._enum:
                    return Config.Instance.EnumerationConfig.ValueExists(EnumSpace, EnumType, value);
                case DataType._decimal:
                    Decimal theDecimal;
                    return System.Decimal.TryParse(value, out theDecimal);
                case DataType._float:
                    float theFloat;
                    return float.TryParse(value, out theFloat);
                case DataType._boolean:
                    return (Helper.ParseBool(value) != null);
                case DataType._double:
                    Double theDouble;
                    return double.TryParse(value, out theDouble);
                case DataType._element:
                    return Config.Instance.GetElement((ElementType)this.ElementType, value) != null;
                case DataType._sqlsubstitution:
                    return true;
                default:
                    throw new ApplicationException(Helper.GetMethodName() + " Unknown data type '" + Type.ToString());
            }
        }

        /// <summary>
        /// Determines if the data type is valid. If so, null is returned. Otherwise an error string is returned.
        /// At this point only cheking enums.
        /// </summary>
        /// <returns></returns>
        public string CheckDataType()
        {
          switch (Type)
          {
            case DataType._enum:
              return CheckEnum();
            default:
              return null;
          }
        }

        /// <summary>
        /// Determines if the EnumSpace and EnumType exist. If so, null is returned. Otherwise an error string is returned.
        /// </summary>
        /// <returns></returns>
        public string CheckEnum()
        {
            if (Type != DataType._enum)
                throw new ApplicationException("DataType is not an enum");

            //Check if the EnumSpace was specified
            if (string.IsNullOrEmpty(this.EnumSpace))
                return "NameSpace not specified";

            //Check if the NameSpace exists
            if (!Config.Instance.EnumerationConfig.NamespaceExists(this.EnumSpace))
                return "Unable to find EnumSpace='" + EnumSpace + "'";

            //Check if the EnumType was specified
            if (string.IsNullOrEmpty(this.EnumType))
                return "EnumType not specified";

            //Check if the EnumType exists
            if (!Config.Instance.EnumerationConfig.TypeExists(this.EnumSpace, this.EnumType))
                return "Unable to find EnumType='" + EnumType + "' in EnumSpace='" + EnumSpace + "'";

            return null;
        }


        /// <summary>
        /// Returns the enum type
        /// </summary>
        /// <returns></returns>
        public EnumerationType GetMetraNetEnumerationType()
        {
            if (Type != DataType._enum)
                throw new ApplicationException("DataType is not an enum");

            return Config.Instance.EnumerationConfig.GetEnumerationTypeFromFQN(EnumSpace + "/" + EnumType);
        }


        
        /// <summary>
        /// Returns a somewhat random value for the data type. 
        /// If you need a really random value please update this method.
        /// </summary>
        /// <param name="randomNumber"></param>
        /// <returns></returns>
        public string GetRandomValue(Random randomNumber)
        {
            switch (Type)
            {
                case DataType._boolean:
                    if (Helper.IsEven(randomNumber.Next()))
                        return "True";
                    else
                        return "False";

                case DataType._decimal:
                case DataType._double:
                case DataType._float:
                    return System.Decimal.Round((Decimal)randomNumber.Next(1, 99) + (Decimal)randomNumber.NextDouble(), 2).ToString();


                case DataType._enum:
                    if (Config.Instance == null)
                        return "";

                    if (!Config.Instance.EnumerationConfig.TypeExists(this.EnumSpace, this.EnumType))
                        return "";

                    string[] values = Config.Instance.EnumerationConfig.GetEnumValues(EnumSpace, EnumType);
                    if (values.Length == 0)
                        return "";
                    return values[randomNumber.Next() % values.Length];


                case DataType._int32:
                case DataType._int64:
                    return randomNumber.Next(0, 10000).ToString();

                case DataType._string:
                case DataType._unistring:
                    int length;
                    if (Length != null)
                        length = (int)Length;
                    else
                        length = 20;
                    return Helper.GetRandomString(randomNumber, Math.Min(4, length), Math.Min(15, length), true);

                case DataType._timestamp:
                    DateTime dt = System.DateTime.Now;
                    int offsetMinutes = randomNumber.Next(0, 100000);  //About 70 days
                    if (Helper.IsEven(randomNumber.Next()))            //Use odd/even to figure out if we're adding or subtracting
                        offsetMinutes *= -1;

                    dt = dt.AddMinutes(offsetMinutes);
                    return dt.ToString("MM-dd-yyyy hh:mm");

                default:
                    return Type.ToString();
            }
        }

        public object GetDBSyntaxCheckValue(QueryParameter.ReplacementTypeEnum replacementType, DataPersistence.DatabaseType dbType)
        {
            return GetDBSyntaxCheckValue(this.Type, replacementType, dbType);
        }
        public static object GetDBSyntaxCheckValue(DataType type, QueryParameter.ReplacementTypeEnum replacementType, DataPersistence.DatabaseType dbType)
        {
          switch (type)
          {
            case DataType._boolean:
              return "TRUE";
            case DataType._decimal:
              return "9.99";
            case DataType._double:
              return "8.88";
            case DataType._float:
              return "7.77";
            case DataType._enum:
              return "555";
            case DataType._int32:
              return "111";
            case DataType._int64:
              return "99999999";
            case DataType._string:
            case DataType._unistring:
              return "HelloWorld";
            case DataType._timestamp:
              if (replacementType == QueryParameter.ReplacementTypeEnum.DoublePercent)
                return (dbType == DataPersistence.DatabaseType.Oracle) ? "'01-JAN-1900'" : "'1900-01-01 00:00:00'";
                return new DateTime(1900, 1, 1);
              case DataType._uniqueidentifier:
              return "3AAAAAAA-BBBB-CCCC-DDDD-2EEEEEEEEEEE";
            case DataType._guid:
              return "0xAbcd";
            default:
              throw new ApplicationException("Unhandled data type: " + type.ToString());
          }
        }

        //public object GetDBSyntaxCheckValue()
        //{
        //    return DataTypeInfo.GetDBSyntaxCheckValue(this.Type);
        //}
        //public static object GetDBSyntaxCheckValue(DataType type)
        //{
        //    switch (type)
        //    {
        //        case DataType._boolean:
        //            return true;
        //        case DataType._decimal:
        //            decimal decimalValue = 9.8m;
        //            return decimalValue;
        //        case DataType._double:
        //            double doubleValue = 8.8;
        //            return doubleValue;
        //        case DataType._float:
        //            float floatValue = 9.8f;
        //            return floatValue;
        //        case DataType._enum:
        //            int enumValue = 555;
        //            return enumValue;
        //        case DataType._int32:
        //            Int32 int32Value = 12;
        //            return int32Value;
        //        case DataType._int64:
        //            Int64 int64Value = 9999999999;//Int64.MaxValue;
        //            return int64Value;
        //        case DataType._string:
        //        case DataType._unistring:
        //            return "HelloWorld";
        //        case DataType._timestamp:
        //            return System.DateTime.Now;
        //        default:
        //            throw new ApplicationException("Unhandled data type: " + type.ToString());
        //    }
        //}

        /// <summary>
        /// Determines if the data type is Enum
        /// </summary>
        /// <returns></returns>
        public bool IsEnum()
        {
            return (Type == DataType._enum);
        }

        /// <summary>
        /// Determines if the type is numeric
        /// </summary>
        /// <returns></returns>
        public bool IsNumeric()
        {
            switch (Type)
            {
                case DataType._decimal:
                case DataType._double:
                case DataType._float:
                case DataType._int32:
                case DataType._int64:
                    return true;
                default:
                    return false;
            }
        }

        /// <summary>
        /// Determines if the type can be aggregated (i.e., via a Avg, Sum, Min, Max, etc. aggregate function)
        /// </summary>
        /// <returns></returns>
        public bool IsAggregatable()
        {
            switch (Type)
            {
                case DataType._decimal:
                case DataType._double:
                case DataType._float:
                case DataType._int32:
                case DataType._int64:
                case DataType._timestamp:
                    return true;
                default:
                    return false;
            }
        }
        /// <summary>
        /// Determines if the type is text
        /// </summary>
        /// <returns></returns>
        public bool IsText()
        {
            return (Type == DataType._string || Type == DataType._unistring);
        }

        /// <summary>
        /// Determines if the type is DateTime
        /// </summary>
        /// <returns></returns>
        public bool IsDateTime()
        {
            return (Type == DataType._timestamp);
        }

        /// <summary>
        /// Determines if the data type is logic
        /// </summary>
        /// <returns></returns>
        public bool IsLogic()
        {
            return (Type == DataType._boolean);
        }

        /// <summary>
        /// Determines if the data type matches the specified summary data type
        /// </summary>
        /// <param name="summaryDataType">The summary data type to compare to</param>
        /// <returns></returns>
        public bool IsMatch(SummaryDataType? summaryDataType)
        {
            if (summaryDataType == null)
                return true;

            switch (summaryDataType)
            {
                case SummaryDataType.Numeric:
                    return IsNumeric();
                case SummaryDataType.Text:
                    return IsText();
                case SummaryDataType.DateTime:
                    return IsDateTime();
                case SummaryDataType.Logic:
                    return IsLogic();
                default:
                    throw new ApplicationException(Helper.GetMethodName() + " Unhandled SummaryDataType: " + summaryDataType.ToString());
            }
        }
        
        /// <summary>
        /// Determines if the specified data type info is the same type
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public bool IsSameType(DataTypeInfo dataTypeInfo)
        {
            return DataTypeInfo.IsSameType(this, dataTypeInfo);
        }
        public static bool IsSameType(DataTypeInfo type1, DataTypeInfo type2)
        {
            if (type1.Type != type2.Type)
                return false;

            switch (type1.Type)
            {
                case DataType._enum:
                    return (type1.EnumSpace == type2.EnumSpace && type1.EnumType == type2.EnumType);
                case DataType._record:
                case DataType._bme:
                    return (type1.Name == type2.Name);
              case DataType._element:
                    return (type1.ElementType == type2.ElementType);
            }

            return true;
        }

        /// <summary>
        /// Determines if the datatypes are the same at a high level. Any numerics 
        /// will return true and any enum will return true. All other data type need
        /// to be exact match
        /// </summary>
        /// <param name="type1"></param>
        /// <param name="type2"></param>
        /// <returns></returns>
        public static bool IsSameVeryGeneralType(DataTypeInfo type1, DataTypeInfo type2)
        {
            if (type1.IsNumeric() && type2.IsNumeric())
                return true;
            if (type1.IsEnum() && type2.IsEnum())
                return true;

            return (type1.Type == type2.Type) ;
        }
                
        public bool CanBeImplicitlyCastTo(DataTypeInfo target)
        {
            return DataTypeInfo.IsImplicitCast(this, target);
        }
        public static bool IsImplicitCast(DataTypeInfo source, DataTypeInfo target)
        {
            if (source == null || target == null)
                return false;

            //Check the easy stuff
            if (DataTypeInfo.BasicTypeIsCompatible(source, target))
                return true;

            //Integers to Decimal is OK
            if ((source.Type == DataType._int32 || source.Type == DataType._int64) && target.Type == DataType._decimal)
                return true;

            //Int32 to Int64 is OK
            if (source.Type == DataType._int32 && target.Type == DataType._int64)
                return true;

            return false;
        }

        public bool IsRecordType(string recordName)
        {
          if (Type != DataType._record)
            return false;
          return Name.Equals(recordName, StringComparison.CurrentCultureIgnoreCase);
        }

        public static string ConvertValueToCode(CodeGen.LanguageEnum lang, DataTypeInfo dtInfo, string value)
        {
            switch (lang)
            {
                case CodeGen.LanguageEnum.CSharp:
                    return ConvertValueStringToCSharpConstant(dtInfo, value);
                case CodeGen.LanguageEnum.Mtsql:
                    return ConvertValueToMtsqlConstant(dtInfo, value);
                default:
                    throw new Exception("Language not supported " + lang.ToString());
            }
        }

        public bool IsMsixCompatible(string propertyName)
        {
          return DataTypeInfo.IsMsixCompatible(this.Type, propertyName);
        }
        public static bool IsMsixCompatible(DataType type, string propertyName)
        {
          if (propertyName.Contains("."))
            return false;

          return MSIXDataTypes.Contains(type);
        }

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
                throw new ApplicationException("DataTypeInfo is null.");

            switch (dtInfo.Type)
            {
                //Decimals must have a decimal place
                case DataType._decimal:
                    if (value.StartsWith("."))
                        return "0" + value;
                    else if (!value.Contains('.'))
                        return value + ".0";
                    else
                        return value;
    
                case DataType._string:
                    return "N'" + value + "'";

                case DataType._timestamp:
                    return "'" + value + "'";
                
                case DataType._enum:
                    return string.Format("#{0}/{1}/{2}#", dtInfo.EnumSpace, dtInfo.EnumType, value);

                //Don't do anything special
                default:
                    return value;
            }
        }

        public static string ConvertValueStringToCSharpConstant(DataTypeInfo dtInfo, string value)
        {
            if (dtInfo == null)
                throw new ApplicationException("DataTypeInfo is null.");

            switch (dtInfo.Type)
            {
                //Strings and timestamps must be enclosed in quotes
                case DataType._string:
                case DataType._element:
                case DataType._timestamp:
                    return '"' + value + '"';
                case DataType._decimal:
                    return value + "M";
                case DataType._enum:
                    Type enumType = EnumHelper.GetGeneratedEnumType(dtInfo.EnumSpace, dtInfo.EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory);
                    object enumValue = EnumHelper.GetGeneratedEnumByEntry(enumType, value);
                    string enumValueName = System.Enum.GetName(enumType, enumValue);
                    return enumType.FullName + "." + enumValueName;
                default:
                    return value;
            }
        }

      public string GetMetraNetEnumString(Int32 enumInt)
        {
          return "";
        }

        public string ConvertEnumRuntimeIntegerToEnumName(int enumValue)
        {
          if (Type != DataType._enum)
            throw new Exception("Wrong data type: " + Type.ToString() + " for " + Helper.GetMethodName());
          else
          {
            string fqn = EnumerationMetraNetRuntimeUtility.Instance.GetFQNFromID(enumValue);

            string valueName;
            string typeName;
            string namespaceName;

            EnumerationConfiguration.GetNamespaceTypeAndValueFromFQN(fqn, out namespaceName, out typeName, out valueName);

            return valueName;
          }
        }

        public int ConvertEnumValueToEnumRuntimeInteger(string enumValue)
        {
          if (Type != DataType._enum)
            throw new Exception("Wrong data type: " + Type.ToString() + " for " + Helper.GetMethodName());
          else
          {
            string fqn = EnumerationConfiguration.GetFQNFromNamespaceTypeAndValue(this.EnumSpace, this.EnumType, enumValue);
            int runtimeId = EnumerationMetraNetRuntimeUtility.Instance.GetIDFromFQN(fqn);
            return runtimeId;
          }
            
        }

        public object ConvertValueToNativeValue(string value)
        {
            return DataTypeInfo.ConvertValueToNativeValue(this, value);
        }
        public static object ConvertValueToNativeValue(DataTypeInfo type, string value)
        {
            if (value == null)
                return null;

            switch (type.Type)
            {
                case DataType._boolean:
                    return Helper.GetBool(value);
                case DataType._decimal:
                    return decimal.Parse(value);
                case DataType._double:
                    return double.Parse(value);
                case DataType._enum:
                    Type enumType = EnumHelper.GetGeneratedEnumType(type.EnumSpace, type.EnumType, EnvironmentConfiguration.Instance.MetraNetBinariesDirectory);
                    return EnumHelper.GetGeneratedEnumByEntry(enumType, value);
                case DataType._float:
                    return float.Parse(value);
                case DataType._int32:
                    return int.Parse(value);
                case DataType._int64:
                    return long.Parse(value);
                case DataType._string:
                    return value;
                //case DataType._timestamp:
                //    return new DateTime.Parse(value);
                default:
                    throw new Exception("Unhandled DataType " + type.Type.ToString());
            }
        }


        
        public static bool BasicTypeIsCompatible(DataTypeInfo dt1, DataTypeInfo dt2)
        {
            if (dt1.Type != dt2.Type)
                return false;

            if (dt1.Type == DataType._enum)
                return (dt1.EnumSpace == dt2.EnumSpace && dt1.EnumType == dt2.EnumType);

            if (dt1.Type == DataType._record)
            {
              if (string.IsNullOrEmpty(dt1.Name) || string.IsNullOrEmpty(dt2.Name))
                return false;
              return (dt1.Name.Equals(dt2.Name, StringComparison.CurrentCultureIgnoreCase));
            }

            return true;
        }

        public static DataTypeInfo CreateFromProperty(Property prop)
        {
            DataTypeInfo dt = new DataTypeInfo(prop.Type);
            if (prop.Type == DataType._enum)
            {
                dt.EnumSpace = prop.EnumSpace;
                dt.EnumType = prop.EnumType;
            }
            return dt;
        }
    }
}
