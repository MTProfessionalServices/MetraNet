<%@ Page Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" Inherits="AccountSelector" Title="MetraNet Account Selector" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto" CodeFile="AccountSelector.aspx.cs" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script> 
  <div id="FilteredResults1" class="InfoMessage" style="display:none;"></div>  
  <MT:MTFilterGrid ID="MyGrid1" runat="server" ExtensionName="Account" TemplateFileName="AccountSelectorLayoutTemplate"></MT:MTFilterGrid>
  
  <script type="text/javascript">

  var ROOT_CRUMB_HTML = "<div id=\"crumb\" style=\"clip:auto;overflow-x:auto;width:285px;height:10px;padding:0px;\"><a href=\"JavaScript:NavigateAncestor(1, 'Root');\">root (1)</a></div>";
    
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
     
    var records = grid_<%= MyGrid1.ClientID %>.getSelectionModel().getSelections();
    var ids = "";
    for(var i=0; i < records.length; i++)
    {
      if(i > 0)
      {
        ids += ",";
      }
      ids += records[i].data._AccountID;
    }

    try
    {
      if(getFrameMetraNet().MainContentIframe)
      {
        if(getFrameMetraNet().MainContentIframe.ticketFrame)
        {
          if(getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage)
          {
           
            getFrameMetraNet().MainContentIframe.ticketFrame.fmeTemplatePage.<%= CallbackFunction %>(ids, records, '<%= Utils.EncodeForJavaScript(Target) %>');
          }
          else
          {            
            getFrameMetraNet().MainContentIframe.ticketFrame.<%= CallbackFunction %>(ids, records, '<%= Utils.EncodeForJavaScript(Target) %>');
          }
        }
        else
        {
           getFrameMetraNet().MainContentIframe.<%= CallbackFunction %>(ids, records, '<%= Utils.EncodeForJavaScript(Target) %>');
        }
      }
    }
    catch(e)
    {
      //Ext.UI.msg("Error", "Couldn't find <%= CallbackFunction %> method.");      
      Ext.UI.msg(TEXT_ERROR_MSG, TEXT_CALLBACK_MSG_1 + <%= Utils.EncodeForJavaScript(CallbackFunction) %> + TEXT_CALLBACK_MSG_2);      
    }
     
    if(getFrameMetraNet().accountSelectorWin != null)
    {
      getFrameMetraNet().accountSelectorWin.hide();
    }

    if(getFrameMetraNet().accountSelectorWin2 != null)
    {
      getFrameMetraNet().accountSelectorWin2.hide();
    }
      
    getFrameMetraNet().accountSelectorWin = null;
    getFrameMetraNet().accountSelectorWin2 = null;
     
      
  }; 

  onCancel_<%=MyGrid1.ClientID %> = function()
  {
  };  
 
  OverrideRenderer_<%= MyGrid1.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('Navigate'), navigateRenderer); 
   /*   cm.setRenderer(cm.getIndexById('AccountStartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('AccountEndDate'), DateRenderer);
  
    cm.setRenderer(cm.getIndexById('Payment_StartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('Payment_EndDate'), DateRenderer); 
    cm.setRenderer(cm.getIndexById('Hierarchy_StartDate'), DateRenderer);
    cm.setRenderer(cm.getIndexById('Hierarchy_EndDate'), DateRenderer); 
  */
    cm.setRenderer(cm.getIndexById('UserName'), UsernameRenderer);
  }
  
  function UsernameRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var folder = "False" ;
    if (record.data["Internal#Folder"] == true) 
    { 
        folder = "True" ;
    } 

    var str = String.format("<span title='{2} ({1}) - {0}'><img src='/ImageHandler/images/Account/{0}/account.gif?State={3}&Folder={4}'>{2}</span>",
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
      str = String.format("<a title='{3}' href=\"JavaScript:NavigateAncestor({1}, '{2}');\"><img src='/Res/Images/icons/bullet_hierarchy.png'></a>",
                                  record.data.AccountType,
                                  record.data._AccountID,
                                  Ext.util.Format.htmlEncode(record.data.UserName),
                                  TEXT_VIEW_CHILDREN);
    }                             
    return str;
  }
  
  function NavigateAncestor(ancestorID, ancestorUsername)
  {         
    onClear_<%=MyGrid1.ClientID %>();
        
    Ext.get("filter_AncestorAccountID_<%= MyGrid1.ClientID %>").dom.value = ancestorID;
    Ext.get("combo_filter_AncestorAccountID_<%= MyGrid1.ClientID %>").dom.value = String.format("{0} ({1})", ancestorUsername, ancestorID);
    onSearch_<%=MyGrid1.ClientID %> ();
    
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
    var html = "<div id='path_{_AccountID}'><a href='JavaScript:getAncestorPath({_AccountID});'>" + TEXT_GET_HIERARCHY_PATH + "</a></div>";
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
        var el = Ext.get("FilteredResults1");	 
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

