using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Common;

public partial class Adjustments_AjaxServices_CreateCreditNotePDF : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      var response = new AjaxResponse();
      int creditNoteId = Convert.ToInt32(Request.Params["CreditNoteID"]);
      int accountId = Convert.ToInt32(Request.Params["AccountID"]);
      int languageCode = Convert.ToInt32(Request.Params["LanguageCode"]);
      string creditNotePrefix = Convert.ToString(Request.Params["CreditNotePrefix"]);
      string templateName = Convert.ToString(Request.Params["TemplateName"]);
      
      using (new HighResolutionTimer("CreateCreditNotePDF", 5000))
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
          client.CreateCreditNotePDF(creditNoteId, accountId, creditNotePrefix, templateName, languageCode);
          response.Success = true;
          //response.Message = string.Format("Successfully submitted request to generate Credit Note pdf");
          var message = GetGlobalResourceObject("Adjustments", "TEXT_Successfully_submitted_request_to_generate_Credit_Note_pdf");
          if (message != null)
            response.Message = message.ToString();
        }
        catch (FaultException<MASBasicFaultDetail> ex)
        {
          response.Success = false;
          response.Message = ex.Detail.ErrorMessages[0];
          Logger.LogError(ex.Detail.ErrorMessages[0]);
        }
        catch (Exception ex)
        {
          response.Success = false;
          response.Message = ex.Message;
          Logger.LogException("An unknown exception occurred.  Please check system logs.", ex);
          throw;
        }
        finally
        {
          if (client != null)
          {
            client.Abort();
          }
          Response.Write(response.ToJson());
          Response.End();
        }
      }
    }
}