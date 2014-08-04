﻿
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
    'passwordText': TEXT_PASSWORD_VALIDATION_MESSAGE
  });

  // phone 
  Ext.apply(Ext.form.VTypes, {
    'phone': function () {
      var re = /^\(?\d{3}\)?([-\/\.\s])\d{3}\1\d{4}$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'phoneText': TEXT_PHONE_VALIDATION_MESSAGE
  });

  // credit card number 
  Ext.apply(Ext.form.VTypes, {
    'credit_card_number': function () {
      var re = /^\d[\d-]{11,24}$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'credit_card_numberText': TEXT_CREDITCARD_VALIDATION_MESSAGE
  });

  // credit card verification number
  Ext.apply(Ext.form.VTypes, {
    'cv_number': function () {
      var re = /[\d-]{3,4}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'cv_numberText': TEXT_CREDITCARD_VERIFICATIONNO_VALIDATION_MESSAGE
  });

  //ssn
  Ext.apply(Ext.form.VTypes, {
    'ssn': function () {
      var re = /^([0-6]\d{2}|7[0-6]\d|77[0-2])([ \-]?)(\d{2})\2(\d{4})$/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'ssnText': TEXT_SSN_VALIDATION_MESSAGE
  });


  //Account number, routing number
  Ext.apply(Ext.form.VTypes, {
    'digits': function () {
      var re = /[\d-]{11,20}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'digitsText': TEXT_ACCOUNTNO_VALIDATION_MESSAGE
  });


  // zipcode
  Ext.apply(Ext.form.VTypes, {
    'zipcode': function () {
      var re = /[\d-]{5}/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'zipcodeText': TEXT_ZIPCODE_VALIDATION_MESSAGE
  });
  
  //Middle Initial
  Ext.apply(Ext.form.VTypes, {
    'middleinitial': function () {
      var re = /[a-zA-Z]/;
      return function (v) {
        return re.test(v);
      }
    } (),
    'middleinitialText': TEXT_MIDDLEINITIAL_VALIDATION_MESSAGE
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