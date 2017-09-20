package r1.deval.rt
{
   public class ForInCond extends ObjectExprBase
   {
       
      
      private var _fip:ForInPrologue;
      
      public function ForInCond(param1:ForInPrologue)
      {
         super();
         this._fip = param1;
      }
      
      override public function getBoolean() : Boolean
      {
         var _loc1_:Array = Env.getProperty(_fip._temp_arr_name) as Array;
         var _loc2_:int = Env.getProperty(_fip._temp_idx_name) as int;
         if(_loc2_ >= _loc1_.length)
         {
            return false;
         }
         Env.setProperty(_fip._iterVar,_loc1_[_loc2_]);
         Env.setProperty(_fip._temp_idx_name,_loc2_ + 1);
         return true;
      }
   }
}
