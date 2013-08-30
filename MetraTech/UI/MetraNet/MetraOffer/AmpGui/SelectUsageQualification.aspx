<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="SelectUsageQualification.aspx.cs" Inherits="AmpSelectUsageQualificationPage" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Select Usage Qualification" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">
    <asp:Label ID="lblSelectUsageQual" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblSelectUsageQualResource1" 
      Text="Usage (a rated billing record) is a collection of product view record fields.  A Usage Qualification limits the usage that a Decision can analyze to those usage records that have certain properties."/>
    <br />
    <div style="padding-top:5px;">
      <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_SELECT_USAGE_QUALIFICATION, 420, 110)" id="moreLink" ><asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" /></span>
    </div>
    <br />
    <asp:Label ID="lblSelect" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblSelectResource1" 
      Text="Select the Usage Qualification for this Decision Type:" ></asp:Label>
  </div>  
  
      <div>
        <div style="float:left;padding-left:10px;">
            <MT:MTCheckBoxControl ID="FromParamTableCheckBox" runat="server" LabelWidth="0" BoxLabel="<%$Resources:Resource,TEXT_FROM_PARAM_TABLE%>" XType="Checkbox" XTypeNameSpace="form" />
        </div>
        <div  style="float:left">
            <div id="divUsageQualFromParamTableDropdownSource" runat="server">
                <MT:MTDropDown ID="ddUsageQualFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200" HideLabel="True" AllowBlank="True" Editable="True"/>
            </div>
        </div>
        <div style="clear:both;"></div>
    </div>


  <div id="divUsageQualGrid" runat="server" >

  <div style="padding-left:5px;">
    <MT:MTFilterGrid ID="UsageQualGrid" runat="server" TemplateFileName="AmpWizard.UsageQualificationGroups" ExtensionName="MvmAmp">
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
  <div style="padding-left:0.85in; padding-top:0in;">   
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
                         OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); onContinueClick(); } else { MPC_setNeedToConfirm(true); return false; }"
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


  <input id="hiddenUsageQualGroupName" type="hidden" runat="server" value="" />


  <script type="text/javascript" language="javascript">
    function updateActiveControls() {
         var dd = Ext.getCmp('<%=ddUsageQualFromParamTableSource.ClientID %>');
         var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
         if (cb.checked == true) {
             dd.enable();
             document.getElementById('<%=divUsageQualGrid.ClientID %>').style.display = "none";
         } else {
             dd.disable();
             document.getElementById('<%=divUsageQualGrid.ClientID %>').style.display = "block";
         }
     }

    function onContinueClick() {
      // Store the selected usage qualification group name.
      var dd = Ext.getCmp('<%=ddUsageQualFromParamTableSource.ClientID %>');
      var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
     var records = grid_<%= UsageQualGrid.ClientID %>.getSelectionModel().getSelections();
        if (("<%=AmpAction%>" != 'View') ) {
            if (cb.checked) {
                Ext.get("<%=hiddenUsageQualGroupName.ClientID%>").dom.value = dd.value.toString();
            }
            else if (records.length > 0)
                Ext.get("<%=hiddenUsageQualGroupName.ClientID%>").dom.value = records[0].data.Name;
            else {
                Ext.get("<%=hiddenUsageQualGroupName.ClientID%>").dom.value = '';
            }
        } 
    }


    // Event handler for Add button in AmpWizard.UsageQualificationGroups gridlayout
    function onAdd_<%=UsageQualGrid.ClientID %>()
    {
      location.href = "UsageQualification.aspx?UsgAction=Create";
    }


    OverrideRenderer_<%= UsageQualGrid.ClientID %> = function(cm)
    {
      cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer); 
    }


    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";    
   
      // View
      str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' href='JavaScript:onViewUsageQualification(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>", record.data.Name, TEXT_AMPWIZARD_VIEW);
   
      return str;
    }

    function onViewUsageQualification(name)
    {
      location.href= "UsageQualification.aspx?UsgAction=View&UsageQualificationName=" + name;    
    }

      // This flag is needed to enable us to select the current usage qualification group
      // in the grid after loading the grid, even if the user is just viewing the decision type.
      var initializingGridSelection = false;


      // Define event handlers for the grid, and record initial values
      // of the page's controls.
      Ext.onReady(function () {

        // Define an event handler for the grid control's Load event,
        // which will select the radio button that corresponds to the 
        // decision type's current usage qualification group.
        dataStore_<%= UsageQualGrid.ClientID %>.on(
          "load",
          function(store, records, options)
          {
            var currentUsageQualGroupName = Ext.get("<%=hiddenUsageQualGroupName.ClientID%>").dom.value;
            for (var i = 0; i < records.length; i++)
            {
              if (records[i].data.Name === currentUsageQualGroupName)
              {
                // Found the right row!
                initializingGridSelection = true;  // to permit row selection even if action is View
                grid_<%= UsageQualGrid.ClientID %>.getSelectionModel().selectRow(i);
                break;
              }
            }
             updateActiveControls();

          }
        );

        // Define an event handler for the grid's beforerowselect event,
        // which makes the grid readonly if the AmpAction is "View"
        // by preventing any row from being selected.
        var selectionModel = grid_<%= UsageQualGrid.ClientID %>.getSelectionModel();
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
              var records = grid_<%= UsageQualGrid.ClientID %>.getSelectionModel().getSelections();
              if (records.length > 0) {
                Ext.get("<%=hiddenUsageQualGroupName.ClientID%>").dom.value = records[0].data.Name;
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

