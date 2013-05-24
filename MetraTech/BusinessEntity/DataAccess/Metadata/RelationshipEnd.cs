using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Exception;
using NHibernate.Cfg.MappingSchema;
using NHibernate.Util;

using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;


namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class RelationshipEnd
  {
    #region Public Properties
    [DataMember]
    public string EntityTypeName { get; set; }
    [DataMember]
    public string EntityInterfaceName { get; set; }
    [DataMember]
    public Multiplicity Multiplicity { get; set; }
    [DataMember]
    public string PropertyName { get; set; }
    [DataMember]
    public string ColumnName { get; set; }

    /// <summary>
    ///    The property field name for this Relationship
    /// </summary>
    public string PropertyFieldName { get { return "_" + PropertyName.LowerCaseFirst(); } }
    #endregion

    #region Internal Properties
    internal Entity Entity { get; set; }
    internal string OtherEntityTypeName { get; set; }
    internal HbmId HbmId { get; set; }
    #endregion

    #region Internal Methods
    public object GetHbmNavigationItem(HbmId entityHbmId, RelationshipEnd otherEnd)
    {
      object item = null;
      // One-to-Many
      if (Multiplicity == Multiplicity.One && otherEnd.Multiplicity == Multiplicity.Many)
      {
        // Bag (e.g.)
        // <bag name="OrderItems" inverse="true" lazy="false" cascade="all-delete-orphan">
        //   <key column="OrderId" />
        //   <one-to-many class="MetraTech.BusinessEntity.OrderManagement.OrderItem, MetraTech.BusinessEntity" />
        // </bag>
        item = new HbmBag();
        ((HbmBag)item).name = PropertyName;
        ((HbmBag)item).inverse = true;
        ((HbmBag) item).lazy = HbmCollectionLazy.False;
        ((HbmBag)item).cascade = "all-delete-orphan";

        // Key
        HbmKey key = new HbmKey();
        ((HbmBag)item).key = key;
        key.column1 = entityHbmId.column1;

        // One-to-Many
        HbmOneToMany oneToMany = new HbmOneToMany();
        ((HbmBag)item).Item = oneToMany;
        oneToMany.@class = Name.GetEntityAssemblyQualifiedName(otherEnd.EntityTypeName);
      }
      else if (Multiplicity == Multiplicity.Many && otherEnd.Multiplicity == Multiplicity.One)
      {
        // <many-to-one name="Order" class="MetraTech.BusinessEntity.OrderManagement.Order" column="OrderId" not-null="true" />
        item = new HbmManyToOne();
        ((HbmManyToOne)item).name = PropertyName;
        ((HbmManyToOne)item).@class = Name.GetEntityAssemblyQualifiedName(otherEnd.EntityTypeName);
        ((HbmManyToOne)item).column = otherEnd.HbmId.column1;
        ((HbmManyToOne)item).notnull = true;
        ((HbmManyToOne)item).notnullSpecified = true;
      }
      else if (Multiplicity == Multiplicity.One && otherEnd.Multiplicity == Multiplicity.One)
      {
        // <one-to-one name="Person" constrained="true"/>
        item = new HbmManyToOne();
        ((HbmManyToOne)item).name = PropertyName;
        ((HbmManyToOne)item).column = otherEnd.HbmId.column1;
        ((HbmManyToOne)item).notnull = true;
        ((HbmManyToOne)item).notnullSpecified = true;
      }
      else
      {
        string message = String.Format(Multiplicity + "-to-" + otherEnd.Multiplicity + " not supported");
        throw new MetadataException(message, SystemConfig.CallerInfo);
      }

      return item;
    }
    internal RelationshipEnd Clone()
    {
      var relationshipEnd = new RelationshipEnd();
      relationshipEnd.EntityTypeName = EntityTypeName;
      relationshipEnd.EntityInterfaceName = EntityInterfaceName;
      relationshipEnd.Multiplicity = Multiplicity;
      relationshipEnd.PropertyName = PropertyName;
      relationshipEnd.ColumnName = ColumnName;
      relationshipEnd.Entity = Entity.Clone();
      relationshipEnd.OtherEntityTypeName = OtherEntityTypeName;
      relationshipEnd.HbmId = HbmId;
      return relationshipEnd;
    }
    #endregion

    #region Validation
    public bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(EntityTypeName))
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_END_VALIDATION_MISSING_QUALIFIED_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject("RelationshipEnd validation failed. EntityTypeName must be specified.", errorData));
      }
      else
      {
        List<ErrorObject> errors;
        if (!Name.IsValidEntityTypeName(EntityTypeName, out errors))
        {
          validationErrors.AddRange(errors);
        }
      }

      if (String.IsNullOrEmpty(PropertyName))
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_END_VALIDATION_MISSING_PROPERTY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject("RelationshipEnd validation failed. PropertyName must be specified.", errorData));
      }
      else if (!Name.IsValidIdentifier(PropertyName))
      {
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_END_VALIDATION_INVALID_PROPERTY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(String.Format("RelationshipEnd validation failed. PropertyName '{0}' is not a valid identifier.", PropertyName), errorData));
      }

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion
  }

  
}
