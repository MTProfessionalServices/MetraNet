// JScript File

/**
 * Ext.ux.form.DateTime Extension Class for Ext 2.x Library
 *
 * @author    Ing. Jozef Sakalos
 * @copyright (c) 2008, Ing. Jozef Sakalos
 * @version $Id: Ext.ux.form.DateTime.js 11 2008-02-22 17:13:52Z jozo $
 *
 * @license Ext.ux.form.DateTime is licensed under the terms of
 * the Open Source LGPL 3.0 license.  Commercial use is permitted to the extent
 * that the code/component(s) do NOT become part of another Open Source or Commercially
 * licensed development library or toolkit without explicit permission.
 * 
 * License details: http://www.gnu.org/licenses/lgpl.html
 */

Ext.ns('Ext.ux.form');

/**
 * @class Ext.ux.form.NumericOperationField
 * @extends Ext.form.Field
 */
Ext.ux.form.NumericOperationField = Ext.extend(Ext.form.Field, {
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

    /**
     * @cfg {String} timePosition Where the time field should be rendered. 'right' is suitable for forms
     * and 'below' is suitable if the field is used as the grid editor (defaults to 'right')
     */
    ,timePosition:'right' // valid values:'below', 'right'

    // {{{
    /**
     * private
     * creates DateField and TimeField and installs the necessary event handlers
     */
    ,initComponent:function() {
        // call parent initComponent
        Ext.ux.form.NumericOperationField.superclass.initComponent.call(this);

        // create DateField
        var opData = [
                           ['=', 'eq']
                          ,['<', 'lt']
                          ,['<=', 'lte']
                          ,['>', 'gt']
                          ,['>=', 'gte']
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

        // create TimeField
        var valueFieldConfig = Ext.apply({}, {
             id:this.id + '-value'
            ,width:this.width - 60
            ,selectOnFocus:this.selectOnFocus
            ,listeners:{
                  blur:{scope:this, fn:this.onBlur}
                 ,focus:{scope:this, fn:this.onFocus}
            }
        }, this.valueFieldConfig);
        this.valueField = new Ext.ux.form.LargeNumberField(valueFieldConfig);

        // relay events
        this.relayEvents(this.opField, ['focus', 'specialkey', 'invalid', 'valid']);
        this.relayEvents(this.valueField, ['focus', 'specialkey', 'invalid', 'valid']);

    } // eo function initComponent
    // }}}
    // {{{
    /**
     * private
     * Renders underlying DateField and TimeField and provides a workaround for side error icon bug
     */
    ,onRender:function(ct, position) {
        // don't run more than once
        if(this.isRendered) {
            return;
        }

        // render underlying hidden field
        Ext.ux.form.NumericOperationField.superclass.onRender.call(this, ct, position);

        // render DateField and TimeField
        // create bounding table
        var t;
        if('below' === this.timePosition) {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                 {tag:'tr',children:[{tag:'td', width:'60px', style:'padding-bottom:1px', cls:'ux-datetime-date'}]}
                ,{tag:'tr',children:[{tag:'td', width:'130px', cls:'ux-datetime-time'}]}
            ]}, true);
        }
        else {
            t = Ext.DomHelper.append(ct, {tag:'table',style:'border-collapse:collapse',children:[
                {tag:'tr',children:[
                    {tag:'td',style:'padding-right:4px',  width:'40px', cls:'ux-datetime-date'},
                    {tag:'td', cls:'ux-datetime-time' , width:'110'}
                ]}
            ]}, true);
        }

        this.tableEl = t;
        this.wrap = t.wrap({cls:'x-form-field-wrap'});
        this.wrap.on("mousedown", this.onMouseDown, this, {delay:10});

        // render DateField & TimeField
        this.opField.render(t.child('td.ux-datetime-date'));
        this.valueField.render(t.child('td.ux-datetime-time'));

        // workaround for IE trigger misalignment bug
        if(Ext.isIE && Ext.isStrict) {
            t.select('input').applyStyles({top:0});
        }

        this.on('specialkey', this.onSpecialKey, this);
        this.opField.el.swallowEvent(['keydown', 'keypress']);
        this.valueField.el.swallowEvent(['keydown', 'keypress']);

        // create icon for side invalid errorIcon
        if('side' === this.msgTarget) {
            var elp = this.el.findParent('.x-form-element', 10, true);
            this.errorIcon = elp.createChild({cls:'x-form-invalid-icon'});

            this.opField.errorIcon = this.errorIcon;
            this.valueField.errorIcon = this.errorIcon;
        }

        // we're rendered flag
        this.isRendered = true;

    } // eo function onRender
    // }}}
    // {{{
    /**
     * private
     */
    ,adjustSize:Ext.BoxComponent.prototype.adjustSize
    // }}}
    // {{{
    /**
     * private
     */
    ,alignErrorIcon:function() {
        this.errorIcon.alignTo(this.tableEl, 'tl-tr', [2, 0]);
    }
    // }}}
    // {{{
    /**
     * private initializes internal dateValue
     */
    ,initDateValue:function() {
        this.internalValue = this.valueField.getValue();
    }
    
    ,initQuery:function()
    {
      this.doQuery('');
    }
    // }}}
    // {{{
    /**
     * Disable this component.
     * @return {Ext.Component} this
     */
    ,disable:function() {
        if(this.isRendered) {
            this.opField.disabled = this.disabled;
            this.opField.onDisable();
            this.valueField.onDisable();
        }
        this.disabled = true;
        this.opField.disabled = true;
        this.valueField.disabled = true;
        this.fireEvent("disable", this);
        return this;
    } // eo function disable
    // }}}
    // {{{
    /**
     * Enable this component.
     * @return {Ext.Component} this
     */
    ,enable:function() {
        if(this.rendered){
            this.opField.onEnable();
            this.valueField.onEnable();
        }
        this.disabled = false;
        this.opField.disabled = false;
        this.valueField.disabled = false;
        this.fireEvent("enable", this);
        return this;
    } // eo function enable
    // }}}
    // {{{
    /**
     * private Focus date filed
     */
    ,focus:function() {
        this.opField.focus();
    } // eo function focus
    // }}}
    // {{{
    /**
     * private
     */
    ,getPositionEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * private
     */
    ,getResizeEl:function() {
        return this.wrap;
    }
    // }}}
    // {{{
    /**
     * @return {Date/String} Returns value of this field
     */
     
    ,getValue:function() {
        // create new instance of date
        return this.valueField.getValue();
    } // eo function getValue
    
    
    ,getOperation:function()
    {
      return this.opField.getValue();
    }
    ,setOperation:function(v)
    {
      this.opField.setValue(v);
    }
    ,reset:function()
    {
      this.valueField.setValue('');
      this.opField.setValue('eq');
    }
    
    // }}}
    // {{{
    /**
     * @return {Boolean} true = valid, false = invalid
     * private Calls isValid methods of underlying DateField and TimeField and returns the result
     */
    ,isValid:function() {
        return this.opField.isValid() && this.valueField.isValid();
    } // eo function isValid
    // }}}
    // {{{
    /**
     * Returns true if this component is visible
     * @return {boolean} 
     */
    ,isVisible : function(){
        return this.opField.rendered && this.opField.getActionEl().isVisible();
    } // eo function isVisible
    // }}}
    // {{{
    /** 
     * private Handles blur event
     */
    ,onBlur:function(f) {
        // called by both DateField and TimeField blur events

        // revert focus to previous field if clicked in between
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

    } // eo function onBlur
    // }}}
    // {{{
    /**
     * private Handles focus event
     */
    ,onFocus:function() {
        if(!this.hasFocus){
            this.hasFocus = true;
            this.startValue = this.getValue();
            this.fireEvent("focus", this);
        }
    }
    // }}}
    // {{{
    /**
     * private Just to prevent blur event when clicked in the middle of fields
     */
    ,onMouseDown:function(e) {
        this.wrapClick = 'td' === e.target.nodeName.toLowerCase();
    }
    // }}}
    // {{{
    /**
     * private
     * Handles Tab and Shift-Tab events
     */
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

    } // eo function onSpecialKey
    // }}}
    // {{{
    /**
     * private Sets the value of DateField
     */
    ,setDate:function(date) {
        this.opField.setValue(date);
    } // eo function setDate
    // }}}
    // {{{
    /** 
     * private Sets the value of TimeField
     */
    ,setTime:function(date) {
        this.valueField.setValue(date);
    } // eo function setTime
    // }}}
    // {{{
    /**
     * private
     * Sets correct sizes of underlying DateField and TimeField
     * With workarounds for IE bugs
     */
    ,setSize:function(w, h) {
        if(!w) {
            return;
        }

        this.opField.setSize(56,h);//(w - this.width - 60 - 4, h);
        this.valueField.setSize(this.width-60, h);

        if(Ext.isIE) {
            this.opField.el.up('td').setWidth(56,h);//(w - this.width-60 - 4);
            this.valueField.el.up('td').setWidth(this.width - 60);
        }
        
    } // eo function setSize
    // }}}
    // {{{
    /**
     * @param {Mixed} val Value to set
     * Sets the value of this field
     */
    ,setValue:function(val) {
        this.valueField.setValue(val);
    } // eo function setValue
    // }}}
    // {{{
    /**
     * Hide or show this component by boolean
     * @return {Ext.Component} this
     */
    ,setVisible: function(visible){
        if(visible) {
            this.opField.show();
            this.valueField.show();
        }else{
            this.opField.hide();
            this.valueField.hide();
        }
        return this;
    } // eo function setVisible
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
    
    /**
     * @return {Boolean} true = valid, false = invalid
     * callse validate methods of DateField and TimeField
     */
    ,validate:function() {
        return this.opField.validate() && this.valueField.validate();
    } // eo function validate
    // }}}
    // {{{
    /**
     * Returns renderer suitable to render this field
     * @param {Object} Column model config
     */
     /*
    ,renderer: function(field) {
        var format = field.editor.dateFormat || Ext.ux.form.DateTime.prototype.dateFormat;
        format += ' ' + (field.editor.timeFormat || Ext.ux.form.DateTime.prototype.timeFormat);
        var renderer = function(val) {
            var retval = Ext.util.Format.date(val, format);
            return retval;
        };
        return renderer;
    } // eo function renderer
    */
    // }}}

}); // eo extend

// register xtype
Ext.reg('xnumericoperationfield', Ext.ux.form.NumericOperationField);