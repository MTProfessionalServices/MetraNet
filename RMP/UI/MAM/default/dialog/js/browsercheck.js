
  function BrowserCheck() {
  	var b = navigator.appName

  	if (b=="Netscape") this.b = "ns"
    	else if (b=="Microsoft Internet Explorer") this.b = "ie"
  	else 
      this.b = b

  	this.v = parseInt(navigator.appVersion)
  	this.ns = (this.b=="ns" && this.v>=4)
  	this.ns4 = (this.b=="ns" && this.v==4)
  	this.ns5 = (this.b=="ns" && this.v==5)
  	this.ie = (this.b=="ie" && this.v>=4)
  	this.ie4 = (navigator.userAgent.indexOf('MSIE 4')>0)
  	this.ie5 = (navigator.userAgent.indexOf('MSIE 5')>0)

  	if (this.ie5) this.v = 5
  	  this.min = (this.ns||this.ie)
  }

