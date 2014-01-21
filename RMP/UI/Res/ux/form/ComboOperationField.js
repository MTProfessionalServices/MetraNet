// JScript File

Ext.ns('Ext.ux.form');
Ext.ux.form.ComboOperationField = Ext.extend(Ext.form.Field, {
     /**
     * @cfg {String/Object} defaultAutoCreate DomHelper element spec
     * Let superclass to create hidden field instead of textbox. Hidden will be submittend to server
     */
     defaultAutoCreate:{tag:'input', type:'hidden'}
  
      /**
     * @cfg {Number} valueFieldWidth Width of time field in pixels (defaults to 100)
     */
    ,valueFieldWidth:160
    ,width:220
    ,initComponent:function() {
        // call parent initComponent
        Ext.ux.form.ComboOperationField.superclass.initComponent.call(this);
        
        
        var opData = [
                           ['=', 'eq']
                          ,['!=', 'ne']                          
                      ];
        var dataStore = new Ext.data.SimpleStore({
                 fields:['text', 'value']
                ,data:opData
            });
        this.opField = new Ext.form.ComboBox({
            hiddenId:this.id + '-opValue'
            ,hiddenName:this.id + '-opValue'
            ,id:this.id + '-opText'
            ,store: dataStore
            ,width:40
            ,listWidth:60
            ,editable:true
            ,disableKeyFilter:true
            ,valueNotFoundText:TEXT_ERROR_INVALID_VALUE
            ,invalidText :TEXT_ERROR_INVALID_VALUE
            ,forceSelection:true
            ,selectOnFocus:this.selectOnFocus
            ,maxLength:2
            ,displayField:'text'
            ,valueField:'value'
            ,triggerAction: 'all'
            ,mode:'local'
            ,typeAhead:false
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }    
          }
        );
        this.opField.setValue('eq');
        
        dataStore.clearFilter(false);  
              
        // create value field
        var valueFieldConfig = Ext.apply({}, {
             id:this.id + '-value'
            ,width:this.width - 60
            ,selectOnFocus:this.selectOnFocus
            , store: this.store
             ,hiddenId: this.hiddenName
            ,hiddenName:this.hiddenName
            ,fieldLabel:this.fieldLabel
            ,displayField:this.displayField
            ,valueField:this.valueField
            ,typeAhead:this.typeAhead
            ,mode:this.mode
            ,triggerAction:this.triggerAction
            ,editable:this.editable
            ,forceSelection:this.forceSelection
            ,allowBlank:this.allowBlank
            ,valueNotFoundText:this.valueNotFoundText
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.valueFieldConfig);
        this.valueField = new Ext.form.ComboBox(valueFieldConfig);

        // relay events
        this.relayEvents(this.opField, ['focus', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.valueField, ['focus', 'specialkey', 'invalid', 'valid']);

    }
    ,onRender:function(ct, position) {
        // don't run more than once
        if(this.isRendered) {
            return;
        }

        // render underlying hidden field
        Ext.ux.form.NumericOperationField.superclass.onRender.call(this, ct, position);
        var t;
        
         t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                {tag:'tr',children:[
                    {tag:'td',style:'padding-right:4px',  width:'40px', cls:'ux-datetime-date'},
                    {tag:'td', cls:'ux-datetime-time' , width:'110'}
                ]}
            ]}, true);
            
            
        this.tableEl = t;
        this.wrap = t.wrap({cls:'x-form-field-wrap'});
        this.wrap.on("mousedown", this.onMouseDown, this, {delay:10});
            
        // render fields
        this.opField.render(t.child('td.ux-datetime-date'));
        this.valueField.render(t.child('td.ux-datetime-time'));

        // workaround for IE trigger misalignment bug
        if(Ext.isIE && Ext.isStrict) {
            t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);
        this.opField.el.swallowEvent(['keydown', 'keypress']);
        this.valueField.el.swallowEvent(['keydown', 'keypress']);

        // we're rendered flag
        this.isRendered = true;
    }
    ,getValue:function() {
      // create new instance of date
      return this.valueField.getValue();
    } // eo function getValue
    
    ,getOperation:function()
    {
      return this.opField.getValue();
    }
    
    ,reset:function()
    {
      this.opField.setValue('eq');
      this.setValue('');
    }
    
    ,setOperation:function(v)
    {
      this.opField.setValue(v);
    }
    
    ,setValue:function(val){
      this.valueField.setValue(val);
    }
    ,isValid:function(){
      return true;
      
    }
    ,onBlur:function(f) {
        if(this.wrapClick) {
            f.focus();
            this.wrapClick = false;
        }

        // fire events later
        (function() {
            if(!this.opField.hasFocus && !this.valueField.hasFocus) {
                var v = this.getValue();
                if(String(v) !== String(this.startValue)) {
                    this.fireEvent("change", this, v, this.startValue);
                }
                this.hasFocus = false;
                this.fireEvent('blur', this);
            }
        }).defer(100, this);
    }
    ,onMouseDown:function(e) {
        this.wrapClick = 'td' === e.target.nodeName.toLowerCase();
    }
    ,onSpecialKey:function(t, e) {
        var key = e.getKey();
        if(key == e.TAB) {
            if(t === this.opField && !e.shiftKey) {
                e.stopEvent();
                this.valueField.focus();
            }
            if(t === this.valueField && e.shiftKey) {
                e.stopEvent();
                this.opField.focus();
            }
        }
        // otherwise it misbehaves in editor grid
        if(key == e.ENTER) {
            this.internalValue = this.valueField.getValue();
        }

    }
   // }}}
    //{{{
    ,show:function() {
        return this.setVisible(true);
    } // eo function show
    //}}}
    //{{{
    ,hide:function() {
        return this.setVisible(false);
    } // eo function hide
    //}}}
    
    ,setSize:function(w, h) {
        if(!w) {
            return;
        }

        this.opField.setSize(56,h);//(w - this.valueFieldWidth - 4, h);
        this.valueField.setSize(this.width-60, h);//(this.valueFieldWidth, h);

        if(Ext.isIE) {
            this.opField.el.up('td').setWidth(56,h);//(w - this.valueFieldWidth - 4);
            this.valueField.el.up('td').setWidth(this.width - 60);//(this.valueFieldWidth);
        }
        
    } // eo function setSize   
    
    
});

// register xtype
Ext.reg('xcombooperationfield', Ext.ux.form.ComboOperationField);