using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
using Resources;
using MetraTech.SecurityFramework;

public partial class MetraControl_FileManagement_FileManagement : MTPage
{
    public string customTitle;
    public string stateFilter = "";
    public string rawFilter = "";
    
    protected void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Manage FLS Files") && !UI.CoarseCheckCapability("View FLS Files"))
      {
        Response.End();
        return;
      }
      rawFilter = Request.QueryString["filter"];
        string customTitle = FileManagementResources.JOB_ALL_TITLE;

		try
		{
            // SECENG: Allow execution without filter
            if (!string.IsNullOrEmpty(rawFilter))
            {
                ApiInput input = new ApiInput(rawFilter);
                SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
            }
		}
		catch (AccessControllerException accessExp)
		{
			Session[Constants.ERROR] = accessExp.Message;
			rawFilter = string.Empty;
		}
		catch (Exception exp)
		{
			Session[Constants.ERROR] = exp.Message;
			throw exp;
		}
			
        if (!String.IsNullOrEmpty(rawFilter))
        {
            if (rawFilter == "0")
            {
              customTitle = FileManagementResources.JOB_PAST_TWO_DAYS_TITLE;
            }
            else if (rawFilter == "1")
            {
              customTitle = FileManagementResources.JOB_PAST_WEEK_TITLE;
            }
            else if (rawFilter == "2")
            {
                customTitle = FileManagementResources.JOB_ACTIVE_TITLE;
                stateFilter = EnumHelper.GetDbValueByEnum(EInvocationState.ACTIVE).ToString();
            }
            else if (rawFilter == "3")
            {
                customTitle = FileManagementResources.JOB_FAILED_TITLE;
                stateFilter = EnumHelper.GetDbValueByEnum(EInvocationState.FAILED).ToString();
            }   
            else if (rawFilter == "4")
            {
                customTitle = FileManagementResources.JOB_COMPLETED_TITLE;
                stateFilter = EnumHelper.GetDbValueByEnum(EInvocationState.COMPLETED).ToString();
            }
            else
            {
              customTitle = FileManagementResources.JOB_ALL_TITLE;
            }
        }

        MTTitle1.Text = customTitle;
    }

    protected override void OnLoadComplete(EventArgs e)
    {
        string filter = Request.QueryString["filter"];
        MTGridDataElement dateElement = MTFilterGrid1.FindElementByID("_DateTime");
        MTGridDataElement stateElement = MTFilterGrid1.FindElementByID("_State");

        if (!String.IsNullOrEmpty(filter) &&
            dateElement != null && stateElement != null)
        {
            if (filter == "0")  // Last 2 Days
            {
                DateTime dt2 = DateTime.Now;
                DateTime dt1 = dt2.AddDays(-1);

              dateElement.ElementValue = dt1.ToString("M/d/yyyy");
              dateElement.ElementValue2 = dt2.ToString("M/d/yyyy");
            }
            else if (filter == "1")  // Last Week
            {
                DateTime dt2 = DateTime.Now;
                DateTime dt1 = dt2.AddDays(-7);

                dateElement.ElementValue = dt1.ToString("M/d/yyyy");
                dateElement.ElementValue2 = dt2.ToString("M/d/yyyy");
            }
            else if (filter == "2") // Active
            {
                stateElement.ElementValue =
                    EnumHelper.GetDbValueByEnum(EInvocationState.ACTIVE).ToString();
                stateElement.ElementValue2 = "ACTIVE";
            }
            else if (filter == "3") // Failed
            {
                stateElement.ElementValue = 
                    EnumHelper.GetDbValueByEnum(EInvocationState.FAILED).ToString();
                stateElement.ElementValue2 = "FAILED";
            }
            else if (filter == "4") // Completed
            {
              stateElement.ElementValue =
                EnumHelper.GetDbValueByEnum(EInvocationState.COMPLETED).ToString();
              stateElement.ElementValue2 = "COMPLETED";
            }
        }

        base.OnLoadComplete(e);
    }
    /// <summary>
    /// Try to parse string
    /// </summary>
    /// <param name="val"></param>
    /// <param name="defaultVal"></param>
    /// <returns></returns>
    public static int TryParseWithDefault(string val, int defaultVal = 0)
    {
        int result;
        return int.TryParse(val, out result) ? result : defaultVal;
    }
}
