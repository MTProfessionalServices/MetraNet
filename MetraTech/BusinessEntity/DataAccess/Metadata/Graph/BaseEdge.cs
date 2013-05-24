using System;
using QuickGraph;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class BaseEdge : Edge<EntityNode>
  {
    #region Properties
    protected virtual string Label { get { return Source + " --> " + Target; } }
    #endregion

    public BaseEdge(EntityNode source, EntityNode target)
      : base(source, target)
    {
    }

    public override string ToString()
    {
      return Label;
    }

    #region Internal Methods
    internal BaseEdge Clone()
    {
      var baseEdge = new BaseEdge(Source.Clone(), Target.Clone());
      return baseEdge;
    }
    #endregion
    
  }
}
