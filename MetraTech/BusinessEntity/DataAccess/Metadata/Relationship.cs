using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.Serialization;

using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.DataAccess.Exception;
using NHibernate.Cfg.MappingSchema;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class Relationship
  {
    #region Properties
    /// <summary>
    ///    End1 end of this relationship
    /// </summary>
    [DataMember]
    public RelationshipEnd End1 { get; set; }

    /// <summary>
    ///    End2 end of this relationship
    /// </summary>
    [DataMember]
    public RelationshipEnd End2 { get; set; }

    /// <summary>
    ///    The relationship entity
    /// </summary>
    [DataMember]
    public RelationshipEntity RelationshipEntity { get; set; }

    /// <summary>
    ///    End1 end of this relationship
    /// </summary>
    [DataMember]
    public RelationshipEnd Source { get; set; }

    /// <summary>
    ///    End2 end of this relationship
    /// </summary>
    [DataMember]
    public RelationshipEnd Target { get; set; }

    /// <summary>
    ///    RelationshipName
    /// </summary>
    [DataMember]
    public string RelationshipName
    {
      get { return RelationshipEntity != null ? RelationshipEntity.RelationshipName : String.Empty; }
      set { }
    }
    #endregion

    #region Public Methods
    public Relationship()
    {
    }

    public Relationship(RelationshipEntity relationshipEntity, 
                        Entity sourceEntity, 
                        Entity targetEntity,
                        string ownerTypeName)
    {
      Check.Require(relationshipEntity != null, "relationshipEntity cannot be null");
      Check.Require(sourceEntity != null, "sourceEntity cannot be null");
      Check.Require(targetEntity != null, "targetEntity cannot be null");
      Check.Require(sourceEntity.FullName == relationshipEntity.SourceEntityName,
                    String.Format("Incorrect source entity '{0}' " +
                                  "specified to the Relationship constructor for RelationshipEntity '{1}'",
                                  sourceEntity.FullName, RelationshipEntity));
      Check.Require(targetEntity.FullName == relationshipEntity.TargetEntityName,
                   String.Format("Incorrect target entity '{0}' " +
                                 "specified to the Relationship constructor for RelationshipEntity '{1}'",
                                 targetEntity.FullName, RelationshipEntity));

      RelationshipEntity = relationshipEntity;

      Source = 
        new RelationshipEnd()
              {
                EntityTypeName = relationshipEntity.SourceEntityName,
                EntityInterfaceName = Name.GetInterfaceFullName(relationshipEntity.SourceEntityName),
                Multiplicity = relationshipEntity.SourceMultiplicity,
                PropertyName = relationshipEntity.SourcePropertyNameForTarget,
                ColumnName = relationshipEntity.SourceKeyColumnName,
                Entity = sourceEntity
              };

      Target =
        new RelationshipEnd()
          {
            EntityTypeName = relationshipEntity.TargetEntityName,
            EntityInterfaceName = Name.GetInterfaceFullName(relationshipEntity.TargetEntityName),
            Multiplicity = relationshipEntity.TargetMultiplicity,
            PropertyName = relationshipEntity.TargetPropertyNameForSource,
            ColumnName = relationshipEntity.TargetKeyColumnName,
            Entity = targetEntity
          };
      
      if (ownerTypeName == relationshipEntity.SourceEntityName)
      {
        End1 = Source;
        End2 = Target;
      }
      else
      {
        End1 = Target;
        End2 = Source;
      }
    }

    public ICollection<RelationshipEnd> GetRelationshipEnds()
    {
      return new List<RelationshipEnd> { End1, End2 };
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as Relationship;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      if (RelationshipEntity == null || compareTo.RelationshipEntity == null)
      {
        return false;
      }

      return RelationshipEntity.Equals(compareTo.RelationshipEntity);
    }

    public override int GetHashCode()
    {
      if (RelationshipEntity == null)
      {
        return base.GetHashCode();
      }

      return RelationshipEntity.GetHashCode();
    }

    public override string ToString()
    {
      return String.Format(End1.Multiplicity + "-to-" + End2.Multiplicity + " relationship between entity '{0}' and entity '{1}'",
        End1.EntityTypeName, End2.EntityTypeName);
    }
    #endregion

    #region Internal Methods
    internal Relationship Clone()
    {
      var relationship = new Relationship();
      relationship.End1 = End1.Clone();
      relationship.End2 = End2.Clone();
      relationship.RelationshipEntity = (RelationshipEntity)RelationshipEntity.Clone();
      relationship.Source = Source.Clone();
      relationship.Target = Target.Clone();
      return relationship;
    }

    internal object GetHbmRelationshipItem(string entityName)
    {
      if (RelationshipEntity.HasJoinTable)
      {
        return GetHbmBag(entityName);
      }

      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty");
      Check.Require(Source.Entity.FullName == entityName || Target.Entity.FullName == entityName,
                    String.Format("Specified entity '{0}' does not match source or target for relationship '{1}'",
                                  entityName, ToString()));

      // Is this the method called for the source
      object item = Source.Entity.FullName == entityName
                      ? GetSourceHbmRelationshipItem()
                      : GetTargetHbmRelationshipItem();

      Check.Ensure(item != null, String.Format("Cannot get hbm relationship item for entity '{0}' and relationship '{1}'",
                                                entityName, ToString()));

      return item;
    }

    internal object GetSourceHbmRelationshipItem()
    {
      object hbmItem = null;

      if (RelationshipEntity.RelationshipType == RelationshipType.OneToMany)
      {
        // <bag name="Children" inverse="true" lazy="true">
        //   <key column="parent_id"/>
        //   <one-to-many class="Child"/>
        // </bag>
        var hbmBag = new HbmBag();
        hbmBag.name = RelationshipEntity.SourcePropertyNameForTarget;
        hbmBag.inverse = true;
        hbmBag.cascade = RelationshipEntity.Cascade ? "delete" : "none";
        hbmBag.access = "field.camelcase-underscore";

        // <key>
        hbmBag.key = new HbmKey();
        hbmBag.key.column1 = 
          RelationshipEntity.IsSelfRelationship ? 
          Property.GetColumnName(RelationshipEntity.TargetPropertyNameForSource) : 
          RelationshipEntity.SourceKeyColumnName;
       
        // <one-to-many>
        var hbmOneToMany = new HbmOneToMany();
        hbmBag.Item = hbmOneToMany;
        hbmOneToMany.@class = Name.GetEntityAssemblyQualifiedName(RelationshipEntity.TargetEntityName);

        // Set Attributes
        SetRelationshipAttributes(hbmBag, RelationshipEntity.GetAttributeNameValues(), typeof (HbmBagExtension));

        hbmItem = hbmBag;
      }
      else if (RelationshipEntity.RelationshipType == RelationshipType.OneToOne)
      {
        // <one-to-one name="Employee" class="Employee"/>
        var oneToOne = new HbmOneToOne();
        oneToOne.name = RelationshipEntity.SourcePropertyNameForTarget;
        oneToOne.@class = Name.GetEntityAssemblyQualifiedName(RelationshipEntity.TargetEntityName);
        oneToOne.cascade = RelationshipEntity.Cascade ? "delete" : "none";
        // Add attributes
        SetRelationshipAttributes(oneToOne, RelationshipEntity.GetAttributeNameValues(), typeof(HbmOneToOneExtension));
        hbmItem = oneToOne;
      }

      return hbmItem;
    }

    internal object GetTargetHbmRelationshipItem()
    {
      object hbmItem = null;

      if (RelationshipEntity.RelationshipType == RelationshipType.OneToMany)
      {
        // <many-to-one name="parent" class="Parent" column="parent_id"/>
        var manyToOne = new HbmManyToOne();
        manyToOne.name = RelationshipEntity.TargetPropertyNameForSource;
        manyToOne.@class = Name.GetEntityAssemblyQualifiedName(RelationshipEntity.SourceEntityName);
        manyToOne.column = 
          RelationshipEntity.IsSelfRelationship ? 
          Property.GetColumnName(RelationshipEntity.TargetPropertyNameForSource) : 
          RelationshipEntity.SourceKeyColumnName;
        
        manyToOne.unique = false;
        manyToOne.cascade = "none";

        // string foreignKey = "FK_" + Source.Entity.TableName.Truncate(23) + "_" + random.Next().ToString().Truncate(4);
        // manyToOne.foreignkey = foreignKey;

        // Add attributes
        SetRelationshipAttributes(manyToOne, RelationshipEntity.GetAttributeNameValues(), typeof(HbmManyToOneExtension));
        hbmItem = manyToOne;
      }
      else if (RelationshipEntity.RelationshipType == RelationshipType.OneToOne)
      {
        var manyToOne = new HbmManyToOne();
        manyToOne.name = RelationshipEntity.TargetPropertyNameForSource;
        manyToOne.@class = Name.GetEntityAssemblyQualifiedName(RelationshipEntity.SourceEntityName);
        manyToOne.unique = false;
        manyToOne.column = RelationshipEntity.SourceKeyColumnName;

        // Add attributes
        SetRelationshipAttributes(manyToOne, RelationshipEntity.GetAttributeNameValues(), typeof(HbmManyToOneExtension));
        hbmItem = manyToOne;
      }

      return hbmItem;
    }

    /// <summary>
    ///    entityName must correspond to source or target
    /// </summary>
    /// <param name="entityName"></param>
    /// <returns></returns>
    internal HbmBag GetHbmBag(string entityName)
    {
      Check.Require(!String.IsNullOrEmpty(entityName), "entityName cannot be null or empty");
      Entity entity = null;
      if (Source.Entity.FullName == entityName)
      {
        entity = Source.Entity;
      }
      else if (Target.Entity.FullName == entityName)
      {
        entity = Target.Entity;
      }

      Check.Require(entity != null, 
                    String.Format("Specified entity '{0}' does not match source or target for relationship '{1}'",
                                  entityName, ToString()));
      // bag for Join Table

      // <bag name="Order_OrderItems" inverse="true" cascade="all" lazy="true">
      //   <meta attribute="target-entity">Core.OrderManagement.OrderItem</meta>
      //   <key column="Order_Id" />
      //   <one-to-many class="Core.OrderManagement.Order_OrderItem, Core.OrderManagement.Entity"/>
      // </bag>

      var hbmBag = new HbmBag();
      hbmBag.name = RelationshipEntity.PluralName;
      hbmBag.inverse = true;
      hbmBag.lazy = HbmCollectionLazy.True;
      hbmBag.lazySpecified = true;
      hbmBag.cascade = RelationshipEntity.Cascade ? "delete" : "none";

      // <meta>
      hbmBag.meta =
        new[]
            {
              new HbmMeta
                {
                  attribute = Entity.TargetEntityAttribute,
                  Text = new[] {End2.EntityTypeName}
                }
            };

      // <key>
      hbmBag.key = new HbmKey();
      hbmBag.key.column1 = entity.GetIdColumnName();

      // <one-to-many>
      hbmBag.Item = new HbmOneToMany();
      ((HbmOneToMany)hbmBag.Item).@class = Name.GetEntityAssemblyQualifiedName(RelationshipEntity.FullName);

      return hbmBag;
    }
    #endregion

    #region Static Methods
    internal static void SetRelationshipAttributes(dynamic item, 
                                                   Dictionary<string, string> attributeNameValues, 
                                                   Type extensionMethodType)
    {
      MethodInfo methodInfo = extensionMethodType.GetMethod("SetAttributeValue");
      Check.Require(methodInfo != null, String.Format("Cannot find method 'SetAttributeValue' on type '{0}'", item.GetType().FullName));
      
      foreach(KeyValuePair<string, string> kvp in attributeNameValues)
      {
        methodInfo.Invoke(null,
                          new[] { item, kvp.Key, kvp.Value});
      }
    }
    #endregion

    #region Validation
    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (RelationshipEntity == null)
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_RELATIONSHIP_ENTITY;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject("Relationship validation failed. RelationshipEntity must be specified", errorData));
        return false;
      }

      if (End1 == null)
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_SOURCE;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject("Relationship validation failed. End1 must be specified", errorData));
      }
      else
      {
        List<ErrorObject> errors;
        if (!End1.Validate(out errors))
        {
          foreach (ErrorObject errorObject in errors)
          {
            ((RelationshipValidationErrorData)errorObject.ErrorData).SourceEntityTypeName = End1.EntityTypeName;
            validationErrors.Add(errorObject);
          }
        }
      }

      if (End2 == null)
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_TARGET;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject("Relationship validation failed. End2 must be specified", errorData));
      }
      else
      {
        List<ErrorObject> errors;
        if (!End2.Validate(out errors))
        {
          foreach (ErrorObject errorObject in errors)
          {
            ((RelationshipValidationErrorData)errorObject.ErrorData).TargetEntityTypeName = End2.EntityTypeName;
            validationErrors.Add(errorObject);
          }

        }
      }

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("Relationship");
    private static Random random = new Random();
    #endregion
  }
}
