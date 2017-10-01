package r1.deval.rt
{
  import flash.utils.Proxy;
  import flash.utils.describeType;
  import flash.utils.flash_proxy;

  public class ContextProxy extends Proxy
  {
	private var obj:Object;
	private var getters:Object = new Object();
	private var setters:Object = new Object();
	private var isProxy:Boolean = false;
	private var isnull:Boolean = false;

	public function ContextProxy(o:Object):void
	{
	  this.obj = o;
	  if (o == null)
	  {
		this.isnull = true;
		return;
	  }
	  if ((o is ClassProxy) || (o is InstanceProxy) || (o is ContextProxy))
	  {
		this.isProxy=true;
		return;
	  }
	  var xml:XML = describeType(o);
	  var s:String;
	  for each (var x:XML in xml.accessor)
	  {
		s = x.@access;
		if (s == "readwrite") setters[x.@name] = getters[x.@name] = true;
		else if (s == "readonly") getters[x.@name] = true;
		else if (s == "writeonly") setters[x.@name] = true;
	  }
	}

	deval_namesp function hasGetProperty(prop:*):Boolean
	{
	  if (this.isnull) return false;
	  if (this.isProxy) return this.obj.deval_namesp::hasGetProperty(prop);
	  return this.obj.hasOwnProperty(prop) || this.getters.hasOwnProperty(prop);
	}
	
	deval_namesp function hasSetProperty(prop:*):Boolean
	{
	  if (this.isnull) return false;
	  if (this.isProxy) return this.obj.deval_namesp::hasSetProperty(prop);
	  return this.obj.hasOwnProperty(prop) || this.setters.hasOwnProperty(prop);
	}

	deval_namesp function getObject():Object { return this.obj; }

	flash_proxy override function callProperty(name:*, ...args):* { return this.obj[name].apply(this.obj[name], args); }

	flash_proxy override function hasProperty(name:*):Boolean { return this.obj.hasOwnProperty(name); }

	flash_proxy override function getProperty(name:*):* { return this.obj[name]; }

	flash_proxy override function setProperty(name:*, value:*):void { this.obj[name] = value; }

	flash_proxy override function deleteProperty(name:*):Boolean
	{
	  if (this.obj.hasOwnProperty(name))
	  {
		delete this.obj[name];
		return true;
	  }
	  return false;
	}
  }
}