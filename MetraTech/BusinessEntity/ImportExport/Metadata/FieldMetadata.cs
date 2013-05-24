using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.ImportExport.Metadata
{
  public class FieldMetadata
  {
    public string Name;
    public PropertyType Type;
    public bool isRequired;
    public int Length;

    /// <summary>
    /// Compare two fields, put description of differences in the differences list
    /// </summary>
    /// <param name="src">The first FieldMetadata to compare</param>
    /// <param name="dst">The second FieldMetadata to compare</param>
    /// <param name="differences">list of differences</param>
    /// <returns>true if filds are the same, false if different</returns>
    public static bool Equals(FieldMetadata src, FieldMetadata dst, List<string> differences)
    {
      if (differences == null) differences = new List<string>();
      if (src == null || dst == null)
      {
        differences.Add("can not compare null fields");
        return false;
      }
      bool equal = true;
      if (src.Name != dst.Name)
      {
        equal = false;
        differences.Add(string.Format("name is different {0}, {1}", src.Name, dst.Name));
      }
      if (src.Length != dst.Length)
      {
        equal = false;
        differences.Add(string.Format("length is different {0}, {1}", src.Length, dst.Length));
      }
      if (src.isRequired != dst.isRequired)
      {
        equal = false;
        differences.Add(string.Format("IsRequired is different {0}, {1}", src.isRequired, dst.isRequired));
      }
      if (src.Type != dst.Type)
      {
        equal = false;
        differences.Add(string.Format("Type is different {0}, {1}", src.Type.ToString(), dst.Type.ToString()));
      }
      return equal;
    }
  }

}
