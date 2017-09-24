package r1.deval.rt {
	import flash.events.EventDispatcher;
	public class RTErrorHandler extends EventDispatcher {
		private static var _instance:RTErrorHandler=new RTErrorHandler();
		public static function dispatch(x:Error):void {
			_instance.dispatchEvent(new RTErrorEvent(x));
		}
		public static function getInstance():RTErrorHandler {
			return _instance;
		}
	}
}