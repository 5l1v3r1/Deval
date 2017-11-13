package r1.deval.rt
{
  public class ForInCond extends ObjectExprBase
  {
	private var _fip:ForInPrologue;

	public function ForInCond(fip:ForInPrologue)
	{
	  super();
	  this._fip = fip;
	}

	override public function getBoolean():Boolean
	{
	  var arr:Array = Env.getProperty(_fip._temp_arr_name) as Array;
	  var idx:int = Env.getProperty(_fip._temp_idx_name) as int;
	  if (idx >= arr.length) return false;
	  Env.setProperty(_fip._iterVar, arr[idx]);
	  Env.setProperty(_fip._temp_idx_name, idx + 1);
	  return true;
	}
  }
}