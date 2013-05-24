using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Security.Permissions;
using System.Text;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class AssertionException : DesignByContractException
  {
    public AssertionException()
    {}

    public AssertionException(string message)
      : base(message)
    {}

    public AssertionException(string message, string component)
      : base(message, component)
    {}

    public AssertionException(string message, System.Exception e)
      : base(message, e)
    {}


    public AssertionException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected AssertionException(SerializationInfo info, StreamingContext context)
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
