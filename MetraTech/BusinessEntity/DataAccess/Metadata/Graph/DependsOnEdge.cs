
using System;
using QuickGraph;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  /// <summary>
  ///   Source depends on Target ie. target must be built before source.
  /// </summary>
  [Serializable]
  public class DependsOnEdge : Edge<AssemblyNode>
  {
    #region Properties
    #endregion

    public DependsOnEdge(AssemblyNode source, AssemblyNode target)
      : base(source, target)
    {
    }

    public DependsOnEdge Clone()
    {
      var dependsOnEdge = new DependsOnEdge(Source.Clone(), Target.Clone());
      return dependsOnEdge;
    }

    public override bool Equals(object obj)
    {
      var compareTo = obj as DependsOnEdge;

      if (ReferenceEquals(this, compareTo))
      {
        return true;
      }

      return compareTo != null && compareTo.Source.Equals(Source) && compareTo.Source.Equals(Target);
    }

    public override int GetHashCode()
    {
      return (Source.ExtensionName + Source.EntityGroupName + Target.ExtensionName + Target.EntityGroupName).GetHashCode();;
    }

    public override string ToString()
    {
      return Source.AssemblyName + " depends on " + Target.AssemblyName;
    }
  }
}
