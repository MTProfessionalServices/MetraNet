
using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class InvariantException : DesignByContractException
  {
    public InvariantException()
    {}

    public InvariantException(string message)
      : base(message)
    {}

    public InvariantException(string message, string component)
      : base(message, component)
    {}

    public InvariantException(string message, System.Exception e)
      : base(message, e)
    {}


    public InvariantException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected InvariantException(SerializationInfo info, StreamingContext context)
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
