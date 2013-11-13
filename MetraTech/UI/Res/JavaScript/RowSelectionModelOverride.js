// Overrides the RowSelectionModel class to add keepSelections property, that will allow cross-page row selection

Ext.override(Ext.grid.RowSelectionModel, {
		onRefresh : function(){
			var ds = this.grid.store, index;
			var s = this.getSelections();
			if (!this.keepSelections)
				this.clearSelections(true);
			for (var i = 0, len = s.length; i < len; i++) {
				var r = s[i];
				if ((index = ds.indexOfId(r.id)) != -1) {
					this.selectRow(index, true);
				}
			}
		},

    deselectRow : function(index, preventViewNotify){
        if(this.locked) return;
        if(this.last == index){
            this.last = false;
        }
        if(this.lastActive == index){
            this.lastActive = false;
        }
        var r = this.grid.store.getAt(index);
        if(r){
            //this.selections.remove(r);
            for(var i = this.selections.items.length - 1; i >= 0; i--)
            {
              if(this.selections.items[i].id == r.id)
              {
                this.selections.removeAt(i);
              }
            }
            if(!preventViewNotify){
                this.grid.getView().onRowDeselect(index);
            }
            this.fireEvent("rowdeselect", this, index, r);
            this.fireEvent("selectionchange", this);
        }
    },

    selectRow : function(index, keepExisting, preventViewNotify){
        if(this.locked || (index < 0 || index >= this.grid.store.getCount()) || this.isSelected(index)) 
        {
          if(this.isSelected(index))
          {
            if(!preventViewNotify){
                this.grid.getView().onRowSelect(index);
            }
            
            this.fireEvent("rowselect", this, index, this.grid.store.getAt(index));
          }          
          return;
        }
        var r = this.grid.store.getAt(index);
        if(r && this.fireEvent("beforerowselect", this, index, keepExisting, r) !== false){
            if(!keepExisting || this.singleSelect){
                this.clearSelections();
            }
            this.selections.add(r);
            this.last = this.lastActive = index;
            if(!preventViewNotify){
                this.grid.getView().onRowSelect(index);
            }
            this.fireEvent("rowselect", this, index, r);
            this.fireEvent("selectionchange", this);
        }
    },
		 
     // Deselects all rows.
     
    deselectAll : function(){
        if(this.locked) return;
        //this.selections.clear();
        for(var i = 0, len = this.grid.store.getCount(); i < len; i++){
            this.deselectRow(i);
        }
    },
    
     // Selects all rows.
    selectAll : function(){
        if(this.locked) return;
                
        for(var i = 0, len = this.grid.store.getCount(); i < len; i++){
            this.selectRow(i, true);
        }
    },
    
    // private
    handleMouseDown : function(g, rowIndex, e){
       return;
    },
    
		keepSelections: true
	});


	Ext.override(Ext.grid.CheckboxSelectionModel, {
	  header: ((this.singleSelect) ? '' : '<div class="x-grid3-hd-checker">&#160;</div>'),

	  initEvents: function() {
	    //this.header = ((this.singleSelect) ? '' : '<div class="x-grid3-hd-checker">&#160;</div>');
        Ext.grid.CheckboxSelectionModel.superclass.initEvents.call(this);
	    this.grid.on('render', function() {
            var view = this.grid.getView();
            view.mainBody.on('mousedown', this.onMouseDown, this);
            Ext.fly(view.innerHd).on('mousedown', this.onHdMouseDown, this);

        }, this);
    },


	    // private
	  onMouseDown: function(e, t) {
        var selectClassName = ((this.singleSelect) ? 'x-grid3-row-radio' : 'x-grid3-row-checker');

	    if (e.button === 0 && t.className == selectClassName) { // Only fire if left-click
            e.stopEvent();
            var row = e.getTarget('.x-grid3-row');
	      if (row) {
                var index = row.rowIndex;
	        if (this.isSelected(index)) {
                    this.deselectRow(index);
                    var a = 1;
	        } else {
                    var b = 2;
                    this.selectRow(index, true);
                }
            }
        }
    },

	  onHdMouseDown: function(e, t) {
	    if (t.className == 'x-grid3-hd-checker') {
            e.stopEvent();
            var hd = Ext.fly(t.parentNode);
            var isChecked = hd.hasClass('x-grid3-hd-checker-on');
	      if (isChecked) {
                hd.removeClass('x-grid3-hd-checker-on');
                this.deselectAll();
	      } else {
	        if (this.singleSelect) return;

                hd.addClass('x-grid3-hd-checker-on');
                this.selectAll();
            }
        }
    },
	  renderer: function(v, p, record, x, y, grid) {
	    if (grid.sm) {
          if (grid.sm.singleSelect)
            return '<div class="x-grid3-row-radio">&#160;</div>';
        }
       return '<div class="x-grid3-row-checker">&#160;</div>';
     }
	});
	
		Ext.override(Ext.form.DateField,{
	  errDateFormat : ERR_DATE_FORMAT,
	  	  
	   validateValue : function(value){
        value = this.formatDate(value);
        if(!Ext.form.DateField.superclass.validateValue.call(this, value)){
            return false;
        }
        if(value.length < 1){ // if it's blank and textfield didn't flag it then it's valid
             return true;
        }
        var svalue = value;
        value = this.parseDate(value);
        if(!value){
            this.markInvalid(String.format(this.invalidText, svalue, this.errDateFormat));
            return false;
        }
        var time = value.getTime();
        if(this.minValue && time < this.minValue.getTime()){
            this.markInvalid(String.format(this.minText, this.formatDate(this.minValue)));
            return false;
        }
        if(this.maxValue && time > this.maxValue.getTime()){
            this.markInvalid(String.format(this.maxText, this.formatDate(this.maxValue)));
            return false;
        }
        if (this.compareValue && value < this.parseDate(this.compareValue))
        {
          this.markInvalid(String.format(ERROR_SUBSCRIPTION_STARTDATE_BIGGER_ENDDATE));
          return false;
        }
        if(this.disabledDays){
            var day = value.getDay();
            for(var i = 0; i < this.disabledDays.length; i++) {
            	if(day === this.disabledDays[i]){
            	    this.markInvalid(this.disabledDaysText);
                    return false;
            	}
            }
        }
        var fvalue = this.formatDate(value);
        if(this.ddMatch && this.ddMatch.test(fvalue)){
            this.markInvalid(String.format(this.disabledDatesText, fvalue));
            return false;
        }
        return true;
    }
	  
	  
	 
    });
    
    
//better date validation in date field control
Ext.override(Ext.form.DateField, {
            parseDate : function(value){
                if(!value || value instanceof Date){
                    return value;
                }
                if(this.preValidateDate(value, this.format)){
                    var v = Date.parseDate(value, this.format);
                }
                if(!v && this.altFormats){
                    if(!this.altFormatsArray){
                        this.altFormatsArray = this.altFormats.split("|");
                    }
                    for(var i = 0, len = this.altFormatsArray.length; i < len && !v; i++){
                        if(this.preValidateDate(value, this.altFormatsArray[i])){
                            v = Date.parseDate(value, this.altFormatsArray[i]);
                        }
                    }
                }
                return v;
            },
            preValidateDate : function(value, format){
                var d, m, y, r = /[-\/\\.]/;
                var valueParts = value.split(r);
                var formatParts = format.split(r);

                if(!valueParts || !formatParts){
                    return false;
                }
                for(var i = 0; i < formatParts.length; i++){
                    switch(formatParts[i]){
                        case 'm': //leading 0
                        case 'n': //no leading 0
                            m = valueParts[i];
                            break;
                        case 'd': //leading 0
                        case 'j': //no leading 0
                            d = valueParts[i];
                            break;
                        case 'y': //2-digit
                        case 'Y': //4-digit
                            y = valueParts[i];
                            break;
                    }
                }
                if(m && (m < 1 || m > 12)){
                    return false;
                }
                if(d){
                    y = y || new Date().getFullYear();
                    var isLeapYear = ((y & 3) == 0 && (y % 100 || (y % 400 == 0 && y)));
                    var daysInMonth = [31,(isLeapYear ? 29 : 28),31,30,31,30,31,31,30,31,30,31];
                    m = m ? m-1 : new Date().getMonth();
                    var days = daysInMonth[m];
                    if(d < 1 || d > days){
                        return false;
                    }
                }
                return true;
            }
        });
        
//handling null values when formatting
//SECENG: Overload to do htmlEncoding for strings too
Ext.apply(Ext.util.Format, {
	hideNull: function(v) {
	    //return v !== null ? v : '';
	    return v !== null ? ((typeof v == "string") ? ((v == '') ? '' : Ext.util.Format.htmlEncode(v)) : v) : '';
	}

});

Ext.apply(Ext.util.Format, {
  formatBool: function(v) {
    if ((v + '').toLowerCase() == 'true') {
      return TEXT_YES;
    }

    if ((v + '').toLowerCase() == 'false') {
      return TEXT_NO;
    }

    return '';
  }
});

Ext.apply(Ext.util.Format, {
	formatLineBreaks: function(v) {
		return v != null ? v.replace(/\n/g,"<br/>").replace(/\r/g,"") : '';
	}
});

Ext.apply(Ext.util.Format,{
  formatDate: function(value){
         return RenderDate(value, DATE_FORMAT);
      }
});

Ext.apply(Ext.util.Format, {  
   formatDateTime: function (value) {  
          return RenderDate(value, DATE_TIME_RENDERER);  
      }  
 });

Ext.override(Ext.EventObjectImpl, {
    getTarget : function(selector, maxDepth, returnEl){
        var targetElement;

        try {
            targetElement = selector ? Ext.fly(this.target).findParent(selector, maxDepth, returnEl) : this.target;
        } catch(e) {
            targetElement = this.target;
        }

        return targetElement;
    }
});

Ext.apply(String,{
  escapeQuote: function(string){
         return string.replace(/'/g, "''");
      }
});