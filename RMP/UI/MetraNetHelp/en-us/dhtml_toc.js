// Functions for TOC

function exp(id) {
  var mySrc=document.getElementById('p'+id).src;

  // check current display state
  if (mySrc.slice(mySrc.lastIndexOf('/')+1) == 'minus.gif') {
    collapse(id);
  } else{
    expand(id);
  }
}

function expand(id) {
  var myDoc= parent.TOC.document;

  with(myDoc.getElementById('s'+id)) {
    className='x';
    style.display=''; 
  }
  myDoc.getElementById('p'+id).src='minus.gif';
  myDoc.getElementById('b'+id).src='obook.gif';
}

function collapse(id) {
  with(document.getElementById('s'+id)) {
    className='x';
    style.display='none'; 
  }
  document.getElementById('p'+id).src='plus.gif';
  document.getElementById('b'+id).src='cbook.gif';
}

function highlight(id) {
  parent.TOC.document.getElementById('a'+id).focus();
}

function loadTOC() {
  // check current page displayed in TOC window.  If not toc.htm, load it.
  if (!isTOCLoaded()) {
    parent.TOC.location.href='toc.htm';
  }
}

function isTOCLoaded() {
  // return true, if toc.htm is loaded in TOC window.
  if (parent.TOC) {
    var myPath=parent.TOC.location.pathname;
    var myFile=myPath.substr(myPath.length-7);

    if (myFile == 'toc.htm') {
      return true;
    } else {
      return false; 
    }
  } else {
    return false;
  }
}

