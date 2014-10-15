using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.DomainModel;
using MetraTech.UI.Controls;
using System.Globalization;
using System.Reflection;
using System.Resources;
using MetraTech.Interop.IMTAccountType;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.DataAccess;

public partial class DataExportReportManagement_ShowAllReportDefinitions : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    if (!UI.CoarseCheckCapability("Manage DataExportFramework"))
    {
      Response.End();
      return;
    }

  }
}