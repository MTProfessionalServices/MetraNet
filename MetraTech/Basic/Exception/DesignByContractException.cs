using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Security.Permissions;
using System.Text;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class DesignByContractException : BasicException
  {
    public DesignByContractException()
    {}

    public DesignByContractException(string message)
      : base(message)
    {}

    public DesignByContractException(string message, string component)
      : base(message, component)
    {}

    public DesignByContractException(string message, System.Exception e)
      : base(message, e)
    {}


    public DesignByContractException(string message, System.Exception e, string component)
      : base(message, e, component)
    {}

    #region ISerializable
    protected DesignByContractException(SerializationInfo info, StreamingContext context)
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
