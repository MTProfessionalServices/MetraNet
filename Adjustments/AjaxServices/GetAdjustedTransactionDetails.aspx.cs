using System;
using System.ServiceModel;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

using MetraTech.ActivityServices.Common;
using MetraTech.Debug.Diagnostics;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;

public partial class Adjustments_AjaxServices_GetAdjustedTransactionDetails : MTListServicePage
{
	protected void Page_Load(object sender, EventArgs e)
	{
		using (new HighResolutionTimer("GetAdjustedTransactionDetail", 5000))
		{
			var response = new AjaxResponse();
			AdjustmentsServiceClient client = null;

			try
			{
				client = new AdjustmentsServiceClient();

				if (client.ClientCredentials != null)
				{
					client.ClientCredentials.UserName.UserName = UI.User.UserName;
					client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
				}


				long sessionId = System.Convert.ToInt64(Request.Params["SessionId"]);
				AdjustedTransactionDetail detail;
				client.Open();
				client.GetAdjustedTransactionDetail(sessionId, out detail);

				//CORE-5824 Check if details is null
				var message = GetGlobalResourceObject("Adjustments", "TEXT_Details_for_ajustment_not_found");
        string messageNotFound = "";
        if (message != null)
          messageNotFound = message.ToString();

        string html = detail != null ? GetResponse(detail) : messageNotFound;
        
				Response.Write(html);
				client.Close();
				client = null;
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
				Response.End();
			}
		}
	}

	private string GetResponse(AdjustedTransactionDetail detail)
	{
		StringBuilder html = new StringBuilder();
		html.Append("<table>");
		html.Append("<tr><td>AdjTrxId  : </td><td>  " + detail.AdjTrxId + "</td></tr>");
		html.Append("<tr><td>AdjustmentAmount  : </td><td>  " + detail.AdjustmentAmount + "</td></tr>");
		html.Append("<tr><td>AdjustmentCreationDate  : </td><td>  " + detail.AdjustmentCreationDate + "</td></tr>");
		html.Append("<tr><td>AdjustmentCurrency  : </td><td>  " + detail.AdjustmentCurrency + "</td></tr>");
		html.Append("<tr><td>Status  : </td><td>  " + detail.Status + "</td></tr>");
		html.Append("<tr><td>AdjustmentTemplateDisplayName  : </td><td>  " + detail.AdjustmentTemplateDisplayName + "</td></tr>");
		html.Append("<tr><td>AdjustmentType  : </td><td>  " + detail.AdjustmentType + "</td></tr>");
		html.Append("<tr><td>AdjustmentUsageInterval  : </td><td>  " + detail.AdjustmentUsageInterval + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillAdjAmt  : </td><td>  " + detail.AtomicPostbillAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillAdjedAmt : </td><td>  " + detail.AtomicPostbillAdjedAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillCntyTaxAdjAmt  : </td><td>  " + detail.AtomicPostbillCntyTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillFedTaxAdjAmt  : </td><td>  " + detail.AtomicPostbillFedTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillLocalTaxAdjAmt : </td><td>  " + detail.AtomicPostbillLocalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillOtherTaxAdjAmt : </td><td>  " + detail.AtomicPostbillOtherTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillStateTaxAdjAmt : </td><td>  " + detail.AtomicPostbillStateTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPostbillTotalTaxAdjAmt : </td><td>  " + detail.AtomicPostbillTotalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillAdjAmt : </td><td>  " + detail.AtomicPrebillAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillAdjedAmt : </td><td>  " + detail.AtomicPrebillAdjedAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillCntyTaxAdjAmt : </td><td>  " + detail.AtomicPrebillCntyTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillFedTaxAdjAmt : </td><td>  " + detail.AtomicPrebillFedTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillLocalTaxAdjAmt : </td><td>  " + detail.AtomicPrebillLocalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillOtherTaxAdjAmt : </td><td>  " + detail.AtomicPrebillOtherTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillStateTaxAdjAmt : </td><td>  " + detail.AtomicPrebillStateTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>AtomicPrebillTotalTaxAdjAmt : </td><td>  " + detail.AtomicPrebillTotalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CanAdjust  : </td><td>  " + detail.CanAdjust + "</td></tr>");
		html.Append("<tr><td>CanManageAdjustments  : </td><td>  " + detail.CanManageAdjustments + "</td></tr>");
		html.Append("<tr><td>CanManagePostbillAdjustment  : </td><td>  " + detail.CanManagePostbillAdjustment + "</td></tr>");
		html.Append("<tr><td>CanManagePrebillAdjustment  : </td><td>  " + detail.CanManagePrebillAdjustment + "</td></tr>");
		html.Append("<tr><td>CanRebill  : </td><td>  " + detail.CanRebill + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillAdjAmt  : </td><td>  " + detail.CompoundPostbillAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillAdjedAmt  : </td><td>  " + detail.CompoundPostbillAdjedAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillCntyTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillCntyTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillFedTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillFedTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillLocalTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillLocalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillOtherTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillOtherTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillStateTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillStateTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPostbillTotalTaxAdjAmt  : </td><td>  " + detail.CompoundPostbillTotalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillAdjAmt  : </td><td>  " + detail.CompoundPrebillAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillAdjedAmt  : </td><td>  " + detail.CompoundPrebillAdjedAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillCntyTaxAdjAmt : </td><td>  " + detail.CompoundPrebillCntyTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillFedTaxAdjAmt  : </td><td>  " + detail.CompoundPrebillFedTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillLocalTaxAdjAmt  : </td><td>  " + detail.CompoundPrebillLocalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillOtherTaxAdjAmt  : </td><td>  " + detail.CompoundPrebillOtherTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompoundPrebillTotalTaxAdjAmt  : </td><td>  " + detail.CompoundPrebillTotalTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CompundPrebillStateTaxAdjAmt  : </td><td>  " + detail.CompundPrebillStateTaxAdjAmt + "</td></tr>");
		html.Append("<tr><td>CountyTaxAmount  : </td><td>  " + detail.CountyTaxAmount + "</td></tr>");
		html.Append("<tr><td>Description  : </td><td>  " + detail.Description + "</td></tr>");
		html.Append("<tr><td>DivAmount  : </td><td>  " + detail.DivAmount + "</td></tr>");
		html.Append("<tr><td>DivCurrency   : </td><td>  " + detail.DivCurrency + "</td></tr>");
		html.Append("<tr><td>FederalTaxAmount  : </td><td>  " + detail.FederalTaxAmount + "</td></tr>");
		html.Append("<tr><td>LanguageCode : </td><td>  " + detail.LanguageCode + "</td></tr>");
		html.Append("<tr><td>LocalTaxAmount : </td><td>  " + detail.LocalTaxAmount + "</td></tr>");
		html.Append("<tr><td>ModifedDate  : </td><td>  " + detail.ModifedDate + "</td></tr>");
		html.Append("<tr><td>NumPostbillAdjustedChildren  : </td><td>  " + detail.NumPostbillAdjustedChildren + "</td></tr>");
		html.Append("<tr><td>NumPrebillAdjustedChildren  : </td><td>  " + detail.NumPrebillAdjustedChildren + "</td></tr>");
		html.Append("<tr><td>OtherTaxAmount : </td><td>  " + detail.OtherTaxAmount + "</td></tr>");
		if (detail.ParentSessionId == 0)
			html.Append("<tr><td>ParentSessionId : </td><td> </td></tr>");
		else
			html.Append("<tr><td>ParentSessionId : </td><td>  " + detail.ParentSessionId + "</td></tr>");
		html.Append("<tr><td>PendingPostbillAdjAmt  : </td><td>  " + detail.PendingPostbillAdjAmt + "</td></tr>");
		html.Append("<tr><td>PendingPrebillAdjAmt  : </td><td>  " + detail.PendingPrebillAdjAmt + "</td></tr>");
		html.Append("<tr><td>PITemplateDisplayName : </td><td>  " + detail.PITemplateDisplayName + "</td></tr>");
		html.Append("<tr><td>PostbillAdjAmt  : </td><td>  " + detail.PostbillAdjAmt + "</td></tr>");
		html.Append("<tr><td>PostbillAdjDefaultDesc : </td><td>  " + detail.PostbillAdjDefaultDesc + "</td></tr>");
		html.Append("<tr><td>PostbillAdjustmentDescription : </td><td>  " + detail.PostbillAdjustmentDescription + "</td></tr>");
		html.Append("<tr><td>PrebillAdjAmt : </td><td>  " + detail.PrebillAdjAmt + "</td></tr>");
		html.Append("<tr><td>PrebillAdjDefaultDesc : </td><td>  " + detail.PrebillAdjDefaultDesc + "</td></tr>");
		html.Append("<tr><td>PrebillAdjustmentDescription : </td><td>  " + detail.PrebillAdjustmentDescription + "</td></tr>");
		html.Append("<tr><td>ReasonCodeDescription : </td><td>  " + detail.ReasonCodeDescription + "</td></tr>");
		html.Append("<tr><td>ReasonCodeDisplayName : </td><td>  " + detail.ReasonCodeDisplayName + "</td></tr>");
		html.Append("<tr><td>ReasonCodeId  : </td><td>  " + detail.ReasonCodeId + "</td></tr>");
		html.Append("<tr><td>ReasonCodeName : </td><td>  " + detail.ReasonCodeName + "</td></tr>");
		html.Append("<tr><td>SessionId : </td><td>  " + detail.SessionId + "</td></tr>");
		html.Append("<tr><td>StateTaxAmount : </td><td>  " + detail.StateTaxAmount + "</td></tr>");
		html.Append("<tr><td>UsageIntervalId : </td><td>  " + detail.UsageIntervalId + "</td></tr>");
		html.Append("<tr><td>UserNamePayee : </td><td>  " + detail.UserNamePayee + "</td></tr>");
		html.Append("<tr><td>UserNamePayer : </td><td>  " + detail.UserNamePayer + "</td></tr>");
		html.Append("</table>");

		return html.ToString();
	}

}