package r1.deval.rt
{
  import flash.events.Event;

  public class RTErrorEvent extends Event
  {
	public static const TYPE:String = "RT_ERROR_EVENT";

	public var error:Error;

	public function RTErrorEvent(e:Error):void
	{
	  super(TYPE);
	  error = e;
	}
  }
}