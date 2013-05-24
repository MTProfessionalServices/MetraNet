using System;
using System.Runtime.Serialization;

namespace Core.Common
{
  [Serializable]
  [DataContract]
  public class EntitySyncData
  {
    [DataMember]
    public virtual Guid Id { get; set; }

    [DataMember]
    public virtual string EntityName { get; set; }

    [DataMember]
    public virtual string HbmChecksum { get; set; }

    [DataMember]
    public virtual DateTime SyncDate { get; set; }

    public override string ToString()
    {
      return String.Format("EntitySyncData: Entity = '{0}'", EntityName);
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as EntitySyncData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.EntityName == EntityName;
    }

    public override int GetHashCode()
    {
      return EntityName.GetHashCode();
    }

    public virtual EntitySyncData Clone()
    {
      return new EntitySyncData() {EntityName = EntityName, HbmChecksum = HbmChecksum, Id = Id, SyncDate = SyncDate};
    }
  }
}

