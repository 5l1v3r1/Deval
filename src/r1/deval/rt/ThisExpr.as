package r1.deval.rt
{
  public class ThisExpr extends ObjectExprBase
  {
	public static const INSTANCE:ThisExpr = new ThisExpr();

	public function ThisExpr() { super(); }

	override public function getAny():Object { return Env.getThis(); }
  }
}