using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using Newtonsoft.Json;

namespace MetraTech.Custom.Json.Converters
{
    /// <summary>
    /// Converts a <see cref="DateTime"/> to and from the current default date format (no conversions)
    /// </summary>
    public class PlainDateTimeConverter : Newtonsoft.Json.Converters.IsoDateTimeConverter // DateTimeConverterBase
    {
        /// <summary>
        /// Writes the JSON representation of the object.
        /// </summary>
        /// <param name="writer">The <see cref="JsonWriter"/> to write to.</param>
        /// <param name="value">The value.</param>
        /// <param name="serializer">The calling serializer.</param>
        //public override void WriteJson(JsonWriter writer, object value /*, JsonSerializer serializer*/)
        public void WriteJson(JsonWriter writer, object value /*, JsonSerializer serializer*/)
        {
            string text;

            if (value is DateTime)
            {
                DateTime dateTime = (DateTime)value;
                text = dateTime.ToString();
            }
            else
            {
                throw new Exception("Unexpected value when converting date");
            }

            writer.WriteValue(text);
        }


        public bool IsNullableType(Type t)
        {
            return (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(Nullable<>));
        }

        /// <summary>
        /// Reads the JSON representation of the object.
        /// </summary>
        /// <param name="reader">The <see cref="JsonReader"/> to read from.</param>
        /// <param name="objectType">Type of the object.</param>
        /// <param name="existingValue">The existing value of object being read.</param>
        /// <param name="serializer">The calling serializer.</param>
        /// <returns>The object value.</returns>
        //public override object ReadJson(JsonReader reader, Type objectType /*, object existingValue, JsonSerializer serializer*/)
        public object ReadJson(JsonReader reader, Type objectType /*, object existingValue, JsonSerializer serializer*/)
        {
            bool nullable = IsNullableType(objectType);
            Type t = (nullable)
              ? Nullable.GetUnderlyingType(objectType)
              : objectType;

            if (reader.TokenType == JsonToken.Null)
            {
                if (!IsNullableType(objectType))
                    throw new Exception("Cannot convert null value");

                return null;
            }

            if (reader.TokenType != JsonToken.String)
                throw new Exception("Unexpected token parsing date. Expected String");

            string dateText = reader.Value.ToString();

            if (string.IsNullOrEmpty(dateText) && nullable)
                return null;

            return DateTime.Parse(dateText);
        }
    }
}
