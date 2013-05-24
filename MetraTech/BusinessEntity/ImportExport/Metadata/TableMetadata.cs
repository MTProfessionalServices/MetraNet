using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.IO;

using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.ImportExport.Metadata
{
  public class TableMetadata
  {
    // full name of the entity i.e. Core.UI.Site
    public string EntityFullName;
    // name of the table in the database
    public string Name;
    public List<FieldMetadata> Fields = new List<FieldMetadata>();

    public string FileName
    {
      get
      {
        return EntityFullName.Replace('.','#');
      }
    }

    public void SaveMetadataToFile(string Directory)
    {
      XmlSerializer xs = new XmlSerializer(typeof(TableMetadata));
      using (StreamWriter writer = new StreamWriter(string.Format(@"{0}\{1}.meta.xml", Directory, FileName)))
      {
        xs.Serialize(writer, this);
      }
    }

    public static TableMetadata ReadMetadataFromFile(string Directory, string Name)
    {
      XmlSerializer xs = new XmlSerializer(typeof(TableMetadata));
      using (StreamReader reader = new StreamReader(string.Format(@"{0}\{1}.meta.xml", Directory, Name.Replace('.', '#'))))
      {
        object o = xs.Deserialize(reader);
        return (TableMetadata)o;
      }
    }

    public static TableMetadata ReadMetadataFromEntity(Entity entity)
    {
      TableMetadata table = new Metadata.TableMetadata();
      table.Name = entity.TableName;
      table.EntityFullName = entity.FullName;
      List<Property> tableColumnProperties = entity.GetDatabaseProperties();
      foreach (Property property in tableColumnProperties)
      {
        Metadata.FieldMetadata field = new Metadata.FieldMetadata();
        field.Name = property.ColumnName;
        field.Type = property.PropertyType;
        field.Length = property.Length;
        field.isRequired = property.IsRequired;
        table.Fields.Add(field);
      }
      return table;
    }

    /// <summary>
    /// Compare two TableMetadata, put description of differences in the differences list
    /// </summary>
    /// <param name="src">The first TableMetadata to compare</param>
    /// <param name="dst">The second TableMetadata to compare</param>
    /// <param name="differences">list of differences</param>
    /// <returns>true if filds are the same, false if different</returns>
    public static bool Equals(TableMetadata src, TableMetadata dst, List<string> differences)
    {
      if (differences == null) differences = new List<string>();
      if (src == null || dst == null)
      {
        differences.Add("can not compare null tables");
        return false;
      }
      bool equal = true;
      if (src.Name != dst.Name)
      {
        equal = false;
        differences.Add(string.Format("table names are different {0}, {1}", src.Name, dst.Name));
        return equal;
      }
      if (src.Fields.Count != dst.Fields.Count)
      {
        equal = false;
        differences.Add(string.Format("field count is different {0}, {1}",
          src.Fields.Count,
          dst.Fields.Count));
      }
      foreach (FieldMetadata srcField in src.Fields)
      {
        IEnumerable<FieldMetadata> dstFieldQuery = from fld in dst.Fields
                                                   where fld.Name == srcField.Name
                                                   select fld;
        if (dstFieldQuery.Count() == 0)
        {
          equal = false;
          differences.Add(string.Format("Field {0} is missing", srcField.Name));
        }
        FieldMetadata dstField = dstFieldQuery.FirstOrDefault();
        if (dstField == null)
        {
        }
        else
        {
          List<string> fieldDifferences = new List<string>();
          bool fieldsEqual = FieldMetadata.Equals(srcField, dstField, fieldDifferences);
          if (!fieldsEqual)
          {
            equal = false;
            differences.Add(string.Format("Field {0} has differences", srcField.Name));
            differences.AddRange(fieldDifferences);
          }
        }
      }
      return equal;
    }

  }
}
