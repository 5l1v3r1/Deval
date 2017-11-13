package r1.deval.rt
{
  import r1.deval.parser.TokenStream;

  public class ForInPrologue extends EmptyStmt
  {
	internal var _iterVar:String;
	internal var _temp_arr_name:String;
	internal var _temp_idx_name:String;
	private var _forEach:Boolean;
	private var _collection:IExpr;

	public function ForInPrologue(forInLoopId:int, iterVar:String, collection:IExpr, forEach:Boolean, lineno:int, ts:TokenStream)
	{
	  super(lineno, ts);
	  this._iterVar = iterVar;
	  this._collection = collection;
	  this._forEach = forEach;
	  this._temp_arr_name = "_tmp_arr_" + forInLoopId;
	  this._temp_idx_name = "_tmp_idx_" + forInLoopId;
	}

	override public function exec():void
	{
	  var _tmp_arr:Array = null;
	  var x:* = undefined;
	  var coll:Object = _collection.getAny();
	  if (_forEach)
	  {
		if (coll is Array)
		{
		  _tmp_arr = coll as Array;
		}
		else
		{
		  _tmp_arr = [];
		  for each (x in coll) _tmp_arr.push(x);
		}
	  }
	  else
	  {
		_tmp_arr = [];
		for (x in coll) _tmp_arr.push(x);
	  }
	  Env.setProperty(_temp_arr_name, _tmp_arr);
	  Env.setProperty(_temp_idx_name, 0);
	}
  }
}