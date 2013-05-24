using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.IO;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;
using Core.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using NHibernate.Cfg.MappingSchema;
using NHibernate.Util;

using MetraTech.DomainModel.Enums;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Config;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Persistence;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [KnownType(typeof(Property))]
  [KnownType(typeof(EnumType))]
  [KnownType(typeof(RelationshipEntity))]
  [KnownType(typeof(SelfRelationshipEntity))]
  [KnownType(typeof(HistoryEntity))]
  [KnownType(typeof(CompoundEntity))]
  [KnownType(typeof(LocalizedEntry))]
  [Serializable]
  public class Entity : Metadata
  {
    #region Public Static Methods
    public static string GetTableName(string entityFullName)
    {
      return MetadataRepository.Instance.GetTableName(entityFullName);
    }

    #endregion

    #region Public Methods

    public Entity()
    {
      Initialize();
    }

    /// <summary>
    ///    Create the entity based on the fullName.
    /// </summary>
    /// <param name="fullName"></param>
    public Entity(string fullName)
    {
      SetTypeData(fullName);
    }

    public virtual Entity ReadHbm(string hbmFile)
    {
      Entity entity = null;

      HbmMapping hbmMapping = GetHbmMapping(hbmFile);
      EntityType entityType = hbmMapping.GetEntityType();
      Check.Require(entityType != EntityType.None,
                    String.Format("Cannot determine the entity type from hbm file '{0}'", hbmFile));

      switch (entityType)
      {
        case EntityType.Entity:
        case EntityType.History:
        case EntityType.Relationship:
        case EntityType.SelfRelationship:
        case EntityType.Compound:
          {
            List<ErrorObject> errors = GetEntity(hbmFile, out entity);
            if (errors.Count > 0)
            {
              throw new MetadataException(String.Format("Cannot parse hbm file '{0}'", hbmFile), errors);
            }
            break;
          }
        case EntityType.Derived:
          {

            break;
          }
        default:
          {
            throw new MetadataException(String.Format("Cannot handle entity type '{0}'", entityType));
          }
      }

      Check.Ensure(entity != null, String.Format("Cannot create an entity from hbm file '{0}'", hbmFile));
      return entity;
    }

    public bool HasProperty(string propertyName)
    {
      return Properties.Exists(p => p.Name == propertyName);
    }

    public void AddProperty(Property property)
    {
      property.Entity = this;
      property.Order = Properties.Count + 1;
      if (String.IsNullOrEmpty(property.ColumnName))
      {
        property.ColumnName = ColumnNameGenerator.CreateColumnName(property, this);
      }

      if (!Properties.Contains(property))
      {
        Properties.Add(property);
      }
    }

    public void AddCompoundProperty(DbColumnMetadata columnMetadata)
    {
      Check.Require(EntityType == EntityType.Compound, "Operation valid for only a compound entity");

      Property property = Property.CreateProperty(columnMetadata);
      AddProperty(property);
    }

    public void RemoveProperty(Property property)
    {
      Properties.Remove(property);
    }

    public virtual string GetBackupTableName()
    {
      Check.Require(!String.IsNullOrEmpty(TableName), "Cannot get backup table name because TableName is null or empty");
      string backupTableName = TableName + "_b";
      if (EntityType == EntityType.History)
      {
        if (backupTableName.Length > 30)
        {
          string uniqueifier = Math.Abs((Guid.NewGuid().ToString()).GetHashCode()).ToString();
          if (uniqueifier.Length > 6)
          {
            uniqueifier = uniqueifier.Substring(0, 6);
          }

          backupTableName = backupTableName.Substring(0, 20) + uniqueifier + "_h_b";
        }
      }

      return backupTableName;
    }

    public virtual List<Property> GetDatabaseProperties()
    {
      var dbProperties = new List<Property>();

      dbProperties.AddRange(GetStandardProperties());
      dbProperties.AddRange(Properties.Where(property => !property.IsCompound || property.IsLegacyPrimaryKey));

      dbProperties.AddRange(GetForeignKeyProperties());

      return dbProperties;
    }

    public virtual List<Property> GetForeignKeyProperties(bool useIdPropertyName = false)
    {
      var foreignKeyProperties = new List<Property>();

      foreignKeyProperties.AddRange
        (
          from relationship in Relationships
          where !relationship.RelationshipEntity.HasJoinTable &&
                (
                  relationship.End1.Multiplicity == Multiplicity.Many ||
                  (
                    relationship.End1.Multiplicity == Multiplicity.One &&
                    relationship.RelationshipEntity.TargetEntityName == relationship.End1.EntityTypeName &&
                    relationship.RelationshipEntity.RelationshipType == RelationshipType.OneToOne
                  )
                )
          select new Property(this,
                              useIdPropertyName ? relationship.End1.PropertyName + "Id" : relationship.End1.PropertyName,
                              "Guid",
                              false) { ColumnName = relationship.End2.ColumnName }
        );

      return foreignKeyProperties;
    }

    public Property GetIdProperty()
    {
      var idProperty = new Property();

      string fullName;
      string assemblyName;
      idProperty.PropertyType = Property.GetPropertyType("Guid", out fullName, out assemblyName);

      idProperty.TypeName = fullName;
      idProperty.AssemblyName = assemblyName;
      idProperty.AssemblyQualifiedTypeName = fullName + ", " + assemblyName;

      idProperty.Name = "Id";
      idProperty.Entity = this;
      idProperty.ColumnName = GetIdColumnName();


      idProperty.IsUnique = true;
      idProperty.IsRequired = true;
      idProperty.Length = 255;

      return idProperty;
    }

    public virtual List<Property> GetStandardProperties()
    {
      var standardProperties = new List<Property>();

      standardProperties.Add(GetIdProperty());

      if (InternalBusinessKey)
      {
        var internalKeyProperty =
        new Property(this, "InternalKey", "Guid", false)
        {
          ColumnName = "c_internal_key",
          IsUnique = true,
          IsRequired = true
        };

        standardProperties.Add(internalKeyProperty);
      }

      if (EntityType == EntityType.Derived)
      {
        // Skip the version property
        standardProperties.AddRange(PreDefinedProperties.Where(property => property.Name != Property.VersionPropertyName));
      }
      else
      {
        standardProperties.AddRange(PreDefinedProperties);
      }


      return standardProperties;
    }

    public RelationshipEntity GetRelationshipEntity(string relatedTypeName)
    {
      RelationshipEntity relationshipEntity = null;

      Relationship relationship =
        Relationships.SingleOrDefault(rel => rel.End2.EntityTypeName == relatedTypeName);

      if (relationship != null)
      {
        relationshipEntity = relationship.RelationshipEntity;
        Check.Ensure(relationshipEntity != null,
                     String.Format("Cannot find RelationshipEntity for relationship between '{0}' and '{1}'",
                                   FullName, relatedTypeName),
                     SystemConfig.CallerInfo);
      }

      return relationshipEntity;
    }

    public bool HasRelationshipWith(string entityName)
    {
      bool hasRelationship = false;

      foreach (Relationship relationship in Relationships)
      {
        if (relationship.End2.EntityTypeName == entityName)
        {
          hasRelationship = true;
          break;
        }
      }

      return hasRelationship;
    }

    public EntityInstance GetEntityInstance()
    {
      var entityInstance = new EntityInstance();
      entityInstance.EntityGroupName = EntityGroupName;
      entityInstance.ExtensionName = ExtensionName;
      entityInstance.EntityFullName = FullName;
      entityInstance.EntityName = ClassName;
      entityInstance.AssemblyQualifiedTypeName = AssemblyQualifiedName;

      foreach (Property property in Properties)
      {
        var propertyInstance =
          new PropertyInstance(property.Name,
                               property.AssemblyQualifiedTypeName,
                               property.IsBusinessKey);

        if (!String.IsNullOrEmpty(property.DefaultValue))
        {
          propertyInstance.Value = property.DefaultValueObject;
        }

        propertyInstance.IsCompound = property.IsCompound;
        propertyInstance.IsLegacyPrimaryKey = property.IsLegacyPrimaryKey;

        entityInstance.Properties.Add(propertyInstance);
      }

      foreach (Property property in PreDefinedProperties)
      {
        var propertyInstance =
          new PropertyInstance(property.Name,
                               property.AssemblyQualifiedTypeName,
                               property.IsBusinessKey);

        entityInstance.Properties.Add(propertyInstance);
      }

      if (InternalBusinessKey)
      {
        var propertyInstance = new PropertyInstance("InternalKey", "Guid", true);
        entityInstance.Properties.Add(propertyInstance);
      }

      return entityInstance;
    }

    public List<IMetranetEntity> GetAssociatedMetranetEntities()
    {
      List<IMetranetEntity> metranetEntities = new List<IMetranetEntity>();

      MetaAttribute metaAttribute;
      MetaAttributes.TryGetValue(MetraNetEntityAssociationAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        foreach (string value in metaAttribute.Values)
        {
          string[] assemblyNameAndMultiplicity = value.Split(new string[] { "::" }, StringSplitOptions.RemoveEmptyEntries);
          Check.Require(assemblyNameAndMultiplicity.Length == 2,
                       "Expected two entries after splitting metranet entity association attribute on '::'",
                       SystemConfig.CallerInfo);

          var metranetEntity =
            Activator.CreateInstance(Type.GetType(assemblyNameAndMultiplicity[0])) as IMetranetEntity;

          Check.Require(metranetEntity != null,
                        String.Format("Cannot create metranet entity '{0}'", assemblyNameAndMultiplicity[0]),
                        SystemConfig.CallerInfo);

          metranetEntity.MetraNetEntityConfig =
            BusinessEntityConfig.Instance.GetMetranetEntityConfig(assemblyNameAndMultiplicity[0]);

          Check.Require(metranetEntity.MetraNetEntityConfig != null,
                        String.Format("Cannot find metranet entity config for '{0}'", assemblyNameAndMultiplicity[0]));

          metranetEntities.Add(metranetEntity);
        }
      }

      return metranetEntities;
    }

    public IList<Association> GetAssociations()
    {
      IList<Association> associations = new List<Association>();
      foreach (Relationship relationship in Relationships)
      {
        if (relationship.Target.Multiplicity == Multiplicity.One)
        {
          Association association = new Association();
          association.EntityInstance = relationship.Target.Entity.GetEntityInstance();
          association.EntityTypeName = relationship.Target.EntityTypeName;
          association.PropertyName = relationship.Source.PropertyName;
          association.OtherPropertyName = relationship.Target.PropertyName;
          associations.Add(association);
        }
      }
      return associations;
    }

    public IList<CollectionAssociation> GetCollectionAssociations()
    {
      IList<CollectionAssociation> associations = new List<CollectionAssociation>();
      foreach (Relationship relationship in Relationships)
      {
        if (relationship.Target.Multiplicity == Multiplicity.Many)
        {
          CollectionAssociation association = new CollectionAssociation();
          association.EntityTypeName = relationship.Target.EntityTypeName;
          association.PropertyName = relationship.Source.PropertyName;
          association.OtherPropertyName = relationship.Target.PropertyName;
          associations.Add(association);
        }
      }
      return associations;
    }

    /// <summary>
    ///   Return true if this entity has the specified relationship 
    /// </summary>
    /// <param name="relationship"></param>
    /// <returns></returns>
    public bool HasRelationship(Relationship relationship)
    {
      if (Relationships.Count == 0)
      {
        return false;
      }

      Relationship existingRelationship =
        Relationships.Single(rel => rel.Source.EntityTypeName == relationship.Source.EntityTypeName &&
                                    rel.Target.EntityTypeName == relationship.Target.EntityTypeName);

      if (existingRelationship != null)
      {
        return true;
      }

      return false;
    }

    public bool HasRelationship(string relationshipName)
    {
      return Relationships.Exists(r => r.RelationshipEntity.RelationshipName == relationshipName);
    }

    /// <summary>
    ///   Get the localized label based on the CurrentUICulture.
    ///   If not found, try the label.
    ///   If not found, use the class name.
    /// </summary>
    /// <returns></returns>
    public string GetLocalizedLabel()
    {
      string localizedLabel = String.Empty;

      LocalizedEntry localizedEntry =
        LocalizedLabels.Find(l => l.Locale == Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName);

      if (localizedEntry == null)
      {
        localizedLabel = String.IsNullOrEmpty(Label) ? ClassName : Label;
      }
      else
      {
        localizedLabel = localizedEntry.Value;
      }

      return localizedLabel;
    }

    public string GetCompoundTableName()
    {
      Check.Require(EntityType == EntityType.Compound, "Operation valid for only a compound entity");
      var compoundEntity = this as CompoundEntity;
      Check.Require(compoundEntity != null, String.Format("Cannot convert '{0}' to a compound entity", FullName));
      return compoundEntity.LegacyTableName;
    }

    public Property GetPropertyByColumnName(string columnName)
    {
      Property property = Properties.Find(p => p.ColumnName.ToLower() == columnName.ToLower());
      return property;
    }

    /// <summary>
    ///   Return true if the specified entityName is in the same assembly as this entity
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public bool IsInSameAssembly(string entityName)
    {
      return Name.GetEntityAssemblyName(FullName).ToLower().Equals(Name.GetEntityAssemblyName(entityName).ToLower());
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as Entity;

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
      return String.Format("EntityName: '{0}', EntityType: '{1}'", FullName, EntityType);
    }

    #endregion

    #region Public Properties
    /// <summary>
    ///    Name of the C# class that implements this entity
    /// </summary>
    [DataMember]
    public string ClassName { get; set; }

    /// <summary>
    ///    The namespace for this entity
    /// </summary>
    [DataMember]
    public string Namespace { get; set; }

    /// <summary>
    /// </summary>
    public EntityGroupData EntityGroupData { get; set; }

    /// <summary>
    ///    The extension for this entity
    /// </summary>
    [DataMember]
    public string ExtensionName { get; set; }

    /// <summary>
    ///    The entity group for this entity
    /// </summary>
    [DataMember]
    public string EntityGroupName { get; set; }

    /// <summary>
    ///    Plural name for the class. 
    /// </summary>
    [DataMember]
    public string PluralName { get; set; }

    /// <summary>
    ///    Database for the class. 
    /// </summary>
    [DataMember]
    public string DatabaseName { get; set; }

    /// <summary>
    ///    If true, maintains history data. 
    /// </summary>
    [DataMember]
    public bool RecordHistory { get; set; }

    /// <summary>
    ///   
    /// </summary>
    public EntityType EntityType { get; set; }

    /// <summary>
    ///    Category for this entity
    /// </summary>
    [DataMember]
    public Category Category { get; set; }

    /// <summary>
    ///    The label for this entity 
    /// </summary>
    [DataMember]
    public string Label { get; set; }

    /// <summary>
    ///    The table name for this entity 
    /// </summary>
    [DataMember]
    public string TableName { get; set; }

    /// <summary>
    ///    The description of the entity.  
    /// </summary>
    [DataMember]
    public string Description { get; set; }

    /// <summary>
    ///    The namespace qualified name for this entity 
    /// </summary>
    [DataMember]
    public string FullName { get; set; }

    /// <summary>
    ///    The assembly name for this entity 
    /// </summary>
    public string AssemblyName { get; set; }

    /// <summary>
    ///    The parent entity for this entity - valid if this is derived
    /// </summary>
    public string ParentEntityName { get; set; }

    /// <summary>
    ///    A custom (hand coded) base class. The base class is not an entity. It does not have a database table associated with it.
    /// </summary>
    public string CustomBaseClassName { get; set; }

    /// <summary>
    ///    The root entity for this entity - valid if this is derived
    /// </summary>
    public string RootEntityName { get; set; }

    /// <summary>
    ///    The assembly qualified name for this entity 
    /// </summary>
    public string AssemblyQualifiedName { get; set; }

    public Property this[string propertyName]
    {
      get
      {
        List<Property> databaseProperties = GetDatabaseProperties();
        return databaseProperties.Where(p => p.Name == propertyName).SingleOrDefault();
      }
    }

    /// <summary>
    /// 
    /// </summary>
    [DataMember]
    public virtual List<Property> PreDefinedProperties { get; set; }

    /// <summary>
    ///    Properties for this entity
    /// </summary>
    [DataMember]
    public virtual List<Property> Properties { get; protected set; }

    /// <summary>
    ///    Relationships for this entity
    /// </summary>
    [DataMember]
    public virtual List<Relationship> Relationships { get; set; }

    /// <summary>
    ///    If HasSelfRelationship is true and synchronization has happened, then this should be non-null
    /// </summary>
    [DataMember]
    public virtual SelfRelationshipEntity SelfRelationshipEntity { get; set; }

    /// <summary>
    ///    If RecordHistory is true and synchronization has happened, then this should be non-null
    /// </summary>
    [DataMember]
    public virtual HistoryEntity HistoryEntity { get; set; }

    /// <summary>
    ///    Return true if this entity has not been saved.
    /// </summary>
    [DataMember]
    public virtual bool IsPersisted { get; set; }

    public virtual Dictionary<string, MetaAttribute> MetaAttributes { get; set; }

    /// <summary>
    ///   If this is true, then no BusinessKey property has been specified.
    ///   An internal business key (of type Guid) will be used.
    /// </summary>
    [DataMember]
    public virtual bool InternalBusinessKey { get; set; }

    /// <summary>
    ///   Map the CultureInfo.TwoLetterISOLanguageName	to the localized label
    /// </summary>
    [DataMember]
    public virtual List<LocalizedEntry> LocalizedLabels { get; set; }

    /// <summary>
    ///   This must be removed after the Self-Relationship functionality is removed from ICE.
    /// </summary>
    public bool HasSelfRelationship { get; set; }
    #endregion

    #region Internal Properties
    internal HbmClass HbmClass { get; set; }
    internal HbmMapping HbmMapping { get; set; }
    internal HbmJoinedSubclass HbmJoinedSubclass { get; set; }
    internal EntitySyncData EntitySyncData { get; set; }
    internal virtual string BusinessKeyPropertyName
    {
      get { return Name.GetBusinessKeyPropertyName(FullName); }
    }

    internal virtual string BusinessKeyFieldName
    {
      get { return Name.GetBusinessKeyFieldName(FullName); }
    }

    internal virtual bool HasForeignKeyProperties
    {
      get { return GetForeignKeyProperties().Count > 0; }
    }

    internal List<HbmDatabaseObject> HbmDatabaseObjects { get; set; }
    #endregion

    #region Private Properties

    #endregion

    #region Validation
    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(ClassName))
      {
        string message = "ClassName must be specified.";
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_CLASS_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      else if (!Name.IsValidIdentifier(ClassName))
      {
        string message = String.Format("ClassName '{0}' is not a valid identifier", ClassName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_INVALID_CLASS_IDENTIFIER;
        errorData.ErrorType = ErrorType.EntityValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(Namespace))
      {
        string message = String.Format("Entity '{0}' does not have a namespace", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_NAMESPACE;
        errorData.ErrorType = ErrorType.EntityValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }
      else
      {
        string[] nameSpaceParts = Namespace.Split(new char[] { '.' });
        foreach (string nameSpacePart in nameSpaceParts)
        {
          if (!Name.IsValidIdentifier(nameSpacePart))
          {
            string message =
              String.Format(
                "Namespace part '{0}' in namespace '{1}' is not a valid identifier for entity '{2}'", nameSpacePart, Namespace, FullName);

            var errorData = new EntityValidationErrorData();
            errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_INVALID_NAMESPACE;
            errorData.ErrorType = ErrorType.EntityValidation;
            validationErrors.Add(new ErrorObject(message, errorData));
            logger.Error(message);
          }
        }
      }

      if (String.IsNullOrEmpty(AssemblyName))
      {
        string message = String.Format("Entity '{0}' does not have an assembly name", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_ASSEMBLY_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(PluralName))
      {
        string message = String.Format("Entity '{0}' does not have a plural name", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_PLURAL_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      if (String.IsNullOrEmpty(DatabaseName))
      {
        string message = String.Format("Entity '{0}' does not have a database name", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_DATABASE_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      // Confirm that the entity name is unique
      if (!IsPersisted && !MetadataRepository.Instance.IsEntityNameUnique(FullName))
      {
        string message = String.Format("ClassName '{0}' is not unique", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_DUPLICATE_CLASS_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      // Confirm that a table name has been created
      if (String.IsNullOrEmpty(TableName))
      {
        string message = String.Format("Entity '{0}' does not have a table name", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_TABLE_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      // If this is a SubClass, ParentEntityName must be non-empty
      if (EntityType == EntityType.Derived && String.IsNullOrEmpty(ParentEntityName))
      {
        string message = String.Format("Entity '{0}' is marked as SubClass but is missing the name of the parent entity", FullName);
        var errorData = new EntityValidationErrorData();
        errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_MISSING_PARENT_ENTITY_NAME;
        errorData.ErrorType = ErrorType.EntityValidation;
        errorData.EntityTypeName = FullName;
        validationErrors.Add(new ErrorObject(message, errorData));
        logger.Error(message);
      }

      // Atleast one BusinessKey and unique property names
      bool hasBusinessKey = false;
      var propertyNames = new List<string>();
      foreach (Property property in Properties)
      {
        if (property.IsBusinessKey)
        {
          hasBusinessKey = true;
        }
        List<ErrorObject> errors;
        if (!property.Validate(out errors))
        {
          validationErrors.AddRange(errors);
        }

        if (propertyNames.Contains(property.Name))
        {
          string message = String.Format("Property name '{0}' occurs more than once in Entity '{1}'.", property.Name, FullName);
          var errorData = new EntityValidationErrorData();
          errorData.ErrorCode = ErrorCode.ENTITY_VALIDATION_DUPLICATE_PROPERTY_NAME;
          errorData.ErrorType = ErrorType.EntityValidation;
          errorData.EntityTypeName = FullName;
          validationErrors.Add(new ErrorObject(message, errorData));
          logger.Error(message);
        }
        else
        {
          propertyNames.Add(property.Name);
        }
      }

      if (hasBusinessKey)
      {
        InternalBusinessKey = false;
      }
      else
      {
        InternalBusinessKey = true;
      }

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion

    #region Internal Methods
    /// <summary>
    ///    Return the database enum value (id_enum_data) for the specified propertyName and
    ///    the specified CSharp enum value for that property.
    ///  
    ///    If a property with propertyName does not exist or if the 
    ///    propertyName does not map to an enum property, an exception will be thrown.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <param name="cSharpEnumValue"></param>
    /// <returns></returns>
    internal int GetDbEnumValue(string propertyName, int cSharpEnumValue)
    {
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty");

      Property property = Properties.Find(p => p.Name == propertyName);
      Check.Require(property != null,
                   String.Format("Cannot find property '{0}' for entity '{1}'", propertyName, FullName));
      Check.Require(property.IsEnum,
                    String.Format("Cannot retrieve enum value for non enum property '{0}' for entity '{1}'", propertyName, FullName));

      return property.GetDbEnumValue(cSharpEnumValue);
    }

    /// <summary>
    ///    Return the C# enum instance for the specified propertyName and
    ///    the specified db enum value (id_enum_data) for that property.
    ///  
    ///    If a property with propertyName does not exist or if the 
    ///    propertyName does not map to an enum property, an exception will be thrown.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <param name="dbEnumValue"></param>
    /// <returns></returns>
    internal object GetCSharpEnumInstance(string propertyName, int dbEnumValue)
    {
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty");

      Property property = Properties.Find(p => p.Name == propertyName);
      Check.Require(property != null,
                   String.Format("Cannot find property '{0}' for entity '{1}'", propertyName, FullName));
      Check.Require(property.IsEnum,
                    String.Format("Cannot retrieve enum value for non enum property '{0}' for entity '{1}'", propertyName, FullName));

      return property.GetCSharpEnumValue(dbEnumValue);
    }

    internal Type GetPropertyType(string propertyName)
    {
      Check.Require(!String.IsNullOrEmpty(propertyName), "propertyName cannot be null or empty");

      Property property = Properties.Find(p => p.Name == propertyName);
      Check.Require(property != null,
                   String.Format("Cannot find property '{0}' for entity '{1}'", propertyName, FullName));

      return Type.GetType(property.AssemblyQualifiedTypeName, true);
    }

    internal void InitLocalizationData(List<LocalizedEntry> localizedEntries)
    {
      string labelKey = Name.GetEntityLocalizedLabelKey(FullName);

      List<LocalizedEntry> labelLocalizedEntries =
        localizedEntries.FindAll(l => l.LocaleKey.ToLower() == labelKey.ToLower());

      LocalizedLabels.Clear();
      labelLocalizedEntries.AsParallel().ForEach(l => LocalizedLabels.Add(l));

      Properties.AsParallel().ForEach(p => p.InitLocalizationData(localizedEntries));
    }

    internal List<Property> GetEnumProperties()
    {
      var enumProperties = new List<Property>();
      foreach (Property property in Properties)
      {
        if (property.IsEnum)
        {
          enumProperties.Add(property);
        }
      }

      return enumProperties;
    }

    internal virtual void GetEnumTypes(ref ICollection<EnumType> enumTypes)
    {
      foreach (Property property in Properties)
      {
        if (property.IsEnum && !enumTypes.Contains(property.EnumType))
        {
          enumTypes.Add(property.EnumType);
        }
      }
    }

    internal virtual EntityChangeSet CreateChangeSet(Entity originalEntity, DbTableMetadata tableMetadata, string databaseName)
    {
      Check.Require(tableMetadata != null, "tableMetadata cannot be null");
      Check.Require(!String.IsNullOrEmpty(databaseName), "databaseName cannot be null or empty");
      Check.Require(tableMetadata.HasData,
                    String.Format("Cannot create change set for entity '{0}' and table '{1}' because it does not have any data",
                                  FullName, tableMetadata.TableName));

      var entityChangeSet = new EntityChangeSet(FullName, tableMetadata.TableName);

      // Specify the standard properties
      List<Property> databaseProperties = GetDatabaseProperties();

      // dbTableMetadata contains the current columns in the database for this table. These will be backed up.
      // databaseProperties represents the columns for the new table.
      // The intersection of the two sets contains the properties that will be restored from backup.
      // The extra properties in this entity will be new properties.

      List<Property> backupProperties =
        databaseProperties.Join(tableMetadata.ColumnMetadataList,
                                p => p.ColumnName.ToLower(),  // join key for property
                                c => c.ColumnName.ToLower(),  // join key for ColumnMetadata
                                (p, c) => p).ToList();

      // Remove those backupProperties which are also standard properties (overlap occurs for history)
      // backupProperties.RemoveAll(p => standardProperties.Exists(sp => sp.Name == p.Name));

      foreach (Property property in backupProperties)
      {
        Property originalProperty = originalEntity[property.Name];

        if (originalProperty == null) continue;

        bool canRestoreEntityData;
        Property.ValidatePropertyChanges(property, originalProperty, out canRestoreEntityData);

        if (!canRestoreEntityData)
        {
          // Just backup the data. No restore
          entityChangeSet.BackupOnly = true;
          return entityChangeSet;
        }

        if (!originalProperty.IsRequired && property.IsRequired)
        {
          // Must have a default value (already verified by 'ValidatePropertyChanges')
          Check.Require(property.DefaultValueObject != null,
                        String.Format("Expected non null default value for property '{0}' on entity '{1}'",
                        property.Name, FullName));

          string caseStatement =
            "(case when " + property.ColumnName + " is null then " +
            property.GetDefaultValueDatabaseLiteral(NHibernateConfig.IsOracle(databaseName)) +
            " else " + property.ColumnName + " end) as " + property.ColumnName;

          entityChangeSet.InsertSelectColumnNameValues.Add(property.ColumnName, caseStatement);
        }
        else
        {
          entityChangeSet.InsertSelectColumnNameValues.Add(property.ColumnName, property.ColumnName);
        }
      }

      // NewProperties - those properties which are not in backupProperties
      // SkipWhile bypasses elements for which the condition is true
      var newProperties = new List<Property>();
      foreach (Property property in Properties)
      {
        if (!backupProperties.Contains(property))
        {
          newProperties.Add(property);
        }
      }

      // Properties.SkipWhile(backupProperties.Contains);

      foreach (Property newProperty in newProperties)
      {
        // If the new property is required and it doesn't have a default value - cannot restore data
        if (newProperty.IsRequired && !newProperty.HasDefaultValue())
        {
          logger.Debug(String.Format("Cannot restore data for entity '{0}' because the new property '{1}' " +
                                     "is required and there is no default value specified",
                                     FullName, newProperty.Name));

          // Just backup the data. No restore
          entityChangeSet.BackupOnly = true;
          return entityChangeSet;
        }

        if (newProperty.IsUnique)
        {
          logger.Debug(String.Format("Cannot restore data for entity '{0}' because property '{1}' " +
                                     "is specified as unique",
                                     FullName, newProperty.Name));

          // Just backup the data. No restore
          entityChangeSet.BackupOnly = true;
          return entityChangeSet;
        }

        if (!newProperty.IsRequired) continue;

        entityChangeSet.InsertSelectColumnNameValues.Add(newProperty.ColumnName,
                                                         newProperty.GetDefaultValueDatabaseLiteral(NHibernateConfig.IsOracle(databaseName)));
      }

      // INSERT INTO NEWTABLE (COL1, COL2, COL3) SELECT COL1, COL4, COL7 FROM BACKUP_TABLE 



      return entityChangeSet;
    }

    public HistoryEntity CreateHistoryEntity()
    {
      var entity = Clone();
      entity.Properties.ForEach(p => { p.IsUnique = false; });
      HistoryEntity = new HistoryEntity(entity);

      return HistoryEntity;
    }

    internal SelfRelationshipEntity CreateSelfRelationshipEntity()
    {
      SelfRelationshipEntity = new SelfRelationshipEntity(this);
      return SelfRelationshipEntity;
    }

    /// <summary>
    ///   Clone entity and property data. Not relationships.
    /// </summary>
    /// <returns></returns>
    internal virtual Entity Clone()
    {
      return new Entity(this);
    }

    internal HbmMapping CreateHbmMappingForDerived()
    {
      // <hibernate-mapping>
      var hbmMapping = new HbmMapping();
      var hbmMappingItems = new List<object>();

      hbmMapping.meta =
        new HbmMeta[]
          {
            new HbmMeta
              {
                attribute = CategoryAttribute,
                Text = new string[] {Category.ConfigDriven.ToString()}
              }
          };

      var hbmJoinedSubclass = new HbmJoinedSubclass();
      hbmMappingItems.Add(hbmJoinedSubclass);

      hbmJoinedSubclass.name = AssemblyQualifiedName;
      hbmJoinedSubclass.table = TableName;
      Check.Require(!String.IsNullOrEmpty(ParentEntityName),
                    String.Format("ParentEntityName cannot be null or empty"));
      hbmJoinedSubclass.extends = ParentEntityName;

      // Meta attributes
      UpdateClassAttributes();
      List<HbmMeta> metaAttributes = GetMetaAttributes();
      hbmJoinedSubclass.meta = metaAttributes.ToArray();

      // Key
      hbmJoinedSubclass.key = new HbmKey() { column1 = GetIdColumnName() };

      var items = new List<object>();

      // Business Key
      items.Add(CreateBusinessKeyHbmComponent());

      // Properties
      foreach (Property property in Properties)
      {
        // BusinesKey properties are in a component
        // Compound properties are ignored
        if (property.IsBusinessKey || property.IsCompound)
        {
          continue;
        }

        items.Add(property.CreateHbmProperty());
      }

      // Relationships
      foreach (Relationship relationship in Relationships)
      {
        items.Add(relationship.GetHbmRelationshipItem(FullName));
      }

      // Add to hbmJoinedSubclass
      if (items.Count > 0)
      {
        hbmJoinedSubclass.Items = items.ToArray();
      }

      // Add to hbmMapping
      hbmMapping.Items = hbmMappingItems.ToArray();

      return hbmMapping;
    }

    internal virtual string GetHbmMappingFileContent(bool overWriteHbm)
    {
      HbmMapping hbmMapping = null;

      if (!overWriteHbm && HbmMapping != null)
      {
        hbmMapping = HbmMapping;
      }
      else
      {
        if (EntityType == EntityType.Derived)
        {
          hbmMapping = CreateHbmMappingForDerived();
        }
        else
        {
          HbmClass hbmClass;
          hbmMapping = CreateHbmMapping(out hbmClass);
        }
      }

      var serializer = new XmlSerializer(typeof(HbmMapping));

      var stringWriter = new NullEncodingStringWriter();
      serializer.Serialize(stringWriter, hbmMapping);

      Check.Require(!String.IsNullOrEmpty(stringWriter.ToString()),
                     String.Format("Failed to generate hbm mapping for entity '{0}'", FullName));

      return stringWriter.ToString();
    }

    internal virtual string GetCodeFileContent()
    {
      string codeFileContent = EntityGenerator.GenerateCode(this);
      Check.Require(!String.IsNullOrEmpty(codeFileContent),
                    String.Format("Failed to generate code for entity '{0}'", FullName));

      return codeFileContent;
    }

    internal HbmId GetHbmId()
    {
      if (HbmClass != null)
      {
        return HbmClass.Id;
      }

      // Manufacture one
      var hbmId = new HbmId();
      hbmId.name = "Id";
      hbmId.column1 = GetIdColumnName();
      hbmId.type = new HbmType() { name = "guid" };
      hbmId.generator = new HbmGenerator();
      hbmId.generator.@class = "guid.comb";

      return hbmId;
    }

    /// <summary>
    ///    Available for MASInterfaceGenerator. It is called at build time during
    ///    client proxy generation. Not used by the BME system.
    /// 
    ///    NOTE: The way this is implemented currently is buggy - because it will not generate
    ///    the correct Id if the specified entity is a derived entity.
    ///    
    ///    This has to be fixed to go to the file system to load the inheritance
    ///    hierarchy for this entity (if necessary). 
    ///    It will be too expensive to run MetadataRepository initialization during client proxy generation.
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    public static string GetIdColumnName(string entityName)
    {
      string columnName = Name.GetEntityClassName(entityName);

      if (columnName.Length > 24)
      {
        columnName = columnName.Substring(0, 24);
      }

      return "c_" + columnName + "_Id";
    }

    public virtual string GetIdColumnName()
    {
      string columnName = null;
      if (EntityType == EntityType.Derived)
      {
        Check.Require(!String.IsNullOrEmpty(RootEntityName),
                      String.Format("RootEntityName cannot be null or empty for derived entity '{0}'", FullName));
        columnName = Name.GetEntityClassName(RootEntityName);
      }
      else
      {
        columnName = ClassName;
      }


      if (columnName.Length > 24)
      {
        columnName = columnName.Substring(0, 24);
      }

      return "c_" + columnName + "_Id";
    }

    /// <summary>
    ///    Create a new HbmMapping/HbmClass, populate it using the data in this class and return it
    /// </summary>
    /// <returns></returns>
    internal List<ErrorObject> AddMetranetEntityAssociation(IMetranetEntity metranetEntity, Multiplicity multiplicity)
    {
      Check.Require(metranetEntity != null, "metranetEntity cannot be null", SystemConfig.CallerInfo);
      Check.Require(metranetEntity.MetraNetEntityConfig != null, "metranetEntityConfig cannot be null", SystemConfig.CallerInfo);
      Check.Require(metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName != null, "metranetEntityConfig.AssemblyQualifiedName cannot be null", SystemConfig.CallerInfo);

      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;
      MetaAttributes.TryGetValue(MetraNetEntityAssociationAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        foreach (string value in metaAttribute.Values)
        {
          if (value.StartsWith(metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName))
          {
            string message = String.Format("An association with '{0}' already exists", metranetEntity.MetraNetEntityConfig.TypeName);
            errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
            return errors;
          }
        }
      }

      // Validate that the property names on metranetEntity do not
      // conflict with the existing property names on the entity
      foreach (MetranetEntityProperty metranetEntityProperty in metranetEntity.Properties)
      {
        // Check that the property name does not conflict with an existing property
        if (this[metranetEntityProperty.Name] != null)
        {
          string message = String.Format("The property name '{0}' on metranet entity '{1}' already exists on " +
                                         "the entity '{2}'.",
                                         metranetEntityProperty.Name,
                                         metranetEntity.MetraNetEntityConfig.TypeName,
                                         FullName);

          errors.Add(new ErrorObject(message, SystemConfig.CallerInfo));
          continue;
        }
      }

      if (errors.Count > 0)
      {
        return errors;
      }

      // Create properties
      foreach (MetranetEntityProperty metranetEntityProperty in metranetEntity.Properties)
      {
        Property property = new Property(this, metranetEntityProperty.Name, metranetEntityProperty.TypeName);
        property.AssociationEntityName = metranetEntity.MetraNetEntityConfig.TypeName;
        if (multiplicity == Multiplicity.One)
        {
          property.IsUnique = true;
        }

        AddProperty(property);
      }

      // Create metranet-entity-association metadata
      if (metaAttribute == null)
      {
        metaAttribute = new MetaAttribute();
        metaAttribute.Name = MetraNetEntityAssociationAttribute;
      }

      metaAttribute.Values.Add(metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName + "::" + multiplicity);

      return errors;
    }

    internal void DeleteMetranetEntityAssociation(IMetranetEntity metranetEntity)
    {
      Check.Require(metranetEntity != null, "metranetEntity cannot be null", SystemConfig.CallerInfo);
      Check.Require(metranetEntity.MetraNetEntityConfig != null, "metranetEntityConfig cannot be null", SystemConfig.CallerInfo);
      Check.Require(metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName != null, "metranetEntityConfig.AssemblyQualifiedName cannot be null", SystemConfig.CallerInfo);

      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;
      MetaAttributes.TryGetValue(MetraNetEntityAssociationAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        metaAttribute.Values.RemoveAll(v => v.StartsWith(metranetEntity.MetraNetEntityConfig.AssemblyQualifiedName));

        var metranetEntityProperties =
        metranetEntity.GetType()
                      .GetProperties(BindingFlags.Public | BindingFlags.Instance)
                      .Where(p => p.Name != "MetraNetEntityConfig");

        foreach (PropertyInfo propertyInfo in metranetEntityProperties)
        {
          Properties.RemoveAll(p => p.Name == propertyInfo.Name);
        }
      }
    }


    internal static List<ErrorObject> GetEntities(string hbmFile, out List<Entity> entities)
    {
      Check.Require(!String.IsNullOrEmpty(hbmFile), "Argument 'hbmFile' cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(File.Exists(hbmFile), String.Format("Cannot find file '{0}'", hbmFile), SystemConfig.CallerInfo);

      logger.Debug(String.Format("Retrieving entity from file '{0}'", hbmFile));

      entities = new List<Entity>();
      var errors = new List<ErrorObject>();

      var hbmMapping = GetHbmMapping(hbmFile);

      ErrorObject errorObject;
      Category category = hbmMapping.GetCategoryMetadata(CategoryAttribute, out errorObject);
      if (errorObject != null)
      {
        errors.Add(errorObject);
      }

      string errorMessage = String.Empty;

      if (hbmMapping.Items == null)
      {
        return errors;
      }

      Entity entity = null;
      HbmClass hbmClass = null;

      foreach (object item in hbmMapping.Items)
      {
        if (item is HbmJoinedSubclass)
        {
          entity = ReadHbmMappingForDerived(hbmMapping, hbmFile);
          Check.Require(entity != null, String.Format("Cannot find derived entity in file '{0}'", hbmFile));
          entities.Add(entity);
          continue;
        }
        else if (item is HbmClass)
        {
          hbmClass = item as HbmClass;
        }
        else
        {
          continue;
        }

        #region Entity
        if (String.IsNullOrEmpty(hbmClass.name))
        {
          errorMessage = String.Format("Cannot find class name in file '{0}'", hbmFile);
          errors.Add(new ErrorObject(errorMessage));
          logger.Error(errorMessage);
          continue;
        }

        AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(hbmClass.name);
        if (String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) || String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly))
        {
          errorMessage =
            String.Format("Cannot parse assembly qualified name '{0}' in file '{1}'", hbmClass.name, hbmFile);
          errors.Add(new ErrorObject(errorMessage));
          logger.Error(errorMessage);
          continue;
        }

        Check.Require(!String.IsNullOrEmpty(hbmClass.table),
                      String.Format("Cannot find table name for class '{0}' in file '{1}'", hbmClass.name, hbmFile));

        EntityType entityType = hbmClass.GetEntityType();

        if (entityType == EntityType.Entity)
        {
          entity = new Entity(assemblyQualifiedTypeName.Type);
        }
        else if (entityType == EntityType.Relationship)
        {
          entity = new RelationshipEntity(assemblyQualifiedTypeName.Type);
        }
        else if (entityType == EntityType.SelfRelationship)
        {
          entity = new SelfRelationshipEntity(assemblyQualifiedTypeName.Type);
        }
        else if (entityType == EntityType.History)
        {
          entity = new HistoryEntity(assemblyQualifiedTypeName.Type);
        }
        else if (entityType == EntityType.Compound)
        {
          entity = new CompoundEntity(assemblyQualifiedTypeName.Type);
        }
        else if (entityType == EntityType.Legacy)
        {
          continue;
        }

        entity.IsPersisted = true;
        entity.TableName = hbmClass.table;
        entity.EntityType = entityType;
        entity.HbmDatabaseObjects.AddRange(hbmMapping.GetHbmDatabaseObjects());

        if (entity.AssemblyName != assemblyQualifiedTypeName.Assembly)
        {
          errorMessage =
            String.Format("The assembly name '{0}' for class '{1}' in file '{2}' does not match the assembly name on the entity.",
                          assemblyQualifiedTypeName.Assembly, hbmClass.name, hbmFile);
          errors.Add(new ErrorObject(errorMessage));
          logger.Error(errorMessage);
          continue;
        }

        // Get the interface
        if (entity.EntityType != EntityType.History)
        {
          string interfaceName = hbmClass.GetMetadata(InterfaceAttribute);
          if (String.IsNullOrEmpty(interfaceName))
          {
            errorMessage =
              String.Format("Cannot find interface name for entity '{0}' in file '{1}'", hbmClass.name, hbmFile);

            errors.Add(new ErrorObject(errorMessage));
            logger.Error(errorMessage);
            continue;
          }

          assemblyQualifiedTypeName = TypeNameParser.Parse(interfaceName);

          if (String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) || String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly))
          {
            errors.Add(new ErrorObject(errorMessage));
            logger.Error(errorMessage);
            continue;
          }
        }

        // Setup Attributes
        errors.AddRange(entity.SetupAttributes(hbmClass.GetMetaAttributes()));

        entities.Add(entity);

        entity.Category = category;
        entity.HbmClass = hbmClass;
        entity.HbmMapping = hbmMapping;
        #endregion

        #region Properties
        errors.AddRange(Property.GetProperties(ref entity));
        #endregion
      }

      return errors;
    }

    internal static Entity ReadHbmMappingForDerived(HbmMapping hbmMapping, string hbmFile)
    {
      Entity entity = null;
      foreach (object item in hbmMapping.Items)
      {
        var hbmSubclass = item as HbmJoinedSubclass;
        if (hbmSubclass == null)
        {
          continue;
        }

        ErrorObject errorObject;
        Category category = hbmMapping.GetCategoryMetadata(CategoryAttribute, out errorObject);
        if (errorObject != null)
        {
          throw new
            MetadataException(String.Format("The following error occurred while retrieving category from file '{0}': '{1}'",
                                            hbmFile, errorObject.Message));
        }

        Check.Require(!String.IsNullOrEmpty(hbmSubclass.name),
                      String.Format("Cannot find subclass name in file '{0}'", hbmFile));

        AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(hbmSubclass.name);
        Check.Require(!String.IsNullOrEmpty(assemblyQualifiedTypeName.Type) &&
                      !String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly),
                      String.Format("Cannot parse assembly qualified name '{0}' in file '{1}'",
                                    hbmSubclass.name, hbmFile));

        Check.Require(!String.IsNullOrEmpty(hbmSubclass.table),
                      String.Format("Cannot find table name for class '{0}' in file '{1}'",
                                    hbmSubclass.name, hbmFile));

        entity = new Entity(assemblyQualifiedTypeName.Type);
        entity.Category = category;
        entity.HbmJoinedSubclass = hbmSubclass;
        entity.IsPersisted = true;
        entity.TableName = hbmSubclass.table;
        entity.EntityType = EntityType.Derived;
        entity.ParentEntityName = hbmSubclass.extends;
        Check.Require(!String.IsNullOrEmpty(entity.ParentEntityName),
                      String.Format("Cannot find parent class name for class '{0}' in file '{1}'",
                                    hbmSubclass.name, hbmFile));

        Check.Require(entity.AssemblyName == assemblyQualifiedTypeName.Assembly,
                      String.Format("The assembly name '{0}' for class '{1}' in file '{2}' does not match the assembly name on the entity.",
                                    assemblyQualifiedTypeName.Assembly, hbmSubclass.name, hbmFile));

        // Setup attributes
        entity.SetupAttributes(hbmSubclass.GetMetaAttributes());

        // Setup properties
        List<ErrorObject> errors = Property.GetProperties(ref entity);
        Check.Require(errors.Count == 0,
                      String.Format("Failed to retrieve properties from entity '{0}' with error(s): '{1}'",
                                    entity.FullName, StringUtil.Join(" , ", errors, e => e.Message)));

      }

      return entity;
    }

    internal static List<ErrorObject> GetEntity(string hbmFile, out Entity entity)
    {
      entity = null;
      List<Entity> entities;
      List<ErrorObject> errors = GetEntities(hbmFile, out entities);
      if (entities.Count > 0)
      {
        entity = entities[0];
      }

      return errors;
    }

    internal static bool TypeInHbmMappingFile(string nameSpaceQualifiedTypeName, string hbmMappingFile)
    {
      bool foundType = false;

      List<string> classNames;
      Category category;
      GetClassNamesAndCategory(hbmMappingFile, out classNames, out category);

      string className = classNames.SingleOrDefault(cn => cn == nameSpaceQualifiedTypeName);

      if (!String.IsNullOrEmpty(className))
      {
        foundType = true;
      }

      return foundType;
    }

    /// <summary>
    ///    Return the namespace qualifed class names for all the classes in the specified hbmMappingFile.
    /// </summary>
    /// <param name="hbmMappingFile"></param>
    /// <returns></returns>
    internal static List<ErrorObject> GetClassNamesAndCategory(string hbmMappingFile,
                                                               out List<string> classNames,
                                                               out Category category)
    {
      classNames = new List<string>();
      var errors = new List<ErrorObject>();

      logger.Debug(String.Format("Getting class names and category from hbm file '{0}'", hbmMappingFile));

      var serializer = new XmlSerializer(typeof(HbmMapping));
      HbmMapping hbmMapping = null;

      using (FileStream fileStream = File.Open(hbmMappingFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
      {
        hbmMapping = (HbmMapping)serializer.Deserialize(fileStream);
      }

      if (hbmMapping == null)
      {
        string errorMessage = String.Format("Cannot deserialize file '{0}'", hbmMappingFile);
        throw new MetadataException(errorMessage, SystemConfig.CallerInfo);
      }

      ErrorObject error;
      category = hbmMapping.GetCategoryMetadata(CategoryAttribute, out error);
      if (error != null)
      {
        errors.Add(error);
        return errors;
      }

      if (hbmMapping.Items == null)
      {
        return errors;
      }

      string className = String.Empty;

      foreach (object item in hbmMapping.Items)
      {
        HbmClass hbmClass = item as HbmClass;
        if (hbmClass == null)
        {
          continue;
        }

        string nameSpace = GetNamespaceForClass(hbmClass, hbmMapping);
        if (!String.IsNullOrEmpty(nameSpace))
        {
          className = nameSpace + "." + StringHelper.GetClassname(hbmClass.name);
        }
        else
        {
          className = StringHelper.GetClassname(hbmClass.name);
        }

        classNames.Add(className);
      }

      return errors;
    }

    internal static string GetAssemblyNameForClass(HbmClass hbmClass, HbmMapping hbmMapping)
    {
      string assemblyName = String.Empty;

      // If the hbmClass has an assembly qualified type name, then get the assembly name from there
      // Otherwise, look for the assembly name on the hbmMapping
      // Otherwise, error
      AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(hbmClass.name);
      if (assemblyQualifiedTypeName != null && !String.IsNullOrEmpty(assemblyQualifiedTypeName.Assembly))
      {
        assemblyName = assemblyQualifiedTypeName.Assembly;
      }
      else if (!String.IsNullOrEmpty(hbmMapping.assembly))
      {
        assemblyName = hbmMapping.assembly;
      }

      return assemblyName;
    }

    internal static string GetNamespaceForClass(HbmClass hbmClass, HbmMapping hbmMapping)
    {
      string nameSpace = String.Empty;

      // If the hbmClass has a namespace qualified name, then the [full class name] will not match the [class name].
      //   - extract the namespace by subtracting the length of the [class name] from the length of the [full class name]
      // Otherwise, look for the namespace on the hbmMapping.
      // Otherwise, error.

      string fullClassName = StringHelper.GetFullClassname(hbmClass.name);
      string className = StringHelper.GetClassname(hbmClass.name);

      if (className != fullClassName)
      {
        nameSpace = fullClassName.Substring(0, fullClassName.Length - (className.Length + 1));
      }
      else if (!String.IsNullOrEmpty(hbmMapping.@namespace))
      {
        nameSpace = hbmMapping.@namespace;
      }

      return nameSpace;
    }

    /// <summary>
    ///    Return the 'category' meta tag for the given hbmClass.
    /// </summary>
    /// <param name="hbmClass"></param>
    /// <returns></returns>
    internal static Category GetCategory(HbmClass hbmClass)
    {
      Category category = Category.CodeDriven;
      if (hbmClass.meta == null)
      {
        return category;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (hbmMeta.attribute.Equals("category", StringComparison.InvariantCultureIgnoreCase))
        {
          if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
          {
            string errorMessage = String.Format("Cannot find category name for class '{0}'", hbmClass.name);
            throw new MetadataException(errorMessage, SystemConfig.CallerInfo);
          }

          if (hbmMeta.Text[0].Equals("ConfigDriven", StringComparison.InvariantCultureIgnoreCase))
          {
            category = Category.ConfigDriven;
          }
          else if (hbmMeta.Text[0].Equals("CodeDriven", StringComparison.InvariantCultureIgnoreCase))
          {
            category = Category.CodeDriven;
          }
          else
          {
            string errorMessage = String.Format("Unknown category name '{0}' specified for class '{1}'", hbmMeta.Text[0], hbmClass.name);
            throw new MetadataException(errorMessage, SystemConfig.CallerInfo);
          }

          break;
        }
      }

      return category;
    }

    internal static string GetDescription(HbmClass hbmClass)
    {
      string description = String.Empty;

      if (hbmClass.meta == null)
      {
        return description;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (!hbmMeta.attribute.Equals("description", StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          logger.Debug(String.Format("No description specified for class '{0}'", hbmClass.name));
        }
        else
        {
          description = hbmMeta.Text[0];
        }

        break;
      }

      return description;
    }

    ///    Return the interface namespaces for this and its related entities.
    /// </summary>
    /// <returns></returns>
    internal ICollection<string> GetInterfaceNamespaces(bool includeSelf)
    {
      IList<string> interfaceNamespaces = new List<string>();

      string interfaceNamespace = Name.GetInterfaceNamespace(FullName);
      if (includeSelf)
      {
        interfaceNamespaces.Add(interfaceNamespace);
      }

      foreach (Relationship relationship in Relationships)
      {
        string otherInterfaceNamespace = Name.GetInterfaceNamespace(relationship.Target.EntityTypeName);
        if (!interfaceNamespaces.Contains(otherInterfaceNamespace) && otherInterfaceNamespace != interfaceNamespace)
        {
          interfaceNamespaces.Add(otherInterfaceNamespace);
        }
      }

      return interfaceNamespaces;
    }

    /// <summary>
    ///    Return the interface assembly name for this and its related entities.
    /// </summary>
    /// <returns></returns>
    internal ICollection<string> GetInterfaceAssemblyNames(bool includeSelf, bool withPath)
    {
      IList<string> interfaceAssemblyNames = new List<string>();
      string interfaceAssemblyName = Name.GetInterfaceAssemblyName(FullName);
      if (withPath)
      {
        interfaceAssemblyName = Path.Combine(SystemConfig.GetBinDir(), Name.GetInterfaceAssemblyName(FullName) + ".dll");
      }

      if (includeSelf)
      {
        interfaceAssemblyNames.Add(interfaceAssemblyName);
      }

      foreach (Relationship relationship in Relationships)
      {
        string otherInterfaceAssemblyName = Name.GetInterfaceAssemblyName(relationship.Target.EntityTypeName);
        if (withPath)
        {
          otherInterfaceAssemblyName = Path.Combine(SystemConfig.GetBinDir(), otherInterfaceAssemblyName + ".dll");
        }

        if (!interfaceAssemblyNames.Contains(otherInterfaceAssemblyName) && otherInterfaceAssemblyName != interfaceAssemblyName)
        {
          interfaceAssemblyNames.Add(otherInterfaceAssemblyName);
        }
      }

      return interfaceAssemblyNames;
    }

    /// <summary>
    ///   Only use for testing
    /// </summary>
    /// <param name="obj"></param>
    /// <returns></returns>
    internal bool TestEquals(object obj)
    {
      Entity compareTo = obj as Entity;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.FullName == FullName &&
             compareTo.Category == Category &&
             compareTo.Label == Label &&
             compareTo.Description == Description &&
             compareTo.PluralName == PluralName &&
             compareTo.Properties.SequenceEqual(Properties);
    }

    internal bool IsPropertySortable(string propertyName)
    {
      bool sortable = false;

      Property property = Properties.Find(p => p.Name == propertyName);
      if (property != null)
      {
        sortable = property.IsSortable;
      }

      return sortable;
    }

    internal bool IsCompoundProperty(string propertyName)
    {
      bool isCompound = false;

      Property property = Properties.Find(p => p.Name == propertyName);
      if (property != null)
      {
        isCompound = property.IsCompound;
      }

      return isCompound;
    }

    internal bool IsBusinessKeyProperty(string propertyName)
    {
      bool isBusinessKey = false;

      Property property = Properties.Find(p => p.Name == propertyName);
      if (property != null)
      {
        isBusinessKey = property.IsBusinessKey;
      }

      return isBusinessKey;
    }
    #endregion

    #region Protected Methods

    protected Entity(Entity entity)
    {
      Check.Require(entity != null, "entity cannot be null");
      Check.Require(!String.IsNullOrEmpty(entity.FullName), "entity.FullName cannot be null or empty");

      SetTypeData(entity.FullName);

      PluralName = entity.PluralName;
      DatabaseName = entity.DatabaseName;
      ParentEntityName = entity.ParentEntityName;
      RootEntityName = entity.RootEntityName;
      CustomBaseClassName = entity.CustomBaseClassName;
      EntityType = entity.EntityType;
      IsPersisted = entity.IsPersisted;
      RecordHistory = entity.RecordHistory;
      HistoryEntity = entity.HistoryEntity;
      // HasSelfRelationship = entity.HasSelfRelationship;
      SelfRelationshipEntity = entity.SelfRelationshipEntity;
      TableName = entity.TableName;
      Category = entity.Category;
      Description = entity.Description;
      Label = entity.Label;

      MetaAttributes = new Dictionary<string, MetaAttribute>();
      entity.MetaAttributes.ForEach(kvp => MetaAttributes.Add(kvp.Key, kvp.Value.Clone()));

      InternalBusinessKey = entity.InternalBusinessKey;

      LocalizedLabels = new List<LocalizedEntry>();
      entity.LocalizedLabels.ForEach(l => LocalizedLabels.Add(l));

      HbmClass = entity.HbmClass;
      if (entity.EntitySyncData != null)
      {
        EntitySyncData = entity.EntitySyncData.Clone();
      }

      entity.Properties.ForEach(p => AddProperty(p.Clone()));

      entity.HbmDatabaseObjects.ForEach(h => HbmDatabaseObjects.Add(h));
    }

    protected virtual HbmMapping CreateBasicHbmMapping()
    {
      // <hibernate-mapping>
      var hbmMapping = new HbmMapping();
      hbmMapping.autoimport = false;

      hbmMapping.meta =
        new HbmMeta[]
          {
            new HbmMeta
              {
                attribute = CategoryAttribute,
                Text = new string[] {Category.ConfigDriven.ToString()}
              }
          };

      // Database objects);
      HbmDatabaseObjects.AsParallel().ForEach(hbmMapping.AddHbmDatabaseObject);

      return hbmMapping;
    }

    protected virtual HbmClass CreateBasicHbmClass()
    {
      var hbmClass = new HbmClass();
      hbmClass.name = AssemblyQualifiedName;

      Check.Require(!String.IsNullOrEmpty(TableName), String.Format("TableName cannot be null or empty for entity '{0}'", FullName));
      hbmClass.table = TableName;

      // Update attributes
      UpdateClassAttributes();

      // Add attributes
      List<HbmMeta> metaAttributes = GetMetaAttributes();
      hbmClass.meta = metaAttributes.ToArray();

      // <id>
      var hbmId = GetHbmId();
      hbmClass.Item = hbmId;

      // <property> 
      var items = new List<object>();

      // <component> for Business Key
      items.Add(CreateBusinessKeyHbmComponent());

      #region  Predefined properties
      foreach (Property property in PreDefinedProperties)
      {
        // Create a HbmVersion, if this is the Version property
        if (property.Name == Property.VersionPropertyName)
        {
          hbmClass.Item1 = CreateHbmVersion();
          continue;
        }

        items.Add(property.CreateHbmProperty());
      }
      #endregion

      #region Regular properties
      foreach (Property property in Properties)
      {
        // BusinesKey properties are in a component
        // Compound properties are ignored
        if (property.IsBusinessKey || (property.IsCompound))
        {
          continue;
        }

        items.Add(property.CreateHbmProperty());
      }
      #endregion
      hbmClass.Items = items.ToArray();
      return hbmClass;
    }
    /// <summary>
    /// </summary>
    /// <param name="hbmClass"></param>
    /// <returns></returns>
    protected virtual HbmMapping CreateHbmMapping(out HbmClass hbmClass)
    {
      // <hibernate-mapping>

      HbmMapping hbmMapping = CreateBasicHbmMapping();
      var hbmMappingItems = new List<object>();

      hbmClass = CreateBasicHbmClass();
      // Add the hbmClass to hbmMapping
      hbmMapping.AddHbmClass(hbmClass);

      var hbmClassItems = hbmClass.Items.ToList();

      List<Property> legacyPrimaryKeys = Properties.FindAll(p => p.IsCompound && p.IsLegacyPrimaryKey);

      #region Parent/Children specification for Entity with self relationship
      //if (HasSelfRelationship)
      //{
      //  Check.Require(SelfRelationshipEntity != null,
      //                String.Format("Cannot find SelfRelationshipEntity on entity '{0}'", FullName));

      //  // Parent
      //  HbmBag hbmBag = new HbmBag();
      //  hbmBag.name = SelfRelationshipEntity.GetParentPluralName(); ;
      //  hbmBag.inverse = true;
      //  hbmBag.lazy = HbmCollectionLazy.True;
      //  hbmBag.lazySpecified = true;
      //  hbmBag.cascade = "delete";

      //  // <key>
      //  hbmBag.key = new HbmKey();
      //  hbmBag.key.column1 = "c_Parent_Id";

      //  // <one-to-many>
      //  hbmBag.Item = new HbmOneToMany();
      //  ((HbmOneToMany)hbmBag.Item).@class = Name.GetEntityAssemblyQualifiedName(SelfRelationshipEntity.FullName);

      //  items.Add(hbmBag);

      //  // Child
      //  hbmBag = new HbmBag();
      //  hbmBag.name = SelfRelationshipEntity.GetChildPluralName(); ;
      //  hbmBag.inverse = true;
      //  hbmBag.lazy = HbmCollectionLazy.True;
      //  hbmBag.lazySpecified = true;
      //  hbmBag.cascade = "none";

      //  // <key>
      //  hbmBag.key = new HbmKey();
      //  hbmBag.key.column1 = "c_Child_Id"; // GetIdColumnName(SelfRelationshipEntity.EntityName);

      //  // <one-to-many>
      //  hbmBag.Item = new HbmOneToMany();
      //  ((HbmOneToMany)hbmBag.Item).@class = Name.GetEntityAssemblyQualifiedName(SelfRelationshipEntity.FullName);

      //  items.Add(hbmBag);
      //}
      #endregion

      #region Relationship specification for Entity
      // navigation properties
      foreach (Relationship relationship in Relationships)
      {

        if (relationship.RelationshipEntity.HasSameSourceAndTarget)
        {
          hbmClassItems.Add(relationship.GetSourceHbmRelationshipItem());
          hbmClassItems.Add(relationship.GetTargetHbmRelationshipItem());
          continue;
        }

        hbmClassItems.Add(relationship.GetHbmRelationshipItem(FullName));

        #region Code for Not Generating Bags
        //if (relationship.RelationshipEntity.HasSameSourceAndTarget)
        //{
        //  items.Add(relationship.GetTargetHbmRelationshipItem());
        //  continue;
        //}

        //// Don't generate bags
        //if (relationship.Source.EntityTypeName == FullName)
        //{
        //  continue;
        //}

        //items.Add(relationship.GetTargetHbmRelationshipItem());
        #endregion
      }
      #endregion

      #region Relationship specification for RelationshipEntity
      // Two <many-to-one> entries for source and target respectively
      var relationshipEntity = this as RelationshipEntity;
      if (relationshipEntity != null && relationshipEntity.HasJoinTable)
      {
        //<many-to-one name="Order"
        //             class="Core.OrderManagement.Order, Core.OrderManagement.Entity"
        //             column="Order_Id"
        //             not-null="true" />
        var sourceManyToOne = new HbmManyToOne();
        sourceManyToOne.name = Name.GetEntityClassName(relationshipEntity.SourceEntityName);
        sourceManyToOne.@class = Name.GetEntityAssemblyQualifiedName(relationshipEntity.SourceEntityName);
        sourceManyToOne.column = relationshipEntity.SourceKeyColumnName;
        sourceManyToOne.notnull = true;
        sourceManyToOne.notnullSpecified = true;
        sourceManyToOne.cascade = "none";
        sourceManyToOne.uniquekey = ClassName; // creates a multi-column unique constraint - ClassName string isn't used in the constraint name 

        hbmClassItems.Add(sourceManyToOne);

        //     <many-to-one name="OrderItem" 
        //                  class="Core.OrderManagement.OrderItem, Core.OrderManagement.Entity" 
        //                  column="OrderItem_Id"
        //                  not-null="true" />
        var targetManyToOne = new HbmManyToOne();
        targetManyToOne.name = Name.GetEntityClassName(relationshipEntity.TargetEntityName);
        targetManyToOne.@class = Name.GetEntityAssemblyQualifiedName(relationshipEntity.TargetEntityName);
        targetManyToOne.column = relationshipEntity.TargetKeyColumnName;
        targetManyToOne.notnull = true;
        targetManyToOne.notnullSpecified = true;
        targetManyToOne.cascade = "none";
        targetManyToOne.uniquekey = ClassName; // creates a multi-column unique constraint - ClassName string isn't used in the constraint name
        hbmClassItems.Add(targetManyToOne);

      }
      #endregion

      #region Relationship specification for SelfRelationshipEntity
      // Two <many-to-one> entries for source and target respectively
      if (this is SelfRelationshipEntity)
      {
        var selfRelationshipEntity = this as SelfRelationshipEntity;
        //<many-to-one name="Parent"
        //             class="Core.OrderManagement.Order, Core.OrderManagement.Entity"
        //             column="c_Order_Id"
        //             not-null="true" />
        var parentManyToOne = new HbmManyToOne();
        parentManyToOne.name = "Parent";
        parentManyToOne.@class = Name.GetEntityAssemblyQualifiedName(selfRelationshipEntity.EntityName);
        parentManyToOne.column = "c_Parent_Id"; // GetIdColumnName(selfRelationshipEntity.EntityName);
        parentManyToOne.notnull = true;
        parentManyToOne.notnullSpecified = true;

        hbmClassItems.Add(parentManyToOne);

        //     <many-to-one name="Child" 
        //                  class="Core.OrderManagement.Order, Core.OrderManagement.Entity" 
        //                  column="c_Order_Id"
        //                  not-null="true" />
        var childManyToOne = new HbmManyToOne();
        childManyToOne.name = "Child";
        childManyToOne.@class = Name.GetEntityAssemblyQualifiedName(selfRelationshipEntity.EntityName);
        childManyToOne.column = "c_Child_Id"; // GetIdColumnName(selfRelationshipEntity.EntityName);
        childManyToOne.notnull = true;
        childManyToOne.notnullSpecified = true;

        hbmClassItems.Add(childManyToOne);
      }

      #endregion
      
      #region Many to One

        #region Many-To-One for Compound

        if (EntityType == EntityType.Compound)
        {
          Check.Require(legacyPrimaryKeys.Count > 0,
                        String.Format("Cannot find primary key for legacy entity '{0}'", FullName));

          //<many-to-one name="Legacy"
          //             class="Core.Common.EntitySyncData_Legacy, Core.Common.Entity"
          //             lazy="false"
          //             cascade="none">
          //  <column name="nm_login" unique="true"/>
          //  <column name="nm_space" unique="true"/>
          //</many-to-one>

          var isUniquePrimaryKey = legacyPrimaryKeys[0].IsUnique;

          var hbmManyToOne = new HbmManyToOne();
          hbmManyToOne.name = "LegacyObject";
          hbmManyToOne.@class = Name.GetLegacyAssemblyQualifiedName(FullName);
          hbmManyToOne.lazy = HbmLaziness.False;
          hbmManyToOne.lazySpecified = true;
          hbmManyToOne.cascade = "none";
          hbmManyToOne.unique = isUniquePrimaryKey;

          var primaryKeyColumns = new List<object>();
          foreach (Property legacyPrimaryKey in legacyPrimaryKeys)
          {
            int length = legacyPrimaryKey.DbColumnMetadata.MaxLength;
            int precision = legacyPrimaryKey.DbColumnMetadata.Precision;

            var hbmColumn = new HbmColumn()
                              {
                                name = legacyPrimaryKey.DbColumnMetadata.ColumnName,
                                // unique = true,
                                // uniqueSpecified = true,
                                notnull = true,
                                notnullSpecified = true
                              };
            if (isUniquePrimaryKey)
            {
              hbmColumn.uniquekey = "test";
            }

            if (length > 0)
            {
              hbmColumn.length = Convert.ToString(length);
            }

            if (precision > 0)
            {
              hbmColumn.precision = Convert.ToString(precision);
            }

            primaryKeyColumns.Add(hbmColumn);
          }

          hbmManyToOne.Items = primaryKeyColumns.ToArray();
          hbmClassItems.Add(hbmManyToOne);
        }

        #endregion

        // Add items to hbmClass
        if (hbmClassItems.Count > 0)
        {
          hbmClass.Items = hbmClassItems.ToArray();
        }

        #region Compound Legacy Class
        if (EntityType == EntityType.Compound)
        {
          var hbmLegacyClass = new HbmClass();
          hbmMappingItems.Add(hbmLegacyClass);
          hbmLegacyClass.name = Name.GetLegacyAssemblyQualifiedName(FullName);

          hbmLegacyClass.meta =
            new HbmMeta[]
              {
                new HbmMeta
                  {
                    attribute = EntityTypeAttribute,
                    Text = new string[] {EntityType.Legacy.ToString()}
                  }
              };

          hbmLegacyClass.table = GetCompoundTableName();
          Check.Require(!String.IsNullOrEmpty(hbmClass.table),
                        String.Format("Cannot find table name for legacy entity '{0}'", FullName));


          // Create <composite-id>
          var compositeId = new HbmCompositeId();
          var primaryKeys = new List<object>();

          foreach (Property legacyPrimaryKey in legacyPrimaryKeys)
          {
            primaryKeys.Add
              (new HbmKeyProperty()
                 {
                   name = legacyPrimaryKey.Name,
                   column1 = legacyPrimaryKey.DbColumnMetadata.ColumnName,
                   type1 = legacyPrimaryKey.IsEnum ? "System.Int32" : legacyPrimaryKey.AssemblyQualifiedTypeName,
                   length = Convert.ToString(legacyPrimaryKey.DbColumnMetadata.MaxLength)
                 }
              );

          }

          compositeId.Items = primaryKeys.ToArray();
          hbmLegacyClass.Item = compositeId;

          List<Property> legacyProperties = Properties.FindAll(p => p.IsCompound && !p.IsLegacyPrimaryKey);
          var hbmLegacyProperties = new List<object>();
          foreach (Property legacyProperty in legacyProperties)
          {
            hbmLegacyProperties.Add
              (new HbmProperty()
                 {
                   name = legacyProperty.Name,
                   column = legacyProperty.DbColumnMetadata.ColumnName,
                   length = Convert.ToString(legacyProperty.DbColumnMetadata.MaxLength),
                   type =
                     new HbmType() { name = legacyProperty.IsEnum ? "System.Int32" : legacyProperty.AssemblyQualifiedTypeName }
                 });
          }

          hbmLegacyClass.Items = hbmLegacyProperties.ToArray();
          hbmMapping.AddHbmClass(hbmLegacyClass);
        }

        #endregion

      #endregion

      return hbmMapping;
    }

    protected virtual List<HbmMeta> GetMetaAttributes()
    {
      var hbmMetaList = new List<HbmMeta>();
      foreach (string attributeName in MetaAttributes.Keys)
      {
        MetaAttribute metaAttribute = MetaAttributes[attributeName];

        if (metaAttribute.Values.Count > 0)
        {
          foreach (string value in metaAttribute.Values)
          {
            var hbmMeta = new HbmMeta();
            hbmMeta.attribute = attributeName;
            hbmMeta.Text = new[] { value };
            hbmMetaList.Add(hbmMeta);
          }
        }
        else
        {
          var hbmMeta = new HbmMeta();
          hbmMeta.attribute = attributeName;
          hbmMeta.Text = new[] { metaAttribute.Value };
          hbmMetaList.Add(hbmMeta);
        }
      }

      // Add attributes for compound properties
      if (EntityType == EntityType.Compound)
      {
        var compoundProperties = Properties.FindAll(p => p.IsCompound);
        foreach (Property compoundProperty in compoundProperties)
        {
          var hbmMeta = new HbmMeta();
          hbmMeta.attribute = CompoundPropertyAttribute;
          hbmMeta.Text = new[] { compoundProperty.DbColumnMetadata.ToHbmString() };
          hbmMetaList.Add(hbmMeta);
        }
      }

      return hbmMetaList;
    }

    protected virtual HbmVersion CreateHbmVersion()
    {
      var hbmVersion =
        new HbmVersion()
         {
           name = Property.VersionPropertyName,
           column1 = Property.VersionPropertyColumnName
         };

      return hbmVersion;
    }

    internal virtual HbmComponent CreateBusinessKeyHbmComponent()
    {
      var hbmComponent = new HbmComponent();
      var items = new List<object>();

      if (InternalBusinessKey)
      {
        HbmProperty hbmProperty = CreateInternalBusinessKeyHbmProperty();
        if (EntityType == EntityType.History)
        {
          hbmProperty.unique = false;
        }
        items.Add(hbmProperty);
      }
      else
      {
        foreach (Property property in Properties)
        {
          if (property.IsBusinessKey)
          {
            HbmProperty hbmProperty = property.CreateHbmProperty();
            if (EntityType == EntityType.History)
            {
              hbmProperty.unique = false;
              hbmProperty.uniquekey = null; //CORE-5770 no unique keys on history tables
            }
            items.Add(hbmProperty);
          }
        }
      }


      hbmComponent.Items = items.ToArray();
      hbmComponent.name = BusinessKeyPropertyName;
      hbmComponent.@class = Name.GetEntityBusinessKeyAssemblyQualifiedName(FullName);
      hbmComponent.meta =
        new[]
          {
            new HbmMeta
              {
                attribute = Property.BusinessKeyAttribute,
                Text = new string[] {"true"}
              },
            new HbmMeta
            {
              attribute = Property.InternalBusinessKeyAttribute,
              Text = new string[] { InternalBusinessKey ? "true" : "false" }
            }
          };

      return hbmComponent;
    }

    protected virtual List<ErrorObject> SetupAttributes(Dictionary<string, MetaAttribute> metaAttributes)
    {
      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;

      metaAttributes.TryGetValue(DescriptionAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        Description = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(LabelAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        Label = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(PluralNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        PluralName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(DatabaseAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        DatabaseName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(CustomBaseClassNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        CustomBaseClassName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(RecordHistoryAttribute, out metaAttribute);
      if (metaAttribute != null && !String.IsNullOrEmpty(metaAttribute.Value))
      {
        RecordHistory = Convert.ToBoolean(metaAttribute.Value);
      }

      metaAttributes.TryGetValue(MetraNetEntityAssociationAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        MetaAttribute metranetEntityAssociationAttribute =
          MetaAttributes[MetraNetEntityAssociationAttribute];
        metranetEntityAssociationAttribute.Values.AddRange(metaAttribute.Values);
      }

      return errors;
    }

    protected virtual void SetTypeData(string fullName)
    {
      Initialize();

      string className, nameSpace, extensionName, entityGroupName, assemblyName, assemblyQualifiedName;

      Name.GetPartsOfName(fullName,
                          out className,
                          out nameSpace,
                          out extensionName,
                          out entityGroupName,
                          out assemblyName,
                          out assemblyQualifiedName);

      ClassName = className;
      Namespace = nameSpace;
      ExtensionName = extensionName;
      EntityGroupName = entityGroupName;
      EntityGroupData = new EntityGroupData(ExtensionName, EntityGroupName);
      FullName = fullName;
      AssemblyName = assemblyName;
      AssemblyQualifiedName = assemblyQualifiedName;
      EntityType = EntityType.Entity;
    }

    protected virtual void Initialize()
    {
      Label = String.Empty;
      Description = String.Empty;
      DatabaseName = "NetMeter";
      Properties = new List<Property>();
      MetaAttributes = new Dictionary<string, MetaAttribute>();
      PreDefinedProperties = new List<Property>();

      var versionProperty = new Property(this, Property.VersionPropertyName, "int", false);
      versionProperty.ColumnName = "c_" + Property.VersionPropertyName;
      versionProperty.IsRequired = true;
      versionProperty.Entity = this;
      PreDefinedProperties.Add(versionProperty);

      var creationDateProperty = new Property(this, Property.CreationDatePropertyName, "DateTime", false);
      creationDateProperty.ColumnName = "c_" + Property.CreationDatePropertyName;
      creationDateProperty.IsRequired = false;
      creationDateProperty.Entity = this;
      PreDefinedProperties.Add(creationDateProperty);

      var updateDateProperty = new Property(this, Property.UpdateDatePropertyName, "DateTime", false);
      updateDateProperty.ColumnName = "c_" + Property.UpdateDatePropertyName;
      updateDateProperty.IsRequired = false;
      updateDateProperty.Entity = this;
      PreDefinedProperties.Add(updateDateProperty);

      var uidProperty = new Property(this, Property.UIDPropertyName, "int", false);
      uidProperty.ColumnName = "c_" + Property.UIDPropertyName;
      uidProperty.IsRequired = false;
      uidProperty.Entity = this;
      PreDefinedProperties.Add(uidProperty);

      //new List<Property>()
      //    {
      //      new Property(Property.VersionPropertyName, "int") {IsRequired = true, ColumnName = }
      //      //new Property(Property.ExtensionNamePropertyName, "string") {IsRequired = true},
      //      //new Property(Property.EntityGroupNamePropertyName, "string") {IsRequired = true},
      //      //new Property(Property.EntityFullNamePropertyName, "string") {IsRequired = true},
      //      //new Property(Property.EntityNamePropertyName, "string") {IsRequired = true}
      //    };

      Relationships = new List<Relationship>();
      InternalBusinessKey = true;
      InitializeClassAttributes();
      LocalizedLabels = new List<LocalizedEntry>();
      HbmDatabaseObjects = new List<HbmDatabaseObject>();
    }

    protected virtual void InitializeClassAttributes()
    {
      MetaAttributes.Add(DescriptionAttribute, new MetaAttribute());
      MetaAttributes.Add(LabelAttribute, new MetaAttribute());
      MetaAttributes.Add(PluralNameAttribute, new MetaAttribute());
      MetaAttributes.Add(DatabaseAttribute, new MetaAttribute());
      MetaAttributes.Add(CustomBaseClassNameAttribute, new MetaAttribute());
      MetaAttributes.Add(RecordHistoryAttribute, new MetaAttribute());
      // MetaAttributes.Add(HasSelfRelationshipAttribute, new MetaAttribute());
      MetaAttributes.Add(EntityTypeAttribute, new MetaAttribute());
      MetaAttributes.Add(InterfaceAttribute, new MetaAttribute());
      MetaAttributes.Add(MetraNetEntityAssociationAttribute, new MetaAttribute());

    }

    protected virtual void UpdateClassAttributes()
    {
      MetaAttributes[DescriptionAttribute].Value = Description;
      MetaAttributes[LabelAttribute].Value = Label;
      MetaAttributes[PluralNameAttribute].Value = PluralName;
      MetaAttributes[DatabaseAttribute].Value = DatabaseName;
      MetaAttributes[CustomBaseClassNameAttribute].Value = CustomBaseClassName;
      MetaAttributes[RecordHistoryAttribute].Value = RecordHistory ? "true" : "false";
      // MetaAttributes[HasSelfRelationshipAttribute].Value = HasSelfRelationship ? "true" : "false";
      MetaAttributes[EntityTypeAttribute].Value = EntityType.ToString();
      MetaAttributes[InterfaceAttribute].Value = Name.GetInterfaceAssemblyQualifiedName(FullName);
    }

    protected static HbmProperty CreateInternalBusinessKeyHbmProperty()
    {
      HbmProperty hbmProperty =
        new HbmProperty()
        {
          name = "InternalKey",
          column = "c_internal_key",
          meta =
            new HbmMeta[]
                {
                  new HbmMeta
                    {
                      attribute = Property.LabelAttribute,
                      Text = new string[] { "Internal Business Key" }
                    },
                  new HbmMeta
                    {
                      attribute = Property.DescriptionAttribute,
                      Text = new string[] {String.Empty}
                    },
                  new HbmMeta
                    {
                      attribute = Property.DefaultValueAttribute,
                      Text = new string[] {String.Empty}
                    },
                  new HbmMeta
                    {
                      attribute = Property.SortableAttribute,
                      Text = new string[] {"true"}
                    },
                  new HbmMeta
                    {
                      attribute = Property.SearchableAttribute,
                      Text = new string[] {"true" }
                    },
                  new HbmMeta
                    {
                      attribute = Property.AssociationEntityNameAttribute,
                      Text = new string[] {String.Empty}
                    },
                  new HbmMeta
                    {
                      attribute = Property.EncryptedAttribute,
                      Text = new string[] {"false" }
                    }
                  
                }
        };

      hbmProperty.type = new HbmType() { name = "System.Guid" };
      hbmProperty.unique = true;
      hbmProperty.notnull = true;
      hbmProperty.notnullSpecified = true;

      return hbmProperty;
    }

    internal virtual string GetClassNameSectionForTable()
    {
      string classNameSection = ClassName;
      if (classNameSection.Length > 15)
      {
        classNameSection = classNameSection.Substring(0, 14);
      }

      return classNameSection;
    }

    public static HbmMapping GetHbmMapping(string hbmFile)
    {
      Check.Require(File.Exists(hbmFile), String.Format("Cannot find hbmFile '{0}'", hbmFile));

      var serializer = new XmlSerializer(typeof(HbmMapping));
      HbmMapping hbmMapping = null;

      using (FileStream fileStream = File.Open(hbmFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
      {
        using (var xtr = new XmlTextReader(fileStream))
        {
          xtr.WhitespaceHandling = WhitespaceHandling.All;
          hbmMapping = (HbmMapping)serializer.Deserialize(xtr);
        }
      }

      Check.Ensure(hbmMapping != null, String.Format("Cannot find deserialize file '{0}'", hbmFile));

      return hbmMapping;
    }
    #endregion

    #region Private Methods
    protected virtual void GetNewAndChangedProperties(Entity newEntity,
                                                      DbTableMetadata originalEntityMetadata,
                                                      out Dictionary<DbColumnMetadata, Property> modifiedProperties,
                                                      out List<Property> newProperties)
    {
      Check.Require(newEntity != null, "newEntity cannot be null");
      Check.Require(originalEntityMetadata != null, "originalEntityMetadata cannot be null");

      modifiedProperties = new Dictionary<DbColumnMetadata, Property>();
      newProperties = new List<Property>();

      foreach (Property property in newEntity.Properties)
      {
        DbColumnMetadata dbColumnMetadata =
          originalEntityMetadata.ColumnMetadataList.Find(c => c.ColumnName.ToLowerInvariant() ==
                                                         property.ColumnName.ToLowerInvariant());

        // If the property in the new entity is found in the column metadata, then it's not a new property
        if (dbColumnMetadata != null)
        {
          modifiedProperties.Add(dbColumnMetadata, property);
        }
        else
        {
          newProperties.Add(property);
        }
      }
    }


    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("Entity");
    public const string DescriptionAttribute = "description";
    public const string CategoryAttribute = "category";
    public const string LabelAttribute = "label";
    public const string PluralNameAttribute = "plural-name";
    public const string RecordHistoryAttribute = "record-history";
    public const string EntityTypeAttribute = "entity-type";
    public const string MetraNetEntityAssociationAttribute = "metranet-entity-association";
    public const string InterfaceAttribute = "interface";
    public const string TargetEntityAttribute = "target-entity";
    public const string CompoundPropertyAttribute = "compound-property";
    public const string DatabaseAttribute = "database";
    public const string CustomBaseClassNameAttribute = "custom-base-class-name";

    internal static readonly List<string> CollectionMetaAttributes =
      new List<string>() { MetraNetEntityAssociationAttribute, CompoundPropertyAttribute };

    #endregion
  }

  [Flags]
  public enum Category
  {
    ConfigDriven = 0x01,
    CodeDriven = 0x02,
    System = 0x04,  // Used by the system. Can create schema. Not displayed in ICE. 
    Legacy = 0x08   // Points to legacy tables. Cannot create schema via BE. Not displayed in ICE.
  }

  [Flags]
  public enum EntityType
  {
    None = 0x0,
    Entity = 0x01,
    Relationship = 0x02,
    SelfRelationship = 0x04,
    History = 0x08,
    Compound = 0x10,
    Legacy = 0x20,
    Derived = 0x40
  }

  internal static class HbmMappingExtension
  {
    /// <summary>
    ///    Extension method must
    ///    (1) Be in a static class.
    ///    (2) Have atleast one parameter prefixed with 'this'. Cannot be out/ref.
    /// </summary>
    /// <param name="hbmMapping"></param>
    /// <param name="attributeName"></param>
    /// <param name="errorObject"></param>
    /// <returns></returns>
    internal static Category GetCategoryMetadata(this HbmMapping hbmMapping, string attributeName, out ErrorObject errorObject)
    {
      string categoryName = String.Empty;
      errorObject = null;

      Category category = Category.CodeDriven;

      if (hbmMapping.meta == null)
      {
        return category;
      }

      foreach (HbmMeta hbmMeta in hbmMapping.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          Entity.logger.Debug(String.Format("Category metadata attribute not specified for HbmMapping '{0}'", hbmMapping.@namespace + ", " + hbmMapping.assembly));
        }
        else
        {
          categoryName = hbmMeta.GetText();
        }

        break;
      }

      try
      {
        category =
          String.IsNullOrEmpty(categoryName) ? Category.CodeDriven : (Category)Enum.Parse(typeof(Category), categoryName);
      }
      catch (System.Exception e)
      {
        string errorMessage =
              String.Format("Cannot create Category from value '{0}'. Exception message: '{1}'", categoryName, e.Message);
        errorObject = new ErrorObject(errorMessage, SystemConfig.CallerInfo);
        Entity.logger.Error(errorMessage);
      }

      return category;
    }

    /// <summary>
    ///   Return the EntityType for the contained item
    /// </summary>
    /// <param name="hbmMapping"></param>
    /// <returns></returns>
    internal static EntityType GetEntityType(this HbmMapping hbmMapping)
    {
      EntityType entityType = EntityType.None;

      foreach (object item in hbmMapping.Items)
      {
        if (item is HbmClass)
        {
          string entityTypeValue = ((HbmClass)item).GetMetadata(Entity.EntityTypeAttribute);
          if (String.IsNullOrEmpty(entityTypeValue))
          {
            entityType = EntityType.Entity;
          }
          else
          {
            entityType = (EntityType)Enum.Parse(typeof(EntityType), entityTypeValue);
          }
          break;
        }

        if (item is HbmJoinedSubclass)
        {
          entityType = EntityType.Derived;
          break;
        }
      }

      return entityType;
    }

    internal static List<HbmDatabaseObject> GetHbmDatabaseObjects(this HbmMapping hbmMapping)
    {
      var hbmDatabaseObjects = new List<HbmDatabaseObject>();
      if (hbmMapping.databaseobject != null)
      {
        return hbmMapping.databaseobject.ToList();
      }

      return hbmDatabaseObjects;
    }

    internal static void AddHbmClass(this HbmMapping hbmMapping, HbmClass hbmClass)
    {
      Check.Require(hbmClass != null, "hbmClass cannot be null");
      List<object> hbmMappingItems = hbmMapping.Items != null ? hbmMapping.Items.ToList() : new List<object>();
      hbmMappingItems.Add(hbmClass);
      hbmMapping.Items = hbmMappingItems.ToArray();
    }

    internal static void AddHbmDatabaseObject(this HbmMapping hbmMapping, HbmDatabaseObject hbmDatabaseObject)
    {
      Check.Require(hbmDatabaseObject != null, "hbmDatabaseObject cannot be null");
      List<HbmDatabaseObject> hbmDatabaseObjects = hbmMapping.databaseobject != null ? hbmMapping.databaseobject.ToList() : new List<HbmDatabaseObject>();
      hbmDatabaseObjects.Add(hbmDatabaseObject);
      hbmMapping.databaseobject = hbmDatabaseObjects.ToArray();
    }

    /// <summary>
    ///   Return true if the specified triggerName matches an existing HbmDatabaseObject
    /// </summary>
    /// <param name="hbmMapping"></param>
    /// <param name="triggerName"></param>
    /// <returns></returns>
    internal static bool RemoveTriggerHbmDatabaseObject(this HbmMapping hbmMapping, string triggerName)
    {
      Check.Require(!String.IsNullOrEmpty(triggerName), "triggerName cannot be null or empty");
      List<HbmDatabaseObject> hbmDatabaseObjects = hbmMapping.databaseobject != null ? hbmMapping.databaseobject.ToList() : new List<HbmDatabaseObject>();
      var deletedItems = new List<HbmDatabaseObject>();

      foreach (HbmDatabaseObject hbmDatabaseObject in hbmDatabaseObjects)
      {
        if (hbmDatabaseObject.FindCreateText().ToLower().Contains(triggerName.ToLower()))
        {
          deletedItems.Add(hbmDatabaseObject);
        }
      }

      deletedItems.ForEach(d => hbmDatabaseObjects.Remove(d));
      hbmMapping.databaseobject = hbmDatabaseObjects.ToArray();

      return deletedItems.Count > 0;
    }
  }

  public static class HbmClassExtension
  {
    internal static void SetIdColumnName(this HbmClass hbmClass, string columnName)
    {
      HbmId hbmId = hbmClass.Item as HbmId;
      Check.Require(hbmId != null, "hbmId cannot be null");
      hbmId.column1 = columnName;
    }

    internal static void MakeAllPropertiesNonUnique(this HbmClass hbmClass)
    {
      foreach (object item in hbmClass.Items)
      {
        // Get BusinessKey properties from HbmComponent
        if (item is HbmComponent)
        {
          HbmComponent hbmComponent = item as HbmComponent;
          foreach (HbmProperty hbmProperty in hbmComponent.Items)
          {
            hbmProperty.unique = false;
          }
        }
        else
        {
          if (item is HbmProperty)
          {
            ((HbmProperty)item).unique = false;
          }
        }
      }
    }

    internal static List<HbmProperty> GetHbmProperties(this HbmClass hbmClass)
    {
      var hbmProperties = new List<HbmProperty>();

      foreach (object item in hbmClass.Items)
      {
        // Get BusinessKey properties from HbmComponent
        if (item is HbmComponent)
        {
          var hbmComponent = item as HbmComponent;
          hbmProperties.AddRange(hbmComponent.Items.Cast<HbmProperty>());
        }
        else
        {
          if (item is HbmProperty)
          {
            hbmProperties.Add(item as HbmProperty);
          }
        }
      }

      return hbmProperties;
    }

    internal static void RemoveHbmProperty(this HbmClass hbmClass, string propertyName)
    {
      List<object> items = hbmClass.Items.ToList();
      items.RemoveAll(i => i is HbmProperty && ((HbmProperty)i).name.ToLower() == propertyName.ToLower());
      hbmClass.Items = items.ToArray();
    }

    internal static EntityType GetEntityType(this HbmClass hbmClass)
    {
      string attributeValue = hbmClass.GetMetadata(Entity.EntityTypeAttribute);
      if (!String.IsNullOrEmpty(attributeValue))
      {
        return (EntityType)Enum.Parse(typeof(EntityType), attributeValue);
      }

      attributeValue = hbmClass.GetMetadata(RelationshipEntity.RelationshipTypeAttribute);
      if (!String.IsNullOrEmpty(attributeValue))
      {
        return EntityType.Relationship;
      }

      return EntityType.Entity;
    }

    internal static Dictionary<string, MetaAttribute> GetMetaAttributes(this HbmClass hbmClass)
    {
      var metaAttributes = new Dictionary<string, MetaAttribute>();

      if (hbmClass.meta == null)
      {
        return metaAttributes;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          continue;
        }

        MetaAttribute metaAttribute;
        metaAttributes.TryGetValue(hbmMeta.attribute, out metaAttribute);
        if (metaAttribute == null)
        {
          metaAttribute = new MetaAttribute() { Name = hbmMeta.attribute };
          metaAttributes.Add(metaAttribute.Name, metaAttribute);
        }

        if (Entity.CollectionMetaAttributes.Contains(hbmMeta.attribute))
        {
          metaAttribute.Values.Add(hbmMeta.GetText());
        }
        else
        {
          metaAttribute.Value = hbmMeta.GetText();
        }
      }

      return metaAttributes;
    }

    internal static Dictionary<string, MetaAttribute> GetMetaAttributes(this HbmJoinedSubclass hbmClass)
    {
      var metaAttributes = new Dictionary<string, MetaAttribute>();

      if (hbmClass.meta == null)
      {
        return metaAttributes;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          continue;
        }

        MetaAttribute metaAttribute;
        metaAttributes.TryGetValue(hbmMeta.attribute, out metaAttribute);
        if (metaAttribute == null)
        {
          metaAttribute = new MetaAttribute() { Name = hbmMeta.attribute };
          metaAttributes.Add(metaAttribute.Name, metaAttribute);
        }

        if (Entity.CollectionMetaAttributes.Contains(hbmMeta.attribute))
        {
          metaAttribute.Values.Add(hbmMeta.GetText());
        }
        else
        {
          metaAttribute.Value = hbmMeta.GetText();
        }
      }

      return metaAttributes;
    }

    /// <summary>
    ///    Extension method must
    ///    (1) Be in a static class.
    ///    (2) Have atleast one parameter prefixed with 'this'. Cannot be out/ref.
    /// </summary>
    /// <param name="hbmClass"></param>
    /// <param name="attributeName"></param>
    /// <returns></returns>
    public static string GetMetadata(this HbmClass hbmClass, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmClass.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        attributeValue = hbmMeta.GetText();

        break;
      }

      return attributeValue;
    }

    internal static Dictionary<string, Multiplicity> GetMetranetEntities(this HbmClass hbmClass, out List<ErrorObject> errorObjects)
    {
      errorObjects = new List<ErrorObject>();
      var metranetEntities = new Dictionary<string, Multiplicity>();

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (!hbmMeta.attribute.Equals("metranet-entity-association", StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          continue;
        }

        string[] splits =
          hbmMeta.Text[0].Split(new string[] { "::" }, StringSplitOptions.RemoveEmptyEntries);

        // Validate
        if (splits.Length != 2)
        {
          string errorMessage = String.Format("Expected metadata '{0}' to have two items separated by '::'",
                                              hbmMeta.Text[0]);
          errorObjects.Add(new ErrorObject(errorMessage, SystemConfig.CallerInfo));
          Entity.logger.Error(errorMessage);
          continue;
        }

        // Get the assembly qualified name
        AssemblyQualifiedTypeName assemblyQualifiedName;
        Multiplicity multiplicity;

        try
        {
          assemblyQualifiedName = TypeNameParser.Parse(splits[0]);
          if (assemblyQualifiedName == null)
          {
            string errorMessage = String.Format("Expected metadata '{0}' to have an assembly qualified name followed by '::'",
                                                hbmMeta.Text[0]);
            errorObjects.Add(new ErrorObject(errorMessage, SystemConfig.CallerInfo));
            Entity.logger.Error(errorMessage);
            continue;
          }
        }
        catch (System.Exception e)
        {
          string errorMessage = String.Format("Expected metadata '{0}' to have an assembly qualified name followed by '::'",
                                               hbmMeta.Text[0]);
          errorObjects.Add(new ErrorObject(errorMessage, SystemConfig.CallerInfo));
          Entity.logger.Error(errorMessage, e);
          continue;
        }


        try
        {
          multiplicity = (Multiplicity)Enum.Parse(typeof(Multiplicity), splits[1]);
        }
        catch (System.Exception e)
        {
          string errorMessage = String.Format("Expected metadata '{0}' to have One or Many following the '::'",
                                               hbmMeta.Text[0]);
          errorObjects.Add(new ErrorObject(errorMessage, SystemConfig.CallerInfo));
          Entity.logger.Error(errorMessage, e);
          continue;
        }

        metranetEntities.Add(assemblyQualifiedName.Type + ", " + assemblyQualifiedName.Assembly, multiplicity);

      }

      return metranetEntities;
    }

    public static List<HbmBag> GetHbmBags(this HbmClass hbmClass)
    {
      return hbmClass.Items.OfType<HbmBag>().ToList();
    }

    public static HbmBag GetHbmBag(this HbmClass hbmClass, string joinClassName)
    {
      return hbmClass.Items.OfType<HbmBag>().Where(h => h.GetJoinClassName() == joinClassName).SingleOrDefault();
    }

    public static List<HbmBag> GetSelfRelationshipHbmBags(this HbmClass hbmClass, string joinClassName)
    {
      return hbmClass.Items.OfType<HbmBag>().Where(h => h.GetJoinClassName() == joinClassName).ToList();
    }

    public static void DeleteHbmBag(this HbmClass hbmClass, string joinClassName)
    {
      List<object> items = hbmClass.Items.ToList();
      items.RemoveAll(i => i is HbmBag && ((HbmBag)i).GetJoinClassName() == joinClassName);
      hbmClass.Items = items.ToArray();
    }

    public static void AddItem(this HbmClass hbmClass, object item)
    {
      List<object> items = hbmClass.Items.ToList();
      items.Add(item);
      hbmClass.Items = items.ToArray();
    }

    public static List<RelationshipEntity> GetRelationships(this HbmClass hbmClass, out List<string> legacyRelationships)
    {
      var relationshipEntities = new List<RelationshipEntity>();
      legacyRelationships = new List<string>();
      List<string> tmpRelationships = null;

      // HbmBag
      List<HbmBag> hbmBags = hbmClass.Items.OfType<HbmBag>().ToList();
      foreach (HbmBag hbmBag in hbmBags)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmBag, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      // HbmManyToOne
      List<HbmManyToOne> hbmManyToOnes = hbmClass.Items.OfType<HbmManyToOne>().ToList();
      foreach (HbmManyToOne hbmManyToOne in hbmManyToOnes)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmManyToOne, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      // HbmOneToOne
      List<HbmOneToOne> hbmOneToOnes = hbmClass.Items.OfType<HbmOneToOne>().ToList();
      foreach (HbmOneToOne hbmOneToOne in hbmOneToOnes)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmOneToOne, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      return relationshipEntities;
    }
  }

  public static class HbmJoinedSubclassExtension
  {
    internal static void RemoveHbmProperty(this HbmJoinedSubclass hbmClass, string propertyName)
    {
      List<object> items = hbmClass.Items.ToList();
      items.RemoveAll(i => i is HbmProperty && ((HbmProperty)i).name.ToLower() == propertyName.ToLower());
      hbmClass.Items = items.ToArray();
    }

    public static string GetMetadata(this HbmJoinedSubclass hbmClass, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmClass.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmClass.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        attributeValue = hbmMeta.GetText();

        break;
      }

      return attributeValue;
    }

    public static HbmBag GetHbmBag(this HbmJoinedSubclass hbmClass, string joinClassName)
    {
      return hbmClass.Items.OfType<HbmBag>().Where(h => h.GetJoinClassName() == joinClassName).SingleOrDefault();
    }

    public static List<HbmBag> GetHbmBags(this HbmJoinedSubclass hbmJoinedSubclass)
    {
      return hbmJoinedSubclass.Items.OfType<HbmBag>().ToList();
    }

    public static List<RelationshipEntity> GetRelationships(this HbmJoinedSubclass hbmClass, out List<string> legacyRelationships)
    {
      var relationshipEntities = new List<RelationshipEntity>();
      legacyRelationships = new List<string>();
      List<string> tmpRelationships = null;

      // HbmBag
      List<HbmBag> hbmBags = hbmClass.Items.OfType<HbmBag>().ToList();
      foreach (HbmBag hbmBag in hbmBags)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmBag, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      // HbmManyToOne
      List<HbmManyToOne> hbmManyToOnes = hbmClass.Items.OfType<HbmManyToOne>().ToList();
      foreach (HbmManyToOne hbmManyToOne in hbmManyToOnes)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmManyToOne, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      // HbmOneToOne
      List<HbmOneToOne> hbmOneToOnes = hbmClass.Items.OfType<HbmOneToOne>().ToList();
      foreach (HbmOneToOne hbmOneToOne in hbmOneToOnes)
      {
        relationshipEntities.AddRange(HbmRelationshipHelper.GetRelationships(hbmOneToOne, out tmpRelationships));
        legacyRelationships.AddRange(tmpRelationships);
      }

      return relationshipEntities;
    }

    public static void AddItem(this HbmJoinedSubclass hbmClass, object item)
    {
      List<object> items = hbmClass.Items.ToList();
      items.Add(item);
      hbmClass.Items = items.ToArray();
    }

    public static void DeleteHbmBag(this HbmJoinedSubclass hbmClass, string joinClassName)
    {
      List<object> items = hbmClass.Items.ToList();
      items.RemoveAll(i => i is HbmBag && ((HbmBag)i).GetJoinClassName() == joinClassName);
      hbmClass.Items = items.ToArray();
    }

    internal static List<HbmProperty> GetHbmProperties(this HbmJoinedSubclass hbmClass)
    {
      var hbmProperties = new List<HbmProperty>();

      foreach (object item in hbmClass.Items)
      {
        // Get BusinessKey properties from HbmComponent
        if (item is HbmComponent)
        {
          var hbmComponent = item as HbmComponent;
          hbmProperties.AddRange(hbmComponent.Items.Cast<HbmProperty>());
        }
        else
        {
          if (item is HbmProperty)
          {
            hbmProperties.Add(item as HbmProperty);
          }
        }
      }

      return hbmProperties;
    }
  }

  public static class HbmRelationshipHelper
  {
    public static List<RelationshipEntity> GetRelationships(dynamic hbmRelationship, out List<string> legacyRelationships)
    {
      legacyRelationships = new List<string>();
      var relationshipEntities = new List<RelationshipEntity>();

      if (hbmRelationship.meta == null)
        return relationshipEntities;

      RelationshipEntity relationshipEntity = null;
      var metaAttributeNameValues = new Dictionary<string, string>();

      foreach (HbmMeta hbmMeta in hbmRelationship.meta)
      {
        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        // If we find 'target-entity' then it's a legacy relationship and we're done
        if (hbmMeta.attribute == "target-entity")
        {
          Check.Require(!String.IsNullOrEmpty(hbmMeta.Text[0]),
                        String.Format("Cannot find value for target-entity on '{0}'", hbmRelationship.name));
          legacyRelationships.Add(hbmMeta.Text[0]);
          break;
        }

        metaAttributeNameValues.Add(hbmMeta.attribute, hbmMeta.Text[0]);
      }

      if (legacyRelationships.Count == 0)
      {
        // Create a relationship entity
        relationshipEntity = new RelationshipEntity(metaAttributeNameValues);
        relationshipEntities.Add(relationshipEntity);
      }

      return relationshipEntities;
    }
  }

  public static class HbmBagExtension
  {
    public static string GetMetadata(this HbmBag hbmBag, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmBag.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmBag.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        attributeValue = hbmMeta.GetText();

        break;
      }

      return attributeValue;
    }

    /// <summary>
    ///   Replace the value for the specified attribute if it exists. Add it, if it doesn't.
    /// </summary>
    /// <param name="hbmBag"></param>
    /// <param name="attributeName"></param>
    /// <param name="attributeValue"></param>
    public static void SetAttributeValue(this HbmBag hbmBag, string attributeName, string attributeValue)
    {
      HbmMeta hbmMeta = hbmBag.meta == null ? null : hbmBag.meta.Where(m => m.attribute == attributeName).FirstOrDefault();
      if (hbmMeta != null)
      {
        hbmMeta.Text = new[] { attributeValue };
      }
      else
      {
        hbmMeta = new HbmMeta { attribute = attributeName, Text = new[] { attributeValue } };
        List<HbmMeta> items = hbmBag.meta == null ? new List<HbmMeta>() : hbmBag.meta.ToList();
        items.Add(hbmMeta);
        hbmBag.meta = items.ToArray();
      }
    }

    public static void RemoveAttribute(this HbmBag hbmBag, string attributeName)
    {
      HbmMeta hbmMeta = hbmBag.meta == null ? null : hbmBag.meta.Where(m => m.attribute == attributeName).FirstOrDefault();
      if (hbmMeta != null)
      {
        List<HbmMeta> items = hbmBag.meta.ToList();
        items.RemoveAll(i => i.attribute == attributeName);
        hbmBag.meta = items.ToArray();
      }
    }

    public static bool IsLegacy(this HbmBag hbmBag)
    {
      string joinTableAttributeValue = hbmBag.GetMetadata(RelationshipEntity.HasJoinTableAttribute);

      // Did not find has-join-table attribute, must be legacy
      if (String.IsNullOrEmpty(joinTableAttributeValue))
      {
        return true;
      }

      return false;
    }

    public static string GetJoinClassName(this HbmBag hbmBag)
    {
      AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(((HbmOneToMany)hbmBag.Item).@class);
      return assemblyQualifiedTypeName.Type;
    }
  }

  public static class HbmManyToOneExtension
  {
    public static string GetMetadata(this HbmManyToOne hbmManyToOne, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmManyToOne.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmManyToOne.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        attributeValue = hbmMeta.GetText();

        break;
      }

      return attributeValue;
    }

    /// <summary>
    ///   Replace the value for the specified attribute if it exists. Add it, if it doesn't.
    /// </summary>
    /// <param name="hbmManyToOne"></param>
    /// <param name="attributeName"></param>
    /// <param name="attributeValue"></param>
    public static void SetAttributeValue(this HbmManyToOne hbmManyToOne, string attributeName, string attributeValue)
    {
      HbmMeta hbmMeta = hbmManyToOne.meta == null ? null : hbmManyToOne.meta.Where(m => m.attribute == attributeName).FirstOrDefault();
      if (hbmMeta != null)
      {
        hbmMeta.Text = new[] { attributeValue };
      }
      else
      {
        hbmMeta = new HbmMeta { attribute = attributeName, Text = new[] { attributeValue } };
        List<HbmMeta> items = hbmManyToOne.meta == null ? new List<HbmMeta>() : hbmManyToOne.meta.ToList();
        items.Add(hbmMeta);
        hbmManyToOne.meta = items.ToArray();
      }
    }


  }

  public static class HbmOneToOneExtension
  {
    public static string GetMetadata(this HbmOneToOne hbmOneToOne, string attributeName)
    {
      string attributeValue = String.Empty;

      if (hbmOneToOne.meta == null)
      {
        return attributeValue;
      }

      foreach (HbmMeta hbmMeta in hbmOneToOne.meta)
      {
        if (!hbmMeta.attribute.Equals(attributeName, StringComparison.InvariantCultureIgnoreCase))
        {
          continue;
        }

        if (hbmMeta.Text == null || hbmMeta.Text.Length == 0 || String.IsNullOrEmpty(hbmMeta.Text[0]))
        {
          // Entity.logger.Debug(String.Format("No '{0}' specified for property '{1}'", attributeName, hbmClass.name));
          continue;
        }

        attributeValue = hbmMeta.GetText();

        break;
      }

      return attributeValue;
    }

    /// <summary>
    ///   Replace the value for the specified attribute if it exists. Add it, if it doesn't.
    /// </summary>
    /// <param name="hbmOneToOne"></param>
    /// <param name="attributeName"></param>
    /// <param name="attributeValue"></param>
    public static void SetAttributeValue(this HbmOneToOne hbmOneToOne, string attributeName, string attributeValue)
    {
      HbmMeta hbmMeta = hbmOneToOne.meta == null ? null : hbmOneToOne.meta.Where(m => m.attribute == attributeName).FirstOrDefault();
      if (hbmMeta != null)
      {
        hbmMeta.Text = new[] { attributeValue };
      }
      else
      {
        hbmMeta = new HbmMeta { attribute = attributeName, Text = new[] { attributeValue } };
        List<HbmMeta> items = hbmOneToOne.meta == null ? new List<HbmMeta>() : hbmOneToOne.meta.ToList();
        items.Add(hbmMeta);
        hbmOneToOne.meta = items.ToArray();
      }
    }


  }
}
