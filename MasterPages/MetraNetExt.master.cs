using System;
using System.Configuration;
using System.Web.UI.WebControls;
using MetraTech;
using MetraTech.Interop.MTYAAC;
using MetraTech.Security;
using MetraTech.UI.Common;
using MetraTech.PageNav.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.Accounts.Type;
using YAAC = MetraTech.Interop.MTYAAC;

public partial class MasterPages_MetraNetExt : System.Web.UI.MasterPage
{
    public string LoadUserAccount = "#";
    public string StartingURL = "/MetraNet/Welcome.aspx";
    public string SubscriberInfo;
    public string UserInfo;
    public int UserId;
    public string MenuContainers;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session[Constants.APP_TIME] == null)
        {
            Session[Constants.APP_TIME] = MetraTime.Now;
        }
        tbAppTime.Text = ((DateTime)Session[Constants.APP_TIME]).ToShortDateString();

        // TODO:  Add supported languages or get from query
        ddLanguage.Items.Add(new ListItem(Resources.Resource.TEXT_AUTO, "Auto"));
        ddLanguage.Items.Add(new ListItem(Resources.Resource.TEXT_EN_US, "en-US"));
        ddLanguage.Items.Add(new ListItem(Resources.Resource.TEXT_FR, "fr"));

        if (BaseUI.Subscriber.SelectedAccount != null)
        {
            SubscriberInfo = String.Format("{0} ({1})", BaseUI.Subscriber.SelectedAccount.UserName, BaseUI.Subscriber.SelectedAccount._AccountID);
        }
        else
        {
            SubscriberInfo = "";
        }


        PartitionData PartitionData = (PartitionData)BaseUI.User.GetData("PartitionData");

        if (PartitionData.isPartitionUser)
        {
            UserInfo = String.Format("{0} ({1}) &rarr; <i>{2}</i>", BaseUI.User.UserName, BaseUI.User.AccountId, PartitionData.PartitionName);
        }
        else
        {
            UserInfo = String.Format("{0} ({1})", BaseUI.User.UserName, BaseUI.User.AccountId);
        }

        UserId = BaseUI.User.AccountId;
    }

    public MTPage BaseMTPage
    {
        get { return (MTPage)Page; }
    }

    public UIManager BaseUI
    {
        get { return BaseMTPage.UI; }
    }

    /// <summary>
    /// Return the current HelpPage.
    /// </summary>
    public string HelpPage
    {
        get { return Session[Constants.HELP_PAGE] as string; }
    }

    protected string GetTopBar()
    {
        /* Uncomment if you don't want the inline search
        var str = @"new Ext.form.TextField({
                        id: 'search',
                        emptyText: TEXT_FIND_AN_ACCOUNT,
                        width: 200,
                        listeners:
                        {
                          specialkey : function(field, e) {
                            if(e.getKey() == e.ENTER) {
                                Ext.UI.LoadPage('/MetraNet/AdvancedFind.aspx?' + Ext.urlEncode({UserName:field.getValue()}));
                            }
                          }
                        }
                      }),
                      '-',
                      {
                        iconCls: 'advancedFind',
                        text: TEXT_ADVANCED_FIND,
                        handler: function() { Ext.UI.LoadPage('/MetraNet/AdvancedFind.aspx'); },
                        scope: this
                      },'-',";
    
         */

        var str = @"new Ext.form.ComboBox({
                    id: 'search',
                    store: ds,
                    displayField: 'UserName',
                    cls: 'inlineSearch',
                    typeAhead: false,
                    loadingText: TEXT_SEARCHING,
                    emptyText: TEXT_FIND_AN_ACCOUNT,
                    width: 400, 
                    height: 27,
                    pageSize: 0,
                    hideTrigger: true,
                    minChars: 1,
                    tpl: resultTpl,
                    itemSelector: 'div.search-item',
                    onSelect: function(record) { // override default onSelect to do redirect
                      Ext.getCmp('search').collapse();
                      Ext.getCmp('search').setValue(record.data.UserName);
                      Account.Load(record.data._AccountID);
                    }
                  }),
                  '-',
                  {
                    //iconCls: 'advancedFind',
                    text: TEXT_ADVANCED_FIND,
                    handler: function() { Ext.UI.LoadPage('/MetraNet/AdvancedFind.aspx'); },
                    scope: this
                  },";
//'-',";

        return BaseUI.CoarseCheckCapability("Manage Account Hierarchies") ? str : "'-',";
    }

    protected string GetAccountTabs()
    {
        var str =
          @"{
            region: 'east',
            id: 'east-panel',
            title: TEXT_ACCOUNT,
            collapsed: true,
            collapsible: true,
            split: true,
            width: 400,
            minSize: 100,
            maxSize: 800,
            layout: 'fit',
            margins: '0 0 0 0',
            items: AcctTabPanel
          },";

        return BaseUI.CoarseCheckCapability("Manage Account Hierarchies") ? str : "'-',";
    }

    protected string GetVerticalMenus()
    {
        const string sep = ",";

        MetraTech.Security.Auth auth = new Auth();
        auth.Initialize(BaseUI.User.UserName, BaseUI.User.NameSpace);
    var addMetraCare = auth.HasAppLoginCapability((IMTSessionContext) BaseUI.SessionContext, "MAM", false);
    var addMetraControl = auth.HasAppLoginCapability((IMTSessionContext) BaseUI.SessionContext, "MOM", false);
    var addMetraOffer = auth.HasAppLoginCapability((IMTSessionContext) BaseUI.SessionContext, "MCM", false);

    var strMetraNetMenu = @"{
              contentEl: 'metranet',
              title: 'MetraNet',
              border: true,
              autoScroll: true,
              layout: 'fit',
              iconCls: 'MetraNetMenu'
            }";

        var strMetraCareMenu = @"{
              contentEl: 'metracare',
              title: 'MetraCare',
              border: true,
              autoScroll: true,
              layout: 'fit',
              iconCls: 'MetraCare'
            }";


        var strMetraControlMenu = @"{
              contentEl: 'metracontrol',
              title: 'MetraControl',
              border: true,
              autoScroll: true,
              layout: 'fit',
              iconCls: 'MetraControl'
            }";

        var strMetraOfferMenu = @"{
              contentEl: 'metraoffer',
              title: 'MetraOffer',
              border: true,
              autoScroll: true,
              layout: 'fit',
              iconCls: 'MetraOffer'
            }";

        string str = "";

        str += strMetraNetMenu + sep;

        if (addMetraCare)
        {
            str += strMetraCareMenu;
            MenuContainers += "Ext.get(\"MetraCareMenuContainer\").dom.style.display = \"block\";";
        }

        if (addMetraCare && addMetraControl) str += sep;

        if (addMetraControl)
        {
            str += strMetraControlMenu;
            MenuContainers += "Ext.get(\"MetraControlMenuContainer\").dom.style.display = \"block\";";
        }

        if ((addMetraCare && addMetraOffer) || (addMetraControl && addMetraOffer)) str += sep;

        if (addMetraOffer)
        {
            str += strMetraOfferMenu;
            MenuContainers += "Ext.get(\"MetraOfferMenuContainer\").dom.style.display = \"block\";";
        }

        return str;

        /*, {
                  title: TEXT_SETTINGS,
                  border: false,
                  autoScroll: true,
                  layout: 'fit',
                  iconCls: 'settings',
                  contentEl: 'settings'
                }*/
    }

    protected string EnableMenuContainers()
    {
        return MenuContainers;
    }

    // Returns the code to show the account hierarchy in a tree view if enalbed in the web.config
    protected string GetAccountTreeView()
    {
        var str = "";
        if (ConfigurationManager.AppSettings["EnableAccountTreeView"].ToLower() == "true")
        {
            str = @" {
                  title: TEXT_ACCOUNT_HIERARCHY,
                  //header: false,
                  xtype: 'container',
                  border:false,
                  autoScroll:true,
                  //layout:'fit',


    items: [{
      xtype: 'panel',
      header: false,
      border: false,
      id: 'accountSummaryPanel',
      collapsible: true,
      hidden: false,
      items: [{
        xtype: 'panel', // combo box panel, no title
        html: ''
        }],
      style: { marginBottom: '10px', marginTop: '10px', marginLeft: '10px', marginRight: '10px'}
      },
      {
                  contentEl: 'accountTree',
                  title:TEXT_ACCOUNT_HIERARCHY,
                  border:false,
                  autoScroll:false,
                  layout:'fit'
      }]
                },";


            //      str =@" {
            //                  contentEl: 'accountTree',
            //                  title:TEXT_ACCOUNT_HIERARCHY,
            //                  border:false,
            //                  autoScroll:true,
            //                  layout:'fit'
            //                },";
        }
        return str;
    }
}