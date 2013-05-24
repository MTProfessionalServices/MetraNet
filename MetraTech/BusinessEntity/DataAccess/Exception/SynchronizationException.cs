using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Runtime.Serialization;
using System.Security.Permissions;

using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.Core.Exception;

namespace MetraTech.BusinessEntity.DataAccess.Exception
{
  [Serializable]
  public class SynchronizationException : BusinessEntityException
  {
    public SynchronizationException()
    {}

    public SynchronizationException(string message)
      : base(message)
    {}

    public SynchronizationException(string message, string component)
      : base(message, component)
    {}

    public SynchronizationException(string message, List<ErrorObject> errors)
      : base(message, errors)
    {}
    
    public SynchronizationException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    {}

    public SynchronizationException(System.Exception e)
      : base(e)
    {}

    public SynchronizationException(System.Exception e, string component)
      : base(e, component)
    {}

    public SynchronizationException(string message, System.Exception e)
      : base(message, e)
    {}


    public SynchronizationException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    public SynchronizationException(string message, List<ErrorObject> errors, System.Exception e)
      : base(message, errors, e)
    {}

    public SynchronizationException(string message, List<ErrorObject> errors, System.Exception e, string component)
      : base(message, errors, e, component)
    { }

    #region ISerializable
    protected SynchronizationException(SerializationInfo info, StreamingContext context)
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
