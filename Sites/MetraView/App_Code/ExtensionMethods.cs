using System;
using System.Threading;
using System.Web;
using MetraTech.Common;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums.PaymentSvrClient.Metratech_com_paymentserver;

/// <summary>
/// ExtensionMethods used to get date and amount display values for the user
/// </summary>
public static class ExtensionMethods
{

  public static DateTime GetUserDate(this DateTime value,  UIManager ui)
  {
    var tId = SiteConfig.Profile.Timezone != null ? SiteConfig.Profile.Timezone.Value : TimeZoneID._GMT_05_00__Eastern_Time__US___Canada_;

    var billManager = new BillManager(ui);
    var languageCode = billManager.GetLanguageCode();
    var timeZoneId = int.Parse(EnumHelper.GetValueByEnum(tId).ToString());
    value = DateTime.FromOADate((double)billManager.GetLocaleTranslator(languageCode).GetDateTime(value, timeZoneId, value.IsDaylightSavingTime()));

    return value;
  }

  public static DateTime FromUserDateToUtc(this DateTime value, UIManager ui)
  {
    return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(value, "GMT Standard Time");
  }

  public static string ToUserDateString(this DateTime value, UIManager ui)
  {
    var d = GetUserDate(value, ui);
    return d.ToShortDateString();
  }

  public static string ToUserTimeString(this DateTime value, UIManager ui)
  {
    var d = GetUserDate(value, ui);
    return d.ToShortTimeString();
  }

  public static string ToUserDateTimeString(this DateTime value, UIManager ui)
  {
    var d = GetUserDate(value, ui);
    return d.ToString();
  }

  public static string ToDisplayAmount(this decimal value, UIManager ui)
  {
    // Get the currency off the invoiceReport
    var billManager = new BillManager(ui);
    var invoiceReport = billManager.GetInvoiceReport(false);
    string currency;
    if(invoiceReport == null || 
       invoiceReport.InvoiceHeader == null || 
       invoiceReport.InvoiceHeader.Currency == null)
    {
      currency = ((InternalView) ui.Subscriber.SelectedAccount.GetInternalView()).Currency;
    }
    else
    {
      currency = invoiceReport.InvoiceHeader.Currency;
    }

    var displayAmount = LCConfigManager.Instance.GetLocalizeAmount(value, Thread.CurrentThread.CurrentUICulture.ToString().ToLower(), currency);
    return displayAmount;
  }

  public static string ToSmallString(this string value)
  {
    string str;
    if((value.Length > 10) && !(value.Length < 13))
    {
      str = value.Substring(0, 10);
      str += "...";
    }
    else
    {
      str = value;
    }
    return str;
  }

  public static string GetLocalizedBankAccountType(string bankAccountType)
  {
    object localResourceObject = null;
    switch (bankAccountType)
    {
      case "Checking":
        localResourceObject = HttpContext.GetGlobalResourceObject("Resource", "TEXT_CHECKING");
        break;
      case "Savings":
        localResourceObject = HttpContext.GetGlobalResourceObject("Resource", "TEXT_SAVINGS");
        break;
    }
    return localResourceObject != null ? localResourceObject.ToString() : bankAccountType;
  }


}
