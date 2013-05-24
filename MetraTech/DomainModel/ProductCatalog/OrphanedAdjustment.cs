using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.Web.Script.Serialization;

using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.BaseTypes;

namespace MetraTech.DomainModel.ProductCatalog
{
  [DataContract]
  [Serializable]

  public class OrphanedAdjustment : BaseObject
  {
    #region SessionId
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    private bool isSessionIdDirty = false;
    private int m_SessionId;
    [MTDataMember(Description = "This is the session id.", Length = 40)]
    [DataMember(IsRequired = false, EmitDefaultValue = false)]
    public int SessionId
    {
      get { return m_SessionId; }
      set
      {
          m_SessionId = value;
          isSessionIdDirty = true;
      }
    }
	[ScriptIgnore]
    public bool IsSessionIdDirty
    {
      get { return isSessionIdDirty; }
    }
    #endregion
  }
}
