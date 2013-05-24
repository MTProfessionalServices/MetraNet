using System;
using System.Collections.Generic;
using MetraTech.BusinessEntity.Core;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  /// <summary>
  ///   Represents a BME assembly. 
  /// </summary>
  [Serializable]
  public class AssemblyNode
  {
    #region Properties
    public string ExtensionName { get; set; }
    public string EntityGroupName { get; set; }
    public string AssemblyName { get; private set; }
   
    #endregion

    #region Public Methods
    public AssemblyNode(string extensionName, string entityGroupName)
    {
      ExtensionName = extensionName;
      EntityGroupName = entityGroupName;
      AssemblyName = Name.GetEntityAssemblyName(ExtensionName, EntityGroupName).ToLower() + ".dll"; 
    }

    public AssemblyNode Clone()
    {
      var assemblyNode = new AssemblyNode(ExtensionName, EntityGroupName);
      return assemblyNode;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as AssemblyNode;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && 
             compareTo.ExtensionName.ToLower() == ExtensionName.ToLower() &&
             compareTo.EntityGroupName.ToLower() == EntityGroupName.ToLower();
    }

    public override int GetHashCode()
    {
      return (ExtensionName + ExtensionName).GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("AssemblyName: '{0}', Extension: '{1}', Entity Group: '{2}'", AssemblyName, ExtensionName, EntityGroupName);
    }

    #endregion

    #region Internal Methods
   
    #endregion

    #region Private Properties
    #endregion
  }
}
