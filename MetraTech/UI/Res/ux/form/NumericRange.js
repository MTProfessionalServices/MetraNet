Ext.namespace('Ext.ux');
Ext.ux.NumericRangeField = Ext.extend(Ext.form.Field, {
  defaultAutoCreate: { tag: 'input', type: 'hidden' }
    , dtSeparator: ' '
    , width: 220
    , isFormField: true
    , toText: TEXT_TO
    , startValue: ''
    , endValue: ''
    , allowBlank: true
    , initComponent: function() {
      Ext.ux.NumericRangeField.superclass.initComponent.call(this);

      var subCtrlWidth = this.width * .4;

      // create DateField
      var startValueConfig = Ext.apply({}, {
        id: this.id + '-start-value'
            , width: subCtrlWidth
            , allowBlank: this.allowBlank
            , listeners: {
              blur: { scope: this, fn: this.onBlur }
            }
      }, this.startValueConfig);
      this.start_value_ctl = new Ext.ux.form.LargeNumberField(startValueConfig);
      //delete(this.dateFormat);

      var endValueConfig = Ext.apply({}, {
        id: this.id + '-end-value'
          , width: subCtrlWidth
            , allowBlank: this.allowBlank
            , listeners: {
              blur: { scope: this, fn: this.onBlur }
            }
      }, this.endValueConfig);

      //initialize start date 
      if (this.startValue != null) {
        this.setStartValue(this.startValue);
      }

      this.end_value_ctl = new Ext.ux.form.LargeNumberField(endValueConfig);

      //initialize
      if (this.endValue != null) {
        this.setEndValue(this.endValue);
      }

      // relay events
      this.relayEvents(this.start_value_ctl, ['focus', 'change', 'specialkey', 'invalid', 'valid']);
      this.relayEvents(this.end_value_ctl, ['focus', 'change', 'specialkey', 'invalid', 'valid']);

    }


    , onRender: function(ct, position) {
      // render underlying field
      Ext.ux.NumericRangeField.superclass.onRender.call(this, ct, position);

      // render DateField and TimeField
      // create bounding table

      var ctlWidth = (this.width * 0.47) + '';
      var separatorWidth = this.width * 0.06;
      var t = Ext.DomHelper.append(ct, { tag: 'table', style: 'border-collapse:collapse', children: [
            { tag: 'tr', style: 'nowrap:true', children: [
                { tag: 'td', style: "padding-right:4px;width:" + ctlWidth + "px" }, { tag: 'td', style: "width:" + separatorWidth + "px" }, { tag: 'td', style: "width:" + ctlWidth + "px" }
            ]
            }
        ]
      }, true);

      // render start value
      var td = t.child('td');
      this.start_value_ctl.render(td);

      var td = td.next('td');
      var toText = new Ext.BoxComponent({
        autoEl: { cn: '&nbsp;' + '-' + '&nbsp;' }
      });
      toText.render(td);


      // render TimeField
      var td = td.next('td');
      this.end_value_ctl.render(td);

      if (Ext.isIE && Ext.isStrict) {
        t.select('input').applyStyles({ top: 0 });
      }

      if (this.ownerCt != null) {
        if (this.ownerCt.ownerCt != null) {
          if (this.ownerCt.ownerCt.collapsed == true) {
            this.start_value_ctl.setPosition(1, 1);
            toText.setPosition(115, 1);
            this.end_value_ctl.setPosition(140, 1);
          }
        }
      }

      //this.on('specialkey', this.onSpecialKey, this);

      this.start_value_ctl.el.swallowEvent(['keydown', 'keypress']);
      this.end_value_ctl.el.swallowEvent(['keydown', 'keypress']);

    } // end of function onRender
  /*
  ,onSpecialKey:function(t, e) {
  if(e.getKey() == e.TAB) {
  if(t === this.start_value_ctl && !e.shiftKey) {
  e.stopEvent();
  this.end_value_ctl.focus();
  }
  if(t === this.end_value_ctl && e.shiftKey) {
  e.stopEvent();
  this.start_value_ctl.focus();
  }
  }

    } // end of function onSpecialKey
  */
    , setSize: function(w, h) {
      if (!w) {
        return;
      }
      this.start_value_ctl.setSize(this.width * .47);
      this.end_value_ctl.setSize(this.width * .47);
    } // end of function setSize

    , updateValue: function(suppressEvent) {
      if (true !== suppressEvent) {
        this.fireEvent('blur', this);
      }
    }
    , focus: function() {
      this.start_value_ctl.focus();
    } // end of function focus

     , reset: function() {
       this.start_value_ctl.reset();
       this.end_value_ctl.reset();
     } // end of function reset



    , getValue: function() {
      // create new instance of date
      return this.getStartValue() + "|" + this.getEndValue();
    } // end of function getValue

    , onBlur: function() {
      (function() {
        var suppressEvent = this.start_value_ctl.hasFocus || this.end_value_ctl.hasFocus;
        this.updateValue(suppressEvent);
      }).defer(100, this);
    } // end of function onBlur


    , isValid: function() {
      var bStartDateValid = this.start_value_ctl.isValid();
      var bEndDateValid = this.end_value_ctl.isValid();

      if (!bStartDateValid || !bEndDateValid) {
        return false;
      }

      var v1, v2;

      if (this.start_value_ctl.getValue() != '') {
        v1 = this.start_value_ctl.getValue();
      }

      if (this.end_value_ctl.getValue() != '') {
        v2 = this.end_value_ctl.getValue();
      }
      if (v1 != null && v2 != null) {
        if (v2 < v1) {
          this.start_value_ctl.markInvalid(TEXT_INVALID_RANGE);
          this.end_value_ctl.markInvalid(TEXT_INVALID_RANGE);
          return false;
        }
      }


      this.start_value_ctl.clearInvalid();
      this.end_value_ctl.clearInvalid();

      return true;
      //  return this.start_value_ctl.isValid() && this.end_value_ctl.isValid();
    } // end of function isValid

    , validate: function() {
      return this.isValid();
      //return this.start_value_ctl.validate() && this.end_value_ctl.validate();
    } // end of function validate

    , setStartValue: function(date) {
      this.start_value_ctl.setValue(date);
    } // end of function setDate

    , setEndValue: function(date) {
      this.end_value_ctl.setValue(date);
    } // end of function setTime

    , getStartValue: function() {
      return this.start_value_ctl.getValue();
    }
    , getEndValue: function() {
      return this.end_value_ctl.getValue();
    }

});

Ext.reg('numericrange', Ext.ux.NumericRangeField);