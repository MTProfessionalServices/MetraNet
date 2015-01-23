
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
	else if (this.ie) {
		var ua = navigator.userAgent;
		var re  = new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})");
		if (re.exec(ua) != null)
		  this.v= parseFloat( RegExp.$1 );
	}		
  	  
    this.min = (this.ns||this.ie)
  }


  function IsIE() {

	return ((navigator.appName == 'Microsoft Internet Explorer') || 
        ((navigator.appName == 'Netscape') && (new RegExp("Trident/.*rv:([0-9]{1,}[\.0-9]{0,})").exec(navigator.userAgent) != null)));
  }