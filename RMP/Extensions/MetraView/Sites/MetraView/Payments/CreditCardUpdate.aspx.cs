using System;
using System.Globalization;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.DomainModel.MetraPay;
using MetraTech.ActivityServices.Common;

public partial class Payments_CreditCardUpdate : MTPage
{
  private Guid PIID
  {
    get
    {
      var sPIID = Request.QueryString["piid"];
      if (String.IsNullOrEmpty(sPIID))
      {
        return new Guid();
      }

      try
      {
        return new Guid(sPIID);
      }
      catch
      {
        return new Guid();
      }
    }
  }

  public CreditCardPaymentMethod CreditCard
  {
    get
    {
      if (ViewState["CreditCard"] == null)
      {
        ViewState["CreditCard"] = new CreditCardPaymentMethod();
      }
      return ViewState["CreditCard"] as CreditCardPaymentMethod;
    }
    set { ViewState["CreditCard"] = value; }
  }

  protected void Page_Load(object sender, EventArgs e)
  {
    //Validate input
    if (String.IsNullOrEmpty(Request.QueryString["piid"]))
    {
      SetError(Resources.ErrorMessages.ERROR_CC_LOAD);
      Logger.LogError("Unable to load Credit Card: empty PIID");
      return;
    }

    if (IsPostBack) return;
    //populate priorities
    PopulatePriority();

    for (var i = 1; i <= 12; i++)
    {
      var monthStr = i.ToString(CultureInfo.InvariantCulture);
      var month = (i < 10) ? "0" + monthStr : monthStr;
      ddExpMonth.Items.Add(month);
    }

    var curYear = DateTime.Today.Year;
    for (var i = 0; i <= 20; i++)
    {
      ddExpYear.Items.Add((curYear + i).ToString(CultureInfo.InvariantCulture));
    }

    try
    {
      //Load payment method
      var acct = UI.Subscriber.SelectedAccount._AccountID == null
                   ? null
                   : new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManger = new MetraPayManager(UI);
      var tmpCC = metraPayManger.GetPaymentMethodDetail(acct, PIID);
      CreditCard = (CreditCardPaymentMethod) tmpCC;
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_LOAD);
      Logger.LogError(ex.Message);
      return;
    }

    if (!MTDataBinder1.DataBind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }

    //populate exp month and year
    LoadExpDate();

    //load current priority
    LoadPriority();
  }

  protected void btnOK_Click(object sender, EventArgs e)
  {
    if (!MTDataBinder1.Unbind())
    {
      Logger.LogError(MTDataBinder1.BindingErrors.ToHtml());
    }
    CreditCard.ExpirationDate = ddExpMonth.SelectedValue + "/" + ddExpYear.SelectedValue;
    CreditCard.ExpirationDateFormat = MTExpDateFormat.MT_MM_slash_YYYY;

    if (CreditCard.Priority == null) return;
    var oldPriority = CreditCard.Priority.Value;
    CreditCard.Priority = Int32.Parse(ddPriority.SelectedValue);

    try
    {
      var acct = UI.Subscriber.SelectedAccount._AccountID == null
                   ? null
                   : new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManger = new MetraPayManager(UI);
      metraPayManger.UpdatePaymentMethod(acct, PIID, CreditCard, oldPriority);

      Response.Redirect("ViewPaymentMethods.aspx", false);
    }
    catch (Exception ex)
    {
      SetError(Resources.ErrorMessages.ERROR_CC_UPDATE);
      Logger.LogError(ex.Message);
    }
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    Response.Redirect("ViewPaymentMethods.aspx");
  }

  #region Private methods

  protected int GetTotalCards()
  {
    var metraPayManger = new MetraPayManager(UI);
    var cardList = metraPayManger.GetPaymentMethodSummaries();
    return cardList.TotalRows > 0 ? cardList.TotalRows : 0;
  }

  protected void PopulatePriority()
  {
    var totalCards = GetTotalCards();
    for (var i = 1; i <= totalCards; i++)
    {
      var item = i.ToString(CultureInfo.InvariantCulture);
      ddPriority.Items.Add(new ListItem(item, item));
    }
  }

  protected void LoadPriority()
  {
    var priority = 0;

    if (CreditCard.Priority.HasValue)
    {
      priority = CreditCard.Priority.Value;
    }

    ddPriority.SelectedValue = priority.ToString(CultureInfo.InvariantCulture);
  }

  protected void LoadExpDate()
  {
    if (String.IsNullOrEmpty(CreditCard.ExpirationDate))
    {
      return;
    }

    string expMonth;
    string expYear;

    CreditCard.GetExpirationDate(out expMonth, out expYear);

    ddExpMonth.SelectedValue = expMonth;
    ddExpYear.SelectedValue = expYear;
  }

  #endregion
}