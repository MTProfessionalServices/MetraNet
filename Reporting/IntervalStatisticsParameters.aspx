<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="IntervalStatisticsParameters.aspx.cs" Inherits="IntervalStatisticsParameters" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

    <script language="javascript" type="text/javascript">
        var ddBillingCycle;
        var ddIntervalId;
        var ddBillGroupId;
        var btnOk;
        var btnOkDiv;

        var txtIntervalId;
        var txtBillGroupId;

        function Initialize() {
            ddBillingCycle = Ext.getCmp('ctl00_ContentPlaceHolder1_ddBillingCycle');
            ddIntervalId = Ext.getCmp('ctl00_ContentPlaceHolder1_ddIntervalId');
            ddBillGroupId = Ext.getCmp('ctl00_ContentPlaceHolder1_ddBillGroupId');

            txtIntervalId = document.getElementById('<%=txtIntervalId.ClientID%>');
            txtBillGroupId = document.getElementById('<%=txtBillGroupId.ClientID%>');
            
            //btnOK = Ext.getCmp("ctl00_ContentPlaceHolder1_btnOK");
            //btnOk.disable();
        }

        function onBillingCycleChange() {
            Initialize(); // This should not be necessary. But the onReady call is not doing its work

            //btnOk.disable();

            ddIntervalId.store.removeAll();
            ddIntervalId.clearValue();
            ddIntervalId.disable();

            ddBillGroupId.store.removeAll();
            ddBillGroupId.clearValue();
            ddBillGroupId.disable();

            ddBillingCycleSelectedValue = ddBillingCycle.getValue();
            if (ddBillingCycleSelectedValue != '') {
                //alert('Make service call to get billing intervals corresponding to the billing cycle ' + ddBillingCycleSelectedValue + ' and populate bill intervals');

                // Sample data for testing
                insertNewOption(ddIntervalId, "", "");

                Ext.Ajax.request({
                    url: '/MetraNet/Reporting/AjaxServices/IntervalListService.aspx',
                    method: 'POST',
                    params: {
                        CycleType: ddBillingCycleSelectedValue
                    },
                    success: function (result, request) {
                        var jsonData = Ext.util.JSON.decode(result.responseText);
                        var intervals = jsonData.records;
                        for (var i = 0; i < intervals.length; i++) {
                            insertNewOption(ddIntervalId, intervals[i].id_interval, '' + intervals[i].dt_start + ' - ' + intervals[i].dt_end + ' (' + intervals[i].id_interval + ')');
                        }
                        ddIntervalId.setValue(ddIntervalId.store.getAt(0).data.value); // Default to first item (blank)
                        ddIntervalId.enable();
                    },
                    failure: function () { console.log('failure'); }
                });
            }
        }

        function onIntervalIdChange() {
            ddBillGroupId.store.removeAll();
            ddBillGroupId.clearValue();
            ddBillGroupId.disable();

            ddIntervalIdSelectedValue = ddIntervalId.getValue();
            txtIntervalId.value = ddIntervalIdSelectedValue;
            //alert('Make service call to get billing groups corresponding to the billing interval ' + ddIntervalIdSelectedValue + ' and populate bill groups');

            // Sample data for testing
            insertNewOption(ddBillGroupId, "", "");

            Ext.Ajax.request({
                url: '/MetraNet/Reporting/AjaxServices/BillGroupListService.aspx',
                method: 'POST',
                params: {
                    IntervalId: ddIntervalIdSelectedValue
                },
                success: function (result, request) {
                    var jsonData = Ext.util.JSON.decode(result.responseText);
                    var billGroups = jsonData.records;
                    for (var i = 0; i < billGroups.length; i++) {
                        insertNewOption(ddBillGroupId, billGroups[i].id_billgroup, '' + billGroups[i].tx_name + ' (' + billGroups[i].id_billgroup + ')');
                    }

                    ddBillGroupId.setValue(ddBillGroupId.store.getAt(0).data.value); // Default to first item (blank)
                    ddBillGroupId.enable();
                    //btnOk.enable();
                },
                failure: function () { console.log('failure'); }
            });
        }

        function onBillGroupIdChange() {
            ddBillGroupIdSelectedValue = ddBillGroupId.getValue();
            txtBillGroupId.value = ddBillGroupIdSelectedValue;
        }

        function insertNewOption(comboBox, value, text) {
            comboBox.store.add(new Ext.data.Record({ value: value, text: text }));
        }

        Ext.onReady(function () {
            Initialize();
        });
    </script>


    <MT:MTTitle ID="MTTitle1" Text="Interval Statistics Parameters" runat="server" meta:resourcekey="MTTitle1Resource1" /><br />

    <MT:MTPanel ID="MTPanel1" runat="server" Text="Interval Statistics Parameters" meta:resourcekey="MTPanel1">

        <div id="leftColumn1" class="LeftColumn">
          
          <MT:MTDropDown ID="ddBillingCycle" runat="server" AllowBlank="true" Label="Billing Cycle"
            TabIndex="100" ControlWidth="200" ListWidth="200" HideLabel="False" LabelSeparator=":" Listeners="{ select: onBillingCycleChange }"
            meta:resourcekey="ddBillingCycle" ReadOnly="False">
          </MT:MTDropDown>
          
          <div id="SectionIntervalId" style="display: block;">
              <MT:MTDropDown ID="ddIntervalId" runat="server" AllowBlank="true" Label="Billing Interval"
                TabIndex="100" ControlWidth="400" ListWidth="400" HideLabel="False" LabelSeparator=":" Listeners="{ select: onIntervalIdChange }"
                meta:resourcekey="ddIntervalId" ReadOnly="False" Enabled="false">
              </MT:MTDropDown>
              <input id="txtIntervalId" runat="server" type="hidden" />
          </div>
          
          <div id="SectionBillGroupId" style="display: block;">
              <MT:MTDropDown ID="ddBillGroupId" runat="server" AllowBlank="true" Label="Billing Group"
                TabIndex="101" ControlWidth="400" ListWidth="400" HideLabel="False" LabelSeparator=":" Listeners="{ select: onBillGroupIdChange }"
                meta:resourcekey="ddBillGroupId" ReadOnly="False" Enabled="false">
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

</asp:Content>
