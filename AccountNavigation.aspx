<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="AccountNavigation" Title="MetraNet Account Finder" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="AccountNavigation.aspx.cs" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script> 
  <div id="FilteredResults2" class="InfoMessage" style="display:none;"></div>  
  <MT:MTFilterGrid ID="MyGrid1" runat="server" ExtensionName="Account" TemplateFileName="AccountNavigatorLayoutTemplate"></MT:MTFilterGrid>
  
  <script type="text/javascript">

  //var ROOT_CRUMB_HTML = "<div id=\"crumb\" style=\"clip:auto;overflow-x:auto;width:285px;height:40px;padding:1px;\"><a href=\"JavaScript:NavigateAncestor(1, 'Root');\">root (1)</a></div>";
  var ROOT_CRUMB_HTML = "<div id=\"crumb\" style=\"clip:auto;overflow-x:auto;width:285px;height:40px;padding:1px;\"></div>";
  
  function BeforeSearch_<%=MyGrid1.ClientID %>()
  {
    Ext.get("crumb").dom.innerHTML = "";
  }
  
  function onAddAccount()
  {
    location.href = '/MetraNet/StartWorkflow.aspx?WorkFlowName=AddAccountWorkflow';
  }

  onOK_<%=MyGrid1.ClientID %> = function()
  {
  }; 

  onCancel_<%=MyGrid1.ClientID %> = function()
  {
  };  
 
  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('Navigate'), navigateRenderer); 
    cm.setRenderer(cm.getIndexById('AccountStartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('AccountEndDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('Payment_StartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('Payment_EndDate'), DateRenderer); 
    cm.setRenderer(cm.getIndexById('Hierarchy_StartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('Hierarchy_EndDate'), DateRenderer); 
    
    cm.setRenderer(cm.getIndexById('UserName'), UsernameRenderer);
    cm.setRenderer(cm.getIndexById('Options'), optionsColRenderer); 
  }
  
  function UsernameRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var folder = "False" ;
    if (record.data["Internal#Folder"] == true) 
    { 
        folder = "True" ;
    } 

    var str = String.format("<span title='{2} ({1}) - {0}'><a style='cursor:hand;' id='manage1_{1}' href='JavaScript:getFrameMetraNet().Account.Load({1});'><img src='/ImageHandler/images/Account/{0}/account.gif?State={3}&Folder={4}'>{2}</a></span>",
                                  record.data.AccountType,
                                  record.data._AccountID,
                                  Ext.util.Format.htmlEncode(record.data.UserName),
                                  record.data.AccountStatus,
                                  folder);
    return str;
  }

  function navigateRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    if(record.data["Internal#Folder"] == true)
    {
      str = String.format("<a title='View Children' href=\"JavaScript:NavigateAncestor({1}, '{2}');\"><img src='/Res/Images/icons/bullet_hierarchy.png'></a>",
                                  record.data.AccountType,
                                  record.data._AccountID,
                                  Ext.util.Format.htmlEncode(record.data.UserName));
    }
    return str;
  }
  
  function NavigateAncestor(ancestorID, ancestorUsername)
  {        
    onClear_<%= MyGrid1.ClientID %>();
         
    Ext.get("filter_AncestorAccountID_<%= MyGrid1.ClientID %>").dom.value = ancestorID;
    Ext.get("combo_filter_AncestorAccountID_<%= MyGrid1.ClientID %>").dom.value = String.format("{0} ({1})", ancestorUsername, ancestorID);
    onSearch_<%= MyGrid1.ClientID %>();
    
    // Ajax call to get ancestor list
    Ext.Ajax.request({
      url:'/MetraNet/AjaxServices/AncestorList.aspx',
      params: {id: ancestorID},
      timeout: 10000,
      success: function(response) {
         var crumb = Ext.get("crumb");
         var html = "";
         var result = Ext.decode(response.responseText)
         for(i=0; i < result.records.length; i++)
         {
           html += "<a href=\"JavaScript:NavigateAncestor(" + result.records[i].id_ancestor + ", '" + result.records[i].nm_login + "');\">" + getFrameMetraNet().Ext.UI.shortName(result.records[i].nm_login) + "(" + result.records[i].id_ancestor + ")" + "</a>"
           if(i < result.records.length -1) 
           {
             html += "<img src='/Res/Images/icons/bullet_arrow_right.png'/>" 
           }
         }
         crumb.dom.innerHTML = html;
      },
      failure : function() {
         var crumb = Ext.get("crumb");
         crumb.dom.innerHTML = ROOT_CRUMB_HTML;
      },
      scope: this
    });  

  }
  
  BeforeExpanderRender_<%= MyGrid1.ClientID %> = function(tplString)
  {
    var html = "<div id='path_{_AccountID}'><a href='JavaScript:getAncestorPath({_AccountID});'>Get Hierarchy Path</a></div>";
    tplString = html + tplString;
    return tplString;
  };
 
  function getAncestorPath(accountID){
      Ext.Ajax.request({
        url:'/MetraNet/AjaxServices/AncestorList.aspx',
        params: {id: accountID},
        timeout: 10000,
        success: function(response) {
           var crumb = Ext.get("path_" + accountID);
           var html = "";
           var result = Ext.decode(response.responseText)
           for(i=0; i < result.records.length; i++)
           {
             html += "<a href=\"JavaScript:NavigateAncestor(" + result.records[i].id_ancestor + ", '" + result.records[i].nm_login + "');\">" + getFrameMetraNet().Ext.UI.shortName(result.records[i].nm_login) + "(" + result.records[i].id_ancestor + ")" + "</a>"
             if(i < result.records.length -1) 
             {
               html += "<img src='/Res/Images/icons/bullet_arrow_right.png'/>" 
             }
           }
           crumb.dom.innerHTML = html;
        },
        failure : function() {
           var crumb = Ext.get("path_" + accountID);
           crumb.dom.innerHTML = ROOT_CRUMB_HTML;
        },
        scope: this
    });  
  }
      
  optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
  {
    var str = ""
    
    // Manage button
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:getFrameMetraNet().Account.Load({0});'><img src='/Res/Images/icons/user_go.png' alt='{1}' /></a>", record.data._AccountID, 'Manage Account');
      
    // Online Bill button
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='bill_{0}' title='{1}' href='JavaScript:getFrameMetraNet().Account.LoadPage({0}, \"/MetraNet/ViewOnlineBill.aspx\");'><img src='/Res/Images/icons/page_world.png' alt='{1}' /></a>", record.data._AccountID, 'Online Bill');
    
    // Add Account
    if(record.data["Internal#Folder"] == true)
    {
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='add_{0}' title='{1}' target='MainContentIframe' href='/MetraNet/StartWorkFlow.aspx?WorkFlowName=AddAccountWorkflow&amp;AncestorID={0}'><img src='/Res/Images/icons/user_add.png' alt='{1}' /></a>", record.data._AccountID, 'Add Account');
    }
    
    return str;
  };
  
  GetTopBar_<%= MyGrid1.ClientID %> = function()
  {  
    var tbar = new Ext.Toolbar([{xtype: 'tbtext', text: ROOT_CRUMB_HTML}]); 
    return tbar;
  };
  
  // Custom message if not all records are being shown
  Ext.onReady(function(){
    var MAX_PAGES = <%= Application["GetAccountListMaxPages"].ToString() %>;
    dataStore_<%= MyGrid1.ClientID %>.on('load',
     function(s, records, options) {      
        var el = Ext.get("FilteredResults2");	 
        if(s.getTotalCount() != 0 && s.getTotalCount() >= (MAX_PAGES * s.getCount())) { 
           el.dom.style.display = "block";
           el.dom.innerHTML = TEXT_TOO_MANY_ROWS;
           el.highlight();
        }
        else {
         el.dom.style.display = "none";
         el.dom.innerHTML = "";
        }
    });
  });  
  </script>
  
</asp:Content>

