<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master" AutoEventWireup="true" CodeFile="IntervalStatisticsParameters.aspx.cs" Inherits="IntervalStatisticsParameters" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <MT:MTTitle ID="MTTitle1" Text="Interval Statistics Parameters" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

    <MT:MTPanel ID="MTPanel1" runat="server" Text="Interval Statistics Parameters" meta:resourcekey="MTPanel1">

        <div id="leftColumn1" class="LeftColumn">
          
          <MT:MTDropDown ID="ddBillingCycle" runat="server" AllowBlank="true" Label="Billing Cycle" meta:resourcekey="ddBillingCycle"
            TabIndex="100" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{ select: onBillingCycleChange }"
            ReadOnly="False">
          </MT:MTDropDown>
          
          <div id="SectionIntervalId" style="display: block;">
              <MT:MTDropDown ID="ddIntervalId" runat="server" AllowBlank="true" Label="Billing Interval" meta:resourcekey="ddIntervalId"
                TabIndex="100" ControlWidth="400" ListWidth="400" HideLabel="False" LabelSeparator=":" Listeners="{ select: onIntervalIdChange }"
                ReadOnly="False" Enabled="false">
              </MT:MTDropDown>
              <input id="txtIntervalId" runat="server" type="hidden" />
          </div>
          
          <div id="SectionBillGroupId" style="display: block;">
              <MT:MTDropDown ID="ddBillGroupId" runat="server" AllowBlank="true" Label="Billing Group" meta:resourcekey="ddBillGroupId"
                TabIndex="101" ControlWidth="400" ListWidth="400" HideLabel="False" LabelSeparator=":" Listeners="{ select: onBillGroupIdChange }"
                ReadOnly="False" Enabled="false">
              </MT:MTDropDown>
              <input id="txtBillGroupId" runat="server" type="hidden" />
          </div>

        </div>

        <div id="rightColumn1"  class="RightColumn">
        </div>

    </MT:MTPanel>

    <!-- BUTTONS -->
    <div class="x-panel-btns-ct">
        <div style="width:725px" class="x-panel-btns x-panel-btns-center">   
            <center>
                <table cellspacing="0">
                    <tr>
                        <td  class="x-panel-btn-td">
                            <MT:MTButton ID="btnOK" runat="server" Width="50px" Text="<%$Resources:Resource,TEXT_OK%>" OnClick="btnOK_Click" TabIndex="390" Enabled="false" />
                        </td>
                        <td  class="x-panel-btn-td">
                            <MT:MTButton ID="btnCancel" runat="server" Width="50px" Text="<%$Resources:Resource,TEXT_CANCEL%>" CausesValidation="False" OnClick="btnCancel_Click" TabIndex="400" />
                        </td>
                    </tr>
                </table> 
            </center>      
        </div>
    </div>
    
    <!-- This JS code should remain at the end, so that InitializeGlobalVars is called after all the other ExtJS code has run -->
    <script language="javascript" type="text/javascript">
        var ddBillingCycle;
        var ddIntervalId;
        var ddBillGroupId;
        var btnOk;
        var btnOkDiv;
        var pnlMTPanel1El;

        var txtIntervalId;
        var txtBillGroupId;

        function InitializeGlobalVars() {
            ddBillingCycle = Ext.getCmp('<%=ddBillingCycle.ClientID%>');
            ddIntervalId = Ext.getCmp('<%=ddIntervalId.ClientID%>');
            ddBillGroupId = Ext.getCmp('<%=ddBillGroupId.ClientID%>');

            txtIntervalId = document.getElementById('<%=txtIntervalId.ClientID%>');
            txtBillGroupId = document.getElementById('<%=txtBillGroupId.ClientID%>');

            btnOk = Ext.getCmp('<%=btnOK.ClientID%>');
            btnOk.disable();

            //pnlMTPanel1El = Ext.getCmp('<%=MTPanel1.ClientID%>').getEl();
            pnlMTPanel1El = Ext.get('formPanel_ctl00_ContentPlaceHolder1_MTPanel1');

            // Show a spinner while loading values
            Ext.Ajax.on('beforerequest', onWaitForAjaxRequest, this);
            Ext.Ajax.on('requestcomplete', onDoneAjaxRequest, this);
            Ext.Ajax.on('requestexception', onDoneAjaxRequest, this);
        }

        function onWaitForAjaxRequest() {
          pnlMTPanel1El.mask(TEXT_LOADING);
        }

        function onDoneAjaxRequest() {
            pnlMTPanel1El.unmask(false);
        }

        function onBillingCycleChange() {
            btnOk.disable();

            ddIntervalId.store.removeAll();
            ddIntervalId.clearValue();
            ddIntervalId.disable();

            ddBillGroupId.store.removeAll();
            ddBillGroupId.clearValue();
            ddBillGroupId.disable();

            var ddBillingCycleSelectedValue = ddBillingCycle.getValue();
            if (ddBillingCycleSelectedValue != '') {
                //alert('Make service call to get billing intervals corresponding to the billing cycle ' + ddBillingCycleSelectedValue + ' and populate bill intervals');

                Ext.Ajax.request({
                    url: '/MetraNet/Reporting/AjaxServices/IntervalListService.aspx',
                    method: 'POST',
                    params: {
                        CycleType: ddBillingCycleSelectedValue
                    },
                    success: function (result, request) {
                        var jsonData = Ext.util.JSON.decode(result.responseText);
                        var intervals = jsonData.records;

                        if (intervals.length > 0) {
                            // Default value = empty
                            insertNewOption(ddIntervalId, "", "");
                            for (var i = 0; i < intervals.length; i++) {
                                insertNewOption(ddIntervalId, intervals[i].value, intervals[i].text);
                            }
                            ddIntervalId.enable();
                        } else {
                            // Default value = N/A - no elements to show
                            insertNewOption(ddIntervalId, "", REPORTS_TREE_NOT_APPLICABLE_TEXT);
                            ddIntervalId.disable();
                        }
                        ddIntervalId.setValue(ddIntervalId.store.getAt(0).data.value); // Default to first item (blank)
                    },
                    failure: function () { console.log('failure'); }
                });
            }
        }

        function onIntervalIdChange() {
            btnOk.disable(); 
            ddBillGroupId.store.removeAll();
            ddBillGroupId.clearValue();
            ddBillGroupId.disable();

            var ddIntervalIdSelectedValue = ddIntervalId.getValue();
            txtIntervalId.value = ddIntervalIdSelectedValue;
            //alert('Make service call to get billing groups corresponding to the billing interval ' + ddIntervalIdSelectedValue + ' and populate bill groups');

            Ext.Ajax.request({
                url: '/MetraNet/Reporting/AjaxServices/BillGroupListService.aspx',
                method: 'POST',
                params: {
                    IntervalId: ddIntervalIdSelectedValue
                },
                success: function (result, request) {
                    var jsonData = Ext.util.JSON.decode(result.responseText);
                    var billGroups = jsonData.records;

                    if (billGroups.length > 0) {
                        // Default value = empty
                        insertNewOption(ddBillGroupId, "", "");
                        for (var i = 0; i < billGroups.length; i++) {
                            insertNewOption(ddBillGroupId, billGroups[i].id_billgroup, '' + billGroups[i].tx_name + ' (' + billGroups[i].id_billgroup + ')');
                        }
                        ddBillGroupId.enable();
                    } else {
                        // Default value = N/A - no elements to show
                        insertNewOption(ddBillGroupId, "", REPORTS_TREE_NOT_APPLICABLE_TEXT);
                        ddBillGroupId.disable();
                    }
                    ddBillGroupId.setValue(ddBillGroupId.store.getAt(0).data.value); // Default to first item (blank)
                },
                failure: function () { console.log('failure'); }
            });
        }

        function onBillGroupIdChange() {
          btnOk.disable();
          var ddBillGroupIdSelectedValue = ddBillGroupId.getValue();
          txtBillGroupId.value = ddBillGroupIdSelectedValue;
          if (ddBillGroupId.store.getCount() > 1 && ddBillGroupIdSelectedValue.length != 0)
            btnOk.enable();
        }

        function insertNewOption(comboBox, value, text) {
            comboBox.store.add(new Ext.data.Record({ value: value, text: text }));
        }

        Ext.onReady(function () {
            InitializeGlobalVars();
        });
    </script>

</asp:Content>
