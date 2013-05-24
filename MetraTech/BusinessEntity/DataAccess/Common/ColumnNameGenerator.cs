using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.Basic;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Common
{
  public static class ColumnNameGenerator
  {
    public static string CreateColumnName(Property property, Entity entity)
    {
      Check.Require(property != null, String.Format("property cannot be null"));
      Check.Require(entity != null, String.Format("Cannot create column name without the parent entity"));
      
      if (!String.IsNullOrEmpty(property.ColumnName))
      {
        return property.ColumnName;
      }

      string columnName = property.Name.Length > 28 ? property.Name.Substring(0, 28) : property.Name;

      // Check for duplicates
      foreach (Property entityProperty in entity.Properties)
      {
        if (entityProperty.Name == property.Name) continue;

        if (entityProperty.ColumnName == columnName)
        {
          string uniqueifier = Math.Abs((Guid.NewGuid().ToString()).GetHashCode()).ToString();

          if (columnName.Length > 22)
          {
            columnName = columnName.Remove(columnName.Length - 6);
          }

          columnName = columnName + (uniqueifier.Length > 6 ? uniqueifier.Substring(0, 6) : uniqueifier);
        }
      }

      return "c_" + columnName;
    }
  }
}
