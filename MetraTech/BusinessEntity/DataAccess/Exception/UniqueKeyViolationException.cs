using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class UniqueKeyViolationException : BusinessEntityException
  {
    public UniqueKeyViolationException(string message, System.Exception e)
      : base(message, e)
    {}

    public UniqueKeyViolationException(string message, List<ErrorObject> errors)
      : base(message, errors)
    {}

    #region ISerializable
    protected UniqueKeyViolationException(SerializationInfo info, StreamingContext context)
      : base(info, context)
    {
    }

    [SecurityPermissionAttribute(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
      base.GetObjectData(info, context);
    }
    #endregion
  }
}
