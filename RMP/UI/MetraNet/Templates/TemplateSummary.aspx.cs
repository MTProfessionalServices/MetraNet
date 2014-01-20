using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;

using MetraTech.DomainModel;
using MetraTech.PageNav.ClientProxies;
using MetraTech.SecurityFramework;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;

public partial class Templates_TemplateSummary : MTPage
{
    #region Inline JavaScript
    string js = @"Ext.onReady(function(){
                        var moveNote = new Ext.Panel({
                            width: '50%',
                            bodyStyle  : 'padding: 10px; background-color: #DFE8F6',
                            html: '<img border=\'0\' style=\'padding-right: 5px; \' src=\'/Res/Images/Icons/information.png\'><b>[MESSAGE]</b><br/><br/><div style=\'padding-left:30px;\'>[MOVED_ACCOUNT_TYPES]</div>',
                            renderTo: 'panelMessage'
                        });
                    });";
    #endregion

    #region Properties
    private string movedAccountTypes = null;
    public string MovedAccountTypes
    {
        get { return movedAccountTypes; }
        set { movedAccountTypes = value; }
    }

    private string hideMovedAccountTypes = null;
    public string HideMovedAccountTypes
    {
        get { return hideMovedAccountTypes; }
        set { hideMovedAccountTypes = value; }
    }

    private string hideMessage = "none";
    public string HideMessage
    {
        get { return hideMessage; }
        set { hideMessage = value; }
    }
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            ArrayList movedTypes = PageNav.Data.Out_StateInitData["MovedTypes"] as ArrayList;
            if (movedTypes != null && movedTypes.Count > 0)
            {
                movedAccountTypes = "<ul>";
                foreach (string accType in movedTypes)
                {
                    // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                    // Added JavaScript encoding
                    //movedAccountTypes += "<li>- " + accType.Replace("'", "\\'") + "</li>";
                    movedAccountTypes += "<li>- " + accType.EncodeForJavaScript() + "</li>";
                }
                movedAccountTypes += "</ul>";
                // SECENG: CORE-4749 CLONE - MSOL BSS 28320 MetraCare: Incorrect Output Encoding on Account Pages (SecEx)
                // Added JavaScript encoding
                //js = js.Replace("[MESSAGE]", this.GetLocalResourceObject("MESSAGE").ToString().Replace("'", "\\'"));
                js = js.Replace("[MESSAGE]", this.GetLocalResourceObject("MESSAGE").ToString().EncodeForJavaScript());
                hideMovedAccountTypes = js.Replace("[MOVED_ACCOUNT_TYPES]", movedAccountTypes);
                hideMessage = "block";
            }
            else
            {
                hideMessage = "none";
                hideMovedAccountTypes = "";
            }
        }
        catch (Exception)
        {
            // continue rendering page
        }

    }

}