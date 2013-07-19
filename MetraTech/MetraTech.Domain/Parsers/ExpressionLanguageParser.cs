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
		LPAREN=1, RPAREN=2, NOT=3, AND=4, OR=5, IDENTIFIER=6, STRING=7, INTEGER=8, 
		DECIMAL=9, DATETIME=10, BOOLEAN=11, SPACE=12;
	public static readonly string[] tokenNames = {
		"<INVALID>", "'('", "')'", "'NOT'", "'AND'", "'OR'", "IDENTIFIER", "STRING", 
		"INTEGER", "DECIMAL", "DATETIME", "BOOLEAN", "SPACE"
	};
	public const int
		RULE_parse = 0, RULE_expression = 1;
	public static readonly string[] ruleNames = {
		"parse", "expression"
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
			State = 4; expression(0);
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
			State = 19;
			switch (_input.La(1)) {
			case NOT:
				{
				_localctx = new NotExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;

				State = 7; Match(NOT);
				State = 8; expression(3);
				}
				break;
			case LPAREN:
				{
				_localctx = new ParenthesisExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 9; Match(LPAREN);
				State = 10; expression(0);
				State = 11; Match(RPAREN);
				}
				break;
			case IDENTIFIER:
				{
				_localctx = new IdentifierExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 13; Match(IDENTIFIER);
				}
				break;
			case STRING:
				{
				_localctx = new StringExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 14; Match(STRING);
				}
				break;
			case INTEGER:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 15; Match(INTEGER);
				}
				break;
			case DECIMAL:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 16; Match(DECIMAL);
				}
				break;
			case DATETIME:
				{
				_localctx = new DateTimeExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 17; Match(DATETIME);
				}
				break;
			case BOOLEAN:
				{
				_localctx = new BooleanExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 18; Match(BOOLEAN);
				}
				break;
			default:
				throw new NoViableAltException(this);
			}
			_ctx.stop = _input.Lt(-1);
			State = 31;
			_errHandler.Sync(this);
			_alt = Interpreter.AdaptivePredict(_input,3,_ctx);
			while ( _alt!=2 && _alt!=-1 ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) TriggerExitRuleEvent();
					_prevctx = _localctx;
					{
					State = 29;
					switch ( Interpreter.AdaptivePredict(_input,2,_ctx) ) {
					case 1:
						{
						_localctx = new OrExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 21;
						if (!(Precpred(_ctx, 1))) throw new FailedPredicateException(this, "Precpred(_ctx, 1)");
						State = 22; Match(OR);
						State = 23; expression(2);
						}
						break;

					case 2:
						{
						_localctx = new AndExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 24;
						if (!(Precpred(_ctx, 2))) throw new FailedPredicateException(this, "Precpred(_ctx, 2)");
						State = 26;
						_la = _input.La(1);
						if (_la==AND) {
							{
							State = 25; Match(AND);
							}
						}

						State = 28; expression(0);
						}
						break;
					}
					} 
				}
				State = 33;
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

	public override bool Sempred(RuleContext _localctx, int ruleIndex, int predIndex) {
		switch (ruleIndex) {
		case 1: return expression_sempred((ExpressionContext)_localctx, predIndex);
		}
		return true;
	}
	private bool expression_sempred(ExpressionContext _localctx, int predIndex) {
		switch (predIndex) {
		case 0: return Precpred(_ctx, 1);

		case 1: return Precpred(_ctx, 2);
		}
		return true;
	}

	public static readonly string _serializedATN =
		"\x5\x3\xE%\x4\x2\t\x2\x4\x3\t\x3\x3\x2\x3\x2\x3\x3\x3\x3\x3\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x5\x3\x16\n\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x5\x3\x1D\n\x3\x3\x3\a\x3 \n\x3\f\x3\xE\x3"+
		"#\v\x3\x3\x3\x2\x2\x3\x4\x4\x2\x2\x4\x2\x2\x2,\x2\x6\x3\x2\x2\x2\x4\x15"+
		"\x3\x2\x2\x2\x6\a\x5\x4\x3\x2\a\x3\x3\x2\x2\x2\b\t\b\x3\x1\x2\t\n\a\x5"+
		"\x2\x2\n\x16\x5\x4\x3\x5\v\f\a\x3\x2\x2\f\r\x5\x4\x3\x2\r\xE\a\x4\x2\x2"+
		"\xE\x16\x3\x2\x2\x2\xF\x16\a\b\x2\x2\x10\x16\a\t\x2\x2\x11\x16\a\n\x2"+
		"\x2\x12\x16\a\v\x2\x2\x13\x16\a\f\x2\x2\x14\x16\a\r\x2\x2\x15\b\x3\x2"+
		"\x2\x2\x15\v\x3\x2\x2\x2\x15\xF\x3\x2\x2\x2\x15\x10\x3\x2\x2\x2\x15\x11"+
		"\x3\x2\x2\x2\x15\x12\x3\x2\x2\x2\x15\x13\x3\x2\x2\x2\x15\x14\x3\x2\x2"+
		"\x2\x16!\x3\x2\x2\x2\x17\x18\f\x3\x2\x2\x18\x19\a\a\x2\x2\x19 \x5\x4\x3"+
		"\x4\x1A\x1C\f\x4\x2\x2\x1B\x1D\a\x6\x2\x2\x1C\x1B\x3\x2\x2\x2\x1C\x1D"+
		"\x3\x2\x2\x2\x1D\x1E\x3\x2\x2\x2\x1E \x5\x4\x3\x2\x1F\x17\x3\x2\x2\x2"+
		"\x1F\x1A\x3\x2\x2\x2 #\x3\x2\x2\x2!\x1F\x3\x2\x2\x2!\"\x3\x2\x2\x2\"\x5"+
		"\x3\x2\x2\x2#!\x3\x2\x2\x2\x6\x15\x1C\x1F!";
	public static readonly ATN _ATN =
		ATNSimulator.Deserialize(_serializedATN.ToCharArray());
}
} // namespace MetraTech.Domain
