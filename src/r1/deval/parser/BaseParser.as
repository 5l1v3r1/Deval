package r1.deval.parser
{
   import r1.deval.rt.Block;
   import r1.deval.rt.EndBlock;
   import r1.deval.rt.ExprList;
   import r1.deval.rt.ForInCond;
   import r1.deval.rt.ForInPrologue;
   import r1.deval.rt.FunctionDef;
   import r1.deval.rt.IExpr;
   import r1.deval.rt.ImportStmt;
   import r1.deval.rt.UnaryStmt;
   
   public class BaseParser extends ExprParser
   {
      
      public static var debugDump:Boolean = false;
       
      
      private var functionList:Array;
      
      private var functionExitBlock:EndBlock = null;
      
      private var curBlock:Block;
      
      private var switchStack:Array;
      
      private var forCount:int = 0;
      
      private var doWhileCount:int = 0;
      
      private var whileCount:int = 0;
      
      private var forInCount:int = 0;
      
      private var anonLabelCount:int = 0;
      
      private var labelStack:Array;
      
      private var blockStack:Array;
      
      public function BaseParser()
      {
         blockStack = [];
         super();
      }
      
      private static function dumpProgram(param1:String, param2:Block, param3:Array) : void
      {
         var _loc5_:FunctionDef = null;
         var _loc4_:Object = {};
         for each(_loc5_ in param3)
         {
            _loc5_.dump(_loc4_);
         }
         param2.dump(_loc4_);
      }
      
      private static function getIgnoredKeyword(param1:int) : String
      {
         switch(param1)
         {
            case CLASS:
               return "class";
            case TRY:
               return "try";
            case CATCH:
               return "catch";
            case FINALLY:
               return "finally";
            default:
               return "";
         }
      }
      
      public function addStmt(param1:*, param2:int ) : void
      {
         if(curBlock.lastIsExit)
         {
            reportError("msg.unreachable.code","K51");
         }
         curBlock.addStmt(param1,param2,ts);
      }
      
      protected function statementAsBlock(param1:String = null, param2:Boolean = false) : Array
      {
         var _loc3_:Block = new Block(param1);
         newBlock(_loc3_);
         statement(null,param2);
         var _loc4_:Array = [_loc3_,curBlock];
         popBlock();
         return _loc4_;
      }
      
      private function curSwitch() : Object
      {
         return switchStack[switchStack.length - 1];
      }
      
      protected function condition() : IExpr
      {
         mustMatchToken(LP,"msg.no.paren.cond","k51");
         var _loc1_:IExpr = expression();
         mustMatchToken(RP,"msg.no.paren.after.cond","k52");
         return _loc1_;
      }
      
      protected function enterLoop(param1:Label, param2:Block, param3:Block, param4:String = null) : Label
      {
         if(param1 == null)
         {
            param1 = createLabel(param4);
         }
         param1.block = param2;
         param1.postfix = param3 == null?param2:param3;
         pushLabel(param1);
         return param1;
      }
      
      public function lastIsExit(param1:Block) : Boolean
      {
         return param1 != null && param1.lastIsExit;
      }
      
      private function popLabel() : Label
      {
         return labelStack.pop() as Label;
      }
      
      private function forStatement(param1:int, param2:Label) : void
      {
         var _loc4_:String = null;
         var _loc5_:IExpr = null;
         var _loc3_:Boolean = false;
         if(matchToken(NAME))
         {
            if(ts.getString() == "each")
            {
               _loc3_ = true;
            }
            else
            {
               reportError("msg.no.paren.for","K55");
            }
         }
         mustMatchToken(LP,"msg.no.paren.for","k54");
         var _loc6_:int = peekToken();
         if(_loc6_ != SEMI)
         {
            if(_loc6_ == VAR)
            {
               consumeToken();
               mustMatchToken(NAME,"msg.bad.var","k55");
               _loc4_ = ts.getString();
               if(peekToken() == IN)
               {
                  consumeToken();
                  exprFactory.createVarExpr(_loc4_);
               }
               else
               {
                  variables(_loc4_);
                  _loc4_ = null;
               }
            }
            else if(peekToken() == NAME)
            {
               _loc4_ = ts.getString();
               consumeToken();
               if(peekToken() == IN)
               {
                  consumeToken();
               }
               else
               {
                  pushbackLookahead();
                  _loc4_ = null;
                  statement(null,true);
               }
            }
            else
            {
               statement(null,true);
            }
         }
         var _loc7_:Block = null;
         if(_loc4_)
         {
            _loc5_ = expression();
         }
         else
         {
            mustMatchToken(SEMI,"msg.no.semi.for","k56");
            _loc5_ = peekToken() == SEMI?null:expression();
            mustMatchToken(SEMI,"msg.no.semi.for.cond","k57");
            if(peekToken() != RP)
            {
               _loc7_ = statementAsBlock(null,true)[0] as Block;
            }
         }
         mustMatchToken(RP,"msg.no.paren.for.ctrl","k58");
         var _loc8_:String = (!!_loc3_?"@for_each_":!!_loc4_?"@for_in_":"@for_") + forCount++;
         if(_loc4_ == null)
         {
            whileStatement(param1,param2,_loc8_,_loc5_,":for-body:",_loc7_);
         }
         else
         {
            forInStatement(param1,param2,_loc8_,_loc4_,_loc5_,_loc3_,_loc7_);
         }
      }
      
      private function doWhileStatement(param1:Label) : void
      {
         var label:Label = null;
         var nextBlock:Block = null;
         var stmtLabel:Label = param1;
         var arr:Array = statementAsBlock(":do-while-body");
         var tempBlock:Block = arr[0] as Block;
         curBlock.trueNext = tempBlock;
         if(!lastIsExit((arr[1] as Block).trueNext))
         {
            (arr[1] as Block).trueNext = tempBlock;
         }
         try
         {
            label = enterLoop(stmtLabel,tempBlock,null,"@do_while_");
            tempBlock.name = label.name;
            mustMatchToken(WHILE,"msg.no.while.do","k53");
            tempBlock.setCond(condition(),ts.getLineno());
            nextBlock = new Block();
            if(!lastIsExit((arr[1] as Block).trueNext))
            {
               (arr[1] as Block).falseNext = nextBlock;
            }
            popBlock();
            newBlock(nextBlock);
            return;
         }
         finally
         {
            exitLoop();
         }
      }
      
      override protected function parseFunction(param1:Boolean = false) : FunctionDef
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(!param1)
         {
            _loc2_ = checkAndConsumeToken(NAME,"msg.missing.function.name","Kf1");
         }
         checkAndConsumeToken(LP,"msg.no.paren.parms","Kf2");
         var _loc4_:Array = [];
         loop0:
         while(true)
         {
            _loc3_ = peekToken();
            if(_loc3_ == RP)
            {
               break;
            }
            else if(_loc3_ == NAME )
            {
               _loc4_.push(ts.getString());
               consumeToken();
               loop1:
               while(true)
               {
                  switch(peekToken())
                  {
                     case COLON:
                     case DOT:
                     case NAME:
                        consumeToken();
                        continue;
                     case COMMA:
                        break loop1;
                     case RP:
                        addr56:
                        continue loop0;
                     default:
                        reportError("msg.no.paren.after.parms","Kf3");
                        continue;
                  }
               }
               consumeToken();
               continue loop0;
            }
            else if (_loc3_==DOTDOTDOT) {
               consumeToken();
               if (peekToken()!=NAME) reportError("msg.invalid.params","Kf6");
               _loc4_.push("..."+ts.getString());
               consumeToken();
               if (peekToken()!=RP) reportError("msg.invalid.params","Kf7");
            }
            else
            {
               reportError("msg.invalid.params","Kf5");
            }
         }
         consumeToken();
         loop2:
         while(true)
         {
            switch(peekToken())
            {
               case COLON:
               case DOT:
               case NAME:
                  consumeToken();
                  continue;
               case LC:
                  break loop2;
               default:
                  reportError("msg.no.brace.body","Kf4");
                  continue;
            }
         }
         consumeToken();
         var _loc5_:Block = newBlock();
         var _loc6_:EndBlock = functionExitBlock = new EndBlock("[/" + _loc2_ + "]");
         while(functionExitBlock != null)
         {
            statement();
         }
         var _loc7_:Block = popBlockTo(_loc5_);
         if(_loc7_.getRefCount() > 0)
         {
            if(_loc7_.trueNext == null)
            {
               _loc7_.trueNext = _loc6_;
            }
            if(_loc7_.falseNext == null)
            {
               _loc7_.falseNext = _loc6_;
            }
         }
         return new FunctionDef(_loc2_,_loc4_,_loc5_,_loc6_);
      }
      
      private function checkAndConsumeToken(param1:int, param2:String, param3:String) : String
      {
         if(peekToken() != param1)
         {
            reportError(param2,param3);
         }
         var _loc4_:String = ts.getString();
         consumeToken();
         return _loc4_;
      }
      
      private function get inSwitch() : Boolean
      {
         return switchStack.length > 0;
      }
      
      private function enterSwitch(param1:Label, param2:IExpr, param3:int) : void
      {
         checkAndConsumeToken(LC,"msg.no.brace.switch","Ksw5");
         var _loc4_:String = "_switch_" + switchDepth;
         addStmt(exprFactory.createVarExpr(_loc4_,param2),0);
         var _loc5_:Block = curBlock;
         _loc5_.trueNext = newBlock();
         if(param1 == null)
         {
            param1 = createLabel();
         }
         param1.isSwitch = true;
         param1.block = new Block();
         pushLabel(param1);
         var _loc6_:Object = {
            "switchVar":exprFactory.createAccessor(null,_loc4_),
            "type":0,
            "branchHead":curBlock,
            "branchCondition":_loc5_,
            "label":param1
         };
         var _loc7_:int = switchDepth;
         switchStack.push(_loc6_);
         do
         {
            statement();
         }
         while(switchDepth > _loc7_);
         
      }
      
      protected function popBlock() : Block
      {
         var _loc1_:Block = blockStack.pop() as Block;
         curBlock = blockStack[blockStack.length - 1] as Block;
         return _loc1_;
      }
      
      private function getLabel(param1:String) : Label
      {
         var _loc2_:Label = labelStack[param1] as Label;
         if(_loc2_ == null)
         {
            reportError("msg.undef.label","K53");
         }
         return _loc2_;
      }
      
      private function forInStatement(param1:int, param2:Label, param3:String, param4:String, param5:IExpr, param6:Boolean, param7:Block = null) : void
      {
         var begin_end:Array = null;
         var begin:Block = null;
         var lineno:int = param1;
         var stmtLabel:Label = param2;
         var defaultLabelName:String = param3;
         var iterVar:String = param4;
         var coll:IExpr = param5;
         var isForEach:Boolean = param6;
         var increment:Block = param7;
         var nextBlock:Block = new Block();
         var forInLoopId:int = forInCount++;
         var fip:ForInPrologue = new ForInPrologue(forInLoopId,iterVar,coll,isForEach,lineno,ts);
         addStmt(fip,lineno);
         var tempBlock:Block = new Block();
         curBlock.trueNext = tempBlock;
         tempBlock.falseNext = nextBlock;
         var label:Label = enterLoop(stmtLabel,tempBlock,increment,defaultLabelName);
         tempBlock.name = label.name;
         try
         {
            begin_end = statementAsBlock(":for-body:");
            begin = begin_end[0] as Block;
            if(increment != null)
            {
               increment.trueNext = begin.trueNext;
               begin.trueNext = increment;
            }
            tempBlock.setCond(new ForInCond(fip));
            tempBlock.trueNext = begin;
            tempBlock.falseNext = nextBlock;
            (begin_end[1] as Block).trueNext = tempBlock;
            popBlock();
            newBlock(nextBlock);
            return;
         }
         finally
         {
            exitLoop();
         }
      }
      
      private function whileStatement(param1:int, param2:Label, param3:String, param4:IExpr, param5:String = ":while_body:", param6:Block = null) : void
      {
         var begin_end:Array = null;
         var end:Block = null;
         var lineno:int = param1;
         var stmtLabel:Label = param2;
         var defaultLabelName:String = param3;
         var cond:IExpr = param4;
         var bodyName:String = param5;
         var increment:Block = param6;
         var nextBlock:Block = new Block();
         var tempBlock:Block = new Block();
         curBlock.trueNext = tempBlock;
         tempBlock.setCond(cond,lineno);
         tempBlock.falseNext = nextBlock;
         var label:Label = enterLoop(stmtLabel,tempBlock,increment,defaultLabelName);
         tempBlock.name = label.name;
         try
         {
            begin_end = statementAsBlock(bodyName);
            end = begin_end[1] as Block;
            if(increment != null && !end.lastIsExit)
            {
               increment.trueNext = end.trueNext;
               end.trueNext = increment;
               end = increment;
            }
            tempBlock.trueNext = begin_end[0] as Block;
            if(!end.lastIsExit)
            {
               end.trueNext = tempBlock;
            }
            popBlock();
            newBlock(nextBlock);
            return;
         }
         finally
         {
            exitLoop();
         }
      }
      
      private function matchJumpLabelName() : Label
      {
         if(peekTokenOrEOL() != NAME)
         {
            return null;
         }
         consumeToken();
         return getLabel(ts.getString());
      }
      
      protected function newBlock(param1:* = null) : Block
      {
         if(param1 == null)
         {
            param1 = new Block();
         }
         else if(param1 is String)
         {
            param1 = new Block(String(param1));
         }
         blockStack.push(curBlock = param1 as Block);
         return curBlock;
      }
      
      override protected function initParser(param1:String) : void
      {
         super.initParser(param1);
         labelStack = [];
         switchStack = [];
         functionList = [];
      }
      
      private function breakContinueStatement(param1:Boolean) : void
      {
         curBlock.lastIsExit = true;
         var _loc2_:Label = matchJumpLabelName();
         if(_loc2_ == null)
         {
            _loc2_ = peekLabel();
         }
         if(_loc2_.isSwitch)
         {
            if(!param1)
            {
               reportError("msg.bad.continue","Ksw");
            }
            curBlock.trueNext = _loc2_.block;
         }
         else
         {
            curBlock.trueNext = !!param1?_loc2_.block.falseNext:_loc2_.postfix;
         }
      }
      
      public function parseProgram(param1:String) : Object
      {
         var _loc3_:FunctionDef = null;
         initParser(param1);
         newBlock(":Main:");
         var _loc2_:Block = curBlock;
         while(peekToken() != EOF)
         {
            statement();
         }
         if(curBlock.trueNext == null)
         {
            curBlock.trueNext = EndBlock.EXIT;
         }
         popBlock();
         if(debugDump)
         {
            dumpProgram("===== Pre-optimization =====",_loc2_,functionList);
         }
         _loc2_.optimize();
         for each(_loc3_ in functionList)
         {
            _loc3_.optimize();
         }
         if(debugDump)
         {
            dumpProgram("\n===== Post-optimization =====",_loc2_,functionList);
         }
         if(functionList.length == 0)
         {
            return _loc2_;
         }
         return [_loc2_,functionList];
      }
      
      private function tryStatement(param1:int): void {
         var u:Array=statementAsBlock(":try-part:");
         u[0].setTryBlock();
         curBlock.trueNext=u[0] as Block;
         var v:String;
         var m:Boolean=false,ok:Boolean=false;
         if (matchToken(CATCH)) {
            ok=true;
            consumeToken();
            if (peekToken()==VAR) {
               m=true;
               consumeToken();
            }
            checkAndConsumeToken(LP,"msg.no.paren.in.catch","K02");
            v=checkAndConsumeToken(NAME,"msg.no.name.in.catch","K03");
            while(true) {
               switch(peekToken()) {
                  case DOT:
                  case COLON:
                  case NAME:
                     consumeToken();
                     continue;
                  case RP:
                     consumeToken();
                     break;
                  default:
                     reportError("msg.no.paren.in.catch","K04");
               }
               break;
            }
            var p:Array=statementAsBlock(":catch-part:");
            u[0].setCatchBlock(v,p[0],m);
         }
         if (matchToken(FINALLY)) {
            ok=true;
            consumeToken();
            var l:Array=statementAsBlock(":finally-part:");
            u[0].setFinallyBlock(l[0]);
         }
         if (!ok) {
            reportError("msg.no.finally.statement","K05");
         }
         var ij:Block=new Block();
         u[1].trueNext=ij;
         popBlock();
         newBlock(ij);
      }
      private function ifStatement(param1:int, param2:IExpr) : void
      {
         curBlock.setCond(param2,param1);
         var _loc3_:Block = new Block();
         var _loc4_:Array = statementAsBlock(":if-part:");
         curBlock.trueNext = _loc4_[0] as Block;
         var _loc5_:Block = _loc4_[1] as Block;
         if(!_loc5_.lastIsExit)
         {
            _loc5_.trueNext = _loc3_;
         }
         if(matchToken(ELSE))
         {
            consumeToken();
            _loc4_ = statementAsBlock(":else-part:");
            curBlock.falseNext = _loc4_[0] as Block;
            _loc5_ = _loc4_[1] as Block;
            if(!_loc5_.lastIsExit)
            {
               _loc5_.trueNext = _loc3_;
            }
         }
         else
         {
            curBlock.falseNext = _loc3_;
         }
         popBlock();
         newBlock(_loc3_);
      }
      
      private function switchEvent(param1:int, param2:IExpr = null) : void
      {
         var _loc9_:Label = null;
         var _loc3_:int = ts.getLineno();
         var _loc4_:Object = curSwitch();
         var _loc5_:Block = _loc4_.branchCondition as Block;
         var _loc6_:Block = _loc4_.branchHead as Block;
         var _loc7_:int = _loc4_.type as int;
         _loc4_.type = param1;
         if(param2 != null)
         {
            param2 = exprFactory.createEqRelExpr(_loc4_.switchVar as IExpr,param2,EQ);
         }
         if(_loc7_ == 0)
         {
            if(!_loc6_.isEmpty())
            {
               reportError("msg.unreachable.stmts.in.switch","Ksw6");
            }
            if(param1 == CASE)
            {
               _loc5_.setCond(param2,_loc3_);
            }
            else
            {
               _loc4_.defaultBlockHead = _loc6_;
            }
            return;
         }
         var _loc8_:Block = popBlockTo(_loc6_);
         if(_loc7_ == DEFAULT)
         {
            _loc4_.defaultBlockTail = _loc8_;
         }
         if(param1 == RC)
         {
            _loc9_ = popLabel();
            if(!_loc8_.lastIsExit)
            {
               _loc8_.trueNext = _loc9_.block;
            }
            _loc6_ = _loc4_.defaultBlockHead as Block;
            if(_loc6_ != null)
            {
               _loc8_ = _loc4_.defaultBlockTail as Block;
               _loc5_.falseNext = _loc6_;
            }
            switchStack.pop();
            newBlock(_loc9_.block);
            return;
         }
         _loc4_.branchHead = newBlock();
         if(!_loc8_.lastIsExit)
         {
            _loc8_.trueNext = curBlock;
         }
         if(param1 == DEFAULT)
         {
            _loc4_.defaultBlockHead = curBlock;
         }
         else if(param1 == CASE)
         {
            if(_loc5_.getCond() != null)
            {
               _loc5_.falseNext = new Block();
               _loc5_ = _loc5_.falseNext;
               _loc5_.falseNext = peekLabel().block;
               _loc4_.branchCondition = _loc5_;
            }
            _loc5_.setCond(param2,_loc3_);
            _loc5_.trueNext = curBlock;
         }
      }
      
      protected function popBlockTo(param1:Block) : Block
      {
         var _loc2_:Block = popBlock();
         var _loc3_:int = blockStack.indexOf(param1);
         if(_loc3_ >= 0)
         {
            blockStack.length = _loc3_;
         }
         curBlock = blockStack[blockStack.length - 1] as Block;
         return _loc2_;
      }
      
      private function createLabel(param1:String = null) : Label
      {
         if(param1 == null)
         {
            param1 = "@_";
         }
         return new Label(param1 + anonLabelCount++);
      }
      
      private function peekLabel() : Label
      {
         if(labelStack.length == 0)
         {
            reportError("msg.bad.break.continue","K56");
         }
         return labelStack[labelStack.length - 1] as Label;
      }
      
      protected function exitLoop() : void
      {
         popLabel();
      }
      
      private function statements() : void
      {
         var _loc1_:int = 0;
         while((_loc1_ = peekToken()) != EOF && _loc1_ != RC)
         {
            statement();
         }
      }
      
      private function get switchDepth() : int
      {
         return switchStack.length;
      }
      
      private function defaultNamespaceStatement(param1:int) : void
      {
         if(!(matchToken(NAME) && ts.getString() == "xml"))
         {
            reportError("msg.bad.namespace","K57");
         }
         if(!(matchToken(NAME) && ts.getString() == "namespace"))
         {
            reportError("msg.bad.namespace","K58");
         }
         if(!matchToken(ASSIGN))
         {
            reportError("msg.bad.namespace","K59");
         }
         addStmt(new UnaryStmt(DEFAULT_NS,expression(),param1,ts),param1);
      }
      
      private function statement(param1:Label = null, param2:Boolean = false) : void
      {
         var _loc3_:Block = null;
         var _loc4_:IExpr = null;
         var _loc5_:Label = null;
         var _loc6_:Array = null;
         var _loc9_:String = null;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc7_:int = ts.getLineno();
         var _loc8_:int = peekToken();
         switch(_loc8_)
         {
            case IF:
               consumeToken();
               ifStatement(_loc7_,condition());
               return;
            case SWITCH:
               consumeToken();
               enterSwitch(param1,condition(),_loc7_);
               break;
            case CASE:
               consumeToken();
               if(!inSwitch)
               {
                  reportError("msg.misplaced.case","Ksw1");
               }
               _loc4_ = expression();
               checkAndConsumeToken(COLON,"msg.case.no.colon","Ksw2");
               switchEvent(CASE,_loc4_);
               return;
            case DEFAULT:
               consumeToken();
               if(peekToken() == COLON)
               {
                  checkAndConsumeToken(COLON,"msg.case.no.colon","Ksw3");
                  switchEvent(DEFAULT);
                  return;
               }
               defaultNamespaceStatement(_loc7_);
               break;
            case RC:
               if(!inSwitch && functionExitBlock == null)
               {
                  reportError("msg.misplaced.right.brace","Krc");
               }
               consumeToken();
               if(inSwitch)
               {
                  switchEvent(RC);
               }
               else
               {
                  functionExitBlock = null;
               }
               return;
            case BREAK:
            case CONTINUE:
               consumeToken();
               breakContinueStatement(_loc8_ == BREAK);
               break;
            case THROW:
               consumeToken();
               curBlock.lastIsExit = true;
               addStmt(new UnaryStmt(THROW,expression(),_loc7_,ts),_loc7_);
               break;
            case WHILE:
               consumeToken();
               _loc4_ = condition();
               whileStatement(_loc7_,param1,"@while_" + whileCount++,_loc4_);
               return;
            case DO:
               consumeToken();
               doWhileStatement(param1);
               return;
            case FOR:
               consumeToken();
               forStatement(ts.getLineno(),param1);
               return;
            case VAR:
               consumeToken();
               variables();
               break;
            case RETURN:
               consumeToken();
               switch(peekTokenOrEOL())
               {
                  case SEMI:
                     consumeToken();
                  case RC:
                  case EOF:
                  case EOL:
                  case ERROR:
                     break;
                  default:
                     addStmt(expression(),_loc7_);
               }
               curBlock.trueNext = functionExitBlock != null?functionExitBlock:EndBlock.EXIT;
               curBlock.lastIsExit = true;
               break;
            case LC:
               consumeToken();
               statements();
               mustMatchToken(RC,"msg.no.brace.block","k65");
               return;
            case ERROR:
            case SEMI:
               consumeToken();
               break;
            case IMPORT:
               consumeToken();
               readImports(_loc7_);
               break;
            case NAME:
               _loc9_ = ts.getString();
               setCheckForLabel();
               _loc4_ = expression();
               if(_loc4_ is Label)
               {
                  if(param1 == null)
                  {
                     _loc10_ = true;
                     param1 = _loc4_ as Label;
                  }
                  else
                  {
                     _loc10_ = false;
                  }
                  statement(param1);
                  break;
               }
               addStmt(_loc4_,_loc7_);
               break;
            case FUNCTION:
               consumeToken();
               functionList.push(parseFunction());
               break;
            case CLASS:
               reportError("msg.class.not.supported","K64");
               break;
            case TRY:
               consumeToken();
               tryStatement(_loc7_);
               return;
            case CATCH:
            case FINALLY:
               reportError("msg.no.try.statement","K01");
               break;
            default:
               addStmt(expression(),ts.getLineno());
         }
         if(!param2)
         {
            _loc11_ = peekFlaggedToken();
            switch(_loc11_ & CLEAR_TI_MASK)
            {
               case SEMI:
                  consumeToken();
               case ERROR:
               case EOF:
               case RC:
                  break;
               default:
                  if((_loc11_ & TI_AFTER_EOL) == 0)
                  {
                     reportError("msg.no.semi.stmt","K65");
                  }
            }
         }
      }
      
      private function readImports(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int;
         var _loc2_:Array = [];
         loop0:
         while(true)
         {
            _loc4_ = peekFlaggedToken();
            switch(_loc4_ & CLEAR_TI_MASK)
            {
               case NAME:
                  if(!_loc3_)
                  {
                     _loc3_ = ts.getString();
                  }
                  else
                  {
                     _loc3_ = _loc3_ + ("." + ts.getString());
                  }
                  consumeToken();
                  continue;
               case DOT:
                  consumeToken();
                  continue;
               case COMMA:
                  _loc2_.push(_loc3_);
                  _loc3_ = null;
                  consumeToken();
                  continue;
               case MUL:
                  if (!_loc3_) reportError("msg.invalid.import.stmt","K00");
                  _loc3_+=".*";
                  consumeToken();
                  _loc5_=peekFlaggedToken();
                  _loc5_=_loc5_&CLEAR_TI_MASK;
                  if (_loc5_!=SEMI&&_loc5_!=COMMA&&_loc5_!=ERROR&&_loc5_!=EOF&&_loc5_!=RC) reportError("msg.invalid.import.stmt","K00");
                  continue;
               case SEMI:
                  consumeToken();
               case ERROR:
               case EOF:
               case RC:
                  addr113:
                  _loc2_.push(_loc3_);
                  addStmt(new ImportStmt(_loc2_,param1,ts),param1);
                  return;
               default:
                  break loop0;
            }
         }
         if((_loc4_ & TI_AFTER_EOL) == 0)
         {
            reportError("msg.no.semi.stmt","K66");
         }
         _loc2_.push(_loc3_);
         addStmt(new ImportStmt(_loc2_,param1,ts),param1);
         return;
      }
      
      private function pushLabel(param1:Label) : void
      {
         if(labelStack[param1.name] != null)
         {
            reportError("msg.dup.label","K61");
         }
         labelStack.push(param1);
         labelStack[param1.name] = param1;
      }
      
      private function variables(param1:String = null) : void
      {
         var _loc2_:IExpr = null;
         var _loc4_:* = undefined;
         var _loc5_:* = undefined;
         var _loc3_:int = ts.getLineno();
         do
         {
            if(param1 != null)
            {
               _loc4_ = param1;
            }
            else
            {
               mustMatchToken(NAME,"msg.bad.var","k66");
               _loc4_ = ts.getString();
            }
            if(peekToken() == COLON)
            {
               consumeToken();
               mustMatchToken(NAME,"msg.bad.var","k67");
               consumeToken();
            }
            _loc5_ = null;
            if(matchToken(ASSIGN))
            {
               _loc5_ = assignExpr();
            }
            _loc2_ = exprFactory.createVarExpr(_loc4_,_loc5_,_loc2_);
         }
         while(matchToken(COMMA));
         
         if(_loc2_ is ExprList)
         {
            _loc2_ = (_loc2_ as ExprList).reduce();
         }
         addStmt(_loc2_,_loc3_);
      }
   }
}
