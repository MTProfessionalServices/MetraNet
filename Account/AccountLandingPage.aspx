<%@ Page Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" Inherits="Account_AccountLandingPage"
   Culture="auto" UICulture="auto" CodeFile="AccountLandingPage.aspx.cs" %>

<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<%@ Register src="../UserControls/Analytics/AccountSummary.ascx" tagname="AccountSummary" tagprefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<style>

  .bullet
  {
    font: 10px sans-serif;
  }
  .bullet .marker
  {
    stroke: #000;
    stroke-width: 3px;
  }
  .bullet .marker.good
  {
    stroke: Green;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.bad
  {
    stroke: Red;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.past
  {
    stroke: Blue;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .tick line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.major line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.selected
  {
    font-weight:bolder;
  }
  .bullet .tick.expired
  {
    text-decoration:line-through;
  }
  .bullet .tick.future
  {
    font-style:italic;
  }
  .bullet .domain
  {
    fill: none;
  }
  .bullet .title
  {
    fill: #000;
    display: block;
    font-size: 14px;
    font-weight: bold;
    position: absolute;
    text-anchor: off;
  }
  .bullet .range.s0
  {
    display: block;
    position: absolute;
  }
  .bullet .subtitle
  {
    fill: #999;
    text-anchor: off;
  }
  .bullet .dates
  {
    fill: #000;
    text-anchor: off;
  }
  .bullet .tbutton
  {
    fill:white;
    stroke-width:1;
    stroke:black;
    stroke-opacity:0.05;
  }
  .bullet .notice
  {
    fill:#000;
    font-size: 7px;
    text-anchor: off;
  }
  .bullet .tick
  {
    fill:#000;
  }
.contextmenu {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
}
.contextmenu li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
}
.contextmenu li:hover
{
  font-weight:bolder;
}
.datepicker {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
overflow-y:auto;
overflow-x:visible;
max-height: 100px;
}
.datepicker li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
white-space:nowrap;
}
.datepicker li:hover
{
  font-weight:bolder;
}

.dc-chart rect.bar {
  cursor: default !important;
}
  
</style>
  <script type="text/javascript" src="/Res/JavaScript/jquery.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/jquery.gridster.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/crossfilter.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/dc.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Renderers.js"></script> 
  <script type="text/javascript" src="/Res/JavaScript/d3.v3.min.js"></script>
  <script type="text/javascript" src="/Res/JavaScript/Bullet.js"></script>
  
  <link rel="stylesheet" type="text/css" href="/Res/Styles/jquery.gridster.css">
  <link rel="stylesheet" type="text/css" href="/Res/Styles/dc.css">
  <link rel="stylesheet" type="text/css" href="Styles/Account360.css">
  <script type="text/javascript" src="js/Account360.js"></script>
  <div class="CaptionBar">
    <asp:Label ID="lblAccount360Title" runat="server" meta:resourcekey="lblAccount360Title"></asp:Label>
  </div>
  <div>
    <asp:Label ID="lblErrorMessage" runat="server" CssClass="ErrorMessage" Text="Error Messages"
      Visible="False" meta:resourcekey="lblErrorMessageResource1"></asp:Label>
  </div>



  <script type="text/javascript">
  //Initialize gridster
//    jQuery(function () {
//      var widgets = $('.widget');

//      var currentDashboard = $(".gridster").gridster({
//        widget_selector: widgets,
//        //jQuery(".gridster ul").gridster({
//        widget_margins: [10, 10],
//        widget_base_dimensions: [100, 100]
//      }).data('gridster');

////      gridster = $(".gridster ul").gridster({
////        widget_base_dimensions: [100, 100],
////        widget_margins: [5, 5],
////        helper: 'clone',
////        resize: { enabled: false },
////        autogrow_cols: true
////      }).data('gridster');

//    });

  </script>
  
  <div class="gridster">
    <div class="widget" data-row="1" data-col="1" data-sizex="3" data-sizey="1">
    <div id="AccountSummaryInformation" style="padding: 15px;"></div>
  </div>
  <div id="AccountStatus" class="widgetpanel" style="width:150px; display:none;">
    <div id="Div1"><span class="valueLabel">Status</span><span class="valueHighlighted positive">N/A</span></div>
  </div>
  
  <div id="BalanceInformation" class="widgetpanel" style="width:150px; display:none;">
    <div><span class="valueLabel">Balance</span><span class="valueHighlighted"></span><span class="valueDetail footer">as of March 1st, 2014</span></div>
  </div>
  <div id="FailedTransactionInformation" class="widgetpanel" style="width:150px; display:none;">
    <div><span class="valueLabel">Failed Transactions</span><span class="valueHighlighted"></span><span class="valueDetail footer"></span></div>
  </div>


  <div id="MRRInformation" class="widgetpanel" style="width:150px; display:none;">
    <%-- <div id="LTVInformation" style="float:left;margin-left: 10px;"><span class="valueLabel">LTV</span><span class="valueHighlighted" style='padding-left: 10px;'></span></div> --%>
    <div><span class="valueLabel">MRR</span><span class="valueHighlighted"></span></div>
  </div>

  <br style="clear: both;" />
   
  <div class="widget" data-row="3" data-col="1" data-sizex="8" data-sizey="1">
  <%--  <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>
    <MT:MTPanel ID="SalesSummaryPanel" runat="server" Text="Sales Summary" >
      <div id="SalesSummaryInformation"></div>
    </MT:MTPanel>
    <MT:MTFilterGrid ID="SalesSummaryGrid" runat="server" TemplateFileName="SalesSummary.xml" ExtensionName="Account" Resizable="False" Title="Sales Summary"></MT:MTFilterGrid>   --%>
  </div>
  <table style="width:100%; height:100%;">
    <tr style="vertical-align: top;">
      <td style="width: 380px; height: 336px;"> 
        <div class="widget" data-row="3" data-col="1" data-sizex="3" data-sizey="3">
          <MT:MTPanel ID="billingActivityPanel" runat="server"  Width="380" meta:resourcekey="billingActivityPanel">
            <div id="billsPaymentsChart" style="width: 100%; height: 100%;">
            </div>
          </MT:MTPanel>
        </div>
      </td>
      <td>
        <div class="widget" data-row="3" data-col="4" data-sizex="5" data-sizey="3" >
          <MT:MTPanel ID="billingSummaryPanel" runat="server" Width="500" meta:resourcekey="billingSummaryPanel">
            <MT:MTFilterGrid ID="BillingSummaryGrid" runat="server" TemplateFileName="AccountBillingSummary.xml"
              ExtensionName="Account" Resizable="False">
            </MT:MTFilterGrid>
          </MT:MTPanel>
        </div>
      </td>
    </tr>
  </table>
  <div class="widget" data-row="6" data-col="1" data-sizex="8" data-sizey="3">
    <MT:MTFilterGrid ID="SubscriptionSummaryGrid" runat="server" TemplateFileName="AccountSubscriptionSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
  </div>
  
  <%--  <div class="widget" data-row="9" data-col="1" data-sizex="8" data-sizey="3">
    <MT:MTFilterGrid ID="InvoiceSummaryGrid" runat="server" TemplateFileName="AccountInvoiceSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
    </div>
  
    <div class="widget" data-row="12" data-col="1" data-sizex="8" data-sizey="3">
      <MT:MTFilterGrid ID="PaymentGrid" runat="server" TemplateFileName="AccountPaymentSummary.xml" ExtensionName="Account" ></MT:MTFilterGrid>
    </div>--%>
    <div style="width: 99.4%; margin-left: 0;" >
    <div class="widget" data-row="15" data-col="1" data-sizex="8" data-sizey="3" >
	  <MT:MTPanel ID="pnlNowCast" runat="server" Text="NowCast">
        <div id="NowCast-body" ></div>
      </MT:MTPanel>
    </div>
    </div>

  <%--  <MT:MTFilterGrid ID="PaymentGrid" runat="server" TemplateFileName="AccountPaymentTransactionList.xml"
      ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
      DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
      ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
      FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
      MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
      TotalProperty="TotalRows">
    </MT:MTFilterGrid>
  --%>

  <%--
    <MT:MTFilterGrid ID="PaysFor" runat="server" TemplateFileName="AccountPaymentTransactionList.xml"
      ExtensionName="Account" ButtonAlignment="Center" Buttons="None" DefaultSortDirection="Ascending"
      DisplayCount="True" EnableColumnConfig="True" EnableFilterConfig="True" Expandable="False"
      ExpansionCssClass="" Exportable="False" FilterColumnWidth="350" FilterInputWidth="220"
      FilterLabelWidth="75" FilterPanelCollapsed="False" FilterPanelLayout="MultiColumn"
      MultiSelect="False" PageSize="10" Resizable="True" RootElement="Items" SearchOnLoad="True" SelectionModel="Standard"
      TotalProperty="TotalRows">
    </MT:MTFilterGrid>--%>
  
  <MT:MTDataBinder ID="MTDataBinder1" runat="server">
    <DataBindingItems>
      <MT:MTDataBindingItem runat="server" ControlId="lblErrorMessage" ErrorMessageLocation="RedTextAndIconBelow">
      </MT:MTDataBindingItem>
    </DataBindingItems>
  </MT:MTDataBinder>
  </div>
  <script type="text/javascript">

    //MOVE THIS TO GENERIC FUNCTION HANDLER TO BE INCLUDED
    // Subscription Grid Event handlers
    function onAddRegularSubscription_<%=SubscriptionSummaryGrid.ClientID %>()
    {
      document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=SubscriptionsWorkflow&StartWithStep=AddStep"; 
    }
    
    function onAddAccountToGroupSubscription_<%=SubscriptionSummaryGrid.ClientID %>()
    {
      document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=GroupSubscriptionsWorkflow&StartWithStepGr=JoinStep";
    }


    function subscriptiontypeColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var localizedSubscriptionTypeText = "";
      if (value.toLowerCase() == "subscription") {
        localizedSubscriptionTypeText = '<%=GetLocalResourceObject("SUBSCRIPTION_TYPE_TEXT") %>';
      } else {
        localizedSubscriptionTypeText = '<%=GetLocalResourceObject("GROUP_SUBSCRIPTION_TYPE_TEXT") %>';
      }
      return String.format("<span style='display:inline-block; vertical-align:middle'><img src='/Res/Images/icons/ProductCatalog_{0}.png' title='{1}' align='middle'/></span>", record.data.subscriptiontype, localizedSubscriptionTypeText);
    }


    function subscriptionInformationColRenderer(value, meta, record, rowIndex, colIndex, store) {
      meta.attr = 'style="white-space:normal"';
      var str = "";
  
      if (record.data.subscriptiontype.toLowerCase() === 'subscription') {
        str = String.format("<a href='JavaScript:editSubscription({0});' class='ItemName'>{1}</a><br/><span class='ItemDescription'>{2}</span>", record.json.subscriptionid, record.json.productofferingname, (record.json.productofferingdescription || ''));
      } else {
        str = String.format("<span class='ItemName'>{0}</span><br/><span class='ItemDescription'>{1}</span><br /><br /><span class='ItemName'>{2}</span><br/><span class='ItemDescription'>{3}</span>", record.data.productofferingname, (record.json.productofferingdescription || ''), (record.json.groupsubscriptionname  || ''), (record.json.groupsubscriptiondescription || ''));
        //null AS 'GroupSubscriptionDescription')
      }
  
      return str;
    }
    
    function editSubscription(n) {
      if (checkButtonClickCount() == true) {
        document.location.href = "/MetraNet/StartWorkFlow.aspx?WorkflowName=SubscriptionsWorkflow&StartWithStep=" + n; 
      }
    }

    // Custom Renderers
    OverrideRenderer_<%= SubscriptionSummaryGrid.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('subscriptiontype'), subscriptiontypeColRenderer);
      cm.setRenderer(cm.getIndexById('productofferingname'), subscriptionInformationColRenderer);
    };
    
    function itemtypeColRenderer(value, meta, record, rowIndex, colIndex, store) {
      var localizedItemTypeText = "";
      if (value.toLowerCase() == "invoice") {
        localizedItemTypeText = '<%=GetLocalResourceObject("INVOICE_ITEM_TEXT") %>';
      } else {
        localizedItemTypeText = '<%=GetLocalResourceObject("PAYMENT_ITEM_TEXT") %>';
      }
      return String.format("<span style='display:inline-block; vertical-align:middle'>{0}</span>", localizedItemTypeText);
    }
        
    OverrideRenderer_<%= BillingSummaryGrid.ClientID %> = function(cm)
    {  
      cm.setRenderer(cm.getIndexById('nm_type'), itemtypeColRenderer);
    };
    
//    function onCancel_<%= SubscriptionSummaryGrid.ClientID %>()
//    {
//      //pageNav.Execute("GroupSubscriptionsEvents_Back_ManageGroupSubscriptions_Client", null, null);
//    }

//    function edit(n)
//    {
//      var args = "GroupSubscriptionId=" + n;
//      //pageNav.Execute("GroupSubscriptionsEvents_Edit_Client", args, null);            
//    }

//    function rates(n)
//    {
//      var args = "GroupSubscriptionId=" + n;
//      document.location.href = "/MetraNet/TicketToMAM.aspx?URL=/mam/default/dialog/DefaultDialogRates.asp|id_group=" + n + "**LinkColumnMode=TRUE**NewMetraCare=TRUE";          
//    }
//    
//    function members(n)
//    {   
//      var args = "GroupSubscriptionId=" + n;         
//      pageNav.Execute("GroupSubscriptionsEvents_Members_Client", args, null);
//    }
//       
//    function deleteGroupSub(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("GroupSubscriptionsEvents_Delete_Client", args, null);
//    }
//    
//    function unsubscribeFromGroupSub(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("", args, null);
//    }   
//      
//    function removeGroupSubMembership(n)
//    {
//      var args = "GroupSubscriptionId=" + n;      
//      pageNav.Execute("", args, null);
//    }    
//            
//    function onAdd_<%=SubscriptionSummaryGrid.ClientID %>()
//    {
//      pageNav.Execute("GroupSubscriptionsEvents_Add_Client", null, null);
//    }
//     function onJoin_<%=SubscriptionSummaryGrid.ClientID %>()
//    {
//      pageNav.Execute("GroupSubscriptionsEvents_JoinGroupSubscription_Client", null, null);
//    }
//    
//    
//    optionsColRenderer = function(value, meta, record, rowIndex, colIndex, store)
//    {
//      var str = "";      
//          
//      // Edit Link
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {     
//         if(<%=IsCorporate.ToString().ToLower() %>)
//         {
//                //str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
//                str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
//         } 
//      }


//     str += String.format("&nbsp;<a style='cursor:hand;' id='Edit' href='javascript:edit({0});'><img src='/Res/Images/icons/table_edit.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_EDIT_GRPSUB);                
//      
//        // Rates button
//      str += String.format("&nbsp;<a style='cursor:hand;' id='rates' href='javascript:rates({0})'><img src='/Res/Images/icons/money.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_RATES);
//      

//      // Members button
//      if(<%= UI.CoarseCheckCapability("Modify groupsub membership").ToString().ToLower() %>)
//      {
//        str += String.format("&nbsp;<a style='cursor:hand;' id='members' href='javascript:members({0})'><img src='/Res/Images/icons/group_add.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_MEMBERS);
//      }
//      
//      // Delete button
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {
//        if(<%=IsCorporate.ToString().ToLower() %>)
//        {
//          str += String.format("&nbsp;<a style='cursor:hand;' id='delete' href='javascript:deleteGroupSub({0})'><img src='/Res/Images/icons/cross.png' title='{1}' alt='{1}'/></a>", record.data.GroupId, TEXT_DELETE);
//        }
//      }      
//       

//      return str;
//    };    

//    EditLinkRenderer = function(value, meta, record, rowIndex, colIndex, store)
//    {
//      var str = "";
//      
//      // Edit Link
//      if(<%= UI.CoarseCheckCapability("Update group subscriptions").ToString().ToLower() %>)
//      {     
//         if(<%=IsCorporate.ToString().ToLower() %>)
//         {
//                str += String.format("<a href='JavaScript:edit({0});'>{1}</a>", record.data.GroupId, value);
//         }
//         else
//         {
//            str += value;
//         }  
//      }
//      
//      
//      return str;
//    };
    

    function adjustHeights(elem) {
      var fontstep = 2;
      if ($(elem).height()>($(elem).parent().height() - 30) || $(elem)[0].scrollWidth>$(elem).parent().width()) {
        $(elem).css('font-size',(($(elem).css('font-size').substr(0,2)-fontstep)) + 'px').css('line-height',(($(elem).css('font-size').substr(0,2))) + 'px');
        adjustHeights(elem);
      }
    }
  
    function resize_to_fit(){
      var children = document.getElementById('AccountStatus').children;
      adjustHeights(children[1]);
    }
    
    Ext.onReady(function() {
      displayAccountStatusInformation();
      displayBalanceInformation();
      displayFailedTransactionCount(<% =int.Parse(UI.Subscriber["_AccountID"]) %>);
      displayBillingActivityAndMRR(<%=ShowFinancialData.ToString().ToLower()%>);
      resize_to_fit();
    });
    
   
  </script>
  

  <%-- script used for NowCast widget  --%>
      <script>

      function populateDatePicker(id) {
        clearDatePickers();
        var dp = document.getElementById(id);
        var old = dp.innerHTML;
        dp.innerHTML = "";
        var div = d3.select("#" + id);
        div.on("click", null);
        div.style("overflow-y", "auto");
        div.style("overflow-x", "visible");
        var ul = div.append("ul").style("margin-left", "0px").style("margin-right", "10px").style("padding-left", "0px");
        ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button.png) left center no-repeat").attr("datepickerid", id).attr("interval", div.attr("interval")).attr("title", "Interval " + div.attr("interval")).attr("selected", "true").on("click", function () { var ul = d3.select(this); /*console.log("" + ul.text() + " " + ul.attr("datepickerid"));*/document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).style("overflow", "hidden").attr("title", "Interval " + ul.attr("interval")).attr("interval", ul.attr("interval")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text(old);
        //    ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button_uncheck.png) left center no-repeat").attr("datepickerid", id).attr("interval", 90133432).attr("title", "Interval 90133432").on("click", function () { var ul = d3.select(this); console.log("" + ul.text() + " " + ul.attr("datepickerid")); document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text("February 28, 2012 - February 27, 2013");
        d3.event.preventDefault();
      }

      function selectDatePicker() {
      }

      function clearDatePickers() {
        d3.selectAll(".datepicker").each(function (d, i) {
          var div = d3.select(this);
          var ul = div.select("ul");
          if (!ul.empty()) {
            var sel = ul.select("li[selected='true']");
            if (!sel.empty()) {
              var txt = sel.text();
              div.text(txt).attr("title", "Interval 97773432").style("right", "0px").style("text-anchor", "end");
              div.style("overflow", "hidden");
            }
            div.on("click", function () { populateDatePicker(div.attr("id")); });
          }
        });

      }

      Ext.onReady(function () {

        var margin = { top: 25, right: 55, bottom: 20, left: 25 },
        width = document.getElementById("NowCast-body").clientWidth - margin.left - margin.right,
        height = 70 - margin.top - margin.bottom;

        var chart = d3.bullet()
          .width(width)
          .height(height);

        d3.json("/MetraNet/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function (error, data) {
          var svg = d3.select("#NowCast-body").selectAll("svg")
            .data(data)
            .enter().append("svg")
            .attr("class", "bullet")
            .attr("width", "100%")
            .attr("height", height + margin.top + margin.bottom + 35);
          svg.style("background-color", "white");
          svg.style("margin-bottom", "5px");
          svg.append("rect").attr("width", width + margin.right - 10).attr("height", height + margin.top + margin.bottom + 30).attr("fill", "white").attr("fill-opacity", 0);
          svg.on("contextmenu", function (d, i) {
            d3.selectAll(".bullet .contextmenu").attr("display", "none");
            var cm = d3.select("#contextmenu" + 0)
                .style("display", "block")
                .style("left", d3.event.pageX + "px")
                .style("top", d3.event.pageY - 60 + "px");
            d3.event.preventDefault();
            return false;
          });

          svg = svg.append("g")
            .attr("transform", "translate(" + margin.left + "," + (margin.top + 30) + ")")
            .call(chart);

          var title = svg.append("g")
            .attr("transform", "translate(-6," + 1.35 * -height + ")");

          title.append("text")
            .attr("class", "title")
            .attr("dx", "0.5em")
            .attr("dy", "-0.3em")
            .text(function (d) { return d.title; });

          title.append("text")
            .attr("class", "subtitle")
            .attr("dx", "0.8em")
            .attr("dy", "1em")
            .text(function (d) { return d.subtitle; });

          //title.append("text")
          //  .attr("class", "notice")
          //  .attr("x", width + margin.left)
          //  .attr("y", 3.4 * height)
          //  .attr("text-anchor", "end")
          //  .text("TEXT_NOWCAST_RIGHT_CLICK_FOR_OPTIONS");

          var svgd = svg.data();
          if ((typeof svgd === 'undefined') || svgd === undefined || svgd == null || svgd.length == 0) {
            d3.select("#NowCast-body").append("text").text('<%=NoDecisionsText%>').style("color", "gray");
            return;
          }

          var cnt = 0;
          if (title != null && title.length > 0) {
            cnt = title[0].length;
          }
          title.each(function (d, i) {
            var bdy = document.getElementById("NowCast-body");
            var rect = bdy.getBoundingClientRect();
            var span = d3.select("#NowCast-body").append("span").style("position", "relative");
            span.style("top", -((cnt * 100) + 11) + "px");
            span.style("right", "+40px");
            var button = span.append("div");
            button.attr("class", "datepicker").style("white-space", "nowrap").style("display", "inline-block").attr("id", "datepicker" + i).style("width", "auto").style("position", "absolute").style("background-color", "#fff").style("border", "dotted").style("border-width", "1px").style("border-color", "#aaa").style("padding", "0px").style("padding-left", "2px").style("padding-right", "2px").style("margin", "0px");
            if (i == 0) {
              //        button.style("top", -((cnt * 100) + 41) + "px"); //.style("right", "-300px");
              button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
            } else {
              button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
            }
            button.attr("interval", d.intervalId);
            button.text(d.datesLabel).attr("title", "Interval " + d.intervalId).style("right", "0px").style("text-anchor", "end");
            span.on("contextmenu", function (d, i) {
              d3.selectAll(".bullet .contextmenu").attr("display", "none");
              var cm = d3.select("#contextmenu" + 0)
                .style("display", "block")
                .style("left", d3.event.pageX + "px")
                .style("top", d3.event.pageY + "px");
              d3.event.preventDefault();
              return false;
            });
          });

          d3.selectAll(".datepicker").on("click", function (d, i) {
            populateDatePicker("datepicker" + i);
          });

          var divs = d3.select("#NowCast-body").append("div").attr("id", function (d, i) { return "contextmenu" + i; }).attr("class", "contextmenu").style("display", "none").style("top", "150px").style("left", "400px").style("position", "absolute").style("background-color", "#fff").style("border", "solid").style("border-width", "3px").style("padding", "2px");
          var ul = divs.append("ul").attr("class", "contextmenulist").style("margin-left", "0px").style("padding-left", "0px");
          //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_yes.png) left center no-repeat").text("Include Previous Results");
          //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_no.png) left center no-repeat").text("Include Projected Results");
          //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_redo.png) left center no-repeat").text("Redraw").on('click', function () { console.log("redraw"); svg.call(chart); });
          //ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_refresh_small.png) left center no-repeat").text(TEXT_NOWCAST_REFRESH).on('click', function () {
          //  d3.json("/MetraNet/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function (error, data) {
          //    var svg = d3.select("#NowCast-body").selectAll("svg")
          //      .data(data);
          //    svg.call(chart);
          //  });
          //});

          d3.select("body").on('click', function (d, i) {
            d3.selectAll(".contextmenu").style("display", "none");
            d3.selectAll(".bullet .tbutton").attr("height", 13);
          });
          d3.select("body").on('contextmenu', function (d, i) { clearDatePickers(); });
          //    d3.selectAll("button").on("click", function () {
          //      svg.datum(randomize).call(chart.duration(1000)); // TODO automatic transition
          //    });
        });
      });
    </script>

</asp:Content>
