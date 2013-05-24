using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Exception
{
  [Serializable]
  public class BusinessEntityException : BasicException
  {
    public BusinessEntityException()
    { }

    public BusinessEntityException(string message)
      : base(message)
    { }

    public BusinessEntityException(string message, string component)
      : base(message, component)
    { }

    public BusinessEntityException(string message, List<ErrorObject> errors)
      : base(message, errors)
    { }

    public BusinessEntityException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    { }

    public BusinessEntityException(System.Exception e)
      : base(e)
    { }

    public BusinessEntityException(System.Exception e, string component)
      : base(e, component)
    { }

    public BusinessEntityException(string message, System.Exception e)
      : base(message, e)
    { }


    public BusinessEntityException(string message, System.Exception e, string component)
      : base(message, e, component)
    { }

    public BusinessEntityException(string message, List<ErrorObject> errors, System.Exception e)
      : base(message, errors, e)
    { }

    public BusinessEntityException(string message, List<ErrorObject> errors, System.Exception e, string component)
      : base(message, errors, e, component)
    { }

    #region ISerializable
    protected BusinessEntityException(SerializationInfo info, StreamingContext context)
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
