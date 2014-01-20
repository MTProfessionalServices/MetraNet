using System;
using System.Linq;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using System.Collections.Generic;
using System.Diagnostics;
using MetraTech.Approvals;
using System.Text;
using System.Threading;

public partial class Notifications_NotificationEndpointList : MTPage
{
    public string strShowChangeState { get; set; } //so we can read it any time in the session 
    public string strdefaultchangeidload { get; set; }

    public void Page_Load(object sender, EventArgs e)
    {
      //if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
      //  Response.End();

      //strShowChangeState = Request.QueryString["showchangestate"];
      //Session["strChangeState"] = strShowChangeState;

      ////lblShowChangesSummaryTitle.Text = "All Changes";
      ////ChangesSummary.Title = "All Changes Summary";

      //if (strShowChangeState == "PENDING")
      //{
      //  lblShowChangesSummaryTitle.Text = "Pending Changes";
      //  ChangesSummary.Title = "Pending Changes Summary";
      //}

      //if (strShowChangeState == "FAILED")
      //{
      //  lblShowChangesSummaryTitle.Text = "Failed Changes";
      //  ChangesSummary.Title = "Failed Changes Summary";
      //}
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      //SetPageTitleFromQueryString();
      //ApprovalsConfiguration approvalConfig = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
      //SetChangeTypeFilterOptions(ChangesSummary, this.ApprovalConfiguration);
      //SetDefaultFilterFromQueryString(ChangesSummary);

      base.OnLoadComplete(e);
    }

    /// <summary>
    /// Sets the default filter from query string.
    /// </summary>
    /// <param name="grid">The grid.</param>
    /// <remarks></remarks>
    protected void SetDefaultFilterFromQueryString(MTFilterGrid grid)
    {
      if (grid == null)
        return;

      string sFilterSerialized = Request["Filter_" + grid.ID + "_ChangeType"];
      if (!string.IsNullOrEmpty(sFilterSerialized))
      {
        try
        {
          ApiInput input = new ApiInput(sFilterSerialized);
          SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(
            AccessControllerEngineCategory.UrlController.ToString(), input);
        }
        catch (AccessControllerException accessExp)
        {
          Session[Constants.ERROR] = accessExp.Message;
          sFilterSerialized = string.Empty;
        }
        catch (Exception exp)
        {
          Session[Constants.ERROR] = exp.Message;
          throw;
        }

        try
        {
          MTGridDataElement el = grid.FindElementByID("ChangeType");
          if (el != null)
          {
            el.ElementValue = sFilterSerialized;
          }
        }
        catch (Exception)
        {
          // continue rendering the grid anyway
        }
      }

      sFilterSerialized = Request.QueryString["Filter_" + grid.ID + "_ChangeState"];
      if (!string.IsNullOrEmpty(sFilterSerialized))
      {
        try
        {
          ApiInput input = new ApiInput(sFilterSerialized);
          SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(
            AccessControllerEngineCategory.UrlController.ToString(), input);
        }
        catch (AccessControllerException accessExp)
        {
          Session[Constants.ERROR] = accessExp.Message;
          sFilterSerialized = string.Empty;
        }
        catch (Exception exp)
        {
          Session[Constants.ERROR] = exp.Message;
          throw;
        }

        try
        {
          MTGridDataElement el = grid.FindElementByID("CurrentState");
          if (el != null)
          {
            el.ElementValue = sFilterSerialized;
          }
        }
        catch (Exception)
        {
          // continue rendering the grid anyway
        }
      }

      sFilterSerialized = Request["Filter_" + grid.ID + "_UniqueItemId"];
      if (!string.IsNullOrEmpty(sFilterSerialized))
      {
        try
        {
          ApiInput input = new ApiInput(sFilterSerialized);
          SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(
            AccessControllerEngineCategory.UrlController.ToString(), input);
        }
        catch (AccessControllerException accessExp)
        {
          Session[Constants.ERROR] = accessExp.Message;
          sFilterSerialized = string.Empty;
        }
        catch (Exception exp)
        {
          Session[Constants.ERROR] = exp.Message;
          throw;
        }

        try
        {
          MTGridDataElement el = grid.FindElementByID("UniqueItemId");
          if (el != null)
          {
            el.ElementValue = sFilterSerialized;
          }
        }
        catch (Exception)
        {
          // continue rendering the grid anyway
        }
      }
    }

    //Move this to MTFilterGrid
    public static MTGridDataElement FindElementByID(MTFilterGrid MyGrid1, string elementID)
    {
        foreach (MTGridDataElement element in MyGrid1.Elements)
        {
            if (element.ID.ToLower() == elementID.ToLower())
            {
                return element;
            }
        }

        return null;
    }

 
    
}