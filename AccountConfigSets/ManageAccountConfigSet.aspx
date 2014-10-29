<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true"
  CodeFile="ManageAccountConfigSet.aspx.cs" Inherits="MetraNet.AccountConfigSets.ManageAccountConfigSet" Title="MetraNet - Manage OnBoard Template"
  Culture="auto" UICulture="auto" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
  <asp:PlaceHolder ID="PlaceHolderPOJavaScript" runat="server"></asp:PlaceHolder>
  <MT:MTTitle ID="ManageAccountConfigSetTitle" runat="server" />
  <br />
  <MT:MTPanel ID="MTPanelAccountConfigSetParameters" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="panelAccountConfigSetParameters">
    <div id="leftColumn1" class="LeftColumn">
      <MT:MTTextBoxControl ID="MTtbAcsDescription" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="tbAcsDescriptionResource"/>
      <MT:MTTextBoxControl ID="MTtbRank" AllowBlank="True" LabelWidth="120" runat="server"
       meta:resourcekey="tbRankResource"/>
      
    </div>
    <div id="rightColumn1" class="RightColumn">
      <MT:MTCheckBoxControl ID="MTcbAcsEnabled" runat="server" LabelWidth="120"
        meta:resourcekey="cbAcsEnabledResource"/>
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpStartDate"
        Label="Start date" LabelWidth="120" meta:resourcekey="dpStartDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpEndDate"
        Label="End date" LabelWidth="120" meta:resourcekey="dpEndDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelCriteria" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="panelCriteriaResource">
    <div id="PlaceHolderSelectionCriteria" class="LeftColumn">
    </div>
    <div id="PlaceHolderPropertiesToSet" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelSubscriptionParameters" runat="server" Collapsible="True"
    Collapsed="True" meta:resourcekey="panelSubscriptionParametersResource">
    <%--div style="width: 720px" class="x-panel-btns x-panel-btns-center">
      <div style="text-align: center; width: 25%; margin: auto;">
        <table>
          <tr>            
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnSelectSubParams" runat="server" OnClientClick="return getDataGrids();"
                OnClick="btnAddAccountConfigSet_Click" TabIndex="150" meta:resourcekey="btnAddAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnRemoveSubParams" runat="server" OnClientClick="return getConvertApprove();"
                OnClick="btnUpdateAccountConfigSet_Click" Visible="False" TabIndex="150" meta:resourcekey="btnUpdateAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTButton3" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="160" meta:resourcekey="MTbtnCancelResource1" />
            </td>
          </tr>
        </table>
      </div>
    </div>--%>
    <div id="leftColumn2" class="LeftColumn">
       <MT:MTTextBoxControl ID="MTtbSubParamId" AllowBlank="True" ReadOnly="true"
        LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsId"/>
       <MT:MTTextBoxControl ID="MTtbSubParamsDescription" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsDescriptionResource"/>
       <MT:MTTextBoxControl ID="MTtbSubParamsPo" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="tbSubParamsPoResource"/>
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpSubParamsStartDate"
        Label="Start date" LabelWidth="120" meta:resourcekey="dpSubParamsStartDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpSubParamsEndDate"
        Label="End date" LabelWidth="120" meta:resourcekey="dpSubParamsEndDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTInlineSearch ID="MTisCorpAccountId" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="isCorpAccountIdResource"/>
      <MT:MTTextBoxControl ID="MTtbGroupSubscriptionName" AllowBlank="True" 
        LabelWidth="120" runat="server" meta:resourcekey="tbGroupSubscriptionNameResource"/>
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
              <MT:MTButton ID="MTbtnUpdateAccountConfigSet" runat="server" OnClientClick="return getUpdateApprove();"
                OnClick="btnUpdateAccountConfigSet_Click" Visible="False" TabIndex="160" meta:resourcekey="btnUpdateAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnGoToUpdateAccountConfigSet" runat="server" 
                OnClick="btnGoToUpdateAccountConfigSet_Click" Visible="False" TabIndex="170" meta:resourcekey="btnGoToUpdateAccountConfigSetResource" />
            </td>
            <td class="x-panel-btn-td">
              <MT:MTButton ID="MTbtnCancel" runat="server" OnClick="btnCancel_Click" CausesValidation="False"
                TabIndex="180" meta:resourcekey="MTbtnCancelResource1" />
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
  <input id="HiddenSelectionCriteria" runat="server" type="hidden" />
  <input id="HiddenPropertiesToSet" runat="server" type="hidden" />  
  <input id="HiddenUDRCs" runat="server" type="hidden" />
  <%-- General--%>
  <script language="javascript" type="text/javascript">

  function getUpdateApprove()
  {                
      return confirm('<%=GetGlobalResourceObject("JSConsts", "TEXT_UPDATE_ACS_MESSAGE")%>');        
  }

    var GRID_HEIGHT = 300;
    var ACTIONS_COLUMN_HEIGHT = 40;
    var NAME_COLUMN_HEIGHT = 100;
    var isViewMode = <%=IsViewMode.ToString().ToLower()%>;

    var propertyValueRecord = Ext.data.Record.create([// creates a subclass of Ext.data.Record      
      { name: 'AccountView' },
      { name: 'Property' },
      { name: 'Value' },
      { name: 'CriterionId' }
    ]);

    function addPropertyValues(items, store) {
      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new propertyValueRecord({
          AccountView: items[i].AccountView,
          Property: items[i].Property,
          Value: items[i].Value,
          CriterionId: items[i].CriterionId          
        });
        store.add(myNewRecord);
      }
    }
    
    Ext.onReady(function () {
      selectionCriteriaGrid.render(window.Ext.get('PlaceHolderSelectionCriteria'));
//      poGrid.render(window.Ext.get('PlaceHolderProductOfferingsGrid'));     
    });

        function loadFromPostback(hidden, store, data, dataDetails) {
          var hiddenItems = window.Ext.get(hidden).dom;
          if (hiddenItems.value.length > 0)
            dataDetails = window.Ext.decode(hiddenItems.value);
          store.loadData(data);
        }

    window.onload = function () {
      var hiddenSelectionCriteria = window.Ext.get("<%=HiddenSelectionCriteria.ClientID %>").dom;
      if (hiddenSelectionCriteria.value.length > 0)
        selectionCriteriaData.selectionCriterion = window.Ext.decode(hiddenSelectionCriteria.value);
      addPropertyValues(selectionCriteriaData.selectionCriterion, selectionCriteriaStore);

//      var hiddenSelectionCriteria = window.Ext.get("<%=HiddenSelectionCriteria.ClientID %>").dom;
//      if (hiddenSelectionCriteria.value.length > 0)
//        selectionCriteriaData.selectionCriterion = window.Ext.decode(hiddenSelectionCriteria.value);
//      addPropertyValues(selectionCriteriaData.selectionCriterion, selectionCriteriaStore);

    };    

    function getDataGrids() {
      var result = getSelectionCriteria();
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

     // addItemToPIs(response.items);
    }
    
//    var ConditionSignData = new Ext.data.ArrayStore({
//                  id: 0,
//                  fields: ['value', 'sign'],
//                  data: [
//                          ['Equal', '='],
//                          ['NotEqual', '<>'],
//                          ['Greater', '>'],
//                          ['GreaterEqual', '>='],
//                          ['Less', '<'],
//                          ['LessEqual', '<='],
//                          //['Default', '<%=GetLocalResourceObject("DEFAULT_RULE")%>'],
//                        ]
//                });
var form_addPropertyValue = new Ext.form.FormPanel();
    var AddPropertyValueWindow = new Ext.Window();

    function AddPropertyValue(type, accountView, property, value, criterionId, mode) {

      if (AddPropertyValueWindow.rendered)
        return;

      form_addPropertyValue = new Ext.form.FormPanel();
      AddPropertyValueWindow = new Ext.Window();

      form_addPropertyValue = new Ext.FormPanel({
        baseCls: 'x-plain',
        labelWidth: 70,
        defaultType: 'textfield',

        items: [          
          {
            xtype: 'hidden',
            hideLabel: true,
            id: 'form_addPropertyValue_type',
            name: 'form_addPropertyValue_type',
            value: type
          },
          {
            xtype: 'hidden',
            hideLabel: true,
            id: 'form_addPropertyValue_mode',
            name: 'form_addPropertyValue_mode',
            value: mode
          },
          {
            xtype: 'hidden',
            hideLabel: true,
            id: 'form_addPropertyValue_CriterionId',
            name: 'form_addPropertyValue_CriterionId',
            value: criterionId
          },
        //////////
          {
            xtype: 'textfield',
            allowBlank: false,
            inputType: "text",
            fieldLabel: '<%=GetLocalResourceObject("ACCOUNTVIEW")%>',
            id: 'form_addPropertyValue_AccountView',
            name: 'form_addPropertyValue_AccountView',
            anchor: '100%',            
            tabIndex: 10,
            value: accountView
          },
          {
            xtype: 'textfield',
            allowBlank: false,
            inputType: "text",
            fieldLabel: '<%=GetLocalResourceObject("PROPERTY")%>',
            id: 'form_addPropertyValue_Property',
            name: 'form_addPropertyValue_Property',
            anchor: '100%',
            tabIndex: 20,
            value: property
          },
          {
            xtype: 'textfield',
            allowBlank: true,
            inputType: "text",
            fieldLabel: '<%=GetLocalResourceObject("VALUE")%>',
            id: 'form_addPropertyValue_Value',
            name: 'form_addPropertyValue_Value',
            anchor: '100%',
            value: 0,
            tabIndex: 30,
            value: value
          }]
      });

      var windowTitle = '';
      if (type == 'SelectionCriteria') 
        if(mode == 'new')
          windowTitle = '<%=GetLocalResourceObject("ADD_SELECTION_CRITERIA")%>';
        else
          windowTitle = '<%=GetLocalResourceObject("EDIT_SELECTION_CRITERIA")%>';
            
      AddPropertyValueWindow = new Ext.Window({
        title: windowTitle,
        width: 400,
        height: 250,
        minWidth: 100,
        minHeight: 100,
        layout: 'fit',
        plain: true,
        bodyStyle: 'padding:5px;',
        buttonAlign: 'center',
        items: form_addPropertyValue,
        closable: true,
        resizeable: true,
        maximizable: false,
        closeAction: 'close',

        buttons: [{
                    text: '<%=GetLocalResourceObject("TEXT_OK")%>',
                    handler: onOK_AddPropertyValue,
                    tabIndex: 40
                  },
                  {
                    text: '<%=GetLocalResourceObject("TEXT_CANCEL")%>',
                    handler: onCancel_AddPropertyValue,
                    tabIndex: 50
                  }]
      });

      AddPropertyValueWindow.show();
    }

    function onOK_AddPropertyValue() {

      var isValidForm = form_addPropertyValue.getForm().isValid();

      if (!(isValidForm == true))
        Ext.Msg.alert('Failed', 'Wrong input');
      else {

        var accountView = form_addPropertyValue.items.get('form_addPropertyValue_AccountView').getValue();
        var property = form_addPropertyValue.items.get('form_addPropertyValue_Property').getValue();
        var value = form_addPropertyValue.items.get('form_addPropertyValue_Value').getValue();
        var oldCriterionId = form_addPropertyValue.items.get('form_addPropertyValue_CriterionId').getValue();
        var type = form_addPropertyValue.items.get('form_addPropertyValue_type').getValue();
        var mode = form_addPropertyValue.items.get('form_addPropertyValue_mode').getValue();

        var newCriterionId = accountView + "-" + property;

        var foundOldCriterionId = selectionCriteriaStore.find('CriterionId', oldCriterionId);
        
        if (foundOldCriterionId > -1) //remove already existed item for update case
          {
            if (type == 'SelectionCriteria') 
              removeSelectionCriterion(oldCriterionId);            
          }

        var foundNewCriterionId = selectionCriteriaStore.find('CriterionId', newCriterionId);

        if (foundNewCriterionId == -1) {  //add new item          
          var newPropertyValueRecord = new propertyValueRecord({
            AccountView: accountView,
            Property: property,
            Value: value,
            CriterionId: newCriterionId
          });

          if (type == 'SelectionCriteria') {
            selectionCriteriaStore.add(newPropertyValueRecord);
          }

          AddPropertyValueWindow.destroy();
          AddPropertyValueWindow.rendered = false;
        }
      }
    }

    function onCancel_AddPropertyValue() {
      form_addPropertyValue.getForm().reset({});
      AddPropertyValueWindow.destroy();
      AddPropertyValueWindow.rendered = false;
    }

  </script>
  <%-- SelectionCriteria Grid--%>
  <script language="javascript" type="text/javascript">

    var selectionCriteriaData = { selectionCriteria: [] };

    var selectionCriteriaStore = new Ext.data.GroupingStore({
      root: 'selectionCriteria',
      fields: propertyValueRecord.fields,
      groupField: 'AccountView'
    });

    var selectionCriteriaToolBar = null;
    if (!isViewMode) {
      selectionCriteriaToolBar = new Ext.Toolbar([
        { iconCls: 'add', id: 'Add', text: '<%=GetLocalResourceObject("ADD_SELECTION_CRITERIA")%>', handler: onSelectionCriterionAdd }
        ]);
    }

    // create the Grid
    var textAccountView = '<%=GetLocalResourceObject("ACCOUNTVIEW")%>';
    var textProperty = '<%=GetLocalResourceObject("PROPERTY")%>';
    var textValue = '<%=GetLocalResourceObject("VALUE")%>';
    var textSelectionCriteriaActions = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textSelectionCriteriaGridTitle = '<%=GetLocalResourceObject("SELECTION_CRITERIA_GRID_TITLE")%>';

    var selectionCriteriaColumns = [
      { header: '', hidden: true, dataIndex: 'CriterionId' },
      { header: textAccountView, hidden: true, dataIndex: 'AccountView' },
      { header: textProperty, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Property' },
      { header: textValue, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Value' }
    ];

    if (!isViewMode)
      selectionCriteriaColumns.push({ header: textSelectionCriteriaActions, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: selectionCriteriaActionsRenderer });

    var selectionCriteriaGrid = new Ext.grid.EditorGridPanel({
      ds: selectionCriteriaStore,
      columns: selectionCriteriaColumns,
      tbar: selectionCriteriaToolBar,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textSelectionCriteriaGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "<%=GetLocalResourceObject("ITEMS")%>" : "<%=GetLocalResourceObject("ITEM")%>"]})'
      })
    });

    function selectionCriteriaActionsRenderer(value, meta, record) {     
      var str = String.format(
        "<a style='cursor:hand;' id='deleteSelectionCriterion_{0}' title='{1}' href='JavaScript:removeSelectionCriterion(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data.CriterionId, '<%=GetLocalResourceObject("REMOVE_SELECTIONCRITERION")%>');
      str += String.format(
        "<a style='cursor:hand;' id='updateSelectionCriterion_{0}' title='{4}' href='JavaScript:editSelectionCriterion(\"{0}\",\"{1}\",\"{2}\",\"{3}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",
        record.data.AccountView, record.data.Property, record.data.Value, record.data.CriterionId, '<%=GetLocalResourceObject("EDIT_SELECTIONCRITERION")%>');
      return str;
    }

    function onSelectionCriterionAdd() {
      AddPropertyValue('SelectionCriteria', '', '', '', '', 'new');
    }     

    function removeSelectionCriterion(accId) {
      var idx = selectionCriteriaStore.find('CriterionId', accId);
      selectionCriteriaStore.remove(selectionCriteriaStore.getAt(idx));
    }

    function editSelectionCriterion(accountView, property, value, criterionId) {
      AddPropertyValue('SelectionCriteria', accountView, property, value, criterionId, 'edit')
    }

    function getSelectionCriteria() {
      var records = selectionCriteriaStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS, //todo
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      selectionCriteriaStore.selectionCriteria.length = 0;
      for (var i = 0; i < records.length; i++) {
        var record = {
          'AccountView': records[i].data.AccountView,
          'Property': records[i].data.Property,
          'Value': records[i].data.Value,
          'CriterionId': records[i].data.CriterionId
        };
        selectionCriteriaData.selectionCriteria.push(record);        
      }

      window.Ext.get("<%=HiddenSelectionCriteria.ClientID %>").dom.value = selectionCriteriaData.selectionCriteria.length > 0 ? window.Ext.encode(selectionCriteriaData.selectionCriteria) : "";

      return true;
    }
  </script>
  
  <%-- PropertyesToSet Grid-- %>
  <script language="javascript" type="text/javascript">

    var selectionCriteriaData = { selectionCriteria: [] };

    var selectionCriteriaStore = new Ext.data.GroupingStore({
      root: 'selectionCriteria',
      fields: propertyValueRecord.fields,
      groupField: 'AccountView'
    });

    var selectionCriteriaToolBar = null;
    if (!isViewMode) {
      selectionCriteriaToolBar = new Ext.Toolbar([
        { iconCls: 'add', id: 'Add', text: '<%=GetLocalResourceObject("ADD_SELECTION_CRITERIA")%>', handler: onSelectionCriterionAdd }
        ]);
    }

    // create the Grid
    var textAccountView = '<%=GetLocalResourceObject("ACCOUNTVIEW")%>';
    var textProperty = '<%=GetLocalResourceObject("PROPERTY")%>';
    var textValue = '<%=GetLocalResourceObject("VALUE")%>';
    var textSelectionCriteriaActions = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
    var textSelectionCriteriaGridTitle = '<%=GetLocalResourceObject("SELECTION_CRITERIA_GRID_TITLE")%>';

    var selectionCriteriaColumns = [
      { header: '', hidden: true, dataIndex: 'CriterionId' },
      { header: textAccountView, hidden: true, dataIndex: 'AccountView' },
      { header: textProperty, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Property' },
      { header: textValue, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Value' }
    ];

    if (!isViewMode)
      selectionCriteriaColumns.push({ header: textSelectionCriteriaActions, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: selectionCriteriaActionsRenderer });

    var selectionCriteriaGrid = new Ext.grid.EditorGridPanel({
      ds: selectionCriteriaStore,
      columns: selectionCriteriaColumns,
      tbar: selectionCriteriaToolBar,
      stripeRows: true,
      height: GRID_HEIGHT,
      width: 345,
      iconCls: 'icon-grid',
      frame: true,
      title: textSelectionCriteriaGridTitle,
      view: new Ext.grid.GroupingView({
        forceFit: true,
        // custom grouping text template to display the number of items per group
        groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "<%=GetLocalResourceObject("ITEMS")%>" : "<%=GetLocalResourceObject("ITEM")%>"]})'
      })
    });

    function selectionCriteriaActionsRenderer(value, meta, record) {
      var str = String.format(
        "<a style='cursor:hand;' id='deleteSelectionCriterion_{0}' title='{1}' href='JavaScript:removeSelectionCriterion(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
        record.data.CriterionId, '<%=GetLocalResourceObject("REMOVE_SELECTIONCRITERION")%>');
      str += String.format(
        "<a style='cursor:hand;' id='updateSelectionCriterion_{0}' title='{4}' href='JavaScript:editSelectionCriterion(\"{0}\",\"{1}\",\"{2}\",\"{3}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",
        record.data.AccountView, record.data.Property, record.data.Value, record.data.CriterionId, '<%=GetLocalResourceObject("EDIT_SELECTIONCRITERION")%>');
      return str;
    }

    function onSelectionCriterionAdd() {
      AddPropertyValue('SelectionCriteria', '', '', '', '');
    }

    function removeSelectionCriterion(accId) {
      var idx = selectionCriteriaStore.find('CriterionId', accId);
      selectionCriteriaStore.remove(selectionCriteriaStore.getAt(idx));
    }

    function editSelectionCriterion(accountView, property, value, criterionId) {
      AddPropertyValue('SelectionCriteria', accountView, property, value, criterionId)
    }

    function getSelectionCriteria() {
      var records = selectionCriteriaStore.data.items;
      if (records.length == 0) {
        window.Ext.Msg.show({
          title: window.TEXT_ERROR,
          msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS, //todo
          buttons: window.Ext.Msg.OK,
          icon: window.Ext.MessageBox.ERROR
        });
        return false;
      }

      selectionCriteriaStore.selectionCriteria.length = 0;
      for (var i = 0; i < records.length; i++) {
        var record = {
          'AccountView': records[i].data.AccountView,
          'Property': records[i].data.Property,
          'Value': records[i].data.Value,
          'CriterionId': records[i].data.CriterionId
        };
        selectionCriteriaData.selectionCriteria.push(record);
      }

      window.Ext.get("<%=HiddenSelectionCriteria.ClientID %>").dom.value = selectionCriteriaData.selectionCriteria.length > 0 ? window.Ext.encode(selectionCriteriaData.selectionCriteria) : "";

      return true;
    }
  </script>

  <%--UDRC PI Grid--%>
  <%--<script language="javascript" type="text/javascript">
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

  </script>--%>
  <%-- UDRC Grid--%>
  <%--<script language="javascript" type="text/javascript">
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
  </script>--%>
  
</asp:Content>
