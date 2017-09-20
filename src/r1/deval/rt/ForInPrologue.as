package r1.deval.rt
{
	import r1.deval.parser.TokenStream;

   public class ForInPrologue extends EmptyStmt
   {
       
      
      var _forEach:Boolean;
      
      var _iterVar:String;
      
      var _temp_arr_name:String;
      
      var _temp_idx_name:String;
      
      var _collection:IExpr;
      
      public function ForInPrologue(param1:int, param2:String, param3:IExpr, param4:Boolean, param5:int, param6:TokenStream)
      {
         super(param5,param6);
         this._iterVar = param2;
         this._collection = param3;
         this._forEach = param4;
         this._temp_arr_name = "_tmp_arr_" + param1;
         this._temp_idx_name = "_tmp_idx_" + param1;
      }
      
      override public function exec() : void
      {
         var _loc2_:Array = null;
         var _loc3_:* = undefined;
         var _loc1_:Object = _collection.getAny();
         if(_forEach)
         {
            if(_loc1_ is Array)
            {
               _loc2_ = _loc1_ as Array;
            }
            else
            {
               _loc2_ = [];
               for each(_loc3_ in _loc1_)
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         else
         {
            _loc2_ = [];
            for(_loc3_ in _loc1_)
            {
               _loc2_.push(_loc3_);
            }
         }
         Env.setProperty(_temp_arr_name,_loc2_);
         Env.setProperty(_temp_idx_name,0);
      }
   }
}
