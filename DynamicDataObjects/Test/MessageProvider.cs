using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.DynamicDataObjects.Samples
{
  /// <summary>
  /// Class used to test basic NHibernate interaction
  /// </summary>
  public class MessageProvider
  {
    public MessageProvider() { }
    public virtual int Id
    {
      get { return this.id; }
      set { this.id = value; }
    }
    public virtual string Message
    {
      get { return this.message; }
      set { this.message = value; }
    }
    private int id;
    private string message;
  }
}
