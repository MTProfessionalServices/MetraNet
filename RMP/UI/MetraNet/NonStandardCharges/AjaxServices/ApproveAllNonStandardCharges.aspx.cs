using System;
using System.ServiceModel;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.ProductView;
using MetraTech.UI.Common;

public partial class NonStandardCharges_AjaxServices_ApproveAllNonStandardCharges : MTListServicePage
{
    protected void Page_Load(object sender, EventArgs e)
    {
      var response = new AjaxResponse();
      using (new HighResolutionTimer("ApproveAllNonstandardCharges", 5000))
      {
        NonStandardChargeServiceClient client = null;

        try
        {
          client = new NonStandardChargeServiceClient();

          if (client.ClientCredentials != null)
          {
            client.ClientCredentials.UserName.UserName = UI.User.UserName;
            client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
          }

          MTList<Metratech_com_NonStandardChargeProductView> charges = new MTList<Metratech_com_NonStandardChargeProductView>();
          // set the sorting anf filtering, but don't pass the paging back
          SetSorting(charges);
          SetFilters(charges);

          client.Open();
          client.ApproveAllNonStandardCharges(ref charges);
          response.Success = true;          
          var message = GetGlobalResourceObject("Adjustments", "TEXT_Successfully_approved_all_selected_charges");
          if (message != null)
            response.Message = message.ToString(); 
          client.Close();
          client = null;
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