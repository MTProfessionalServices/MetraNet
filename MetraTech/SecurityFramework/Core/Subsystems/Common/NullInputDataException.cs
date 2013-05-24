using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Core.Common;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Indicates that NULLs or empty value passed to some Security Framework engine.
    /// </summary>
    public class NullInputDataException : BadInputDataException
    {
        #region Constructors

        /// <summary>
        /// Creates an instance of the <see cref="NullInputDataException"/> class
        /// with specified source Subsystem and its Category names.
        /// </summary>
        /// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
        /// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
        /// <param name="eventType">Specifies a type of the event that caused the exception.</param>
        public NullInputDataException(string subsystemName, string categoryName, SecurityEventType eventType)
            : base(ExceptionId.General.Null.ToInt(), subsystemName, categoryName, "Input data is null", eventType, null, "NULL input value found")
        {
        }

        /// <summary>
        /// Creates an instance of the <see cref="NullInputDataException"/> class
        /// with specified message, source Subsystem and its Category names, a previous exception, and an Event category.
        /// </summary>
        ///<param name="id">Security problem Id</param>
        /// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
        /// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        /// <param name="eventType">Specifies a type of the event that caused the exception.</param>
        public NullInputDataException(int id, string subsystemName, string categoryName, string message, SecurityEventType eventType)
            : base(id, subsystemName, categoryName, message, eventType, null, "NULL input value found")
        {
        }

        /// <summary>
        /// Creates an instance of the <see cref="NullInputDataException"/> class
        /// with specified message, source Subsystem and its Category names, a previous exception, and an Event category.
        /// </summary>
        ///<param name="id">Security problem Id</param>
        /// <param name="subsystemName">Specifies a name of the subsystem a source engine belongs to.</param>
        /// <param name="categoryName">Specifies a name of the category a source engine belongs to.</param>
        /// <param name="message">A message describing the exception.</param>
        /// <param name="eventType">Specifies a type of the event that caused the exception.</param>
        /// <param name="inner">An exception that initailly caused the exception.</param>
        public NullInputDataException(int id, string subsystemName, string categoryName, string message, SecurityEventType eventType, Exception inner)
            : base(id, subsystemName, categoryName, message, eventType, inner)
        {
        }

        #endregion
    }
}
