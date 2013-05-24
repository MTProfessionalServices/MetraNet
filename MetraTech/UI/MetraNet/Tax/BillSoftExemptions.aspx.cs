using System;
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.UI.Common;

public partial class Tax_BillSoftExemptions : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string action = Request["Action"];
    
    if (!String.IsNullOrEmpty(action))
    {
      if (action.ToLower().Equals("delete"))
      {
        int id = System.Convert.ToInt32(Request["ExemptionId"]);
        TaxServiceClient client = null;
        try
        {
          client = new TaxServiceClient();
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;

          client.Open();
          client.DeleteBillSoftExemption(id);
          client.Close();
          client = null;
        }
        catch (FaultException<MASBasicFaultDetail> ex)
        {
          SetError(ex.Detail.ErrorMessages[0]);
        }
        catch (Exception ex)
        {
          SetError("An unknown exception occurred. Please check system logs: " + ex);
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
  }
}