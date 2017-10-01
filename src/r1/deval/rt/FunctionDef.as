package r1.deval.rt
{
  import r1.deval.D;

  public class FunctionDef implements IExpr
  {
	private var head:Block;
	private var params:Array;
	public var name:String;
	private var restParam:String = null;
	private var tail:EndBlock;

	public function FunctionDef(_name:String, _params:Array, _head:Block, _tail:EndBlock)
	{
	  super();
	  this.name = _name == null ? "_anonymous_" : _name;
	  if (_params.length > 0 && _params[_params.length - 1].substring(0, 3) == "...") restParam = _params.pop().substr(3);
	  this.params = _params;
	  this.head = _head;
	  this.tail = _tail;
	}

	public function optimize():void
	{
	  if (head != null) head.optimize();
	}

	public function getAny():Object { return getFunction(); }

	public function getNumber():Number { throw new RTError("msg.rt.eval.function.to.value"); }

	public function getString():String { throw new RTError("msg.rt.eval.function.to.value"); }

	public function getBoolean():Boolean { throw new RTError("msg.rt.eval.function.to.value"); }

	public function getFunction(thisobj:Object=null):Function
	{
	  var fixthisobj:Object = thisobj;
	  var snp:Env = Env.createSnapshot();
	  if (thisobj) snp.setThis(thisobj);
	  var x:Function = function(...args):Object
	  {
		Env.pushEnv(snp);
		if (!fixthisobj) Env.setThis(this);
		try
		{
		  return run(args, null);
		}
		catch(e:Error)
		{
		  RTErrorHandler.dispatch(e);
		  throw e;
		}
		finally
		{
		  if (!fixthisobj) Env.setThis(null);
		  Env.popEnv();
		}
		return null;
	  }
	  return x;
	}

	public function run(paramVals:Array, cont:Object=null):Object
	{
	  var paramVals:Array = paramVals;
	  var paramsLen:int = params == null ? 0 : int(params.length);
	  var len:int = paramVals == null ? 0 : int(paramVals.length);
	  if (len > paramsLen) len = paramsLen;
	  var context:Object = cont != null ? cont : new Object();
	  for (var i:int = 0; i < len; i++) context[params[i]] = paramVals[i];
	  if (restParam != null)
	  {
		var v:Array = new Array();
		for (i = len; i < paramVals.length; i++) v.push(paramVals[i]);
		context[restParam] = v;
	  }
	  try
	  {
		Env.pushObject(context);
		Env.setContext(context);
		Env.setReturnValue(null);
		head.run(tail);
		return Env.getReturnValue();
	  }
	  finally
	  {
		Env.popObject();
		Env.setContext(null);
	  }
	  return null;
	}

	public function dump(dumpMap:Object):void
	{
	  var ret:* = "\n<Function name=\"" + name + "\" params=\"";
	  var len:int = params == null ? 0 : int(params.length);
	  for (var i:int = 0; i < len; i++)
	  {
		if (i > 0) ret = ret + ",";
		ret = ret + params[i];
	  }
	  trace(ret + "\">");
	  head.dump(dumpMap, 1);
	  trace("\n</Function>");
	}
  }
}