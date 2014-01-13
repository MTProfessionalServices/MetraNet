﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.ActivityServices.Common;
using MetraTech.UI.Common;

public partial class Mobile_DeletePaymentMethod : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    string resultSuccess = "{ \"success\": \"true\", \"errorMessage\" : \"\"}";
    string resultFailed = "{ \"success\": \"false\", \"errorMessage\" : \"%%ERROR_MESSAGE%%\" }";

    try
    {
      AccountIdentifier acct = new AccountIdentifier(UI.Subscriber.SelectedAccount._AccountID.Value);
      var metraPayManager = new MetraPayManager(UI);
      metraPayManager.DeletePaymentMethod(acct, new Guid(Request["PIID"]));

      Response.Write(resultSuccess);
    }
    catch (FaultException<MASBasicFaultDetail> fe)
    {
      string message = "";
      foreach (string msg in fe.Detail.ErrorMessages)
      {
        message += msg + " ";
      }
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", message));
    }
    catch (Exception ex)
    {
      Response.Write(resultFailed.Replace("%%ERROR_MESSAGE%%", ex.Message));
      Logger.LogError(ex.Message);
    }
  }
}
