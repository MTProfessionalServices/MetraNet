
using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class PreconditionException : DesignByContractException
  {
    public PreconditionException()
    {}

    public PreconditionException(string message)
      : base(message)
    {}

    public PreconditionException(string message, string component)
      : base(message, component)
    {}

    public PreconditionException(string message, System.Exception e)
      : base(message, e)
    {}


    public PreconditionException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected PreconditionException(SerializationInfo info, StreamingContext context)
      : base(info, context)
    {
    }

    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
      base.GetObjectData(info, context);
    }
    #endregion
  }
}
