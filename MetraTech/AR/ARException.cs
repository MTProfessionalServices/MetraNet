using System;
using System.Runtime.InteropServices;

namespace MetraTech.AR
{

	[ComVisible(false)]
  public class ARException : ApplicationException
  {
    public ARException(string msg)
      : base(msg)
    {
    }

    public ARException(string format, params object[] args)
      : base (String.Format(format, args))
    {
    }
  }
}
