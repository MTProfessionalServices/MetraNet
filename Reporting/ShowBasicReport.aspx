<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPages/PageExt.master" AutoEventWireup="true" CodeFile="ShowBasicReport.aspx.cs" Inherits="ShowBasicReport" meta:resourcekey="PageResource1" Culture="auto" UICulture="auto" %>

<%@ Register assembly="MetraTech.UI.Controls" namespace="MetraTech.UI.Controls" tagprefix="MT" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" Runat="Server">
 <style>
.mtpanel-inner {
width:100%;
margin-right:20px;
}
 </style>
 
  <div id="mydiv2" height="100%">
  </div>
	
	<script type="text/javascript">
AutoGridView = Ext.extend(
    Ext.grid.GridView,
    {
        fixOverflow: function() {
            if (this.grid.autoHeight === true || this.autoHeight === true){
                Ext.get(this.innerHd).setStyle("float", "none");
                this.scroller.setStyle("overflow-x", this.scroller.getWidth() < this.mainBody.getWidth() ? "scroll" : "auto");
            }
        },
        layout: function () {
            AutoGridView.superclass.layout.call(this);
            this.fixOverflow();
        },
        render: function(){
            AutoGridView.superclass.render.apply(this, arguments);

            this.scroller.on('resize', this.fixOverflow, this);

            if (this.grid.autoHeight === true || this.autoHeight === true){
                this.grid.getStore().on('datachanged', function(){
                    if (this.ownerCt) { this.ownerCt.doLayout(); }
                }, this.grid, { delay: 10 });
            }
        }
    }
);
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
				title: 'Report: <%=reportName %>',
				autoHeight: true,
				view: new AutoGridView()
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
