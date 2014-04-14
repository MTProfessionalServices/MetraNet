<%@ Page Title="MetraNet" Language="C#" MasterPageFile="~/MasterPages/NoMenuPageExt.master"
  AutoEventWireup="true" Inherits="ReportsTree" CodeFile="ReportsTree.aspx.cs" %>
<%@ Import Namespace="MetraTech.UI.Tools" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT"
  TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="Server">
<head>
		<link rel="stylesheet" type="text/css" href="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/treegrid.css" rel="stylesheet" />
        <script type="text/javascript" src="js/Reports.js?v=0.17"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGridSorter.js"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGridColumnResizer.js"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGridNodeUI.js"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGridLoader.js"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGridColumns.js"></script>
        <script type="text/javascript" src="http://dev.sencha.com/deploy/ext-3.4.0/examples/ux/treegrid/TreeGrid.js"></script>
</head>
<body>
  <MT:MTTitle ID="MTTitle1" Text="Reports" runat="server" meta:resourcekey="MTTitle1Resource1" />
  <div id="treeDIV" style="width: 100%">
  </div>
  <div style="padding: 10px">
    <MT:MTLabel ID="LblcurrentEntityName" runat="server" Font-Bold="true" Font-Size="Medium" />
  </div>
  <a href="/MetraNet/BME/BEList.aspx?Name=MetraTech.Reporting.Reports.Report&Extension=MetraTech.Reporting&NewBreadcrumb=True&BMEGrid_TemplateFileName=MetraTech.Reporting.Reports.Report">Manage Reports</a>
		<script type="text/javascript">
    var referer ='<%=RefererUrl%>';
	
Ext.ux.CustomNodeTreeLoader = Ext.extend(Ext.ux.tree.TreeGridLoader, {
    processResponse:function(response, node, callback, scope) {
        var json = response.responseText;
        try {
            var o = response.responseData || Ext.decode(json);
             
            o = this.customLoad(o, node);
             
            node.beginUpdate();
            for(var i = 0, len = o.length; i < len; i++){
                var n = this.createNode(o[i]);
                if(n){
                    node.appendChild(n);
                }
            }
            node.endUpdate();
            this.runCallback(callback, scope || node, [node]);
        }catch(e){
            this.handleFailure(response);
        }
    },
     
    // This is the function that you need to override. Currently
    // it only gives the same functionality as Ext.tree.TreeLoader.
    customLoad:function(o, node) {
        return o;
    }
});
 
Ext.reg('customnodetreeloader', Ext.ux.CustomNodeTreeLoader);
	Ext.onReady(function() {
    Ext.QuickTips.init();

    var tree = new Ext.ux.tree.TreeGrid({
        renderTo: Ext.Element.get('treeDIV'),
        enableDD: true,
		width: 810,

        columns:[{
            header: 'Name',
            dataIndex: 'Name',
            width: 350,
            tpl: new Ext.Template('<a href="{thehref}" title="{Name}">{Name}</a>')
        },{
            header: 'Description',
            dataIndex: 'Description',
            width: 457,
            tpl: new Ext.Template('<a href="{thehref}" title="{Description}">{Description}</a>')
		}],
		loader:new Ext.ux.CustomNodeTreeLoader({
			dataUrl: '../AjaxServices/BEListSvc.aspx?Name=MetraTech.Reporting.Reports.Report&Assembly=MetraTech.Reporting.Reports.Entity&limit=10000',
			requestMethod:'POST',
			customLoad:function(data, node) {
				var categories = {};
				var nodes = [];
				var items = data.Items;
				Ext.each(items, function(item) {
					var category = item.Category;
					var subCategory = item.SubCategory;
					var name = item.Name;
					var description = item.Description;
					if (!description)
					{
						description = name;
					}
					var href = getCustomReportUrl(null, null, {'data':item}, null, null, null);
					if (href)
					{
						href = href.replace(/"/g, "'");
					}
					if (!category)
					{
						category = "Undefined";
					}
					if (!(category in categories))
					{
					  categories[category] = {'Name':category, 'expanded':false, 'Description':'', 'children':[], 'subs':{}};
					  nodes.push(categories[category]);
					}
					var cat = categories[category];
					if (subCategory)
					{
						if (!(subCategory in cat.subs))
						{
						  cat.subs[subCategory] = {'Name':subCategory, 'expanded':false, 'Description':'', 'children':[]};
						  cat.children.push(cat.subs[subCategory]);
						}
						cat.subs[subCategory].children.push({'leaf':true, 'Name':name, 'Description':description, 'thehref':href, 'href':href});
					}
					else
					{
					  cat.children.push({'leaf':true, 'Name':name, 'Description':description, 'thehref':href, 'href':href});
					}
				});
				return nodes;
			}
		})
    });
});

  </script>
</body>
</asp:Content>
