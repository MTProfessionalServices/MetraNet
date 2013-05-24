using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Rule;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using NHibernate.Cfg;
using NHibernate.Mapping;
using NHibernate.Util;
using MetaAttribute=NHibernate.Mapping.MetaAttribute;
using Property=MetraTech.BusinessEntity.DataAccess.Metadata.Property;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public static class RuntimeMetadata
  {
    //public static List<ErrorObject> GetRelationshipType(string sourceTypeName, 
    //                                                    string targetTypeName, 
    //                                                    Configuration configuration,
    //                                                    out RelationshipType relationshipType)
    //{
    //  var errors = new List<ErrorObject>();

    //  RelationshipData relationshipData;
    //  errors.AddRange(GetRelationshipInfo(sourceTypeName,
    //                                      targetTypeName,
    //                                      configuration,
    //                                      out relationshipData));

    //  relationshipType = relationshipData.RelationshipType;


    //  return errors;
    //}

    public static List<string> GetCollectionPropertyNames(string typeName, Configuration configuration)
    {
      Check.Require(!String.IsNullOrEmpty(typeName), "typeName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(configuration != null, "configuration cannot be null", SystemConfig.CallerInfo);

      var propertyNames = new List<string>();

      PersistentClass persistentClass = configuration.GetClassMapping(typeName);
      Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", typeName));
      foreach (var element in persistentClass.PropertyIterator)
      {
        if (element.Type.IsAssociationType && element.Type.IsCollectionType)
        {
          propertyNames.Add(element.Name);
        }
      }

      return propertyNames;
    }

    //public static List<ErrorObject> GetRelationshipInfo(string sourceTypeName, 
    //                                                    string targetTypeName, 
    //                                                    Configuration configuration,
    //                                                    out RelationshipData relationshipData)
    //{
    //  var errors = new List<ErrorObject>();
    //  relationshipData = null;

    //  Check.Require(!String.IsNullOrEmpty(sourceTypeName), 
    //                "sourceTypeName cannot be null or empty",
    //                SystemConfig.CallerInfo);

    //  Check.Require(!String.IsNullOrEmpty(targetTypeName),
    //                "targetTypeName cannot be null or empty",
    //                SystemConfig.CallerInfo);

    //  Check.Require(configuration != null,
    //                "configuration cannot be null",
    //                SystemConfig.CallerInfo);


    //  PersistentClass persistentClass = configuration.GetClassMapping(sourceTypeName);
    //  Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", sourceTypeName));

    //  foreach (var element in persistentClass.PropertyIterator)
    //  {
    //    var bag = element.Value as Bag;
    //    if (bag == null) continue;

    //    // Get the 'target-entity' metaAttribute on this bag
    //    if (element.MetaAttributes == null)
    //    {
    //      var errorMessage =
    //        String.Format("Expected to find meta attribute '{0}' on relationship for entity '{1}'", Entity.TargetEntityAttribute, sourceTypeName);
    //      logger.Error(errorMessage);
    //      errors.Add(new ErrorObject(errorMessage));
    //      continue;
    //    }
        
    //    NHibernate.Mapping.MetaAttribute metaAttribute;
    //    element.MetaAttributes.TryGetValue(Entity.TargetEntityAttribute, out metaAttribute);
    //    if (metaAttribute == null || String.IsNullOrEmpty(metaAttribute.Value))
    //    {
    //      var errorMessage =
    //        String.Format("Expected to find meta attribute '{0}' on relationship for entity '{1}'", Entity.TargetEntityAttribute, sourceTypeName);
    //      logger.Error(errorMessage);
    //      errors.Add(new ErrorObject(errorMessage));
    //      continue;
    //    }

    //    if (metaAttribute.Value != targetTypeName) continue;

    //    // Found the relationship

    //    var oneToMany = bag.Element as OneToMany;
    //    if (oneToMany == null)
    //    {
    //      var errorMessage =
    //        String.Format("Expected to find one-to-many element on relationship for entity '{0}'", sourceTypeName);
    //      errors.Add(new ErrorObject(errorMessage));
    //      return errors;
    //    }

    //    if (oneToMany.AssociatedClass == null || String.IsNullOrEmpty(oneToMany.AssociatedClass.ClassName))
    //    {
    //      var errorMessage =
    //        String.Format("Expected to find one-to-many element with a class name on relationship for entity '{0}'", sourceTypeName);
    //      errors.Add(new ErrorObject(errorMessage));
    //      return errors;
    //    }

    //    AssemblyQualifiedTypeName assemblyQualifiedTypeName = TypeNameParser.Parse(oneToMany.AssociatedClass.ClassName);
    //    if (String.IsNullOrEmpty(assemblyQualifiedTypeName.Type))
    //    {
    //      var errorMessage =
    //        String.Format("Cannot parse assembly qualified name '{0}' for relationship on entity '{1}'", oneToMany.AssociatedClass.ClassName, sourceTypeName);
    //      errors.Add(new ErrorObject(errorMessage));
    //      return errors;
    //    }

    //    string relationshipEntityName = assemblyQualifiedTypeName.Type;

    //    // Get the relationship type
    //    errors.AddRange(GetRelationshipData(relationshipEntityName, configuration, out relationshipData));

    //    break;
    //  }

    //  return errors;
    //}

    //public static List<ErrorObject> GetRelationshipData(string relationshipEntityName, 
    //                                                    Configuration configuration, 
    //                                                    out RelationshipData relationshipData)
    //{
    //  relationshipData = new RelationshipData();
    //  relationshipData.RelationshipEntityName = relationshipEntityName;

    //  var errors = new List<ErrorObject>();

    //  // Get the metadata for the relationshipEntity
    //  PersistentClass relationshipEntity = configuration.GetClassMapping(relationshipEntityName);
    //  if (relationshipEntity == null)
    //  {
    //    var errorMessage = String.Format("Cannot find metadata for relationship entity '{0}'", relationshipEntityName);
    //    errors.Add(new ErrorObject(errorMessage));
    //    return errors;
    //  }

    //  if (relationshipEntity.MetaAttributes == null)
    //  {
    //    var errorMessage =
    //      String.Format("Cannot find meta attributes for relationship entity '{0}'", relationshipEntityName);
    //    errors.Add(new ErrorObject(errorMessage));
    //    return errors;
    //  }

    //  string metaAttributeValue;
    //  errors.AddRange(GetAttributeValue(relationshipEntity, 
    //                                    RelationshipEntity.RelationshipTypeAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;

    //  try
    //  {
    //    relationshipData.RelationshipType = (RelationshipType)Enum.Parse(typeof(RelationshipType), metaAttributeValue);
    //  }
    //  catch (System.Exception)
    //  {
    //    string errorMessage = String.Format("Cannot parse RelationshipType value '{0}' on entity '{1}'",
    //                                         metaAttributeValue, relationshipEntityName);
    //    errors.Add(new ErrorObject(errorMessage));
    //    return errors;
    //  }

    //  // SourceEntityName
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.SourceEntityNameAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.SourceEntityName = metaAttributeValue;

    //  // SourceKeyColumnName
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.SourceKeyColumnNameAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.SourceKeyColumnName = metaAttributeValue;

    //  // SourcePropertyNameForTarget
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.SourcePropertyNameForTargetAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.SourcePropertyNameForTarget = metaAttributeValue;




    //  // TargetEntityName
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.TargetEntityNameAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.TargetEntityName = metaAttributeValue;

    //  // TargetKeyColumnName
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.TargetKeyColumnNameAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.TargetKeyColumnName = metaAttributeValue;

    //  // TargetPropertyNameForTarget
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.TargetPropertyNameForSourceAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;
    //  relationshipData.TargetPropertyNameForSource = metaAttributeValue;

    //  // Cascade
    //  errors.AddRange(GetAttributeValue(relationshipEntity,
    //                                    RelationshipEntity.CascadeAttribute,
    //                                    out metaAttributeValue));

    //  if (errors.Count > 0) return errors;

    //  try
    //  {
    //    relationshipData.Cascade = Convert.ToBoolean(metaAttributeValue);
    //  }
    //  catch (System.Exception)
    //  {
    //    string errorMessage = String.Format("Cannot parse boolean value '{0}' for cascade entry on entity '{1}'",
    //                                         metaAttributeValue, relationshipEntityName);
    //    errors.Add(new ErrorObject(errorMessage));
    //    return errors;
    //  }

    //  return errors;
    //}

    public static List<ErrorObject> GetAttributeValue(PersistentClass persistentClass, 
                                                      string attributeName,
                                                      out string value)
    {
      value = null;
      var errors = new List<ErrorObject>();

      NHibernate.Mapping.MetaAttribute metaAttribute;

      // RelationshipType
      persistentClass.MetaAttributes.TryGetValue(attributeName, out metaAttribute);
      if (metaAttribute == null || String.IsNullOrEmpty(metaAttribute.Value))
      {
        var errorMessage =
          String.Format("Cannot find the value for meta attribute '{0}' in relationship entity '{1}'",
                        attributeName, persistentClass.GetType().FullName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      value = metaAttribute.Value;

      return errors;
    }

    public static List<ErrorObject> GetTargetPropertyNameForEntity(string entityName, 
                                                                   string relationshipEntityName, 
                                                                   Configuration configuration,
                                                                   out string targetPropertyName)
    {
      var errors = new List<ErrorObject>();
      targetPropertyName = null;

      // Get the metadata for the relationshipEntity
      PersistentClass relationshipEntity = configuration.GetClassMapping(relationshipEntityName);
      if (relationshipEntity == null)
      {
        var errorMessage = String.Format("Cannot find metadata for relationship entity '{0}'", relationshipEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      if (relationshipEntity.MetaAttributes == null)
      {
        var errorMessage =
          String.Format("Cannot find meta attributes for relationship entity '{0}'", relationshipEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      NHibernate.Mapping.MetaAttribute sourceEntityNameMetaAttribute, 
                                       targetEntityNameMetaAttribute;

      relationshipEntity.MetaAttributes.TryGetValue(RelationshipEntity.SourceEntityNameAttribute, 
                                                    out sourceEntityNameMetaAttribute);

      relationshipEntity.MetaAttributes.TryGetValue(RelationshipEntity.TargetEntityNameAttribute, 
                                                    out targetEntityNameMetaAttribute);

      if (sourceEntityNameMetaAttribute == null || String.IsNullOrEmpty(sourceEntityNameMetaAttribute.Value))
      {
        var errorMessage =
          String.Format("Cannot find the value for meta attribute '{0}' in relationship entity '{1}'", RelationshipEntity.SourceEntityNameAttribute, relationshipEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      if (targetEntityNameMetaAttribute == null || String.IsNullOrEmpty(targetEntityNameMetaAttribute.Value))
      {
        var errorMessage =
          String.Format("Cannot find the value for meta attribute '{0}' in relationship entity '{1}'", RelationshipEntity.TargetEntityNameAttribute, relationshipEntityName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      if (sourceEntityNameMetaAttribute.Value != entityName)
      {
        if (targetEntityNameMetaAttribute.Value != entityName)
        {
          var errorMessage =
          String.Format("Entity '{0}' does not match either source or target in relationship entity '{1}'", entityName, relationshipEntityName);
          errors.Add(new ErrorObject(errorMessage));
          return errors;
        }
        
        // Is target. Get source-property-name-for-target
        NHibernate.Mapping.MetaAttribute metaAttribute;
        relationshipEntity.MetaAttributes.TryGetValue(RelationshipEntity.SourcePropertyNameForTargetAttribute,
                                                      out metaAttribute);
        if (metaAttribute == null || String.IsNullOrEmpty(metaAttribute.Value))
        {
          var errorMessage =
          String.Format("Cannot find value for attribute '{0}' in relationship entity '{1}'", RelationshipEntity.SourcePropertyNameForTargetAttribute, relationshipEntityName);
          errors.Add(new ErrorObject(errorMessage));
          return errors;
        }

        targetPropertyName = metaAttribute.Value;
        
      }
      else
      {
        // Is source. Get target-property-name-for-source
        NHibernate.Mapping.MetaAttribute metaAttribute;
        relationshipEntity.MetaAttributes.TryGetValue(RelationshipEntity.TargetPropertyNameForSourceAttribute,
                                                      out metaAttribute);

        if (metaAttribute == null || String.IsNullOrEmpty(metaAttribute.Value))
        {
          var errorMessage =
          String.Format("Cannot find value for attribute '{0}' in relationship entity '{1}'", RelationshipEntity.TargetPropertyNameForSourceAttribute, relationshipEntityName);
          errors.Add(new ErrorObject(errorMessage));
          return errors;
        }

        targetPropertyName = metaAttribute.Value;
      }

      return errors;
    }

    public static List<ErrorObject> GetRelationshipType(string relationshipEntityFullName,
                                                        Configuration configuration, 
                                                        out RelationshipType relationshipType)
    {
      var errors = new List<ErrorObject>();
      relationshipType = RelationshipType.OneToMany;

      // Get relationship type
      string value;
      errors.AddRange(GetMetaAttributeValue(relationshipEntityFullName,
                                            RelationshipEntity.RelationshipTypeAttribute,
                                            configuration,
                                            out value));
      if (errors.Count > 0)
      {
        return errors;
      }

      try
      {
        relationshipType = (RelationshipType)Enum.Parse(typeof(RelationshipType), value);
      }
      catch (System.Exception)
      {
        string errorMessage = String.Format("Cannot parse RelationshipType value '{0}'", value);
        errors.Add(new ErrorObject(errorMessage));
      }

      return errors;
    }

    public static List<ErrorObject> GetMetaAttributeValue(string entityFullName,
                                                          string attributeName,
                                                          Configuration configuration,
                                                          out string value)
    {
      var errors = new List<ErrorObject>();
      value = null;

      // Get the metadata for the relationshipEntity
      PersistentClass relationshipEntity = configuration.GetClassMapping(entityFullName);
      if (relationshipEntity == null)
      {
        var errorMessage = String.Format("Cannot find metadata for relationship entity '{0}'", entityFullName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      if (relationshipEntity.MetaAttributes == null)
      {
        var errorMessage =
          String.Format("Cannot find meta attributes for relationship entity '{0}'", entityFullName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      NHibernate.Mapping.MetaAttribute nhMetaAttribute;

      relationshipEntity.MetaAttributes.TryGetValue(RelationshipEntity.RelationshipTypeAttribute,
                                                    out nhMetaAttribute);

      if (nhMetaAttribute == null || String.IsNullOrEmpty(nhMetaAttribute.Value))
      {
        var errorMessage =
          String.Format("Cannot find the value for meta attribute '{0}' in relationship entity '{1}'", RelationshipEntity.RelationshipTypeAttribute, entityFullName);
        errors.Add(new ErrorObject(errorMessage));
        return errors;
      }

      value = nhMetaAttribute.Value;

      return errors;
    }

    public static bool HasInternalBusinessKey(string entityName, Configuration configuration)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(configuration != null, "configuration cannot be null", SystemConfig.CallerInfo);

      bool hasInternalBusinessKey = false;

      PersistentClass persistentClass = configuration.GetClassMapping(entityName);
      Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", entityName));

      foreach (var element in persistentClass.PropertyIterator)
      {
        var component = element.Value as Component;
        if (component == null ||
            String.IsNullOrEmpty(component.ComponentClassName) ||
            component.ComponentClassName != Name.GetEntityBusinessKeyAssemblyQualifiedName(entityName))
        {
          continue;
        }
        
        MetaAttribute metaAttribute;
        component.MetaAttributes.TryGetValue(Property.InternalBusinessKeyAttribute, out metaAttribute);
        
        if (metaAttribute != null && metaAttribute.Value == "true")
        {
          hasInternalBusinessKey = true;
        }
        
      }

      return hasInternalBusinessKey;
    }

    public static List<ComputedPropertyData> GetComputedPropertyDataList(string entityName, Configuration configuration)
    {
      var computedPropertyDataList = new List<ComputedPropertyData>();

      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(configuration != null, "configuration cannot be null", SystemConfig.CallerInfo);

      PersistentClass persistentClass = configuration.GetClassMapping(entityName);
      Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", entityName));

      foreach (var element in persistentClass.PropertyIterator)
      {
        MetaAttribute metaAttribute;
        
        element.MetaAttributes.TryGetValue(Property.ComputedAttribute, out metaAttribute);

        if (metaAttribute != null && metaAttribute.Value == "true")
        {
          MetaAttribute computationTypeName;
          element.MetaAttributes.TryGetValue(Property.ComputationTypeNameAttribute, out computationTypeName);
          if (computationTypeName != null && !String.IsNullOrEmpty(computationTypeName.Value))
          {
            computedPropertyDataList.Add(new ComputedPropertyData(entityName, element.Name));
          }
        }
      }

      return computedPropertyDataList;
    }

    public static List<string> GetEncryptedPropertyNames(string entityName, Configuration configuration)
    {
      var encryptedPropertyNames = new List<string>();

      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty", SystemConfig.CallerInfo);
      Check.Require(configuration != null, "configuration cannot be null", SystemConfig.CallerInfo);

      PersistentClass persistentClass = configuration.GetClassMapping(entityName);
      Check.Require(persistentClass != null, String.Format("Cannot find metadata for type '{0}'", entityName));

      foreach (var element in persistentClass.PropertyIterator)
      {
        MetaAttribute metaAttribute;

        element.MetaAttributes.TryGetValue(Property.EncryptedAttribute, out metaAttribute);

        if (metaAttribute != null && metaAttribute.Value == "true")
        {
          encryptedPropertyNames.Add(element.Name);
        }
      }

      return encryptedPropertyNames;
    }

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("RuntimeMetadata");
    #endregion
  }
}
