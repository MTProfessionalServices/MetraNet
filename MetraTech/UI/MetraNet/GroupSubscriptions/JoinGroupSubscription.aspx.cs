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

public partial class GroupSubscriptions_JoinGroupSubscription : MTPage
{

  public string MetraTimeNow
  {
    get { return ApplicationTime.ToShortDateString(); }
  }


}