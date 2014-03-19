using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.CreditNotes;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;

public partial class Adjustments_CreateCreditNote : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      lblAccount.Text = String.Format("{0} ({1})", UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount._AccountID);
      populateCreditNotesTemplateTypes();
      populateDDTimeInterval();

      ddTimeIntervals.Attributes.Add("onChange", "return onChange();");
     }
 
  protected void btnIssueCreditNote_Click(object sender, EventArgs e)
  {
    throw new NotImplementedException();
  }

  protected void btnCancel_Click(object sender, EventArgs e)
  {
    throw new NotImplementedException();
  }

    private void populateDDTimeInterval()
    {

      List<string> items = new List<string>(GetLocalResourceObject("ddTimeIntervalsResource1.Text").ToString().Split(','));
      int i = 0;
      foreach (var item in items)
      {
        ddTimeIntervals.Items.Add(new ListItem { Text = item, Value = i.ToString() });
        if (item.ToLower().Contains("30"))
          ddTimeIntervals.SelectedIndex = i;

        i++;
      }
    }
  

    private void populateCreditNotesTemplateTypes()
    {
      CreditNoteServiceClient client = null;

      try
      {
        client = new CreditNoteServiceClient();

        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        LanguageCode? languageCode = ((InternalView)UI.Subscriber.SelectedAccount.GetInternalView()).Language;

        var items = new MTList<CreditNoteTmpl>();
        client.GetCreditNoteTemplates(ref items, Convert.ToInt32(EnumHelper.GetValueByEnum(languageCode, 1)));
        if (items.Items.Count == 0)
        {
          items = new MTList<CreditNoteTmpl>();
          client.GetCreditNoteTemplates(ref items, Convert.ToInt32(EnumHelper.GetValueByEnum(LanguageCode.US, 1)));
        }

        foreach (var item in items.Items)
        {
          ddTemplateTypes.Items.Add(new ListItem(item.TemplateName, item.CreditNoteTemplateID.ToString()));
        }
      }
      catch (Exception ex)
      {
        Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }
   }
}
