// Create user extensions namespace (Ext.ux)
Ext.namespace('Ext.ux');

// StaticTextField - is used to show a readonly view of MT wrapped Ext controls, when readonly is set
Ext.ux.StaticTextField = Ext.extend(Ext.form.TextField, {
    fieldClass: 'x-static-text-field',

    onRender: function() {
        this.readOnly = true;
        this.disabled = false; //!this.initialConfig.submitValue;
        Ext.ux.StaticTextField.superclass.onRender.apply(this, arguments);
    }
});


/**
 * @class Ext.form.MiscField
 * @extends Ext.BoxComponent
 * Base class to easily display simple text in the form layout.
 * @constructor
 * Creates a new MiscField Field
 * @param {Object} config Configuration options
 */
Ext.form.MiscField = function(config){
    Ext.form.MiscField.superclass.constructor.call(this, config);
};

Ext.extend(Ext.form.MiscField, Ext.BoxComponent,  {
    /**
     * @cfg {String/Object} autoCreate A DomHelper element spec, or true for a default element spec (defaults to
     * {tag: "div"})
     */
    defaultAutoCreate : {tag: "div"},

    /**
     * @cfg {String} fieldClass The default CSS class for the field (defaults to "x-form-field")
     */
    fieldClass : "x-form-field",

    // private
    isFormField : true,

    /**
     * @cfg {Mixed} value A value to initialize this field with.
     */
    value : undefined,

    /**
     * @cfg {Boolean} disableReset True to prevent this field from being reset when calling Ext.form.Form.reset()
     */
    disableReset: false,

    /**
     * @cfg {String} name The field's HTML name attribute.
     */
    /**
     * @cfg {String} cls A CSS class to apply to the field's underlying element.
     */

    // private ??
    initComponent : function(){
        Ext.form.MiscField.superclass.initComponent.call(this);
    },

    /**
     * Returns the name attribute of the field if available
     * @return {String} name The field name
     */
    getName: function(){
         return this.rendered && this.el.dom.name ? this.el.dom.name : (this.hiddenName || '');
    },

    // private
    onRender : function(ct, position){
        Ext.form.MiscField.superclass.onRender.call(this, ct, position);
        if(!this.el){
            var cfg = this.getAutoCreate();
            if(!cfg.name){
                cfg.name = this.name || this.id;
            }
            this.el = ct.createChild(cfg, position);
        }

        this.el.addClass([this.fieldClass, this.cls]);
        this.initValue();
    },

    // private
    initValue : function(){
        if(this.value !== undefined){
            this.setRawValue(this.value);
        }else if(this.el.dom.innerHTML.length > 0){
            this.setRawValue(this.el.dom.innerHTML);
        }
    },

    /**
     * Returns true if this field has been changed since it was originally loaded.
     */
    isDirty : function() {
        return String(this.getRawValue()) !== String(this.originalValue);
    },

    // private
    afterRender : function(){
        Ext.form.MiscField.superclass.afterRender.call(this);
        this.initEvents();
    },

    /**
     * Resets the current field value to the originally-loaded value
     * @param {Boolean} force Force a reset even if the option disableReset is true
     */
    reset : function(force){
        if(!this.disableReset || force === true){
            this.setRawValue(this.originalValue);
        }
    },

    // private
    initEvents : function(){
        // reference to original value for reset
        this.originalValue = this.getRawValue();
    },

    /**
     * Returns whether or not the field value is currently valid
     * Always returns true, not used in MiscField.
     * @return {Boolean} True
     */
    isValid : function(){
        return true;
    },

    /**
     * Validates the field value
     * Always returns true, not used in MiscField.  Required for Ext.form.Form.isValid()
     * @return {Boolean} True
     */
    validate : function(){
        return true;
    },

    processValue : function(value){
        return value;
    },

    // private
    // Subclasses should provide the validation implementation by overriding this
    validateValue : function(value){
        return true;
    },

    /**
     * Mark this field as invalid
     * Not used in MiscField.  Required for Ext.form.Form.markInvalid()
     */
    markInvalid : function(){
        return;
    },

    /**
     * Clear any invalid styles/messages for this field
     * Not used in MiscField.  Required for Ext.form.Form.clearInvalid()
     */
    clearInvalid : function(){
        return;
    },

    /**
     * Returns the raw field value.
     * @return {Mixed} value The field value
     */
    getRawValue : function(){
        return this.el.dom.innerHTML;
    },

    /**
     * Returns the clean field value - plain text only, strips out HTML tags.
     * @return {Mixed} value The field value
     */
    getValue : function(){
        var f = Ext.util.Format;
        var v = f.trim(f.stripTags(this.getRawValue()));
        return v;
    },

    /**
     * Sets the raw field value.
     * @param {Mixed} value The value to set
     */
    setRawValue : function(v){
        this.value = v;
        if(this.rendered){
            this.el.dom.innerHTML = v;
        }
    },

    /**
     * Sets the clean field value - plain text only, strips out HTML tags.
     * @param {Mixed} value The value to set
     */
    setValue : function(v){
        var f = Ext.util.Format;
	this.setRawValue(f.trim(f.stripTags(v)));
    }

});

Ext.ComponentMgr.registerType('miscfield', Ext.form.MiscField);