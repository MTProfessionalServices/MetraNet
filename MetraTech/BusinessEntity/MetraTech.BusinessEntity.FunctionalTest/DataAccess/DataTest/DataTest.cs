using System;
using MetraTech.BusinessEntity.DataAccess.Persistence;

namespace MetraTech.BusinessEntity.Test.DataAccess.DataTest
{
  public class DataTest
  {
    #region Public Methods
    public static void Initialize()
    {
      if (!initialized)
      {
        RepositoryAccess.Instance.Initialize();
        initialized = true;
      }
    }
    #endregion

    #region Data

    private static bool initialized;
    internal static Random Random = new Random();

    #endregion
  }
}
