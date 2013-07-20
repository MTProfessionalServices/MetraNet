// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;
using System.Collections.Generic;
using DFA = Antlr4.Runtime.Dfa.DFA;

public partial class ExpressionLanguageParser : Parser {
	public const int
		T__2=1, T__1=2, T__0=3, NOT=4, AND=5, OR=6, STRING=7, INTEGER=8, DECIMAL=9, 
		DATETIME=10, BOOLEAN=11, IDENTIFIER=12, SPACE=13;
	public static readonly string[] tokenNames = {
		"<INVALID>", "')'", "','", "'('", "'NOT'", "'AND'", "'OR'", "STRING", 
		"INTEGER", "DECIMAL", "DATETIME", "BOOLEAN", "IDENTIFIER", "SPACE"
	};
	public const int
		RULE_parse = 0, RULE_expression = 1, RULE_function = 2;
	public static readonly string[] ruleNames = {
		"parse", "expression", "function"
	};

	public override string GrammarFileName { get { return "ExpressionLanguage.g4"; } }

	public override string[] TokenNames { get { return tokenNames; } }

	public override string[] RuleNames { get { return ruleNames; } }

	public ExpressionLanguageParser(ITokenStream input)
		: base(input)
	{
		_interp = new ParserATNSimulator(this,_ATN);
	}
	public partial class ParseContext : ParserRuleContext {
		public ExpressionContext expression() {
			return GetRuleContext<ExpressionContext>(0);
		}
		public ParseContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_parse; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterParse(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitParse(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitParse(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public ParseContext parse() {
		ParseContext _localctx = new ParseContext(_ctx, State);
		EnterRule(_localctx, 0, RULE_parse);
		try {
			EnterOuterAlt(_localctx, 1);
			{
			State = 6; expression(0);
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

	public partial class ExpressionContext : ParserRuleContext {
		public ExpressionContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_expression; }
	 
		public ExpressionContext() { }
		public virtual void CopyFrom(ExpressionContext context) {
			base.CopyFrom(context);
		}
	}
	public partial class OrExpressionContext : ExpressionContext {
		public ExpressionContext[] expression() {
			return GetRuleContexts<ExpressionContext>();
		}
		public ExpressionContext expression(int i) {
			return GetRuleContext<ExpressionContext>(i);
		}
		public ITerminalNode OR() { return GetToken(ExpressionLanguageParser.OR, 0); }
		public OrExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterOrExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitOrExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitOrExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class NotExpressionContext : ExpressionContext {
		public ExpressionContext expression() {
			return GetRuleContext<ExpressionContext>(0);
		}
		public ITerminalNode NOT() { return GetToken(ExpressionLanguageParser.NOT, 0); }
		public NotExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterNotExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitNotExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitNotExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class ParenthesisExpressionContext : ExpressionContext {
		public ExpressionContext expression() {
			return GetRuleContext<ExpressionContext>(0);
		}
		public ParenthesisExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterParenthesisExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitParenthesisExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitParenthesisExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class IdentifierExpressionContext : ExpressionContext {
		public ITerminalNode IDENTIFIER() { return GetToken(ExpressionLanguageParser.IDENTIFIER, 0); }
		public IdentifierExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterIdentifierExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitIdentifierExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitIdentifierExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class AndExpressionContext : ExpressionContext {
		public ExpressionContext[] expression() {
			return GetRuleContexts<ExpressionContext>();
		}
		public ExpressionContext expression(int i) {
			return GetRuleContext<ExpressionContext>(i);
		}
		public ITerminalNode AND() { return GetToken(ExpressionLanguageParser.AND, 0); }
		public AndExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterAndExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitAndExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitAndExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class DateTimeExpressionContext : ExpressionContext {
		public ITerminalNode DATETIME() { return GetToken(ExpressionLanguageParser.DATETIME, 0); }
		public DateTimeExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterDateTimeExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitDateTimeExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitDateTimeExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class BooleanExpressionContext : ExpressionContext {
		public ITerminalNode BOOLEAN() { return GetToken(ExpressionLanguageParser.BOOLEAN, 0); }
		public BooleanExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterBooleanExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitBooleanExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitBooleanExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class NumberExpressionContext : ExpressionContext {
		public ITerminalNode DECIMAL() { return GetToken(ExpressionLanguageParser.DECIMAL, 0); }
		public NumberExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterNumberExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitNumberExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitNumberExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class StringExpressionContext : ExpressionContext {
		public ITerminalNode STRING() { return GetToken(ExpressionLanguageParser.STRING, 0); }
		public StringExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterStringExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitStringExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitStringExpression(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public ExpressionContext expression(int _p) {
		ParserRuleContext _parentctx = _ctx;
		int _parentState = State;
		ExpressionContext _localctx = new ExpressionContext(_ctx, _parentState);
		ExpressionContext _prevctx = _localctx;
		int _startState = 2;
		EnterRecursionRule(_localctx, RULE_expression, _p);
		int _la;
		try {
			int _alt;
			EnterOuterAlt(_localctx, 1);
			{
			State = 21;
			switch (_input.La(1)) {
			case NOT:
				{
				_localctx = new NotExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;

				State = 9; Match(NOT);
				State = 10; expression(9);
				}
				break;
			case 3:
				{
				_localctx = new ParenthesisExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 11; Match(3);
				State = 12; expression(0);
				State = 13; Match(1);
				}
				break;
			case STRING:
				{
				_localctx = new StringExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 15; Match(STRING);
				}
				break;
			case INTEGER:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 16; Match(INTEGER);
				}
				break;
			case DECIMAL:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 17; Match(DECIMAL);
				}
				break;
			case DATETIME:
				{
				_localctx = new DateTimeExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 18; Match(DATETIME);
				}
				break;
			case BOOLEAN:
				{
				_localctx = new BooleanExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 19; Match(BOOLEAN);
				}
				break;
			case IDENTIFIER:
				{
				_localctx = new IdentifierExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 20; Match(IDENTIFIER);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			_ctx.stop = _input.Lt(-1);
			State = 33;
			_errHandler.Sync(this);
			_alt = Interpreter.AdaptivePredict(_input,3,_ctx);
			while ( _alt!=2 && _alt!=-1 ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) TriggerExitRuleEvent();
					_prevctx = _localctx;
					{
					State = 31;
					switch ( Interpreter.AdaptivePredict(_input,2,_ctx) ) {
					case 1:
						{
						_localctx = new OrExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 23;
						if (!(Precpred(_ctx, 7))) throw new FailedPredicateException(this, "Precpred(_ctx, 7)");
						State = 24; Match(OR);
						State = 25; expression(8);
						}
						break;

					case 2:
						{
						_localctx = new AndExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 26;
						if (!(Precpred(_ctx, 8))) throw new FailedPredicateException(this, "Precpred(_ctx, 8)");
						State = 28;
						_la = _input.La(1);
						if (_la==AND) {
							{
							State = 27; Match(AND);
							}
						}

						State = 30; expression(0);
						}
						break;
					}
					} 
				}
				State = 35;
				_errHandler.Sync(this);
				_alt = Interpreter.AdaptivePredict(_input,3,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.ReportError(this, re);
			_errHandler.Recover(this, re);
		}
		finally {
			UnrollRecursionContexts(_parentctx);
		}
		return _localctx;
	}

	public partial class FunctionContext : ParserRuleContext {
		public ExpressionContext[] expression() {
			return GetRuleContexts<ExpressionContext>();
		}
		public ExpressionContext expression(int i) {
			return GetRuleContext<ExpressionContext>(i);
		}
		public ITerminalNode IDENTIFIER() { return GetToken(ExpressionLanguageParser.IDENTIFIER, 0); }
		public FunctionContext(ParserRuleContext parent, int invokingState)
			: base(parent, invokingState)
		{
		}
		public override int GetRuleIndex() { return RULE_function; }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterFunction(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitFunction(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitFunction(this);
			else return visitor.VisitChildren(this);
		}
	}

	[RuleVersion(0)]
	public FunctionContext function() {
		FunctionContext _localctx = new FunctionContext(_ctx, State);
		EnterRule(_localctx, 4, RULE_function);
		int _la;
		try {
			EnterOuterAlt(_localctx, 1);
			{
			State = 36; Match(IDENTIFIER);
			State = 37; Match(3);
			State = 46;
			_la = _input.La(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 3) | (1L << NOT) | (1L << STRING) | (1L << INTEGER) | (1L << DECIMAL) | (1L << DATETIME) | (1L << BOOLEAN) | (1L << IDENTIFIER))) != 0)) {
				{
				State = 38; expression(0);
				State = 43;
				_errHandler.Sync(this);
				_la = _input.La(1);
				while (_la==2) {
					{
					{
					State = 39; Match(2);
					State = 40; expression(0);
					}
					}
					State = 45;
					_errHandler.Sync(this);
					_la = _input.La(1);
				}
				}
			}

			State = 48; Match(1);
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

	public override bool Sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 1: return expression_sempred((ExpressionContext)_localctx, predIndex);
		}
		return true;
	}
	private bool expression_sempred(ExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0: return Precpred(_ctx, 7);

		case 1: return Precpred(_ctx, 8);
		}
		return true;
	}

	public static readonly string _serializedATN =
		"\x5\x3\xF\x35\x4\x2\t\x2\x4\x3\t\x3\x4\x4\t\x4\x3\x2\x3\x2\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x5"+
		"\x3\x18\n\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x5\x3\x1F\n\x3\x3\x3\a\x3\""+
		"\n\x3\f\x3\xE\x3%\v\x3\x3\x4\x3\x4\x3\x4\x3\x4\x3\x4\a\x4,\n\x4\f\x4\xE"+
		"\x4/\v\x4\x5\x4\x31\n\x4\x3\x4\x3\x4\x3\x4\x2\x2\x3\x4\x5\x2\x2\x4\x2"+
		"\x6\x2\x2\x2=\x2\b\x3\x2\x2\x2\x4\x17\x3\x2\x2\x2\x6&\x3\x2\x2\x2\b\t"+
		"\x5\x4\x3\x2\t\x3\x3\x2\x2\x2\n\v\b\x3\x1\x2\v\f\a\x6\x2\x2\f\x18\x5\x4"+
		"\x3\v\r\xE\a\x5\x2\x2\xE\xF\x5\x4\x3\x2\xF\x10\a\x3\x2\x2\x10\x18\x3\x2"+
		"\x2\x2\x11\x18\a\t\x2\x2\x12\x18\a\n\x2\x2\x13\x18\a\v\x2\x2\x14\x18\a"+
		"\f\x2\x2\x15\x18\a\r\x2\x2\x16\x18\a\xE\x2\x2\x17\n\x3\x2\x2\x2\x17\r"+
		"\x3\x2\x2\x2\x17\x11\x3\x2\x2\x2\x17\x12\x3\x2\x2\x2\x17\x13\x3\x2\x2"+
		"\x2\x17\x14\x3\x2\x2\x2\x17\x15\x3\x2\x2\x2\x17\x16\x3\x2\x2\x2\x18#\x3"+
		"\x2\x2\x2\x19\x1A\f\t\x2\x2\x1A\x1B\a\b\x2\x2\x1B\"\x5\x4\x3\n\x1C\x1E"+
		"\f\n\x2\x2\x1D\x1F\a\a\x2\x2\x1E\x1D\x3\x2\x2\x2\x1E\x1F\x3\x2\x2\x2\x1F"+
		" \x3\x2\x2\x2 \"\x5\x4\x3\x2!\x19\x3\x2\x2\x2!\x1C\x3\x2\x2\x2\"%\x3\x2"+
		"\x2\x2#!\x3\x2\x2\x2#$\x3\x2\x2\x2$\x5\x3\x2\x2\x2%#\x3\x2\x2\x2&\'\a"+
		"\xE\x2\x2\'\x30\a\x5\x2\x2(-\x5\x4\x3\x2)*\a\x4\x2\x2*,\x5\x4\x3\x2+)"+
		"\x3\x2\x2\x2,/\x3\x2\x2\x2-+\x3\x2\x2\x2-.\x3\x2\x2\x2.\x31\x3\x2\x2\x2"+
		"/-\x3\x2\x2\x2\x30(\x3\x2\x2\x2\x30\x31\x3\x2\x2\x2\x31\x32\x3\x2\x2\x2"+
		"\x32\x33\a\x3\x2\x2\x33\a\x3\x2\x2\x2\b\x17\x1E!#-\x30";
	public static readonly ATN _ATN =
		ATNSimulator.Deserialize(_serializedATN.ToCharArray());
}
} // namespace MetraTech.Domain
