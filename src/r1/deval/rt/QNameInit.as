package r1.deval.rt
{
  public class QNameInit extends ObjectExprBase
  {
	private var ns:IExpr, name:IExpr;

	public function QNameInit(_ns:IExpr, _name:IExpr)
	{
	  super();
	  this.ns = _ns;
	  this.name = _name;
	}

	override public function getAny():Object { return new QName(ns.getAny() as Namespace,name.getString()); }
  }
}