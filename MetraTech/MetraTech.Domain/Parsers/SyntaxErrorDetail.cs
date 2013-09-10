namespace MetraTech.Domain.Parsers
{
    /// <summary>
    /// Holds information about a syntax error in an expression
    /// </summary>
    public class SyntaxErrorDetail
    {
        public int Line { get; private set; }
        public int CharacterPosition { get; private set; }
        public string Message { get; private set; }

        public SyntaxErrorDetail(int line, int characterPosition, string message)
        {
            Line = line;
            CharacterPosition = characterPosition;
            Message = message;
        }
    }
}
