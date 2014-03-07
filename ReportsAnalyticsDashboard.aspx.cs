using System;
using MetraTech.UI.Common;

public partial class ReportsAnalyticsDashboard : MTPage
{
  protected long previousMonth = (new DateTime(DateTime.Now.ToUniversalTime().AddMonths(-1).Year, DateTime.Now.ToUniversalTime().AddMonths(-1).Month, 1).Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
  protected long firstMonth = (new DateTime(DateTime.Now.ToUniversalTime().AddMonths(-13).Year, DateTime.Now.ToUniversalTime().AddMonths(-13).Month, 1).Ticks - new DateTime(1970, 1, 1).Ticks) / 10000;
}
