
//Requires that browsercheck is included
///////////////////////////////////////////////////////////////////////////////////////////////////////////
 var bc = new BrowserCheck();  
 var n = bc.ns;
 var ie = bc.ie;
 
 var showing = '';
 var hiding = '';
 var layerRef = '';
 var styleSwitch = '';
 //////////////////////////////////////////////////////////////////////////////////////////////////////////// 
if(n) { 
  showing = "show";
	hiding  = "hide";
  layerRef="document.layers";
  styleSwitch="";
} else { 
  showing = "visible";
  hiding  = "hidden";
  layerRef="document.all";
  styleSwitch=".style";
}
  
///////////////////////////////////////////////////////////////////////////
// ShowDiv, show a hidden div.                                           //
///////////////////////////////////////////////////////////////////////////
function ShowDiv(strDiv)
{
  eval(layerRef + "." + strDiv + styleSwitch + '.visibility="' + showing + '"');
}
function HideDiv(strDiv)
{
  eval(layerRef + "." + strDiv + styleSwitch + '.visibility="' + hiding + '"');
}
///////////////////////////////////////////////////////////////////////////
// SizeDiv -- resize a div that contains a table, up to a maximum size.  //
///////////////////////////////////////////////////////////////////////////
function SizeDiv(strDiv, strTable, intSize) {
  var intHeight;
  var intWidth;
  
  intHeight = eval('document.all.' + strTable + '.scrollHeight;');
  intWidth = eval('document.all.' + strTable + '.scrollWidth;');      
  
  if(intHeight > intSize) {
    intHeight = intSize;
    
    intWidth = intWidth - 15;
    eval('document.all.' + strTable + '_Header.style.pixelWidth="' + intWidth + '";');
  }      
  eval('document.all.' + strDiv + '.style.pixelHeight="' + intHeight + '";');
}
