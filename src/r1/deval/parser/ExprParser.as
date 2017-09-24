package r1.deval.parser
{
  import r1.deval.rt.CallExpr;
  import r1.deval.rt.Constant;
  import r1.deval.rt.Env;
  import r1.deval.rt.ExprFactory;
  import r1.deval.rt.FunctionDef;
  import r1.deval.rt.IExpr;
  import r1.deval.rt.ISettable;

  public class ExprParser extends ParserConsts
  {
	protected static const TI_CHECK_LABEL:int = 1 << 17;
	protected static const CLEAR_TI_MASK:int = 65535;
	protected static const TI_AFTER_EOL:int = 1 << 16;
	private var next_currentFlaggedToken:int;
	protected var exprFactory:ExprFactory;
	protected var currentFlaggedToken:int;
	private var lookaheadName:Boolean;
	protected var ts:TokenStream;

	public function ExprParser()
	{
	  super();
	  this.exprFactory = new ExprFactory();
	}

	protected function checkVarDefined(x:String):void {}
	protected function propertyName(host:IExpr, name:String, attrFlag:Boolean=false, descFlag:Boolean=false):IExpr
	{
	  var tt:int = 0;
	  var ns:IExpr = null;
	  if(matchToken(COLONCOLON))
	  {
        checkVarDefined(name);
		ns = exprFactory.createAccessor(null, name);
		tt = nextToken();
		switch(tt)
		{
		  case NAME:
			name = ts.getString();
			break;
		  case MUL:
			name = "*";
			break;
		  case LB:
			host = exprFactory.createAccessor(host, expression(), ns, attrFlag, descFlag);
			mustMatchToken(RB, "msg.no.bracket.index", "k07");
			return host;
		  default:
			reportError("msg.no.name.after.coloncolon", "K08");
			name = "?";
		}
	  }
     if (host==null) checkVarDefined(name);
	  return exprFactory.createAccessor(host, name, ns, attrFlag, descFlag);
	}

	protected function pushbackLookahead():void
	{
	  lookaheadName = true;
	  next_currentFlaggedToken = currentFlaggedToken;
	  currentFlaggedToken = NAME;
	}

	private function argumentList(callee:CallExpr):void
	{
	  if(matchToken(RP)) return;
	  do
	  {
		callee.addParam(assignExpr());
	  }
	  while(matchToken(COMMA));
	  mustMatchToken(RP, "msg.no.paren.arg", "k04");
	}

	protected function assignExpr():IExpr
	{
	  var expr:IExpr = condExpr();
	  var tt:int = peekToken();
	  if(FIRST_ASSIGN <= tt && tt <= LAST_ASSIGN)
	  {
		consumeToken();
		checkAssignable(expr);
		expr = exprFactory.createAssignment(expr as ISettable, assignExpr(), tt, ts.getLineno(), ts);
	  }
	  return expr;
	}

	protected function nextToken():int
	{
	  var tt:int = peekToken();
	  consumeToken();
	  return tt;
	}

	public function codeBug(id:String):void { throw new ParseError(null, id, ts.getLineno()); }

	public function parseExpr(sourceString:String):IExpr
	{
	  initParser(sourceString);
	  return expression();
	}

	private function xmlInitializer():IExpr
	{
	  var strlit:IExpr = null;
	  var x:IExpr = null;
	  var expr:IExpr = null;
	  loop0:
	  for (var tt:int = ts.getFirstXMLToken(); true; tt = ts.getNextXMLToken())
	  {
		strlit = exprFactory.literal(ts.getString());
		switch (tt)
		{
		  case XML:
			mustMatchToken(LC, "msg.syntax", "k02");
			expr = exprFactory.createAddSubExpr(expr, strlit);
			if (peekToken() != RC)
			{
			  x = expression();
			  if (ts.isXMLAttribute()) x = exprFactory.createXMLAttrExpr(x);
			  expr = exprFactory.createAddSubExpr(expr, x);
			}
			mustMatchToken(RC, "msg.syntax", "k03");
			break;
		  case XMLEND:
			break loop0;
		  default:
			reportError("msg.syntax", "K05");
		}
	  }
	  return exprFactory.createXMLLiteralExpr(expr, strlit);
	}

	private function unaryExpr():IExpr
	{
	  var expr:IExpr = null;
	  var tt:int = peekToken();
	  switch (tt)
	  {
		case VOID:
		case NOT:
		case BITNOT:
		case TYPEOF:
		case SUB:
		case ADD:
		case INC:
		case DEC:
		case DELETE:
		  consumeToken();
		  expr = unaryExpr();
		  if (tt == INC || tt == DEC) checkAssignable(expr);
		  return exprFactory.createUnaryExpr(expr, tt);
		case ERROR:
		  consumeToken();
		  reportError("msg.syntax", "K04");
		  return null;
		case LT:
		  consumeToken();
		  return memberExprTail(true, xmlInitializer());
		default:
		  expr = memberExpr(true);
		  tt = peekTokenOrEOL();
		  while (tt == INC || tt == DEC)
		  {
			consumeToken();
			expr = exprFactory.createUnaryExpr(expr, tt == INC ? int(POSTFIX_INC) : int(POSTFIX_DEC));
			tt = peekTokenOrEOL();
		  }
		  return expr;
	  }
	}

	protected function initParser(sourceString:String):void
	{
	  this.ts = new TokenStream(sourceString);
	  this.currentFlaggedToken = EOF;
	}

	private function eqExpr():IExpr
	{
	  var expr:IExpr = relExpr();
	  loop0:
	  for (var tt:int = peekToken(); true; )
	  {
		switch (tt)
		{
		  case EQ:
		  case NE:
		  case SHEQ:
		  case SHNE:
			consumeToken();
			expr = exprFactory.createEqRelExpr(expr, relExpr(), tt);
			tt = peekToken();
			continue;
		  default:
			break loop0;
		}
	  }
	  return expr;
	}

	protected function setCheckForLabel():void
	{
	  if ((currentFlaggedToken & CLEAR_TI_MASK) != NAME) codeBug("K01");
	  currentFlaggedToken = currentFlaggedToken | TI_CHECK_LABEL;
	}

	protected function nextFlaggedToken():int
	{
	  peekToken();
	  var ttFlagged:int = currentFlaggedToken;
	  consumeToken();
	  return ttFlagged;
	}

	private function shiftExpr():IExpr
	{
	  var expr:IExpr = addExpr();
	  loop0:
	  for (var tt:int = peekToken(); true; )
	  {
		switch (tt)
		{
		  case LSH:
		  case URSH:
		  case RSH:
			consumeToken();
			expr = exprFactory.createShiftExpr(expr, addExpr(), tt);
			tt = peekToken();
			continue;
		  default:
			break loop0;
		}
	  }
	  return expr;
	}

	private function mulExpr():IExpr
	{
	  var expr:IExpr = unaryExpr();
	  loop0:
	  for (var tt:int = peekToken(); true; )
	  {
		switch (tt)
		{
		  case MUL:
		  case DIV:
		  case MOD:
			consumeToken();
			expr = exprFactory.createMulDivModExpr(expr, unaryExpr(), tt);
			tt = peekToken();
			continue;
		  default:
			break loop0;
		}
	  }
	  return expr;
	}

	protected function mustMatchToken(toMatch:int, messageId:String, id:String):void
	{
	  if (!matchToken(toMatch)) reportError(messageId, id);
	}

	protected function peekToken():int
	{
	  if (lookaheadName) return NAME;
	  var tt:int = int(currentFlaggedToken);
	  if (tt == EOF)
	  {
		tt = int(ts.getToken());
		if (tt == EOL)
		{
		  do
		  {
			tt = int(ts.getToken());
		  }
		  while (tt == EOL);
		  tt = tt | TI_AFTER_EOL;
		}
		currentFlaggedToken = tt;
	  }
	  return tt & CLEAR_TI_MASK;
	}

	private function attributeAccess(host:IExpr=null, descFlag:Boolean=false):IExpr
	{
	  var tt:int = nextToken();
	  switch (tt)
	  {
		case NAME:
		  return propertyName(host, ts.getString(), true, descFlag);
		case MUL:
		  return propertyName(host, "*", true, descFlag);
		case LB:
		  host = exprFactory.createAccessor(host, expression(), null, true, descFlag);
		  mustMatchToken(RB,"msg.no.bracket.index", "k68");
		  return host;
		default:
		  reportError("msg.no.name.after.xmlAttr", "K69");
		  return null;
	  }
	}

	protected function peekTokenOrEOL():int
	{
	  var tt:int = peekToken();
	  if ((currentFlaggedToken & TI_AFTER_EOL) != 0) tt = EOL;
	  return tt;
	}

	private function bitXorExpr():IExpr
	{
	  var expr:IExpr = bitAndExpr();
	  for (var tt:int = peekToken(); tt == BITXOR; )
	  {
		consumeToken();
		expr = exprFactory.createBitExpr(expr, bitAndExpr(), BITXOR);
		tt = peekToken();
	  }
	  return expr;
	}

	protected function consumeToken():void
	{
	  if(lookaheadName)
	  {
		lookaheadName = false;
		currentFlaggedToken = next_currentFlaggedToken;
		return;
	  }
	  currentFlaggedToken = EOF;
	}

	private function bitOrExpr():IExpr
	{
	  var expr:IExpr = bitXorExpr();
	  for(var tt:int = peekToken(); tt == BITOR; )
	  {
		consumeToken();
		expr = exprFactory.createBitExpr(expr, bitXorExpr(), BITOR);
		tt = peekToken();
	  }
	  return expr;
	}

	private function bitAndExpr():IExpr
	{
	  var expr:IExpr = eqExpr();
	  for (var tt:int = peekToken(); tt == BITAND; )
	  {
		consumeToken();
		expr = exprFactory.createBitExpr(expr, eqExpr(), BITAND);
		tt = peekToken();
	  }
	  return expr;
	}

	protected function expression():IExpr
	{
	  var expr:IExpr = assignExpr();
	  while (matchToken(COMMA)) expr = exprFactory.createExprList(expr, assignExpr());
	  return expr;
	}

	protected function parseFunction(isAnon:Boolean=false):FunctionDef
	{
	  reportError("msg.function.expr.not.supported", "K09");
	  return null;
	}

	private function andExpr():IExpr
	{
	  var firstOp:int = 0;
	  var isNot:Boolean = false;
	  var expr:IExpr = bitOrExpr();
	  var tt:int = peekToken();
	  if (tt == AND || tt == NAND)
	  {
		firstOp = tt;
		for(isNot = tt == NAND; tt == firstOp; )
		{
		  consumeToken();
		  expr = exprFactory.createAndOrExpr(expr, andExpr(), true, isNot);
		  tt = peekToken();
		}
	  }
	  return expr;
	}

	private function relExpr():IExpr
	{
	  var expr:IExpr = shiftExpr();
	  var tt:int = peekToken();
	  loop0:
	  while (true)
	  {
		switch (tt)
		{
		  case IS:
		  case INSTANCEOF:
		  case IN:
		  case AS:
			consumeToken();
			expr = exprFactory.createIsInAsExpr(expr, shiftExpr(), tt);
			break loop0;
		  case LE:
		  case LT:
		  case GE:
		  case GT:
			consumeToken();
			expr = exprFactory.createEqRelExpr(expr, shiftExpr(), tt);
			tt = peekToken();
			continue;
		  default:
//			addr93:
			return expr;
		}
	  }
	  return expr;
	}

	private function memberExpr(allowCallSyntax:Boolean):IExpr
	{
	  var expr:IExpr = null;
	  if (peekToken() == NEW)
	  {
		consumeToken();
		expr = exprFactory.createNewExpr(memberExpr(false));
		if (matchToken(LP)) argumentList(expr as CallExpr);
	  }
	  else
	  {
		expr = primaryExpr();
	  }
	  return memberExprTail(allowCallSyntax, expr);
	}

	private function checkAssignable(expr:*):void
	{
	  if (!(expr is ISettable)) reportError("msg.not.assignable", "K03");
	}

	public function reportError(msgId:String, id:String, p1:String=null, p2:String=null, p3:String=null):void
	{
	  var v:int;
	  throw new ParseError(Env.getMessage(msgId, p1, p2, p3), id, (v = ts.getLineno()), ts.getLineFromNo(v));
	}

	private function memberExprTail(allowCallSyntax:Boolean, expr:IExpr):IExpr
	{
	  var tt:int = 0;
	  var descFlag:Boolean = false;
	  loop0:
	  while (true)
	  {
		tt = peekToken();
		switch (tt)
		{
		  case DOT:
		  case DOTDOT:
			consumeToken();
			descFlag = tt == DOTDOT;
			tt = nextToken();
			switch (tt)
			{
			  case NAME:
				expr = propertyName(expr, ts.getString(), descFlag);
				break;
			  case MUL:
				expr = propertyName(expr, "*", descFlag);
				break;
			  case XMLATTR:
				expr = attributeAccess(expr, descFlag);
				break;
			  default:
				reportError("msg.no.name.after.dot", "K06");
			  }
			  continue;
		  case DOTQUERY:
			consumeToken();
			expr = exprFactory.createDotQuery(expr,expression());
			mustMatchToken(RP, "msg.no.paren", "k05");
			continue;
		  case LB:
			consumeToken();
			expr = exprFactory.createAccessor(expr, expression());
			mustMatchToken(RB, "msg.no.bracket.index", "k06");
			continue;
		  case LP:
			if (!allowCallSyntax)
			{
//			  addr168:
//			  return expr;
			  break loop0;
			}
			consumeToken();
			expr = exprFactory.createCallExpr(expr);
			argumentList(expr as CallExpr);
			continue;
		  default:
			break loop0;
		}
	  }
	  return expr;
	}

	private function addExpr():IExpr
	{
	  var expr:IExpr = mulExpr();
	  var tt:int = peekToken();
	  while (tt == ADD || tt == SUB)
	  {
		consumeToken();
		expr = exprFactory.createAddSubExpr(expr, mulExpr(), tt == ADD);
		tt = peekToken();
	  }
	  return expr;
	}

	private function condExpr():IExpr
	{
	  var ifTrue:IExpr = null;
	  var expr:IExpr = orExpr();
	  if (matchToken(HOOK))
	  {
		ifTrue = assignExpr();
		mustMatchToken(COLON, "msg.no.colon.cond", "k01");
		expr = exprFactory.createCondExpr(expr, ifTrue, assignExpr());
	  }
	  return expr;
	}

	private function orExpr():IExpr
	{
	  var firstOp:int = 0;
	  var isNot:Boolean = false;
	  var isXor:Boolean = false;
	  var expr:IExpr = andExpr();
	  var tt:int = peekToken();
	  if (tt == OR || tt == NOR || tt == XOR)
	  {
		firstOp = tt;
		isNot = tt == NOR;
		for (isXor = tt == XOR; tt == firstOp; )
		{
		  consumeToken();
		  expr = exprFactory.createAndOrExpr(expr, orExpr(), false, isNot, isXor);
		  tt = peekToken();
		}
	  }
	  return expr;
	}

	protected function peekFlaggedToken():int
	{
	  peekToken();
	  return currentFlaggedToken;
	}

	protected function matchToken(toMatch:int):Boolean
	{
	  var tt:int = peekToken();
	  if (tt != toMatch) return false;
	  consumeToken();
	  return true;
	}

	protected function eof():Boolean { return ts.eof(); }

	private function primaryExpr():IExpr
	{
	  var expr:IExpr = null;
	  var elems:Array = null;
	  var after_lb_or_comma:Boolean = false;
	  var obj:Object = null;
	  var name:String = null;
	  var flags:String = null;
	  var property:* = undefined;
	  var allConstantElems:Boolean = true;
	  var ttFlagged:int = nextFlaggedToken();
	  var tt:int = ttFlagged & CLEAR_TI_MASK;
	  switch (tt)
	  {
		case FUNCTION:
		  return parseFunction(true);
		case LB:
		  elems = [];
		  after_lb_or_comma = true;
		  while (true)
		  {
			tt = peekToken();
			if (tt == COMMA)
			{
			  consumeToken();
			  if (!after_lb_or_comma) after_lb_or_comma = true;
			  else elems.push(Constant.NULL);
			}
			else
			{
			  if (tt == RB)
			  {
				consumeToken();
				break;
			  }
			  if (!after_lb_or_comma) reportError("msg.no.bracket.arg", "K10");
			  after_lb_or_comma = false;
			  expr = assignExpr();
			  if (expr is Constant)
			  {
				elems.push((expr as Constant).getAny());
			  }
			  else
			  {
				elems.push(expr);
				allConstantElems = false;
			  }
			}
		  }
		  return exprFactory.createObjectInit(elems, allConstantElems);
		case LC:
		  obj = {};
		  elems = [];
		  if(!matchToken(LC))
		  {
			loop1:
			do
			{
			  tt = int(peekToken());
			  switch(tt)
			  {
				case NAME:
				case STRING:
				  consumeToken();
				  property = ts.getString();
				  elems.push(property);
				  break;
				case NUMBER:
				  consumeToken();
				  property = ts.getNumber();
				  elems.push(property);
				  break;
				case RC:
				  break loop1;
				default:
				  reportError("msg.bad.prop", "K11");
				  break loop1;
			  }
			  mustMatchToken(COLON, "msg.no.colon.prop", "k08");
			  expr = assignExpr();
			  if (expr is Constant)
			  {
				obj[property] = (expr as Constant).getAny();
			  }
			  else
			  {
				obj[property] = expr;
				allConstantElems = false;
			  }
			}
			while (matchToken(COMMA));
			mustMatchToken(RC, "msg.no.brace.prop", "k09");
		  }
		  return exprFactory.createObjectInit(obj, allConstantElems, elems);
		case LP:
		  expr = expression();
		  mustMatchToken(RP, "msg.no.paren", "k10");
		  return expr;
		case XMLATTR:
		  return attributeAccess();
		case NAME:
		  name = ts.getString();
		  if ((ttFlagged & TI_CHECK_LABEL) != 0 && peekToken() == COLON)
		  {
			consumeToken();
			return new Label(name);
		  }
		  return propertyName(null, name);
		case THIS:
		  consumeToken();
		  return exprFactory.thisExpr();
		case NULL:
		  return exprFactory.literal(null);
		case FALSE:
		  return exprFactory.literal(false);
		case TRUE:
		  return exprFactory.literal(true);
		case NUMBER:
		  return exprFactory.literal(ts.getNumber());
		case STRING:
		  return exprFactory.literal(ts.getString());
		case DIV:
		case ASSIGN_DIV:
		  ts.readRegExp(tt);
		  flags = ts.regExpFlags;
		  ts.regExpFlags = null;
		  return exprFactory.regExp(ts.getString(), flags);
		case RESERVED:
		  reportError("msg.reserved.id", "K12");
		  break;
		case EOF:
		  reportError("msg.unexpected.eof", "K13");
		  break;
		case ERROR:
		default:
		  reportError("msg.syntax", "K14");
	  }
	  return null;
	}
  }
}