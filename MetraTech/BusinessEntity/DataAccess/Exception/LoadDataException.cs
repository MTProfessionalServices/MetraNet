using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class LoadDataException : BusinessEntityException
  {
    public LoadDataException(string message)
      : base(message)
    { }

    public LoadDataException(string message, System.Exception e)
      : base(message, e)
    {}

    public LoadDataException(string message, List<ErrorObject> errors)
      : base(message, errors)
    {}

    #region ISerializable
    protected LoadDataException(SerializationInfo info, StreamingContext context)
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
