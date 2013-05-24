using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class DeleteDataException : BusinessEntityException
  {
    public DeleteDataException(string message)
      : base(message)
    { }

    public DeleteDataException(string message, System.Exception e)
      : base(message, e)
    {}

    public DeleteDataException(string message, List<ErrorObject> errors)
      : base(message, errors)
    {}

    #region ISerializable
    protected DeleteDataException(SerializationInfo info, StreamingContext context)
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
