using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace MetraTech.Basic
{
  [Serializable]
  public class ReferenceAssembly
  {
    #region Public Methods
    public ReferenceAssembly(string name)
    {
      Check.Require(!String.IsNullOrEmpty(name), "name cannot be null or empty");
      Name = name;
      IsSystem = false;
      UseRmpBinForBuild = true;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as ReferenceAssembly;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.Name == Name &&
             compareTo.IsSystem == IsSystem;
    }

    public override int GetHashCode()
    {
      return Path.GetFileName(Name).GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("ReferenceAssembly: Name='{0}'", Name);
    }
    #endregion

    #region Properties
    public string Name { get; set; }
    public bool IsSystem { get; set; }
    public bool UseRmpBinForBuild { get; set; }
    #endregion

  }
}
