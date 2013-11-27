using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WizardTest
{
  class WizardValidation
  {
    private ErrorProvider _errorProvider;
    public WizardValidation(ErrorProvider errorProvider)
    {
      _errorProvider = errorProvider;
      this.IsValid = IsValid;
      IsValid = true;
    }

    public bool IsValid { get; set; }

    public void Required(Control control, string errorMessage)
    {
      if (string.IsNullOrEmpty(control.Text))
      {
        _errorProvider.SetError(control, errorMessage);
        IsValid = false;
      }
      else
      {
        _errorProvider.SetError(control, string.Empty);
      }
    }

    public bool MaxLength(Control control, int length)
    {
      return control.Text.Length <= length;
    }


  }
}
