using System;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;
using System.Collections.Generic;
using System.Diagnostics;
using MetraTech.Approvals;
using System.Text;
using System.Threading;

public partial class ApprovalFrameworkManagement_ShowChangesSummary : MTPage
{
    public string strShowChangeState { get; set; } //so we can read it any time in the session 
    public string strdefaultchangeidload { get; set; }

    protected static ApprovalsConfiguration approvalConfiguration;
    public ApprovalsConfiguration ApprovalConfiguration
    {
      get
      {
        if( approvalConfiguration == null)
        {
          var newApprovalConfiguration = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
          if(Interlocked.CompareExchange(ref approvalConfiguration, newApprovalConfiguration, null) != null)
          {
              if (newApprovalConfiguration is IDisposable) ((IDisposable)newApprovalConfiguration).Dispose();
          }
        }

        return approvalConfiguration;
      }
    }

    public void Page_Load(object sender, EventArgs e)
    {
      if (!UI.CoarseCheckCapability("Allow ApprovalsView"))
        Response.End();

      strShowChangeState = Request.QueryString["showchangestate"];
      Session["strChangeState"] = strShowChangeState;

      lblShowChangesSummaryTitle.Text = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_ALL_CHANGES"));
      ChangesSummary.Title = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_ALL_CHANGES") + " " + GetLocalResourceObject("TEXT_SUMMARY"));

      if (strShowChangeState == "PENDING")
      {
        lblShowChangesSummaryTitle.Text = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_PENDING_CHANGES"));
        ChangesSummary.Title = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_PENDING_CHANGES") + " " + GetLocalResourceObject("TEXT_SUMMARY"));
      }

      if (strShowChangeState == "FAILED")
      {
        lblShowChangesSummaryTitle.Text = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_FAILED_CHANGES"));
        ChangesSummary.Title = Convert.ToString(GetLocalResourceObject("TEXT_APPROVAL_FAILED_CHANGES") + " " + GetLocalResourceObject("TEXT_SUMMARY"));
      }
    }

    protected override void OnLoadComplete(EventArgs e)
    {
      //SetPageTitleFromQueryString();
      //ApprovalsConfiguration approvalConfig = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();
      SetChangeTypeFilterOptions(ChangesSummary, this.ApprovalConfiguration);
      SetDefaultFilterFromQueryString(ChangesSummary);

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

    public void SetChangeTypeFilterOptions(MTFilterGrid MyGrid1, ApprovalsConfiguration approvalConfiguration)
    {
        MTGridDataElement changeTypeElement = FindElementByID(MyGrid1, "ChangeType");
        if (changeTypeElement == null)
        {
            return;
        }

        List<string> sortList = new List<string>();
        Dictionary<string, string> map = new Dictionary<string, string>();
        List<string> exList = new List<string>();

        //ApprovalsConfiguration approvalConfig = ApprovalsConfigurationManager.LoadChangeTypesFromAllExtensions();

        foreach (ChangeTypeConfiguration changeConfig in approvalConfiguration.Values)
        {
            if (changeConfig.Enabled)
            {
                sortList.Add(changeConfig.Name); //TODO: Use/Get Localized value
                map[changeConfig.Name] = changeConfig.Name; //TODO: First value should be localized value used in the line above
            }
        }

        sortList.Sort();
        
        foreach (string sortedItem in sortList)
        {
            MTFilterDropdownItem filterItem = new MTFilterDropdownItem();
            filterItem.Key = map[sortedItem].ToString();
            filterItem.Value = sortedItem;
            changeTypeElement.FilterDropdownItems.Add(filterItem);
        }
    }

    public string GenerateJavascriptForChangeTypeConfiguration()
    {
      return GenerateJavascriptForChangeTypeConfiguration(this.ApprovalConfiguration);
    }

    public string GenerateJavascriptForChangeTypeConfiguration(ApprovalsConfiguration approvalConfiguration)
    {
      var sb = new StringBuilder();
      sb.Append("var changeTypesConfiguration = {};" + Environment.NewLine);

      foreach (var changeConfiguration in approvalConfiguration.Values)
      {
        if (changeConfiguration.LocalizationTag == null) continue;

        var safeChangeConfigName = changeConfiguration.Name.Replace("'", "\\'");
        var safeApprovalsUrl = TranslateApprovalsUrl(changeConfiguration.WebpageForView != null
                                                       ? changeConfiguration.WebpageForView.URL
                                                       : "").Replace("'", "\\'");
        var safeWebpageForEdit = changeConfiguration.WebpageForEdit != null
                                   ? changeConfiguration.WebpageForEdit.URL
                                   : "".Replace("'", "\\'");
        var gridTitle = GetGlobalResourceObject("JSConsts", changeConfiguration.LocalizationTag);
        if (gridTitle == null)
        {
          throw new NullReferenceException(
            String.Format("LocalizationTag '{0}' not found in Global Resources for localization 'JSConsts'",
                          changeConfiguration.LocalizationTag));
        }
        var safeGridTitle = gridTitle.ToString().Replace("'", "\\'");

        sb.Append(
          string.Format(
            "changeTypesConfiguration['{0}'] = {{WebpageForView: '{1}', WebpageForEdit: '{2}', GridTitle: '{3}' }};{4}",
            safeChangeConfigName, safeApprovalsUrl, safeWebpageForEdit, safeGridTitle, Environment.NewLine));
      }

      return sb.ToString();
    }

    public const string TAG_CHANGE_ID = "%%CHANGE_ID%%";
    public const string TAG_CHANGE_STATE = "%%CHANGE_STATE%%";

    public string TranslateApprovalsUrl(string url)
    {
      
      string approvalUrl = url;

      if (string.IsNullOrEmpty(approvalUrl) || approvalUrl.Contains(TAG_CHANGE_ID))
        return approvalUrl;

      //UriBuilder uri = new UriBuilder(url);
      //uri.SetQueryParam("ChangeId","{ChangeId}");
      if (approvalUrl.Contains("?"))
        approvalUrl += "&ChangeId=" + TAG_CHANGE_ID;
      else
        approvalUrl += "&ChangeId=" + TAG_CHANGE_ID;

      return approvalUrl;
    }

    public string GenerateJavascriptForUserChangeTypeCapabilities()
    {
      return GenerateJavascriptForUserChangeTypeCapabilities(this.ApprovalConfiguration);
    }

    public string GenerateJavascriptForUserChangeTypeCapabilities(ApprovalsConfiguration approvalConfiguration)
    {
      /*
        var userCapabilities = {};
        userCapabilities['AccountUpdate']     =  true;
        userCapabilities['ProductOfferingUpdate'] = true;
        userCapabilities['RateUpdate']  = true;
       */
      ApprovalManagementImplementation approvals = new ApprovalManagementImplementation(approvalConfiguration, UI.SessionContext);

      StringBuilder sb = new StringBuilder();
      sb.Append("var userCapabilities = {};" + System.Environment.NewLine);
      foreach (string changeTypeName in approvals.GetChangeTypesUserIsAllowedToWorkWith())
      {
        sb.Append("userCapabilities['" + changeTypeName + "'] = true;" + System.Environment.NewLine);
      }

      return sb.ToString();
    }
    
}