using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// We need to model UoMs. It would see that we'd want:
    /// * UomCategory: e.g., Time, Memory (or whatever we call bytes), Volumne, Length, etc.
    /// * UomValue: these are within a UoM category (e.g., Minutes and Seconds would be within Time)
    /// </summary>
    public class UoM
    {
    }
}
