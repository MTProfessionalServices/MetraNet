using System;
using System.Collections.Generic;
using QuickGraph;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class RelationshipEdge : Edge<EntityNode>
  {
    #region Properties
    public RelationshipEntity RelationshipEntity
    {
      get { return RelationshipEntities.Find(r => r.IsDefault); }
    }
    public bool IsExtension { get; set; }
    public List<RelationshipEntity> RelationshipEntities { get; set; }
    #endregion

    #region Public Methods
    public RelationshipEdge(EntityNode source, EntityNode target)
      : base(source, target)
    {
      RelationshipEntities = new List<RelationshipEntity>();
    }

    public List<RelationshipEntity> GetJoinTableRelationshipEntities()
    {
      return RelationshipEntities.FindAll(r => r.HasJoinTable);
    }

    public RelationshipEntity GetRelationshipEntity(string relationshipName)
    {
      return RelationshipEntities.Find(r => r.RelationshipName == relationshipName);
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as RelationshipEdge;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && 
             compareTo.RelationshipEntity != null && 
             compareTo.RelationshipEntity.Equals(RelationshipEntity);
    }

    public override int GetHashCode()
    {
      return RelationshipEntity.GetHashCode();
    }

    public override string ToString()
    {
      return RelationshipEntity.SourceEntityName + " => " +
             RelationshipEntity.TargetEntityName + " (" +
             RelationshipEntity.RelationshipType + ")";
      
    }
    #endregion
  }
}
