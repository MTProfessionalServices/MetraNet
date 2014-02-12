//Loading.js
var strLoadingDiv          = 'divLoading';   //div with the loading text
var strLoadingClass        = 'clsLoading';  //class for the loading div
var strPageDiv             = 'divPage';     //div containing the actual page body
var strPageClass           = 'clsPage';     //class for the page div
var strColor               = 'white';       //default background color
var showing;                                //visible attribute value
var hiding;                                 //invisible attribute value
var layerRef;                               //layer reference name
var styleSwitch;                            //visibility style attribute
var bc = new BrowserCheck();                //browser check object
var n = bc.ns;
var ie = bc.ie;


//Set the browser specific values
if(n) { 
  showing = 'show';
  hiding  = 'hide';
  layerRef='document.layers';
  styleSwitch='';
  } 
	
  else { 
	  showing = 'visible';
	  hiding  = 'hidden';
    layerRef='document.all';
    styleSwitch='.style';
  }

  //Write the loading and page styles
	document.write('<style type="text/css">');
  
  if(n) {
    document.write('.' + strLoadingClass + '{position:absolute;background-color:white;left:0px;top:0px;visibility:' + hiding + ';z-index:100;}');
//   	document.write('.' + strPageClass + '{position:absolute;left:20px;top:20px;visibility:' +  showing+ ';z-index:101;}');
  } else {
    document.write('.' + strLoadingClass + '{position:absolute;background-color:' + strColor + ';width=100%;height=100%;left:0px;top:0px;visibility:' + showing + ';z-index:300;}');
 	  document.write('.' + strPageClass + '{position:absolute;left:20px;top:20px;visibility:' + hiding + ';z-index:101;}');
  }
  document.write('</style>');


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function ShowDiv(strName) {
  eval(layerRef + '.' + strName + styleSwitch + '.visibility="' + showing + '"');
//  alert('Showing: ' + strName);
 }
function HideDiv(strName) {
  eval(layerRef + '.' + strName + styleSwitch + '.visibility="' + hiding + '"');
//  alert('Hiding: ' + strName);
 }
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
function Loaded() {
  if(ie) {
    HideDiv(strLoadingDiv);
    ShowDiv(strPageDiv);
  }
}
//////////////////////////////////////////////////////////////////////////////

