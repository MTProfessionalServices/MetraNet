using System;
using System.Collections.Generic;
using System.Data;
using System.Runtime.Serialization;
using System.Threading;
using Core.Common;
using MetraTech.DataAccess;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.DataAccess.Rule;
using MetraTech.DomainModel.Enums;
using NHibernate;
using NHibernate.Cfg.MappingSchema;
using NHibernate.Dialect;
using NHibernate.SqlTypes;
using NHibernate.Type;

using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Exception;

using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.Basic.Exception;
using MetraTech.Basic;
using NHibernate.Util;


namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class Property : Metadata
  {
    #region Constructors
    /// <summary>
    ///    Constructor
    /// </summary>
    public Property()
    {
      Label = String.Empty;
      Description = String.Empty;
      DefaultValue = String.Empty;
      IsSortable = true;
      RecordHistory = true;
      LocalizedLabels = new List<LocalizedEntry>();
    }

    /// <summary>
    ///    Specify the name and type name
    /// </summary>
    /// <param name="name"></param>
    /// <param name="typeName"></param>
    /// <param name="checkPropertyName"></param>
    public Property(string name, string typeName, bool checkPropertyName = true)
    {
      Initialize(name, typeName, checkPropertyName);
    }

    /// <summary>
    ///    Specify owning entity, name and type name
    /// </summary>
    /// <param name="entity"></param>
    /// <param name="name"></param>
    /// <param name="typeName"></param>
    /// <param name="checkPropertyName"></param>
    internal Property(Entity entity, string name, string typeName, bool checkPropertyName = true)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);
      Entity = entity;
      Initialize(name, typeName, checkPropertyName);
    }

    #endregion

    #region Properties
    /// <summary>
    ///    Name of the C# property
    /// </summary>
    [DataMember]
    public string Name { get; set; }

    /// <summary>
    ///    Db column name of the C# property
    /// </summary>
    [DataMember]
    public string ColumnName { get; set; }

    /// <summary>
    ///    TypeName of the C# property
    /// </summary>
    [DataMember]
    public string TypeName { get; set; }

    /// <summary>
    ///    Assembly qualified type name of the C# property
    /// </summary>
    [DataMember]
    public string AssemblyQualifiedTypeName { get; set; }

    /// <summary>
    ///    Assembly name of the C# property
    /// </summary>
    [DataMember]
    public string AssemblyName { get; set; }

    /// <summary>
    ///    PropertyType of the C# property
    /// </summary>
    [DataMember]
    public PropertyType PropertyType { get; set; }

    /// <summary>
    ///    The label for this entity 
    /// </summary>
    [DataMember]
    public string Label { get; set; }

    /// <summary>
    ///    The description of the property.  
    /// </summary>
    [DataMember]
    public string Description { get; set; }

    /// <summary>
    ///    DefaultValue. 
    /// </summary>
    [DataMember]
    public string DefaultValue { get; set; }

    /// <summary>
    ///    RecordHistory. 
    /// </summary>
    [DataMember]
    public bool RecordHistory { get; set; }

    /// <summary>
    ///    DefaultValue. 
    /// </summary>
    public object DefaultValueObject { get; set; }

    private bool isBusinessKey;
    /// <summary>
    ///    True, if this property is a business key. 
    /// </summary>
    [DataMember]
    public bool IsBusinessKey 
    {
      get { return isBusinessKey; }
      set 
      { 
        isBusinessKey = value; 
        if (isBusinessKey)
        {
          IsRequired = true;
          IsUnique = true;
        }
      }
    }

    /// <summary>
    ///   True if this property is from a NetMeter table
    /// </summary>
    [DataMember]
    public bool IsCompound { get; set; }

    /// <summary>
    ///   True if this property is from a NetMeter table and a primary key in that table
    /// </summary>
    [DataMember]
    public bool IsLegacyPrimaryKey { get; set; }

    /// <summary>
    ///   Non-null if this is a compound property
    /// </summary>
    [DataMember]
    public DbColumnMetadata DbColumnMetadata { get; set; }

    /// <summary>
    ///    If IsBusinessKey is true, then this is ignored. Generates a non-null column specification.
    /// </summary>
    [DataMember]
    public bool IsRequired { get; set; }

    /// <summary>
    ///    If IsBusinessKey is true, then this is ignored. 
    /// </summary>
    [DataMember]
    public bool IsUnique { get; set; }

    /// <summary>
    ///    True, if this property can be sorted. 
    /// </summary>
    [DataMember]
    public bool IsSortable { get; set; }

    /// <summary>
    ///    True, if this property is searchable. 
    /// </summary>
    [DataMember]
    public bool IsSearchable { get; set; }

    /// <summary>
    ///    Will be used when support for encryption is added. 
    /// </summary>
    [DataMember]
    public bool IsEncrypted { get; set; }

    /// <summary>
    ///    Used to order the properties. 
    /// </summary>
    [DataMember]
    public int Order { get; set; }

    /// <summary>
    ///    Non-null if BasicPropertyType == Enum. 
    /// </summary>
    [DataMember]
    public EnumType EnumType {get; set;}

    /// <summary>
    ///    True, if this is a property in a custom base class.
    /// </summary>
    [DataMember]
    public bool IsCustomBaseClassProperty { get; set; }
    
    /// <summary>
    ///   FullName
    /// </summary>
    public string FullName
    {
      get
      {
        return Entity.FullName + "." + Name;
      }
    }

    /// <summary>
    ///    Field name of the C# property
    /// </summary>
    public string FieldName
    {
      get
      {
        return Name.StartsWith("@") ? 
               "@_" + Name.Remove(0, 1).LowerCaseFirst() : 
               "_" + Name.LowerCaseFirst();
      }
    }

    public bool IsEnum
    {
      get
      {
        return PropertyType == PropertyType.Enum;
      }
    }

    public bool IsValueType
    {
      get
      {
        if (PropertyType == PropertyType.Boolean || 
            PropertyType == PropertyType.DateTime ||
            PropertyType == PropertyType.Decimal ||
            PropertyType == PropertyType.Double ||
            PropertyType == PropertyType.Guid ||
            PropertyType == PropertyType.Int32 ||
            PropertyType == PropertyType.Int64 ||
            PropertyType == PropertyType.Enum)
        {
          return true;
        }

        return false;
      }
    }

    private bool IsBasicPropertyType
    {
      get
      {
        if (PropertyType == PropertyType.Enum)
        {
          return false;
        }

        return true;
      }
    }

    private ICollection<string> BasicPropertyTypes
    {
      get
      {
        return new List<string>()
                 {
                   BooleanTypeName,
                   DateTimeTypeName,
                   DecimalTypeName,
                   DoubleTypeName,
                   GuidTypeName,
                   Int32TypeName,
                   Int64TypeName,
                   StringTypeName,
                   EnumTypeName
                 };
      }

    }

    public bool IsAssociation { get { return !String.IsNullOrEmpty(AssociationEntityName); } }
    public string AssociationEntityName { get; set; }

    [DataMember]
    public bool IsComputed { get; set; }
    [DataMember]
    public string ComputationTypeName { get; set; }

    /// <summary>
    ///   Map the CulterInfo.TwoLetterISOLanguageName	to the localized label
    /// </summary>
    [DataMember]
    public virtual List<LocalizedEntry> LocalizedLabels { get; set; }

    // Specifies the length of string data types. Ignored for other data types.
    // Default value is 255 characters.
    [DataMember]
    public Int32 Length { get; set; }

    #endregion

    #region Public Static Methods
    public static string GetColumnName(string propertyName)
    {
      if (propertyName.Length > 24)
      {
        propertyName = propertyName.Substring(0, 24);
      }

      return "c_" + propertyName + "_Id";
    }

    public static string GetColumnName(string entityName, string propertyName)
    {
      return MetadataRepository.Instance.GetColumnName(entityName, propertyName);
    }

    public static Property CreateProperty(DbColumnMetadata columnMetadata)
    {
      Check.Require(!String.IsNullOrEmpty(columnMetadata.PropertyName) &&
                    MetraTech.BusinessEntity.Core.Name.IsValidIdentifier(columnMetadata.PropertyName),
                    String.Format("The specified DbColumnMetadata must have a valid PropertyName"));

      // If columnMetadata.EnumAssemblyQualifiedTypeName is not empty, then it's the type name of an enum property
      // otherwise convert the db type name to a C# type
      string typeName =
        !String.IsNullOrEmpty(columnMetadata.EnumAssemblyQualifiedTypeName) ?
        columnMetadata.EnumAssemblyQualifiedTypeName :
        columnMetadata.CSharpTypeName;
     
      var property = new Property(columnMetadata.PropertyName, typeName);
      property.IsCompound = true;
      property.DbColumnMetadata = columnMetadata;
      property.Label = columnMetadata.Label;
      property.Description = columnMetadata.Description;
      property.ColumnName = columnMetadata.ColumnName;
      property.IsUnique = columnMetadata.IsUnique;

      if (columnMetadata.IsPrimaryKey)
      {
        property.IsLegacyPrimaryKey = true;
        property.IsRequired = true;
      }

      if (!String.IsNullOrEmpty(columnMetadata.EnumAssemblyQualifiedTypeName))
      {
        columnMetadata.EnumAssemblyQualifiedTypeName = property.AssemblyQualifiedTypeName;
      }

      return property;
    }

    #endregion

    #region Public Methods

    /// <summary>
    ///   Get the localized label based on the CurrentUICulture.
    ///   If not found, try the label.
    ///   If not found, use the property name.
    /// </summary>
    /// <returns></returns>
    public string GetLocalizedLabel()
    {
      string localizedLabel = String.Empty;

      LocalizedEntry localizedEntry =
        LocalizedLabels.Find(l => l.Locale == Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName);

      if (localizedEntry == null)
      {
        localizedLabel = String.IsNullOrEmpty(Label) ? Name : Label;
      }
      else
      {
        localizedLabel = localizedEntry.Value;
      }

      return localizedLabel;
    }

    public string GetCodeSnippetForInitializingFieldWithDefaultValueInT4Template()
    {
      Check.Require(!String.IsNullOrEmpty(DefaultValue), "Default value cannot be null", SystemConfig.CallerInfo);
      string codeSnippet = String.Empty;
      
      switch (PropertyType)
      {
        case PropertyType.String:
          {
            codeSnippet = "\"" + DefaultValue + "\"";
            break;
          }
        case PropertyType.Boolean:
          {
            codeSnippet = DefaultValue.ToLower() == "true" ? "true" : "false";
            break;
          }
        case PropertyType.Int32:
        case PropertyType.Int64:
        case PropertyType.Double:
          {
            codeSnippet = DefaultValue;
            break;
          }
        case PropertyType.Decimal:
          {
            codeSnippet = "new Decimal(" + DefaultValue + ")";
            break;
          }
        case PropertyType.DateTime:
          {
            codeSnippet = "DateTime.Parse(\"" + DefaultValue + "\")";
            break;
          }
        case PropertyType.Guid:
          {
            codeSnippet = "new Guid(\"" + DefaultValue + "\")";
            break;
          }
        case PropertyType.Enum:
          {
            string typeName, assemblyName;
            Core.Name.ParseAssemblyQualifiedTypeName(TypeName, out typeName, out assemblyName);
            codeSnippet = typeName + "." + DefaultValueObject.ToString();
            break;
          }
        default:
          {
            throw new MetadataException(String.Format("Invalid Property Type '{0}'", TypeName), SystemConfig.CallerInfo);
          }
      }
      
      Check.Ensure(!String.IsNullOrEmpty(codeSnippet), "'codeSnippet' cannot be null or empty", SystemConfig.CallerInfo);
      return codeSnippet;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as Property;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.FullName == FullName;
    }

    public override int GetHashCode()
    {
      return FullName.GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("Property: Name = {0} : Type = {1}", Name, TypeName);
    }
    #endregion

    #region Validation
    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (Entity == null)
      {
        string message = "Property validation failed. Entity has not been specified";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_MISSING_ENTITY;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(Name))
      {
        string message = "Property validation failed. Name must be specified";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_MISSING_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      else if (Name.StartsWith("@"))
      {
        string message = "Property validation failed. Name cannot start with '@'";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_INVALID_IDENTIFIER;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      else if (!Core.Name.IsValidIdentifier(Name))
      {
        string message = String.Format("Property validation failed. Name '{0}' is not a valid identifier", Name);
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_INVALID_IDENTIFIER;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      else if (!IsValidName(Name))
      {
        string message = String.Format("Property validation failed. Name '{0}' is reserved. Please specify a different name", Name);
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_RESERVED_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(TypeName))
      {
        string message = "Property validation failed. TypeName must be specified";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_MISSING_TYPE_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(ColumnName))
      {
        string message = "Property validation failed. ColumnName must be specified";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_MISSING_COLUMN_NAME;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (PropertyType == PropertyType.String &&
          (Length <=0 || Length > 2000))
      {
        string message = "Property validation failed. String length must be between 1 and 2000";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_INVALID_STRING_LENGTH;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      #region Default Value
      // Confirm that default value can be converted to type specified by TypeName
      if (!String.IsNullOrEmpty(DefaultValue))
      {
        try
        {
          Type type = Type.GetType(AssemblyQualifiedTypeName, true);
          if (type.IsEnum)
          {
            DefaultValueObject = EnumHelper.GetGeneratedEnumByEntry(type, DefaultValue);
          }
          else
          {
            DefaultValueObject = StringUtil.ChangeType(DefaultValue, type);
          }

          if (DefaultValueObject == null)
          {
            string message =
            String.Format("Property validation failed. Cannot convert default value '{0}' to the property type '{1}'",
                          DefaultValue, TypeName);

            var errorData = new PropertyValidationErrorData();
            errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_CANNOT_CONVERT_DEFAULT_VALUE_TO_PROPERTY_TYPE;
            errorData.ErrorType = ErrorType.PropertyValidation;
            errorData.EntityTypeName = Entity.FullName;
            errorData.PropertyName = Name;
            validationErrors.Add(new ErrorObject(message, errorData));
            logger.Error(message);
          }
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Property validation failed. Cannot convert default value '{0}' to the property type '{1}' with exception '{2}'",
                          DefaultValue, TypeName, e.Message);

          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_CANNOT_CONVERT_DEFAULT_VALUE_TO_PROPERTY_TYPE;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));

          logger.Error(message);
        }
      }
      #endregion

      #region Computed Property
      if (!IsComputed && !String.IsNullOrEmpty(ComputationTypeName))
      {
        string message = "Property validation failed. ComputationTypeName must be not be specified for a non computed property.";
        var errorData = new PropertyValidationErrorData();
        errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_COMPUTATION_TYPE_NAME_SPECIFIED_FOR_NON_COMPUTED_PROPERTY;
        errorData.ErrorType = ErrorType.PropertyValidation;
        errorData.EntityTypeName = Entity.FullName;
        errorData.PropertyName = Name;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      
      if (!String.IsNullOrEmpty(ComputationTypeName))
      {
        try
        {
          string typeName, assemblyName;
          Core.Name.ParseAssemblyQualifiedTypeName(ComputationTypeName, out typeName, out assemblyName);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Property validation failed. Cannot parse computation type name '{0}' as an assembly qualified type. Exception: '{1}'",
                          ComputationTypeName, e.Message);

          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_CANNOT_PARSE_COMPUTATION_TYPE_NAME;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));

          logger.Error(message);
        }

        // Check that the type implements ComputedProperty
        try
        {
          List<ErrorObject> errors;
          if (!AppDomainHelper.ValidateComputationTypeName(ComputationTypeName, out errors))
          {
            string message = 
              String.Format("Property validation failed for property '{0}' with errors: '{1}'", 
                            Name, StringUtil.Join(",", errors, e => e.Message));

            var errorData = new PropertyValidationErrorData();
            errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_INVALID_BASE_CLASS_FOR_COMPUTATION_TYPE;
            errorData.ErrorType = ErrorType.PropertyValidation;
            errorData.EntityTypeName = Entity.FullName;
            errorData.PropertyName = Name;
            validationErrors.Add(new ErrorObject(message, errorData));
            logger.Error(message);
          }
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Property validation failed. Cannot create the computation type '{0}'. Exception: '{1}'",
                          ComputationTypeName, e.Message);

          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_CANNOT_CANNOT_CREATE_COMPUTATION_TYPE;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));

          logger.Error(message);
        }
      }
      #endregion

      #region Encrypted
      if (IsEncrypted)
      {
        if (PropertyType != PropertyType.String)
        {
          string message = String.Format("Property validation failed. Encrypted property '{0}' must be a String.", Name);
          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_ENCRYPTED_PROPERTY_CAN_ONLY_BE_STRING;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));
          logger.Error(message);
        }
      }
      #endregion

      #region BusinessKey
      if (IsBusinessKey)
      {
        if (PropertyType != PropertyType.Guid && 
            PropertyType != PropertyType.Int32 &&
            PropertyType != PropertyType.Int64 &&
            PropertyType != PropertyType.String)
        {
          string message = 
            String.Format("Property validation failed. " +
                          "Business key property '{0}' must be a Guid or Int32 or Int64 or String.", Name);

          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_INVALID_BUSINESS_KEY_PROPERTY;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));
          logger.Error(message);
        }
      }
      #endregion

      #region Compound Property
      if (IsCompound)
      {
        if (DbColumnMetadata == null)
        {
          string message =
            String.Format("Property validation failed. " +
                          "DbColumnMetadata must be specified for compound property '{0}'", Name);

          var errorData = new PropertyValidationErrorData();
          errorData.ErrorCode = ErrorCode.PROPERTY_VALIDATION_MISSING_COLUMN_METADATA;
          errorData.ErrorType = ErrorType.PropertyValidation;
          errorData.EntityTypeName = Entity.FullName;
          errorData.PropertyName = Name;
          validationErrors.Add(new ErrorObject(message, errorData));
          logger.Error(message);
        }

        List<ErrorObject> errors;
        if (!DbColumnMetadata.Validate(out errors))
        {
          validationErrors.AddRange(errors);
        }
      }
      #endregion

      return validationErrors.Count > 0 ? false : true;
    }

    public static void ValidatePropertyChanges(Property newProperty, 
                                               Property oldProperty,
                                               out bool canRestoreEntityData)
    {
      canRestoreEntityData = true;

      // Check data type change
      if (!IsDataTypeChangeValid(newProperty.PropertyType, oldProperty.PropertyType))
      {
        throw new MetadataException
          (String.Format("Cannot change property type from '{0}' to '{1}'", 
                         oldProperty.PropertyType, newProperty.PropertyType));
      }

      // Cannot restore data when changing from non-unique to unique 
      if (!oldProperty.IsUnique && newProperty.IsUnique)
      {
        logger.Debug(String.Format("Cannot restore data for entity '{0}' because property '{1}' " +
                                   "has changed from non-unique to unique",
                                   newProperty.Entity.FullName,
                                   newProperty.Name));

        canRestoreEntityData = false;
      }
      // Cannot restore data when changing from non-required to required change, if
      // there is no default value specified
      else if (!oldProperty.IsRequired && newProperty.IsRequired && newProperty.DefaultValueObject == null)
      {
        logger.Debug(String.Format("Cannot restore data for entity '{0}' because property '{1}' " +
                                   "has changed from non-required to required and there is no default value specified",
                                   newProperty.Entity.FullName,
                                   newProperty.Name));

        canRestoreEntityData = false;
      }
    }

    public static bool IsDataTypeChangeValid(PropertyType newPropertyType, PropertyType oldPropertyType)
    {
      // No change
      if (newPropertyType == oldPropertyType)
      {
        return true;
      }

      switch(oldPropertyType)
      {
        case PropertyType.Boolean:
        case PropertyType.DateTime:
        case PropertyType.Guid:
          {
            if (newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          }
        case PropertyType.Decimal:
          {
            if (newPropertyType != PropertyType.Double &&
                newPropertyType != PropertyType.Int32 &&
                newPropertyType != PropertyType.Int64 &&
                newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          }
        case PropertyType.Double:
          {
            if (newPropertyType != PropertyType.Decimal &&
                newPropertyType != PropertyType.Int32 &&
                newPropertyType != PropertyType.Int64 &&
                newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          }
        case PropertyType.Int32:
          {
            if (newPropertyType != PropertyType.Decimal &&
                newPropertyType != PropertyType.Double &&
                newPropertyType != PropertyType.Int64 &&
                newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          }
        case PropertyType.Int64:
          {
            if (newPropertyType != PropertyType.Decimal &&
                newPropertyType != PropertyType.Double &&
                newPropertyType != PropertyType.Int32 &&
                newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          }
        case PropertyType.String:
          {
            return false;
          }
        case PropertyType.Enum:
          {
            if (newPropertyType != PropertyType.Int32 &&
                newPropertyType != PropertyType.Int64 &&
                newPropertyType != PropertyType.String)
            {
              return false;
            }

            break;
          } 
        default :
          {
            break;
          }
      }

      return true;
    }
    #endregion
   
    #region Internal Properties
    /// <summary>
    ///   HbmProperty
    /// </summary>
    internal HbmProperty HbmProperty { get; set; }

    /// <summary>
    ///   Entity that this property belongs to.
    /// </summary>
    internal Entity Entity { get; set; }
    #endregion

    #region Internal Methods
    internal int GetDbEnumValue(int cSharpEnumValue)
    {
      Check.Require(IsEnum, String.Format("Invalid call to 'GetDbEnumValue' because property '{0}' is not an enum type", Name));
      Check.Require(EnumType != null, String.Format("Missing EnumType for enum property '{0}'", Name));

      int dbEnumValue = EnumType.GetDbEnumValue(cSharpEnumValue);
      Check.Ensure(dbEnumValue != Int32.MinValue, 
                   String.Format("Failed to convert C# enum value '{0}' to database enum value for property '{1}' and enum type '{2}'", 
                                 cSharpEnumValue, Name, AssemblyQualifiedTypeName));
      
      return dbEnumValue;
    }

    internal object GetCSharpEnumValue(int dbEnumValue)
    {
      Check.Require(IsEnum, String.Format("Invalid call to 'GetCSharpEnumValue' because property '{0}' is not an enum type", Name));
      Check.Require(EnumType != null, String.Format("Missing EnumType for enum property '{0}'", Name));

      object cSharpEnumValue = EnumType.GetCSharpEnumValue(dbEnumValue);
      Check.Ensure(cSharpEnumValue != null,
                   String.Format("Failed to convert database enum value '{0}' to C# enum value for property '{1}' and enum type '{2}'",
                                 dbEnumValue, Name, AssemblyQualifiedTypeName));

      return cSharpEnumValue;
    }


    internal void InitLocalizationData(List<LocalizedEntry> localizedEntries)
    {
      string labelKey = MetraTech.BusinessEntity.Core.Name.GetPropertyLocalizedLabelKey(Entity.FullName, Name);

      List<LocalizedEntry> labelLocalizedEntries =
        localizedEntries.FindAll(l => l.LocaleKey.ToLower() == labelKey.ToLower());

      LocalizedLabels.Clear();
      labelLocalizedEntries.ForEach(l => LocalizedLabels.Add(l));

      if (IsEnum)
      {
        Check.Require(EnumType != null, 
                      String.Format("EnumType cannot be null for enum property '{0}' of type '{1}'", 
                                    Name, AssemblyQualifiedTypeName));

        EnumType.InitLocalizationData(localizedEntries);
      }
    }

    internal Property Clone()
    {
      //PropertyType = GetPropertyType(typeName, out fullName, out assemblyName);

      //Name = name;
      //TypeName = fullName;
      //AssemblyName = assemblyName;
      //AssemblyQualifiedTypeName = fullName + ", " + AssemblyName;

      var property = new Property(Name, AssemblyQualifiedTypeName, false);
      property.ColumnName = ColumnName;
      property.Label = Label;
      property.Description = Description;
      property.DefaultValue = DefaultValue;
      property.DefaultValueObject = DefaultValueObject;
      property.IsBusinessKey = IsBusinessKey;
      property.IsRequired = IsRequired;
      property.IsUnique = IsUnique;
      property.IsSortable = IsSortable;
      property.IsSearchable = IsSearchable;
      property.IsEncrypted = IsEncrypted;
      property.Order = Order;
      if (EnumType != null)
      {
        property.EnumType = EnumType.Clone();
      }
      property.AssociationEntityName = AssociationEntityName;
      property.IsComputed = IsComputed;
      property.ComputationTypeName = ComputationTypeName;
      property.LocalizedLabels = new List<LocalizedEntry>();
      LocalizedLabels.ForEach(l => property.LocalizedLabels.Add(l));
      property.Length = Length;
      property.HbmProperty = HbmProperty;
      property.RecordHistory = RecordHistory;
      if (IsCompound)
      {
        property.IsCompound = IsCompound;
        property.IsLegacyPrimaryKey = IsLegacyPrimaryKey;
        property.DbColumnMetadata = DbColumnMetadata.Clone();
      }
      property.IsCustomBaseClassProperty = IsCustomBaseClassProperty;
      return property;
    }

    internal bool IsPredefined()
    {
      if (Name == UIDPropertyName)
      {
        return true;
      }

      return false;
    }

    internal bool IsBasePredefined()
    {
      if (Name == VersionPropertyName || 
          Name == CreationDatePropertyName || 
          Name == UpdateDatePropertyName)
      {
        return true;
      }

      return false;
    }
    /// <summary>
    ///    Create a new HbmProperty, populate it using the data in this class and return it
    /// </summary>
    /// <returns></returns>
    internal HbmProperty CreateHbmProperty()
    {
      HbmProperty hbmProperty =
        new HbmProperty()
          {
            name = Name,
            column = ColumnName,
            meta =
              new HbmMeta[]
                {
                  new HbmMeta
                    {
                      attribute = LabelAttribute,
                      Text = new string[] { Label }
                    },
                  new HbmMeta
                    {
                      attribute = DescriptionAttribute,
                      Text = new string[] {Description}
                    },
                  new HbmMeta
                    {
                      attribute = DefaultValueAttribute,
                      Text = new string[] {DefaultValue}
                    },
                  new HbmMeta
                    {
                      attribute = SortableAttribute,
                      Text = new string[] {IsSortable ? "true" : "false" }
                    },
                  new HbmMeta
                    {
                      attribute = SearchableAttribute,
                      Text = new string[] {IsSearchable ? "true" : "false" }
                    },
                  new HbmMeta
                    {
                      attribute = AssociationEntityNameAttribute,
                      Text = new string[] {AssociationEntityName}
                    },
                  new HbmMeta
                    {
                      attribute = EncryptedAttribute,
                      Text = new string[] {IsEncrypted ? "true" : "false" }
                    },
                  new HbmMeta
                    {
                      attribute = ComputedAttribute,
                      Text = new string[] {IsComputed ? "true" : "false" }
                    },
                  new HbmMeta
                    {
                      attribute = ComputationTypeNameAttribute,
                      Text = new string[] {ComputationTypeName}
                    },
                  new HbmMeta
                    {
                      attribute = RecordHistoryAttribute,
                      Text = new string[] {RecordHistory ? "true" : "false" }
                    },
                  new HbmMeta
                    {
                      attribute = IsCustomBaseClassPropertyAttribute,
                      Text = new string[] { IsCustomBaseClassProperty ? "true" : "false"}
                    }
                }
          };
      
      // Set Type
      if (PropertyType == PropertyType.Boolean)
      {
        hbmProperty.type = new HbmType() { name = "TrueFalse" }; 
      }
      else if (PropertyType == PropertyType.DateTime)
      {
        hbmProperty.type = new HbmType() { name = "Timestamp" };
      }
      else
      {
        hbmProperty.type = new HbmType() {name = AssemblyQualifiedTypeName};
      }

      if (PropertyType == PropertyType.Decimal)
      {
        hbmProperty.precision = Constants.METRANET_PRECISION_MAX_STR;
        hbmProperty.scale = Constants.METRANET_SCALE_MAX_STR;
      }

      // Set string lengths
      if (PropertyType == PropertyType.String)
      {
        hbmProperty.length = Length.ToString();
      }

      if (IsBusinessKey)
      {
        // hbmProperty.unique = true;
        hbmProperty.uniquekey = "businesskey"; // creates a multi-column unique constraint - the 'businesskey' string isn't used in the constraint name
        hbmProperty.notnull = true;
        hbmProperty.notnullSpecified = true;
      }
      else if (IsUnique)
      {
        hbmProperty.unique = true;
        hbmProperty.notnull = true;
        hbmProperty.notnullSpecified = true;
      }
      else if (IsRequired)
      {
        hbmProperty.notnull = true;
        hbmProperty.notnullSpecified = true;
      }

      if (IsComputed)
      {
        hbmProperty.insert = false;
        hbmProperty.insertSpecified = true;
        hbmProperty.update = false;
        hbmProperty.updateSpecified = true;
      }

      return hbmProperty;
    }

    internal static List<ErrorObject> GetProperties(ref Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null", SystemConfig.CallerInfo);
      object[] items = null;
      if (entity.EntityType == EntityType.Derived)
      {
        Check.Require(entity.HbmJoinedSubclass != null, 
                      String.Format("entity.HbmSubclass cannot be null for derived entity '{0}'", entity.FullName));
        Check.Require(entity.HbmJoinedSubclass.Items != null,
                      String.Format("entity.HbmSubclass.Items cannot be null for derived entity '{0}'", entity.FullName));
        items = entity.HbmJoinedSubclass.Items;
      }
      else
      {
        Check.Require(entity.HbmClass != null,
                      String.Format("entity.HbmClass cannot be null for derived entity '{0}'", entity.FullName));
        Check.Require(entity.HbmClass.Items != null,
                      String.Format("entity.HbmClass.Items cannot be null for derived entity '{0}'", entity.FullName));
        items = entity.HbmClass.Items;
      }
  
      var errors = new List<ErrorObject>();

      Property property;
      HbmProperty hbmProperty;

      foreach (object item in items)
      {
        // Get BusinessKey properties from HbmComponent
        if (item is HbmComponent)
        {
          var hbmComponent = item as HbmComponent;

          string internalBusinessKeyFlag = hbmComponent.GetMetadata(InternalBusinessKeyAttribute);
          if (!String.IsNullOrEmpty(internalBusinessKeyFlag) && internalBusinessKeyFlag.ToLower() == "true")
          {
            entity.InternalBusinessKey = true;
            continue;
          }
          
          entity.InternalBusinessKey = false;
          
          string businessKeyFlag = hbmComponent.GetMetadata(BusinessKeyAttribute);
          if (!String.IsNullOrEmpty(businessKeyFlag) && businessKeyFlag.ToLower() == "true")
          {
            foreach (object businessKeyItem in hbmComponent.Items)
            {
              hbmProperty = businessKeyItem as HbmProperty;
              Check.Require(hbmProperty != null, "hbmProperty cannot be null", SystemConfig.CallerInfo);

              // If this business key property is a compound property, then it's already been added.
              if (entity.Properties.Exists(p => p.Name == hbmProperty.name)) continue;

              errors.AddRange(GetProperty(hbmProperty, out property));
              if (errors.Count > 0)
              {
                return errors;
              }

              property.IsBusinessKey = true;
              entity.AddProperty(property);
            }
          }

          continue;
        }

        hbmProperty = item as HbmProperty;
        if (hbmProperty == null)
        {
          continue;
        }

        // logger.Debug(String.Format("Retrieving property '{0}' for Nhibernate class '{1}'", hbmProperty.name, hbmClass.name));
        
        errors.AddRange(GetProperty(hbmProperty, out property));
        if (errors.Count > 0)
        {
          return errors;
        }

        if (!property.IsBasePredefined() && !property.IsPredefined())
        {
          entity.AddProperty(property);
        }
      }

      return errors;
    }
    
    internal static List<ErrorObject> GetProperty(HbmProperty hbmProperty, out Property property)
    {
      var errors = new List<ErrorObject>();
      property = null;

      string typeName = String.Empty;

      #region Type Name
      if (!String.IsNullOrEmpty(hbmProperty.type1))
      {
        typeName = hbmProperty.type1;
      }
      else if (hbmProperty.type != null && !String.IsNullOrEmpty(hbmProperty.type.name))
      {
        typeName = hbmProperty.type.name;
      }
      else
      {
        string message = String.Format("Cannot find property type name '{0}'", typeName);
        errors.Add(new ErrorObject(message));
        logger.Error(message);
        return errors;
      }
      #endregion

      property = new Property(hbmProperty.name, typeName, false);
      property.HbmProperty = hbmProperty;
      property.ColumnName = hbmProperty.column;
    
      property.Label = hbmProperty.GetMetadata(LabelAttribute);
      property.Description = hbmProperty.GetMetadata(DescriptionAttribute);
      property.DefaultValue = hbmProperty.GetMetadata(DefaultValueAttribute);
      property.AssociationEntityName = hbmProperty.GetMetadata(AssociationEntityNameAttribute);

      property.IsUnique = hbmProperty.unique;
      property.IsRequired = hbmProperty.notnull;

      string sortable = hbmProperty.GetMetadata(SortableAttribute);
      property.IsSortable = String.IsNullOrEmpty(sortable) ? false : Convert.ToBoolean(sortable);
      string searchable = hbmProperty.GetMetadata(SearchableAttribute);
      property.IsSearchable = String.IsNullOrEmpty(searchable) ? false : Convert.ToBoolean(searchable);
      string encrypted = hbmProperty.GetMetadata(EncryptedAttribute);
      property.IsEncrypted = String.IsNullOrEmpty(encrypted) ? false : Convert.ToBoolean(encrypted);
      string computed = hbmProperty.GetMetadata(ComputedAttribute);
      property.IsComputed = String.IsNullOrEmpty(computed) ? false : Convert.ToBoolean(computed);
      property.ComputationTypeName = hbmProperty.GetMetadata(ComputationTypeNameAttribute);
      string isCustomBaseClassProperty = hbmProperty.GetMetadata(IsCustomBaseClassPropertyAttribute);
      property.IsCustomBaseClassProperty = String.IsNullOrEmpty(isCustomBaseClassProperty) ? false : Convert.ToBoolean(isCustomBaseClassProperty);

      #region Property Type

      if (property.PropertyType == PropertyType.String && !String.IsNullOrEmpty(hbmProperty.length))
      {
        property.Length = Convert.ToInt32(hbmProperty.length);
      }
      #endregion

      if (!String.IsNullOrEmpty(property.DefaultValue))
      {
        Type type = Type.GetType(property.AssemblyQualifiedTypeName, true);
        if (type.IsEnum)
        {
          property.DefaultValueObject = EnumHelper.GetGeneratedEnumByEntry(type, property.DefaultValue);
        }
        else
        {
          property.DefaultValueObject = StringUtil.ChangeType(property.DefaultValue, type);
        }
      }

      return errors;
    }

    internal static void InitializeEnumType(Property property)
    {
      if (!property.IsEnum)
      {
        return;
      }

      string enumSpace;
      string enumName;
      EnumUtil.GetEnumSpaceAndName(property.AssemblyQualifiedTypeName, out enumSpace, out enumName);
      property.EnumType = new EnumType()
      {
        AssemblyName = property.AssemblyName,
        Name = enumName,
        Namespace = enumSpace,
        FQN = enumSpace + "/" + enumName
      };

      Type enumType = Type.GetType(property.AssemblyQualifiedTypeName, true);
      foreach (object enumValue in Enum.GetValues(enumType))
      {
        var enumEntry = new EnumEntry();
        enumEntry.CSharpValue = enumValue;
        enumEntry.Name = EnumHelper.GetEnumEntryName(enumValue);
        enumEntry.FQN = property.EnumType.FQN + "/" + enumEntry.Name;
        property.EnumType.Entries.Add(enumEntry);
      }
    }

    internal static PropertyType GetPropertyType(string typeName)
    {
      string fullName, assemblyName;
      return GetPropertyType(typeName, out fullName, out assemblyName);
    }

    internal static PropertyType GetPropertyType(string typeName, out string fullName, out string assemblyName)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "Argument 'typeName' cannot be null or empty", SystemConfig.CallerInfo);
      
      PropertyType propertyType = PropertyType.Int32;
      assemblyName = null;
      fullName = null;

      if (typeName.ToLower() == "binary")
      {
        typeName = "System.Byte[]";
      }

      var assemblyQualifiedTypeName = TypeNameParser.Parse(typeName);

      if (!String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly) &&
           assemblyQualifiedTypeName.Assembly.ToLower().Contains("mscorlib"))
      {
        typeName = assemblyQualifiedTypeName.Type;
      }

      IType type = TypeFactory.Basic(assemblyQualifiedTypeName.Type);
      if (type != null)
      {
        assemblyName = type.ReturnedClass.Assembly.GetName().Name;
        fullName = type.ReturnedClass.FullName;

        #region Return Basic Type
        switch (type.ReturnedClass.FullName)
        {
          case BooleanTypeName:
            {
              propertyType = PropertyType.Boolean;
              break;
            }
          case DateTimeTypeName:
            {
              propertyType = PropertyType.DateTime;
              break;
            }
          case DecimalTypeName:
            {
              propertyType = PropertyType.Decimal;
              break;
            }
          case DoubleTypeName:
            {
              propertyType = PropertyType.Double;
              break;
            }
          case GuidTypeName:
            {
              propertyType = PropertyType.Guid;
              break;
            }
          case Int32TypeName:
            {
              propertyType = PropertyType.Int32;
              break;
            }
          case Int64TypeName:
            {
              propertyType = PropertyType.Int64;
              break;
            }
          case StringTypeName:
            {
              propertyType = PropertyType.String;
              break;
            }
          case BinaryTypeName:
            {
              propertyType = PropertyType.Binary;
              break;
            }
          default:
            {
              string message = String.Format("Cannot interpret property type name '{0}'", typeName);
              throw new InvalidPropertyTypeException(message, null, SystemConfig.CallerInfo);
            }
        }

        return propertyType;
        #endregion
      }
     
      type = TypeFactory.HeuristicType(typeName);
      if (type == null)
      {
        string message = String.Format("Cannot interpret property type name '{0}'", typeName);
        throw new MetadataException(message, SystemConfig.CallerInfo);
      }

      assemblyName = type.ReturnedClass.Assembly.GetName().Name;
      fullName = type.ReturnedClass.FullName;

      if (type is PersistentEnumType)
      {
        propertyType = PropertyType.Enum;
      }
      else
      {
        string message = String.Format("Cannot interpret property type name '{0}'", typeName);
        throw new MetadataException(message, SystemConfig.CallerInfo);
      }

      return propertyType;
    }

    internal bool HasDefaultValue()
    {
      if (DefaultValueObject != null || !String.IsNullOrEmpty(DefaultValue))
      {
        return true;
      }

      return false;
    }

    internal string GetDefaultValueDatabaseLiteral(bool isOracle)
    {
      string defaultValue = String.Empty;

      if (DefaultValueObject == null)
      {
        return defaultValue;
      }

      switch(PropertyType)
      {
        case PropertyType.Boolean:
          {
            var value = (Boolean)DefaultValueObject;
            defaultValue = value ? "'T'" : "'F'";
            break;
          }
        case PropertyType.DateTime:
          {
              if (isOracle)
              {
                  // For Oracle, we say the default value in string format is something like:
                  // to_timestamp('20100316 16.04.06.444', 'YYYYMMDD HH24.MI.SS.FF3')
                  // We escape the single quotes using ''.
                  defaultValue = string.Format("to_timestamp(''{0}'', ''YYYYMMDD HH24.MI.SS.FF3'')",
                                               ((DateTime)DefaultValueObject).ToString("yyyyMMdd HH.mm.ss.fff"));
              }
              else
              {
                  defaultValue = "'" + ((DateTime) DefaultValueObject).ToString("yyyyMMdd HH:mm:ss.fff") + "'";
              }

              break;
          }
        case PropertyType.Decimal:
        case PropertyType.Double:
        case PropertyType.Int32:
        case PropertyType.Int64:
          {
            defaultValue = DefaultValueObject.ToString();
            break;
          }
        case PropertyType.Guid:
        case PropertyType.String:
          {
            defaultValue = "'" + DefaultValueObject + "'";
            break;
          }
        case PropertyType.Enum:
          {
            defaultValue = ((int)DefaultValueObject).ToString();
            break;
          }
        default:
          {
            break;
          }
      }

      return defaultValue;
    }

    #endregion

    #region Private Methods
    private void Initialize(string name, string typeName, bool checkPropertyName = true)
    {
      Check.Require(!String.IsNullOrEmpty(name), "name cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(Core.Name.IsValidIdentifier(name),
                    "name is not a valid identifier",
                    SystemConfig.CallerInfo);

      if (checkPropertyName)
      {
        Check.Require(IsValidName(name),
                      String.Format("'{0}' cannot be used as a property name because it is reserved", name));
      }

      string assemblyName;
      string fullName;

      PropertyType = GetPropertyType(typeName, out fullName, out assemblyName);

      Name = name;
      TypeName = fullName;
      AssemblyName = assemblyName;
      AssemblyQualifiedTypeName = fullName + ", " + AssemblyName;

      Label = String.Empty;
      Description = String.Empty;
      DefaultValue = String.Empty;
      IsSortable = true;
      RecordHistory = true;
      LocalizedLabels = new List<LocalizedEntry>();

      // Number of characters
      Length = 255;

      // Initialize enums
      InitializeEnumType(this);
    }

    private bool IsValidName(string name)
    {
      Check.Require(!String.IsNullOrEmpty(name), "name cannot be null or empty");
      string lowerName = name.ToLower();
      if (lowerName == "id" ||
          lowerName == "businesskey" ||
          lowerName == "internalkey" ||
          lowerName == "parent" ||
          lowerName == "children" ||
          lowerName == "creationdate" ||
          lowerName == "updatedate" ||
          lowerName == "fullname" ||
          lowerName == "_version" ||
          lowerName == "uid")
      {
        return false;
      }

      return true;
    }

    internal static string ConvertDbTypeNameToCSharpTypeName(DbColumnMetadata columnMetadata)
    {
      return ConvertDbTypeNameToCSharpTypeName(columnMetadata.DbTypeName,
                                               columnMetadata.MaxLength,
                                               columnMetadata.Precision,
                                               columnMetadata.Scale);
    }

    /// <summary>
    ///   Convert the specified database type (NVARCHAR, DATETIME etc) to the corresponding 
    ///   C# type name (string, DateTime etc)
    /// </summary>
    /// <param name="columnMetadata"></param>
    /// <returns></returns>
    internal static string ConvertDbTypeNameToCSharpTypeName(string dbTypeName,
                                                             int maxLength,
                                                             int precision,
                                                             int scale)
    {
      Check.Require(!String.IsNullOrEmpty(dbTypeName), "dbTypeName cannot be null");
      string typeName = String.Empty;

      switch (dbTypeName.ToUpper())
      {
        case "CHAR":
        case "VARCHAR":
        case "NVARCHAR":
        case "VARCHAR2":  // Oracle
        case "NVARCHAR2": // Oracle 
        case "NCHAR":     // Oracle
        case "CLOB":      // Oracle
        case "NCLOB":     // Oracle
          {
            typeName = "String";
            break;
          }
        case "INT":
        case "SMALLINT":
        case "TINYINT":
        case "BIT":
        case "INTEGER": // Oracle
          {
            typeName = "Int32";
            break;
          }
        case "BIGINT":
          {
            typeName = "Int64";
            break;
          }
        case "NUMERIC":
        case "DECIMAL":
          {
            typeName = "Decimal";
            break;
          }
        case "FLOAT":
        case "DOUBLE PRECISION": // Oracle
          {
            typeName = "Double";
            break;
          }
        case "UNIQUEIDENTIFIER":
          {
            typeName = "Guid";
            break;
          }
        case "RAW": // Oracle
          {
            if (maxLength == 16)
            {
              typeName = "Guid";
            }
            break;
          }
        case "DATETIME":
        case "DATE":          // Oracle
        case "TIMESTAMP(6)":  // Oracle
        case "TIMESTAMP(4)":  // Oracle
          {
            typeName = "DateTime";
            break;
          }
        case "NUMBER":  // Oracle
          {
            if (precision == 10 && scale == 0)
            {
              typeName = "Int32";
            }
            else if (precision == 20 && scale == 0)
            {
              typeName = "Int64";
            }
            else if (precision == 19 && scale == 5)
            {
              typeName = "Decimal";
            }
            else
            {
              typeName = "Double";
            }
            break;
          }

        default:
          {
            break;
          }
      }

      return typeName;
    }
    #endregion

    #region Data
    internal static readonly string DescriptionAttribute = "description";
    internal static readonly string DefaultValueAttribute = "defaultvalue";
    internal static readonly string LabelAttribute = "label";
    internal static readonly string EncryptedAttribute = "encrypted";
    internal static readonly string BusinessKeyAttribute = "business-key";
    internal static readonly string InternalBusinessKeyAttribute = "internal-business-key";
    internal static readonly string UniqueAttribute = "unique";
    internal static readonly string RequiredAttribute = "required";
    internal static readonly string SortableAttribute = "sortable";
    internal static readonly string SearchableAttribute = "searchable";
    internal static readonly string AssociationEntityNameAttribute = "association-entity";
    internal static readonly string ComputedAttribute = "computed";
    internal static readonly string ComputationTypeNameAttribute = "computation-type-name";
    internal static readonly string RecordHistoryAttribute = "record-history";
    internal static readonly string IsCustomBaseClassPropertyAttribute = "is-custom-base-class-property";

    internal const string BooleanTypeName = "System.Boolean";
    internal const string DateTimeTypeName = "System.DateTime";
    internal const string DecimalTypeName = "System.Decimal";
    internal const string DoubleTypeName = "System.Double";
    internal const string GuidTypeName = "System.Guid";
    internal const string Int32TypeName = "System.Int32";
    internal const string Int64TypeName = "System.Int64";
    internal const string StringTypeName = "System.String";
    internal const string EnumTypeName = "System.Enum";
    internal const string BinaryTypeName = "System.Byte[]";

    internal static readonly string ExtensionNamePropertyName = "ExtensionName";
    internal static readonly string EntityGroupNamePropertyName = "EntityGroupName";
    internal static readonly string EntityFullNamePropertyName = "EntityFullName";
    internal static readonly string EntityNamePropertyName = "EntityName";
    public static readonly string VersionPropertyName = "_Version";
    public static readonly string CreationDatePropertyName = "CreationDate";
    public static readonly string UpdateDatePropertyName = "UpdateDate";
    public static readonly string UIDPropertyName = "UID";

    internal static readonly string ExtensionNamePropertyColumnName = "c_extension_name";
    internal static readonly string EntityGroupPropertyColumnName = "c_entity_group_name";
    internal static readonly string EntityNamePropertyColumnName = "c_entity_name";
    internal static readonly string VersionPropertyColumnName = "c__version";

    internal static readonly ILog logger = LogManager.GetLogger("Property");

    internal static readonly string[] CSharpKeywords =
      new []
        {
          "abstract",
          "as",
          "base",
          "bool",
          "break",
          "byte",
          "case",
          "catch",
          "char",
          "checked",
          "class",
          "const",
          "continue",
          "decimal",
          "default",
          "delegate",
          "do",
          "double",
          "else",
          "enum",
          "even",
          "explicit",
          "extern",
          "false",
          "finally",
          "fixed",
          "float",
          "for",
          "foreach",
          "goto",
          "if",
          "implicit",
          "in",
          "int",
          "interface",
          "internal",
          "is",
          "lock",
          "long",
          "namespace",
          "new",
          "null",
          "object",
          "operator",
          "out",
          "override",
          "params",
          "private",
          "protected",
          "public",
          "readonly",
          "ref",
          "return",
          "sbyte",
          "sealed",
          "short",
          "sizeof",
          "stackalloc",
          "static",
          "string",
          "String",
          "struct",
          "switch",
          "this",
          "throw",
          "true",
          "try",
          "typeof",
          "uint",
          "ulong",
          "unchecked",
          "unsafe",
          "ushort",
          "using",
          "virtual",
          "volatile",
          "void",
          "while"
        };
    #endregion
  }

  internal static class HbmPropertyExtension
  {
    /// <summary>
    ///    Extension method must
    ///    (1) Be in a static class.
    ///    (2) Have atleast one parameter prefixed with 'this'. Cannot be out/ref.
    /// </summary>
    /// <param name="hbmProperty"></param>
    /// <param name="attributeName"></param>
    /// <returns></returns>
    internal static string GetMetadata(this HbmProperty hbmProperty, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmProperty.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmProperty.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text != null && hbmMeta.Text.Length > 0 && !String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          attributeValue = hbmMeta.GetText();
        }
      
        break;
      }

      return attributeValue;
    }
  }

  internal static class HbmComponentExtension
  {
    /// <summary>
    ///    Extension method must
    ///    (1) Be in a static class.
    ///    (2) Have atleast one parameter prefixed with 'this'. Cannot be out/ref.
    /// </summary>
    /// <param name="hbmComponent"></param>
    /// <param name="attributeName"></param>
    /// <returns></returns>
    internal static string GetMetadata(this HbmComponent hbmComponent, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmComponent.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmComponent.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text != null && hbmMeta.Text.Length > 0 && !String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          attributeValue = hbmMeta.GetText();
        }

        break;
      }

      return attributeValue;
    }
  }
}
