// Generated from C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source\MetraTech\MetraTech.Domain\Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime;
using Antlr4.Runtime.Atn;
using Antlr4.Runtime.Misc;
using Antlr4.Runtime.Tree;
using System.Collections.Generic;
using DFA = Antlr4.Runtime.Dfa.DFA;

public partial class ExpressionLanguageParser : Parser {
	public const int
		T__2=1, T__1=2, T__0=3, OR=4, AND=5, EQUALS=6, NOTEQUALS=7, LT=8, LTEQ=9, 
		GT=10, GTEQ=11, PLUS=12, MINUS=13, MULT=14, DIV=15, MOD=16, POW=17, NOT=18, 
		DOT=19, STRING=20, INTEGER=21, DECIMAL=22, DATETIME=23, BOOLEAN=24, IDENTIFIER=25, 
		SPACE=26;
	public static readonly string[] tokenNames = {
		"<INVALID>", "')'", "','", "'('", "OR", "AND", "EQUALS", "NOTEQUALS", 
		"'<'", "'<='", "'>'", "'>='", "'+'", "'-'", "'*'", "'/'", "'%'", "'^'", 
		"NOT", "'.'", "STRING", "INTEGER", "DECIMAL", "DATETIME", "BOOLEAN", "IDENTIFIER", 
		"SPACE"
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
	public partial class FunctionExpressionContext : ExpressionContext {
		public FunctionContext function() {
			return GetRuleContext<FunctionContext>(0);
		}
		public FunctionExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterFunctionExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitFunctionExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitFunctionExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class BinaryExpressionContext : ExpressionContext {
		public ExpressionContext[] expression() {
			return GetRuleContexts<ExpressionContext>();
		}
		public ITerminalNode PLUS() { return GetToken(ExpressionLanguageParser.PLUS, 0); }
		public ExpressionContext expression(int i) {
			return GetRuleContext<ExpressionContext>(i);
		}
		public ITerminalNode MINUS() { return GetToken(ExpressionLanguageParser.MINUS, 0); }
		public BinaryExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterBinaryExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitBinaryExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitBinaryExpression(this);
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
	public partial class PropertyExpressionContext : ExpressionContext {
		public ExpressionContext expression() {
			return GetRuleContext<ExpressionContext>(0);
		}
		public ITerminalNode DOT() { return GetToken(ExpressionLanguageParser.DOT, 0); }
		public ITerminalNode IDENTIFIER() { return GetToken(ExpressionLanguageParser.IDENTIFIER, 0); }
		public PropertyExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterPropertyExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitPropertyExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitPropertyExpression(this);
			else return visitor.VisitChildren(this);
		}
	}
	public partial class UnaryExpressionContext : ExpressionContext {
		public ExpressionContext expression() {
			return GetRuleContext<ExpressionContext>(0);
		}
		public ITerminalNode MINUS() { return GetToken(ExpressionLanguageParser.MINUS, 0); }
		public UnaryExpressionContext(ExpressionContext context) { CopyFrom(context); }
		public override void EnterRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.EnterUnaryExpression(this);
		}
		public override void ExitRule(IParseTreeListener listener) {
			IExpressionLanguageListener typedListener = listener as IExpressionLanguageListener;
			if (typedListener != null) typedListener.ExitUnaryExpression(this);
		}
		public override TResult Accept<TResult>(IParseTreeVisitor<TResult> visitor) {
			IExpressionLanguageVisitor<TResult> typedVisitor = visitor as IExpressionLanguageVisitor<TResult>;
			if (typedVisitor != null) return typedVisitor.VisitUnaryExpression(this);
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
			State = 24;
			switch ( Interpreter.AdaptivePredict(_input,0,_ctx) ) {
			case 1:
				{
				_localctx = new UnaryExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;

				State = 9; Match(NOT);
				State = 10; expression(16);
				}
				break;

			case 2:
				{
				_localctx = new UnaryExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 11; Match(MINUS);
				State = 12; expression(11);
				}
				break;

			case 3:
				{
				_localctx = new ParenthesisExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 13; Match(3);
				State = 14; expression(0);
				State = 15; Match(1);
				}
				break;

			case 4:
				{
				_localctx = new StringExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 17; Match(STRING);
				}
				break;

			case 5:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 18; Match(INTEGER);
				}
				break;

			case 6:
				{
				_localctx = new NumberExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 19; Match(DECIMAL);
				}
				break;

			case 7:
				{
				_localctx = new DateTimeExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 20; Match(DATETIME);
				}
				break;

			case 8:
				{
				_localctx = new BooleanExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 21; Match(BOOLEAN);
				}
				break;

			case 9:
				{
				_localctx = new IdentifierExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 22; Match(IDENTIFIER);
				}
				break;

			case 10:
				{
				_localctx = new FunctionExpressionContext(_localctx);
				_ctx = _localctx;
				_prevctx = _localctx;
				State = 23; function();
				}
				break;
			}
			_ctx.stop = _input.Lt(-1);
			State = 52;
			_errHandler.Sync(this);
			_alt = Interpreter.AdaptivePredict(_input,2,_ctx);
			while ( _alt!=2 && _alt!=-1 ) {
				if ( _alt==1 ) {
					if ( _parseListeners!=null ) TriggerExitRuleEvent();
					_prevctx = _localctx;
					{
					State = 50;
					switch ( Interpreter.AdaptivePredict(_input,1,_ctx) ) {
					case 1:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 26;
						if (!(Precpred(_ctx, 15))) throw new FailedPredicateException(this, "Precpred(_ctx, 15)");
						State = 27; Match(AND);
						State = 28; expression(16);
						}
						break;

					case 2:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 29;
						if (!(Precpred(_ctx, 14))) throw new FailedPredicateException(this, "Precpred(_ctx, 14)");
						State = 30; Match(OR);
						State = 31; expression(15);
						}
						break;

					case 3:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 32;
						if (!(Precpred(_ctx, 13))) throw new FailedPredicateException(this, "Precpred(_ctx, 13)");
						State = 33;
						_la = _input.La(1);
						if ( !(_la==EQUALS || _la==NOTEQUALS) ) {
						_errHandler.RecoverInline(this);
						}
						Consume();
						State = 34; expression(14);
						}
						break;

					case 4:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 35;
						if (!(Precpred(_ctx, 12))) throw new FailedPredicateException(this, "Precpred(_ctx, 12)");
						State = 36;
						_la = _input.La(1);
						if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << LT) | (1L << LTEQ) | (1L << GT) | (1L << GTEQ))) != 0)) ) {
						_errHandler.RecoverInline(this);
						}
						Consume();
						State = 37; expression(13);
						}
						break;

					case 5:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 38;
						if (!(Precpred(_ctx, 10))) throw new FailedPredicateException(this, "Precpred(_ctx, 10)");
						State = 39; Match(POW);
						State = 40; expression(11);
						}
						break;

					case 6:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 41;
						if (!(Precpred(_ctx, 9))) throw new FailedPredicateException(this, "Precpred(_ctx, 9)");
						State = 42;
						_la = _input.La(1);
						if ( !((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << MULT) | (1L << DIV) | (1L << MOD))) != 0)) ) {
						_errHandler.RecoverInline(this);
						}
						Consume();
						State = 43; expression(10);
						}
						break;

					case 7:
						{
						_localctx = new BinaryExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 44;
						if (!(Precpred(_ctx, 8))) throw new FailedPredicateException(this, "Precpred(_ctx, 8)");
						State = 45;
						_la = _input.La(1);
						if ( !(_la==PLUS || _la==MINUS) ) {
						_errHandler.RecoverInline(this);
						}
						Consume();
						State = 46; expression(9);
						}
						break;

					case 8:
						{
						_localctx = new PropertyExpressionContext(new ExpressionContext(_parentctx, _parentState));
						PushNewRecursionContext(_localctx, _startState, RULE_expression);
						State = 47;
						if (!(Precpred(_ctx, 17))) throw new FailedPredicateException(this, "Precpred(_ctx, 17)");
						State = 48; Match(DOT);
						State = 49; Match(IDENTIFIER);
						}
						break;
					}
					} 
				}
				State = 54;
				_errHandler.Sync(this);
				_alt = Interpreter.AdaptivePredict(_input,2,_ctx);
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
			State = 55; Match(IDENTIFIER);
			State = 56; Match(3);
			State = 65;
			_la = _input.La(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << 3) | (1L << MINUS) | (1L << NOT) | (1L << STRING) | (1L << INTEGER) | (1L << DECIMAL) | (1L << DATETIME) | (1L << BOOLEAN) | (1L << IDENTIFIER))) != 0)) {
				{
				State = 57; expression(0);
				State = 62;
				_errHandler.Sync(this);
				_la = _input.La(1);
				while (_la==2) {
					{
					{
					State = 58; Match(2);
					State = 59; expression(0);
					}
					}
					State = 64;
					_errHandler.Sync(this);
					_la = _input.La(1);
				}
				}
			}

			State = 67; Match(1);
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
		case 0: return Precpred(_ctx, 15);

		case 1: return Precpred(_ctx, 14);

		case 2: return Precpred(_ctx, 13);

		case 3: return Precpred(_ctx, 12);

		case 4: return Precpred(_ctx, 10);

		case 5: return Precpred(_ctx, 9);

		case 6: return Precpred(_ctx, 8);

		case 7: return Precpred(_ctx, 17);
		}
		return true;
	}

	public static readonly string _serializedATN =
		"\x5\x3\x1CH\x4\x2\t\x2\x4\x3\t\x3\x4\x4\t\x4\x3\x2\x3\x2\x3\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x5\x3\x1B\n\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3"+
		"\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\x3\a\x3\x35\n\x3\f\x3\xE\x3\x38\v\x3\x3"+
		"\x4\x3\x4\x3\x4\x3\x4\x3\x4\a\x4?\n\x4\f\x4\xE\x4\x42\v\x4\x5\x4\x44\n"+
		"\x4\x3\x4\x3\x4\x3\x4\x2\x2\x3\x4\x5\x2\x2\x4\x2\x6\x2\x2\x6\x3\b\t\x3"+
		"\n\r\x3\x10\x12\x3\xE\xFW\x2\b\x3\x2\x2\x2\x4\x1A\x3\x2\x2\x2\x6\x39\x3"+
		"\x2\x2\x2\b\t\x5\x4\x3\x2\t\x3\x3\x2\x2\x2\n\v\b\x3\x1\x2\v\f\a\x14\x2"+
		"\x2\f\x1B\x5\x4\x3\x12\r\xE\a\xF\x2\x2\xE\x1B\x5\x4\x3\r\xF\x10\a\x5\x2"+
		"\x2\x10\x11\x5\x4\x3\x2\x11\x12\a\x3\x2\x2\x12\x1B\x3\x2\x2\x2\x13\x1B"+
		"\a\x16\x2\x2\x14\x1B\a\x17\x2\x2\x15\x1B\a\x18\x2\x2\x16\x1B\a\x19\x2"+
		"\x2\x17\x1B\a\x1A\x2\x2\x18\x1B\a\x1B\x2\x2\x19\x1B\x5\x6\x4\x2\x1A\n"+
		"\x3\x2\x2\x2\x1A\r\x3\x2\x2\x2\x1A\xF\x3\x2\x2\x2\x1A\x13\x3\x2\x2\x2"+
		"\x1A\x14\x3\x2\x2\x2\x1A\x15\x3\x2\x2\x2\x1A\x16\x3\x2\x2\x2\x1A\x17\x3"+
		"\x2\x2\x2\x1A\x18\x3\x2\x2\x2\x1A\x19\x3\x2\x2\x2\x1B\x36\x3\x2\x2\x2"+
		"\x1C\x1D\f\x11\x2\x2\x1D\x1E\a\a\x2\x2\x1E\x35\x5\x4\x3\x12\x1F \f\x10"+
		"\x2\x2 !\a\x6\x2\x2!\x35\x5\x4\x3\x11\"#\f\xF\x2\x2#$\t\x2\x2\x2$\x35"+
		"\x5\x4\x3\x10%&\f\xE\x2\x2&\'\t\x3\x2\x2\'\x35\x5\x4\x3\xF()\f\f\x2\x2"+
		")*\a\x13\x2\x2*\x35\x5\x4\x3\r+,\f\v\x2\x2,-\t\x4\x2\x2-\x35\x5\x4\x3"+
		"\f./\f\n\x2\x2/\x30\t\x5\x2\x2\x30\x35\x5\x4\x3\v\x31\x32\f\x13\x2\x2"+
		"\x32\x33\a\x15\x2\x2\x33\x35\a\x1B\x2\x2\x34\x1C\x3\x2\x2\x2\x34\x1F\x3"+
		"\x2\x2\x2\x34\"\x3\x2\x2\x2\x34%\x3\x2\x2\x2\x34(\x3\x2\x2\x2\x34+\x3"+
		"\x2\x2\x2\x34.\x3\x2\x2\x2\x34\x31\x3\x2\x2\x2\x35\x38\x3\x2\x2\x2\x36"+
		"\x34\x3\x2\x2\x2\x36\x37\x3\x2\x2\x2\x37\x5\x3\x2\x2\x2\x38\x36\x3\x2"+
		"\x2\x2\x39:\a\x1B\x2\x2:\x43\a\x5\x2\x2;@\x5\x4\x3\x2<=\a\x4\x2\x2=?\x5"+
		"\x4\x3\x2><\x3\x2\x2\x2?\x42\x3\x2\x2\x2@>\x3\x2\x2\x2@\x41\x3\x2\x2\x2"+
		"\x41\x44\x3\x2\x2\x2\x42@\x3\x2\x2\x2\x43;\x3\x2\x2\x2\x43\x44\x3\x2\x2"+
		"\x2\x44\x45\x3\x2\x2\x2\x45\x46\a\x3\x2\x2\x46\a\x3\x2\x2\x2\a\x1A\x34"+
		"\x36@\x43";
	public static readonly ATN _ATN =
		ATNSimulator.Deserialize(_serializedATN.ToCharArray());
}
} // namespace MetraTech.Domain
