using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NHibernate;

namespace MetraTech.BusinessEntity.Test.DataAccess.Dev
{
  public class StandardProcessor : IProcessor
  {
    public void Process(object data, ISession session, bool beforeMethodCall, MethodInfo targetMethodInfo)
    {
      if (beforeMethodCall)
      {
        Console.WriteLine(String.Format("Pre processing data for method '{0}'", targetMethodInfo.Name));
      }
      else
      {
        Console.WriteLine(String.Format("Post processing data for method '{0}'", targetMethodInfo.Name));
      }
    }
  }
}
