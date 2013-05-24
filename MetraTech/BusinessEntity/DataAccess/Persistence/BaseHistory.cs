using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Text;
using MetraTech.BusinessEntity.DataAccess.Metadata;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  [DataContract(IsReference = true)]
  [Serializable]
  public abstract class BaseHistory : DataObject
  {
    #region Public Methods
    public abstract DataObject GetDataObject();
    #endregion

    #region Public Properties
    [DataMember]
    public virtual DateTime _StartDate { get; set; }
    [DataMember]
    public virtual DateTime _EndDate { get; set; }
    #endregion

    public const string StartDatePropertyName = "_StartDate";
    public const string EndDatePropertyName = "_EndDate";

  }
}
