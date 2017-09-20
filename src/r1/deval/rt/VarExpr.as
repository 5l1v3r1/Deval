package r1.deval.rt
{
   class VarExpr extends ObjectExprBase
   {
       
      
      var init:IExpr;
      
      var name:String;
      
      function VarExpr(param1:String, param2:IExpr = null)
      {
         super();
         this.name = param1;
         this.init = param2;
      }
      
      override public function getAny() : Object
      {
         var _loc1_:Object = init == null?null:init.getAny();
         Env.setProperty(name,_loc1_);
         return _loc1_;
      }
   }
}
