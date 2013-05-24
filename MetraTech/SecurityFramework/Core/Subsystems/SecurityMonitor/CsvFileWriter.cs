/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework.Common;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor
{
    /// <summary>
    /// Provides a writer to record security events to a CSV formatted file.
    /// </summary>
    internal class CsvFileWriter : SecurityEventWriter
    {
        #region Constants

        private const string CharactersToQuote = " \t\n\t\r\",";
        
        #endregion

        #region Private fields

        string _fileName;
        private List<TableColumn> _columnNames;
        private Dictionary<string, string> _record;
        private bool _rollFileName;

        #endregion

		#region Properties

		/// <summary>
		/// Gets a value indicating the writer supports recording info about recommended security policy actions.
		/// </summary>
		/// <remarks>always False</remarks>
		public override bool SupportsActionsRecording
		{
			get
			{
				return false;
			}
		}

		#endregion

		#region Constructors

		/// <summary>
        /// Creates an instance of the <see cref="CsvFileWriter"/> class.
        /// </summary>
        /// <param name="fileName">A name of the file to write the data to.</param>
        /// <param name="columnNames">A list of column names.</param>
        public CsvFileWriter(string fileName, IEnumerable<TableColumn> columnNames, bool rollFileName)
        {
            _fileName = fileName;
            _columnNames = new List<TableColumn>(columnNames);
            _rollFileName = rollFileName;
        }

        /// <summary>
        /// Creates an instance of the <see cref="CsvFileWriter"/> class.
        /// </summary>
        /// <param name="fileName">A name of the file to write the data to.</param>
        public CsvFileWriter(string fileName)
        {
            _fileName = fileName;
        }

        #endregion

        #region Overriden methods

        /// <summary>
        /// Accurate an exclusive lock. Starts writing of the event data.
        /// </summary>
        public override void BeginRecord()
        {
            base.BeginRecord();

            _record = new Dictionary<string, string>();
        }

        /// <summary>
        /// Finishes writing of the event data. Releases an exclusive lock.
        /// </summary>
        public override void EndRecord()
        {
            try
            {
                WriteRecord();
                _record = null;
            }
            finally
            {
                base.EndRecord();
            }
        }

		/// <summary>
		/// Writes a string field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, string value)
        {
            SetValue(fieldName, value);
        }

		/// <summary>
		/// Writes an integer field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, int value)
        {
            SetValue(fieldName, value.ToString(CultureInfo.InvariantCulture));
        }

		/// <summary>
		/// Writes a nullable integer value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, int? value)
		{
			SetValue(fieldName, value.HasValue ? value.Value.ToString() : null);
		}

		/// <summary>
		/// Writes a boolean field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, bool value)
        {
            SetValue(fieldName, value.ToString(CultureInfo.InvariantCulture));
        }

		/// <summary>
		/// Writes a date/time field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, DateTime value)
        {
            SetValue(fieldName, value.ToString(Constants.Formatting.ISO8601DateFormat));
        }

		/// <summary>
		/// Writes an event type field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, SecurityEventType value)
        {
            SetValue(fieldName, value.ToString(Constants.Formatting.EnumToStringFormat));
		}

		/// <summary>
		/// Writes a double field value.
		/// </summary>
		/// <param name="fieldName">A field name.</param>
		/// <param name="value">A field value.</param>
		public override void Write(string fieldName, double value)
		{
			SetValue(fieldName, value.ToString(CultureInfo.InvariantCulture));
		}

		/// <summary>
		/// Is not supported.
		/// </summary>
		public override void BeginRecordAction()
		{
			throw new NotSupportedException();
		}

		/// <summary>
		/// Is not supported.
		/// </summary>
		public override void EndRecordAction()
		{
			throw new NotSupportedException();
		}

        #endregion

        #region Private methods

        private void SetValue(string fieldName, string value)
        {
            if (_record == null)
            {
                throw new InvalidOperationException("Writing record is not started. Call BeginRecord() method at first.");
            }

            if (_columnNames.Exists(p => p.Name == fieldName))
            {
                _record[fieldName] = value ?? string.Empty;
            }
        }

        private void WriteRecord()
        {
            // Roll the output file.
            if (_rollFileName && File.Exists(_fileName) && File.GetLastWriteTime(_fileName) < DateTime.Today)
            {
                ArchiveLogFile();
            }

            // Write the data
            using (FileStream file = File.Open(_fileName, FileMode.Append))
            {
                using (TextWriter writer = new StreamWriter(file))
                {
                    if (file.Length == 0)
                    {
                        WriteColumnCaptions(writer);
                    }

                    WriteRecord(writer);
                }
            }
        }

        private void WriteColumnCaptions(TextWriter writer)
        {
            for (int i = 0; i < _columnNames.Count; i++)
            {
                if (i > 0)
                {
                    writer.Write(Constants.Formatting.Comma);
                }

                WriteValue(writer, _columnNames[i].Caption);
            }

            writer.WriteLine();
        }

        private void WriteRecord(TextWriter writer)
        {
            for (int i = 0; i < _columnNames.Count; i++)
            {
                string value =
                    _record.ContainsKey(_columnNames[i].Name) ? _record[_columnNames[i].Name] : string.Empty;

                if (i > 0)
                {
                    writer.Write(Constants.Formatting.Comma);
                }

                WriteValue(writer, value);
            }

            writer.WriteLine();
        }

        private void ArchiveLogFile()
        {
            string newFileName;
            newFileName = PickFileName(
                Path.Combine(Path.GetDirectoryName(_fileName), Path.GetFileNameWithoutExtension(_fileName)),
                Path.HasExtension(_fileName) ? Path.GetExtension(_fileName) : string.Empty,
                File.GetLastWriteTime(_fileName));

            // One more check if the file still exists to avoid possible issues.
            if (File.Exists(_fileName))
            {
                File.Move(_fileName, newFileName);
            }
        }

        /// <summary>
        /// Generate a name for an archived log file.
        /// The name contains a date when a file was last changed and is unique.
        /// </summary>
        /// <param name="filePath">File path without extension.</param>
        /// <param name="extension">File extension.</param>
        /// <param name="modificationDate">The date when a file was modified.</param>
        /// <returns>An unique file name.</returns>
        private string PickFileName(string filePath, string extension, DateTime modificationDate)
        {
            string dateStr = modificationDate.ToString(Constants.Formatting.SortableDateFormat);
            string newFileName = string.Concat(filePath, dateStr, extension);

            for (int i = 0; File.Exists(newFileName) && i < int.MaxValue; i++)
            {
                newFileName = string.Concat(filePath, dateStr, ".", i.ToString(), extension);
            }

            return newFileName;
        }

        private void WriteValue(TextWriter writer, string value)
        {
            value = value.Replace("\"", "\"\"");
            bool quote = value.IndexOfAny(CharactersToQuote.ToCharArray()) >= 0;

            if (quote)
            {
                value = string.Format(Constants.Formatting.QuotationFormat, value);
            }

            writer.Write(value);
        }

        #endregion
    }
}
