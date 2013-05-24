using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.UI.Controls.MTLayout
{
  /// <summary>
  /// This class defines layout parameters for inline grid editors
  /// </summary>
  [Serializable]
  public class InputValidationLayout
  {    
    /// <summary>
    /// Indicates if validation should allow blank entries to pass thru
    /// </summary>
    public bool Required = false;

    /// <summary>
    /// Specifies minimum value that is allowed for the editor.
    /// Applies only to Numeric and Date filters
    /// </summary>
    public string MinValue;

    /// <summary>
    /// Specifies maximum value that is allowed for the editor.
    /// Applies only to Numeric and Date filters
    /// </summary>
    public string MaxValue;

    /// <summary>
    /// Specifies minimum input field length required (defaults to 0) 
    /// </summary>
    public int MinLength = 0;

    /// <summary>
    /// Specifies maximum input field length required. Defaults to -1, implying sizeof(double) 
    /// </summary>
    public int MaxLength = -1;

    /// <summary>
    /// Regular expression pattern that is to be used to validate the value of the editor
    /// </summary>
    public string Regex;

    /// <summary>
    /// A custom validation function to be called during field validation. 
    /// If specified, this function will be called only after the validations,
    /// such as allowBlank, minLength, maxLength, minValue, maxValue.
    /// 
    /// This function will be passed the current field value 
    /// and expected to return boolean true if the value is valid 
    /// or a string error message if invalid. 
    /// </summary>
    public string ValidationFunction;

    /// <summary>
    /// A pre-set validation type name supported by MetraCare Validation,
    /// such as 'credit_card_number' or 'phone'
    /// </summary>
    public string ValidationType;

  }
}
