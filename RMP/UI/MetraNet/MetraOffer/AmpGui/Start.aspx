<%@ Page Language="C#" MasterPageFile="~/MasterPages/AmpWizardPageExt.master" AutoEventWireup="true" CodeFile="Start.aspx.cs" Inherits="AmpStartPage" Title="MetraNet" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 
 <div class="CaptionBar">
    <asp:Label ID="lblTitle" runat="server" Text="Manage Aggregate Metrics Processing (AMP) Decisions" meta:resourcekey="lblTitleResource1"></asp:Label>   
 </div>

 <div style="line-height:20px;padding:15px;">
    <asp:Label ID="lblDescription" runat="server" Font-Bold="false" ForeColor="DarkBlue" Font-Size="9pt" meta:resourcekey="lblDecisionDescriptionResource1" 
               Text="A Decision Type defines a set of actions to take on a specified set of accounts when a summed quantity meets certain criteria. <br/>A Decision, which is an instance of a Decision Type, is processed by the Aggregate Metrics Processor." ></asp:Label>
 </div>
  

 <div style="padding-left:5px;">
   <MT:MTFilterGrid ID="DecisionsGrid" runat="server" TemplateFileName="AmpWizard.Decisions" ExtensionName="MvmAmp">
   </MT:MTFilterGrid>
</div>


<script type="text/javascript">

  // Event handler for Create button in AmpWizard.Decisions gridlayout
  function onCreate_<%=DecisionsGrid.ClientID %>()
  {
    location.href = "NavigationPanelInit.aspx?Action=Create";
  }


  OverrideRenderer_<%= DecisionsGrid.ClientID %> = function(cm)
  {
    cm.setRenderer(cm.getIndexById('IsActive'), isActiveColRenderer); 
    cm.setRenderer(cm.getIndexById('Actions'), actionsColRenderer); 
  }


  // We put an id on the images in the IsActive column so that we can change them
  // if a decision is de/activated while the grid is sorted by IsActive.
  // (See onActivateDecision().)
  function isActiveColRenderer(value, meta, record, rowIndex, colIndex, store) 
  {
    if ((value + '').toLowerCase() == 'true') {
      return String.format("<img id='activeImg{0}' border=\'0\' src=\'/Res/Images/Icons/tick.png\'>", rowIndex);
    }

    if ((value + '').toLowerCase() == 'false') {
      return String.format("<img id='activeImg{0}' border=\'0\' src=\'/Res/Images/Icons/cross.png\'>", rowIndex);
    }

    return '';
  }

  
  function actionsColRenderer(value, meta, record, rowIndex, colIndex, store)
  {
    var str = "";    
   
    // View
    str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='View' title='{1}' href='JavaScript:onViewDecision(\"{0}\");'><img src='/Res/Images/icons/view.gif' alt='{1}' /></a>", record.data.Name.replace("\u0027","&#039;"), TEXT_AMPWIZARD_VIEW);
   
    //Edit
    if ((record.json != null) && record.json.IsEditable)
    {
      str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Edit' title='{1}' href='JavaScript:onEditDecision(\"{0}\");'><img src='/Res/Images/icons/pencil.png' alt='{1}' /></a>",  record.data.Name.replace("\u0027","&#039;"), TEXT_EDIT);
    }

    // Activate/Deactivate
    str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Activate' title='{1}' href='JavaScript:onActivateDecision(\"{0}\");'><img src='/Res/Images/icons/switch.png' alt='{1}' /></a>",  rowIndex, TEXT_ACTIVATE_DEACTIVATE);
   
    //Clone
    str += String.format("&nbsp;&nbsp;<a style='cursor:pointer;' id='Clone' title='{1}' href='JavaScript:onCloneDecision(\"{0}\");'><img src='/Res/Images/icons/copy.png' alt='{1}' /></a>",  rowIndex, TEXT_CLONE);
    
    return str;
  }

  function onViewDecision(name)
  {
    location.href= "NavigationPanelInit.aspx?Action=View&DecisionName=" + name;    
  }
  
  function onEditDecision(name)
  {
    location.href= "NavigationPanelInit.aspx?Action=Edit&DecisionName=" + name;
  }

   function escapeHTMLEncode(str) {
  var div = document.createElement('div');
  var text = document.createTextNode(str);
  div.appendChild(text);
  return div.innerHTML;
 }


  function ParamTableExists(directivePTName) {
      var exists = false;
      
      if (parameterTableNames)
      {
          for (var i = 0; i < parameterTableNames.length; i++)
          {
              if(directivePTName === parameterTableNames[i]) {
                  exists = true;
                  break;
              }
          }
      }
      
      return exists;
  }

  function onActivateDecision(rowIndex)
  {
      var record = grid_<%= DecisionsGrid.ClientID %> .getStore().getAt(rowIndex);
      
      if (!record.data.IsActive) {
          if (!ParamTableExists(record.data.ParameterTableName)) {
              top.Ext.MessageBox.show({
                      title: '<%= GetLocalResourceObject("TITLE_UNABLE_TO_ACTIVATE") %>',
                      msg: '<%= GetLocalResourceObject("TEXT_PT_NOT_EXIST") %>',
                      buttons: Ext.MessageBox.OK,
                      icon: Ext.MessageBox.ERROR
                  });
              return;
          }
      }

      record.data.IsActive = !record.data.IsActive;
      var decisionName = record.data.Name;
      var newStatus = record.data.IsActive;
      if (decisionName != null)
      {

          var parameters = { decisionName: decisionName, status: newStatus, setStatus: true };
          Ext.Ajax.request(
              {
                  url: '/MetraNet/MetraOffer/AmpGui/AjaxServices/DecisionSvc.aspx',
                  params: parameters,
                  scope: this,
                  disableCaching: true,
                  callback: function(options, success, response)
                  {
                      if (success)
                      {
                          var tmpSortInfo = grid_<%= DecisionsGrid.ClientID %> .getStore().sortInfo;
                          if ((tmpSortInfo != null) && (tmpSortInfo.field == 'IsActive'))
                          {
                              // If the grid is sorted by IsActive, this operation will cause 
                              // the grid to be resorted, which might confuse the user.
                              // So first update the icon for the affected decision;
                              // then alert the user that the order of Decisions will change in the grid.
                              if (newStatus == true)
                              {
                                  Ext.get('activeImg' + rowIndex).dom.src = "/Res/Images/icons/tick.png";
                              }
                              else
                              {
                                  Ext.get('activeImg' + rowIndex).dom.src = "/Res/Images/icons/cross.png";
                              }

                              top.Ext.MessageBox.show({
                                      title: TEXT_SUCCESS,
                                      msg: TEXT_AMPWIZARD_SUCCESS_RESORTING_GRID,
                                      buttons: Ext.MessageBox.OK,
                                      animEl: 'elId',
                                      icon: Ext.MessageBox.INFO,
                                      fn: function(btn) {
                                          // Reload the grid once the user has clicked on OK.
                                          dataStore_<%= DecisionsGrid.ClientID %> .reload();
                                      }
                                  });
                          }
                          else
                          {
                              // Just reload the grid.
                              dataStore_<%= DecisionsGrid.ClientID %> .reload();
                          }
                      }
                      else  // !success
                      {
                          Ext.UI.SystemError(TEXT_AMPWIZARD_ERROR_ACTIVATE_DECISION + " " + decisionName);
                      }
                  }
              });

      }
  }


  function onCloneDecision(rowIndex)
  {
      var record = grid_<%= DecisionsGrid.ClientID %> .getStore().getAt(rowIndex);

      if (!ParamTableExists(record.data.ParameterTableName)) {
          top.Ext.MessageBox.show({
                  title: '<%= GetLocalResourceObject("TITLE_UNABLE_TO_CLONE") %>',
                  msg: '<%= GetLocalResourceObject("TEXT_PT_NOT_EXIST") %>',
                  buttons: Ext.MessageBox.OK,
                  icon: Ext.MessageBox.ERROR
              });
          return;
      }

      var cloneWindow = new top.Ext.Window({
              title: TITLE_AMPWIZARD_CLONE_DECISION,
              id: 'cloneWin',
              width: 450,
              height: 290,
              minWidth: 450,
              minHeight: 290,
              layout: 'fit',
              plain: true,
              bodyStyle: 'padding:5px;',
              buttonAlign: 'center',
              collapsible: true,
              resizeable: false,
              maximizable: false,
              closable: true,
              closeAction: 'close',
              modal: 'true',
              html: '<iframe id="cloneWindow" src="/MetraNet/MetraOffer/AmpGui/CloneDecision.aspx?OrigIsActive=' + record.data.IsActive + '&OrigDecisionName=' + record.data.Name + '" width="100%" height="100%" frameborder="0" />'
          });

      cloneWindow.show();
      cloneWindow.on('close', function() {
          dataStore_<%= DecisionsGrid.ClientID %> .reload();
	      checkFrameLoading();
      });
  }
   
</script>
   
</asp:Content>

