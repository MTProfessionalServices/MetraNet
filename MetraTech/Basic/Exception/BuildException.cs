using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace MetraTech.Basic.Exception
{
  [Serializable]
  public class BuildException : BasicException
  {
    public BuildException(string message)
      : base(message)
    { }

    public BuildException(string message, List<ErrorObject> errors, string component)
      : base(message, errors, component)
    {}

    #region ISerializable
    protected BuildException(SerializationInfo info, StreamingContext context)
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
