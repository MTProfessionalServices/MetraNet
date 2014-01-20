/////////////////////////////////////////////////////////////////////////////////////
// JavaScript used by the AMP Wizard.
/////////////////////////////////////////////////////////////////////////////////////


// This method is called by OnClientClick on some pages.
// (The assignment cannot be made directly in OnClientClick
// because of scoping strangeness.)
function setLocationHref(target) {
  if (target == 'Start.aspx') {
    // Escape the iframe.
    parent.location.href = target;
  }
  else {
    document.location.href = target;
  }
}

// Step through each tree link and disable each tree link. Select the first link in the list of tree links.
function disableTreeLinks(elementId) {
  var frame = getFrameMetraNet().MainContentIframe;
  if (frame != null) {
    var treeviewElem = frame.document.getElementById(elementId);
    if (treeviewElem != null) {
      var atagList = treeviewElem.getElementsByTagName("a");
      for (var n = 0; n < atagList.length; n++) {
        // change the href for each html <a> tag by appending a # character followed by the id for the element so that 
        // the href is no longer valid and the <a> tag will no longer be rendered as clickable.
        var currHREF = atagList[n].href;
        atagList[n].href = currHREF + "#" + atagList[n].id;
        atagList[n].style.cursor = "text";
        atagList[n].onclick = function () {
          return false;
        };
        
        if (n == 0) {
          frame.TreeView_SelectNode(frame.ctl00_ContentPlaceHolder1_TreeView1_Data, atagList[n], atagList[n].id.toString());
        } else {
          atagList[n].style.color = "grey";
          atagList[n].style.textDecoration = "none";
        }
      }
    }
  }
}

// Step through each tree link and enable each tree link. This function undoes what the disableTreeLinks function does.
function enableTreeLinks(elementId) {
  var frame = getFrameMetraNet().MainContentIframe;
  if (frame != null) {
    var treeviewElem = frame.document.getElementById(elementId);
    if (treeviewElem != null) {
      var atagList = treeviewElem.getElementsByTagName("a");
      for (var n = 0; n < atagList.length; n++) {
        // reset the <a> tag's href to its original value in the case that disableTreeLinks() funciton previously appended
        // a # character plus the id to the href so that the href is valid again.
        var currHREF = atagList[n].href;
        var pieces = currHREF.split("#");
        var origHREF = pieces[0];
        atagList[n].href = origHREF;
        // remove any style that may have been added to the <a> tag by the disableTreeLinks() function
        atagList[n].removeAttribute("style");
      }
    }
  }
}

// Highlights the node in the navigation panel that corresponds to the specified page.
function updateNavPanel(pageName) {
  var frame = getFrameMetraNet().MainContentIframe;
  if (frame != null) {    
    // Update header if just created a new decision.
    var decisionNameElem = frame.document.getElementById("ctl00_ContentPlaceHolder1_lblDecisionName");
    if (decisionNameElem != null) {
      // textContent works on Firefox, but not IE.  innerHTML works on both.
      if (decisionNameElem.innerHTML.length == 0) {
        if (ampDecisionName.length > 0) {
          decisionNameElem.innerHTML = '\'' + ampDecisionName + '\'';
          // enable the navigation when we have an ampDecisionName
          enableTreeLinks("ctl00_ContentPlaceHolder1_TreeView1");
        } else {
          // for the general information page, disable the navigation if we are in Create mode so that user has to enter a name 
          // for the new Decision Type before going to another step in the wizard.
          if (pageName != null && pageName == 'GeneralInformation.aspx') {
            disableTreeLinks("ctl00_ContentPlaceHolder1_TreeView1");
          }
        }
      }
    }
    
    var treeviewElem = frame.document.getElementById("ctl00_ContentPlaceHolder1_TreeView1");
    if (treeviewElem != null) {
      // First look for a match among the clickable nodes in the treeview.
      var atagList = treeviewElem.getElementsByTagName("a");
      for (var n = 0; n < atagList.length; n++) {
        var url = atagList[n].getAttribute('href');
        var pieces = url.split("/");
        var filename = pieces[pieces.length - 1];
        if (filename === pageName) {
          frame.TreeView_SelectNode(frame.ctl00_ContentPlaceHolder1_TreeView1_Data, atagList[n], atagList[n].id.toString());
          return;
        }
      }
      // Next check the nonclickable nodes in the treeview.
      // (See the explanation in NavigationPanelInit.aspx, onReady() function.)
      var spanList = treeviewElem.getElementsByTagName("span");
      for (var n = 0; n < spanList.length; n++) {
        var url = spanList[n].getAttribute('data');
        if (url === pageName) {
          frame.TreeView_SelectNode(frame.ctl00_ContentPlaceHolder1_TreeView1_Data, spanList[n], spanList[n].id.toString());
          return;
        }
      }
    }
  } // if (frame != null)
}

//Function for showing "More", "Help" windows
function displayInfo(infoTitle, infoMessage, width, height) {

  var moreInfoHelpWindow = new Ext.Window({
    title: infoTitle,
    id: 'moreInfoHelpWindow',
    width: width,
    height: height,
    minWidth: 300,
    minHeight: 200,
    layout: 'fit',
    plain: true,
    bodyStyle: 'padding:5px;',
    buttonAlign: 'center',
    collapsible: false,
    resizeable: true,
    maximizable: false,
    closable: true,
    closeAction: 'close',
    html: '<p>' + infoMessage + '</p>'
  });
  moreInfoHelpWindow.show();
}

// Function for showing "More", "Info"multiple windows 
function displayInfoMultiple(moreInfoTitle, moreInfoMessage, width, height) {
  var moreInfoHelpWindow = new Ext.Window({
    title: moreInfoTitle,
    width: width,
    height: height,
    minWidth: 300,
    minHeight: 200,
    layout: 'fit',
    plain: true,
    bodyStyle: 'padding:5px;',
    buttonAlign: 'center',
    collapsible: false,
    resizeable: true,
    maximizable: false,
    closable: true,
    closeAction: 'close',
    cascadeOnFirstShow: true,
    html: '<p>' + moreInfoMessage + '</p>',
    beforeShow: function () {
      delete this.el.lastXY;
      delete this.el.lastLT;
      if (this.x === undefined || this.y === undefined) {
        var xy = this.el.getAlignToXY(this.container, 'c-c');
        var pos = this.el.translatePoints(xy[0], xy[1]);
        this.x = this.x === undefined ? pos.left : this.x;
        this.y = this.y === undefined ? pos.top : this.y;
        if (this.cascadeOnFirstShow) {
          var prev;
          this.manager.each(function (w) {
            if (w == this) {
              if (prev) {
                var p = prev.getPosition();
                this.x = p[0] + 20;
                this.y = p[1] + 20;
              }
              return false;
            }
            if (w.isVisible()) prev = w;
          }, this);
        }
      }

      this.el.setLeftTop(this.x, this.y);

      if (this.expandOnShow) {
        this.expand(false);
      }

      if (this.modal) {
        Ext.getBody().addClass("x-body-masked");
        this.mask.setSize(Ext.lib.Dom.getViewWidth(true), Ext.lib.Dom.getViewHeight(true));
        this.mask.show();
      }
    }
  });
  moreInfoHelpWindow.show();
}




// When a page of the AMP Wizard is loaded, highlight it on the navigation panel.
Ext.onReady(function () {
  updateNavPanel(ampCurrentPage);
});
