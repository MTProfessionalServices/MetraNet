<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="UsageQualification.aspx.cs" Inherits="AmpUsageQualificationPage" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">

  <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Usage Qualification" meta:resourcekey="lblTitleResource1"></asp:Label>
  </div>
  
  <div style="line-height: 20px; padding-top: 10px; padding-left: 15px;">
    

    <table>
      <tr>
        <td>
          <asp:Label ID="lblInfo" runat="server" Font-Bold="False" ForeColor="DarkBlue" 
                     Font-Size="9pt" meta:resourcekey="lblInfoResource" 
                     Text="Specify the properties that usage records must have in order to be analyzed by this Decision Type." />
          <br />
          <div style="padding-top: 5px;">
            <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_MORE_INFO, TEXT_AMPWIZARD_HELP_USAGE_QUALIFICATION, 400, 85)" id="moreLinkSpan" ><asp:Literal ID="moreLink" runat="server" Text="<%$ Resources:AmpWizard,TEXT_MORE %>" /></span>
          </div>
        </td>
        <td width="40px" align="right" valign="top">
          <asp:Image ID="AdvancedFeature" runat="server" 
                     ToolTip="<%$ Resources:AmpWizard,TEXT_ADVANCED_FEATURE %>" 
                     ImageUrl="/Res/Images/icons/cog_error_32x32.png" />
        </td>
      </tr>
    </table>
  </div>

  <br />

  <MT:MTTextBoxControl ID="UsageQualificationName" runat="server" meta:resourcekey="UsageQualificationNameResource"
                       Label="Name" ControlWidth="500" TabIndex="200" VType="decisionRelatedName" />
  <br />
  <div id="editDescriptionDiv" runat="server">
    <MT:MTTextArea ID="UsageQualificationDescription" runat="server" meta:resourcekey="UsageQualificationDescriptionResource"
                   Label="Description" ControlHeight="60" ControlWidth="500" TabIndex="210"/>
  </div> <!-- editDescriptionDiv -->
  <div id="viewDescriptionDiv" runat="server">
    <table class="UsageQualificationViewDescription" >
      <tr>
        <td class="UsageQualificationViewDescriptionCol1">
          <MT:MTLabel ID="ViewDescriptionLabel" runat="server" Text="Description:" meta:resourcekey="ViewDescriptionLabelResource"/>
        </td>
        <td class="UsageQualificationViewDescriptionCol2">
          <MT:MTLabel ID="ViewDescriptionText" runat="server" />
        </td>
      </tr>
    </table>
  </div> <!-- viewDescriptionDiv -->

  <br />

  <table>
    <tr>
      <td>
        <div id="editUsageQualificationFilterDiv" runat="server">
          <MT:MTTextArea ID="UsageQualificationFilter" runat="server" meta:resourcekey="UsageQualificationFilterResource"
                         ControlHeight="200" ControlWidth="500" Label="Filter" TabIndex="230"/>
        </div> <!-- editUsageQualificationFilterDiv -->
        <div id="viewUsageQualificationFilterDiv" runat="server">
          <table class="UsageQualificationViewFilter" >
            <tr>
              <td class="UsageQualificationViewFilterCol1">
                <MT:MTLabel ID="ViewUsageQualificationFilterLabel" runat="server" Text="Filter:" meta:resourcekey="ViewUsageQualificationFilterLabelResource"/>
              </td>
              <td class="UsageQualificationViewFilterCol2">
                <MT:MTLabel ID="ViewUsageQualificationFilterText" runat="server" />
              </td>
            </tr>
          </table>
        </div> <!-- viewUsageQualificationFilterDiv -->
      </td>
      <td valign="top">
        <span style="color: blue; text-decoration: underline; cursor: pointer" onclick="displayInfoMultiple(TITLE_AMPWIZARD_FILTER_HELP, TEXT_AMPWIZARD_HELP_FILTER, 400, 150)">
          <asp:Image ID="Image1" runat="server" ImageUrl="/Res/Images/icons/help.png" />
        </span>
      </td>
    </tr>
  </table>
  
  <br/>

  <div id="UsageFieldPanelDiv"  runat="server">
    <MT:MTPanel ID="UsageFieldPanel" runat="server" Collapsible="False" 
                Text="t_acc_usage/Product View Field" meta:resourcekey="lblUsageFieldPanelResource"
                Width="655px" >
      <asp:HiddenField ID="UsageQualificationFilterCursorLocation" runat="server" />
      <br />
      <table>
        <tr>
          <td>
            <asp:Label ID="TableLabel" runat="server" Text="Table:" meta:resourcekey="TableLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td>
            <asp:Label ID="FieldLabel" runat="server" Text="Field:" meta:resourcekey="FieldLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td>
            <asp:Label ID="LogicLabel" runat="server" Text="Logic:" meta:resourcekey="LogicLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td width="200">
            <asp:Label ID="ValueLabel" runat="server" Text="Value:" meta:resourcekey="ValueLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td>
            &nbsp;
          </td>
        </tr>
        <tr>
          <td>
            <asp:DropDownList ID="TableDropDown" runat="server" AutoPostBack="True" OnSelectedIndexChanged="TableDropDown_SelectedIndexChanged"
                              onmouseover="this.title=this.options[this.selectedIndex].title"
                              Width="150px" TabIndex="300"/>
            <asp:CustomValidator ID="TableDropDownCustomValidator" ControlToValidate="TableDropDown" 
                                 ClientValidationFunction="MPC_setNeedToConfirm(false);" runat="server" />
          </td>
          <td>
            <asp:DropDownList ID="FieldDropDown" runat="server" AutoPostBack="True" OnSelectedIndexChanged="FieldDropDown_SelectedIndexChanged"
                              onmouseover="this.title=this.options[this.selectedIndex].title"
                              Width="150px" TabIndex="310" />
            <asp:CustomValidator ID="FieldDropDownCustomValidator" ControlToValidate="FieldDropDown" 
                                 ClientValidationFunction="MPC_setNeedToConfirm(false);" runat="server" />
          </td>
          <td>
            <asp:DropDownList ID="LogicDropDown" runat="server"
                              width="60px" TabIndex="320"/>
          </td>
          <td>
            <MT:MTTextBoxControl ID="StringValue" runat="server" HideLabel="True" 
                                 AllowBlank="True" Width="200" ControlWidth="200" TabIndex="330"/>
            <MT:MTNumberField ID="NumberValue" runat="server" HideLabel="True"
                              AllowBlank="true" Width="200" ControlWidth="200" DecimalPrecision="6" AllowDecimals="True" TabIndex="330"/>
            <asp:DropDownList ID="EnumDropDownValue" runat="server" AutoPostBack="True"
                              onmouseover="this.title=this.options[this.selectedIndex].title"
                              Width="200px" TabIndex="330" />
            <asp:CustomValidator ID="EnumDropDownValueCustomValidator" ControlToValidate="EnumDropDownValue" 
                                 ClientValidationFunction="MPC_setNeedToConfirm(false);" runat="server" />
            <MT:MTDatePicker ID="DateValue" runat="server" HideLabel="True" 
                             AllowBlank="True" Width="200" ControlWidth="200" TabIndex="330"/>
          </td>
          <td width="10">
            &nbsp;
          </td>
          <td align="right">
            <MT:MTButton ID="InsertFilterTextButton" runat="server" Text="<%$Resources:TEXT_INSERT%>"
                         OnClientClick="MPC_setNeedToConfirm(false); saveCursorPos();"
                         OnClick="btnInsertFilterTextButton_Click"
                         CausesValidation="false" TabIndex="340" />
          </td>
        </tr>
      </table>
    </MT:MTPanel>

    <br/>
  
    <MT:MTPanel ID="AnotherUQGPanel" runat="server" Collapsible="False" 
                Text="Another Usage Qualification" meta:resourcekey="lblAnotherUQGPanelResource"
                Width="655px" >

      <table>
        <tr>
          <td>
            <asp:Label ID="AnotherUQGLabel1" runat="server" Text="Usage Qualification:" meta:resourcekey="UsageQualificationLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td>
            <asp:Label ID="AnotherUQGLabel2" runat="server" Text="Logic:" meta:resourcekey="AnotherUQGLogicLabelResource"
                       Font-Bold="True" ForeColor="Black"></asp:Label>
          </td>
          <td>
            &nbsp;
          </td>
        </tr>
        <tr>
          <td>
            <asp:DropDownList ID="AnotherUQGDropDown" runat="server"
                              onmouseover="this.title=this.options[this.selectedIndex].title"
                              Width="150px" TabIndex="400"/>
          </td>
          <td>
            <asp:DropDownList ID="AnotherUQGLogicDropDown" runat="server"
                              onmouseover="this.title=this.options[this.selectedIndex].title"
                              Width="200px" TabIndex="410"
              />
          </td>
          <td align="right">
            <MT:MTButton ID="InsertAnotherUQGFilterTextButton" runat="server" Text="<%$Resources:TEXT_INSERT%>"
                         OnClientClick="MPC_setNeedToConfirm(false); saveCursorPos();"
                         OnClick="btnInsertAnotherUsageQualificationTextButton_Click"
                         CausesValidation="false" TabIndex="420" />
          </td>
        </tr>
      </table>    
    </MT:MTPanel>
  </div>

  <!-- 
    Regarding positioning of the Back and Continue buttons:
    The br element is needed; leave it there!
    The padding-left and padding-top might change from page to page,
    but leave the col width the same to maintain the same spacing between buttons on every page.
    -->
  <br />
  <div style="padding-left: 0.85in; padding-top: -0.5in;">   
    <table>
      <col style="width: 190px"/>
      <col style="width: 190px"/>
      <tr>
        <td align="left">
          <MT:MTButton ID="btnBack" runat="server" Text="<%$Resources:Resource,TEXT_BACK%>"
                       OnClientClick="setLocationHref(ampPreviousPage); return false;"
                       CausesValidation="false" TabIndex="500" />
        </td>
        <td align="right">
          <MT:MTButton ID="btnSaveAndContinue" runat="server" Text="<%$Resources:Resource,TEXT_SAVE_AND_CONTINUE%>"
                       OnClientClick="if (ValidateForm()) { MPC_setNeedToConfirm(false); } else { MPC_setNeedToConfirm(true); return false; }"
                       OnClick="btnContinue_Click"
                       CausesValidation="true" TabIndex="510"/>
          <MT:MTButton ID="btnContinue" runat="server" Text="<%$Resources:Resource,TEXT_CONTINUE%>"
                       OnClientClick="MPC_setNeedToConfirm(false);"
                       OnClick="btnContinue_Click"
                       CausesValidation="False" TabIndex="510"/>
        </td>
      </tr>
    </table> 
  </div>

  
  <script type="text/javascript" language="javascript">

/**
    This function returns the start position and the end position of the selected text within the element el.
**/
    function getSelection(el) {
      /*Special handling for IE*/
      if (Ext.isIE) {
        el.focus();

        var range = document.selection.createRange();
        var bookmark = range.getBookmark();

        var contents = el.value;
        var originalContents = contents;
        var marker = "##SELECTION_MARKER_" + Math.random() + "##";
        while (contents.indexOf(marker) != -1) {
          marker = "##SELECTION_MARKER_" + Math.random() + "##";
        }

        var parent = range.parentElement();
        if (parent == null || parent.type != "textarea") {
          return { start: 0, end: 0 };
        }
        range.text = marker + range.text + marker;
        contents = el.value;

        var result = { };
        result.start = contents.indexOf(marker);
        contents = contents.replace(marker, "");
        result.end = contents.indexOf(marker);

        el.value = originalContents;
        range.moveToBookmark(bookmark);
        range.select();

        return { start: result.start, end: result.end };
      }
      /*Not IE, so just use supported javascript selectionStart and selectionEnd properties of the element*/
      else {
        return {
          start: el.selectionStart,
          end: el.selectionEnd
        };
      }
    }

    function saveCursorPos() {
      var el = Ext.get("<%=UsageQualificationFilter.ClientID%>").dom;
      var sel = getSelection(el);
      var out = document.getElementById('<%=UsageQualificationFilterCursorLocation.ClientID %>');
      out.value = sel.start;
    }


    function InsertTextAtCursorPos(v) {
      var el = document.getElementById('<%=UsageQualificationFilter.ClientID%>');
      if (Ext.isIE) {
        el.focus();
        var sel = document.selection.createRange();
        sel.text = v;
        sel.moveEnd('character', v.length);
        sel.moveStart('character', v.length);
      } else {
        var startPos = el.dom.selectionStart;
        var endPos = el.dom.selectionEnd;
        el.dom.value = el.dom.value.substring(0, startPos)
          + v
            + el.dom.value.substring(endPos, el.dom.value.length);

        el.focus();
        el.dom.setSelectionRange(endPos + v.length, endPos + v.length);
      }
    }
  </script>

</asp:Content>
