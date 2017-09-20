package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   
   public class UnaryExpr implements IExpr
   {
       
      
      var op:int;
      
      var base:IExpr;
      
      public function UnaryExpr(param1:IExpr, param2:int)
      {
         super();
         this.base = param1;
         this.op = param2;
      }
      
      private function incDec(param1:Boolean, param2:Boolean) : Number
      {
         var _loc3_:ISettable = base as ISettable;
         if(_loc3_ == null)
         {
            throw new RTError("msg.rt.incdec.on.const");
         }
         var _loc4_:Number = base.getNumber();
         _loc3_.setValue(_loc4_ + (!!param1?1:-1));
         return !!param2?Number(_loc4_):Number(_loc4_ + (!!param1?1:-1));
      }
      
      public function getNumber() : Number
      {
         switch(op)
         {
            case ParserConsts.NOT:
            case ParserConsts.DELETE:
               return Number(getBoolean());
            case ParserConsts.BITNOT:
               return ~base.getNumber();
            case ParserConsts.SUB:
               return -base.getNumber();
            case ParserConsts.INC:
            case ParserConsts.DEC:
               return incDec(op == ParserConsts.INC,false);
            case ParserConsts.POSTFIX_INC:
            case ParserConsts.POSTFIX_DEC:
               return incDec(op == ParserConsts.POSTFIX_INC,true);
            default:
               return 0;
         }
      }
      
      public function getString() : String
      {
         switch(op)
         {
            case ParserConsts.NOT:
            case ParserConsts.DELETE:
               return getBoolean().toString();
            case ParserConsts.ESCXMLATTR:
               return "\"" + base.getString() + "\"";
            case ParserConsts.ESCXMLTEXT:
               return XML(getAny()).toXMLString();
            case ParserConsts.TYPEOF:
               return typeof base.getAny();
            case ParserConsts.VOID:
               return "";
            default:
               return getNumber().toString();
         }
      }
      
      public function getAny() : Object
      {
         var _loc1_:String = null;
         switch(op)
         {
            case ParserConsts.NOT:
            case ParserConsts.DELETE:
               return getBoolean();
            case ParserConsts.TYPEOF:
            case ParserConsts.ESCXMLATTR:
               return getString();
            case ParserConsts.ESCXMLTEXT:
               _loc1_ = base.getString();
               if(Util.beginsWith(_loc1_,"<>"))
               {
                  return new XMLList(_loc1_);
               }
               return new XML(_loc1_);
            case ParserConsts.VOID:
               return null;
            default:
               return getNumber();
         }
      }
      
      public function getBoolean() : Boolean
      {
         switch(op)
         {
            case ParserConsts.NOT:
               return !base.getBoolean();
            case ParserConsts.ESCXMLATTR:
            case ParserConsts.ESCXMLTEXT:
               return false;
            case ParserConsts.DELETE:
               try
               {
                  return (base as ISettable).delProp();
               }
               catch(e:Error)
               {
               }
               return false;
            default:
               return Boolean(getNumber());
         }
      }
   }
}
