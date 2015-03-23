<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ManageSubscriptionParameters.aspx.cs" Inherits="MetraNet.AccountConfigSets.ManageSubscriptionParameters"
Title="MetraNet - Manage Subscription Parameters" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <MT:MTTitle ID="ManageSubscriptionParameterTitle" runat="server" meta:resourcekey="manageSubscriptionParameterTitle"/>
  <br />
   <MT:MTPanel ID="MTPanelAccountConfigSetParameters" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="panelAccountConfigSetParametersResource">
    <div>
    <MT:MTTextBoxControl ID="MTtbSubParamsDescription" AllowBlank="True" ControlWidth="560"
        LabelWidth="120" MaxLength="200" runat="server" meta:resourcekey="tbSubParamsDescriptionResource"/>
    </div>
    <div>
    <div id="leftColumn1" class="LeftColumn">    
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpSubParamsStartDate"
        LabelWidth="120" meta:resourcekey="dpSubParamsStartDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpSubParamsEndDate"
        LabelWidth="120" meta:resourcekey="dpSubParamsEndDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
    </div>
    <div id="rightColumn1" class="RightColumn">      
      <MT:MTInlineSearch ID="MTisCorpAccountId" AllowBlank="True" ReadOnly="False"
        LabelWidth="120" runat="server" meta:resourcekey="isCorpAccountIdResource"/>
      <MT:MTTextBoxControl ID="MTtbGroupSubscriptionName" AllowBlank="True" ReadOnly="False"
        LabelWidth="120" runat="server" meta:resourcekey="tbGroupSubscriptionNameResource"/>      
    </div>
    </div>
  </MT:MTPanel>

  <MT:MTPanel ID="MTPanelSelectPo" runat="server" Collapsible="True" meta:resourcekey="panelSubscriptionParametersResource">    
    <div>
    <MT:MTTextBoxControl ID="MTtbSubParamsPoName" AllowBlank="True" ControlWidth="560" ReadOnly="True"
        LabelWidth="120" MaxLength="200" runat="server" meta:resourcekey="tbSubParamsPoNameResource"/>
    </div>
    <div>
      <div id="leftColumn2" class="LeftColumn">    
       <MT:MTTextBoxControl ID="MTtbSubParamsPo" AllowBlank="True" ReadOnly="True"
          LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsPoResource"/>
      </div>
      <div id = "PlaceHolderSelectPoToolBar" class="RightColumn">  
      </div>
    </div>
  </MT:MTPanel>

  <MT:MTPanel ID="MTPanelUDRC" runat="server" Collapsible="True"
    Collapsed="False" meta:resourcekey="MTPanelUDRCResource">
    <div id="PlaceHolderPIWithUDRCAllowedGrid" class="LeftColumn">
    </div>
    <div id="PlaceHolderUDRCGrid" class="RightColumn">
    </div>
  </MT:MTPanel>

  <div class="x-panel-btns-ct">
    <div style="width: 720px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center; width: 25%; margin: auto;">
        <table>
          <tr>            
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnAddAccountConfigSet" runat="server" OnClientClick="return getDataGrids();"
                OnClick="btnAddAccountConfigSet_Click" Visible="False" TabIndex="150" meta:resourcekey="btnAddAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnUpdateAccountConfigSet" runat="server" OnClientClick="return getDataGrids();"
                OnClick="btnUpdateAccountConfigSet_Click" Visible="False" TabIndex="160" meta:resourcekey="btnUpdateAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnGoToUpdateAccountConfigSet" runat="server" 
                OnClick="btnGoToUpdateAccountConfigSet_Click" Visible="False" TabIndex="170" meta:resourcekey="btnGoToUpdateAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="180" meta:resourcekey="MTbtnCancelResource" />
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
  <input id="HiddenUDRCs" runat="server" type="hidden" />
  <input id="HiddenPis" runat="server" type="hidden" />
  <%-- General--%>
  <script language="javascript" type="text/javascript">

  function getUpdateApprove()
  {                
      return true;        
  }

    var GRID_HEIGHT = 200;
    var ACTIONS_COLUMN_HEIGHT = 25;
    var NAME_COLUMN_HEIGHT = 255;
    var isViewMode = <%=IsViewMode.ToString().ToLower()%>;

    var piRecord = Ext.data.Record.create([// creates a subclass of Ext.data.Record
      { name: 'PriceableItemId' },
      { name: 'Name' },
      { name: 'DisplayName' },
      { name: 'PIKind' },
      { name: 'PICanICB' },
      { name: 'RatingType' },
      { name: 'RecordId' }
    ]);
    
    Ext.onReady(function () {

      if(poToolBar!= null)
          poToolBar.render(window.Ext.get('PlaceHolderSelectPoToolBar'));
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
      var hiddenPi = window.Ext.get("<%=HiddenPis.ClientID %>").dom;
      if (hiddenPi.value.length > 0)
        piUDRCData.pi = window.Ext.decode(hiddenPi.value);      
      addItemToPIs(piUDRCData.pi);

      var hiddenUDRCs = window.Ext.get("<%=HiddenUDRCs.ClientID %>").dom;
      if (hiddenUDRCs.value.length > 0)
        udrcData.UDRCs = window.Ext.decode(hiddenUDRCs.value);
      //window.udrcStore.loadData(udrcData);
      addUDRCs(udrcData.UDRCs);      
    };

    function getDataGrids() {
      var result = getUDRCs() && getPo() ;
      
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
      loadPoToControls(response.poName);
    }      
  </script>
  <%-- Product Offering Grid--%>
  <script language="javascript" type="text/javascript">

    var poToolBar = isViewMode ? null : new Ext.Toolbar([
    { iconCls: 'add', id: 'AddPo', text: '<%=GetLocalResourceObject("TEXT_SELECT_POS")%>', handler: onPoAdd },    
    ]);

    function selectSubParams() {
      ShowSubParamsSelector('addSubParamsCallback', 'Frame');
    }

    function loadPoToControls(poName) {
      if (poName == null)
        return;

      window.Ext.get("<%=MTtbSubParamsPoName.ClientID %>").dom.value = poName;      
    };

    function addItemToPIs(items) {
      piUDRCStore.removeAll();
      udrcStore.removeAll();

      if (items != null) {
        for (var i = 0; i < items.length; i++) {
          var piId = items[i].PriceableItemId;
          var displayName = items[i].DisplayName;
          var recordId = piId + '_' + displayName;
          var piKind = items[i].PIKind;
          var ratingType = items[i].RatingType;

          var myNewRecord = new piRecord({
            PriceableItemId: piId,
            Name: items[i].Name,
            DisplayName: displayName,
            PIKind: piKind,
            RatingType: ratingType,
            RecordId: recordId
          });

          var isUDRC = (piKind == 25) || (piKind == 'UnitDependentRecurring');

          if (isUDRC) { //UDRC pi
            piUDRCStore.add(myNewRecord);
          }
        }
      }      
    }

    function onPoAdd() {
      ShowMultiPoSelector('addPoCallback', 'Frame');
    }

    function ShowMultiPoSelector(functionName, target) {
      if (window.poSelectorWin2 == null || window.poSelectorWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
        window.poSelectorWin2 = new top.Ext.Window({
          title: '<%=GetLocalResourceObject("TEXT_SELECT_POS")%>',
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
          html: '<iframe id="poSelectorWin2" src="/MetraNet/AccountConfigSets/SelectPoForSubscriptionParameters.aspx?t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no"/>'
        });
      }
      if (window.poSelectorWin2 != null) {
        window.poSelectorWin2.hide();
      }
      window.lastTarget2 = target;
      window.lastFunctionName2 = functionName;
      window.poSelectorWin2.show();
      window.poSelectorWin2.on('close', closeFrame);
    }

    function addPoCallback(ids) {
      if (window.Ext.get("<%=MTtbSubParamsPo.ClientID %>").dom.value != ids) {
        window.Ext.get("<%=MTtbSubParamsPo.ClientID %>").dom.value = ids;
        window.CallServer(JSON.stringify({ poId: ids }));
      }
      window.poSelectorWin2.hide();
      window.poSelectorWin2.close();
    }

    function closeFrame() {
      window.getFrameMetraNet().Ext.getDom("poSelectorWin2").contentWindow = null;
      window.getFrameMetraNet().frames["poSelectorWin2"] = null;
      window.poSelectorWin2 = null;
    }
    
    function getPo() {
      var poId = window.Ext.get("<%=MTtbSubParamsPo.ClientID %>").dom.value;
      if ((poId == null) || (poId == '') || (poId === undefined)){
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: '<%=GetLocalResourceObject("TEXT_MISSED_PO")%>',
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }
      return true;
    }
  </script>
  <%--UDRC PI Grid--%>
  <script language="javascript" type="text/javascript">
    var piUDRCData = { piUDRC: [] };

    // create the data store
    var piUDRCStore = new Ext.data.ArrayStore({
      root: 'piUDRC',
      fields: piRecord.fields
    });

    // create the Grid    
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textPiName = '<%=GetLocalResourceObject("PINAME")%>';
    var textPiWithUDRCAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textPiWithUDRCGridTitle = '<%=GetLocalResourceObject("UDRC_PI_GRID_TITLE")%>';

    var piWithAllowUDRCColumns = [
      { header: textPiName, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'DisplayName' }
    ];
    if (!isViewMode)
      piWithAllowUDRCColumns.push({ header: textPiWithUDRCAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: piWithAllowUDRCActionsRenderer });

    var piWithAllowUDRCGrid = new Ext.grid.GridPanel({
      ds: piUDRCStore,
      columns: piWithAllowUDRCColumns,
      enableHdMenu: false,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textPiWithUDRCGridTitle
      });

    var textUDRCAdd = '<%=GetLocalResourceObject("TEXT_ADD_UDRC")%>';

    function piWithAllowUDRCActionsRenderer(value, meta, record) {
      var str = String.format(
            "<a style='cursor:hand;' id='addUDRC_{0}_{1}' title='{1}' href='JavaScript:addUDRC({0});'><img src='/Res/Images/icons/coins_add.png' alt='{1}' /></a>",
            record.data.PriceableItemId, textUDRCAdd);
      return str;
    }

    var form_addUDRC = new Ext.form.FormPanel();
    var AddUDRCWindow = new Ext.Window();

    function addUDRC(piId) {

      if (AddUDRCWindow.rendered)
        return;

      form_addUDRC = new Ext.form.FormPanel();
      AddUDRCWindow = new Ext.Window();

      var idx = piUDRCStore.find('PriceableItemId', piId);
      var piName = piUDRCStore.getAt(idx).data.Name;

      form_addUDRC = new Ext.FormPanel({
        baseCls: 'x-plain',
        labelWidth: 70,
        defaultType: 'textfield',

        items: [
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
        var piId = form_addUDRC.items.get('form_addUDRC_PIId').value;
        var piName = form_addUDRC.items.get('form_addUDRC_PIName').value;
        var startDate = form_addUDRC.items.get('form_addUDRC_StartDate').value;
        var endDate = form_addUDRC.items.get('form_addUDRC_EndDate').value;
        var recordId = piId + "_" + startDate + "_" + endDate;

        var found = udrcStore.find('RecordId', recordId);
        if (found == -1) {
          var newUDRCRecord = new udrcRecord({
            PriceableItemId: piId,
            PriceableItemName: piName,
            Value: form_addUDRC.items.get('form_addUDRC_Value').value,
            StartDate: startDate,
            EndDate: endDate,
            RecordId: recordId
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
        { name: 'PriceableItemId' },
        { name: 'PriceableItemName' },
        { name: 'Value' },
        { name: 'StartDate' },
        { name: 'EndDate' },
        { name: 'RecordId' }
    ]);

    // create the data store
    var udrcStore = new Ext.data.GroupingStore({
      root: 'UDRCs',
      fields: udrcRecord.fields,
      groupField: 'PriceableItemName'
    });

    function addUDRCs(items) {
      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new udrcRecord({
          PriceableItemId: items[i].PriceableItemId,
          PriceableItemName: items[i].PriceableItemName,
          Value: items[i].Value,
          StartDate: items[i].StartDate,
          EndDate: items[i].EndDate,
          RecordId: items[i].RecordId
        });
        udrcStore.add(myNewRecord);
      }
    }

    // create the Grid    
    var textPiId = '<%=GetLocalResourceObject("PIID")%>';
    var textValue = '<%=GetLocalResourceObject("TEXT_VALUE")%>';
    var textStartDate = '<%=GetLocalResourceObject("TEXT_START_DATE")%>';
    var textEndDate = '<%=GetLocalResourceObject("TEXT_END_DATE")%>';
    var textUDRCAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textUDRCGridTitle = '<%=GetLocalResourceObject("UDRC_GRID_TITLE")%>';

    var udrcColumns = [
      { hidden: true, header: ' ', dataIndex: 'RecordId' },
      { hidden: true, header: ' ', dataIndex: 'PriceableItemName' },
      { header: textValue, width: 95, sortable: true, dataIndex: 'Value' },
      { header: textStartDate, width: 95, sortable: true, dataIndex: 'StartDate' },
      { header: textEndDate, width: 95, sortable: true, dataIndex: 'EndDate' }
    ];
    if (!isViewMode)
      udrcColumns.push({ header: textUDRCAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: UdrcActionsRenderer });

    var udrcGrid = new Ext.grid.GridPanel({
      ds: udrcStore,
      columns: udrcColumns,
      enableHdMenu: false,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textUDRCGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "<%=GetLocalResourceObject("ITEMS")%>" : "<%=GetLocalResourceObject("ITEM")%>"]})'
      })
    });

    function UdrcActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='deleteUDRC_{0}' title='{1}' href='JavaScript:removeUDRC(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
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

      records = piUDRCStore.data.items;
      piUDRCData.piUDRC.length = 0;
      for (var i = 0; i < records.length; i++)
        piUDRCData.piUDRC.push(records[i].data);

      window.Ext.get("<%=HiddenPis.ClientID %>").dom.value = piUDRCData.piUDRC.length > 0 ? window.Ext.encode(piUDRCData.piUDRC) : "";
      return true;
    }
  </script>
</asp:Content>
