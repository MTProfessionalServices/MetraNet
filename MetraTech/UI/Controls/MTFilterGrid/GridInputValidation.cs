using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Controls
{
  /// <summary>
  /// This class defines basic validation for grid editors
  /// </summary>
  public class GridInputValidation
  {
    private bool required = true;

    /// <summary>
    /// Indicates if validation should allow blank entries to pass thru
    /// </summary>
    public bool Required
    {
      get { return required; }
      set { required = value; }
    }
    
    private string minValue;

    /// <summary>
    /// Specifies minimum value that is allowed for the editor.
    /// Applies only to Numeric and Date filters
    /// </summary>
    public string MinValue
    {
      get { return minValue; }
      set { minValue = value; }
    }

    private string maxValue;

    /// <summary>
    /// Specifies maximum value that is allowed for the editor.
    /// Applies only to Numeric and Date filters
    /// </summary>
    public string MaxValue
    {
      get { return maxValue; }
      set { maxValue = value; }
    }

    private int minLength = 0;

    /// <summary>
    /// Specifies minimum input field length required (defaults to 0) 
    /// </summary>
    public int MinLength
    {
      get { return minLength; }
      set { minLength = value; }
    }

    private int maxLength = -1;

    /// <summary>
    /// Specifies maximum input field length required. Defaults to -1, implying sizeof(double) 
    /// </summary>
    public int MaxLength
    {
      get { return maxLength; }
      set { maxLength = value; }
    }

    private string regex;

    /// <summary>
    /// Regular expression pattern that is to be used to validate the value of the editor
    /// </summary>
    public string Regex
    {
      get { return regex; }
      set { regex = value; }
    }

    private string  validationFunction;

    /// <summary>
    /// A custom validation function to be called during field validation. 
    /// If specified, this function will be called only after the validations,
    /// such as allowBlank, minLength, maxLength, minValue, maxValue.
    /// 
    /// This function will be passed the current field value 
    /// and expected to return boolean true if the value is valid 
    /// or a string error message if invalid. 
    /// </summary>
    public string  ValidationFunction
    {
      get { return validationFunction; }
      set { validationFunction = value; }
    }

    private string validationType;

    /// <summary>
    /// A pre-set validation type name supported by MetraCare Validation,
    /// such as 'credit_card_number' or 'phone'
    /// </summary>
    public string ValidationType
    {
      get { return validationType; }
      set { validationType = value; }
    }
  }
}
