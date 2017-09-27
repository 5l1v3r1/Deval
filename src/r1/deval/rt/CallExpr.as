package r1.deval.rt
{
   public class CallExpr extends ObjectExprBase
   {
       
      
      private var newOp:Boolean;
      
      private var expr:IExpr;
      
      private var params:Array;
      
      public function CallExpr(param1:Boolean, param2:IExpr)
      {
         params = [];
         super();
         this.expr = param2;
         this.newOp = param1;
      }
      
      private static function newInstance(param1:*, param2:Array) : Object
      {
         switch(param2.length)
         {
            case 0:
               return new param1();
            case 1:
               return new param1(param2[0]);
            case 2:
               return new param1(param2[0],param2[1]);
            case 3:
               return new param1(param2[0],param2[1],param2[2]);
            case 4:
               return new param1(param2[0],param2[1],param2[2],param2[3]);
            case 5:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4]);
            case 6:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5]);
            case 7:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6]);
            case 8:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7]);
            case 9:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8]);
            case 10:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9]);
            case 11:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10]);
            case 12:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11]);
            case 13:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12]);
            case 14:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13]);
            case 15:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14]);
            case 16:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14],param2[15]);
            case 17:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14],param2[15],param2[16]);
            case 18:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14],param2[15],param2[16],param2[17]);
            case 19:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14],param2[15],param2[16],param2[17],param2[18]);
            case 20:
               return new param1(param2[0],param2[1],param2[2],param2[3],param2[4],param2[5],param2[6],param2[7],param2[8],param2[9],param2[10],param2[11],param2[12],param2[13],param2[14],param2[15],param2[16],param2[17],param2[18],param2[19]);
            default:
               throw new Error("Number of parameters exceeds limit of 20.");
         }
      }
      
      public function addParam(param1:IExpr) : void
      {
         params.push(param1);
      }
      
      override public function getAny() : Object
      {
         var _loc1_:* = undefined;
         var _loc2_:* = undefined;
         var _loc4_:Accessor = null;
         var _loc5_:Array = null;
         var _loc3_:Array = [];
         for each(_loc2_ in params)
         {
            if(_loc2_ is IExpr)
            {
               _loc2_ = (_loc2_ as IExpr).getAny();
            }
            _loc3_.push(_loc2_);
         }
         if(newOp)
         {
            _loc1_ = expr.getAny();
            if (_loc1_ is ClassProxy) {
               return _loc1_.getInstance(_loc3_);
            }
            if(!_loc1_)
            {
               throw new RTError("msg.rt.no.class");
            }
            if(!(_loc1_ is Class)&&!(_loc1_ is Function))
            {
               throw new RTError("msg.rt.not.callable");
            }
            return newInstance(_loc1_,_loc3_);
         }
         if(expr is Accessor)
         {
            _loc4_ = expr as Accessor;
            _loc5_ = [null,null,false];
            _loc4_.resolveMethod(_loc5_);
            _loc2_ = _loc5_[0];
            _loc1_ = _loc5_[1];
            if(_loc5_[2])
            {
               _loc3_.unshift(_loc2_);
               _loc2_ = null;
            }
         }
         else
         {
            _loc2_ = null;
            _loc1_ = expr.getAny();
         }
         if(_loc1_ != null)
         {
            if(_loc1_ is Function)
            {
               return (_loc1_ as Function).apply(_loc2_==null?Env.peekObject():_loc2_,_loc3_);
            }
            if(_loc1_ is Class)
            {
               if(_loc3_.length <= 0)
               {
                  return null;
               }
               return _loc3_[0] as (_loc1_ as Class);
            }
         }
         throw new RTError("msg.rt.no.function");
      }
   }
}
