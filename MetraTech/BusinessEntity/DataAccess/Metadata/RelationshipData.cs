using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Metadata.Graph;
using NHibernate.Cfg.MappingSchema;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class RelationshipData
  {
    #region Public Methods

    public RelationshipData(bool isDefault = true)
    {
      IsDefault = isDefault;
      HasJoinTable = false;
    }

    public RelationshipData(RelationshipType relationshipType,
                            bool cascade,
                            bool isDefault = true)
    {
      RelationshipType = relationshipType;
      Cascade = cascade;
      IsDefault = isDefault;
      HasJoinTable = false;
    }

    public RelationshipData(Entity source, 
                            Entity target, 
                            RelationshipType relationshipType, 
                            bool cascade,
                            bool isDefault = true)
    {
      RelationshipType = relationshipType;
      Cascade = cascade;
      Source = source;
      Target = target;
      IsDefault = isDefault;
      HasJoinTable = false;
      if (source.FullName == target.FullName)
      {
        IsSelfRelationship = true;
      }
    }

    #endregion

    #region Public Properties
    public RelationshipType RelationshipType { get; set; }
    public string RelationshipName { get; set; }
    public bool IsDefault { get; set; }
    public bool HasJoinTable { get; set; }
    public bool IsBiDirectional { get; set; }

    public Entity Source { get; set; }
    public string SourcePropertyNameForTarget { get; set; }

    public Entity Target { get; set; }
    public string TargetPropertyNameForSource { get; set; }

    public bool IsSelfRelationship { get; set; }
    public string SelfRelationshipEntityName { get; set; }

    public bool Cascade { get; set; }
    public string Label { get; set; }
    public string Description { get; set; }

    public bool SourceAndTargetInSameEntityGroup
    {
      get
      {
        // Determine if the source and target entities belong to different entity groups
        string sourceExtensionName, sourceEntityGroupName, targetExtensionName, targetEntityGroupName;
        Name.GetExtensionAndEntityGroup(Source.FullName, out sourceExtensionName, out sourceEntityGroupName);
        Name.GetExtensionAndEntityGroup(Target.FullName, out targetExtensionName, out targetEntityGroupName);
        if (sourceEntityGroupName.ToLower() != targetEntityGroupName.ToLower() ||
           (sourceEntityGroupName.ToLower() == targetEntityGroupName.ToLower() &&
            sourceExtensionName.ToLower() != targetExtensionName.ToLower()))
        {
          return true;
        }

        return false;
      }
    }
    #endregion

    #region Internal Properties
   
   
    #endregion

    #region Public Static Methods
    //public static RelationshipData GetRelationshipData(XElement relationshipEntityElement)
    //{
    //  var relationshipData = new RelationshipData();

    //  relationshipData.Label = 
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == Entity.LabelAttribute)
    //    .Value;

    //  relationshipData.Description = 
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == Entity.DescriptionAttribute)
    //    .Value;
        
    //  string relationshipType =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.RelationshipTypeAttribute)
    //    .Value;

    //  relationshipData.RelationshipType = 
    //     (RelationshipType)Enum.Parse(typeof (RelationshipType), relationshipType, false);

    //  string cascade =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.CascadeAttribute)
    //    .Value;

    //  relationshipData.Cascade = Convert.ToBoolean(cascade);

    //  relationshipData.RelationshipEntityName = EntityGroupNode.GetEntityFullName(relationshipEntityElement);
      
    //  relationshipData.SourceEntityName =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.SourceEntityNameAttribute)
    //    .Value;

    //  relationshipData.SourceKeyColumnName =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.SourceKeyColumnNameAttribute)
    //    .Value;

    //  relationshipData.SourcePropertyNameForTarget =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.SourcePropertyNameForTargetAttribute)
    //    .Value;

    //  relationshipData.TargetEntityName =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.TargetEntityNameAttribute)
    //    .Value;

    //  relationshipData.TargetKeyColumnName =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.TargetKeyColumnNameAttribute)
    //    .Value;

    //  relationshipData.TargetPropertyNameForSource =
    //    relationshipEntityElement
    //    .Elements(Name.NHibernateNamespace + "meta")
    //    .Single(m => (string)m.Attribute("attribute") == RelationshipEntity.TargetPropertyNameForSourceAttribute)
    //    .Value;

      
    //  SetInterGroup(ref relationshipData);

    //  return relationshipData;
    //}

    //public static void SetInterGroup(ref RelationshipData relationshipData)
    //{
    //  // Determine if the source and target entities belong to different entity groups
    //  string sourceExtensionName, sourceEntityGroupName, targetExtensionName, targetEntityGroupName;
    //  Name.GetExtensionAndEntityGroup(relationshipData.Source.FullName, out sourceExtensionName, out sourceEntityGroupName);
    //  Name.GetExtensionAndEntityGroup(relationshipData.Target.FullName, out targetExtensionName, out targetEntityGroupName);
    //  if (sourceEntityGroupName.ToLower() != targetEntityGroupName.ToLower() ||
    //      (sourceEntityGroupName.ToLower() == targetEntityGroupName.ToLower() && sourceExtensionName.ToLower() != targetExtensionName.ToLower()))
    //  {
    //    relationshipData.IsInterGroup = true;
    //  }
    //}

    #endregion
  }

  [Serializable]
  public class HbmRelationshipData : RelationshipData
  {
    #region Properties
    public string SourceEntityName { get; set; }
    public HbmBag SourceHbmBag { get; set; }
    public HbmClass SourceHbmClass { get; set; }
    public HbmJoinedSubclass SourceHbmJoinedSubclass { get; set; }
    public string SourceKeyColumn { get; set; }


    public string TargetEntityName { get; set; }
    public HbmBag TargetHbmBag { get; set; }
    public HbmClass TargetHbmClass { get; set; }
    public HbmJoinedSubclass TargetHbmJoinedSubclass { get; set; }
    public string TargetKeyColumn { get; set; }

    public List<HbmBag> SelfRelationshipHbmBags { get; set; }

    public string OriginalJoinClassName { get; set; }

    public override string ToString()
    {
      return String.Format("HbmRelationshipData: '{0}' --> '{1}' ", SourceEntityName, TargetEntityName);
    }
    #endregion
  }
  
}
