<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="CreateQuote.aspx.cs" Inherits="MetraNet.Quoting.CreateQuote" Title="MetraNet - Create quote"
  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <asp:PlaceHolder ID="PlaceHolderPOJavaScript" runat="server"></asp:PlaceHolder> 
  <MT:MTTitle ID="CreateQuoteTitle" Text="Create Quote" runat="server" />
  <br />  
  <MT:MTPanel ID="MTPanelQuoteParameters" runat="server" Text="Quote parameters" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteParametersResource">
    <div id="leftColumn2" class="LeftColumn">
    <MT:MTTextBoxControl ID="MTtbQuoteDescription" AllowBlank="True" Label = "Quote Description" LabelWidth="120" runat="server"/>
    <MT:MTTextBoxControl ID="MTtbQuoteIdentifier" AllowBlank="True" Label = "Quote Identifier" LabelWidth="120" runat="server"/>
    <MT:MTCheckBoxControl ID="MTcbPdf" BoxLabel = "Generate PDF" runat="server" LabelWidth="120" meta:resourcekey="MTCheckBoxPdfResource" />
    </div>
    <div id="rightColumn2"  class="RightColumn">
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpStartDate"
      Label="Start date" LabelWidth="120" meta:resourcekey="dpStartDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpEndDate"
      Label="End date" LabelWidth="120" meta:resourcekey="dpEndDateResource1" ReadOnly="False"
      runat="server"></MT:MTDatePicker>
    </div>
  </MT:MTPanel>
  <br />
  <MT:MTPanel ID="MTPanelQuoteAccounts" runat="server" Text="Accounts and product offerings for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelQuoteAccountsResource">
    <div id="PlaceHolderAccountsGrid" class="LeftColumn"></div>
    <div id="PlaceHolderProductOfferingsGrid" class="RightColumn"></div>   
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelUDRCMetrics" runat="server" Text="UDRC metrics for quote" Collapsible="True"
    Collapsed="True" meta:resourcekey="MTPanelUDRCResource">
     <asp:PlaceHolder ID="PlaceHolderUDRCMetricsGrid" runat="server"></asp:PlaceHolder> 
     <br />GRID WITH UDRC METRICS (GENERATED DYNAMICALLY ACCORDING TO SET OF POS ABOVE, uses code based on Subscriptions\SetUDRCValues.aspx page<br /> <br />
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelICBs" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="True" meta:resourcekey="MTPanelICBResource">
    <br />GRID WITH ICB METRICS. (most likely we should create a new screen for rates edit instead of existed ASP page for Rates similar to Subscriptions\SetUDRCValues.aspx< page<br /> <br />
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 630px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center;">
        <table>
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTCheckBoxControl ID="MTCheckBoxViewResult" Visible="False" BoxLabel = "View result" runat="server" LabelWidth="100" meta:resourcekey="MTCheckBoxPdfResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnGenerateQuote" runat="server" OnClientClick="return getDataGrids();" OnClick="btnGenerateQuote_Click"
                TabIndex="150" meta:resourcekey="btnGenerateQuoteResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="160" meta:resourcekey="btnCancelResource1" />
            </td>
            
          </tr>
        </table>
      </div>
    </div>
  </div>  
  
  <input id="HiddenAccountIds" runat="server" type="hidden" />
  <input id="HiddenGroupId" runat="server" type="hidden" />
  <input id="HiddenPoIdTextBox" runat="server" type="hidden" />
  <input id="HiddenAccounts" runat="server" type="hidden" />
  <input id="HiddenPos" runat="server" type="hidden" />
  
  <%-- Account Grid--%>
  <script language="javascript" type="text/javascript">
    var accountData = { accounts: [] };
    
    // create the data store
    var accountStore = new Ext.data.JsonStore({
      root: 'accounts',
      fields: [
        { name: '_AccountID' },
        { name: 'AccountStatus' },
        { name: 'AccountType' },
        { name: 'Internal#Folder' },
        { name: 'IsGroup' },
        { name: 'UserName' }
      ]
    });

    var textSelectAccounts = '<%=GetLocalResourceObject("SELECT_ACCOUNTS")%>';
    var accountToolBar = new Ext.Toolbar([{ iconCls: 'add', id: 'Add', text: textSelectAccounts, handler: onAccountAdd}]);

    // create the Grid
    var textUserName = '<%=GetLocalResourceObject("USERNAME")%>';
    var textIsGroup = '<%=GetLocalResourceObject("ISGROUP")%>';
    var textAccountActions = '<%=GetLocalResourceObject("ACTIONS")%>';
    var textAccountGridTitle = '<%=GetLocalResourceObject("GRID_TITLE")%>';
    var accountGrid = new Ext.grid.EditorGridPanel({
      ds: accountStore,
      columns: [
        { id: '_AccountID', header: textUserName, width: 150, sortable: true, renderer: usernameRenderer, dataIndex: '_AccountID' },
        { header: textIsGroup, width: 120, sortable: false, dataIndex: 'IsGroup', renderer: isGroupSubscriptionRenderer },
        { header: textAccountActions, width: 50, sortable: false, dataIndex: '', renderer: accountActionsRenderer }
      ],
      tbar: accountToolBar,
      stripeRows: true,
      height: 300,
      width: 350,
      iconCls: 'icon-grid',
      frame: true,
      title: textAccountGridTitle
    });

    //add account button handler
    function onAccountAdd() {
      window.Ext.UI.ShowMultiAccountSelector('accountCallback', 'Frame');
    }

    function accountCallback(ids, records) {
      for (var i = 0; i < records.length; i++) {
        var accId = records[i].data._AccountID;
        var found = accountStore.find('_AccountID', accId);
        if (found == -1) {
          records[i].IsGroup = 0;
          accountStore.add(records[i]);
        }
      }
      window.accountSelectorWin2.hide();
    }

    var textAccountRemove = '<%=GetLocalResourceObject("REMOVE_ACCOUNT")%>';
    function accountActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='remove_{0}' title='{1}' href='JavaScript:removeAcct({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data._AccountID, textAccountRemove);
      return str;
    }

    function usernameRenderer(value, meta, record) {
      var folder = 'False';
      if (record.data['Internal#Folder'] == true) {
        folder = 'True';
      }

      var str = String.format(
        "<span title='{2} ({1}) - {0}'><img src='/ImageHandler/images/Account/{0}/account.gif?State={3}&Folder={4}'> {2} ({1})</span>",
        record.data.AccountType,
        record.data._AccountID,
        record.data.UserName,
        record.data.AccountStatus,
        folder);
      return str;
    }

    function isGroupSubscriptionRenderer(value, meta, record, rowIndex) {
      var str = '';
      if (record.data.AccountType == 'CorporateAccount') {
        str = '<input ' + (record.data['IsGroup'] == 1 ? 'checked=checked' : '') + 'onchange="setDefaultChecked(' + rowIndex + ');" type=radio name="radioButton' + record.data._AccountID + '">';
      }
      return str;
    }

    function setDefaultChecked(rowIndex) {
      for (var index = 0; index < accountStore.data.items.length; index++) {
        if (accountStore.data.items[index].data.IsGroup == 1)
          accountStore.data.items[index].set('IsGroup', 0);
      }
      accountStore.data.items[rowIndex].set('IsGroup', 1);
      accountStore.commitChanges();
    }

    function removeAcct(accId) {
      var idx = accountStore.find('_AccountID', accId);
      accountStore.remove(accountStore.getAt(idx));
    }

    function getAccountIds() {
      var records = accountStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      var ids = "";
      var gid = "";
      accountData.accounts.length = 0;
      for (var i = 0; i < records.length; i++) {
        var record = {
          '_AccountID': records[i].data._AccountID,
          'AccountStatus': records[i].data.AccountStatus,
          'AccountType': records[i].data.AccountType,
          'Internal#Folder': records[i].data['Internal#Folder'],
          'IsGroup': records[i].data.IsGroup == "1" ? "1" : "0",
          'UserName': records[i].data.UserName
        };
        accountData.accounts.push(record);
        if (i > 0) {
          ids += ",";
        }
        ids += records[i].data._AccountID;
        if (records[i].data.IsGroup == "1")
          gid = records[i].data._AccountID;
      }

      window.Ext.get("<%=HiddenAccountIds.ClientID %>").dom.value = ids;
      window.Ext.get("<%=HiddenGroupId.ClientID %>").dom.value = gid;
      window.Ext.get("<%=HiddenAccounts.ClientID %>").dom.value = accountData.accounts.length > 0 ? window.Ext.encode(accountData.accounts) : "";

      return true;
    }
  </script> 
  
  <%-- Product Offering Grid--%>
  <script language="javascript" type="text/javascript">
    var poData = { pos: [] };
  
    // create the data store
    var poStore = new Ext.data.JsonStore({
      root: 'pos',
      fields: [
        { name: 'Name' },
        { name: 'ProductOfferingId' }
      ]
    });
    poStore.loadData(poData);

    var textSelectPos = '<%=GetLocalResourceObject("SELECT_POS")%>';
    var poToolBar = new Ext.Toolbar([{ iconCls: 'add', id: 'Add', text: textSelectPos, handler: onPoAdd }]);

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPoName = '<%=GetLocalResourceObject("PONAME")%>';
    var textPoAction = '<%=GetLocalResourceObject("ACTIONS")%>';
    var textPoGridTitle = '<%=GetLocalResourceObject("PO_GRID_TITLE")%>';
    var poGrid = new Ext.grid.EditorGridPanel({
      ds: poStore,
      columns: [
        { id: 'ProductOfferingId', header: textPoId, width: 50, sortable: true, dataIndex: 'ProductOfferingId' },
        { header: textPoName, width: 220, sortable: true, dataIndex: 'Name' },
        { header: textPoAction, width: 50, sortable: false, dataIndex: '', renderer: poActionsRenderer }
      ],
      tbar: poToolBar,
      stripeRows: true,
      height: 300,
      width: 350,
      iconCls: 'icon-grid',
      frame: true,
      title: textPoGridTitle
    });

    //this will be called when accts are selected
    function addPoCallback(ids, records) {
      for (var i = 0; i < records.length; i++) {
        var productOfferingId = records[i].data.ProductOfferingId;
        var found = poStore.find('ProductOfferingId', productOfferingId);
        if (found == -1) {
          poStore.add(records[i]);
        }
      }
      poSelectorWin2.hide();
    }

    //add account button handler
    function onPoAdd() {
      ShowMultiPoSelector('addPoCallback', 'Frame');
    }

    var textPoRemove = '<%=GetLocalResourceObject("REMOVE_PO")%>';

    function poActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='remove_{0}' title='{1}' href='JavaScript:removePo({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>", 
        record.data.ProductOfferingId, textPoRemove);
      return str;
    }

    function removePo(poId) {
      var idx = poStore.find('ProductOfferingId', poId);
      poStore.remove(poStore.getAt(idx));
    }

    function getPoIds() {
      var records = poStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      poData.pos.length = 0;
      var ids = "";
      for (var i = 0; i < records.length; i++) {
        poData.pos.push(records[i].data);
        if (i > 0) {
          ids += ",";
        }
        ids += records[i].data.ProductOfferingId;
      }

      window.Ext.get("<%=HiddenPoIdTextBox.ClientID %>").dom.value = ids;
      window.Ext.get("<%=HiddenPos.ClientID %>").dom.value = poData.pos.length > 0 ? window.Ext.encode(poData.pos) : "";
      return true;
    }
    
    function ShowMultiPoSelector(functionName, target) {
      if (window.poSelectorWin2 == null || window.poSelectorWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
        window.poSelectorWin2 = new top.Ext.Window({
          title: 'TEXT_SELECT_PO',
          width: 700,
          height: 500,
          minWidth: 300,
          minHeight: 200,
          layout: 'fit',
          plain: true,
          bodyStyle: 'padding:5px;',
          buttonAlign: 'center',
          collapsible: true,
          resizeable: true,
          maximizable: false,
          closable: true,
          closeAction: 'close',
          html: '<iframe id="poSelectorWindow2" src="/MetraNet/Quoting/SelectPOForQuote.aspx?t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no"/>'
        });
      }
      if (window.poSelectorWin != null) {
        window.poSelectorWin.hide();
      }
      window.lastTarget2 = target;
      window.lastFunctionName2 = functionName;
      window.poSelectorWin2.show();

      window.poSelectorWin2.on('close', function () {
        window.poSelectorWin2 = null;
      });
    }
  </script>
  
  <%-- General--%>
  <script language="javascript" type="text/javascript">
    
    Ext.onReady(function () {
      accountGrid.render(window.Ext.get('PlaceHolderAccountsGrid'));
      poGrid.render(window.Ext.get('PlaceHolderProductOfferingsGrid'));
    });

    window.onload = function () {
      var hiddenAccounts = window.Ext.get("<%=HiddenAccounts.ClientID %>").dom;
      if (hiddenAccounts.value.length > 0)
        accountData.accounts = window.Ext.decode(hiddenAccounts.value);
      window.accountStore.loadData(accountData);
      
      var hiddenPos = window.Ext.get("<%=HiddenPos.ClientID %>").dom;
      if (hiddenPos.value.length > 0)
        poData.pos = window.Ext.decode(hiddenPos.value);
      window.poStore.loadData(poData);
    };
    
    function getDataGrids() {
      return getAccountIds() && getPoIds();
    }
    
  </script>
    
</asp:Content>