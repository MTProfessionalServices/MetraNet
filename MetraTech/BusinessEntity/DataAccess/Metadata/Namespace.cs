using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;

using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  [DataContract]
  [Serializable]
  public class Namespace : Metadata
  {
    #region Properties
    [DataMember]
    public string Name { get; set; }

    private IList<Entity> entities = new List<Entity>();
    /// <summary>
    ///    
    /// </summary>
    [DataMember]
    public virtual IList<Entity> Entities
    {
      get { return entities; }
    }
    #endregion

    #region Validation
    public override bool Validate(out List<ErrorObject> validationErrors)
    {
      validationErrors = new List<ErrorObject>();

      return validationErrors.Count > 0 ? false : true;
    }
    #endregion
  }
}
