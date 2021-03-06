package r1.deval.rt
{
  import flash.utils.flash_proxy;
  import flash.utils.Proxy;

  public class ExprHolder extends Proxy
  {
	private var exprs:Object;
	private var isinited:Object;
	private var cleared:Boolean=false;

	public function ExprHolder(expressions:Object):void
	{
	  this.exprs = new Object();
	  for (var s:String in expressions) this.exprs[s] = expressions[s];
	  this.isinited = new Object();
	}

	flash_proxy override function hasProperty(name:*):Boolean
	{
	  if (this.cleared) return false;
	  return this.exprs.hasOwnProperty(name);
	}

	deval_namesp function clear():void
	{
	  this.exprs = null;
	  this.cleared = true;
	}

	flash_proxy override function getProperty(name:*):*
	{
	  if (this.cleared) return undefined;
	  if (!this.exprs.hasOwnProperty(name)) return undefined;
	  var v:* = this.exprs[name];
	  if (v is ClassDef) return v.getStaticObject();
	  if (this.isinited[name] == undefined)
	  {
		this.exprs[name] = v.getAny();
		this.isinited[name] = true;
	  }
	  return this.exprs[name];
	}

	deval_namesp function addProperty(name:*, value:*, init:Boolean=true):void
	{
	  if (this.cleared) return;
	  this.exprs[name] = value;
	  if (init) this.isinited[name] = true;
	  else delete this.isinited[name];
	}

	deval_namesp function getObject():Object { return this.exprs; }

	flash_proxy override function setProperty(name:*, value:*):void
	{
	  if (this.cleared) return;
	  this.exprs[name] = value;
	  this.isinited[name] = true;
	}

	flash_proxy override function callProperty(name:*, ...args):* { return this.exprs[name].apply(this.exprs[name], args); }

	flash_proxy override function deleteProperty(name:*):Boolean
	{
	  if (this.cleared || !this.exprs.hasOwnProperty(name)) return false;
	  delete this.exprs[name];
	  delete this.isinited[name];
	  return true;
	}
  }
}