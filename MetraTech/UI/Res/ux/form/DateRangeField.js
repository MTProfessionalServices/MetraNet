Ext.namespace('Ext.ux');
Ext.ux.DateRangeField = Ext.extend(Ext.form.Field, {
  defaultAutoCreate: { tag: 'input', type: 'hidden' }
    , dtSeparator: ' '
    , hiddenFormat: DATE_FORMAT
    , altFormats: ALT_FORMAT
    , isFormField: true
    , toText: TEXT_TO
    , startDate: ''
    , endDate: ''
    , autoFill: true
    , allowBlank: true
    , initComponent: function() {
      Ext.ux.DateRangeField.superclass.initComponent.call(this);

      var dateWidth = 100;

      // create DateField
      var startDateConfig = Ext.apply({}, {
        id: this.id + '-start-date'
            , format: this.dateFormat
            , altFormats: this.altFormats
            , allowBlank: this.allowBlank
            , enableKeyEvents: true
        //,width:dateWidth
            , listeners: {
              blur: { scope: this, fn: this.onBlur }
            }
      }, this.startDateConfig);
      this.start_date = new Ext.form.DateField(startDateConfig);
      this.start_date.parent = this;
      //delete(this.dateFormat);

      var endDateConfig = Ext.apply({}, {
        id: this.id + '-end-date'
            , format: this.dateFormat
            , altFormats: this.altFormats
        //,width:dateWidth
            , allowBlank: this.allowBlank
            , listeners: {
              blur: { scope: this, fn: this.onBlur }
            }
      }, this.endDateConfig);

      //initialize start date 
      if (Date.parse(this.startDate)) {
        this.setStartDate(new Date(this.startDate));
      }


      this.end_date = new Ext.form.DateField(endDateConfig);
      this.end_date.parent = this;

      delete (this.dateFormat);

      this.start_date.on('select', function(df, date) {
        df.clearInvalid();
        df.parent.end_date.clearInvalid();
        if (df.parent.getEndDate() == null || df.parent.getEndDate() == '') {
          df.parent.setEndDate(date.add(Date.DAY, 1));
          return;
        }
        else {/*
          //compare the dates and set error if start is greater than end
          if (date > df.parent.getEndDate()) {
            this.markInvalid('Invalid Date Range');
            df.parent.end_date.markInvalid('Invalid Date Range');
          }*/
          df.parent.validate();
        }
      });

      this.start_date.on('keyup', function(df) {
        if (df.getValue() != '') {
          df.clearInvalid();
          df.parent.end_date.clearInvalid();
          df.parent.validate();
        }
      });

      this.start_date.on('focus', function(df) {
        return;
      });
      this.start_date.on('change', function(df, oldValue, newValue) {
        if (oldValue != newValue) {
          df.clearInvalid();
          df.parent.end_date.clearInvalid();
          df.parent.validate();
        }
      });

      this.end_date.on('select', function(df, date) {
        df.clearInvalid();
        df.parent.start_date.clearInvalid();

        if (df.parent.getStartDate() != null && df.parent.getEndDate() != '') {
          /*
          if (date < df.parent.getStartDate()) {
          this.markInvalid('Invalid Date Range');
          df.parent.start_date.markInvalid('Invalid Date Range');
          }
          */
          df.parent.validate();
        }
      });

      //initialize
      if (Date.parse(this.endDate)) {
        this.setEndDate(new Date(this.endDate));
      }

      // relay events
      this.relayEvents(this.start_date, ['focus', 'change', 'specialkey', 'invalid', 'valid']);
      this.relayEvents(this.end_date, ['focus', 'change', 'specialkey', 'invalid', 'valid']);

    }


    , onRender: function(ct, position) {
      // render underlying field
      Ext.ux.DateRangeField.superclass.onRender.call(this, ct, position);

      // render DateField and TimeField
      // create bounding table
      var t = Ext.DomHelper.append(ct, { tag: 'table', style: 'border-collapse:collapse', children: [
            { tag: 'tr', style: 'nowrap:true', children: [
                { tag: 'td', style: 'padding-right:4px;width:100px' }, { tag: 'td' }, { tag: 'td', style: 'width:100px' }
            ]
            }
        ]
      }, true);

      // render DateField
      var td = t.child('td');
      this.start_date.render(td);

      var td = td.next('td');
      var toText = new Ext.BoxComponent({
        autoEl: { cn: '&nbsp;' + this.toText + '&nbsp;' }
      });
      toText.render(td);


      // render TimeField
      var td = td.next('td');
      this.end_date.render(td);

      if (Ext.isIE && Ext.isStrict) {
        t.select('input').applyStyles({ top: 0 });
      }

      if (this.ownerCt != null) {
        if (this.ownerCt.ownerCt != null) {
          if (this.ownerCt.ownerCt.collapsed == true) {
            this.start_date.setPosition(1, 1);
            toText.setPosition(115, 1);
            this.end_date.setPosition(140, 1);
          }
        }
      }

      //this.on('specialkey', this.onSpecialKey, this);

      this.start_date.el.swallowEvent(['keydown', 'keypress']);
      this.end_date.el.swallowEvent(['keydown', 'keypress']);

    } // end of function onRender
  /*
  ,onSpecialKey:function(t, e) {
  if(e.getKey() == e.TAB) {
  if(t === this.start_date && !e.shiftKey) {
  e.stopEvent();
  this.end_date.focus();
  }
  if(t === this.end_date && e.shiftKey) {
  e.stopEvent();
  this.start_date.focus();
  }
  }

    } // end of function onSpecialKey
  */
    , setSize: function(w, h) {
      if (!w) {
        return;
      }
      this.start_date.setSize(100);
      this.end_date.setSize(100);
    } // end of function setSize

    , focus: function() {
      this.start_date.focus();
    } // end of function focus

     , reset: function() {
       this.start_date.reset();
       this.end_date.reset();
     } // end of function reset

   , setValue: function(val) {
     if (!val) {
       return;
     }
     var da, time;
     if (val instanceof Date) {
       this.setStartDate(val);
       this.setEndDate(val.add(Date.DAY, 1));
       this.dateValue = new Date(val);
     }
     else {
       da = val.split(this.dtSeparator);
       this.setStartDate(da[0]);
       if (da[1]) {
         this.setEndDate(da[1]);
       }
     }
     this.updateValue(true);
   } // end of function setValue

    , getValue: function() {
      // create new instance of date
      return new Date(this.dateValue);
    } // end of function getValue

    , onBlur: function() {
      (function() {
        var suppressEvent = this.start_date.hasFocus || this.end_date.hasFocus;
        this.updateValue(suppressEvent);
      }).defer(100, this);
    } // end of function onBlur

    , updateValue: function(suppressEvent) {
      // update date
      var d = this.start_date.getValue();
      this.dateValue = this.dateValue ? this.dateValue : new Date(d);
      if (d instanceof Date) {
        this.dateValue.setFullYear(d.getFullYear());
        this.dateValue.setMonth(d.getMonth());
        this.dateValue.setDate(d.getDate());
      }

      /*
      // update time
      var t = Date.parseDate(this.end_date.getValue(), this.end_date.format);
      if(t instanceof Date && this.dateValue instanceof Date) {
      this.dateValue.setHours(t.getHours());
      this.dateValue.setMinutes(t.getMinutes());
      this.dateValue.setSeconds(t.getSeconds());
      }
      */

      // update underlying hidden
      this.el.dom.value = this.dateValue instanceof Date ? this.dateValue.format(this.hiddenFormat) : this.dateValue;

      // fire blur event if not suppressed and if neither DateField nor TimeField has it
      if (true !== suppressEvent) {
        this.fireEvent('blur', this);
      }
    } // end of function updateValue

    , isValid: function() {
      var bStartDateValid = this.start_date.isValid();
      var bEndDateValid = this.end_date.isValid();

      if (!bStartDateValid || !bEndDateValid) {
        return false;
      }

      var startDate;
      var endDate;

      if (this.start_date.getValue() != '') {
        try {
          startDate = new Date(this.start_date.getValue());
        }
        catch (e) {
          return false;
        }
      }

      if (this.end_date.getValue() != '') {
        try {
          endDate = new Date(this.end_date.getValue());
        }
        catch (e) {
          return false;
        }
      }

      if ((this.start_date.getValue() != '') && (this.end_date.getValue() != '')) {
        if (startDate > endDate) {
          this.start_date.markInvalid(TEXT_INVALID_RANGE);
          this.end_date.markInvalid(TEXT_INVALID_RANGE);
          return false;
        }
      }

      this.start_date.clearInvalid();
      this.end_date.clearInvalid();

      return true;
      //  return this.start_date.isValid() && this.end_date.isValid();
    } // end of function isValid

    , validate: function() {
      return this.isValid();
      //return this.start_date.validate() && this.end_date.validate();
    } // end of function validate

    , setStartDate: function(date) {
      this.start_date.setValue(date);
    } // end of function setDate

    , setEndDate: function(date) {
      this.end_date.setValue(date);
    } // end of function setTime

    , getStartDate: function() {
      return this.start_date.getValue();
    }
    , getEndDate: function() {
      return this.end_date.getValue();
    }

});

Ext.reg('daterange', Ext.ux.DateRangeField);