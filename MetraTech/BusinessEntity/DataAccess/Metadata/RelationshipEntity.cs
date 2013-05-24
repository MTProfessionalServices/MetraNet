using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NHibernate.Cfg.MappingSchema;

using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.Core.Exception;
using NHibernate.Engine;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class RelationshipEntity : Entity
  {
    #region Public Methods

    public RelationshipEntity(string fullName) : base(fullName)
    {
      EntityType = EntityType.Relationship;
    }

    public RelationshipEntity(Dictionary<string, string> metaAttributeNameValues)
    {
      foreach(KeyValuePair<string, string> kvp in metaAttributeNameValues)
      {
        switch(kvp.Key)
        {
          case RelationshipTypeAttribute:
            {
              RelationshipType = (RelationshipType)Enum.Parse(typeof (RelationshipType), kvp.Value);
              break;
            }
          case RelationshipNameAttribute:
            {
              RelationshipName = kvp.Value;
              break;
            }
          case HasJoinTableAttribute:
            {
              HasJoinTable = Convert.ToBoolean(kvp.Value);
              break;
            }
          case IsDefaultAttribute:
            {
              IsDefault = Convert.ToBoolean(kvp.Value);
              break;
            }
          case IsSelfRelationshipAttribute:
            {
              IsSelfRelationship = Convert.ToBoolean(kvp.Value);
              break;
            }
          case IsBiDirectionalAttribute:
            {
              IsBiDirectional = Convert.ToBoolean(kvp.Value);
              break;
            }
          case LabelAttribute:
            {
              Label = kvp.Value;
              break;
            }
          case DescriptionAttribute:
            {
              Description = kvp.Value;
              break;
            }
          case CascadeAttribute:
            {
              Cascade = Convert.ToBoolean(kvp.Value);
              break;
            }
          case SourceEntityNameAttribute:
            {
              SourceEntityName = kvp.Value;
              break;
            }
          case SourceKeyColumnNameAttribute:
            {
              SourceKeyColumnName = kvp.Value;
              break;
            }
          case TargetEntityNameAttribute:
            {
              TargetEntityName = kvp.Value;
              break;
            }
          case TargetKeyColumnNameAttribute:
            {
              TargetKeyColumnName = kvp.Value;
              break;
            }
          case SourcePropertyNameForTargetAttribute:
            {
              SourcePropertyNameForTarget = kvp.Value;
              break;
            }
          case TargetPropertyNameForSourceAttribute:
            {
              TargetPropertyNameForSource = kvp.Value;
              break;
            }
          default:
            {
              // relationshipLogger.Debug(String.Format("Unrecognized attribute '{0}'", kvp.Key));
              break;
            }
        }
      }

      // RelationshipEntity is created in the namespace of the source
      string fullName = Name.GetEntityNamespace(SourceEntityName) + "." +
                        GetSourceEntityClassName() + "_" + GetTargetEntityClassName();

      // Append relationship name to full name, if it's not the default name
      if (!String.IsNullOrEmpty(RelationshipName) &&
          RelationshipName != GetSourceEntityClassName() + "_" + GetTargetEntityClassName())
      {
        fullName += "_" + RelationshipName;
      }


      SetTypeData(fullName);
    }

    /// <summary>
    ///   Called during initialization from file system
    /// </summary>
    /// <param name="relationshipData"></param>
    public RelationshipEntity(HbmRelationshipData relationshipData)
    {
      Check.Require(relationshipData != null, "relationshipData cannot be null");

      RelationshipType = relationshipData.RelationshipType;
      RelationshipName = relationshipData.RelationshipName;
      HasJoinTable = relationshipData.HasJoinTable;
      IsDefault = relationshipData.IsDefault;
      IsBiDirectional = relationshipData.IsBiDirectional;
      IsSelfRelationship = relationshipData.IsSelfRelationship;

      Label = relationshipData.Label;
      Description = relationshipData.Description;
      Cascade = relationshipData.Cascade;

      SourceEntityName = relationshipData.SourceEntityName;
      SourceKeyColumnName = relationshipData.SourceKeyColumn;

      TargetEntityName = relationshipData.TargetEntityName;
      TargetKeyColumnName = relationshipData.TargetKeyColumn;

      SourcePropertyNameForTarget = relationshipData.SourcePropertyNameForTarget;
      TargetPropertyNameForSource = relationshipData.TargetPropertyNameForSource;

      // RelationshipEntity is created in the namespace of the source
      string fullName = Name.GetEntityNamespace(relationshipData.SourceEntityName) + "." +
                        relationshipData.SourceEntityName + "_" + relationshipData.TargetEntityName;

      // Append relationship name to full name, if it's not the default name
      if (!String.IsNullOrEmpty(relationshipData.RelationshipName) &&
          relationshipData.RelationshipName !=
            relationshipData.SourceEntityName + "_" + relationshipData.TargetEntityName)
      {
        fullName += "_" + relationshipData.RelationshipName;
      }

      SetTypeData(fullName);

      Check.Require(relationshipData.Source.DatabaseName.ToLower() == relationshipData.Target.DatabaseName.ToLower(),
                    String.Format("The database '{0}' for the source entity '{1}' is different from the database '{2}' of the target entity '{3}'",
                                   relationshipData.Source.DatabaseName, relationshipData.Source.FullName, relationshipData.Target.DatabaseName, relationshipData.Target.FullName));
      DatabaseName = relationshipData.Source.DatabaseName;
    }

    /// <summary>
    ///    Called from ICE to create a new relationship
    /// </summary>
    /// <param name="relationshipData"></param>
    public RelationshipEntity(RelationshipData relationshipData)
    {
      Check.Require(relationshipData != null, "relationshipData cannot be null");
      Check.Require(relationshipData.Source != null, String.Format("relationshipData.Source cannot be null"));
      Check.Require(relationshipData.Target != null, String.Format("relationshipData.Target cannot be null"));

      RelationshipType = relationshipData.RelationshipType;
      RelationshipName = String.IsNullOrEmpty(relationshipData.RelationshipName)
                           ? relationshipData.Source.FullName + "_" + relationshipData.Target.FullName
                           : relationshipData.RelationshipName;

      HasJoinTable = relationshipData.HasJoinTable;
      if (RelationshipType == RelationshipType.ManyToMany)
      {
        HasJoinTable = true;
      }
      IsDefault = relationshipData.IsDefault;
      IsBiDirectional = relationshipData.IsBiDirectional;
      IsSelfRelationship = relationshipData.IsSelfRelationship;
     
      Label = relationshipData.Label;
      Description = relationshipData.Description;
      Cascade = relationshipData.Cascade;

      SourceEntityName = relationshipData.Source.FullName;
      SourceKeyColumnName = relationshipData.Source.GetIdColumnName();

      TargetEntityName = relationshipData.Target.FullName;
      TargetKeyColumnName = relationshipData.Target.GetIdColumnName();

      if (String.IsNullOrEmpty(relationshipData.SourcePropertyNameForTarget))
      {
        SourcePropertyNameForTarget = TargetMultiplicity == Multiplicity.Many
                                        ? relationshipData.Target.PluralName
                                        : relationshipData.Target.ClassName;
      }
      else
      {
        SourcePropertyNameForTarget = relationshipData.SourcePropertyNameForTarget;
      }

      if (String.IsNullOrEmpty(relationshipData.TargetPropertyNameForSource))
      {
        TargetPropertyNameForSource = SourceMultiplicity == Multiplicity.Many
                                        ? relationshipData.Source.PluralName
                                        : relationshipData.Source.ClassName;
      }
      else
      {
        TargetPropertyNameForSource = relationshipData.TargetPropertyNameForSource;
      }

      // RelationshipEntity is created in the namespace of the source
      string fullName = relationshipData.Source.Namespace + "." +
                          relationshipData.Source.ClassName + "_" +
                          relationshipData.Target.ClassName;

      // Append relationship name to full name, if it's not the default name
      if (!String.IsNullOrEmpty(relationshipData.RelationshipName) &&
          relationshipData.RelationshipName != 
            relationshipData.Source.ClassName + "_" + relationshipData.Target.ClassName)
      {
        fullName += "_" + relationshipData.RelationshipName;
      }

      SetTypeData(fullName);

      Check.Require(relationshipData.Source.DatabaseName.ToLower() == relationshipData.Target.DatabaseName.ToLower(),
                    String.Format("The database '{0}' for the source entity '{1}' is different from the database '{2}' of the target entity '{3}'",
                                   relationshipData.Source.DatabaseName, relationshipData.Source.FullName, relationshipData.Target.DatabaseName, relationshipData.Target.FullName));
      DatabaseName = relationshipData.Source.DatabaseName;
    }

    public string GetSourceEntityInterfaceName()
    {
      return Name.GetInterfaceFullName(SourceEntityName);
    }

    public string GetTargetEntityInterfaceName()
    {
      return Name.GetInterfaceFullName(TargetEntityName);
    }

    public string GetSourceEntityClassName()
    {
      return Name.GetEntityClassName(SourceEntityName);
    }

    public string GetTargetEntityClassName()
    {
      return Name.GetEntityClassName(TargetEntityName);
    }

    public string GetSourceEntityFieldName()
    {
      return "_" + GetSourceEntityClassName().LowerCaseFirst(); 
    }

    public string GetTargetEntityFieldName()
    {
      return "_" + GetTargetEntityClassName().LowerCaseFirst();
    }

    public string GetInterfaceFullName()
    {
      return Name.GetInterfaceFullName(FullName);
    }

    public string GetFieldName()
    {
      return "_" + ClassName.LowerCaseFirst() + "List";
    }

    public static string GetPluralName(string fullName)
    {
      return Name.GetEntityClassName(fullName) + "List";
    }

    public override List<Property> GetStandardProperties()
    {
      List<Property> standardProperties = base.GetStandardProperties();

      var sourceKeyProperty =
        new Property(this, SourceKeyColumnName, "Guid")
        {
          ColumnName = SourceKeyColumnName,
          IsRequired = true
        };

      var targetKeyProperty =
        new Property(this, TargetKeyColumnName, "Guid")
        {
          ColumnName = TargetKeyColumnName,
          IsRequired = true
        };

      standardProperties.Add(sourceKeyProperty);
      standardProperties.Add(targetKeyProperty);

      return standardProperties;
    }

    /// <summary>
    ///   Return true if the specified relationshipEntity has
    ///   the same two entities at its ends as this.
    /// </summary>
    /// <param name="relationshipEntity"></param>
    /// <returns></returns>
    public bool AreEquivalent(RelationshipEntity relationshipEntity)
    {
      if (
           (SourceEntityName == relationshipEntity.SourceEntityName &&
            TargetEntityName == relationshipEntity.TargetEntityName)
           ||
           (SourceEntityName == relationshipEntity.TargetEntityName &&
            TargetEntityName == relationshipEntity.SourceEntityName)
          )
      {
        return true;
      }

      return false;
    }
    public override bool Equals(object obj)
    {
      var compareTo = obj as RelationshipEntity;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return base.Equals(obj);
    }

    public override int GetHashCode()
    {
      return base.GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("RelationshipEntity: " + 
                           SourceMultiplicity + "-to-" + TargetMultiplicity + " relationship between entity '{0}' and entity '{1}'",
                           SourceEntityName, TargetEntityName);
    }
    #endregion

    #region Public Properties

    public string RelationshipName { get; set; }

    public bool IsDefault { get; set; }

    public bool IsSelfRelationship { get; set; }

    public bool HasSameSourceAndTarget { get { return SourceEntityName == TargetEntityName; } }

    public bool IsBiDirectional { get; set; }

    public bool HasJoinTable { get; set; }

    public RelationshipType RelationshipType { get; set;}

    public Multiplicity SourceMultiplicity 
    {
      get
      {
        return RelationshipType == RelationshipType.ManyToMany ? Multiplicity.Many : Multiplicity.One;
      } 
    }

    public string SourceEntityName { get; set; }

    public string SourceKeyColumnName { get; set; }

    public string SourcePropertyNameForTarget { get; set;}

    public string SourceFieldNameForTarget { get { return "_" + SourcePropertyNameForTarget.LowerCaseFirst();  } }

    public Multiplicity TargetMultiplicity
    {
      get 
      {
        Multiplicity multiplicity = Multiplicity.Many;
        if (RelationshipType == RelationshipType.OneToOne)
        {
          multiplicity = Multiplicity.One;
        }

        return multiplicity;
      }
    }

    public string TargetEntityName { get; set;}

    public string TargetKeyColumnName { get; set;}

    public string TargetPropertyNameForSource  { get; set;}

    public string TargetFieldNameForSource { get { return "_" + TargetPropertyNameForSource.LowerCaseFirst(); } }

    public bool Cascade { get; set;}

    public bool SourceAndTargetInSameEntityGroup
    {
      get
      {
        // Determine if the source and target entities belong to different entity groups
        string sourceEntityGroupName = Name.GetEntityGroupName(SourceEntityName);
        string targetEntityGroupName = Name.GetEntityGroupName(TargetEntityName);

        if (sourceEntityGroupName.ToLower() == targetEntityGroupName.ToLower())
        {
          return true;
        }

        return false;
      }
    }

    

    #endregion

    #region Internal Methods
    internal override Entity Clone()
    {
      return new RelationshipEntity(this);
    }

    internal Dictionary<string, string> GetAttributeNameValues()
    {
      var attributeNameValues = new Dictionary<string, string>();
      attributeNameValues.Add(RelationshipTypeAttribute, RelationshipType.ToString());
      attributeNameValues.Add(RelationshipNameAttribute, RelationshipName);
      attributeNameValues.Add(HasJoinTableAttribute, HasJoinTable.ToString().ToLower());
      attributeNameValues.Add(IsDefaultAttribute, IsDefault.ToString().ToLower());
      attributeNameValues.Add(IsSelfRelationshipAttribute, IsSelfRelationship.ToString().ToLower());
      attributeNameValues.Add(IsBiDirectionalAttribute, IsBiDirectional.ToString().ToLower());

      attributeNameValues.Add(SourceMultiplicityAttribute, SourceMultiplicity.ToString());
      attributeNameValues.Add(SourceEntityNameAttribute, SourceEntityName);
      attributeNameValues.Add(SourceKeyColumnNameAttribute, SourceKeyColumnName);
      attributeNameValues.Add(SourcePropertyNameForTargetAttribute, SourcePropertyNameForTarget);

      attributeNameValues.Add(TargetMultiplicityAttribute, TargetMultiplicity.ToString());
      attributeNameValues.Add(TargetEntityNameAttribute, TargetEntityName);
      attributeNameValues.Add(TargetKeyColumnNameAttribute, TargetKeyColumnName);
      attributeNameValues.Add(TargetPropertyNameForSourceAttribute, TargetPropertyNameForSource);

      attributeNameValues.Add(CascadeAttribute, Cascade.ToString().ToLower());

      return attributeNameValues;
    }

    internal bool IsManyEnd(string entityName)
    {
      return TargetEntityName == entityName && TargetMultiplicity == Multiplicity.Many;
    }

    #endregion

    #region Protected Methods

    protected RelationshipEntity(RelationshipEntity relationshipEntity) : base(relationshipEntity)
    {
      RelationshipType = relationshipEntity.RelationshipType;
      RelationshipName = relationshipEntity.RelationshipName;
      HasJoinTable = relationshipEntity.HasJoinTable;
      IsDefault = relationshipEntity.IsDefault;
      IsBiDirectional = relationshipEntity.IsBiDirectional;
      IsSelfRelationship = relationshipEntity.IsSelfRelationship;

      SourceEntityName = relationshipEntity.SourceEntityName;
      SourceKeyColumnName = relationshipEntity.SourceKeyColumnName;
      SourcePropertyNameForTarget = relationshipEntity.SourcePropertyNameForTarget;

      TargetEntityName = relationshipEntity.TargetEntityName;
      TargetKeyColumnName = relationshipEntity.TargetKeyColumnName;
      TargetPropertyNameForSource = relationshipEntity.TargetPropertyNameForSource;

      Cascade = relationshipEntity.Cascade;
    }

    protected override void InitializeClassAttributes()
    {
      base.InitializeClassAttributes();

      MetaAttributes.Add(RelationshipTypeAttribute, new MetaAttribute());
      MetaAttributes.Add(RelationshipNameAttribute, new MetaAttribute());
      MetaAttributes.Add(HasJoinTableAttribute, new MetaAttribute());
      MetaAttributes.Add(IsDefaultAttribute, new MetaAttribute());
      MetaAttributes.Add(IsSelfRelationshipAttribute, new MetaAttribute());
      MetaAttributes.Add(IsBiDirectionalAttribute, new MetaAttribute());

      MetaAttributes.Add(SourceMultiplicityAttribute, new MetaAttribute());
      MetaAttributes.Add(SourceEntityNameAttribute, new MetaAttribute());
      MetaAttributes.Add(SourceKeyColumnNameAttribute, new MetaAttribute());
      MetaAttributes.Add(SourcePropertyNameForTargetAttribute, new MetaAttribute());

      MetaAttributes.Add(TargetMultiplicityAttribute, new MetaAttribute());
      MetaAttributes.Add(TargetEntityNameAttribute, new MetaAttribute());
      MetaAttributes.Add(TargetKeyColumnNameAttribute, new MetaAttribute());
      MetaAttributes.Add(TargetPropertyNameForSourceAttribute, new MetaAttribute());

      MetaAttributes.Add(CascadeAttribute, new MetaAttribute());
    }

    protected override void UpdateClassAttributes()
    {
      base.UpdateClassAttributes();

      MetaAttributes[RelationshipTypeAttribute].Value = RelationshipType.ToString();
      
      // If we don't have a relationship name, set it to SourceClassName_TargetClassName
      MetaAttributes[RelationshipNameAttribute].Value = 
        String.IsNullOrEmpty(RelationshipName) ? 
        GetSourceEntityClassName() + "_" + GetTargetEntityClassName() :
        RelationshipName;

      MetaAttributes[HasJoinTableAttribute].Value = HasJoinTable.ToString().ToLower();
      MetaAttributes[IsDefaultAttribute].Value = IsDefault.ToString().ToLower();
      MetaAttributes[IsSelfRelationshipAttribute].Value = IsSelfRelationship.ToString().ToLower();
      MetaAttributes[IsBiDirectionalAttribute].Value = IsBiDirectional.ToString().ToLower();

      MetaAttributes[SourceMultiplicityAttribute].Value = SourceMultiplicity.ToString();
      MetaAttributes[SourceEntityNameAttribute].Value = SourceEntityName;
      MetaAttributes[SourceKeyColumnNameAttribute].Value = SourceKeyColumnName;
      MetaAttributes[SourcePropertyNameForTargetAttribute].Value = SourcePropertyNameForTarget;

      MetaAttributes[TargetMultiplicityAttribute].Value = TargetMultiplicity.ToString();
      MetaAttributes[TargetEntityNameAttribute].Value = TargetEntityName;
      MetaAttributes[SourceKeyColumnNameAttribute].Value = SourceKeyColumnName;
      MetaAttributes[TargetKeyColumnNameAttribute].Value = TargetKeyColumnName;
      MetaAttributes[TargetPropertyNameForSourceAttribute].Value = TargetPropertyNameForSource;

      MetaAttributes[CascadeAttribute].Value = Cascade.ToString().ToLower();
    }

    protected override void SetTypeData(string fullName)
    {
      base.SetTypeData(fullName);
      PluralName = GetPluralName(fullName);
      EntityType = EntityType.Relationship;
    }

    internal override HbmComponent CreateBusinessKeyHbmComponent()
    {
      var hbmComponent = new HbmComponent();
      var items = new List<object>();
      items.Add(CreateInternalBusinessKeyHbmProperty());

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
              Text = new string[] { "true" }
            }
          };

      return hbmComponent;
    }

    protected override List<ErrorObject> SetupAttributes(Dictionary<string, MetaAttribute> metaAttributes)
    {
      var errors = new List<ErrorObject>();

      MetaAttribute metaAttribute;

      // RelationshipType
      metaAttributes.TryGetValue(RelationshipTypeAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          RelationshipType = (RelationshipType) Enum.Parse(typeof (RelationshipType), metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to 'RelationshipType' " +
                          "for RelationshipEntity '{2}. Legal values are OneToMany, OneToOne or ManyToMany.",
                          metaAttribute.Value, RelationshipTypeAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_RELATIONSHIP_TYPE;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }

      // IsDefault
      metaAttributes.TryGetValue(IsDefaultAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          IsDefault = Convert.ToBoolean(metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to boolean " +
                          "for RelationshipEntity '{2}. Legal values are true or false.",
                          metaAttribute.Value, TargetMultiplicityAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_IS_DEFAULT;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }
      else
      {
        // Did not find IsDefault
        IsDefault = true;
      }

      // IsSelfRelationship
      metaAttributes.TryGetValue(IsSelfRelationshipAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          IsSelfRelationship = Convert.ToBoolean(metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to boolean " +
                          "for RelationshipEntity '{2}. Legal values are true or false.",
                          metaAttribute.Value, TargetMultiplicityAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_IS_SELF_RELATIONSHIP;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }
      else
      {
        // Did not find IsSelfRelationship
        IsSelfRelationship = false;
      }

      // HasJoinTable
      metaAttributes.TryGetValue(HasJoinTableAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          HasJoinTable = Convert.ToBoolean(metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to boolean " +
                          "for RelationshipEntity '{2}. Legal values are true or false.",
                          metaAttribute.Value, TargetMultiplicityAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_HAS_JOIN_TABLE;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }
      else
      {
        // Did not find HasJoinTable
        HasJoinTable = true;
      }

      // IsBiDirectional
      metaAttributes.TryGetValue(IsBiDirectionalAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          IsBiDirectional = Convert.ToBoolean(metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to boolean " +
                          "for RelationshipEntity '{2}. Legal values are true or false.",
                          metaAttribute.Value, TargetMultiplicityAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_IS_BIDIRECTIONAL;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }
      else
      {
        // Did not find IsBiDirectional
        IsBiDirectional = true;
      }

      #region Source Attributes

      metaAttributes.TryGetValue(SourceEntityNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        SourceEntityName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(SourceKeyColumnNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        SourceKeyColumnName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(SourcePropertyNameForTargetAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        SourcePropertyNameForTarget = metaAttribute.Value;
      }

      #endregion

      #region Target Attributes

      metaAttributes.TryGetValue(TargetEntityNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        TargetEntityName = metaAttribute.Value;
      }

     
      metaAttributes.TryGetValue(TargetKeyColumnNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        TargetKeyColumnName = metaAttribute.Value;
      }

      metaAttributes.TryGetValue(TargetPropertyNameForSourceAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        TargetPropertyNameForSource = metaAttribute.Value;
      }

      #endregion

      // Cascade
      metaAttributes.TryGetValue(CascadeAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        try
        {
          Cascade = Convert.ToBoolean(metaAttribute.Value);
        }
        catch (System.Exception e)
        {
          string message =
            String.Format("Cannot convert value '{0}' for meta attribute '{1}' to boolean " +
                          "for RelationshipEntity '{2}. Legal values are true or false.",
                          metaAttribute.Value, TargetMultiplicityAttribute, FullName);
          var errorData = new RelationshipValidationErrorData();
          errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_INVALID_CASCADE;
          errorData.ErrorType = ErrorType.RelationshipValidation;
          errors.Add(new ErrorObject(message, errorData));
          relationshipLogger.Error(message, e);
        }
      }
      else
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        CascadeAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_CASCADE;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        errors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
        
      }

      // RelationshipName
      metaAttributes.TryGetValue(RelationshipNameAttribute, out metaAttribute);
      if (metaAttribute != null)
      {
        RelationshipName = metaAttribute.Value;
      }
      else
      {
        RelationshipName = GetSourceEntityClassName() + "_" + GetTargetEntityClassName();
      }

      errors.AddRange(base.SetupAttributes(metaAttributes));
      errors.AddRange(ValidateAttributes());

      return errors;
    }

    internal override string GetClassNameSectionForTable()
    {
      string sourceClassName = GetSourceEntityClassName();
      Check.Require(!String.IsNullOrEmpty(sourceClassName), String.Format("sourceClassName cannot be null or empty for '{0}'", FullName));
      string targetClassName = GetTargetEntityClassName();
      Check.Require(!String.IsNullOrEmpty(targetClassName), String.Format("targetClassName cannot be null or empty for '{0}'", FullName));

      if (sourceClassName.Length > 6)
      {
        sourceClassName = sourceClassName.Substring(0, 6);
      }

      if (targetClassName.Length > 6)
      {
        targetClassName = targetClassName.Substring(0, 6);
      }

      return sourceClassName + "_" + targetClassName;
    }

    #endregion

    #region Validation
    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      if (!base.Validate(out validationErrors))
      {
        return false;
      }

      validationErrors.AddRange(ValidateAttributes());

      return validationErrors.Count > 0 ? false : true;
    }

    private List<ErrorObject> ValidateAttributes()
    {
      var validationErrors = new List<ErrorObject>();

      #region Source Attributes

      if (String.IsNullOrEmpty(SourceEntityName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        SourceEntityNameAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_SOURCE_ENTITY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }
      else
      {
        List<ErrorObject> specificErrors;
        if (Name.IsValidEntityTypeName(SourceEntityName, out specificErrors))
        {
          validationErrors.AddRange(specificErrors);
        }
      }

      if (String.IsNullOrEmpty(SourceKeyColumnName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        SourceKeyColumnNameAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_SOURCE_KEY_COLUMN;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }

      if (String.IsNullOrEmpty(SourcePropertyNameForTarget))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        SourcePropertyNameForTargetAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_SOURCE_PROPERTY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }
      #endregion

      #region Target Attributes

      if (String.IsNullOrEmpty(TargetEntityName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        TargetEntityNameAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_TARGET_ENTITY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }
      else
      {
        List<ErrorObject> specificErrors;
        if (Name.IsValidEntityTypeName(TargetEntityName, out specificErrors))
        {
          validationErrors.AddRange(specificErrors);
        }
      }

      if (String.IsNullOrEmpty(TargetKeyColumnName))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        TargetKeyColumnNameAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_TARGET_KEY_COLUMN;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }

      if (String.IsNullOrEmpty(TargetPropertyNameForSource))
      {
        string message =
          String.Format("The '{0}' meta attribute is missing or empty for RelationshipEntity '{1}'",
                        TargetPropertyNameForSourceAttribute, FullName);
        var errorData = new RelationshipValidationErrorData();
        errorData.ErrorCode = ErrorCode.RELATIONSHIP_VALIDATION_MISSING_TARGET_PROPERTY_NAME;
        errorData.ErrorType = ErrorType.RelationshipValidation;
        validationErrors.Add(new ErrorObject(message, errorData));
        relationshipLogger.Error(message);
      }
      #endregion

      return validationErrors;
    }
    #endregion

    #region Data
    internal static ILog relationshipLogger = LogManager.GetLogger("RelationshipEntity");

    public const string RelationshipTypeAttribute = "relationship-type";
    public const string RelationshipNameAttribute = "relationship-name";
    public const string IsDefaultAttribute = "is-default";
    public const string IsSelfRelationshipAttribute = "is-self-relationship";
    public const string HasJoinTableAttribute = "has-join-table";
    public const string IsBiDirectionalAttribute = "is-bidirectional";

    public const string SourceMultiplicityAttribute = "source-multiplicity";
    public const string SourceEntityNameAttribute = "source-entity-name";
    public const string SourceKeyColumnNameAttribute = "source-key-column";
    public const string SourcePropertyNameForTargetAttribute = "source-property-name-for-target";

    public const string TargetMultiplicityAttribute = "target-multiplicity";
    public const string TargetEntityNameAttribute = "target-entity-name";
    public const string TargetKeyColumnNameAttribute = "target-key-column";
    public const string TargetPropertyNameForSourceAttribute = "target-property-name-for-source";

    public const string CascadeAttribute = "cascade";

    #endregion
  }

  

  
}
