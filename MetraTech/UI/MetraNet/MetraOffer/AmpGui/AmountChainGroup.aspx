<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="AmountChainGroup.aspx.cs" Inherits="AmpAmountChainGroupPage"  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">


  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Amount Chain Group" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">
    <asp:Label ID="lblAmountChainGroup" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblAmountChainGroupResource1" 
      Text="An &lt;i&gt;Amount Chain&lt;/i&gt; is a collection of usage charge fields that are related to the charge amount.  Some fields are used to determine the amount; some fields are derived from the amount.  An &lt;i&gt;Amount Chain Group&lt;/i&gt; is a set of Amount Chains that are associated with a Decision Type."/>
    <br />
    <div style="padding-top:5px;">
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_AMOUNT_CHAIN_GROUP, 450, 125)" id="moreLink" ><asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" /></span>
    </div>
    <br />

    <asp:Label ID="lblSelect" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblSelectResource1" 
      Text="Select the Amount Chain Group for this Decision Type:" ></asp:Label>
  </div>
  
  <div>
  <div style="float:left;padding-left:10px;">
      <MT:MTCheckBoxControl ID="FromParamTableCheckBox" runat="server" LabelWidth="0"  BoxLabel="<%$Resources:Resource,TEXT_FROM_PARAM_TABLE%>" XType="Checkbox" XTypeNameSpace="form" />
  </div>
  <div style="float:left">
      <div id="divAmountChainGroupFromParamTableDropdownSource" runat="server">
          <MT:MTDropDown ID="ddAmountChainGroupFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200" 
          HideLabel="True" AllowBlank="True" Editable="True"/>
      </div>
  </div>
  <div style="clear:both;"></div>
  </div>
  
  <div id="divAmountChainGroupGrid" runat="server" >
  <div style="padding-left:5px;">
    <MT:MTFilterGrid ID="AmountChainGroupGrid" runat="server" TemplateFileName="AmpWizard.AmountChainGroups" ExtensionName="MvmAmp">
    </MT:MTFilterGrid>
  </div>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
  -->
  <br />
  <div style="padding-left:0.85in; padding-top:0.22in;">   
      <table>
        <col style="width:190px"/>
        <col style="width:190px"/>
        <tr>
          <td align="left">
            <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                         OnClientClick="setLocationHref(ampPreviousPage); return false;"
                         CausesValidation="false" TabIndex="230" />
          </td>
          <td align="right">
            <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_NEXT%>"
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); return onContinueClick(); } else { MPC_setNeedToConfirm(true); return false; }"
                         OnClick="btnContinue_Click"
                         CausesValidation="true" TabIndex="240"/>
            <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"
                         OnClientClick="MPC_setNeedToConfirm(false);"
                         OnClick="btnContinue_Click"
                         CausesValidation="False" TabIndex="240"/>
          </td>
        </tr>
      </table> 
  </div>


  <input id="hiddenAmtChainGroupName" type="hidden" runat="server" value="" />


  <script type="text/javascript" language="javascript">
      function updateActiveControls() {
         var dd = Ext.getCmp('<%=ddAmountChainGroupFromParamTableSource.ClientID %>');
         var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
         if (cb.checked == true) {
             dd.enable();
             document.getElementById('<%=divAmountChainGroupGrid.ClientID %>').style.display = "none";
         } else {
             dd.disable();
             document.getElementById('<%=divAmountChainGroupGrid.ClientID %>').style.display = "block";
         }
     }
     
    function onContinueClick() {
      // Check the selected amount chain group name.
      var records = grid_<%= AmountChainGroupGrid.ClientID %>.getSelectionModel().getSelections();
      if ("<%=AmpAction%>" != 'View')
      {
        if (records.length > 0)
        {
          // Pass the value to the code-behind.
          Ext.get("<%=hiddenAmtChainGroupName.ClientID%>").dom.value = records[0].data.Name;
        }
        else
        {
          // Pass empty string to the code-behind.
            var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
         if (cb.checked == true)
                Ext.get("<%=hiddenAmtChainGroupName.ClientID%>").dom.value = document.getElementById('<%=ddAmountChainGroupFromParamTableSource.ClientID %>').value;
            else 
                Ext.get("<%=hiddenAmtChainGroupName.ClientID%>").dom.value = '';
        }
      }
    }

      // This flag is needed to enable us to select the current amount chain group
      // in the grid after loading the grid, even if the user is just viewing the decision type.
      var initializingGridSelection = false;


      // Define event handlers for the grid, and record initial values
      // of the page's controls.
      Ext.onReady(function () {

        // Define an event handler for the grid control's Load event,
        // which will select the radio button that corresponds to the 
        // decision type's current amount chain group.
         var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
          if (cb.checked != true) {
             document.getElementById('<%=divAmountChainGroupGrid.ClientID %>').style.display = "block";
          }

          dataStore_<%= AmountChainGroupGrid.ClientID %>.on(
          "load",
          function(store, records, options)
          {
            var currentAmtChainGroupName = Ext.get("<%=hiddenAmtChainGroupName.ClientID%>").dom.value;
            for (var i = 0; i < records.length; i++)
            {
              if (records[i].data.Name === currentAmtChainGroupName)
              {
                // Found the right row!
                initializingGridSelection = true;  // to permit row selection even if action is View
                grid_<%= AmountChainGroupGrid.ClientID %>.getSelectionModel().selectRow(i);
                break;
              }
            }
          }
        );

        // Define an event handler for the grid's beforerowselect event,
        // which makes the grid readonly if the AmpAction is "View"
        // by preventing any row from being selected.
        var selectionModel = grid_<%= AmountChainGroupGrid.ClientID %>.getSelectionModel();
        selectionModel.on(
          "beforerowselect",
          function()
          {
            if (initializingGridSelection == true)
            {
              initializingGridSelection = false;
            }
            else if (ampAction === "View")
            {
              return false;
            }
          }
        );

        selectionModel.on(
          "selectionchange",
          function()
          {
            if (ampAction === "View")
            {
              return false;
            }
            else {
              // Not in View mode, so update the hidden input field for monitoring changes to selected row
              var records = grid_<%= AmountChainGroupGrid.ClientID %>.getSelectionModel().getSelections();
              if (records.length > 0) {
                Ext.get("<%=hiddenAmtChainGroupName.ClientID%>").dom.value = records[0].data.Name;
              }
            }
          }
        );
        
        //JCTBD
        // Record the initial values of the page's controls.
        // (Note:  This is called here, and not on the master page,
        // because the call to document.getElementById() returns null
        // if executed on the master page.)
        MPC_assignInitialValues();

      });  // Ext.onReady
    

</script>


</asp:Content>
