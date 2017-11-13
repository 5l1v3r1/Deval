package r1.deval.rt
{
  import r1.deval.parser.TokenStream;

  public class ExprStmt extends EmptyStmt
  {
	private var _expr:IExpr;

	public function ExprStmt(expr:IExpr, lineno:int, ts:TokenStream)
	{
	  super(lineno, ts);
	  this._expr = expr;
	}
	
	override public function exec():void { Env.setReturnValue(_expr.getAny()); }
	
	public function get expr():IExpr { return this._expr; }
	
	public function toString():String { return String(_expr); }
  }
}