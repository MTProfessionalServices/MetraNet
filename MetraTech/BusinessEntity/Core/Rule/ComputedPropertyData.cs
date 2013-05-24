using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;

using MetraTech.Basic;
using MetraTech.Basic.Config;

namespace MetraTech.BusinessEntity.Core.Rule
{
  [Serializable]
  public class ComputedPropertyData
  {
    #region Public Properties
    public string EntityName { get; set; }
    public string PropertyName { get; set; }
    public string Code { get; set; }
    public string ComputationTypeName { get; private set; }
    public string FileName { get; private set; }
    public string ExtensionName  { get; private set; }
    public string EntityGroupName { get; private set; }
    #endregion

    #region Public Methods
    public ComputedPropertyData(string entityName, string propertyName)
    {
      EntityName = entityName;
      PropertyName = propertyName;
      string extensionName, entityGroupName;
      Name.GetExtensionAndEntityGroup(entityName, out extensionName, out entityGroupName);
      ExtensionName = extensionName;
      EntityGroupName = entityGroupName;
      ComputationTypeName = Name.GetEntityClassName(entityName) + "_" + propertyName;
      FileName = ComputationTypeName + ".cs";
      ReferenceAssemblies = new List<ReferenceAssembly>();
    }

    /// <summary>
    ///   Provide assembly name with the .dll extension and without any path.
    ///   The assembly must exist in RMP\Bin
    /// </summary>
    /// <param name="referenceAssembly"></param>
    public void AddReferenceAssembly(ReferenceAssembly referenceAssembly)
    {
      Check.Require(referenceAssembly != null, "referenceAssembly cannot be null");

      Check.Require(referenceAssembly.Name.EndsWith(".dll"), 
                    String.Format("Specified assembly name '{0}' does not have a .dll extension", referenceAssembly),
                    SystemConfig.CallerInfo);

      Check.Require(String.IsNullOrEmpty(Path.GetDirectoryName(referenceAssembly.Name)),
                    String.Format("Specified assembly name '{0}' must not have path information", referenceAssembly),
                    SystemConfig.CallerInfo);
   
      Check.Require(!ReferenceAssemblies.Contains(referenceAssembly),
                    String.Format("Specified assembly name '{0}' has already been added", referenceAssembly),
                    SystemConfig.CallerInfo);

      ReferenceAssemblies.Add(referenceAssembly);
    }

    public void RemoveReferenceAssembly(ReferenceAssembly referenceAssembly)
    {
      Check.Require(ReferenceAssemblies.Contains(referenceAssembly),
                    String.Format("Specified assembly name '{0}' has not been added", referenceAssembly),
                    SystemConfig.CallerInfo);

      ReferenceAssemblies.Remove(referenceAssembly);
    }

    public List<ReferenceAssembly> GetReferenceAssemblies()
    {
      var referenceAssemblies = new List<ReferenceAssembly>(ReferenceAssemblies);
      return referenceAssemblies;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as ComputedPropertyData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null &&
             compareTo.EntityName == EntityName &&
             compareTo.PropertyName == PropertyName;
    }

    public override int GetHashCode()
    {
      return (EntityName + "." + PropertyName).GetHashCode();
    }

    public override string ToString()
    {
      return String.Format("ComputedPoperty: Entity='{0}', Property='{1}'", EntityName, PropertyName);
  }

    public void Validate()
    {
      Check.Require(!String.IsNullOrEmpty(EntityName), "EntityName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(PropertyName), "PropertyName cannot be null or empty");
      Check.Require(!String.IsNullOrEmpty(Code), "Code cannot be null or empty");
    }

    #endregion

    #region Internal Properties
    internal List<ReferenceAssembly> ReferenceAssemblies { get; set; }
 
    #endregion

    
  }

 
}
