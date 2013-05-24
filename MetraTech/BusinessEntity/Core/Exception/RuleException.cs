using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;
using MetraTech.Basic.Exception;

namespace MetraTech.BusinessEntity.Core.Exception
{
  [Serializable]
  public class RuleException : BusinessEntityException
  {
    public RuleException()
    { }

    public RuleException(string message)
      : base(message)
    { }

    public RuleException(string message, string component)
      : base(message, component)
    { }

    public RuleException(string message, System.Exception e)
      : base(message, e)
    { }

    public RuleException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    { }

    #region ISerializable
    protected RuleException(SerializationInfo info, StreamingContext context)
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
