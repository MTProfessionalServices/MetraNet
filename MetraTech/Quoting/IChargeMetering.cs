// -----------------------------------------------------------------------
// <copyright file="IMetering.cs" company="Microsoft">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace MetraTech.Quoting
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using MetraTech.Domain.Quoting;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public interface IChargeMetering
    {
        /// <summary>
        /// Generates ID Batch and return it
        /// </summary>
        /// <returns>ID Batch</returns>
        string InitBatch();

        /// <summary>
        /// SAtarting meter Charges
        /// </summary>
        /// <param name="chargeData"><see cref="MetraTech.Domain.Quoting.ChargeData"/></param>
        void MeterRecodrs(ChargeData chargeData);

    }
}
