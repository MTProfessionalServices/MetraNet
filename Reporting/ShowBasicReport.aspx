<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ShowBasicReport.aspx.cs" Inherits="ShowBasicReport" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <style>
.mtpanel-inner {
width:100%;
margin-right:20px;
}
 </style>
 
  <div id="mydiv2">
  </div>
	
	<script type="text/javascript">
		var ds = new Ext.data.Store({
                url: '<%=queryUrl %>',
                reader: new Ext.data.JsonReader({
                }),
				baseParams:{urlparam_m:true,urlparam_q:'<%=queryParam %>'}
        });
		
        var grid = new Ext.grid.GridPanel({
                ds: ds,
                cm: new Ext.grid.ColumnModel([]),
				columns: [],
				flex: 1,
				viewConfig : {
					autoFit : true
				},
				title: 'Report: <%=queryName %>'
		});
        grid.render(Ext.Element.get('mydiv2'))
		Ext.EventManager.onWindowResize(function(){
			grid.setWidth(Ext.getBody().getWidth() - 20);
		});
        ds.on('metachange', function (store,meta) {
                var columns = [];
        
                for (var i = 0; i < meta.fields.length; i++ ) {
                        var hidden = meta.fields[i].hidden;
                        columns.push( { header: meta.fields[i].header, dataIndex: meta.fields[i].name, type: meta.fields[i].type, id: meta.fields[i].id, sortable: meta.fields[i].sortable } );
                }

                grid.reconfigure(store, new Ext.grid.ColumnModel(columns));
        });
		ds.load();
		</script>
</asp:Content>
