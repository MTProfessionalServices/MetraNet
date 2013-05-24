using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.DataAccess.Persistence;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class SelfRelationshipEntity : Entity
  {
    #region Public Properties
    public string EntityName { get; set; }
    #endregion

    #region Public Methods
    public SelfRelationshipEntity(string fullName)
      : base(fullName)
    {
      EntityType = EntityType.SelfRelationship;
    }

    public string GetParentFieldName()
    {
      return "_parent_" + ClassName + "List";
    }

    public string GetChildFieldName()
    {
      return "_child_" + ClassName + "List";
    }

    public string GetParentPluralName()
    {
      return "Parent_" + ClassName + "List";
    }

    public string GetChildPluralName()
    {
      return "Child_" + ClassName + "List";
    }

    public override string ToString()
    {
      return String.Format("SelfRelationshipEntity: " + FullName);
    }

    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      if (!base.Validate(out validationErrors))
      {
        return false;
      }

      validationErrors.AddRange(ValidateAttributes());

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion

    #region Protected Methods
    protected override void InitializeClassAttributes()
    {
      base.InitializeClassAttributes();
      MetaAttributes.Add(EntityNameAttribute, new MetaAttribute());
    }

    protected override void UpdateClassAttributes()
    {
      base.UpdateClassAttributes();
      MetaAttributes[EntityNameAttribute].Value = EntityName;
    }

    protected override List<ErrorObject> SetupAttributes(Dictionary<string, MetaAttribute> metaAttributes)
    {
      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;

      metaAttributes.TryGetValue(EntityNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        EntityName = metaAttribute.Value;
      }
      
      errors.AddRange(base.SetupAttributes(metaAttributes));
      errors.AddRange(ValidateAttributes());

      return errors;
    }

    protected override void SetTypeData(string fullName)
    {
      base.SetTypeData(fullName);
      PluralName = RelationshipEntity.GetPluralName(fullName);
      EntityType = EntityType.SelfRelationship;
    }
    #endregion

    #region Internal Methods
    public SelfRelationshipEntity(Entity entity)
    {
      string fullName = entity.FullName + "_SelfRelationship";

      SetTypeData(fullName);
      TableName = TableNameGenerator.CreateTableName(this, new List<Entity>());
      EntityName = entity.FullName;
      EntityType = EntityType.SelfRelationship;
    }

    internal override Entity Clone()
    {
      return new SelfRelationshipEntity(this);
    }
    #endregion

    #region Private Methods
    private List<ErrorObject> ValidateAttributes()
    {
      var validationErrors = new List<ErrorObject>();

      if (String.IsNullOrEmpty(EntityName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for SelfRelationshipEntity '{1}'",
                        EntityNameAttribute, FullName);
        var errorData = new ErrorData();
        errorData.ErrorCode = ErrorCode.SELF_RELATIONSHIP_ENTITY_VALIDATION_MISSING_ENTITY;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        selfRelationshipLogger.Error(message);
      }
      else
      {
        List<ErrorObject> specificErrors;
        if (Name.IsValidEntityTypeName(EntityName, out specificErrors))
        {
          validationErrors.AddRange(specificErrors);
        }
      }

      return validationErrors;
    }
    #endregion

    #region Data
    internal static ILog selfRelationshipLogger = LogManager.GetLogger("SelfRelationshipEntity");
    internal static readonly string EntityNameAttribute = "entity-name";
    #endregion
  }
}
