using System;
using System.Collections.Generic;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class EntityNode
  {
    #region Properties
    public Entity Entity { get; set; }
    public bool IsPersisted { get; set; }
    #endregion

    #region Public Methods
    public override bool Equals(object obj)
    {
      var compareTo = obj as EntityNode;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.Entity.Equals(Entity);
    }

    public override int GetHashCode()
    {
      return Entity.GetHashCode();
    }

    public override string ToString()
    {
      return "EntityNode: " + Entity.FullName;
    }

    #endregion

    #region Internal Methods
    internal EntityNode Clone()
    {
      var entityNode = new EntityNode();
      Entity entity = Entity.Clone();

      foreach (Relationship relationship in Entity.Relationships)
      {
        entity.Relationships.Add(relationship.Clone());
      }

      entityNode.Entity = entity;
      entityNode.IsPersisted = IsPersisted;

      return entityNode;
    }
    #endregion

    #region Private Properties
    #endregion
  }
}
