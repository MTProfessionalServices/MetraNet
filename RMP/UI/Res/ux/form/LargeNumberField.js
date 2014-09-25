/**
* @class Ext.ux.form.LargeNumberField
* @extends Ext.form.TextField
* Numeric text field that supports numbers that may exceed the capacity
* of a double-precision floating point number.  (Double precision supports
* only up to 15 digits.)
* This class is modelled on Ext.form.NumberField.  It provides automatic 
* keystroke filtering and numeric validation.
* @constructor
* Creates a new LargeNumberField.
* @param {Object} config Configuration options
* @xtype largenumberfield
*/
Ext.namespace('Ext.ux.form');
Ext.ux.form.LargeNumberField = Ext.extend(Ext.form.TextField, {
  /**
  * @cfg {RegExp} stripCharsRe @hide
  */
  /**
  * @cfg {RegExp} maskRe @hide
  */
  /**
  * @cfg {String} fieldClass The default CSS class for the field 
  * (defaults to "x-form-field x-form-num-field")
  */
  fieldClass: "x-form-field x-form-num-field",

  /**
  * @cfg {Boolean} allowDecimals False to disallow decimal values (defaults to true)
  */
  allowDecimals: false,

  /**
  * @cfg {String} decimalSeparator Character(s) to allow as the decimal separator 
  * (defaults to '.')
  */
  decimalSeparator: ".",

  /**
  * @cfg {Number} decimalPrecision The maximum precision to display after the 
  * decimal separator (defaults to 10)
  */
  decimalPrecision: 10,

  /**
  * @cfg {Boolean} trailingZeros True to cause trailing zeros to be appended to get 
  * the number of decimal places specified by decimalPrecision (defaults to false)
  */
  trailingZeros: false,

  /**
  * @cfg {Boolean} allowNegative False to prevent entering a negative sign 
  * (defaults to true)
  */
  allowNegative: true,

  /**
  * @cfg {Number} minValue The minimum allowed value (defaults to 
  * Number.NEGATIVE_INFINITY)
  */
  minValue: Number.NEGATIVE_INFINITY,

  /**
  * @cfg {Number} maxValue The maximum allowed value (defaults to Number.MAX_VALUE)
  */
  maxValue: Number.MAX_VALUE,

  /**
  * @cfg {String} minText Error text to display if the minimum value validation fails 
  * (defaults to "The minimum value for this field is {minValue}")
  */
  minText: "The minimum value for this field is {0}",

  /**
  * @cfg {String} maxText Error text to display if the maximum value validation fails 
  * (defaults to "The maximum value for this field is {maxValue}")
  */
  maxText: "The maximum value for this field is {0}",

  /**
  * @cfg {String} nanText Error text to display if the value is not a valid number. 
  * For example, this can happen if a valid character like '.' or '-' is left in the 
  * field with no number (defaults to "{value} is not a valid number")
  */
  nanText: "{0} is not a valid number",

  /**
  * @cfg {String} baseChars The base set of characters to evaluate as valid numbers 
  * (defaults to '0123456789').
  */
  baseChars: "0123456789",

  /**
  * @cfg {Boolean} autoStripChars True to automatically strip not allowed characters 
  * from the field.  Defaults to <tt>false</tt>
  */
  autoStripChars: false,

  // private
  initEvents: function () {
    var allowed = this.baseChars + '';
    if (this.allowDecimals) {
      allowed += this.decimalSeparator;
    }
    if (this.allowNegative) {
      allowed += '-';
    }
    allowed = Ext.escapeRe(allowed);
    this.maskRe = new RegExp('[' + allowed + ']');
    if (this.autoStripChars) {
      this.stripCharsRe = new RegExp('[^' + allowed + ']', 'gi');
    }

    Ext.ux.form.LargeNumberField.superclass.initEvents.call(this);
  },

  /**
  * Runs all of LargeNumberField validations and returns an array
  * of strings describing any validation errors that occurred.
  * Note that this function first runs TextField's validations, 
  * so the returned array is an amalgamation of all field errors.
  * The validations beyond the TextField validations test that the value:
  * (a) has the right format, considering the allowNegative, allowDecimals,
  * decimalSeparator, and decimalPrecision properties; and
  * (b) falls within the specified range (minValue, maxValue).
  *
  * @param {Mixed} value The value to get validation errors for (defaults to the current field value)
  * @return {Array} All validation errors for this field
  */
  getErrors: function (value) {

    // First do TextField validations, which include length checks 
    // (allowBlank, minLength, maxLength), vtype, and regex.
    var errors = Ext.ux.form.LargeNumberField.superclass.getErrors.apply(
            this, arguments);

    value = Ext.isDefined(value) ? value : this.processValue(this.getRawValue());

    // If it's blank, then TextField validation is enough.
    if (value.length < 1) {
      return errors;
    }

    // Next test format, using a regular expression.
    // The value can be a decimal number with up to 12 digits left 
    // of the decimal point and up to 10 digits right of the decimal point,
    // which is what SQL Server supports with database columns of (22,10).
    // (Note: Expresso is a good regular expression tool.)

    var _isNaN = false;
    //if (!re.test(value)) {
    if (isNaN(this.parseValue(value))) {
      _isNaN = true;
      errors.push(String.format(this.nanText, value));
    }

    // Finally, test that the value is in the specified range.
    // This is the weakest part of our validation because
    // we can't test values outside JavaScript's double precision
    // floating point range -- BUG!!
    if (!_isNaN && (value.length < 16)) {
      var floatnum = this.parseValue(value);
      if (floatnum < this.minValue) {
        errors.push(String.format(this.minText, this.minValue));
      }
      if (floatnum > this.maxValue) {
        errors.push(String.format(this.maxText, this.maxValue));
      }
    }

    return errors;
  }, // getErrors


  getValue: function () {
    return this.parseValue(Ext.ux.form.LargeNumberField.superclass.getValue.call(this));
    // Might not need the call to fixPrecision() here, but it shouldn't hurt.
    // If fixPrecision() does any truncating of significant digits,
    // then we definitely need to call it here.
  },

  setValue: function (v) {
    if (isNaN(Number(this.parseValue(v))) || v == '') v = '';
    else if (this.allowDecimals)
      v = Number(this.parseValue(v)).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: FRACTION_DIGITS, minimumFractionDigits: FRACTION_DIGITS });
    return Ext.ux.form.LargeNumberField.superclass.setValue.call(this, v);
  },

  /**
  * Replaces any existing {@link #minValue} with the new value.
  * @param {Number} value The minimum value
  */
  setMinValue: function (value) {
    this.minValue = Ext.num(value, Number.NEGATIVE_INFINITY);
  },

  /**
  * Replaces any existing {@link #maxValue} with the new value.
  * @param {Number} value The maximum value
  */
  setMaxValue: function (value) {
    this.maxValue = Ext.num(value, Number.MAX_VALUE);
  },

  // private
  // Can't call parseFloat() because value might be too large.
  // Instead, just replaces decimal separator with standard '.' and checks for NaN.
  // Returns number or empty string.
  parseValue: function (value) {
    value = String(value).split(DECIMAL_SEPARATOR + DECIMAL_SEPARATOR).join("?");
    value = String(value).split(DECIMAL_SEPARATOR).join("_");
    if (DIGIT_SEPARATOR != " ")
      value = String(value).split(DIGIT_SEPARATOR).join("");
    else
      value = String(value).split(/\s+/).join("");
    value = String(value).split("_").join(".");
    return value;
  },

  beforeBlur: function () {
    var v = this.getRawValue();

    if (!Ext.isEmpty(v)) {
      this.setValue(v);
    }
  }
});

Ext.reg('largenumberfield', Ext.ux.form.LargeNumberField);
