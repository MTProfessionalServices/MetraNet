using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Common
{
  public static class Constants
  {
    public const string JavaScriptSection = "JavaScriptSection";
    public const string StyleSection = "StyleSection";
    public const string MAIN_MENU = "MainMenu";
    public const string ACCOUNT_MENU = "AccountMenu";
    public const string METRACARE_MENU = "MetraCareMenu";
    public const string METRACONTROL_MENU = "MetraControlMenu";
    public const string METRAOFFER_MENU = "MetraOfferMenu";
    public const string AGREEMENTS_MENU = "AgreementMenu";
    public const string ADMIN_MENU = "AdminMenu";
    public const string TOP_MENU = "TopMenu";
    public const string BILL_SUB_MENU = "BillSubMenu";
    public const string ACCOUNT_SUB_MENU = "AccountInfoSubMenu";
    public const string ERROR = "MTError";
    public const string UI_MANAGER = "MTUIManager";
    public const string SELECTED_LANGUAGE = "MTSelectedLanguage";
    public const string HELP_PAGE = "MTHelpPage";
    public const string STATE = "MTState";
    public const string PROCESSOR = "MTProcessor";
    public const string CACHED_RESPONSE_DATA = "MTCachedResponseData";
    public const string PAGE_NAV_DATA = "MTPageNavData";
    public const string RECENT_ACCOUNT_LIST = "MTRecentAccounts";
    public const string INTERFACE_NAME = "InterfaceName";
    public const string APP_TIME = "MTAppTime";
    public const string REPORT_SUB_MENU = "ReportSubMenu";
    public const string DEFAULT_ACCOUNT_HIERARCHY_CONTEXT_MENU = "DefaultAccountHierarchyContextMenu";

    // For d.ToString(), where d is a Decimal with a scale of 10
    public const string NUMERIC_FORMAT_STRING_DECIMAL_NO_TRAILING_ZEROS = "0.##########";
    public const string NUMERIC_FORMAT_STRING_DECIMAL_MIN_TWO_DECIMAL_PLACES = "0.00########";

    public const string PAGE_RUNNING_FROM_METRANET = "RunningFromMetraNet";
    public const string CJ_PROTECTION_CODE = "<style type='text/css'>html{display:none;}</style><script type='text/javascript'>var A;try {A = top.location.href;} catch (ex) {}if (!A) {window.location='noframes.html';}else {document.documentElement.style.display = 'block';}</script>";

    // Session keys used by the AMP Wizard:
    public const string AMP_CURRENT_PAGE = "AmpCurrentPage";
    public const string AMP_NEXT_PAGE = "AmpNextPage";
    public const string AMP_PREVIOUS_PAGE = "AmpPreviousPage";
    public const string AMP_DECISION_NAME = "AmpDecisionName";
    public const string AMP_ACTION = "AmpAction";
    public const string AMP_ISERRORCHECKED = "AmpIsErrorChecked";
    public const string AMP_CHARGE_CREDIT_ACTION = "AmpChargeCreditAction";
    public const string AMP_CHARGE_CREDIT_NAME = "AmpChargeCreditName";
    public const string AMP_ACCOUNT_QUALIFICATION_GROUP_NAME = "AmpAccountQualificationGroupName";
    public const string AMP_ACCOUNT_QUALIFICATION_GROUP_ACTION = "AmpAccountQualificationGroupAction";
    public const string AMP_USAGE_QUALIFICATION_ACTION = "AmpUsageQualificationAction";
  }
}
