package r1.deval.rt
{
  import r1.deval.parser.BaseParser;
  import r1.deval.parser.TokenStream;

  public class Block
  {
	private static var blockCount:int=0;
	private var _trueNext:Block;
	private var _cond:IExpr;
	private var _falseReferencers:Array=null;
	public var name:String;
	private var _trueReferencers:Array=null;
	private var _optimized:Boolean=false;
	public var stmts:Array;
	private var _cond_lineno:int;
	private var _falseNext:Block;
	private var _lastIsExit:Boolean=false;
	private var isTryBlock:Boolean=false;
	private var catchBlocks:Array = new Array();
	private var catchVar:String;
	private var finallyBlock:Block=null;

	public function Block(_name:String=null, normal:Boolean=true)
	{
	  super();
	  if (BaseParser.debugDump || !normal)
	  {
		if (normal)
		{
		  if (_name == null) _name = "";
		  this.name = _name + "/" + ++blockCount;
		}
		else
		{
		  this.name = _name;
		}
	  }
	  _optimized = !normal;
	}

	public function isSimple():Boolean { return (_cond == null) && !isTryBlock; }

	public function addCatchBlock(err:String, errortype:IExpr, bl:Block):void
	{
	  isTryBlock = true;
	  catchBlocks.push({catchBlock:bl, catchVar:err, errortype:errortype});
	}

	public function setFinallyBlock(bl:Block):void { finallyBlock = bl; }

	public function info(indent:int=0):String
	{
	  var stmt:IStmt = null;
	  var ind:String = "";
	  for (var i:int = 0; i < indent; i++) ind += "  ";
	  var indnl:String = "\n" + ind;
	  if (this is EndBlock)
	  {
		if (this == EndBlock.EXIT) return ind + "<EXIT name=\"" + name + "\" />";
		return null;
	  }
	  if (isConditional()) return ind + condInfo(true);
	  var ret:String = ind + "<Block name=\"" + name + "\" optimized=\"" + _optimized + "\">";
	  for each (stmt in stmts)
	  {
		ret = ret + (indnl + "  <stmt");
		if (stmt.lineno > 0) ret = ret + (" line=\"" + stmt.lineno + "\"");
		ret = ret + (">" + String(stmt) + "</stmt>");
	  }
	  return ret + indnl + "  " + condInfo() + indnl + "</Block>";
	}

	public function addStmt(s:Object, lineno:int, ts:TokenStream):void
	{
	  if (stmts == null) stmts = [];
	  if (!(s is IStmt))
	  {
		if (s is IExpr) s = new ExprStmt(s as IExpr, lineno, ts);
	  }
	  stmts.push(s);
	}

	public function isEmpty():Boolean { return isSimple() && (stmts == null || stmts.length == 0) && !(this is EndBlock); }

	private function addReferencer(ref:Block, trueOrFalse:Boolean=true):void
	{
	  if (trueOrFalse)
	  {
		if (_trueReferencers == null) _trueReferencers = [];
		_trueReferencers.push(ref);
	  }
	  else
	  {
		if (_falseReferencers == null) _falseReferencers = [];
		_falseReferencers.push(ref);
	  }
	}

	public function set trueNext(blk:Block):void
	{
	  if (_trueNext != null) _trueNext.removeReferencer(this);
	  _trueNext = blk;
	  if (blk != null) blk.addReferencer(this);
	}

	public function isConditional():Boolean { return (stmts == null || stmts.length == 0) && _cond != null; }

	public function getCond():IExpr { return _cond; }

	public function run(nextBlock:Block=null):void
	{
	  if (nextBlock == null) nextBlock = EndBlock.EXIT;
	  var b:Block = this;
	  var loopCnt:Number = 0;
	  while (b != null && b != nextBlock)
	  {
		b = b.exec();
		if (loopCnt > Env.INFINITE_LOOP_LIMIT) throw new RTError("msg.rt.infinite.loop");
		loopCnt++;
	  }
	}

	public function get lastIsExit():Boolean { return _lastIsExit || _trueNext is EndBlock; }

	public function exec():Block
	{
	  var s:IStmt = null;
	  if (stmts != null)
	  {
		var ee:Error;
		for each (s in stmts)
		{
		  try
		  {
			s.exec();
		  }
		  catch (e:Error)
		  {
			if (e is RTError)
			{
			  (e as RTError).pushline(s.line, s.lineno);
			  ee = e;
			}
			else if (e is ErrorContainer)
			{
			  e.rtError.pushline(s.line, s.lineno);
			  ee = e;
			  e = e.error;
			}
			else
			{
			  ee = new ErrorContainer(new RTError(e.message), e);
			  ee.rtError.pushline(s.line, s.lineno);
			}
			if (isTryBlock)
			{
			  var res:*, ok:Boolean=false;
			  var l:Object, m:IExpr;
			  var o:Class;
			  var v:Object;
			  for each (l in catchBlocks)
			  {
				m = l.errortype;
				if (m != null)
				{
				  o = m.getAny() as Class;
				  if (o == null || !(e is o)) continue;
				}
				v = new Object();
				v[l.catchVar] = e;
				Env.pushObject(v, true);
				try
				{
				  l.catchBlock.run();
				  res = Env.getReturnValue();
				  ok = true;
				  break;
				}
				finally {Env.popObject(true);}
			  }
			  if (finallyBlock != null) finallyBlock.run();
			  if (ok)
			  {
				Env.setReturnValue(res);
				break;
			  }
			}
			throw ee;
		  }
		}
	  }
	  if (_cond == null || _cond.getBoolean()) return _trueNext;
	  return _falseNext;
	}

	public function get trueNext():Block { return _trueNext; }

	public function setCond(expr:IExpr, lineno:int=-1):void
	{
	  _cond = expr;
	  if (lineno >= 0) _cond_lineno = lineno;
	}

	public function set falseNext(blk:Block):void
	{
	  if (_falseNext != null) _falseNext.removeReferencer(this, false);
	  _falseNext = blk;
	  if (blk != null) blk.addReferencer(this, false);
	}

	public function condInfo(withName:Boolean=false):String
	{
	  if (trueNext is EndBlock) return "<return/>";
	  var ret:String = _cond == null ? "<goto " : "<test ";
	  if (withName && name != null) ret = ret + ("name=\"" + name + "\" ");
	  if (_cond != null) ret = ret + ("expr=\"" + String(_cond) + "\" ");
	  if (_cond_lineno > 0) ret = ret + ("line=\"" + _cond_lineno + "\" ");
	  if (_trueNext != null) ret = ret + ("trueNext=\"" + _trueNext.name + "\" ");
	  if (_falseNext != null && _cond != null) ret = ret + ("falseNext=\"" + _falseNext.name + "\" ");
	  return ret + "/>";
	}

	private function removeReferencer(ref:Block, trueOrFalse:Boolean=true):void
	{
	  if (trueOrFalse)
	  {
		if (_trueReferencers != null) _trueReferencers.splice(_trueReferencers.indexOf(this));
	  }
	  else if (_falseReferencers != null)
	  {
		_falseReferencers.splice(_falseReferencers.indexOf(this));
	  }
	}

	public function dump(dumpMap:Object, indent:int=0):void
	{
	  if (dumpMap[name] != null) return;
	  dumpMap[name] = true;
	  var msg:String = info(indent);
	  if (msg != null) trace("\n" + msg);
	  if (trueNext != null) trueNext.dump(dumpMap, indent);
	  if (falseNext != null) falseNext.dump(dumpMap, indent);
	}

	public function optimize():void
	{
	  return;
	  var blk:Block = null;
	  var o:Object = null;
	  var cblk:Block = null;
	  if (_optimized) return;
	  _optimized = true;
	  if (_trueNext != null && !(_trueNext is EndBlock))
	  {
		_trueNext.optimize();
		if (_trueNext.isEmpty())
		{
		  trueNext = _trueNext.trueNext;
		}
		else if (isSimple())
		{
		  blk = _trueNext as Block;
		  if (blk.getRefCount() == 1 && blk.isSimple() )
		  {
			if (stmts == null)
			{
			  stmts = blk.stmts;
			}
			else
			{
			  for each (o in blk.stmts)
			  {
				stmts.push(o);
			  }
			}
			trueNext = blk.trueNext;
		  }
		}
	  }
	  if (_falseNext != null && !(_falseNext is EndBlock))
	  {
		_falseNext.optimize();
		if (_falseNext.isEmpty()) falseNext = _falseNext.trueNext;
	  }
	  if (isEmpty() && !(trueNext != null && trueNext.isTryBlock))
	  {
		for each (cblk in _trueReferencers)
		{
		  if (cblk != null) cblk._trueNext = _trueNext;
		}
		for each (cblk in _falseReferencers)
		{
		  if (cblk != null) cblk._falseNext = _trueNext;
		}
		trueNext = falseNext = null;
		_trueReferencers = _falseReferencers = null;
	  }
	}

	public function get falseNext():Block { return _falseNext; }

	public function getRefCount():int { return (_trueReferencers == null ? 0 : _trueReferencers.length) + (_falseReferencers == null ? 0 : _falseReferencers.length); }

	public function set lastIsExit(b:Boolean):void { _lastIsExit = b; }
  }
}