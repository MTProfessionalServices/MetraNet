using System;
using System.Collections.Generic;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [Serializable]
  public class EntityChangeSet
  {
    #region Public Methods

    public EntityChangeSet(string entityName, string tableName)
    {
      EntityName = entityName;
      TableName = tableName;
      InsertSelectColumnNameValues = new Dictionary<string, string>();
    }

    public override string ToString()
    {
      return String.Format("EntityChangeSet: TableName = '{0}'", TableName);
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as EntityChangeSet;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.TableName.ToLower() == TableName.ToLower();
    }

    public override int GetHashCode()
    {
      return TableName.GetHashCode();
    }

    #endregion
    public bool BackupOnly { get; set; }
    public string EntityName { get; set; }
    public string TableName { get; set;}
    public Dictionary<string, string> InsertSelectColumnNameValues { get; set; }
  }
}
