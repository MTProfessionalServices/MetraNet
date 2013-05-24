using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class InvalidPropertyTypeException : BusinessEntityException
  {
    public InvalidPropertyTypeException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    {}

    #region ISerializable
    protected InvalidPropertyTypeException(SerializationInfo info, StreamingContext context)
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
