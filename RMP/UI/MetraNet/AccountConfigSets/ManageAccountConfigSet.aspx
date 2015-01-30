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
    <div>
    <MT:MTTextBoxControl ID="MTtbAcsDescription" AllowBlank="True" ControlWidth="560"
        LabelWidth="120" MaxLength="200" runat="server" meta:resourcekey="tbAcsDescriptionResource"/>
    </div>
    <div>
    <div id="leftColumn1" class="LeftColumn">
      <MT:MTNumberField ID="MTtbRank" AllowBlank="True" LabelWidth="120" runat="server"
       meta:resourcekey="tbRankResource" Text="1" MaxLength="15" />
      <MT:MTCheckBoxControl ID="MTcbAcsEnabled" runat="server" LabelWidth="120" ReadOnly="False"
        meta:resourcekey="cbAcsEnabledResource"/>
    </div>
    <div id="rightColumn1" class="RightColumn">      
      <MT:MTDatePicker AllowBlank="False" Enabled="True" HideLabel="False" ID="MTdpStartDate"
        LabelWidth="120" meta:resourcekey="dpStartDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
      <MT:MTDatePicker AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpEndDate"
        LabelWidth="120" meta:resourcekey="dpEndDateResource" ReadOnly="False"
        runat="server"></MT:MTDatePicker>
    </div>
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelCriteria" runat="server" Collapsible="True" Collapsed="False"
    meta:resourcekey="panelCriteriaResource">
    <div id="PlaceHolderSelectionCriteria" class="LeftColumn">
    </div>
    <div id="PlaceHolderPropertiesToSet" class="RightColumn">
    </div>
  </MT:MTPanel>
  <MT:MTPanel ID="MTPanelManageSubscriptionParameters" runat="server" Collapsible="True"
    meta:resourcekey="panelManageSubscriptionParametersResource">              
      <%--<MT:MTTextBoxControl ID="MTtbSubParamId" AllowBlank="True" ReadOnly="True"
          LabelWidth="120" runat="server" Text = "-" meta:resourcekey="tbSubParamsId"/>--%>      
    <div id = "PlaceHolderSubParamsToolBar" class="LeftColumn">                 
    </div>      
    </MT:MTPanel>
  <MT:MTPanel ID="MTPanelSubscriptionParameters" runat="server" Collapsible="True"
    Collapsed="True" meta:resourcekey="panelSubscriptionParametersResource">    
    <div id="leftColumn2" class="LeftColumn">      
       <MT:MTTextBoxControl ID="MTtbSubParamsDescription" AllowBlank="True" ReadOnly="True" 
        LabelWidth="135" runat="server" Text = "-" meta:resourcekey="tbSubParamsDescriptionResource"/>
       <MT:MTTextBoxControl ID="MTtbSubParamsPo" AllowBlank="True" ReadOnly="True"
        LabelWidth="135" runat="server" Text = "-" meta:resourcekey="tbSubParamsPoResource"/>
      <MT:MTTextBoxControl AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpSubParamsStartDate" 
        LabelWidth="135" Text = "-" meta:resourcekey="dpSubParamsStartDateResource" ReadOnly="True"
        runat="server"></MT:MTTextBoxControl>
      <MT:MTTextBoxControl AllowBlank="True" Enabled="True" HideLabel="False" ID="MTdpSubParamsEndDate"
        LabelWidth="135" Text = "-" meta:resourcekey="dpSubParamsEndDateResource" ReadOnly="True"
        runat="server"></MT:MTTextBoxControl>
      <MT:MTTextBoxControl ID="MTisCorpAccountId" AllowBlank="True" ReadOnly="True"
        LabelWidth="135" runat="server" Text = "-" meta:resourcekey="isCorpAccountIdResource"/>
      <MT:MTTextBoxControl ID="MTtbGroupSubscriptionName" AllowBlank="True" ReadOnly="True"
        LabelWidth="135" runat="server" Text = "-" meta:resourcekey="tbGroupSubscriptionNameResource"/>
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
  <input id="MTtbSubParamId" runat="server" type="hidden" />
  <input id="HiddenSelectionCriteria" runat="server" type="hidden" />
  <input id="HiddenPropertiesToSet" runat="server" type="hidden" />  
  <input id="HiddenUDRCs" runat="server" type="hidden" />
  <input id="HiddenAccountViewPropertyData" runat="server" type="hidden" />
  <input id="HiddenAccountViews" runat="server" type="hidden" />
  <input id="HiddenPis" runat="server" type="hidden" />
    <%-- General--%>
    <script language="javascript" type="text/javascript">

    function getUpdateApprove()
    {  
        var confirmResult = true;
//      top.Ext.MessageBox.show({
//          title: '<%=GetGlobalResourceObject("JSConsts", "TEXT_UPDATE_QUESTION")%>',
//          msg: String.format('<%=GetGlobalResourceObject("JSConsts", "TEXT_UPDATE_ACS_MESSAGE")%>', entityId),
//          buttons: window.Ext.MessageBox.OKCANCEL,
//          fn: function(btn) {
//            if (btn == 'ok') {
//              confirmResult = true;
//            }
//          },
//          animEl: 'elId',
//          icon: window.Ext.MessageBox.QUESTION
//        });
//      
//        var dlg = top.Ext.MessageBox.getDialog();
//	      var buttons = dlg.buttons;
//	      for (i = 0; i < buttons.length; i++) {
//        buttons[i].addClass('custom-class');
//       }

//        if(confirmResult)
           getDataGrids();

        return confirmResult;
    }

      var GRID_HEIGHT = 280;
      var ACTIONS_COLUMN_HEIGHT = 40;
      var NAME_COLUMN_HEIGHT = 100;
      var isViewMode = <%=IsViewMode.ToString().ToLower()%>;

      Ext.onReady(function () {
        selectionCriteriaGrid.render(window.Ext.get('PlaceHolderSelectionCriteria'));
        propertiesToSetGrid.render(window.Ext.get('PlaceHolderPropertiesToSet'));  
        if(subParamsToolBar!= null)
          subParamsToolBar.render(window.Ext.get('PlaceHolderSubParamsToolBar'));   
        if(udrcStore.getCount()>0)
          udrcGrid.render(window.Ext.get('PlaceHolderUDRCGrid'));          
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
          selectionCriteriaData.propertyValue = window.Ext.decode(hiddenSelectionCriteria.value);
        addPropertyValues(selectionCriteriaData.propertyValue, selectionCriteriaStore);
      
        var hiddenPropertiesToSet = window.Ext.get("<%=HiddenPropertiesToSet.ClientID %>").dom;
        if (hiddenPropertiesToSet.value.length > 0)
          propertiesToSetData.propertyValue = window.Ext.decode(hiddenPropertiesToSet.value);
        addPropertyValues(propertiesToSetData.propertyValue, propertiesToSetStore);

        var hiddenAccountViewsData = window.Ext.get("<%=HiddenAccountViews.ClientID %>").dom;
        if (hiddenAccountViewsData.value.length > 0)
          accountViewData.accountView = window.Ext.decode(hiddenAccountViewsData.value);      
        addAccountView(accountViewData.accountView, accountViewStore);

        var hiddenAccountViewPropertyData = window.Ext.get("<%=HiddenAccountViewPropertyData.ClientID %>").dom;
        if (hiddenAccountViewPropertyData.value.length > 0)
          accountViewPropertyMetadataData.accountViewPropertyMetadata = window.Ext.decode(hiddenAccountViewPropertyData.value);      
        addAccountViewPropertyMetadata(accountViewPropertyMetadataData.accountViewPropertyMetadata, accountViewPropertyMetadataStore);

        var hiddenUDRCs = window.Ext.get("<%=HiddenUDRCs.ClientID %>").dom;
        if (hiddenUDRCs.value.length > 0)
          udrcData.UDRCs = window.Ext.decode(hiddenUDRCs.value);        
        addUDRCs(udrcData.UDRCs);
      };    

      function getDataGrids() {
        var result = getSelectionCriteria() && getPropertiesToSet();
      
        return result;
      }
    </script>
    <%-- PropertyValue--%>
    <script language="javascript" type="text/javascript">

    var accountViewRecord = Ext.data.Record.create([
      { name: 'AccountView' }
    ]);

    var accountViewData = { accountView: [] };

    var accountViewStore = new Ext.data.ArrayStore({
      root: 'accountView',
      fields: accountViewRecord.fields
    });

    function addAccountView(items, store) {
      if (items == null || store == null)
        return;

      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new accountViewRecord({
          AccountView: items[i].AccountView            
        });
        store.add(myNewRecord);
      }
    }

    var accountViewPropertyMetadataRecord = Ext.data.Record.create([
      { name: 'AccountView' },
      { name: 'PropertyName' },
      { name: 'TypeName' },
      { name: 'MaxLength' },
      { name: 'Id' }
    ]);

    var accountViewPropertyMetadataData = { accountViewPropertyMetadata: [] };

    var accountViewPropertyMetadataStore = new Ext.data.ArrayStore({
      root: 'accountViewPropertyMetadata',
      fields: accountViewPropertyMetadataRecord.fields
    });

    function addAccountViewPropertyMetadata(items, store) {
      if (items == null || store == null)
        return;

      for (var i = 0; i < items.length; i++) {
        var myNewRecord = new accountViewPropertyMetadataRecord({
          AccountView: items[i].AccountView,
          PropertyName: items[i].PropertyName,
          TypeName: items[i].TypeName,
          MaxLength: items[i].MaxLength,
          Id: items[i].Id
        });
        store.add(myNewRecord);
      }
    }

    var propertyValueRecord = Ext.data.Record.create([
      { name: 'AccountView' },
      { name: 'Property' },
      { name: 'Value' },
      { name: 'CriterionId' }
    ]);

    function addPropertyValues(items, store) {
      if (items == null || store == null)
        return;

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
          xtype: 'combo',
          fieldLabel: '<%=GetLocalResourceObject("ACCOUNTVIEW")%>',
          id: 'form_addPropertyValue_AccountView',
          name: 'form_addPropertyValue_AccountView',
          anchor: '100%',
          mode: 'local',
          allowBlank: false,
          autoSelect: true,
          forceSelection: true,
          store: accountViewStore,
          displayField: 'AccountView',
          valueField: 'AccountView',
          value: accountView,
          tabIndex: 10,
          listeners: {
            select: {
              fn: function (combo, value) {
                var comboProperty = Ext.getCmp('form_addPropertyValue_Property');
                comboProperty.clearValue();
                comboProperty.store.filter('AccountView', combo.getValue());
                lastOptions = comboProperty.store.lastOptions;                               
              }
            }
          }
        },
          {
            xtype: 'combo',
            fieldLabel: '<%=GetLocalResourceObject("PROPERTY")%>',
            id: 'form_addPropertyValue_Property',
            name: 'form_addPropertyValue_Property',
            anchor: '100%',
            mode: 'local',
            allowBlank: false,
            autoSelect: true,
            forceSelection: true,
            store: accountViewPropertyMetadataStore,
            displayField: 'PropertyName',
            valueField: 'PropertyName',
            value: property,
            tabIndex: 20,
            listeners: {
              select: {
                fn: function (comboPropertyValue, value) {
                  var textfieldValue = Ext.getCmp('form_addPropertyValue_Value');
                  var comboAccountView = Ext.getCmp('form_addPropertyValue_AccountView');
                  var accountViewValue = comboAccountView.getValue();
                  var propertyNameValue = comboPropertyValue.getValue();

                  var idx = accountViewPropertyMetadataStore.find('Id', accountViewValue + '-' + propertyNameValue);
                  if (idx > -1) {
                    var accountViewMetaDataItem = accountViewPropertyMetadataStore.getAt(idx);
                    if (accountViewMetaDataItem.get('MaxLength') > 0 )
                      textfieldValue.maxLength = accountViewMetaDataItem.get('MaxLength');
                    else
                      textfieldValue.maxLength = Number.MAX_VALUE;                    
                  }
                  else
                    textfieldValue.maxLength = Number.MAX_VALUE;
                }
              }
            }
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
          windowTitle = '<%=GetLocalResourceObject("ADD_SELECTION_CRITERION")%>';
        else
          windowTitle = '<%=GetLocalResourceObject("EDIT_SELECTIONCRITERION")%>';

      if (type == 'PropertyToSet') 
        if(mode == 'new')
          windowTitle = '<%=GetLocalResourceObject("ADD_PROPERTY_TO_SET")%>';
        else
          windowTitle = '<%=GetLocalResourceObject("EDIT_PROPERTY_TO_SET")%>'; 
               
      AddPropertyValueWindow = new Ext.Window({
        title: windowTitle,
        width: 400,
        height: 150,
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
        Ext.Msg.alert('<%=GetLocalResourceObject("TEXT_FAILED")%>', '<%=GetLocalResourceObject("TEXT_WRONG_INPUT")%>');
      else {

        var accountView = form_addPropertyValue.items.get('form_addPropertyValue_AccountView').getValue();
        var property = form_addPropertyValue.items.get('form_addPropertyValue_Property').getValue();
        var value = form_addPropertyValue.items.get('form_addPropertyValue_Value').getValue();
        var oldCriterionId = form_addPropertyValue.items.get('form_addPropertyValue_CriterionId').getValue();
        var type = form_addPropertyValue.items.get('form_addPropertyValue_type').getValue();
        var mode = form_addPropertyValue.items.get('form_addPropertyValue_mode').getValue();

        var newCriterionId = accountView + "-" + property;

        var foundOldCriterionId = -1;
        if (type == 'SelectionCriteria')
          foundOldCriterionId = selectionCriteriaStore.find('CriterionId', oldCriterionId);

        if (type == 'PropertyToSet')
          foundOldCriterionId = propertiesToSetStore.find('CriterionId', oldCriterionId);
        
        if (foundOldCriterionId > -1) //remove already existed item for update case
          {
            if (type == 'SelectionCriteria')
              removeSelectionCriterion(oldCriterionId);

            if (type == 'PropertyToSet') 
              removePropertyToSet(oldCriterionId);                     
          }

        var foundNewCriterionId = -1;
        if (type == 'SelectionCriteria')
          foundNewCriterionId = selectionCriteriaStore.find('CriterionId', oldCriterionId);

        if (type == 'PropertyToSet')
          foundNewCriterionId = propertiesToSetStore.find('CriterionId', oldCriterionId);

        if (foundNewCriterionId == -1) {  //add new item          
          var newPropertyValueRecord = new propertyValueRecord({
            AccountView: accountView,
            Property: property,
            Value: value,
            CriterionId: newCriterionId
          });

          if (type == 'SelectionCriteria') {
            selectionCriteriaStore.add(newPropertyValueRecord);
            //selectionCriteriaStore.sort('AccountView');
          }

          if (type == 'PropertyToSet') {
            propertiesToSetStore.add(newPropertyValueRecord);
            //propertiesToSetStore.sort('AccountView');
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

      var selectionCriteriaData = { propertyValue: [] };

      var selectionCriteriaStore = new Ext.data.GroupingStore({
        root: 'propertyValue',
        fields: propertyValueRecord.fields,
        groupField: 'AccountView',
        sortInfo: {
          field: 'AccountView',
          direction: 'ASC' 
        }
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
        enableHdMenu : false,
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
//        if (records.length == 0) {
//          window.Ext.Msg.show({
//            title: window.TEXT_ERROR,
//            msg: window.TEXT_SELECT_GRPSUBMEM_ACCOUNTS, //todo
//            buttons: window.Ext.Msg.OK,
//            icon: window.Ext.MessageBox.ERROR
//          });
//          return false;
//        }

        selectionCriteriaData.propertyValue.length = 0;
        for (var i = 0; i < records.length; i++) {
          var record = {
            'AccountView': records[i].data.AccountView,
            'Property': records[i].data.Property,
            'Value': records[i].data.Value,
            'CriterionId': records[i].data.CriterionId
          };
          selectionCriteriaData.propertyValue.push(record);        
        }

        window.Ext.get("<%=HiddenSelectionCriteria.ClientID %>").dom.value = selectionCriteriaData.propertyValue.length > 0 ? window.Ext.encode(selectionCriteriaData.propertyValue) : "";

        return true;
      }
    </script>  
    <%-- PropertiesToSet Grid--%>
    <script language="javascript" type="text/javascript">

      var propertiesToSetData = { propertyValue: [] };

      var propertiesToSetStore = new Ext.data.GroupingStore({
        root: 'propertyValue',
        fields: propertyValueRecord.fields,
        groupField: 'AccountView',
        sortInfo: {
          field: 'AccountView',
          direction: 'ASC' 
        }
      });

      var propertiesToSetToolBar = null;
      if (!isViewMode) {
        propertiesToSetToolBar = new Ext.Toolbar([
          { iconCls: 'add', id: 'Add', text: '<%=GetLocalResourceObject("ADD_PROPERTY_TO_SET")%>', handler: onPropertiesToSetAdd }
          ]);
      }

      // create the Grid
      var textAccountView = '<%=GetLocalResourceObject("ACCOUNTVIEW")%>';
      var textProperty = '<%=GetLocalResourceObject("PROPERTY")%>';
      var textValue = '<%=GetLocalResourceObject("VALUE")%>';
      var textPropertiesToSetActions = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
      var textPropertiesToSetGridTitle = '<%=GetLocalResourceObject("PROPERTY_TO_SET_GRID_TITLE")%>';

      var propertiesToSetColumns = [
        { header: '', hidden: true, dataIndex: 'CriterionId' },
        { header: textAccountView, hidden: true, dataIndex: 'AccountView' },
        { header: textProperty, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Property' },
        { header: textValue, width: NAME_COLUMN_HEIGHT, sortable: true, dataIndex: 'Value' }
      ];

      if (!isViewMode)
        propertiesToSetColumns.push({ header: textPropertiesToSetActions, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: propertiesToSetActionsRenderer });

      var propertiesToSetGrid = new Ext.grid.EditorGridPanel({
        ds: propertiesToSetStore,
        columns: propertiesToSetColumns,        
        enableHdMenu : false,
        tbar: propertiesToSetToolBar,
        stripeRows: true,
        height: GRID_HEIGHT,
        width: 345,
        iconCls: 'icon-grid',
        frame: true,
        title: textPropertiesToSetGridTitle,
        view: new Ext.grid.GroupingView({
          forceFit: true,
          // custom grouping text template to display the number of items per group
          groupTextTpl: '{text} ({[values.rs.length]} {[values.rs.length > 1 ? "<%=GetLocalResourceObject("ITEMS")%>" : "<%=GetLocalResourceObject("ITEM")%>"]})'
        })
      });

      function propertiesToSetActionsRenderer(value, meta, record) {     
        var str = String.format(
          "<a style='cursor:hand;' id='deletePropertyToSet_{0}' title='{1}' href='JavaScript:removePropertyToSet(\"{0}\");'><img src='/Res/Images/icons/cross.png' alt='{1}' /></a>",
          record.data.CriterionId, '<%=GetLocalResourceObject("REMOVE_PROPERTY_TO_SET")%>');
        str += String.format(
          "<a style='cursor:hand;' id='updatePropertyToSet_{0}' title='{4}' href='JavaScript:editPropertyToSet(\"{0}\",\"{1}\",\"{2}\",\"{3}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",
          record.data.AccountView, record.data.Property, record.data.Value, record.data.CriterionId, '<%=GetLocalResourceObject("EDIT_PROPERTY_TO_SET")%>');
        return str;
      }

      function onPropertiesToSetAdd() {
        AddPropertyValue('PropertyToSet', '', '', '', '', 'new');
      }

      function removePropertyToSet(accId) {
        var idx = propertiesToSetStore.find('CriterionId', accId);
        propertiesToSetStore.remove(propertiesToSetStore.getAt(idx));
      }

      function editPropertyToSet(accountView, property, value, criterionId) {
        AddPropertyValue('PropertyToSet', accountView, property, value, criterionId, 'edit')
      }

      function getPropertiesToSet() {
        var records = propertiesToSetStore.data.items;

        propertiesToSetData.propertyValue.length = 0;
        for (var i = 0; i < records.length; i++) {
          var record = {
            'AccountView': records[i].data.AccountView,
            'Property': records[i].data.Property,
            'Value': records[i].data.Value,
            'CriterionId': records[i].data.CriterionId
          };
          propertiesToSetData.propertyValue.push(record);        
        }

        window.Ext.get("<%=HiddenPropertiesToSet.ClientID %>").dom.value = propertiesToSetData.propertyValue.length > 0 ? window.Ext.encode(propertiesToSetData.propertyValue) : "";

        return true;
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
      var textPoId = '<%=GetLocalResourceObject("POID")%>';
      var textPiId = '<%=GetLocalResourceObject("PIID")%>';
      var textValue = '<%=GetLocalResourceObject("TEXT_VALUE")%>';
      var textStartDate = '<%=GetLocalResourceObject("TEXT_START_DATE")%>';
      var textEndDate = '<%=GetLocalResourceObject("TEXT_END_DATE")%>';
      var textUDRCAction = ''; //'<%=GetLocalResourceObject("ACTIONS")%>';
      var textUDRCGridTitle = '<%=GetLocalResourceObject("UDRC_GRID_TITLE")%>';

      var udrcColumns = [
        { hidden: true, header: ' ', dataIndex: 'PriceableItemName' },
        { header: textValue, width: 95, sortable: true, dataIndex: 'Value' },
        { header: textStartDate, width: 95, sortable: true, dataIndex: 'StartDate' },
        { header: textEndDate, width: 95, sortable: true, dataIndex: 'EndDate' }
      ];
      //if (!isViewMode)
      //  udrcColumns.push({ header: textUDRCAction, width: ACTIONS_COLUMN_HEIGHT, sortable: false, dataIndex: '', renderer: UdrcActionsRenderer });

      var udrcGrid = new Ext.grid.GridPanel({
        ds: udrcStore,
        columns: udrcColumns,
        enableHdMenu: false,
        stripeRows: true,
        height: GRID_HEIGHT-50,
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
    </script>
    <%-- Subscription Parameters--%>
  <script language="javascript" type="text/javascript">

    var subParamsToolBar = isViewMode ? null : new Ext.Toolbar([
    { iconCls: 'add', id: 'AddSubParams', text: '<%=GetLocalResourceObject("btnSelectSubParamsResource.Text")%>', handler: selectSubParams },
    { iconCls: 'delete', id: 'RemoveSubParams', text: '<%=GetLocalResourceObject("btnRemoveSubParamsResource.Text")%>', handler: removeSubParams }
    ]);

    function selectSubParams() {
      ShowSubParamsSelector('addSubParamsCallback', 'Frame');
    }

    function removeSubParams() {
      var ids = '-';
      loadEmptySubParamsToControls();
    }

    function ReceiveServerData(value) {
      if (typeof value !== 'string' || value === '') {
        return;
      }
      var response = JSON.parse(value);
      if (response.result !== 'ok') {
        window.Ext.UI.SystemError(response.errorMessage);
      }
      loadSubParamsToControls(response.items);
    }

    function loadEmptySubParamsToControls() {

      window.Ext.get("<%=MTtbSubParamId.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTtbSubParamsDescription.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTtbSubParamsPo.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTdpSubParamsStartDate.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTdpSubParamsEndDate.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTisCorpAccountId.ClientID %>").dom.value = '-';
      window.Ext.get("<%=MTtbGroupSubscriptionName.ClientID %>").dom.value = '-';

      udrcStore.removeAll();      
    }

    function loadSubParamsToControls(subParams) {
      if (subParams == null)
        return;

      window.Ext.get("<%=MTtbSubParamsDescription.ClientID %>").dom.value = subParams.Description;
      window.Ext.get("<%=MTtbSubParamsPo.ClientID %>").dom.value = subParams.ProductOfferingId;
      window.Ext.get("<%=MTdpSubParamsStartDate.ClientID %>").dom.value = subParams.StartDate;
      window.Ext.get("<%=MTdpSubParamsEndDate.ClientID %>").dom.value = subParams.EndDate;
      window.Ext.get("<%=MTisCorpAccountId.ClientID %>").dom.value = subParams.CorporateAccountId;
      window.Ext.get("<%=MTtbGroupSubscriptionName.ClientID %>").dom.value = subParams.GroupSubscriptionName;

      udrcStore.removeAll();      

      if (subParams.UDRC != null) {        
        if (subParams.UDRC.length > 0)
          udrcData.UDRCs = window.Ext.decode(subParams.UDRC);
        addUDRCs(udrcData.UDRCs);

        udrcGrid.render(window.Ext.get('PlaceHolderUDRCGrid'));
      }
      
    }; 
    
    function ShowSubParamsSelector(functionName, target) {
      if (window.subParamsSelectorWin2 == null || window.subParamsSelectorWin2 === undefined ||
        target != window.lastTarget2 || functionName != window.lastFunctionName2) {
        window.subParamsSelectorWin2 = new top.Ext.Window({
          title: '<%=GetLocalResourceObject("SELECT_SUBPARAMS")%>',
          width: 800,
          height: 600,
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
          html: '<iframe id="subParamsSelectorWin2" src="/MetraNet/AccountConfigSets/AccountConfigSetSubscriptionParamsList.aspx?t=' + target + '&f=' + functionName + '" width="100%" height="100%" frameborder="0" scrolling="no"/>'
        });
      }
      if (window.subParamsSelectorWin2 != null) {
        window.subParamsSelectorWin2.hide();
      }
      window.lastTarget2 = target;
      window.lastFunctionName2 = functionName;
      window.subParamsSelectorWin2.show();
      window.subParamsSelectorWin2.on('close', closeFrame);
    }

    function addSubParamsCallback(ids) {
      window.Ext.get("<%=MTtbSubParamId.ClientID %>").dom.value = ids;
      if (ids != '' && ids != null)
        window.CallServer(JSON.stringify({ subParamsId: ids }));
      window.subParamsSelectorWin2.hide();
      window.subParamsSelectorWin2.close();
    }

    function closeFrame() {
      window.getFrameMetraNet().Ext.getDom("subParamsSelectorWin2").contentWindow = null;
      window.getFrameMetraNet().frames["subParamsSelectorWin2"] = null;
      window.subParamsSelectorWin2 = null;
    }
  </script>
</asp:Content>
