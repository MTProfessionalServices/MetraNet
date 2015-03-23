<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="CreateQuote.aspx.cs" Inherits="MetraNet.Quoting.CreateQuote" Title="MetraNet - Create quote"
  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <asp:PlaceHolder ID="PlaceHolderPOJavaScript" runat="server"></asp:PlaceHolder>
  <MT:MTTitle ID="CreateQuoteTitle" runat="server" />
  <br />
  <MT:MTPanel ID="MTPanelQuoteParameters" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="MTPanelQuoteParametersResource">
    <div id="leftColumn2" class="LeftColumn">
      <MT:MTTextBoxControl ID="MTtbQuoteDescription" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="MTtbQuoteDescriptionResource" />
      <MT:MTTextBoxControl ID="MTtbQuoteIdentifier" AllowBlank="True" LabelWidth="120" runat="server"
       meta:resourcekey="MTtbQuoteIdentifierResource"/>
      <MT:MTCheckBoxControl ID="MTcbPdf" runat="server" LabelWidth="120"
        meta:resourcekey="MTCheckBoxPdfResource" />
    </div>
    <div id="rightColumn2" class="RightColumn">
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpStartDate"
        Label="Start date" LabelWidth="120" meta:resourcekey="dpStartDateResource1" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpEndDate"
        Label="End date" LabelWidth="120" meta:resourcekey="dpEndDateResource1" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelQuoteAccounts" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="MTPanelQuoteAccountsResource">
    <div id="PlaceHolderAccountsGrid" class="LeftColumn">
    </div>
    <div id="PlaceHolderProductOfferingsGrid" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelUDRC" runat="server" Text="UDRC metrics for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelUDRCResource">
    <div id="PlaceHolderPIWithUDRCAllowedGrid" class="LeftColumn">
    </div>
    <div id="PlaceHolderUDRCGrid" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelICB" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelICBResource">
    <div id="PlaceHolderPIWithICBAllowedGrid" class="LeftColumn">
    </div>
    <div id="PlaceHolderICBGrid" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelUDRCandICB" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelUDRCandICBResource" Visible="false">
    <div id="PlaceHolderUDRCGrid_ViewMode" class="LeftColumn">
    </div>
    <div id="PlaceHolderICBGrid_ViewMode" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelResult" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="MTPanelResult" Visible="False">
    <div id="Div1" class="LeftColumn">
      <MT:MTTextBoxControl ID="MTTextBoxControlStatus" AllowBlank="True" 
        LabelWidth="100" meta:resourcekey="MTTextBoxControlStatusResource" runat="server" ReadOnly="True" />
      <MT:MTTextBoxControl ID="MTTextBoxControlGroup" AllowBlank="True"
        LabelWidth="100" meta:resourcekey="MTTextBoxControlGroupResource" runat="server" ReadOnly="True" />
      <asp:HyperLink ID="ReportLink" runat="server">Report Link</asp:HyperLink>
    </div>
    <div id="Div2" class="RightColumn">
        <MT:MTDatePicker AllowBlank="True" ReadOnly="True" HideLabel="False" ID="MTdpCreationDate"
        Label="Creation date" LabelWidth="100" meta:resourcekey="MTdpCreationDateResource" 
        runat="server"></MT:MTDatePicker>
      <MT:MTTextBoxControl ID="MTTextBoxControlTotal" AllowBlank="True"
        LabelWidth="100" meta:resourcekey="MTTextBoxControlTotalResource" runat="server" ReadOnly="True" />
      <MT:MTTextBoxControl ID="MTTextBoxControlTax" AllowBlank="True"
        LabelWidth="100" meta:resourcekey="MTTextBoxControlTotalTaxResource" runat="server" ReadOnly="True" />
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelLog" runat="server" Collapsible="True" Collapsed="True" meta:resourcekey="MTPanelLog"
    Visible="False">
    <div id="Div3" style="width: 100%; margin: auto;">
      <MT:MTMessage ID="MTMessageFailed" runat="server" ScrollBars="Auto" WarningLevel="Error"
        Width="720" />
      <MT:MTMessage ID="MTMessageLog" runat="server" ScrollBars="Auto" WarningLevel="Info"
        Width="720" />
    </div>
  </MT:MTPanel>
  <div class="x-panel-btns-ct">
    <div style="width: 720px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center; width: 25%; margin: auto;">
        <table>
          <tr>
            <td class="x-panel-btn-td">
              <MT:MTCheckBoxControl ID="MTCheckBoxViewResult" Visible="False" BoxLabel="View result"
                runat="server" LabelWidth="100" meta:resourcekey="MTCheckBoxPdfResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnGenerateQuote" runat="server" OnClientClick="return getDataGrids();"
                OnClick="btnGenerateQuote_Click" TabIndex="150" meta:resourcekey="btnGenerateQuoteResource1" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnConvertQuote" runat="server" OnClientClick="return getConvertApprove();"
                OnClick="btnConvertQuote_Click" Visible="False" TabIndex="150" meta:resourcekey="btnConvertQuoteResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="160" meta:resourcekey="MTbtnCancelResource1" />
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
  <input id="HiddenPis" runat="server" type="hidden" />
  <input id="HiddenUDRCs" runat="server" type="hidden" />
  <input id="HiddenICBs" runat="server" type="hidden" />
  <input id="MTCheckBoxIsGroupSubscription" runat="server" type="hidden" value="false" />
  <%-- General--%>
  <script language="javascript" type="text/javascript">

  function getConvertApprove()
  {                
      return confirm('<%=GetGlobalResourceObject("JSConsts", "TEXT_CONVERT_MESSAGE")%>');        
  }

    var GRID_HEIGHT = 300;
    var ACTIONS_COLUMN_HEIGHT = 25;
    var NAME_COLUMN_HEIGHT = 225;
    var isViewMode = <%=IsViewMode.ToString().ToLower()%>;

    var piRecord = Ext.data.Record.create([// creates a subclass of Ext.data.Record
      {name: 'ProductOfferingId' },
      { name: 'ProductOfferingName' },
      { name: 'PriceableItemId' },
      { name: 'Name' },
      { name: 'DisplayName' },
      { name: 'PIKind' },
      { name: 'PICanICB' },
      { name: 'RatingType' },
      { name: 'RecordId' }
    ]);
    
    Ext.onReady(function () {
      accountGrid.render(window.Ext.get('PlaceHolderAccountsGrid'));
      poGrid.render(window.Ext.get('PlaceHolderProductOfferingsGrid'));
      //UDRCgrid.render(window.Ext.get('PlaceHolderUDRCMetricsGrid'));
      if(isViewMode)
      {
      icbGrid.render(window.Ext.get('PlaceHolderICBGrid_ViewMode'));
      udrcGrid.render(window.Ext.get('PlaceHolderUDRCGrid_ViewMode'));
      }
      else
      if(window.Ext.get('PlaceHolderPIWithICBAllowedGrid')!=null)
      {
      piWithAllowIcbGrid.render(window.Ext.get('PlaceHolderPIWithICBAllowedGrid'));
      icbGrid.render(window.Ext.get('PlaceHolderICBGrid'));
      }
      if(window.Ext.get('PlaceHolderPIWithUDRCAllowedGrid')!=null)
      {
      piWithAllowUDRCGrid.render(window.Ext.get('PlaceHolderPIWithUDRCAllowedGrid'));
      udrcGrid.render(window.Ext.get('PlaceHolderUDRCGrid'));
      }
    });

    //    function loadFromPostback(hidden, store, data, dataDetails) {
    //      var hiddenItems = window.Ext.get(hidden).dom;
    //      if (hiddenItems.value.length > 0)
    //        dataDetails = window.Ext.decode(hiddenItems.value);
    //      store.loadData(data);
    //    }

    window.onload = function () {
      Ext.form.NumberField.prototype.decimalSeparator = DECIMAL_SEPARATOR;
      var hiddenAccounts = window.Ext.get("<%=HiddenAccounts.ClientID %>").dom;
      if (hiddenAccounts.value.length > 0)
        accountData.accounts = window.Ext.decode(hiddenAccounts.value);
      window.accountStore.loadData(accountData);

      //loadFromPostback("<%=HiddenAccounts.ClientID %>", window.accountStore, accountData, accountData.accounts);

      var hiddenPos = window.Ext.get("<%=HiddenPos.ClientID %>").dom;
      if (hiddenPos.value.length > 0)
        poData.pos = window.Ext.decode(hiddenPos.value);
      window.poStore.loadData(poData);

      var hiddenPi = window.Ext.get("<%=HiddenPis.ClientID %>").dom;
      if (hiddenPi.value.length > 0)
        piData.pi = window.Ext.decode(hiddenPi.value);      
      addItemToPIs(piData.pi);

      var hiddenUDRCs = window.Ext.get("<%=HiddenUDRCs.ClientID %>").dom;
      if (hiddenUDRCs.value.length > 0)
        udrcData.UDRCs = window.Ext.decode(hiddenUDRCs.value);
      //window.udrcStore.loadData(udrcData);
      addUDRCs(udrcData.UDRCs);

      var hiddenICBs = window.Ext.get("<%=HiddenICBs.ClientID %>").dom;
      if (hiddenICBs.value.length > 0)
        icbData.icbs = window.Ext.decode(hiddenICBs.value);
      //window.icbStore.loadData(icbData);
      addICBs(icbData.icbs);

      if (window.Ext.get("<%=MTCheckBoxIsGroupSubscription.ClientID %>").dom.value == "true")
        accountToolBar.items.get('IsGroupSubscription').checked = "checked";
    };

    function getDataGrids() {
      var result = getAccountIds() && getPoIds() && getUDRCs() && getICBs();
      if (result) {
        var btnOk = window.Ext.getCmp('ctl00_ContentPlaceHolder1_MTbtnGenerateQuote');
        btnOk.setDisabled(true);
      }
      return result;
    }

    function ReceiveServerData(value) {
      if (typeof value !== 'string' || value === '') {
        return;
      }
      var response = JSON.parse(value);
      if (response.result !== 'ok') {
        window.Ext.UI.SystemError(response.errorMessage);
      }

      addItemToPIs(response.items);
    }
    
    var ConditionSignData = new Ext.data.ArrayStore({
                  id: 0,
                  fields: ['value', 'sign'],
                  data: [
                          ['Equal', '='],
                          ['NotEqual', '<>'],
                          ['Greater', '>'],
                          ['GreaterEqual', '>='],
                          ['Less', '<'],
                          ['LessEqual', '<='],
                          //['Default', '<%=GetLocalResourceObject("DEFAULT_RULE")%>'],
                        ]
                });
  </script>
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

    var accountToolBar = null;
    if (!isViewMode) {
      accountToolBar = new Ext.Toolbar([
        { iconCls: 'add', id: 'Add', text: '<%=GetLocalResourceObject("SELECT_ACCOUNTS")%>', handler: onAccountAdd },
    '->',
    { xtype: 'checkbox', id: 'IsGroupSubscription', boxLabel: '<%=GetLocalResourceObject("ISGROUP.BoxLabel")%>', handler: onGroupSubscriptionCheck },
    { xtype: 'tbspacer', width: 50}]);
    }

    // create the Grid
    var textUserName = '<%=GetLocalResourceObject("USERNAME")%>';
    var textIsGroup = '<%=GetLocalResourceObject("ISGROUP")%>';
    var textAccountActions = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textAccountGridTitle = '<%=GetLocalResourceObject("GRID_TITLE")%>';

    var accountColumns = [
      { id: '_AccountID', header: textUserName, width: 225, sortable: true, renderer: usernameRenderer, dataIndex: '_AccountID' },
      { header: textIsGroup, width: 50, sortable: false, dataIndex: 'IsGroup', renderer: isGroupSubscriptionRenderer }
    ];
    if (!isViewMode)
      accountColumns.push({ header: textAccountActions, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: accountActionsRenderer });

    var accountGrid = new Ext.grid.EditorGridPanel({
      ds: accountStore,
      columns: accountColumns,
      tbar: accountToolBar,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textAccountGridTitle
    });

    //add account button handler
    function onAccountAdd() {
      window.Ext.UI.ShowMultiAccountSelector('accountCallback', 'Frame');
    }

    function onGroupSubscriptionCheck() {
      window.Ext.get("<%=MTCheckBoxIsGroupSubscription.ClientID %>").dom.value = accountToolBar.items.get('IsGroupSubscription').checked;
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
      
      if (accountToolBar.items.get('IsGroupSubscription').checked && gid.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: '<%=GetLocalResourceObject("TEXT_ISGROUP_CHEKED")%>',
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
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
    var poStore = new Ext.data.JsonStore({
      root: 'pos',
      fields: [
        { name: 'Name' },
        { name: 'ProductOfferingId' }
      ]
    });
    poStore.loadData(poData);

    var piData = { pi: [] };

    var piStore = new Ext.data.GroupingStore({
      root: 'piUDRC',
      fields: piRecord,
      groupField: 'ProductOfferingName'
    });

    var textSelectPos = '<%=GetLocalResourceObject("SELECT_POS")%>';
    var poToolBar = new Ext.Toolbar([{ iconCls: 'add', id: 'Add', text: textSelectPos, handler: onPoAdd}]);

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPoName = '<%=GetLocalResourceObject("PONAME")%>';
    var textPoAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textPoGridTitle = '<%=GetLocalResourceObject("PO_GRID_TITLE")%>';

    var poColumns = [
      { id: 'ProductOfferingId', header: textPoId, hidden: true, dataIndex: 'ProductOfferingId' },
      { header: textPoName, width: NAME_COLUMN_HEIGHT + 40, sortable: true, dataIndex: 'Name' }
    ];
    if (!isViewMode)
      poColumns.push({ header: textPoAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: poActionsRenderer });

    var poToolBar = isViewMode ? null : new Ext.Toolbar([{ iconCls: 'add', id: 'Add', text: '<%=GetLocalResourceObject("SELECT_POS")%>', handler: onPoAdd}]);

    var poGrid = new Ext.grid.EditorGridPanel({
      ds: poStore,
      columns: poColumns,
      tbar: poToolBar,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textPoGridTitle
    });

    //this will be called when accts are selected
    function addPoCallback(ids, records) {
      var poData = { poIds: [] };

      for (var i = 0; i < records.length; i++) {
        var productOfferingId = records[i].data.ProductOfferingId;
        var found = poStore.find('ProductOfferingId', productOfferingId);
        if (found == -1) {
          poStore.add(records[i]);
          poData.poIds.push(productOfferingId);
        }
      }
      window.CallServer(JSON.stringify({ poIds: poData.poIds }));
      poSelectorWin2.hide();
    }

    function addItemToPIs(items) {
      for (var i = 0; i < items.length; i++) {
        var piId = items[i].PriceableItemId;
        var poId = items[i].ProductOfferingId;
        var poName = poStore.getAt(poStore.find('ProductOfferingId', poId)).data.Name;
        var recordId = piId + '_' + poId;
        var piKind = items[i].PIKind;
        var piCanIcb = items[i].PICanICB;
        var ratingType = items[i].RatingType;

        var myNewRecord = new piRecord({
          ProductOfferingId: poId,
          ProductOfferingName: poName,
          PriceableItemId: piId,
          Name: items[i].Name,
          DisplayName: items[i].DisplayName,
          PIKind: piKind,
          PICanICB: piCanIcb,
          RatingType: ratingType,
          RecordId: recordId
        });

        piStore.add(myNewRecord);

        var isUDRC = (piKind == 25) || (piKind == 'UnitDependentRecurring');
        var isRC = (piKind == 20) || (piKind == 'Recurring');
        var isNRC = (piKind == 30) || (piKind == 'NonRecurring');

        if (isUDRC) { //UDRC pi
          var found1 = piUDRCStore.find('RecordId', recordId);
          if (found1 == -1) {
            piUDRCStore.add(myNewRecord);
          }
        }

        if ((piCanIcb == 'Y') && (isUDRC || isRC || isNRC)) {
          var found2 = piWithAllowIcbStore.find('RecordId', recordId);
          if (found2 == -1) {
            piWithAllowIcbStore.add(myNewRecord);
          }
        }
      }
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

      var n = piWithAllowIcbStore.data.length;
      for (var i = n - 1; i >= 0; i--) {
        if (piWithAllowIcbStore.data.items[i].data.ProductOfferingId == poId)
          piWithAllowIcbStore.remove(piWithAllowIcbStore.getAt(i));
      }

      n = piUDRCStore.data.length;
      for (i = n - 1; i >= 0; i--) {
        if (piUDRCStore.data.items[i].data.ProductOfferingId == poId)
          piUDRCStore.remove(piUDRCStore.getAt(i));
      }

      n = udrcStore.data.length;
      for (i = n - 1; i >= 0; i--) {
        if (udrcStore.data.items[i].data.ProductOfferingId == poId)
          udrcStore.remove(udrcStore.getAt(i));
      }

      n = icbStore.data.length;
      for (i = n - 1; i >= 0; i--) {
        if (icbStore.data.items[i].data.ProductOfferingId == poId)
          icbStore.remove(icbStore.getAt(i));
      }

      n = piStore.data.length;
      for (i = n - 1; i >= 0; i--) {
        if (piStore.data.items[i].data.ProductOfferingId == poId)
          piStore.remove(piStore.getAt(i));
      }
    }

    function getPoIds() {
      var records = poStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_PO_ERROR,
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

      records = piStore.data.items;
      piData.pi.length = 0;
      for (var i = 0; i < records.length; i++)
        piData.pi.push(records[i].data);

      window.Ext.get("<%=HiddenPoIdTextBox.ClientID %>").dom.value = ids;
      window.Ext.get("<%=HiddenPos.ClientID %>").dom.value = poData.pos.length > 0 ? window.Ext.encode(poData.pos) : "";
      window.Ext.get("<%=HiddenPis.ClientID %>").dom.value = piData.pi.length > 0 ? window.Ext.encode(piData.pi) : "";
      return true;
    }

    function ShowMultiPoSelector(functionName, target) {
      if (window.poSelectorWin2 == null || window.poSelectorWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
        window.poSelectorWin2 = new top.Ext.Window({
          title: '<%=GetLocalResourceObject("SELECT_POS")%>',
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
  <%--UDRC PI Grid--%>
  <script language="javascript" type="text/javascript">
    var piUDRCData = { piUDRC: [] };

    // create the data store
    var piUDRCStore = new Ext.data.GroupingStore({
      root: 'piUDRC',
      fields: piRecord.fields,
      groupField: 'ProductOfferingName'
    });

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPoName = '<%=GetLocalResourceObject("PONAME")%>';
    var textPiName = '<%=GetLocalResourceObject("PINAME")%>';
    var textPiWithUDRCAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textPiWithUDRCGridTitle = '<%=GetLocalResourceObject("UDRC_PI_GRID_TITLE")%>';

    var piWithAllowUDRCColumns = [
      { header: textPoName, hidden: true, dataIndex: 'ProductOfferingName' },
      { header: textPiName, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Name' }
    ];
    if (!isViewMode)
      piWithAllowUDRCColumns.push({ header: textPiWithUDRCAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: piWithAllowUDRCActionsRenderer });

    var piWithAllowUDRCGrid = new Ext.grid.GridPanel({
      ds: piUDRCStore,
      columns: piWithAllowUDRCColumns,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textPiWithUDRCGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
      })
    });

    var textUDRCAdd = '<%=GetLocalResourceObject("ADD_UDRC")%>';

    function piWithAllowUDRCActionsRenderer(value, meta, record) {
      var str = String.format(
            "<a style='cursor:hand;' id='addUDRC_{0}_{1}' title='{2}' href='JavaScript:addUDRC({0},{1});'><img src='/Res/Images/icons/coins_add.png' alt='{2}' /></a>",
            record.data.ProductOfferingId, record.data.PriceableItemId, textUDRCAdd);
      return str;
    }

    var form_addUDRC = new Ext.form.FormPanel();
    var AddUDRCWindow = new Ext.Window();

    function addUDRC(poId, piId) {

      if (AddUDRCWindow.rendered)
        return;

      form_addUDRC = new Ext.form.FormPanel();
      AddUDRCWindow = new Ext.Window();

      var idx = poStore.find('ProductOfferingId', poId);
      var poName = poStore.getAt(idx).data.Name;
      idx = piUDRCStore.find('PriceableItemId', piId);
      var piName = piUDRCStore.getAt(idx).data.Name;

      form_addUDRC = new Ext.FormPanel({
        baseCls: 'x-plain',
        labelWidth: 70,
        defaultType: 'textfield',

        items: [{
          readOnly: true,
          fieldLabel: '<%=GetLocalResourceObject("PONAME")%>',
          id: 'form_addUDRC_POName',
          name: 'form_addUDRC_POName',
          value: poName,
          allowBlank: false,
          anchor: '100%'
        },
          {
            xtype: 'hidden',
            hideLabel: true,
            id: 'form_addUDRC_POId',
            name: 'form_addUDRC_POId',
            value: poId
          },
          {
            readOnly: true,
            fieldLabel: '<%=GetLocalResourceObject("PINAME")%>',
            id: 'form_addUDRC_PIName',
            name: 'form_addUDRC_PIName',
            value: piName,
            allowBlank: false,
            anchor: '100%'
          },
          {
            xtype: 'hidden',
            hideLabel: true,
            id: 'form_addUDRC_PIId',
            name: 'form_addUDRC_PIId',
            value: piId
          },
        //////////
          {
          xtype: 'numberfield',
          allowDecimals: true,
          allowBlank: false,
          allowNegative: false,
          fieldLabel: '<%=GetLocalResourceObject("TEXT_VALUE")%>',
          id: 'form_addUDRC_Value',
          name: 'form_addUDRC_Value',
          anchor: '100%',
          value: 0,
          tabIndex: 0
        },
          {
            xtype: 'datefield',
            fieldLabel: '<%=GetLocalResourceObject("TEXT_START_DATE")%>',
            //format:DATE_FORMAT,
            //altFormats:DATE_TIME_FORMAT,
            //value: '%%MIN_DATE%%', 
            id: 'form_addUDRC_StartDate',
            name: 'form_addUDRC_StartDate',
            allowBlank: true,
            //disabled:%%FIRST_ITEM%%,
            anchor: '100%'
          },
          {
            xtype: 'datefield',
            fieldLabel: '<%=GetLocalResourceObject("TEXT_END_DATE")%>',
            //format:DATE_FORMAT,
            altFormats: DATE_TIME_FORMAT,
            //value: '%%MAX_DATE%%', 
            id: 'form_addUDRC_EndDate',
            name: 'form_addUDRC_EndDate',
            allowBlank: true,
            //disabled:%%FIRST_ITEM%%,
            anchor: '100%'
          }]
      });

      AddUDRCWindow = new Ext.Window({
        title: '<%=GetLocalResourceObject("TEXT_ADD_UDRC")%>',
        width: 400,
        height: 250,
        minWidth: 100,
        minHeight: 100,
        layout: 'fit',
        plain: true,
        bodyStyle: 'padding:5px;',
        buttonAlign: 'center',
        items: form_addUDRC,
        closable: true,
        resizeable: true,
        maximizable: false,
        closeAction: 'close',

        buttons: [{
          text: '<%=GetLocalResourceObject("TEXT_OK")%>',
          handler: onOK_AddUDRC
        },
                  {
                    text: '<%=GetLocalResourceObject("TEXT_CANCEL")%>',
                    handler: onCancel_AddUDRC
                  }]
      });

      AddUDRCWindow.show();
    }

    function onOK_AddUDRC() {

      var isValidForm = form_addUDRC.getForm().isValid();

      if (!(isValidForm == true))
        Ext.Msg.alert('Failed', 'Wrong input');
      else {

        var startDate = form_addUDRC.items.get('form_addUDRC_StartDate').value;
        var endDate = form_addUDRC.items.get('form_addUDRC_EndDate').value;


          var recordId = form_addUDRC.items.get('form_addUDRC_POId').value + "_" +
              form_addUDRC.items.get('form_addUDRC_PIId').value + "_" +
              form_addUDRC.items.get('form_addUDRC_StartDate').value + "_" +
              form_addUDRC.items.get('form_addUDRC_EndDate').value;

          var groupId = '<%=GetLocalResourceObject("PONAME")%>' + ": " +
              form_addUDRC.items.get('form_addUDRC_POName').value + "; " +
              '<%=GetLocalResourceObject("PINAME")%>' + ": " +
              form_addUDRC.items.get('form_addUDRC_PIName').value;

          var found = udrcStore.find('RecordId', recordId);
          if (found == -1) {
            var newUDRCRecord = new udrcRecord({
              ProductOfferingId: form_addUDRC.items.get('form_addUDRC_POId').value,
              PriceableItemId: form_addUDRC.items.get('form_addUDRC_PIId').value,
              Value: form_addUDRC.items.get('form_addUDRC_Value').value,
              StartDate: startDate,
              EndDate: endDate,
              RecordId: recordId,
              GroupId: groupId
            });

            udrcStore.add(newUDRCRecord);

            AddUDRCWindow.destroy();
            AddUDRCWindow.rendered = false;
          }
      }
    }

    function onCancel_AddUDRC() {
      form_addUDRC.getForm().reset({});
      AddUDRCWindow.destroy();
      AddUDRCWindow.rendered = false;
    }

  </script>
  <%-- UDRC Grid--%>
  <script language="javascript" type="text/javascript">
    var udrcData = { UDRCs: [] };

    var udrcRecord = Ext.data.Record.create([// creates a subclass of Ext.data.Record
        {name: 'PriceableItemId' },
        { name: 'ProductOfferingId' },
        { name: 'Value' },
        { name: 'StartDate' },
        { name: 'EndDate' },
        { name: 'RecordId' },
        { name: 'GroupId' }
    ]);

    // create the data store
    var udrcStore = new Ext.data.GroupingStore({
      root: 'UDRCs',
      fields: udrcRecord.fields,
      groupField: 'GroupId'
    });

    function addUDRCs(items) {
      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new udrcRecord({
          ProductOfferingId: items[i].ProductOfferingId,
          PriceableItemId: items[i].PriceableItemId,
          Value: items[i].Value,
          StartDate: items[i].StartDate,
          EndDate: items[i].EndDate,
          RecordId: items[i].RecordId,
          GroupId: items[i].GroupId
        });
        udrcStore.add(myNewRecord);
      }
    }

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textValue = '<%=GetLocalResourceObject("TEXT_VALUE")%>';
    var textStartDate = '<%=GetLocalResourceObject("TEXT_START_DATE")%>';
    var textEndDate = '<%=GetLocalResourceObject("TEXT_END_DATE")%>';
    var textUDRCAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textUDRCGridTitle = '<%=GetLocalResourceObject("UDRC_GRID_TITLE")%>';

    var udrcColumns = [
      { hidden: true, header: ' ', dataIndex: 'GroupId' },
      { header: textValue, width: 95, sortable: true, dataIndex: 'Value' },
      { header: textStartDate, width: 95, sortable: true, dataIndex: 'StartDate' },
      { header: textEndDate, width: 95, sortable: true, dataIndex: 'EndDate' }
    ];
    if (!isViewMode)
      udrcColumns.push({ header: textUDRCAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: UdrcActionsRenderer });

    var udrcGrid = new Ext.grid.GridPanel({
      ds: udrcStore,
      columns: udrcColumns,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textUDRCGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
      })
    });

    function UdrcActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='deleteICB_{0}' title='{1}' href='JavaScript:removeUDRC(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data.RecordId, '<%=GetLocalResourceObject("REMOVE_UDRC")%>');
      return str;
    }

    function removeUDRC(recordId) {
      var idx = udrcStore.find('RecordId', recordId);
      udrcStore.remove(udrcStore.getAt(idx));
    }

    function getUDRCs() {

      var recordsUDRCPi = piUDRCStore.data.items;
      var isAllUDRCSet = true;
      for (var i = 0; i < recordsUDRCPi.length; i++) {
        var idx = udrcStore.find('ProductOfferingId', recordsUDRCPi[i].data.ProductOfferingId);
        if (idx == -1) {
          isAllUDRCSet = false;
          break;
        }
        idx = udrcStore.find('PriceableItemId', recordsUDRCPi[i].data.PriceableItemId);
        if (idx == -1) {
          isAllUDRCSet = false;
          break;
        }
      }

      if (!isAllUDRCSet) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: '<%=GetLocalResourceObject("TEXT_MISSED_UDRC")%>',
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      var records = udrcStore.data.items;
      udrcData.UDRCs.length = 0;
      for (var i = 0; i < records.length; i++)
        udrcData.UDRCs.push(records[i].data);

      window.Ext.get("<%=HiddenUDRCs.ClientID %>").dom.value = udrcData.UDRCs.length > 0 ? window.Ext.encode(udrcData.UDRCs) : "";
      return true;
    }
  </script>
  <%-- PI With Allow ICB Grid--%>
  <script language="javascript" type="text/javascript">
    var piWithAllowIcbData = { pisWithAllowIcb: [] };

    // create the data store
    var piWithAllowIcbStore = new Ext.data.GroupingStore({
      root: 'pisWithAllowIcb',
      fields: piRecord.fields,
      groupField: 'ProductOfferingName'
    });

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPoName = '<%=GetLocalResourceObject("PONAME")%>';
    var textPiName = '<%=GetLocalResourceObject("PINAME")%>';
    var textPiWithICBAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textPiWithICBGridTitle = '<%=GetLocalResourceObject("ICB_PI_GRID_TITLE")%>';

    var piWithAllowIcbColumns = [
      { header: textPoName, hidden: true, dataIndex: 'ProductOfferingName' },
      { header: textPiName, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Name' }
    ];
    if (!isViewMode)
      piWithAllowIcbColumns.push({ header: textPiWithICBAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: piWithAllowIcbActionsRenderer });

    var piWithAllowIcbGrid = new Ext.grid.GridPanel({
      ds: piWithAllowIcbStore,
      columns: piWithAllowIcbColumns,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textPiWithICBGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
      })
    });

    var textIcbAdd = '<%=GetLocalResourceObject("ADD_ICB")%>';

    function piWithAllowIcbActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='addICB_{0}_{1}' title='{2}' href='JavaScript:addICB({0},{1});'><img src='/Res/Images/icons/money.png' alt='{2}' /></a>",
            record.data.ProductOfferingId, record.data.PriceableItemId, textIcbAdd);
      return str;
    }

    var form_addICB = new Ext.form.FormPanel();
    var AddICBWindow = new Ext.Window();

    function addICB(poId, piId) {

      if (AddICBWindow.rendered)
        return;

      form_addICB = new Ext.form.FormPanel();
      AddICBWindow = new Ext.Window();

      var idx = poStore.find('ProductOfferingId', poId);
      var poName = poStore.getAt(idx).data.Name;
      idx = piWithAllowIcbStore.find('PriceableItemId', piId);
      var piName = piWithAllowIcbStore.getAt(idx).data.Name;
      var piKind = piWithAllowIcbStore.getAt(idx).data.PIKind;
      var UDRCType = piWithAllowIcbStore.getAt(idx).data.RatingType;

      var isUDRC = (piKind == 'UnitDependentRecurring');

      form_addICB = new Ext.FormPanel({
        baseCls: 'x-plain',
        labelWidth: 120,
        defaultType: 'textfield',

        items: [{
          readOnly: true,
          fieldLabel: '<%=GetLocalResourceObject("PONAME")%>',
          id: 'form_addICB_POName',
          name: 'form_addICB_POName',
          value: poName,
          allowBlank: false,
          anchor: '100%'
        },
        {
          xtype: 'hidden',
          hideLabel: true,
          id: 'form_addICB_POId',
          name: 'form_addICB_POId',
          value: poId
        },
        {
          readOnly: true,
          fieldLabel: '<%=GetLocalResourceObject("PINAME")%>',
          id: 'form_addICB_PIName',
          name: 'form_addICB_PIName',
          value: piName,
          allowBlank: false,
          anchor: '100%'
        },
        {
          xtype: 'hidden',
          hideLabel: true,
          id: 'form_addICB_PIId',
          name: 'form_addICB_PIId',
          value: piId
        },
        {
          xtype: 'hidden',
          hideLabel: true,
          id: 'form_addICB_PIKind',
          name: 'form_addICB_PIKind',
          value: piKind
        }]
      });

      if (isUDRC) {
        if (UDRCType == 'Tiered') {
          form_addICB.items.add(new Ext.form.Label({
            fieldLabel: '<%=GetLocalResourceObject("CONDITIONS")%>',
            id: 'form_addICB_Conditions',
            name: 'form_addICB_Conditions',
            anchor: '100%',
            labelStyle: 'font-weight:bold;'
          }));

          form_addICB.items.add(new Ext.form.ComboBox({
            fieldLabel: '<%=GetLocalResourceObject("CONDITION_SIGN")%>',
            id: 'form_addICB_ConditionSign',
            name: 'form_addICB_ConditionSign',
            anchor: '100%',
            mode: 'local',
            allowBlank: true,
            autoSelect: false,
            forceSelection :  true,
            store: ConditionSignData,
            displayField: 'sign',
            valueField: 'value',
            //value: 'LessEqual',
            tabIndex: 1
          }));

          form_addICB.items.add(new Ext.form.NumberField({
            allowDecimals: true,
            allowBlank: true,
            allowNegative: false,
            fieldLabel: '<%=GetLocalResourceObject("UNIT_VALUE")%>',
            id: 'form_addICB_UnitValue',
            name: 'form_addICB_UnitValue',
            anchor: '100%',
            value: 0,
            tabIndex: 1
          }));

          form_addICB.items.add(new Ext.form.Label({
            fieldLabel: '<%=GetLocalResourceObject("ACTIONS")%>',
            id: 'form_addICB_Actions',
            name: 'form_addICB_Actions',
            anchor: '100%',
            labelStyle: 'font-weight:bold;'
          }));
          form_addICB.items.add(new Ext.form.NumberField({
            allowDecimals: true,
            allowBlank: true,
            allowNegative: false,
            fieldLabel: '<%=GetLocalResourceObject("UNIT_AMOUNT")%>',
            id: 'form_addICB_UnitAmount',
            name: 'form_addICB_UnitAmount',
            anchor: '100%',
            value: 0,
            tabIndex: 2
          }));
          form_addICB.items.add(new Ext.form.NumberField({
            allowDecimals: true,
            allowBlank: true,
            allowNegative: false,
            fieldLabel: '<%=GetLocalResourceObject("BASE_AMOUNT")%>',
            id: 'form_addICB_BaseAmount',
            name: 'form_addICB_BaseAmount',
            anchor: '100%',
            value: 0,
            tabIndex: 3
          }));
        } //if (UDRCType == 'Tiered') 
        else if (UDRCType == 'Tapered') {
          form_addICB.items.add(new Ext.form.Label({
            fieldLabel: '<%=GetLocalResourceObject("CONDITIONS")%>',
            id: 'form_addICB_Conditions',
            name: 'form_addICB_Conditions',
            anchor: '100%',
            labelStyle: 'font-weight:bold;'
          }));
          form_addICB.items.add(new Ext.form.NumberField({
            allowDecimals: true,
            allowBlank: true,
            allowNegative: false,
            fieldLabel: '<%=GetLocalResourceObject("UNIT_VALUE")%>'+' (<=)',
            id: 'form_addICB_UnitValue',
            name: 'form_addICB_UnitValue',
            anchor: '100%',
            value: 0,
            tabIndex: 1
          }));
          form_addICB.items.add(new Ext.form.Label({
            fieldLabel: '<%=GetLocalResourceObject("ACTIONS")%>',
            id: 'form_addICB_Actions',
            name: 'form_addICB_Actions',
            anchor: '100%',
            labelStyle: 'font-weight:bold;'
          }));
          form_addICB.items.add(new Ext.form.NumberField({
            allowDecimals: true,
            allowBlank: true,
            allowNegative: false,
            fieldLabel: '<%=GetLocalResourceObject("UNIT_AMOUNT")%>',
            id: 'form_addICB_UnitAmount',
            name: 'form_addICB_UnitAmount',
            anchor: '100%',
            value: 0,
            tabIndex: 2
          }))
        } 
      }
      else {
        form_addICB.items.add(new Ext.form.NumberField({
          allowDecimals: true,
          allowBlank: true,
          allowNegative: false,
          fieldLabel: '<%=GetLocalResourceObject("PRICE")%>',
          id: 'form_addICB_Price',
          name: 'form_addICB_Price',
          anchor: '100%',
          value: 0,
          tabIndex: 1
        }));
      }

      AddICBWindow = new Ext.Window({
        title: '<%=GetLocalResourceObject("TEXT_ADD_ICB")%>',
        width: 400,
        height: 300,
        minWidth: 100,
        minHeight: 100,
        layout: 'fit',
        plain: true,
        bodyStyle: 'padding:5px;',
        buttonAlign: 'center',
        items: form_addICB,
        closable: true,
        resizeable: true,
        maximizable: false,
        closeAction: 'close',

        buttons: [{
          text: '<%=GetLocalResourceObject("TEXT_OK")%>',
          handler: onOK_AddICB
        },
                        {
                          text: '<%=GetLocalResourceObject("TEXT_CANCEL")%>',
                          handler: onCancel_AddICB
                        }]
      });

      AddICBWindow.show();
    }

    function onOK_AddICB() {

      var isValidForm = form_addICB.getForm().isValid();

      if (!(isValidForm == true))
        Ext.Msg.alert('Failed', 'Wrong input');
      else {
        var unitValueComp = form_addICB.items.get('form_addICB_UnitValue');
        var unitValue = 0;
        if (unitValueComp != undefined)
          unitValue = unitValueComp.value;

        var unitAmountComp = form_addICB.items.get('form_addICB_UnitAmount');
        var unitAmount = 0;
        if (unitAmountComp != undefined)
          unitAmount = unitAmountComp.value;

        var baseAmountComp = form_addICB.items.get('form_addICB_BaseAmount');
        var baseAmount = 0;
        if (baseAmountComp != undefined)
          baseAmount = baseAmountComp.value;

        var priceComp = form_addICB.items.get('form_addICB_Price');
        var price = 0;
        if (priceComp != undefined)
          price = priceComp.value;

        var piKind = form_addICB.items.get('form_addICB_PIKind').value

        var conditionSignComp = form_addICB.items.get('form_addICB_ConditionSign');
        var conditionSign = '';
        if (conditionSignComp != undefined)
          conditionSign = conditionSignComp.value;

        var unitValueDisplay = '';
        if (piKind == 'UnitDependentRecurring')          
        {
            var found = ConditionSignData.find('value', conditionSign);
            if (found != -1) {
              unitValueDisplay = ConditionSignData.getAt(found).data.sign;
            }
            unitValueDisplay = unitValueDisplay + unitValue;
        }

        var recordId = form_addICB.items.get('form_addICB_POId').value + "_" +
              form_addICB.items.get('form_addICB_PIId').value + "_" +
              price + "_" +
              baseAmount + "_" +
              unitValue + "_" +
              unitAmount;

        var groupId = '<%=GetLocalResourceObject("PONAME")%>' + ": " +
              form_addICB.items.get('form_addICB_POName').value + "; " +
              '<%=GetLocalResourceObject("PINAME")%>' + ": " +
              form_addICB.items.get('form_addICB_PIName').value;

        var found = icbStore.find('RecordId', recordId);
        if (found == -1) {
          var newICBRecord = new icbRecord({
            ProductOfferingId: form_addICB.items.get('form_addICB_POId').value,
            PriceableItemId: form_addICB.items.get('form_addICB_PIId').value,
            Price: price,
            UnitValue: unitValue,
            UnitValueDisplay: unitValueDisplay,
            UnitAmount: unitAmount,
            BaseAmount: baseAmount,
            PIKind: piKind,
            ConditionSign: conditionSign,
            RecordId: recordId,
            GroupId: groupId
          });

          icbStore.add(newICBRecord);

          AddICBWindow.destroy();
          AddICBWindow.rendered = false;
        }
      }
    }

    function onCancel_AddICB() {
      form_addICB.getForm().reset({});
      AddICBWindow.destroy();
      AddICBWindow.rendered = false;
    }

  </script>
  <%-- ICB Grid--%>
  <script language="javascript" type="text/javascript">
    var icbData = { icbs: [] };

    var icbRecord = Ext.data.Record.create([ // creates a subclass of Ext.data.Record
        {name: 'PriceableItemId' },
        { name: 'ProductOfferingId' },
        { name: 'Price' },
        { name: 'UnitValueDisplay' },
        { name: 'UnitValue' },
        { name: 'UnitAmount' },
        { name: 'BaseAmount' },
        { name: 'PIKind' },
        { name: 'ConditionSign' },
        { name: 'RecordId' },
        { name: 'GroupId' }
    ]);

    // create the data store
    var icbStore = new Ext.data.GroupingStore({
      root: 'icbs',
      fields: icbRecord.fields,
      groupField: 'GroupId'
    });

    function addICBs(items) {
      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new icbRecord({
          PriceableItemId: items[i].PriceableItemId,
          ProductOfferingId: items[i].ProductOfferingId,
          Price: items[i].Price,
          UnitValue: items[i].UnitValue,
          UnitValueDisplay: items[i].UnitValueDisplay,
          UnitAmount: items[i].UnitAmount,
          BaseAmount: items[i].BaseAmount,
          PIKind: items[i].PIKind,
          ConditionSign: items[i].ConditionSign,
          RecordId: items[i].RecordId,
          GroupId: items[i].GroupId
        });
        icbStore.add(myNewRecord);
      }
    }

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPrice = '<%=GetLocalResourceObject("PRICE")%>';
    var textUnitValue = '<%=GetLocalResourceObject("UNIT_VALUE")%>';
    var textUnitAmount = '<%=GetLocalResourceObject("UNIT_AMOUNT")%>';
    var textBaseAmount = '<%=GetLocalResourceObject("BASE_AMOUNT")%>';
    var textICBAction = ''; // '<%=GetLocalResourceObject("ACTIONS")%>';
    var textICBGridTitle = '<%=GetLocalResourceObject("ICB_GRID_TITLE")%>';
    var textConditionSign = '<%=GetLocalResourceObject("CONDITION")%>';

    var icbColumns = [
      { header: ' ', hidden: true, dataIndex: 'GroupId' },
      { header: textPrice, width: 55, sortable: true, dataIndex: 'Price' },
      { header: textUnitValue, width: 70, sortable: true, dataIndex: 'UnitValueDisplay' },
      { header: textUnitAmount, width: 80, sortable: true, dataIndex: 'UnitAmount' },
      { header: textBaseAmount, width: 85, sortable: true, dataIndex: 'BaseAmount' }
    ];
    if (!isViewMode)
      icbColumns.push({ header: textICBAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: IcbActionsRenderer });

    var icbGrid = new Ext.grid.GridPanel({
      ds: icbStore,
      columns: icbColumns,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textICBGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "Items" : "Item"]})'
      })
    });

    function IcbActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='deleteICB_{0}' title='{1}' href='JavaScript:removeICB(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data.RecordId, '<%=GetLocalResourceObject("REMOVE_ICB")%>');
      return str;
    }

    function removeICB(recordId) {
      var idx = icbStore.find('RecordId', recordId);
      icbStore.remove(icbStore.getAt(idx));
    }

    function getICBs() {
      var records = icbStore.data.items;

      if (accountToolBar.items.get('IsGroupSubscription').checked && records.length > 0) {
        var res = confirm('<%=GetLocalResourceObject("ICB_GROUP_CONFIRM")%>');
        return res == true ? readICBs(records) : false;
      }
      return readICBs(records);
    }

    function readICBs(records) {
      icbData.icbs.length = 0;
      for (var i = 0; i < records.length; i++)
        icbData.icbs.push(records[i].data);

      window.Ext.get("<%=HiddenICBs.ClientID %>").dom.value = icbData.icbs.length > 0 ? window.Ext.encode(icbData.icbs) : "";
      return true;
    }
  </script>
</asp:Content>
