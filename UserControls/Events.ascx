<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Events" CodeFile="Events.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="ddLanguage" %>

  <script type="text/javascript" language="javascript" >

   var myDataStringLast = "";
   
   function uiEvents() {

    // heartBeatToMAM - keeps the ticketed session to MAM from timing out.
    //////////////////////////////////////
    this.heartBeatToMAM = function() {
      var req = Ext.Ajax.request({
          url: "/MAM/heartbeat.asp",
          method: 'GET',
          disableCaching: false,
          success: function() { setTimeout("events.heartBeatToMAM()", 600000); } //10 min.
          })
    }
    
    //////////////////////////////////////
    this.init = function() {
      var req = Ext.Ajax.request({
          url: "/MetraNet/AjaxServices/GetEvents.aspx",
          method: 'GET',
          disableCaching: false,
          success: this.process
          })
    }
       
    //////////////////////////////////////   
    this.process = function(result, request) {
      // Uncomment to view JSON       
      //Ext.UI.msg(result.responseText);  
      var messages = "";
      
      try
      {
			  messages = Ext.util.JSON.decode(result.responseText);
			  //Ext.UI.msg('Success', 'Decode of JSON OK');
		  }
		  catch (err) 
		  {
		    setTimeout("events.init()", 10000);
		    return;
		  	//Ext.UI.msg('ERROR', 'Could not decode ' + result.responseText);
		  }

      if(messages == null || messages == "[]" || messages == "")
      {
        setTimeout("events.init()", 10000);
        return;
      }
      
      var myDataString = "["
      for (i=0; i < messages.length; ++i) 
      {
        
        // PROCESS EVENT MESSAGES
        switch(messages[i].MessageID)
        {
          case "TIME_MESSAGE": // for testing
            if(messages[i].Bubbled == 0)
            {
              //Ext.UI.msg("Time:", messages[i].CurrentTime);
            }
            if(myDataString.length != 1)
            {
              myDataString += ",";
            }
            myDataString += "['" + "Time" + "','" + messages[i].CurrentTime  + "']";
            break;

          case "INFO_MESSAGE":
            if(messages[i].Bubbled == 0) // only show bubble message once
            {
              //Ext.UI.msg(messages[i].Label, messages[i].Info);
            }
            
            if(myDataString.length != 1)
            {
              myDataString += ",";
            }
            myDataString += "['" + messages[i].EventTime + "','" + messages[i].Label + "','" + messages[i].Info  + "']";
            break;
                    
          default:
            break;
        }
        
      } 
      myDataString += "]";
        
      if((myDataStringLast != myDataString) && 
         (myDataString != "[]"))
      {
        events.gridInit(Ext.util.JSON.decode(myDataString));
      }
      myDataStringLast = myDataString;
      
      setTimeout("events.init()", 10000);
    }

    //////////////////////////////////////
    this.gridInit = function(myData){

      var ds = new Ext.data.Store({
          proxy: new Ext.data.MemoryProxy(myData),
          reader: new Ext.data.ArrayReader({}, [
                     {name: 'eventTime'},
                     {name: 'event'},
                     {name: 'message'}
                ])
      });
      ds.setDefaultSort('eventTime', "DESC");
      ds.load();

	   	// the DefaultColumnModel expects this blob to define columns. It can be extended to provide
      // custom or reusable ColumnModels
      var colModel = new Ext.grid.ColumnModel([
        {id:'eventTime',header: "Event Time", sortable: true, locked:false, dataIndex: 'eventTime'},
			  {id:'event',header: "Event", sortable: true, locked:false, dataIndex: 'event'},
			  {header: "Message", sortable: true, dataIndex: 'message'}
		  ]);


      // create the Grid
     	var grid = new Ext.grid.GridPanel({
        id: 'statusGrid',
        ds: ds,
        cm: colModel,
				enableColLock: false,
				autoScroll: true, 
				height:150,
				loadMask: {msg:TEXT_LOADING},
			  viewConfig: {
            forceFit:true
        },
				el: 'grid-example' //,
				
				//bbar: new Ext.PagingToolbar({
        //  store: ds,
        //  pageSize: 3
        //})
			});
			grid.render();
			grid.doLayout();
      grid.getSelectionModel().selectFirstRow();
    }
};

// start event polling
var events = new uiEvents();
events.heartBeatToMAM();
setTimeout("events.init()", 10000);
 
  </script>    
  
<div id="grid-example" style="overflow:auto;"></div>
