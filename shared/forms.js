
//////////////////////////////////////////////////////////////////////////////////
// GetComboBoxIndex -- get the index of the selected combo box item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetComboBoxIndex(strForm, strElement)
{
  var i, intLen, el;
  
  //Check for the form element to exist
  el = document.getElementById(strElement)
  if(el != null) {
    intLen = el.length;
    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(el.options[i].selected == true)
          return i;
      }
    }
  }

  return(-1); //unable to get the index
  
}
//////////////////////////////////////////////////////////////////////////////////
// GetComboBoxValue -- attempt to the the current value of the combo box item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetComboBoxValue(strForm, strElement)
{
  var i, intLen;
  
  //Check for the form element to exist
  el = document.getElementById(strElement)
  if(el != null) {
    intLen = el.length;
    if(intLen != null ) {
      for(i=0; i < intLen; i++) {
        if(el.options[i].selected == true)
          return(el.options[i].text);
      }
    }
  }

  return(''); //unable to get the index

}
//////////////////////////////////////////////////////////////////////////////////
// GetElementValue -- attempt to the the current value of the item
//////////////////////////////////////////////////////////////////////////////////
function frmsGetElementValue(strForm, strElement)
{
  var strVal, intLen, el;
 
  el = document.getElementById(strElement)
  if(el != null) {
    intLen = el.length;
    if(intLen != null ) {
      strVal = frmsGetComboBoxValue(strForm, strElement);
      return(strVal);
    } else {
      if(el.value != null) {
        return(el.value);
      }
    }
  }
  
  return('');
}
//////////////////////////////////////////////////////////////////////////////////
// CheckIntVal -- check to see if the character is an integer
//////////////////////////////////////////////////////////////////////////////////
function frmsCheckIntVal(cVal)
{
  var i = 0;
  var arrIntVals = new Array(10);
  arrIntVals[0] = '0';
  arrIntVals[1] = '1';
  arrIntVals[2] = '2';
  arrIntVals[3] = '3';
  arrIntVals[4] = '4';
  arrIntVals[5] = '5';
  arrIntVals[6] = '6';
  arrIntVals[7] = '7';
  arrIntVals[8] = '8';
  arrIntVals[9] = '9';

 
  for(i = 0; i < arrIntVals.length; i++) {
    if(cVal == arrIntVals[i]) {
      return(true);
    }
  }

  return(false);
}
//////////////////////////////////////////////////////////////////////////////////
// CheckAlphaVal -- check to see if a character is an alphabetic character
//////////////////////////////////////////////////////////////////////////////////
function frmsCheckAlphaVal(cVal)
{
  var i = 0;
  
  var arrAlphaVals = new Array(52);
  
  //Build the array of lower-case alpha characters
  arrAlphaVals[0] = 'a';
  arrAlphaVals[1] = 'b';
  arrAlphaVals[2] = 'c';
  arrAlphaVals[3] = 'd';
  arrAlphaVals[4] = 'e';
  arrAlphaVals[5] = 'f';
  arrAlphaVals[6] = 'g';
  arrAlphaVals[7] = 'h';
  arrAlphaVals[8] = 'i';
  arrAlphaVals[9] = 'j';
  arrAlphaVals[10] = 'k';
  arrAlphaVals[11] = 'l';
  arrAlphaVals[12] = 'm';
  arrAlphaVals[13] = 'n';
  arrAlphaVals[14] = 'o';
  arrAlphaVals[15] = 'p';
  arrAlphaVals[16] = 'q';
  arrAlphaVals[17] = 'r';
  arrAlphaVals[18] = 's';
  arrAlphaVals[19] = 't';
  arrAlphaVals[20] = 'u';
  arrAlphaVals[21] = 'v';
  arrAlphaVals[22] = 'w';
  arrAlphaVals[23] = 'x';
  arrAlphaVals[24] = 'y';
  arrAlphaVals[25] = 'z';
  
  //Add the upper case characters
  for(i = 0; i < (arrAlphaVals.length / 2); i++)
    arrAlphaVals[i + 26] = arrAlphaVals[i].toUpperCase;
    
  //Check the valid alpha characters
  for(i = 0; i < arrAlphaVals.length; i++)
    if(cVal == arrAlphaVals[i])
      return(true);

  //The value was never found, return false
  return(false);
}
//////////////////////////////////////////////////////////////////////////////////
// CheckValidString(strValue, bAlphaCheck, bNumCheck, arrExtraValid)
//////////////////////////////////////////////////////////////////////////////////
function frmsCheckValidString(strValue, bAlphaCheck, bNumCheck, bExtra, arrExtraValid)
{
  var bValid = false;
  var i = 0;
  var j = 0;
  
  //Check each character
  for(i = 0; i < strValue.length; i++)
  {
    bValid = false;
    
    //Alphabetic characters
    if(bAlphaCheck)
      if(frmsCheckAlphaVal(strValue.charAt(i)))
        bValid = true;
   
    //Numeric Characters
    if(bNumCheck)
      if(frmsCheckIntVal(strValue.charAt(i)))
        bValid = true;
    
    
    //Additional Characters
    if(bExtra)
    {
      for(j = 0; j < arrExtraValid.length; j++)
        if(strValue.charAt(i) == arrExtraValid[j])
          bValid = true;
    }
    
    //If the character wasn't valid, return false
    if(!bValid)
      return(false);
  }
  
  return(true);
}
//////////////////////////////////////////////////////////////////////////////////
// ValidatePtypeData -- validate that the selected value is in the correct format
//                      for the ptype
//////////////////////////////////////////////////////////////////////////////////
function frmsValidatePtypeData(strData, strPtype)
{
  var bValid = false;
  var i = 0, j = 0;

  //Appropriate values for integers
  
  //Refers not to the enumerated types, but how they appear
  //in the combo box.
  var PTYPE_INTEGER   = 'integer';
  var PTYPE_DOUBLE    = 'double';
  var PTYPE_STRING    = 'string';
  var PTYPE_DATETIME  = 'datetime';
  var PTYPE_TIME      = 'time';
  var PTYPE_BOOLEAN   = 'bool';
  var PTYPE_ENUM      = 'enum';
  var PTYPE_DECIMAL   = 'decimal';

  //Convert data for examination  
  strData = strData.toString();
  strData = strData.toLowerCase();

  strPtype = strPtype.toString();
  strPtype = strPtype.toLowerCase();

  switch(strPtype) {
    case PTYPE_INTEGER:
      //Check for valid letters
      //The first letter is special, it can be a '-'
      bValid = frmsCheckIntVal(strData.charAt(0));
      
      if(strData.charAt(0) == '-')
        bValid = true;
  
      if(!bValid)
        return(false); 

      //Now check the rest
      for(i = 1; i < strData.length; i++) {
        bValid = frmsCheckIntVal(strData.charAt(i));
        if(!bValid)
          return(false);
      }
      
      return(true);
    break;
    
    case PTYPE_DECIMAL:  //decimal has same format as double(in terms of value checking)
    case PTYPE_DOUBLE:
      var intDotCount = 0;
      
      //The first letter is special, it can be a '-'
      bValid = frmsCheckIntVal(strData.charAt(0));
      if(strData.charAt(0) == '-')
        bValid = true;
        
      if(!bValid)
        return(false); 
      
      //Now check the rest
      for(i = 1; i < strData.length; i++) {
        bValid = frmsCheckIntVal(strData.charAt(i));
        
        //Also look for decimal points
        if(strData.charAt(i) == '.') {          //
          if(intDotCount == 0) {
            bValid = true;
          }
          intDotCount++;
        }
          
        if(!bValid)
        return(false);
      }
      
      //Nothing failed...
      return(true);
    
    case PTYPE_STRING:  //strings can be anything
      return(true);
      break;

  
    case PTYPE_DATETIME:
//      1998-01-01T00:00:00Z  -- format    
      //Check the length
      if(strData.length != 20)
        return(false);

      //Check the numeric digits
      for(i = 0; i < 3; i++) {
        bValid = frmsCheckIntVal(strData.charAt(i));
        
        //A non-numeric character was found
        if(!bValid)
          return(false);
      }
      
      //Check the other numbers
      if(!frmsCheckIntVal(strData.charAt(5)))
        return(false);  
      if(!frmsCheckIntVal(strData.charAt(6)))
        return(false);

      if(!frmsCheckIntVal(strData.charAt(8)))
        return(false);  
      if(!frmsCheckIntVal(strData.charAt(9)))
        return(false);

      if(!frmsCheckIntVal(strData.charAt(11)))
        return(false);  
      if(!frmsCheckIntVal(strData.charAt(12)))
        return(false);
        
      if(!frmsCheckIntVal(strData.charAt(14)))
        return(false);  
      if(!frmsCheckIntVal(strData.charAt(15)))
        return(false);

      if(!frmsCheckIntVal(strData.charAt(17)))
        return(false);  
      if(!frmsCheckIntVal(strData.charAt(18)))
        return(false);

      //Check for dashes
      if(strData.charAt(4) != '-')
        return(false);
        
      if(strData.charAt(7) != '-')
        return(false);

      //Check for colons
      if(strData.charAt(13) != ':')
        return(false);

      if(strData.charAt(16) != ':')
        return(false);

      //Check for format specifiers
      if(strData.charAt(10) != 't')
        return(false);
                
      if(strData.charAt(19) != 'z')
        return(false);

      //if the function got here, the number is valid        
      return(true)
      break;
      
    case PTYPE_TIME:
      //HH:MMAM or HH:MMPM
      //check the length

      strData = strData.toUpperCase();
      if(strData.length != 7)
        return(false);

      //Check the first digit
      if(strData.charAt(0) > '1' || strData.charAt(0) < '0')
        return(false);

      if(strData.charAt(0) == '1') {
        if(strData.charAt(1) > '2' || strData.charAt(0) < '0')
          return(false);
      } else {
        if(!frmsCheckIntVal(strData.charAt(1)))
          return(false);
      }     

      if(strData.charAt(2) != ':')
        return(false);

      if(strData.charAt(3) > '5'  || strData.charAt(0) < '0')
        return(false);

      if(!frmsCheckIntVal(strData.charAt(4)))
        return(false);  
   
      //Check AM/PM
      if(strData.charAt(5) != 'P' && strData.charAt(5) != 'A')
        return(false)
      
      if(strData.charAt(6) != 'M')
        return(false);

      //The number is good!
      return(true);

      break;    
    case PTYPE_BOOLEAN:
      if(strData == 'true' || strData == 'false' || strData == 'yes' || strData == 'no' || strData == '0' || 
         strData == '1' || strData == 'y' || strData == 'n')
         return(true);
      else
        return(false);
      break;
    
    case PTYPE_ENUM:
      return(true);
      break;
    
    default:
      break;
  }
  return(false);
}
