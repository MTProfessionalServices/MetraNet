using NHibernate.Driver;

namespace MetraTech.BusinessEntity.DataAccess.Persistence
{
  public class MTOracleDataClientDriver : OracleDataClientDriver
  {
    public override bool SupportsMultipleQueries
    {
      get { return true; }
    }
  }
}
