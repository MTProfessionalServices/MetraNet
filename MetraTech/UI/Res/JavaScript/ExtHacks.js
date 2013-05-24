Ext.ux.IFrameComponent = Ext.extend(Ext.BoxComponent, {
     onRender : function(ct, position){
          this.el = ct.createChild({tag: 'iframe', id: 'iframe-'+ this.id, frameBorder: 0, src: this.url});
     }
});

// used to set attributes in MetraView
Ext.override(Ext.Element, {
  setAttributeNS: function(ns, att, value) {
    if (this.dom.setAttributeNS) {
      this.dom.setAttributeNS(ns, att, value);
    } else if (this.dom.setAttribute) {
      this.dom.setAttribute(ns + ":" + att, value);
    }
  }
});

// HACK for IE fly error
// http://www.sencha.com/forum/showthread.php?19954-TabPanel-and-Ext.fly(...)-is-null-or-not-an-object-error
Ext.override(Ext.EventObjectImpl, {
  getTarget: function (selector, maxDepth, returnEl) {
    var targetElement;

    try {
      targetElement = selector ? Ext.fly(this.target).findParent(selector, maxDepth, returnEl) : this.target;
    } catch (e) {
      targetElement = this.target;
    }

    return targetElement;
  }
});

// IE Hack for menu flicker
Ext.override(Ext.menu.Item, {
  shouldDeactivate: function (e) {
    if (Ext.menu.Item.superclass.shouldDeactivate.call(this, e)) {
      if (Ext.isIE) {
        if (this.getEl().getRegion()[1] >= e.getPoint()[1] + 2 ||
this.getEl().getRegion()[1] + this.getEl().getSize().height < e.getPoint()[1]) {
          return true;
        };
        if (this.parentMenu.getPosition()[0] + 3 >= e.getPoint()[0] ||
this.parentMenu.getPosition()[0] + this.parentMenu.getWidth() - 4 <= e.getPoint()[0]) {
          return true;
        };
      } else {
        if (this.menu && this.menu.isVisible()) {
          return !this.menu.getEl().getRegion().contains(e.getPoint());
        };
        return true;
      };
    }
    return false;
  }
});

// ESR-4813 UI error when resubmitting failed transactions
var noNegatives = /width|height|opacity|padding/i;
Ext.lib.AnimBase.prototype.setAttr = function(attr, val, unit) {
    if ((noNegatives.test(attr) && val < 0) || (isNaN(val) && unit == 'px')) {
        val = 0;
    }
    Ext.fly(this.el, '_anim').setStyle(attr, val + unit);
};

// CORE-5117 Too small a field for "" (blank above "None") from Paper Invoice dropdown
// By default, ExtJS does not provide any special handling to display an empty string in the dropdown 
// list of a ComboBox. In HTML, an empty DIV element has no height. So, in the dropdown list, the "empty string" 
// option is displayed as a thin bar, almost unselectable.
// This override forces the empty string to be rendered as " " in Ext.form.Combobox.
// Got this HACK from http://snipplr.com/view/9122/
Ext.override(Ext.form.ComboBox, {
    initList: (function() {
        if(!this.tpl) {
            this.tpl = new Ext.XTemplate('<tpl for="."><div class="x-combo-list-item">{',  this.displayField , ':this.blank}</div></tpl>', {
                blank: function(value) {
                    return value==='' ? '&nbsp' : value;    
                }
            });
        }
    }).createSequence(Ext.form.ComboBox.prototype.initList)
});

//	CORE-5314
//	IE distort mapping of HTML-elements
Ext.override(Ext.layout.AnchorLayout, {
  getLayoutTargetSize : function() {
        var target = this.container.getLayoutTarget(), ret = {};
        if (target) {
            ret = target.getViewSize();

            
            
            
            if (Ext.isIE && Ext.isStrict && ret.width == 0){
                ret =  target.getStyleSize();
            }
        }
        return ret;
    }
});
