using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  public interface IBusinessKey
  {
    #region Properties
    string EntityFullName { get; set; }
    #endregion

    #region Methods

    object Clone();
    object GetValue(string propertyName);
    void SetValue(string propertyName, object value);

    #endregion
  }
}
