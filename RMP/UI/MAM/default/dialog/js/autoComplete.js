// AutoComplete Form Field - based off of code from inside dhtml
//
// You need to include this script and populate your array like this:
// var sArray = new Array("hello","hello world","/MetraTech/","/MetraTech/Engineering/","/MetraTech/Engineering/Development/")
// Your form field should look like this:
//  <input id="autoComplete" onkeyup="update(this,sArray)" type="text" value="">
////////////////////////////////////////////////////////////////////////////////////////////
function find(x, xs) {
  var xl  = x.length, xsl = xs.length, sValue = ""

  for (var i=0; i < xsl; i++) {
    if (xs.tagName=="SELECT") // Lookup in select list
      sValue = xs[i].text
    else
      sValue = xs[i] // Lookup in array
    if (sValue.substring(0,xl).toLowerCase() == x.toLowerCase())
      return sValue;
  }
  return x;
} 

function update(src,selObject) {
	if (src.createTextRange) {
		// Ignore cursor keys
		var sKeys="8;46;37;38;39;40;33;34;35;36;45;46"
		if (sKeys.indexOf(event.keyCode+";")>-1) return
	
		// Value has changed - do lookup
		if (src.value!=src._value) {
			var r1 = src.createTextRange()
			newValue = find(src.value, selObject)
			if (newValue!=src.value) {
				src.value=newValue
				var rNew = src.createTextRange()
				r1.setEndPoint("StartToEnd",rNew)
				r1.select()
			}
		}
		src._value=src.value
	}
}
