package r1.deval.rt
{
   import r1.deval.parser.BaseParser;
   import r1.deval.parser.TokenStream;
   import flash.utils.getQualifiedClassName;
   
   public class Block
   {
      
      private static var blockCount:int = 0;
       
      
      private var _trueNext:Block;
      
      private var _cond:IExpr;
      
      private var _falseReferencers:Array = null;
      
      public var name:String;
      
      private var _trueReferencers:Array = null;
      
      private var _optimized:Boolean = false;
      
      public var stmts:Array;
      
      private var _cond_lineno:int;
      
      private var _falseNext:Block;
      
      private var _lastIsExit:Boolean = false;
      
      private var isTryBlock:Boolean=false;

      private var catchBlock:Block=null;

      private var catchVar:String;

      private var isLocalCatchVar:Boolean;

      private var finallyBlock:Block=null;

      public function Block(param1:String = null, param2:Boolean = true)
      {
         super();
         if(BaseParser.debugDump || !param2)
         {
            if(param2)
            {
               if(param1 == null)
               {
                  param1 = "";
               }
               this.name = param1 + "/" + ++blockCount;
            }
            else
            {
               this.name = param1;
            }
         }
         _optimized = !param2;
      }
      
      public function isSimple() : Boolean
      {
         return (_cond == null)&&!isTryBlock;
      }
      
      public function setTryBlock():void {
         isTryBlock=true;
      }
      public function setCatchBlock(err:String,bl:Block,isvar:Boolean):void {
         catchBlock=bl;
         catchVar=err;
         isLocalCatchVar=isvar;
      }
      public function setFinallyBlock(bl:Block):void {
         finallyBlock=bl;
      }
      public function info(param1:int = 0) : String
      {
         var _loc6_:IStmt = null;
         var _loc2_:* = "";
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            _loc2_ = _loc2_ + "  ";
            _loc3_++;
         }
         var _loc4_:String = "\n" + _loc2_;
         if(this is EndBlock)
         {
            if(this == EndBlock.EXIT)
            {
               return _loc2_ + "<EXIT name=\"" + name + "\" />";
            }
            return null;
         }
         if(isConditional())
         {
            return _loc2_ + condInfo(true);
         }
         var _loc5_:* = _loc2_ + "<Block name=\"" + name + "\" optimized=\"" + _optimized + "\">";
         for each(_loc6_ in stmts)
         {
            _loc5_ = _loc5_ + (_loc4_ + "  <stmt");
            if(_loc6_.lineno > 0)
            {
               _loc5_ = _loc5_ + (" line=\"" + _loc6_.lineno + "\"");
            }
            _loc5_ = _loc5_ + (">" + String(_loc6_) + "</stmt>");
         }
         return _loc5_ + _loc4_ + "  " + condInfo() + _loc4_ + "</Block>";
      }
      
      public function addStmt(param1:Object, param2:int, param3:TokenStream) : void
      {
         if(stmts == null)
         {
            stmts = [];
         }
         if(!(param1 is IStmt))
         {
            if(param1 is IExpr)
            {
               param1 = new ExprStmt(param1 as IExpr,param2,param3);
            }
         }
         stmts.push(param1);
      }
      
      public function isEmpty() : Boolean
      {
         return isSimple() && (stmts == null || stmts.length == 0) && !(this is EndBlock);
      }
      
      private function addReferencer(param1:Block, param2:Boolean = true) : void
      {
         if(param2)
         {
            if(_trueReferencers == null)
            {
               _trueReferencers = [];
            }
            _trueReferencers.push(param1);
         }
         else
         {
            if(_falseReferencers == null)
            {
               _falseReferencers = [];
            }
            _falseReferencers.push(param1);
         }
      }
      
      public function set trueNext(param1:Block) : void
      {
         if(_trueNext != null)
         {
            _trueNext.removeReferencer(this);
         }
         _trueNext = param1;
         if(param1 != null)
         {
            param1.addReferencer(this);
         }
      }
      
      public function isConditional() : Boolean
      {
         return (stmts == null || stmts.length == 0) && _cond != null;
      }
      
      public function getCond() : IExpr
      {
         return _cond;
      }
      
      public function run(param1:Block = null) : void
      {
         if(param1 == null)
         {
            param1 = EndBlock.EXIT;
         }
         var _loc2_:Block = this;
         var _loc3_:Number = 0;
         while(_loc2_ != null && _loc2_ != param1)
         {
            _loc2_=_loc2_.exec();
            if(_loc3_ > Env.INFINITE_LOOP_LIMIT)
            {
               throw new RTError("msg.rt.infinite.loop");
            }
            _loc3_++;
         }
      }
      
      public function get lastIsExit() : Boolean
      {
         return _lastIsExit || _trueNext is EndBlock;
      }
      
      public function exec() : Block
      {
         var s:IStmt = null;
         if(stmts != null)
         {
            for each(s in stmts)
            {
               try
               {
                  s.exec();
               }
               catch(e:Error)
               {
                  if(e is RTError)
                  {
                     (e as RTError).pushline(s.line,s.lineno);
                  }
                  if (isTryBlock) {
                     var l:Object;
                     if (catchBlock!=null) {
                        if (isLocalCatchVar) {
                           Env.setNewProperty(catchVar,e);
                        }
                        else {
                           Env.setProperty(catchVar,e);
                        }
                        catchBlock.run();
                        l=Env.getReturnValue();
                     }
                     if (finallyBlock!=null) finallyBlock.run();
                     if (l!==undefined) Env.setReturnValue(l);
                     break;
                  }
                  throw e;
               }
            }
         }
         if(_cond == null || _cond.getBoolean())
         {
            return _trueNext;
         }
         return _falseNext;
      }
      
      public function get trueNext() : Block
      {
         return _trueNext;
      }
      
      public function setCond(param1:IExpr, param2:int = -1) : void
      {
         _cond = param1;
         if(param2 >= 0)
         {
            _cond_lineno = param2;
         }
      }
      
      public function set falseNext(param1:Block) : void
      {
         if(_falseNext != null)
         {
            _falseNext.removeReferencer(this,false);
         }
         _falseNext = param1;
         if(param1 != null)
         {
            param1.addReferencer(this,false);
         }
      }
      
      public function condInfo(param1:Boolean = false) : String
      {
         if(trueNext is EndBlock)
         {
            return "<return/>";
         }
         var _loc2_:String = _cond == null?"<goto ":"<test ";
         if(param1 && name != null)
         {
            _loc2_ = _loc2_ + ("name=\"" + name + "\" ");
         }
         if(_cond != null)
         {
            _loc2_ = _loc2_ + ("expr=\"" + String(_cond) + "\" ");
         }
         if(_cond_lineno > 0)
         {
            _loc2_ = _loc2_ + ("line=\"" + _cond_lineno + "\" ");
         }
         if(_trueNext != null)
         {
            _loc2_ = _loc2_ + ("trueNext=\"" + _trueNext.name + "\" ");
         }
         if(_falseNext != null && _cond != null)
         {
            _loc2_ = _loc2_ + ("falseNext=\"" + _falseNext.name + "\" ");
         }
         return _loc2_ + "/>";
      }
      
      private function removeReferencer(param1:Block, param2:Boolean = true) : void
      {
         if(param2)
         {
            if(_trueReferencers != null)
            {
               _trueReferencers.splice(_trueReferencers.indexOf(this));
            }
         }
         else if(_falseReferencers != null)
         {
            _falseReferencers.splice(_falseReferencers.indexOf(this));
         }
      }
      
      public function dump(param1:Object, param2:int = 0) : void
      {
         if(param1[name] != null)
         {
            return;
         }
         param1[name] = true;
         var _loc3_:String = info(param2);
         if(_loc3_ != null)
         {
            trace("\n" + _loc3_);
         }
         if(trueNext != null)
         {
            trueNext.dump(param1,param2);
         }
         if(falseNext != null)
         {
            falseNext.dump(param1,param2);
         }
      }
      
      public function optimize() : void
      {
         return;
         var _loc1_:Block = null;
         var _loc2_:Object = null;
         var _loc3_:Block = null;
         if(_optimized)
         {
            return;
         }
         _optimized = true;
         if(_trueNext != null && !(_trueNext is EndBlock))
         {
            _trueNext.optimize();
            if(_trueNext.isEmpty())
            {
               trueNext = _trueNext.trueNext;
            }
            else if(isSimple())
            {
               _loc1_ = _trueNext as Block;
               if(_loc1_.getRefCount() == 1 && _loc1_.isSimple() )
               {
                  if(stmts == null)
                  {
                     stmts = _loc1_.stmts;
                  }
                  else
                  {
                     for each(_loc2_ in _loc1_.stmts)
                     {
                        stmts.push(_loc2_);
                     }
                  }
                  trueNext = _loc1_.trueNext;
               }
            }
         }
         if(_falseNext != null && !(_falseNext is EndBlock))
         {
            _falseNext.optimize();
            if(_falseNext.isEmpty())
            {
               falseNext = _falseNext.trueNext;
            }
         }
         if(isEmpty()&&(!(trueNext!=null&&trueNext.isTryBlock)))
         {
            for each(_loc3_ in _trueReferencers)
            {
               if(_loc3_ != null)
               {
                  _loc3_._trueNext = _trueNext;
               }
            }
            for each(_loc3_ in _falseReferencers)
            {
               if(_loc3_ != null)
               {
                  _loc3_._falseNext = _trueNext;
               }
            }
            trueNext = falseNext = null;
            _trueReferencers = _falseReferencers = null;
         }
      }
      
      public function get falseNext() : Block
      {
         return _falseNext;
      }
      
      public function getRefCount() : int
      {
         return (_trueReferencers == null?0:_trueReferencers.length) + (_falseReferencers == null?0:_falseReferencers.length);
      }
      
      public function set lastIsExit(param1:Boolean) : void
      {
         _lastIsExit = param1;
      }
   }
}
