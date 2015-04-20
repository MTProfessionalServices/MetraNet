using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.CreditNotes;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.CreditNotes;
using MetraTech.DomainModel.AccountTypes;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UI.Common;

public partial class Adjustments_CreateCreditNote : MTPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      lblAccount.Text = String.Format("{0} ({1})", UI.Subscriber.SelectedAccount.UserName, UI.Subscriber.SelectedAccount._AccountID);
      PopulateCreditNotesTemplateTypes();
      PopulateDDTimeInterval();
     }
 
    protected void btnIssueCreditNote_Click(object sender, EventArgs e)
    {
      var errorOccurredForCreditNote = false;
      CreditNoteServiceClient client = null;
      try
      {
        client = new CreditNoteServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }
        Logger.LogDebug("Creating a Credit Note for adjustments with AccountID: {0},  creditNoteTemplateID: {1}, creditNoteDescription: {2}",
                        UI.Subscriber.SelectedAccount._AccountID.Value, ddTemplateTypes.SelectedItem.Value, CommentTextBox.Text);

        client.CreateCreditNote(GetSelectedAdjustments(), 
                                UI.Subscriber.SelectedAccount._AccountID.Value, UI.SessionContext.ToXML(), 
                                Convert.ToInt32(ddTemplateTypes.SelectedValue), CommentTextBox.Text);
      }
      catch (System.ServiceModel.FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogException("Failed to create credit note for the selected adjustments. An unknown exception occurred. Please check system logs.", ex);
        switch (ex.Detail.ErrorCode)
        {
          case ErrorCodes.CREDIT_NOTE_FAILURE_TO_GENERATE_UNIQUE_CREDIT_NOTE_STRING:
            SetError(GetLocalResourceObject("TEXT_ERROR_CREATING_CREDIT_NOTE_UNIQUE_CREDIT_NOTE_STRING").ToString());
            break;
          case ErrorCodes.CREDIT_NOTE_FAILURE_TO_CREATE_CREDIT_NOTE:
          default:
            SetError(GetLocalResourceObject("TEXT_ERROR_CREATING_CREDIT_NOTE").ToString());
            break;
        }
        errorOccurredForCreditNote = true;
      }
	    catch (Exception ex)
      {
        Logger.LogException("Failed to create credit note for the selected adjustments. An unknown exception occurred. Please check system logs.", ex);
        SetError(GetLocalResourceObject("TEXT_ERROR_CREATING_CREDIT_NOTE").ToString());
        errorOccurredForCreditNote = true;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }
      if (!errorOccurredForCreditNote)
      {
        Response.Redirect("ViewCreditNotesIssued.aspx");
      }
      else
      {
        Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
      }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
      Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
    }

    private void PopulateDDTimeInterval()
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
  

    private void PopulateCreditNotesTemplateTypes()
    {
      var errorOccurred = false;
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
      catch (System.ServiceModel.FaultException<MASBasicFaultDetail> ex)
      {
        Logger.LogException("Failed to create credit note for the selected adjustments. An unknown exception occurred. Please check system logs.", ex);
        switch (ex.Detail.ErrorCode)
        {
          case ErrorCodes.CREDIT_NOTE_FAILURE_TO_GENERATE_UNIQUE_CREDIT_NOTE_STRING:
            SetError(GetLocalResourceObject("TEXT_ERROR_CREATING_CREDIT_NOTE_UNIQUE_CREDIT_NOTE_STRING").ToString());
            break;
          case ErrorCodes.CREDIT_NOTE_FAILURE_TO_CREATE_CREDIT_NOTE:
          default:
            SetError(GetLocalResourceObject("TEXT_ERROR_CREATING_CREDIT_NOTE").ToString());
            break;
        }
        errorOccurred = true;
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
        if (errorOccurred) {
          Response.Redirect(UI.DictionaryManager["DashboardPage"].ToString());
        }
      }
   }

    private List<Tuple<long, CreditNoteAdjustmentType>> GetSelectedAdjustments()
    {
      var adjustments = new List<Tuple<long, CreditNoteAdjustmentType>>();
      string[] parsedData = hdSelectedItemsList.Value.Split(new char[] { ',' });
      foreach (string item in parsedData)
      {
        string[] parsedItem = item.Split(new char[] { ';' });
        if (parsedItem.Length > 0)
        {
          adjustments.Add(new Tuple<long, CreditNoteAdjustmentType>(Convert.ToInt64(parsedItem[0]),
                                                                    (parsedItem[1] == "0"
                                                                       ? CreditNoteAdjustmentType.LineAdjustment
                                                                       : CreditNoteAdjustmentType.MiscAdjustment)));
        }
      }
      return adjustments;
    }
}
