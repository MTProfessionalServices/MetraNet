namespace MetraTech.ICE
{
    //The MetraNet datatypes. The underscores were used because MetraNet's datatypes are reserved words in C#
    public enum DataType
    {
        _string,
        _unistring,
        _int,
        _int32,
        _int64,
        _timestamp,
        _enum,
        _decimal,
        _float,
        _double,
        _boolean,
        _element,
        _any,
        _numeric,
        _guid,
        _binary,
        _bme,
        _record,
        _sqlsubstitution,
        _uniqueidentifier,
        _unknown
    }
}
