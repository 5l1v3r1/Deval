package r1.deval.rt
{
  internal class VarExpr extends ObjectExprBase
  {
	private var init:IExpr, name:String;

	public function VarExpr(_name:String, _init:IExpr=null)
	{
	  super();
	  this.name = _name;
	  this.init = _init;
	}

	override public function getAny():Object
	{
	  var val:Object = init == null ? null : init.getAny();
	  Env.setNewProperty(name, val);
	  return val;
	}
  }
}