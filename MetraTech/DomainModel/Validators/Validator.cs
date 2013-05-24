using System;
using System.Collections.Generic;
using System.Text;

namespace MetraTech.DomainModel.Validators
{
  public interface IValidator
  {
    /// <summary>
    ///    Validate the given object 
    ///    - If the object is valid then return true
    ///    - If the object is invalid then return false and a list of validation error strings.
    /// </summary>
    /// <param name="obj"></param>
    /// <param name="validationErrors"></param>
    /// <returns></returns>
    bool Validate(object obj, out List<string> validationErrors);
  }
}
