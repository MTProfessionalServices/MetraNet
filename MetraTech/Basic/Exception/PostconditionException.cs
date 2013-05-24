
using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class PostconditionException : DesignByContractException
  {
    public PostconditionException()
    {}

    public PostconditionException(string message)
      : base(message)
    {}

    public PostconditionException(string message, string component)
      : base(message, component)
    {}

    public PostconditionException(string message, System.Exception e)
      : base(message, e)
    {}


    public PostconditionException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected PostconditionException(SerializationInfo info, StreamingContext context)
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
