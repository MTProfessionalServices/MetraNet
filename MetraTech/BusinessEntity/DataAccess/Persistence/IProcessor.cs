using System.Reflection;
using NHibernate;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public interface IProcessor
  {
    /// <summary>
    ///    
    /// </summary>
    /// <param name="data"></param>
    /// <param name="session"></param>
    /// <param name="beforeMethodCall">true, if this is being called before the targetMethod is called</param>
    /// <param name="targetMethodInfo"></param>
    void Process(object data, ISession session, bool beforeMethodCall, MethodInfo targetMethodInfo);
  }
}
