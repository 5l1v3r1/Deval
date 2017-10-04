package r1.deval.rt
{
  import flash.system.ApplicationDomain;
  import flash.utils.describeType;
  
  import r1.deval.D;

  public class Env
  {
	public static var INFINITE_LOOP_LIMIT:Number = 100000;
	public static var outputFunction:Function = trace;

	private static var _curEnv:Env;
	private static var stack:Array = [];
	private static var _overrideGlobalOption:int = D.OVERRIDE_GLOBAL_OVERRIDE;

	private static const _global:Object = {"decodeURI":decodeURI, "decodeURIComponent":decodeURIComponent, "encodeURI":encodeURI, "encodeURIComponent":encodeURIComponent,
		"escape":escape, "isFinite":isFinite, "isNaN":isNaN, "isXMLName":isXMLName, "parseFloat":parseFloat, "parseInt":parseInt, "trace":trace, "unescape":unescape,
		"printf":printf, "importFunction":importFunction, "importStaticMethods":importStaticMethods, "Array":Array, "Boolean":Boolean, "int":int, "Number":Number,
		"Object":Object, "String":String, "uint":uint, "XML":XML, "XMLList":XMLList, "Date":Date, "Math":Math, "RegExp":RegExp, "QName":QName, "Namespace":Namespace,
		"Error":Error, "Class":Class};

	private static const __errors:Object = {
		"msg.no.paren.parms":"missing ( before function parameters.",
		"msg.misplaced.case":"misplaced case",
		"msg.no.colon.prop":"missing : in object property definition",
		"msg.no.brace.switch":"missing { in switch",
		"msg.bad.continue":"incorrect use of continue",
		"msg.illegal.character":"illegal character",
		"msg.reserved.id":"identifier is a reserved word",
		"msg.bad.break.continue":"incorrect use of break or continue",
		"msg.unreachable.code":"unreachable code",
		"msg.bad.prop":"invalid property id",
		"msg.no.name.after.dot":"missing name after . operator",
		"msg.no.paren":"missing ) in parenthetical",
		"msg.misplaced.right.brace":"misplaced }",
		"msg.unreachable.stmts.in.switch":"unreachable code in switch statement",
		"msg.XML.bad.form":"illegally formed XML syntax",
		"msg.dup.label":"duplicatet label",
		"msg.no.semi.stmt":"missing ; before statement",
		"msg.class.not.supported":"class not supported",
		"msg.no.colon.cond":"missing : in conditional expression",
		"msg.bad.number.base":"incorrect number base",
		"msg.missing.exponent":"missing exponent",
		"msg.case.no.colon":"missing : after case expression",
		"msg.no.name.after.xmlAttr":"missing name after .@",
		"msg.no.brace.prop":"missing } after property list",
		"msg.unterminated.re.lit":"unterminated regular expression literal",
		"msg.invalid.escape":"invalid Unicode escape sequence",
		"msg.unterminated.comment":"unterminated comment",
		"msg.invalid.re.flag":"invalid flag after regular expression",
		"msg.caught.nfe":"number format error",
		"msg.not.assignable":"not assignable",
		"msg.unexpected.eof":"Unexpected end of file",
		"msg.no.brace.body":"missing \'{\' before function body",
		"msg.undef.label":"undefined labe",
		"msg.function.expr.not.supported":"function expression is not supported",
		"msg.missing.function.name":"missing function name",
		"msg.syntax":"syntax error",
		"msg.unterminated.string.lit":"unterminated string literal",
		"msg.no.bracket.arg":"missing ] after element list",
		"msg.bad.namespace":"not a valid default namespace statement. Syntax is: default xml namespace : EXPRESSION;",
		"msg.no.bracket.index":"missing ] in index expression",
		"msg.no.name.after.coloncolon":"missing name after ::",
		"msg.no.paren.for":"missing ( after for",
		"msg.no.paren.after.parms":"missing ) after formal parameters"};

	public var _globalVars:Object = globalVars;
	public var _globalDyns:Array = globalDyns;

	private var thisObject_getters:Object;
	private var scopeChain:Array;
	private var context:Object;
	private var thisObject_setters:Object;
	private var thisObject:Object;
	private var result:Object;
	private var tempObjects:Object = new Object();

	public function Env(thisObj:Object, cntxt:Object)
	{
	  super();
	  this.context = cntxt == null ? (new Object()) : cntxt;
	  this.scopeChain = [[false, new ContextProxy(this.context)]];
	  this.setThis(thisObj);
	  if (thisObject != null)
	  {
		this.scopeChain.push([false, new ContextProxy(thisObject)]);
		if (thisObject.prototype != null) this.scopeChain.push([false, new ContextProxy(thisObject.prototype)]);
	  }
	  this.scopeChain.push([false, new ContextProxy(globalVars)]);
	  this.scopeChain.push([false, new ContextProxy(_global)]);
	}

	public function setThis(thisObj:Object):void
	{
	  var xml:XML = null;
	  var x:XML = null;
	  var access:String = null;
	  thisObject_setters = {};
	  thisObject_getters = {};
	  if (thisObj)
	  {
		thisObject = thisObj;
		xml = describeType(thisObj);
		for each (x in xml.accessor)
		{
		  access = x.@access;
		  if (access == "readwrite") thisObject_setters[x.@name] = thisObject_getters[x.@name] = true;
		  else if (access == "readonly") thisObject_getters[x.@name] = true;
		  else if (access == "writeonly") thisObject_setters[x.@name] = true;
		}
	  }
	  else
	  {
		thisObject = null;
		thisObject_setters = thisObject_getters;
	  }
	}

	public static function setContext(cntxt:Object):void { _curEnv.context = cntxt; }

	public static function setThis(thisObj:Object):void { _curEnv.setThis(thisObj); }

	public static function createSnapshot():Env { return _curEnv.createSnapshot(); }

	public function createSnapshot():Env
	{
	  var env:Env = new Env(null, null);
	  env.scopeChain = scopeChain.concat();
	  env._globalVars = this._globalVars;
	  env._globalDyns = this._globalDyns;
	  return env;
	}

	public static function get globalVars():Object
	{
	  if (_curEnv == null) return (new Object());
	  else return _curEnv._globalVars;
	}

	public static function get globalDyns():Array
	{
	  if (_curEnv == null) return (new Array());
	  else return _curEnv._globalDyns;
	}

	public static function getClass(className:String):Class
	{
	  var x:* = globalVars[className];
	  if (x == null) x = _global[className];
	  if (x == null)
	  {
		try
		{
		  return (getProperty(className) as Class);
		}
		catch(e:Error)
		{
		  return null;
		}
	  }
	  if (x is Class) return x as Class;
	  if (x is Array)
	  {
		x = (x as Array)[0];
		if (x is Class) return x;
	  }
	  return null;
	}

	public static function getProperty(prop:*, checkonly:Boolean=false):* { return _curEnv.getProperty(prop, checkonly); }

	public static function isInDocQuery():Boolean
	{
		var x:* = peekObject();
		return x is XML || x is XMLList;
	}

	public static function reportWarning(...args):void { outputFunction("[D:warn ] " + getMessage.apply(null, args)); }

	public static function display(msg:String):void { outputFunction(msg); }

	public static function run(prgm:Block, thisObj:Object = null, cntxt:Object = null, funcList:Array=null, classList:Object=null):Object
	{
	  var env:Env = new Env(thisObj, cntxt != null ? cntxt:{});
	  var currCntxt:Object;
	  if (prgm)
	  {
		try
		{
		  pushEnv(env);
		  currCntxt = _curEnv.context;
		  if (classList != null) Env.pushObject(classList, true);
		  if (funcList != null)
		  {
			for each (var p:FunctionDef in funcList) Env.setProperty(p.name, p.getFunction(currCntxt));
		  }
		  prgm.run();
		  return env.returnValue;
		}
		catch (e:Error)
		{
		  if (e is ErrorContainer) throw e.rtError;
		  else throw e;
		}
		finally
		{
		  popEnv();
		}
	  }
	  return null;
	}

	public static function importClass(cls:Class, clsName:String=null):void
	{
	  if (clsName == null) clsName = describeType(cls).@name;
	  var segs:Array = clsName.split(/\./g);
	  clsName = segs[segs.length - 1];
	  importGlobal(clsName, cls);
	}

	public static function getThis():Object { return _curEnv.thisObject; }

	public static function setProperty(prop:*, val:Object):void { _curEnv.setProperty(prop, val); }

	public static function setNewProperty(prop:*, val:Object):void { _curEnv.setNewProperty(prop, val); }

	public static function printf(...args):void { display(getMessageAsIs.apply(null, args)); }

	public static function popEnv():void
	{
	  stack.pop();
	  if (stack.length > 0) _curEnv = stack[stack.length - 1];
	  else _curEnv = null;
	}

	public static function importFunction(name:String, f:Function):void
	{
	  var r:Array = name.split(/\./g);
	  importGlobal(r[r.length - 1], f);
	}

	public static function importStar(param1:String):void
	{
	  if (globalDyns.indexOf(param1) == -1) globalDyns.push(param1);
	}

	public static function setReturnValue(ret:*):void { _curEnv.returnValue = ret; }

	public static function getMessage(...args):String
	{
	  if (args.length > 0) args[0] = idToMessage(args[0]);
	  return getMessageAsIs.apply(null, args);
	}

	public static function setOverrideGlobalOption(option:int):void { _overrideGlobalOption = option; }

	private static function importGlobal(name:String, value:*) : void
	{
	  if (_overrideGlobalOption != D.OVERRIDE_GLOBAL_OVERRIDE)
	  {
		if (_global[name])
		{
		  switch (_overrideGlobalOption)
		  {
			case D.OVERRIDE_GLOBAL_WARN:
			  reportWarning("msg.override.global.name", name);
			  break;
			case D.OVERRIDE_GLOBAL_ERROR:
			  throw new RTError("msg.override.global.name", name);
		  }
		}
	  }
	  globalVars[name] = value;
	}

	public static function getReturnValue():* { return _curEnv.returnValue; }

	public static function getMessageAsIs(...args):String
	{
	  switch (args.length)
	  {
		case 0:
		  return "";
		case 1:
		  return String(args[0]);
		default:
		  return Util.substitute.apply(null, args);
	  }
	}

	public static function popObject(temp:Boolean=false):* { return _curEnv.popObject(); }

	private static function idToMessage(id:String):String
	{
	  var msg:String = __errors[id] as String;
	  return msg == null ? id : msg;
	}

	public static function pushEnv(env:Env):void { stack.push(_curEnv = env); }

	public static function reportError(...args):void { outputFunction("[D:error] " + getMessage.apply(null, args)); }

	public static function debug(...args):void { outputFunction("[D:debug] " + getMessage.apply(null, args)); }

	public static function pushObject(obj:*, temp:Boolean=false):void { _curEnv.pushObject(obj); }

	public static function peekObject():*
	{
	  var ret:*;
	  for each (var arr:Array in _curEnv.scopeChain)
	  {
		if (arr[0]) continue;
		ret = arr[1].deval_namesp::getObject();
		break;
	  }
	  return ret;
	}

	public static function importStaticMethods(cls:Class, criteria:*=null):void
	{
	  var mthd:XML = null;
	  var n:String = null;
	  var xml:XML = describeType(cls);
	  for each (mthd in xml.method)
	  {
		n = mthd.@name;
		if (criteria)
		{
		  if (criteria is RegExp)
		  {
			if (!n.match(criteria as RegExp)) n = null;
		  }
		  else if (criteria is Array)
		  {
			if ((criteria as Array).indexOf(n) < 0) n = null;
		  }
		  else if (n != criteria)
		  {
			n = null;
		  }
		}
		if (n) importFunction(n, cls[n]);
	  }
	}

	internal function set returnValue(param1:*):void { result = param1; }

	internal function get returnValue():* { return result; }

	internal function getProperty(param1:*, checkonly:Boolean=false):*
	{
	  if (param1 == "null") return null;
	  if (param1 == "undefined")
	  {
		if (checkonly) return null;
		else return undefined;
	  }
	  var _loc2_:Array;
	  for each (_loc2_ in scopeChain)
	  {
		if (_loc2_[1].deval_namesp::hasGetProperty(param1))
		{
		  if (checkonly) return null;
		  else return _loc2_[1][param1];
		}
	  }
	  if (thisObject != null && thisObject_getters[param1])
	  {
		if (checkonly) return null;
		else return thisObject[param1];
	  }
	  var ad:ApplicationDomain = ApplicationDomain.currentDomain;
	  var x:*;
	  for (var j:int = 0; j < globalDyns.length; j++)
	  {
		try
		{
		  x = ad.getDefinition(globalDyns[j] + "." + param1);
		}
		catch(e:Error)
		{
		  continue;
		}
		if (x != null)
		{
		  if (x is Class)
		  {
			importClass(x as Class, param1);
			if (checkonly) return null;
			else return globalVars[param1];
		  }
		  else if (x is Function)
		  {
			importFunction(param1, x as Function);
			if (checkonly) return null;
			else return globalVars[param1];
		  }
		}
	  }
	  try
	  {
		x = ad.getDefinition(param1);
		if (x != null) return x;
	  }
	  catch (e:Error)
	  {}
	  return undefined;
	}

	internal function popObject(temp:Boolean=false):*
	{
	  var arr:Array;
	  while ((arr = scopeChain.shift())[0] != temp) continue;
	  return arr[1].deval_namesp::getObject();
	}

	internal function setNewProperty(param1:*, param2:*):void { context[param1] = param2; }

	internal function setProperty(prop:*, val:*):void
	{
	  var x:Array;
	  for each (x in scopeChain)
	  {
		if (x[0]) continue;
		if (x[1].deval_namesp::hasSetProperty(prop))
		{
		  x[1][prop] = val;
		  return;
		}
	  }
	  if (thisObject != null && (thisObject.hasOwnProperty(prop) || thisObject_setters[prop])) thisObject[prop] = val;
	  else context[prop] = val;
	}

	internal function pushObject(obj:*, temp:Boolean=false):void { scopeChain.unshift([temp, new ContextProxy(obj)]); }
  }
}