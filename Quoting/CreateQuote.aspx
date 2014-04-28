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
    Collapsed="False" meta:resourcekey="MTPanelUDRCResource">
     <div id="PlaceHolderUDRCMetricsGrid"></div> 
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelICBs" runat="server" Text="ICBs for quote" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelICBResource">
     <div id="PlaceHolderPIWithICBAllowedGrid" class="LeftColumn"></div>
     <div id="PlaceHolderICBGrid" class="RightColumn"></div>
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
  <input id="HiddenICBs" runat="server" type="hidden" />
  
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
        { id: '_AccountID', header: textUserName, width: 145, sortable: true, renderer: usernameRenderer, dataIndex: '_AccountID' },
        { header: textIsGroup, width: 120, sortable: false, dataIndex: 'IsGroup', renderer: isGroupSubscriptionRenderer },
        { header: textAccountActions, width: 50, sortable: false, dataIndex: '', renderer: accountActionsRenderer }
      ],
      tbar: accountToolBar,
      stripeRows: true,
      height: 300,
      width: 345,
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
        { header: textPoName, width: 210, sortable: true, dataIndex: 'Name' },
        { header: textPoAction, width: 50, sortable: false, dataIndex: '', renderer: poActionsRenderer }
      ],
      tbar: poToolBar,
      stripeRows: true,
      height: 300,
      width: 345,
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
  
    <%-- UDRCs Grid--%>
  <script language="javascript" type="text/javascript">
  
    var dropDownValues_UDRC = [ ]; 
    var ddStoreUDRC = new Ext.data.SimpleStore({
		          fields:['name', 'value'],
		          data: dropDownValues_UDRC,
		          storeId:'dropDownValues_UDRC_store'
          });
          
          //var valueText = TEXT_VALUE + '<br/>' + TEXT_MIN + ' %%MIN_VALUE%% <br/>' + TEXT_MAX + ' %%MAX_VALUE%%';

    var EditUDRCForm = new Ext.form.FormPanel({
      baseCls: 'x-plain',
      labelWidth: 55,
      defaultType: 'textfield',

      items: [{
          readOnly: true,
          fieldLabel: TEXT_NAME,
          id: 'POName',
          name: 'POName',
          //value: '%%NAME%%',
          value: 'PO NAME',
          allowBlank: false,
          anchor: '100%'
        }, {
          readOnly: true,
          fieldLabel: TEXT_NAME,
          id: 'UDRCName',
          name: 'UDRCName',
          //value: '%%NAME%%',
          value: 'UDRC NAME',
          allowBlank: false,
          anchor: '100%'
        }, {
          xtype: 'combo',
          //fieldLabel: valueText,
          fieldLabel: 'Value:',
          id: 'Value',
          name: 'Value',
          allowBlank: false,
          editable: true,
          forceSelection: false,
          typeAhead: true,
          triggerAction: 'all',
          mode: 'local',
          store: ddStoreUDRC,
          valueField: 'value',
          displayField: 'name',
          anchor: '100%',
          labelSeparator: ''
        }, {
          xtype: 'hidden',
          hideLabel: true,
          name: 'IsInteger',
          //value: '%%IS_INTEGER%%'
          value: 'true'
        }, {
          xtype: 'hidden',
          hideLabel: true,
          name: 'ID',
          //value: '%%ID%%', 
          value: '101',
          anchor: '100% -53'  // anchor width by percentage and height by raw adjustment
        }]
    });

    var EditUDRCWindow = new Ext.Window({
      title: 'Edit UDRC value',
      width: 400,
      height: 250,
      minWidth: 100,
      minHeight: 100,
      layout: 'fit',
      plain: true,
      bodyStyle: 'padding:5px;',
      buttonAlign: 'center',
      items: EditUDRCForm,
      closable: false,

      buttons: [{
          text: TEXT_OK,
          handler: onOK_EditUDRC
        }, {
          text: TEXT_CANCEL,
          handler: onCancel_EditUDRC
        }]
    });

    function onOK_EditUDRC() {

      // Construct regular expressions for thousand separator and decimal separator.
      var reThouSep;
      if (THOUSAND_SEPARATOR == '.') {
        reThouSep = new RegExp('\\.', 'g');
      } else {
        reThouSep = new RegExp(THOUSAND_SEPARATOR, 'g');
      }
      var reDecimalSep;
      if (DECIMAL_SEPARATOR == '.') {
        reDecimalSep = new RegExp('\\.', 'g');
      } else {
        reDecimalSep = new RegExp(DECIMAL_SEPARATOR, 'g');
      }

      //code added on 07/08/08 to prevent users from entering values outside of UDRC enum range
      var selectval;

      // Remove any thousand separators and convert decimal separator
      // to a period before calling isNaN().
      var noThousSepValue = Ext.get('Value').getValue().replace(reThouSep, '');
      var tmpValue = noThousSepValue.replace(reDecimalSep, '.');
      if (isNaN(tmpValue)) {
        Ext.getCmp('Value').reset();
      } else {
        selectval = Number(tmpValue);
      }

      // MIN_VALUE and MAX_VALUE may contain commas as separators, so put in quotes.
      var minval = '%%MIN_VALUE%%';
      var maxval = '%%MAX_VALUE%%';

      // Strip out thousand separators and convert decimal separators
      // for minval and maxval before doing mathematical comparison.
      minval = minval.replace(reThouSep, '');
      minval = minval.replace(reDecimalSep, '.');
      minval = Number(minval);
      maxval = maxval.replace(reThouSep, '');
      maxval = maxval.replace(reDecimalSep, '.');
      maxval = Number(maxval);

      if ((selectval < minval) || (selectval > maxval)) {
        Ext.getCmp('Value').reset();
      }

      if (EditUDRCForm.form.isValid()) {

        // Submit the form.

        // Don't include thousand separators in value sent to server.
        Ext.get('Value').dom.value = noThousSepValue;

        /*EditUDRCForm.getForm().submit({
          waitMsg: TEXT_ADDING_UDRC,
          url: '/MetraNet/Quoting/CreateQuote.aspx?UPDATE=TRUE',
          failure: function(form, action) {
            //Ext.MessageBox.alert('Error Message', 'Error processing form on server.');
          },
          success: function(form, action) {
            //Ext.MessageBox.alert('Confirm', action.result.info);
            //window.hide();
            //dataStore.load({params:{start:0, limit:10}});
          }
        });*/
      } else {
        Ext.MessageBox.alert(TEXT_ERROR, TEXT_PLEASE_FIX);
      }
    }

    function onCancel_EditUDRC() {
      EditUDRCWindow.hide();
    }

    function on_UDRC_grid_refresh() {
      // Here is a place to load UDRCs 
      UDRCData = { UDRCs: [{ POName: 'PO1', UDRCName: 'udrc1', Value: 1 }] };
      window.UDRCStore.loadData(UDRCData);
    }

    var UDRCData = { UDRCs: [] };

         // create the data store
    var UDRCStore = new Ext.data.JsonStore({
      root: 'UDRCs',
      fields: [
        { name: 'POName' },
        { name: 'UDRCName' },
        { name: 'Value' }
      ]
    });

    var tbar_refresh_UDRC_grid = new Ext.Toolbar([{
      text: '<%=GetLocalResourceObject("TEXT_REFRESH") %>',
      handler: on_UDRC_grid_refresh,
      tooltip: '<%=GetLocalResourceObject("TEXT_REFRESH_UDRC_GRID") %>',
      iconCls: 'add'
    }, '-']);
          
    // create the Grid
    var UDRCgrid = new Ext.grid.GridPanel({
      store: UDRCStore,
      columns: [
        { id: "Name", header: TEXT_NAME, width: 175, sortable: true, dataIndex: 'POName' },
        { id: "Name", header: TEXT_NAME, width: 175, sortable: true, dataIndex: 'UDRCName' },
        { header: TEXT_VALUE, width: 75, sortable: true, dataIndex: 'Value' },
        { header: '<%=GetLocalResourceObject("ACTIONS") %>', width: 75, sortable: false, dataIndex: 'Actions', renderer: UDRCActionsRenderer }
      ],
      stripeRows: true,
      autoExpandColumn: 'Name',
      height: 150,
      width: 600,
      tbar: tbar_refresh_UDRC_grid,
      title: 'UDRC metrics for quote'
    });
       
    var textEditUDRCValue = '<%=GetLocalResourceObject("EDIT_UDRC_VALUE")%>';

    function UDRCActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='edit_udrc' title='{1}' href='JavaScript:editUDRCValue({0});'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",
        record.data.id, textEditUDRCValue);
      return str;
    }

    function editUDRCValue() {
      EditUDRCWindow.show();
    }

  </script>
  
  <%-- PI With Aloow ICB Grid--%>
  <script language="javascript" type="text/javascript">
    var piWithAllowIcbData = { pisWithAllowIcb: [] };

    // create the data store
    var piWithAllowIcbStore = new Ext.data.JsonStore({
      root: 'pisWithAllowIcb',
      fields: [
        { name: 'ProductOfferingName' },
        { name: 'PricableItemName' },
        { name: 'PricableItemId' },
        { name: 'ProductOfferingId' }        
      ]
    });
    piWithAllowIcbStore.loadData(piWithAllowIcbData);

   // var textSelectPos = '<%=GetLocalResourceObject("SELECT_POS")%>';
    
    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPoName = '<%=GetLocalResourceObject("PONAME")%>';
    var textPiName = '<%=GetLocalResourceObject("PINAME")%>';
    var textPiWithICBAction = '<%=GetLocalResourceObject("ACTIONS")%>';
    var textPiWithICBGridTitle = '<%=GetLocalResourceObject("PI_GRID_TITLE")%>';

    var piWithAllowIcbGrid = new Ext.grid.EditorGridPanel({
      ds: piWithAllowIcbStore,
      columns: [
        //{ id: 'ProductOfferingId', header: textPoId, width: 30, sortable: true, dataIndex: 'ProductOfferingId' },
        { header: textPoName, width: 140, sortable: true, dataIndex: 'ProductOfferingName' },
        { header: textPiName, width: 140, sortable: true, dataIndex: 'PricableItemName' },
        { header: textPiWithICBAction, width: 50, sortable: false, dataIndex: '', renderer: piWithAllowIcbActionsRenderer }
      ],
      stripeRows: true,
      height: 300,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textPiWithICBGridTitle
    });

    //this will be called when icbs are added
    function addIcbCallback(ids, records) {
//      for (var i = 0; i < records.length; i++) {
//        var productOfferingId = records[i].data.ProductOfferingId;
//        var found = poStore.find('ProductOfferingId', productOfferingId);
//        if (found == -1) {
//          poStore.add(records[i]);
//        }
//      }
//      poSelectorWin2.hide();
    }

    var textIcbAdd = '<%=GetLocalResourceObject("ADD_ICB")%>';

    function piWithAllowIcbActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='addICB_{0}_{1}' title='{2}' href='JavaScript:addICB({0},{1});'><img src='/Res/Images/icons/money.png' alt='{2}' /></a>",
        record.data.ProductOfferingId, record.data.PricableItemId, textIcbAdd);
      return str;
    }

    function addICB(poId, piId) {
      alert("Does not implement");
      ShowIcbInputForm(addIcbCallback, "Frame");
    }

//    function getPoIds() {
//      var records = poStore.data.items;
//      if (records.length == 0) {
//        window.Ext.Msg.show({
//          title: window.TEXT_ERROR,
//          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
//          buttons: window.Ext.Msg.OK,
//          icon: window.Ext.MessageBox.ERROR
//        });
//        return false;
//      }

//      poData.pos.length = 0;
//      var ids = "";
//      for (var i = 0; i < records.length; i++) {
//        poData.pos.push(records[i].data);
//        if (i > 0) {
//          ids += ",";
//        }
//        ids += records[i].data.ProductOfferingId;
//      }

//      window.Ext.get("<%=HiddenPoIdTextBox.ClientID %>").dom.value = ids;
//      window.Ext.get("<%=HiddenPos.ClientID %>").dom.value = poData.pos.length > 0 ? window.Ext.encode(poData.pos) : "";
//      return true;
//    }

    var form_addICB = new Ext.form.FormPanel({
            baseCls: 'x-plain',
            labelWidth: 55,
            defaultType: 'textfield',

            items: [{
                xtype: 'datefield',
                //fieldLabel: TEXT_START_DATE,
                //format:DATE_FORMAT,
                //altFormats:DATE_TIME_FORMAT,
                //value: '%%MIN_DATE%%', 
                id: 'StartDate',
                name: 'StartDate',
                allowBlank:true,
                //disabled:%%FIRST_ITEM%%,
                anchor:'100%'  
            }]
          });

    function ShowIcbInputForm(functionName, target) {
      if (window.addIcbWin2 == null || window.addIcbWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
        window.addIcbWin2 = new top.Ext.Window({
          title: 'TEXT_ADD_ICB',
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
          items: form_addICB
        });
      }
      if (window.addIcbWin != null) {
        window.addIcbWin.hide();
      }
      window.lastTarget2 = target;
      window.lastFunctionName2 = functionName;
      window.addIcbWin2.show();

      window.addIcbWin2.on('close', function () {
        window.addIcbWin2 = null;
      });
    }
  </script>

  <%-- ICB Grid--%>
  <script language="javascript" type="text/javascript">
    var icbData = { icbs: [] };

    // create the data store
    var icbStore = new Ext.data.JsonStore({
      root: 'icbs',
      fields: [        
        { name: 'PricableItemId' },
        { name: 'ProductOfferingId' },
        { name: 'Price' },
        { name: 'UnitValue' },
        { name: 'UnitAmount' },
        { name: 'BaseAmount' }
      ]
    });
    icbStore.loadData(icbData);

    // var textSelectPos = '<%=GetLocalResourceObject("SELECT_POS")%>';

    // create the Grid
    var textPoId = '<%=GetLocalResourceObject("POID")%>';
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPrice = '<%=GetLocalResourceObject("PRICE")%>';
    var textUnitValue = '<%=GetLocalResourceObject("UNIT_VALUE")%>';
    var textUnitAmount = '<%=GetLocalResourceObject("UNIT_AMOUNT")%>';
    var textBaseAmount = '<%=GetLocalResourceObject("BASE_AMOUNT")%>';
    var textICBAction = '<%=GetLocalResourceObject("ACTIONS")%>';
    var textICBGridTitle = '<%=GetLocalResourceObject("ICB_GRID_TITLE")%>';

    var icbGrid = new Ext.grid.EditorGridPanel({
      ds: icbStore,
      columns: [
        { header: textPoId, width: 30, sortable: true, dataIndex: 'ProductOfferingId' },
        { header: textPiId, width: 30, sortable: true, dataIndex: 'PricableItemId' },
        { header: textPrice, width: 50, sortable: true, dataIndex: 'Price' },
        { header: textUnitValue, width: 50, sortable: true, dataIndex: 'UnitValue' },
        { header: textUnitAmount, width: 50, sortable: true, dataIndex: 'UnitAmount' },
        { header: textBaseAmount, width: 50, sortable: true, dataIndex: 'BaseAmount' },

        { header: textICBAction, width: 50, sortable: false, dataIndex: '', renderer: IcbActionsRenderer }
      ],
      stripeRows: true,
      height: 300,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textICBGridTitle
    });

    //var textIcbAdd = '<%=GetLocalResourceObject("ADD_ICB")%>';

    function IcbActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='deleteICB_{0}' title='{1}' href='JavaScript:deleteICB({0});'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data.ProductOfferingId, textIcbAdd);
      return str;
    }

    function deleteICB(id) {
      alert("Does not implement");
      //ShowIcbInputForm(addIcbCallback, "Frame");
    }

    //    function getPoIds() {
    //      var records = poStore.data.items;
    //      if (records.length == 0) {
    //        window.Ext.Msg.show({
    //          title: window.TEXT_ERROR,
    //          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS,
    //          buttons: window.Ext.Msg.OK,
    //          icon: window.Ext.MessageBox.ERROR
    //        });
    //        return false;
    //      }

    //      poData.pos.length = 0;
    //      var ids = "";
    //      for (var i = 0; i < records.length; i++) {
    //        poData.pos.push(records[i].data);
    //        if (i > 0) {
    //          ids += ",";
    //        }
    //        ids += records[i].data.ProductOfferingId;
    //      }

    //      window.Ext.get("<%=HiddenPoIdTextBox.ClientID %>").dom.value = ids;
    //      window.Ext.get("<%=HiddenPos.ClientID %>").dom.value = poData.pos.length > 0 ? window.Ext.encode(poData.pos) : "";
    //      return true;
    //    }

  </script>
  
  <%-- General--%>
  <script language="javascript" type="text/javascript">
    
    Ext.onReady(function () {
      accountGrid.render(window.Ext.get('PlaceHolderAccountsGrid'));
      poGrid.render(window.Ext.get('PlaceHolderProductOfferingsGrid'));
      UDRCgrid.render(window.Ext.get('PlaceHolderUDRCMetricsGrid'));
      piWithAllowIcbGrid.render(window.Ext.get('PlaceHolderPIWithICBAllowedGrid'));
      icbGrid.render(window.Ext.get('PlaceHolderICBGrid'));
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

      window.UDRCStore.loadData(UDRCData);
    };
    
    function getDataGrids() {
      return getAccountIds() && getPoIds();
    }
    
  </script>
    
</asp:Content>