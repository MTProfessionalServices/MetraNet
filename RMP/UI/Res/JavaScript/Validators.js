
Ext.onReady(function () {

  // Add the additional 'advanced' VTypes
  // password
  Ext.apply(Ext.form.VTypes, {
    'password': function (val, field) {
      if (field.initialPassField) {
        var pwd = Ext.getCmp(field.initialPassField);
        return (val == pwd.getValue());
      }
      return true;
    },
    'passwordText': 'Passwords do not match.'
  });

  // phone 
  Ext.apply(Ext.form.VTypes, {
    'phone': function () {
      var re = /^\(?\d{3}\)?([-\/\.\s])\d{3}\1\d{4}$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'phoneText': 'The format is wrong, ie: 305-444-1234'
  });

  // credit card number 
  Ext.apply(Ext.form.VTypes, {
    'credit_card_number': function () {
      var re = /^\d[\d-]{11,24}$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'credit_card_numberText': 'Credit card format is invalid'
  });

  // credit card verification number
  Ext.apply(Ext.form.VTypes, {
    'cv_number': function () {
      var re = /[\d-]{3,4}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'cv_numberText': 'CV Number is invalid'
  });

  //ssn
  Ext.apply(Ext.form.VTypes, {
    'ssn': function () {
      var re = /^([0-6]\d{2}|7[0-6]\d|77[0-2])([ \-]?)(\d{2})\2(\d{4})$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'ssnText': 'SSN format: xxx-xx-xxxx'
  });


  //Account number, routing number
  Ext.apply(Ext.form.VTypes, {
    'digits': function () {
      var re = /[\d-]{11,20}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'digitsText': 'Only numeric digits are allowed'
  });


  // zipcode
  Ext.apply(Ext.form.VTypes, {
    'zipcode': function () {
      var re = /[\d-]{5}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'zipcodeText': 'Zipcode is invalid'
  });
  
  //Middle Initial
  Ext.apply(Ext.form.VTypes, {
    'middleinitial': function () {
      var re = /[a-zA-Z]/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'middleinitialText': 'Middle initial is invalid'
  });

  // Decision Name
  Ext.apply(Ext.form.VTypes, {
    'decisionRelatedName': function () {
      var re = /^[^'"]*$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'decisionRelatedNameText': TEXT_AMPWIZARD_AMP_UI_NAME_ILLEGAL_CHAR
  });

});