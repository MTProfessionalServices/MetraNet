using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Rule
{
  [Serializable]
  [DataContract(IsReference = true)]
  public class RuleData : ICloneable
  {
    [DataMember]
    public string EntityName { get; set; }
    [DataMember]
    public CRUDEvent Event { get; set; }
    [DataMember]
    public string Name { get; set; }
    [DataMember]
    public string Description { get; set; }
    [DataMember]
    public int Priority { get; set; }
    [DataMember]
    public bool Enabled { get; set; }
    
    [DataMember]
    public string AssemblyQualifiedTypeName { get; set; }

    public List<ErrorObject> Validate()
    {
      var errors = new List<ErrorObject>();
      if (String.IsNullOrEmpty(AssemblyQualifiedTypeName))
      {
        string message = "AssemblyQualifedName cannot be null or empty";
        errors.Add(new ErrorObject(message));
      }

      return errors;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as RuleData;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.AssemblyQualifiedTypeName == AssemblyQualifiedTypeName;
    }

    public override int GetHashCode()
    {
      return AssemblyQualifiedTypeName.GetHashCode();
    }

    public object Clone()
    {
      return MemberwiseClone();
    }
  }

  public class RuleDataPrioritySorter : IComparer<RuleData>
  {
    public int Compare(RuleData ruleData1, RuleData ruleData2)
    {
      return ruleData1.Priority.CompareTo(ruleData2.Priority);
    }
  }
}
