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
//////////////////////////////////////////////////////////////////////////////
function BrowserCheck() {
  	var b = navigator.appName

   if(IsIE())this.b = "ie"
   else if(b=="Netscape")this.b = "ns"
   else this.b = b;

  	this.v = parseInt(navigator.appVersion)
  	this.ns = (this.b=="ns" && this.v>=4)
  	this.ns4 = (this.b=="ns" && this.v==4)
  	this.ns5 = (this.b=="ns" && this.v==5)
  	this.ie = (this.b=="ie" && this.v>=4)
  	this.ie4 = (navigator.userAgent.indexOf('MSIE 4')>0)
  	this.ie5 = (navigator.userAgent.indexOf('MSIE 5')>0)

  	if (this.ie5) this.v = 5
  	  this.min = (this.ns||this.ie)
	  
	  alert(this.b + ":" + this.v + ":" + this.min);
  }
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////

function IsIE() {

	return ((navigator.appName == 'Microsoft Internet Explorer') || 
        ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null)));
}