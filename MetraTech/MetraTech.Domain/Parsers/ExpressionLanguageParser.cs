// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using System;

using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;
using System.Collections.Generic;
using DFA = Antlr4.Runtime.Dfa.DFA;

public partial class ExpressionLanguageParser : Parser {
	public const int
		T__2=1, T__1=2, T__0=3, TEXT=4, STRING=5;
	public static readonly string[] tokenNames = {
		"<INVALID>", "','", "'\n'", "'\r'", "TEXT", "STRING"
	};
	public const int
		RULE_file = 0, RULE_hdr = 1, RULE_row = 2, RULE_field = 3;
	public static readonly string[] ruleNames = {
		"file", "hdr", "row", "field"
	};

	public override string GrammarFileName { get { return "ExpressionLanguage.g4"; } }

	public override string[] TokenNames { get { return tokenNames; } }

	public override string[] RuleNames { get { return ruleNames; } }

	public ExpressionLanguageParser(ITokenStream input)
		: base(input)
	{
		_interp = new ParserATNSimulator(this,_ATN);
	}
	public partial class FileContext : ParserRuleContext {
		public int i=0;
		public HdrContext _hdr;
		public RowContext _row;
		public IList<RowContext> _rows = new List<RowContext>();
		public RowContext row(int i) {
			return GetRuleContext<RowContext>(i);
		}
		public HdrContext hdr() {
			return GetRuleContext<HdrContext>(0);
		}
		public RowContext[] row() {
			return GetRuleContexts<RowContext>();
		}
		public FileContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_file; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterFile(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitFile(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitFile(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public FileContext file() {
		FileContext _localctx = new FileContext(_ctx, State);
		EnterRule(_localctx, 0, RULE_file);
		int _la;
		try {
			EnterOuterAlt(_localctx, 1);
			{
			State = 8; _localctx._hdr = hdr();
			State = 12;
			_errHandler.Sync(this);
			_la = _input.La(1);
			do {
				{
				{
				State = 9; _localctx._row = row((_localctx._hdr!=null?_input.GetText(_localctx._hdr.start,_localctx._hdr.stop):null).Split(','));
				_localctx._rows.Add(_localctx._row);
				_localctx.i++;
				}
				}
				State = 14;
				_errHandler.Sync(this);
				_la = _input.La(1);
			} while ( (((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 1) | (1L << 2) | (1L << 3) | (1L << TEXT) | (1L << STRING))) != 0) );

			       Console.WriteLine(_localctx.i+" rows");
			       foreach (RowContext r in _localctx._rows) {
			           Console.WriteLine("row token interval: "+ r.SourceInterval);
			       }
			       
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.ReportError(this, re);
			_errHandler.Recover(this, re);
		}
		finally {
			ExitRule();
		}
		return _localctx;
	}

	public partial class HdrContext : ParserRuleContext {
		public RowContext row() {
			return GetRuleContext<RowContext>(0);
		}
		public HdrContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_hdr; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterHdr(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitHdr(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitHdr(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public HdrContext hdr() {
		HdrContext _localctx = new HdrContext(_ctx, State);
		EnterRule(_localctx, 2, RULE_hdr);
		try {
			EnterOuterAlt(_localctx, 1);
			{
			State = 18; row(null);
			Console.WriteLine("header: '"+_input.GetText(_localctx.start, _input.Lt(-1)).Trim()+"'");
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.ReportError(this, re);
			_errHandler.Recover(this, re);
		}
		finally {
			ExitRule();
		}
		return _localctx;
	}

	public partial class RowContext : ParserRuleContext {
		public String[] columns;
		public Dictionary<String,String> values;
		public int col=0;
		public FieldContext _field;
		public FieldContext[] field() {
			return GetRuleContexts<FieldContext>();
		}
		public FieldContext field(int i) {
			return GetRuleContext<FieldContext>(i);
		}
		public RowContext(ParserRuleContext parent, int invokingState) : base(parent, invokingState) { }
		public RowContext(ParserRuleContext parent, int invokingState, String[] columns)
			: base(parent, invokingState)
		{
			this.columns = columns;
		}
		public override int GetRuleIndex() { return RULE_row; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterRow(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitRow(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitRow(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public RowContext row(String[] columns) {
		RowContext _localctx = new RowContext(_ctx, State, columns);
		EnterRule(_localctx, 4, RULE_row);

		    _localctx.values =  new Dictionary<String,String>();

		int _la;
		try {
			EnterOuterAlt(_localctx, 1);
			{
			State = 21; _localctx._field = field();

			        if (_localctx.columns!=null) {
			            _localctx.values.Add(_localctx.columns[_localctx.col++].Trim(), (_localctx._field!=null?_input.GetText(_localctx._field.start,_localctx._field.stop):null).Trim());
			        }
			        
			State = 29;
			_errHandler.Sync(this);
			_la = _input.La(1);
			while (_la==1) {
				{
				{
				State = 23; Match(1);
				State = 24; _localctx._field = field();

				            if (_localctx.columns!=null) {
				                _localctx.values.Add(_localctx.columns[_localctx.col++].Trim(), (_localctx._field!=null?_input.GetText(_localctx._field.start,_localctx._field.stop):null).Trim());
				            }
				            
				}
				}
				State = 31;
				_errHandler.Sync(this);
				_la = _input.La(1);
			}
			State = 33;
			_la = _input.La(1);
			if (_la==3) {
				{
				State = 32; Match(3);
				}
			}

			State = 35; Match(2);
			}

			    if (_localctx.values!=null && _localctx.values.Count>0) {
			        Console.WriteLine("values = "+ String.Concat(_localctx.values));
			    }

		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.ReportError(this, re);
			_errHandler.Recover(this, re);
		}
		finally {
			ExitRule();
		}
		return _localctx;
	}

	public partial class FieldContext : ParserRuleContext {
		public ITerminalNode TEXT() { return GetToken(ExpressionLanguageParser.TEXT, 0); }
		public ITerminalNode STRING() { return GetToken(ExpressionLanguageParser.STRING, 0); }
		public FieldContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_field; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterField(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitField(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitField(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public FieldContext field() {
		FieldContext _localctx = new FieldContext(_ctx, State);
		EnterRule(_localctx, 6, RULE_field);
		try {
			State = 40;
			switch (_input.La(1)) {
			case TEXT:
				EnterOuterAlt(_localctx, 1);
				{
				State = 37; Match(TEXT);
				}
				break;
			case STRING:
				EnterOuterAlt(_localctx, 2);
				{
				State = 38; Match(STRING);
				}
				break;
			case 1:
			case 2:
			case 3:
				EnterOuterAlt(_localctx, 3);
				{
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.ReportError(this, re);
			_errHandler.Recover(this, re);
		}
		finally {
			ExitRule();
		}
		return _localctx;
	}

	public static readonly string _serializedATN =
		"\x5\x3\a-\x4\x2\t\x2\x4\x3\t\x3\x4\x4\t\x4\x4\x5\t\x5\x3\x2\x3\x2\x3\x2"+
		"\x3\x2\x6\x2\xF\n\x2\r\x2\xE\x2\x10\x3\x2\x3\x2\x3\x3\x3\x3\x3\x3\x3\x4"+
		"\x3\x4\x3\x4\x3\x4\x3\x4\x3\x4\a\x4\x1E\n\x4\f\x4\xE\x4!\v\x4\x3\x4\x5"+
		"\x4$\n\x4\x3\x4\x3\x4\x3\x5\x3\x5\x3\x5\x5\x5+\n\x5\x3\x5\x2\x2\x2\x6"+
		"\x2\x2\x4\x2\x6\x2\b\x2\x2\x2-\x2\n\x3\x2\x2\x2\x4\x14\x3\x2\x2\x2\x6"+
		"\x17\x3\x2\x2\x2\b*\x3\x2\x2\x2\n\xE\x5\x4\x3\x2\v\f\x5\x6\x4\x2\f\r\b"+
		"\x2\x1\x2\r\xF\x3\x2\x2\x2\xE\v\x3\x2\x2\x2\xF\x10\x3\x2\x2\x2\x10\xE"+
		"\x3\x2\x2\x2\x10\x11\x3\x2\x2\x2\x11\x12\x3\x2\x2\x2\x12\x13\b\x2\x1\x2"+
		"\x13\x3\x3\x2\x2\x2\x14\x15\x5\x6\x4\x2\x15\x16\b\x3\x1\x2\x16\x5\x3\x2"+
		"\x2\x2\x17\x18\x5\b\x5\x2\x18\x1F\b\x4\x1\x2\x19\x1A\a\x3\x2\x2\x1A\x1B"+
		"\x5\b\x5\x2\x1B\x1C\b\x4\x1\x2\x1C\x1E\x3\x2\x2\x2\x1D\x19\x3\x2\x2\x2"+
		"\x1E!\x3\x2\x2\x2\x1F\x1D\x3\x2\x2\x2\x1F \x3\x2\x2\x2 #\x3\x2\x2\x2!"+
		"\x1F\x3\x2\x2\x2\"$\a\x5\x2\x2#\"\x3\x2\x2\x2#$\x3\x2\x2\x2$%\x3\x2\x2"+
		"\x2%&\a\x4\x2\x2&\a\x3\x2\x2\x2\'+\a\x6\x2\x2(+\a\a\x2\x2)+\x3\x2\x2\x2"+
		"*\'\x3\x2\x2\x2*(\x3\x2\x2\x2*)\x3\x2\x2\x2+\t\x3\x2\x2\x2\x6\x10\x1F"+
		"#*";
	public static readonly ATN _ATN =
		ATNSimulator.Deserialize(_serializedATN.ToCharArray());
}
} // namespace MetraTech.Domain
