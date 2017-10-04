package r1.deval.rt
{
  import r1.deval.parser.ParserConsts;
  import r1.deval.parser.TokenStream;

  public class ExprFactory extends ParserConsts
  {
	public function ExprFactory()
	{
	  super();
	}

	public function createVarExpr(name:String, init:IExpr=null, list:IExpr=null):IExpr { return createExprList(list, new VarExpr(name, init)); }

	public function createXMLAttrExpr(expr:IExpr):IExpr { return new UnaryExpr(expr, ESCXMLATTR); }

	public function createAndOrExpr(left:IExpr, rest:*, op:Boolean, isNot:Boolean, isXor:Boolean=false):IExpr
	{
	  if(left is AndOrExpr && AndOrExpr(left).isA(op, isNot, isXor))
	  {
		AndOrExpr(left).addOperand(rest);
		return left;
	  }
	  return new AndOrExpr(left, rest, op, isNot, isXor);
	}

	public function createAccessor(host:IExpr, index:*, ns:IExpr=null, attrFlag:Boolean=false, descFlag:Boolean=false):IExpr
	{
	  var idx:* = index;
	  if (idx is Constant) idx = (idx as Constant).getAny();
	  if (ns == null && !attrFlag && !descFlag) return new Accessor(host, idx);
	  return new XMLAccessor(host, idx, ns, false, attrFlag, descFlag);
	}

	public function createEqRelExpr(left:IExpr, right:IExpr, op:int):IExpr
	{
	  if (left is EqRelExpr)
	  {
		EqRelExpr(left).addOperand(right, op);
		return left;
	  }
	  return new EqRelExpr(left, [right], [op]);
	}

	public function createUnaryExpr(base:IExpr, tt:int):IExpr
	{
	  if (tt == ADD) return base;
	  if (tt == SUB)
	  {
		if (base is Constant)
		{
		  if (base == Constant.ONE) return Constant.MINUSONE;
		  if (base.getAny() is Number) return new Constant(-base.getNumber());
		}
	  }
	  return new UnaryExpr(base,tt);
	}

	public function createAssignment(left:ISettable, right:IExpr, op:int, lineno:int, ts:TokenStream):IExpr { return new Assignment(left, right, op, lineno, ts); }

	public function createDotQuery(host:IExpr, expr:IExpr):IExpr { return new XMLAccessor(host, expr, null, true); }

	public function createObjectInit(val:Object, allConstantElems:Boolean=false, elems:Array=null):IExpr { return !!allConstantElems ? new Constant(val) : new ObjectInit(val, elems); }

	public function createBitExpr(left:IExpr, rest:*, op:int):IExpr
	{
	  if (left is BitExpr && BitExpr(left).isA(op))
	  {
		BitExpr(left).addOperand(rest);
		return left;
	  }
	  return new BitExpr(left, rest, op);
	}

	public function createMulDivModExpr(left:IExpr, right:IExpr, op:int):IExpr
	{
	  if (left is MulDivModExpr)
	  {
		MulDivModExpr(left).addOperand(right, op);
		return left;
	  }
	  return new MulDivModExpr(left,[right], [op]);
	}

	public function literal(val:Object):IExpr
	{
	  if (val is Number)
	  {
		if (val == 0) return Constant.ZERO;
		if (val == 1) return Constant.ONE;
		if (val == -1) return Constant.MINUSONE;
	  }
	  else
	  {
		if (val is Boolean) return val == true ? Constant.TRUE : Constant.FALSE;
		if (val == null) return Constant.NULL;
		if (val == "") return Constant.EMPTY_STRING;
	  }
	  return new Constant(val);
	}

	public function createQNameInit(ns:IExpr, name:IExpr):IExpr
	{
	  if (ns is Constant && name is Constant) return new Constant(new QName(ns.getAny() as Namespace, name.getString()));
	  return new QNameInit(ns, name);
	}

	public function createIsInAsExpr(left:IExpr, right:IExpr, op:int):IExpr { return new IsInAsExpr(left, right, op); }

	public function thisExpr():IExpr { return ThisExpr.INSTANCE; }

	public function createCallExpr(expr:IExpr):CallExpr { return new CallExpr(false, expr); }

	public function createAddSubExpr(left:IExpr, right:IExpr, op:Boolean=true):IExpr
	{
	  if (left == null) return !!op?right:createUnaryExpr(right, SUB);
	  if (left is AddSubExpr)
	  {
		AddSubExpr(left).addOperand(right, op);
		return left;
	  }
	  return new AddSubExpr(left, [right], [op]);
	}

	public function regExp(re:String, flags:String):IExpr { return new Constant(new RegExp(re, flags)); }

	public function createNewExpr(expr:IExpr):CallExpr { return new CallExpr(true, expr); }

	public function createCondExpr(cond:IExpr, truePart:IExpr, falsePart:IExpr):IExpr { return new CondExpr(cond, truePart, falsePart); }

	public function createShiftExpr(left:IExpr, right:IExpr, op:int):IExpr
	{
	  if (left is ShiftExpr)
	  {
		ShiftExpr(left).addOperand(right, op);
		return left;
	  }
	  return new ShiftExpr(left, [right], [op]);
	}

	public function createXMLLiteralExpr(lead:IExpr, tail:IExpr):IExpr { return new UnaryExpr(createAddSubExpr(lead, tail), ESCXMLTEXT); }

	public function createExprList(expr:IExpr, more:IExpr):IExpr
	{
	  if (expr == null) return more;
	  if (expr is ExprList)
	  {
		ExprList(expr).add(more);
		return expr;
	  }
	  return new ExprList(expr, more);
	}
  }
}