// Currency formatters
if (Ext.util.Format) {
  if (!Ext.util.Format.CurrencyFactory) {
    Ext.util.Format.CurrencyFactory = function (dp, dSeparator, tSeparator, symbol, rightPosition) {
      return function (n) {

        dp = Math.abs(dp) + 1 ? dp : 2;
        dSeparator = dSeparator || ".";
        tSeparator = tSeparator || ",";
        symbol = symbol || "$";
        rightPosition = rightPosition || false;

        var m = /(\d+)(?:(\.\d+)|)/.exec(n + ""),
                x = m[1].length > 3 ? m[1].length % 3 : 0;

        var v = (n < 0 ? '-' : '') // preserve minus sign
                + (x ? m[1].substr(0, x) + tSeparator : "")
                + m[1].substr(x).replace(/(\d{3})(?=\d)/g, "$1" + tSeparator)
                + (dp ? dSeparator + (+m[2] || 0).toFixed(dp).substr(2) : "");

        return rightPosition ? v + symbol : symbol + v;
      };
    };
  }
}  
var eurFormatter = Ext.util.Format.CurrencyFactory(2, ",", ".", "\u20ac", true);
var usFormatter = Ext.util.Format.CurrencyFactory(2);

// Custom Renderers
CheckRenderer = function(value, meta, record, rowIndex, colIndex, store)
{
  var str = "";
  if(value == true)
  {
     return "<img border='0' src='/Res/Images/Icons/tick.png'>";
  }
  else if (value == false)
  {
    return "--";
  }
  
  return str;
};

BulletRenderer = function(value, meta, record, rowIndex, colIndex, store)
{
  var str = "";
  if(value == true)
  {
     return "<img border='0' src='/Res/Images/Icons/bullet_black.png'>";
  }
  else if (value == false)
  {
    return "";
  }
  
  return str;
};

function RenderDate(value, format)
{
  if ((value == null) || (value.indexOf('0001') != -1) ) //Latter corresponds to .NET Date.MinValue
  {
    return '';
  }

  var refDate = Date.parseDate(value, DATE_TIME_RENDERER);

  // if DATE_TIME_RENDERER does not match date value
  // in case Spanish-Mexican localization
  if (refDate === undefined) {
    if (value.indexOf('p.m.') > 0 ) {
      refDate = Date.parseDate(value.replace('p.m.', 'PM'), DATE_TIME_RENDERER);
    }
    if (value.indexOf('a.m.') > 0) {
      refDate = Date.parseDate(value.replace('a.m.', 'AM'), DATE_TIME_RENDERER);
    }
  }
  
  var retDate = new Date(refDate).format(format);
  return retDate;  
}

DateRenderer = function(value, meta, record, rowIndex, colIndex, store)
{
  return RenderDate(value, DATE_FORMAT);
};

DateTimeRenderer = function(value, meta, record, rowIndex, colIndex, store) {
  return RenderDate(value, DATE_TIME_RENDERER);
};

LongDateRenderer = function (value, meta, record, rowIndex, colIndex, store) {
  //Same as DateTimeRenderer; left for backwards compatibility
  return DateTimeRenderer(value, meta, record, rowIndex, colIndex, store);
};

CurrencyRenderer = function (value, meta, record, rowIndex, colIndex, store) {
  meta.attr = "align='right'";

  var regOnlyDec = /^-?\d+\.?\d+$/;
  if (regOnlyDec.test(value)) {
    return "<span class='amount'>" + parseFloat(value).toLocaleString(CURRENT_LOCALE, { maximumFractionDigits: FRACTION_DIGITS, minimumFractionDigits: FRACTION_DIGITS }) + "</span>";
  } else
    return "<span class='amount'>" + value + "</span>";
};

ARCurrencyRenderer = function (value, meta, record, rowIndex, colIndex, store) {
  meta.attr = "align='right'";
  var color = "black";
  //if (record.data.RemittanceDetailType) {
    if (record.data.RemittanceDetailType == 0) {  // DemandForPayment
          color = "red";
    }
  //}
  if (value != null)
    return "<span class='amount' style='color:" + color + "'>" + usFormatter(value) + "</span>";
  else
    return "";
};

//boolean renderer
BooleanRenderer = function (value) {
  if ((value + '').toLowerCase() == 'true') {
    return '<img border=\'0\' src=\'/Res/Images/Icons/tick.png\'>';
  }

  if ((value + '').toLowerCase() == 'false') {
    return '<img border=\'0\' src=\'/Res/Images/Icons/cross.png\'';
  }

  return '';
};

HTMLContentRenderer = function (value, meta, record, rowIndex, colIndex, store) {
    return "<html>" + value + "</html>";
};


NoTrailingZerosRenderer = function (value, meta, record, rowIndex, colIndex, store) {
    var nan = isNaN(value);
    if (!value || (value.length == 0) || nan) {
      return nan ? '' : value;
    }

    // Remove all trailing zeros after the decimal point.
    var newValue = value.replace(/(\.(?:\d*[1-9])?)0+$/, '$1');

    return newValue;
};

//SECENG:
Ext.override(Ext.grid.ColumnModel, {
    defaultRenderer: function (value) {
        if (typeof value == "string") {
            if (value.length < 1) {
                return "&#160;";
            } else {
                return Ext.util.Format.htmlEncode(value);
            }
        }
        return value;
    }
});

//SECENG:
Ext.override(Ext.grid.Column, {
    renderer: function (value) {
        if (typeof value == "string") {
            if (value.length < 1) {
                return "&#160;";
            } else {
                return Ext.util.Format.htmlEncode(value);
            }
        }
        return value;
    }
});
