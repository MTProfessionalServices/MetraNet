////////////////////////////////////////////////////////////////////
// Client Side Workflow interactions
// PageNav: Register, UnRegister, Execute
////////////////////////////////////////////////////////////////////

// Use this counter to prevent user from double clicking on buttons that result in pageNav calls getting called multiple times resulting in  
// HTTP 500 errors when the same event is enqueued multiple times
var buttonClickCount;

Ext.onReady(function () {
  buttonClickCount = 0;
});

function incrementButtonClickCount() {
  buttonClickCount += 1;
}

function resetButtonClickCount() {
  buttonClickCount = 0;
}

// Use this function to ensure that only one button click gets executed on the page
function checkButtonClickCount() {
  incrementButtonClickCount();
  if (buttonClickCount <= 1)
    return true;
  else
    return false;
};

var pageNav;

function PageNav(){
    this.mState = "";
    this.mProcessorId = "";
    this.mInterfaceName = "";
        
    this.Init = function(state, processorId, interfaceName)
    {
      this.mState = state;
      this.mProcessorId = processorId;
      this.mInterfaceName = interfaceName;
    }

    // Here we actually use server side state to keep track of if we have been
    // to this workflow state before.
    // Check if we need to register a new state
    this.CheckIfNewState = function() {
      if ((this.mState == "") && (this.mInterfaceName == "")) {
        flagOkLoadStore = "true";
      }
       
      ServerState.get(this.mState, this.RegisterNewStateCallback);
    } 
    
    this.SetIsNewState = function(val)
    {
      ServerState.set(this.mState, val);
    }
    
    // Register client side state with backed workflow.
    // This keeps the client in sync. with the backend even if the back or forward
    // buttons on the browser are clicked.
    this.RegisterNewStateCallback = function (options, success, response) {
      if (success) {
        if (response.responseText == "true") {
          // Call Server Register via AJAX, pageNav is initialized in the master page
          pageNav.ServerRegister();
          pageNav.SetIsNewState("false");
        }
        else {
          flagOkLoadStore = "true";
        }
      }
      else {
        // OK to load grid
        //Ext.UI.msg("Error Getting State", "Error getting " + this.mState);
      }

    }
    
    // Unregister state
    this.UnRegister = function () {     
      this.SetIsNewState("true");   
    }

    // ServerRegister - calls back to the server to set the current wf state
    this.ServerRegister = function()
    {
      var parameters = {State: this.mState, ProcessorID: this.mProcessorId, InterfaceName : this.mInterfaceName}; 

      // make the call back to the server
      Ext.Ajax.request({
          url: '/MetraNet/AjaxServices/RegisterState.aspx',
          params: parameters,
          scope: this,
          disableCaching: true,
          callback: function(options, success, response) {
            if (success) {
              if(response.responseText == "OK") {
                // everything is good
                // OK to load grid
                flagOkLoadStore = "true";
              }
              else if(response.responseText=="FAILED") {
                //document.location.href = "/MetraNet/Welcome.aspx";
              }      
              else
              {
                //document.location.href = "/MetraNet/Login.aspx";
              }
            }
          }
       });
    }
      
    // Executes similar to the PageNav execute, but from the client.
    // It will fire the event into the WF and navigate to a new page if required.
    this.Execute = function (operation, args, callbackMethod) {
      var parameters = { State: this.mState,
        ProcessorID: this.mProcessorId,
        Operation: operation,
        Args: args
      };

      // make the call back to the server
      Ext.Ajax.request({
        url: '/MetraNet/AjaxServices/PageNav.aspx',
        params: parameters,
        scope: this,
        disableCaching: true,
        callback: function (options, success, response) {
          if (success) {
            try {
              var responseObject = getFrameMetraNet().Ext.util.JSON.decode(response.responseText);
              //{"In_AccountId":129,"In_ContactType":0,"InOut_ProcessorInstanceId":"92a2b8ce-06e0-45d3-bc34-695009ebb557",
              //"Out_StateInitData":{"PageName":"/MetraNet/Account/ContactUpdate.aspx","PageInstanceId":"0b96e488-e9de-470c-b82e-83990bb262cd"},
              //"Out_ErrorText":null}
              if (responseObject.Out_ErrorText == null) {

                // If we have a URL we navigate to it
                if (responseObject.Out_StateInitData != null) {
                  if (responseObject.Out_StateInitData.PageName != null) {
                    if (responseObject.Out_StateInitData.PageName.length > 0) {
                      var url = getFrameMetraNet().String.format("{0}?State={1}", responseObject.Out_StateInitData.PageName, responseObject.Out_StateInitData.PageInstanceId);
                      document.location.href = url;
                      return;
                    }
                  }
                }

                // If we have a valid callback method, time to call it
                if (callbackMethod) {
                  resetButtonClickCount();
                  callbackMethod(responseObject);
                }

              }
              else {
                resetButtonClickCount();
                getFrameMetraNet().Ext.UI.SystemError(responseObject.Out_ErrorText);
              }
            }
            catch (e) {
              resetButtonClickCount();
              getFrameMetraNet().Ext.UI.SystemError(e.message);
            }
          }
          else {
            // Failure
            try {
              resetButtonClickCount();
              var responseObject = getFrameMetraNet().Ext.util.JSON.decode(response.responseText);

              if (responseObject.Out_ErrorText != null) {
                getFrameMetraNet().Ext.UI.SystemError(responseObject.Out_ErrorText);
              }
              else {
                getFrameMetraNet().Ext.UI.SystemError("Unknown communication error");
              }
            }
            catch (e) {
              resetButtonClickCount();
              getFrameMetraNet().Ext.UI.SystemError(e.message);
            }
          }
        }
      });
    }

}
