package r1.deval.rt
{
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;

  public class TempObjectProxy extends Proxy
  {
	private var obj:Object=null, tempObj:Object=null;

	public function TempObjectProxy(item:Object=null)
	{
	  super();
	  this.obj = (item == null ? new Object() : item);
	  this.tempObj = new Object();
	  return;
	}

	public function clearTempProperties():void
	{
	  this.tempObj = new Object();
	  return;
	}

	flash_proxy override function hasProperty(name:*):Boolean
	{
	  if (this.obj[name] != undefined) return true;
	  if (this.tempObj != null && this.tempObj[name] != undefined) return true;
	  return false;
	}

	flash_proxy override function getProperty(name:*):*
	{
	  if (this.obj[name] != undefined) return this.obj[name];
	  if (this.tempObj != null && this.tempObj[name] != undefined) return this.tempObj[name];
	  return undefined;
	}

	flash_proxy override function setProperty(name:*, value:*):void
	{
	  if (this.obj[name] != undefined) this.obj[name] = value;
	  else this.tempObj[name] = value;
	  return;
	}

	flash_proxy override function callProperty(name:*, ...args):* { this.obj[name].apply(this.obj, args); }
  }
}