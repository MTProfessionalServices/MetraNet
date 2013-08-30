<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="AccountGroup.aspx.cs" Inherits="AmpAccountGroupPage"  meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Select Account Group" meta:resourcekey="lblTitleResource1"></asp:Label>   
  </div>

  <div style="line-height:20px;padding-top:10px;padding-left:15px;">
  <table>
    <tr>
      <td width="480px">
        <asp:Label ID="lblAccountGroup" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
        Font-Size="9pt" meta:resourcekey="lblAccountGroupResource1" 
        Text="When considering a Decision for an account, you may want to analyze, not just the single account, but other related accounts as well."/>
        <br />
        <div style="padding-top:5px;">
          <span style="color:blue;text-decoration:underline;cursor:pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_ACCOUNT_GROUP, 450, 130)" id="moreLink" ><asp:Literal ID="Literal1" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" /></span>
        </div>
      </td>
      <td>
        <div style="padding-left: 10px; padding-top:4px;">
          <img id="Img2" src='/Res/Images/icons/cog_error_32x32.png' runat="server" title="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" />
        </div>
      </td>
    </tr>
  </table>

    <br />
    <asp:Label ID="lblSelect" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
      Font-Size="9pt" meta:resourcekey="lblSelectResource1" 
      Text="Select the Account Group for this Decision Type:" ></asp:Label>
  </div>  

    <div>
        <div style="float:left;padding-left:10px;">
            <MT:MTCheckBoxControl ID="FromParamTableCheckBox" runat="server" LabelWidth="0" BoxLabel="<%$Resources:Resource,TEXT_FROM_PARAM_TABLE%>" XType="Checkbox" XTypeNameSpace="form" />
        </div>
        <div style="float:left">
            <div id="divAccountGroupFromParamTableDropdownSource" runat="server">
                <MT:MTDropDown ID="ddAccountGroupFromParamTableSource" runat="server" ControlWidth="160" ListWidth="200" HideLabel="True" AllowBlank="True" Editable="True"/>
            </div>
        </div>
        <div style="clear:both;"></div>
    </div>

<div id="divAccountGroupGrid" runat="server" >
 
  <div style="padding-left:5px;">
    <MT:MTFilterGrid ID="AccountGroupGrid" runat="server" TemplateFileName="AmpWizard.AccountGroups" ExtensionName="MvmAmp">
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


  <input id="hiddenAcctGroupName" type="hidden" runat="server" value="" />


  <script type="text/javascript" language="javascript">
        function updateActiveControls() {
         var dd = Ext.getCmp('<%=ddAccountGroupFromParamTableSource.ClientID %>');
         var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
         if (cb.checked == true) {
             dd.enable();
             document.getElementById('<%=divAccountGroupGrid.ClientID %>').style.display = "none";
         } else {
             dd.disable();
             document.getElementById('<%=divAccountGroupGrid.ClientID %>').style.display = "block";
         }
     }

    OverrideRenderer_<%= AccountGroupGrid.ClientID %> = function(cm) {
      if (cm.getIndexById('Actions') != -1) {
        cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer);
      }
    }

    function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
    {
      var str = "";    
      str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' href='JavaScript:onViewAccountGroup(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>",  record.data.Name, TEXT_VIEW_ACCOUNT_GROUP);
      if (ampAction != "View")
      {
        str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Edit' title='{1}' href='JavaScript:onEditAccountGroup(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",  record.data.Name, TEXT_EDIT_ACCOUNT_GROUP);
      }
      return str;
    }
    
   function onViewAccountGroup(name)
   {
        location.href= "EditAccountGroup.aspx?AccountGroupAction=View&AccountGroupName=" + name;
   }

   function onEditAccountGroup(name)
   {
        location.href= "EditAccountGroup.aspx?AccountGroupAction=Edit&AccountGroupName=" + name; 
   }
   
  // Event handler for Add button in AccountGroupGrid gridlayout
  function onAdd_<%=AccountGroupGrid.ClientID %>() {
    var addAccountGroupWindow = new top.Ext.Window({
      id: 'addAccountGroupWindow',
      title: TITLE_AMPWIZARD_ADD_ACCOUNT_GROUP,
      width: 450,
      height: 280,
      minWidth: 450,
      minHeight: 280,
      layout: 'fit',
      plain: true,
      bodyStyle: 'padding:5px;',
      buttonAlign: 'center',
      collapsible: true,
      resizable: false,
      maximizable: false,
      closable: true,
      closeAction: 'close',
      modal: 'true',
      html: '<iframe id="addWindow" src="/MetraNet/MetraOffer/AmpGui/AddAccountGroup.aspx" width="100%" height="100%" frameborder="0" />'
    });
    // add a parameter to the window so that we know if we need to stay on page or not after the window is closed. This parameter will be
    // updated within javascript in AddAccountGroup.aspx.
    addAccountGroupWindow.myExtraParams = { newAccountGroupName: "" };
    addAccountGroupWindow.show();
    addAccountGroupWindow.on('close', function() {
      // Open the edit Account Group page for the new Account Group just inserted. If no new Account Groups were inserted, stay on page.
      if (addAccountGroupWindow.myExtraParams.newAccountGroupName != "") {
        window.location = "/MetraNet/MetraOffer/AmpGui/EditAccountGroup.aspx?AccountGroupAction=Edit&AccountGroupName="
                            + addAccountGroupWindow.myExtraParams.newAccountGroupName;
      }
    });
  }

  function onContinueClick() {
      // Store the selected account group name.
      var records = grid_<%= AccountGroupGrid.ClientID %>.getSelectionModel().getSelections();
      var dd = Ext.getCmp('<%=ddAccountGroupFromParamTableSource.ClientID %>');
      var cb = Ext.getCmp('<%=FromParamTableCheckBox.ClientID %>');
      if ((ampAction != 'View'))
      {
          if (cb.checked) {
              Ext.get("<%=hiddenAcctGroupName.ClientID%>").dom.value = dd.value.toString();
          } else {
              if(records.length>0)
                Ext.get("<%=hiddenAcctGroupName.ClientID%>").dom.value = records[0].data.Name;
              else
                Ext.get("<%=hiddenAcctGroupName.ClientID%>").dom.value = '';
          }
      }
    }

      // This flag is needed to enable us to select the current account group
      // in the grid after loading the grid, even if the user is just viewing the decision type.
      var initializingGridSelection = false;


      // Define event handlers for the grid, and record initial values
      // of the page's controls.
      Ext.onReady(function () {

        // Define an event handler for the grid control's Load event,
        // which will select the radio button that corresponds to the 
        // decision type's current account group.
        dataStore_<%= AccountGroupGrid.ClientID %>.on(
          "load",
          function(store, records, options)
          {
            var currentAcctGroupName = Ext.get("<%=hiddenAcctGroupName.ClientID%>").dom.value;
            for (var i = 0; i < records.length; i++)
            {
              if (records[i].data.Name === currentAcctGroupName)
              {
                // Found the right row!
                initializingGridSelection = true;  // to permit row selection even if action is View
                grid_<%= AccountGroupGrid.ClientID %>.getSelectionModel().selectRow(i);
                break;
              }
            }
            updateActiveControls();
          }
        );

        // Define an event handler for the grid's beforerowselect event,
        // which makes the grid readonly if the AmpAction is "View"
        // by preventing any row from being selected.
        var selectionModel = grid_<%= AccountGroupGrid.ClientID %>.getSelectionModel();
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
              var records = grid_<%= AccountGroupGrid.ClientID %>.getSelectionModel().getSelections();
              if (records.length > 0) {
                Ext.get("<%=hiddenAcctGroupName.ClientID%>").dom.value = records[0].data.Name;
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


