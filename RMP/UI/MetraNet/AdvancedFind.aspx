<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="AdvancedFind" Title="MetraNet" CodeFile="AdvancedFind.aspx.cs" Culture="auto" meta:resourcekey="PageResource1" UICulture="auto"  %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
  <style>
    .x-panel-ml .x-btn-text
    {
      width: 75px !important;
      height: 22px;
    }
  </style>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script>
  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Advanced Find" meta:resourcekey="lblTitle"></asp:Label>
  </div>
  <div id="FilteredResults" class="InfoMessage" style="display:none;"></div>
  <MT:MTFilterGrid ID="MyGrid1" runat="Server" ExtensionName="Account" TemplateFileName="AccountListLayoutTemplate.xml"></MT:MTFilterGrid>
  <MT:MTPanel ID="InvoiceSearch" runat="server" Collapsed="True" Collapsible="True" Text="<%$ Resources: InvoiceSearch.Text%>" Width="720px">
    <div class="x-form-item">
      <table cellspacing="0" cellpadding="0" border="0">
        <tr>
          <td>
            <MT:MTLabel ID="labelInvoiceNumber" runat="server" CssClass="x-form-item-label" style="width:100px;visibility:hidden;display:block" Text="<%$ Resources: labelInvoiceNumber.Text %>" />
          </td>
          <td>
            <MT:MTTextBoxControl ID="InvoiceNumber" runat="server" AllowBlank="true" HideLabel="true" style="width: 218px" />
          </td>
        </tr>
      </table>
    </div>
    <div class="x-panel-fbar x-small-editor x-toolbar-layout-ct" style="width: auto; margin-top: 15px">
      <table class="x-toolbar-ct" cellspacing="0">
        <tr>
          <td class="x-toolbar-left" align="center">
            <table cellspacing="0" cellpadding="0" border="0">
              <tr>
                <td style="padding-right: 3px">
                  <MT:MTButton ID="SearchByInvoice" runat="server" CssClass="x-btn-text" Text="Search" EnableViewState="false" />
                </td>
                <td style="padding-left: 3px">
                  <MT:MTButton ID="ClearInvoiceNumber" runat="server" CssClass="x-btn-text" Text="Clear" EnableViewState="false" />
                </td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
    </div>
  </MT:MTPanel>
     
   
  <script type="text/javascript">

  var ROOT_CRUMB_HTML = "<div id=\"crumb\" style=\"clip:auto;overflow-x:auto;width:545px;height:40px;padding:1px;\"></div>";
 
  function BeforeSearch_<%=MyGrid1.ClientID %>()
  {
    Ext.get("crumb").dom.innerHTML = "";
    adjustGridPosition();
  }
  
  function AfterSearch_<%=MyGrid1.ClientID %>()
  {
    autoSaveSearch();
  }

  function autoSaveSearch()
  {
    Ext.Ajax.request({
      url:'<%=GetVirtualFolder()%>/AjaxServices/LoadSavedSearchByName.aspx',
      params: {
        SavedSearchName: "autosave",
        PageUrl: "<%=HttpUtility.HtmlEncode(HttpUtility.UrlDecode(Page.Request.Url.PathAndQuery).Replace(";", string.Empty).Replace("'",string.Empty).Replace("\"",string.Empty).Replace("+",string.Empty))%>",
        GridID:'<%=MyGrid1.ID %>', 
        SearchLayout:xmlPath_<%=MyGrid1.ClientID %>
      },
      timeout: 10000,
      success: function(response) {
        var searchFilters = Ext.util.JSON.decode(response.responseText);
        for(var i = 0 ; i < searchFilters.Items.length; i++)
        {
          Ext.Ajax.request({
            url:'<%=GetVirtualFolder()%>/AjaxServices/DeleteSavedSearch.aspx',
            params: {'delete': searchFilters.Items[i].Id}
          });
        }
      },
      scope: this
    });  

    searchNameField_<%=MyGrid1.ClientID %> = new Ext.form.TextField({
      fieldLabel: TEXT_SEARCH_NAME,
      width:200,
      allowBlank:false
    });
    
    searchDescriptionField_<%=MyGrid1.ClientID %> = new Ext.form.TextArea({
      fieldLabel: TEXT_DESCRIPTION,
      width: 200,
      height: 100
    });

    var params = GetFiltersAsParamList_<%=MyGrid1.ClientID %>(searchNameField_<%=MyGrid1.ClientID %>,searchDescriptionField_<%=MyGrid1.ClientID %>);
    params['search_name'] = "autosave";
    params['description'] = "<%=Session.SessionID%>";

    Ext.Ajax.request({
      url:'<%=GetVirtualFolder()%>/AjaxServices/SaveSearchParameters.aspx',
      params: params,
      success:function(result, request)
      {
        return;
      } //end success
    
    }); //end ajax request
  }
  
  function loadAutoSavedSearch()
  {
      Ext.Ajax.request({
        url:'<%=GetVirtualFolder()%>/AjaxServices/LoadSavedSearchByName.aspx',
        params: {
          SavedSearchName: "autosave",
          PageUrl: "<%=HttpUtility.HtmlEncode(HttpUtility.UrlDecode(Page.Request.Url.PathAndQuery).Replace(";", string.Empty).Replace("'",string.Empty).Replace("\"",string.Empty).Replace("+",string.Empty))%>",
          GridID:'<%=MyGrid1.ID %>', 
          SearchLayout:xmlPath_<%=MyGrid1.ClientID %>
        },
        timeout: 10000,
        success: function(response) {
          var searchFilters = Ext.util.JSON.decode(response.responseText);
          if(searchFilters && searchFilters.TotalRows > 0)
            LoadSavedSearch_<%=MyGrid1.ClientID %>(searchFilters.Items[0].Id);
        },
        scope: this
    });  
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
 
  function adjustGridPosition()
  {
    var invoicePanel = Ext.get('MyFormDiv_<%=InvoiceSearch.ClientID %>');

    var el = grid_<%= MyGrid1.ClientID %>.getEl();
    
    el.setStyle("position", "absolute");
    el.setStyle("margin-top", invoicePanel.getHeight().toString() + "px");
  }

  function searchByInvoceNumber()
  {
    var params = {'pageURL':'{page_url}', 'GridID':'{<%=MyGrid1 %>}', 'SearchLayout':xmlPath_<%= MyGrid1.ClientID %>};
    var ctrl = Ext.getCmp(('<%=InvoiceNumber.ClientID %>'));
    
    if (ctrl != null)
    {
      adjustGridPosition();         
      //make results pane visible, it could be hidden if not searching on load
      if (!grid_<%= MyGrid1.ClientID %>.isVisible())
      {
        grid_<%= MyGrid1.ClientID %>.setVisible(true);
      }

      var myMask = new Ext.LoadMask(grid_<%= MyGrid1.ClientID %>.getEl());
      myMask.show();
     
      Ext.Ajax.request({
            url:'/MetraNet/AjaxServices/FindAccountSvc.aspx',
            params:{invoiceID:ctrl.getValue()},
            failure:function(result, request){
              myMask.hide();
              Ext.MessageBox.show({
                      title:TEXT_ERROR,
                      msg:TEXT_ERROR_LOADING_SEARCH,
                      buttons:Ext.MessageBox.OK,
                      icon:Ext.MessageBox.ERROR
                    }); 
            },
            
            success:function(result,request)
            {
              var requestData = Ext.util.JSON.decode(result.responseText);
              
              dataStore_<%= MyGrid1.ClientID %>.loadData(requestData, false);
              
              myMask.hide();
            }
          });
    }
    return false;
  }

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
      
  optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";
    
    // Manage button
    str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='manage_{0}' title='{1}' href='JavaScript:getFrameMetraNet().Account.Load({0});'><img src='/Res/Images/icons/user_go.png' alt='{1}' /></a>", record.data._AccountID, TEXT_MANAGE_ACCOUNT);
      
    // Online Bill button
    if (record.json.HasLogonCapability) {
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='bill_{0}' title='{1}' href='JavaScript:getFrameMetraNet().Account.LoadPage({0}, \"/MetraNet/ViewOnlineBill.aspx\");'><img src='/Res/Images/icons/page_world.png' alt='{1}' /></a>", record.data._AccountID, TEXT_ONLINE_BILL);
    }
    
	  // Link Hierarchy button
	if (record.data.AccountType != "IndependentAccount")
	{
		str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='hierarchy_{0}' title='{1}' onclick='JavaScript:getFrameMetraNet().Account.ShowHierarchyTab({0});'><img src='/Res/Images/icons/sync.png' alt='{1}' /></a>", record.data._AccountID, "Find in Hierarchy");
    }
    // Add Account
    if(record.data["Internal#Folder"] == true && record.json.CanHaveChildren)
    {
      str += String.format("&nbsp;&nbsp;<a style='cursor:hand;' id='add_{0}' title='{1}' target='MainContentIframe' href='/MetraNet/StartWorkFlow.aspx?WorkFlowName=AddAccountWorkflow&amp;AncestorID={0}'><img src='/Res/Images/icons/user_add.png' alt='{1}' /></a>", record.data._AccountID, TEXT_ADD_ACCOUNT);
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
    Ext.override(Ext.ux.JPathJsonReader, {
      readRecords: function (o) {
        this.jsonData = o;
        var s = this.meta, Record = this.recordType, f = Record.prototype.fields, fi = f.items, fl = f.length;

        if (!this.ef) {
          if (s.totalProperty) {
            this.getTotal = this.getJsonAccessor(s.totalProperty);
          }
          if (s.successProperty) {
            this.getSuccess = this.getJsonAccessor(s.successProperty);
          }
          this.getRoot = s.root ? this.getJsonAccessor(s.root) : function (p) {
            return p;
          };
          if (s.id) {
            var g = this.getJsonAccessor(s.id);
            this.getId = function (rec) {
              var r = g(rec);
              return (r === undefined || r === "") ? null : r;
            };
          }
          else {
            this.getId = function () {
              return null;
            };
          }
          this.ef = [];
          for (var i = 0; i < fl; i++) {
            f = fi[i];
            var map = (f.mapping !== undefined && f.mapping !== null) ? f.mapping : f.name;
            this.ef[i] = this.getJsonAccessor(map);
          }
        }

        var root = this.getRoot(o), c = root.length, totalRecords = c, success = true;
        if (s.totalProperty) {
          var v = parseInt(this.getTotal(o), 10);
          if (!isNaN(v)) {
            totalRecords = v;
          }
        }
        if (s.successProperty) {
          var v = this.getSuccess(o);
          if (v === false || v === 'false') {
            success = false;
          }
        }
        var records = [];
        for (var i = 0; i < c; i++) {
          var n = root[i];
          var values = {};
          var id = this.getId(n);
          for (var j = 0; j < fl; j++) {
            f = fi[j];
            var v = "";
            try{
              (f.useJPath !== undefined && f.useJPath !== null && f.useJPath)
                      ? v = this.getJPathVal(n, f)
                      : v = this.ef[j](n)
            }
            catch (e){}
            values[f.name] = f.convert((v !== undefined) ? v : f.defaultValue, n);
          }
          var record = new Record(values, id);
          record.json = n;
          records[i] = record;
        }
        return {
          success: success,
          records: records,
          totalRecords: totalRecords
        };
      }
    });
    
    var MAX_PAGES = <%= Application["GetAccountListMaxPages"].ToString() %>;
    dataStore_<%= MyGrid1.ClientID %>.on('load',
     function(s, records, options) {      
        var el = Ext.get("FilteredResults");	 
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
    loadAutoSavedSearch();

    var invoicePanel = Ext.getCmp('formPanel_<%=InvoiceSearch.ClientID %>');
    invoicePanel.on('collapse', function(){
      adjustGridPosition();
    });
    invoicePanel.on('expand', function(){
      adjustGridPosition();
    });
    var invoiceTitle = Ext.get('<%=labelInvoiceNumber.ClientID %>');
    invoiceTitle.show();
  });
  </script>
  
</asp:Content>

