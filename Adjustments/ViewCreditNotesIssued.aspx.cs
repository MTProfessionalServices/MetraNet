using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.CreditNotes;


public partial class Adjustments_ViewCreditNotesIssued : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    
  }

  protected override void OnLoadComplete(EventArgs e)
  {
    string accountsFilterValue = Request["Accounts"];

    if (!String.IsNullOrEmpty(accountsFilterValue))
    {
      if (accountsFilterValue == "ALL")
      {
        CreditNotesGrid.DataSourceURL =
          @"/MetraNet/Adjustments/AjaxServices/LoadCreditNotesIssued.aspx?Accounts=ALL";
        lblViewCreditNotesTitle.Visible = false;
      }
    }
    PopulatePDFStatusesDropdown();
  }

  private void PopulatePDFStatusesDropdown()
  {
    MTGridDataElement ddStatuses = CreditNotesGrid.FindElementByID("CreditNotePDFStatusLocalized") as MTGridDataElement;
    if (ddStatuses == null) return;
    ddStatuses.FilterDropdownItems.Clear();

    foreach(PDFStatus status in GetPDFStatuses())
    {
      var dropDownItem = new MTFilterDropdownItem();
      dropDownItem.Key = dropDownItem.Value = status.statusName;
      ddStatuses.FilterDropdownItems.Add(dropDownItem);
    }
  }

  private List<PDFStatus> GetPDFStatuses()
  {
    string cacheKey = "PDFStatuses_" + UI.SessionContext.LanguageID.ToString();
    List<PDFStatus> pdfStatuses = new List<PDFStatus>();
    List<PDFStatus> cachedPdfStatuses = (List<PDFStatus>)HttpContext.Current.Application[cacheKey];

    if (cachedPdfStatuses == null)
    {
      using (var client = new CreditNoteServiceClient())
      {
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        client.GetCreditNotePDFStatuses(ref pdfStatuses, UI.SessionContext.LanguageID);
      }
      HttpContext.Current.Application[cacheKey] = pdfStatuses;
    }
    else
    {
      pdfStatuses = cachedPdfStatuses;
    }
    return pdfStatuses;
  }
}