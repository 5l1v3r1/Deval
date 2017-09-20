package r1.deval.rt
{
   class XMLAccessor extends Accessor
   {
       
      
      var ns:IExpr;
      
      var flags:int;
      
      var dotQuery:Boolean;
      
      function XMLAccessor(param1:IExpr, param2:*, param3:IExpr, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false)
      {
         super(param1,param2);
         this.dotQuery = param4;
         this.ns = param3;
         this.flags = 0;
         if(param5)
         {
            flags = flags | 2;
         }
         if(param6)
         {
            flags = flags | 1;
         }
      }
      
      override public function setValue(param1:Object) : void
      {
         var _loc2_:Object = getIndex();
         if(ns != null)
         {
            _loc2_ = new QName(ns.getAny(),_loc2_);
         }
         var _loc3_:Object = host.getAny();
         switch(flags)
         {
            case 0:
               _loc3_[_loc2_] = param1;
               break;
            case 2:
               _loc3_[_loc2_] = param1;
               break;
            default:
               throw new RTError("msg.unknown.xml.operator");
         }
      }
      
      override public function getAny() : Object
      {
         var _loc1_:Object = null;
         if(dotQuery)
         {
            return doDotQuery();
         }
         var _loc2_:Object = getIndex();
         if(ns != null)
         {
            _loc2_ = new QName(ns.getAny(),_loc2_);
         }
         if(host == null)
         {
            _loc1_ = Env.peekObject();
            switch(flags)
            {
               case 0:
                  return _loc1_[_loc2_];
               case 1:
                  return _loc1_.descendants(_loc2_);
               case 2:
                  return _loc1_[_loc2_];
               case 3:
                  return _loc1_[_loc2_];
            }
         }
         else
         {
            _loc1_ = host.getAny();
            switch(flags)
            {
               case 0:
                  return _loc1_[_loc2_];
               case 1:
                  return _loc1_.descendants(_loc2_);
               case 2:
                  return _loc1_[_loc2_];
               case 3:
                  return _loc1_[_loc2_];
            }
         }
         throw new RTError("msg.unknown.xml.operator");
      }
      
      private function doDotQuery() : Object
      {
         var _loc2_:XML = null;
         var _loc3_:* = undefined;
         var _loc1_:Object = host.getAny();
         if(_loc1_ is XML)
         {
            Env.pushObject(_loc1_);
            if(!getIndexAsBoolean())
            {
               return new XMLList("");
            }
            Env.popObject();
         }
         else
         {
            _loc2_ = <root/>;
            for each(_loc3_ in _loc1_ as XMLList)
            {
               Env.pushObject(_loc3_);
               if(getIndexAsBoolean())
               {
                  _loc2_.appendChild(_loc3_);
               }
               Env.popObject();
            }
            _loc1_ = _loc2_.children();
         }
         return _loc1_;
      }
   }
}
