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


public partial class Account_AccountLandingPage : MTPage
{
  protected string NoDecisionsText;
  public bool IsPrototypePage { get; set; }
  public bool ShowFinancialData { get; set; } 
  public bool AccountCanSubscribe { get; set; }
  
  public string MetraTimeNow
  {
    get { return ApplicationTime.ToShortDateString(); }
  }

  protected bool isCorporate = false;
  public bool IsCorporate
  {
    get
    {
      return isCorporate;
    }
  }

  protected override void OnInit(EventArgs e)
  {
    //Some experimental settings for now
    IsPrototypePage = true;
    AccountCanSubscribe = true;
  
    CheckIsCorporate();
    base.OnInit(e);
  }

  protected void CheckIsCorporate()
  {
    //if (UI.Subscriber.SelectedAccount != null)
    //{
    //  AccountTypeManager accountTypeManager = new AccountTypeManager();
    //  YAAC.MTYAAC yaac = new YAAC.MTYAAC();
    //  yaac.InitAsSecuredResource((int)UI.Subscriber.SelectedAccount._AccountID,
    //                             (MetraTech.Interop.MTYAAC.IMTSessionContext)UI.SessionContext,
    //                             ApplicationTime);
    //  IMTAccountType accType = accountTypeManager.GetAccountTypeByID((IMTSessionContext)UI.SessionContext,
    //                                                                 yaac.AccountTypeID);
    //  isCorporate = accType.IsCorporate;     
    //}
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    ShowFinancialData = true; //UI.CoarseCheckCapability("View Summary Financial Information");
    if (!IsPostBack)
    {
      NoDecisionsText = string.Format("{0}", GetLocalResourceObject("NO_DECISIONS_TEXT"));
    }
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    //MTGridButton gridButton1 = new MTGridButton();

    //if (UI.Subscriber.SelectedAccount == null)
    //{
    //  gridButton1.ButtonID = GetLocalResourceObject("AddButtonID").ToString();
    //  gridButton1.ButtonText = GetLocalResourceObject("AddButtonText").ToString();
    //  gridButton1.ToolTip = GetLocalResourceObject("AddToolTip").ToString();
    //  gridButton1.JSHandlerFunction = "onAdd";
    //  gridButton1.IconClass = GetLocalResourceObject("AddIconClass").ToString();
    //}
    //else
    //{
    //  if (!isCorporate)
    //  {
    //    gridButton1.ButtonID = GetLocalResourceObject("JoinButtonID").ToString();
    //    gridButton1.ButtonText = GetLocalResourceObject("JoinButtonText").ToString();
    //    gridButton1.ToolTip = GetLocalResourceObject("JoinToolTip").ToString();
    //    gridButton1.JSHandlerFunction = "onJoin";
    //    gridButton1.IconClass = GetLocalResourceObject("JoinIconClass").ToString();
    //  }
    //  else
    //  {
    //    gridButton1.ButtonID = GetLocalResourceObject("AddButtonID").ToString();
    //    gridButton1.ButtonText = GetLocalResourceObject("AddButtonText").ToString();
    //    gridButton1.ToolTip = GetLocalResourceObject("AddToolTip").ToString();
    //    gridButton1.JSHandlerFunction = "onAdd";
    //    gridButton1.IconClass = GetLocalResourceObject("AddIconClass").ToString();
    //  }
    //}
    //this.GroupSubGrid.ToolbarButtons.Add(gridButton1);
  }

}