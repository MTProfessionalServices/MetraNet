using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Core.Common
{
  [Serializable]
  public class DbTableMetadata
  {
    #region Public Methods
    public DbTableMetadata()
    {
      ColumnMetadataList = new List<DbColumnMetadata>();
    }

    public override string ToString()
    {
      return String.Format("DbTableMetadata: TableName = '{0}'", TableName);
    }
    #endregion

    #region Public Properties
    public string TableName { get; set; }
    public bool HasData { get; set; }
    public List<DbColumnMetadata> ColumnMetadataList { get; set; }
    #endregion
  }
}
