

using System;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  [Serializable]
  public class SubClassEdge : BaseEdge
  {
    #region Properties
    #endregion

    #region Public Methods
    public SubClassEdge(EntityNode source, EntityNode target)
      : base(source, target)
    {
    }
    #endregion

    
  }
}
