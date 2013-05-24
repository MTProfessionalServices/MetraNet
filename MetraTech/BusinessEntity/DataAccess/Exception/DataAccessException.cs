using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class DataAccessException : BusinessEntityException
  {
    public DataAccessException(string message)
      : base(message)
    { }

    public DataAccessException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    {}

    public DataAccessException(string message, string component)
      : base(message, component)
    {}

    public DataAccessException(string message, System.Exception e)
      : base(message, e)
    { }

    public DataAccessException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected DataAccessException(SerializationInfo info, StreamingContext context)
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
