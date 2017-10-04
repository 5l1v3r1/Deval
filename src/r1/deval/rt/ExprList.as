package r1.deval.rt
{
  public class ExprList implements IExpr
  {
	private var exprs:Array;

	public function ExprList(expr1:IExpr, expr2:IExpr)
	{
		exprs = [];
		super();
		if (expr1 != null) exprs.push(expr1);
		if (expr2 != null) exprs.push(expr2);
	}

	public function add(expr:IExpr):void { exprs.push(expr); }

	public function getNumber():Number { return Number(getAny()); }

	public function reduce():IExpr
	{
	  if (exprs.length == 1) return exprs[0] as IExpr;
	  return this;
	}

	public function getString():String
	{
	  var o:Object = getAny();
	  if (o == null) return null;
	  return o.toString();
	}

	public function getBoolean():Boolean { return Boolean(getAny()); }

	public function getAny():Object
	{
	  for (var i:int = 0; i < exprs.length - 1; i++) (exprs[i] as IExpr).getAny();
	  return (exprs[exprs.length - 1] as IExpr).getAny();
	}
  }
}