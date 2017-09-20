package r1.deval.parser
{
   import r1.deval.rt.CallExpr;
   import r1.deval.rt.Constant;
   import r1.deval.rt.Env;
   import r1.deval.rt.ExprFactory;
   import r1.deval.rt.FunctionDef;
   import r1.deval.rt.IExpr;
   import r1.deval.rt.ISettable;
   
   public class ExprParser extends ParserConsts
   {
      
      protected static const TI_CHECK_LABEL:int = 1 << 17;
      
      protected static const CLEAR_TI_MASK:int = 65535;
      
      protected static const TI_AFTER_EOL:int = 1 << 16;
       
      
      private var next_currentFlaggedToken:int;
      
      protected var exprFactory:ExprFactory;
      
      protected var currentFlaggedToken:int;
      
      private var lookaheadName:Boolean;
      
      protected var ts:TokenStream;
      
      public function ExprParser()
      {
         super();
         this.exprFactory = new ExprFactory();
      }
      
      protected function propertyName(param1:IExpr, param2:String, param3:Boolean = false, param4:Boolean = false) : IExpr
      {
         var _loc6_:int = 0;
         var _loc5_:IExpr = null;
         if(matchToken(COLONCOLON))
         {
            _loc5_ = exprFactory.createAccessor(null,param2);
            _loc6_ = nextToken();
            switch(_loc6_)
            {
               case NAME:
                  param2 = ts.getString();
                  break;
               case MUL:
                  param2 = "*";
                  break;
               case LB:
                  param1 = exprFactory.createAccessor(param1,expression(),_loc5_,param3,param4);
                  mustMatchToken(RB,"msg.no.bracket.index","k07");
                  return param1;
               default:
                  reportError("msg.no.name.after.coloncolon","K08");
                  param2 = "?";
            }
         }
         return exprFactory.createAccessor(param1,param2,_loc5_,param3,param4);
      }
      
      protected function pushbackLookahead() : void
      {
         lookaheadName = true;
         next_currentFlaggedToken = currentFlaggedToken;
         currentFlaggedToken = NAME;
      }
      
      private function argumentList(param1:CallExpr) : void
      {
         if(matchToken(RP))
         {
            return;
         }
         do
         {
            param1.addParam(assignExpr());
         }
         while(matchToken(COMMA));
         
         mustMatchToken(RP,"msg.no.paren.arg","k04");
      }
      
      protected function assignExpr() : IExpr
      {
         var _loc1_:IExpr = condExpr();
         var _loc2_:int = peekToken();
         if(FIRST_ASSIGN <= _loc2_ && _loc2_ <= LAST_ASSIGN)
         {
            consumeToken();
            checkAssignable(_loc1_);
            _loc1_ = exprFactory.createAssignment(_loc1_ as ISettable,assignExpr(),_loc2_,ts.getLineno(),ts);
         }
         return _loc1_;
      }
      
      protected function nextToken() : int
      {
         var _loc1_:int = peekToken();
         consumeToken();
         return _loc1_;
      }
      
      public function codeBug(param1:String) : void
      {
         throw new ParseError(null,param1,ts.getLineno());
      }
      
      public function parseExpr(param1:String) : IExpr
      {
         initParser(param1);
         return expression();
      }
      
      private function xmlInitializer() : IExpr
      {
         var _loc3_:IExpr = null;
         var _loc4_:IExpr = null;
         var _loc1_:IExpr = null;
         var _loc2_:int = ts.getFirstXMLToken();
         loop0:
         while(true)
         {
            _loc3_ = exprFactory.literal(ts.getString());
            switch(_loc2_)
            {
               case XML:
                  mustMatchToken(LC,"msg.syntax","k02");
                  _loc1_ = exprFactory.createAddSubExpr(_loc1_,_loc3_);
                  if(peekToken() != RC)
                  {
                     _loc4_ = expression();
                     if(ts.isXMLAttribute())
                     {
                        _loc4_ = exprFactory.createXMLAttrExpr(_loc4_);
                     }
                     _loc1_ = exprFactory.createAddSubExpr(_loc1_,_loc4_);
                  }
                  mustMatchToken(RC,"msg.syntax","k03");
                  break;
               case XMLEND:
                  break loop0;
               default:
                  reportError("msg.syntax","K05");
            }
            _loc2_ = ts.getNextXMLToken();
         }
         return exprFactory.createXMLLiteralExpr(_loc1_,_loc3_);
      }
      
      private function unaryExpr() : IExpr
      {
         var _loc1_:IExpr = null;
         var _loc2_:int = peekToken();
         switch(_loc2_)
         {
            case VOID:
            case NOT:
            case BITNOT:
            case TYPEOF:
            case SUB:
            case ADD:
            case INC:
            case DEC:
            case DELETE:
               consumeToken();
               _loc1_ = unaryExpr();
               if(_loc2_ == INC || _loc2_ == DEC)
               {
                  checkAssignable(_loc1_);
               }
               return exprFactory.createUnaryExpr(_loc1_,_loc2_);
            case ERROR:
               consumeToken();
               reportError("msg.syntax","K04");
               return null;
            case LT:
               consumeToken();
               return memberExprTail(true,xmlInitializer());
            default:
               _loc1_ = memberExpr(true);
               _loc2_ = peekTokenOrEOL();
               while(_loc2_ == INC || _loc2_ == DEC)
               {
                  consumeToken();
                  _loc1_ = exprFactory.createUnaryExpr(_loc1_,_loc2_ == INC?int(POSTFIX_INC):int(POSTFIX_DEC));
                  _loc2_ = peekTokenOrEOL();
               }
               return _loc1_;
         }
      }
      
      protected function initParser(param1:String) : void
      {
         this.ts = new TokenStream(param1);
         this.currentFlaggedToken = EOF;
      }
      
      private function eqExpr() : IExpr
      {
         var _loc1_:IExpr = relExpr();
         var _loc2_:int = peekToken();
         loop0:
         while(true)
         {
            switch(_loc2_)
            {
               case EQ:
               case NE:
               case SHEQ:
               case SHNE:
                  consumeToken();
                  _loc1_ = exprFactory.createEqRelExpr(_loc1_,relExpr(),_loc2_);
                  _loc2_ = peekToken();
                  continue;
               default:
                  break loop0;
            }
         }
         return _loc1_;
      }
      
      protected function setCheckForLabel() : void
      {
         if((currentFlaggedToken & CLEAR_TI_MASK) != NAME)
         {
            codeBug("K01");
         }
         currentFlaggedToken = currentFlaggedToken | TI_CHECK_LABEL;
      }
      
      protected function nextFlaggedToken() : int
      {
         peekToken();
         var _loc1_:int = currentFlaggedToken;
         consumeToken();
         return _loc1_;
      }
      
      private function shiftExpr() : IExpr
      {
         var _loc1_:IExpr = addExpr();
         var _loc2_:int = peekToken();
         loop0:
         while(true)
         {
            switch(_loc2_)
            {
               case LSH:
               case URSH:
               case RSH:
                  consumeToken();
                  _loc1_ = exprFactory.createShiftExpr(_loc1_,addExpr(),_loc2_);
                  _loc2_ = peekToken();
                  continue;
               default:
                  break loop0;
            }
         }
         return _loc1_;
      }
      
      private function mulExpr() : IExpr
      {
         var _loc1_:IExpr = unaryExpr();
         var _loc2_:int = peekToken();
         loop0:
         while(true)
         {
            switch(_loc2_)
            {
               case MUL:
               case DIV:
               case MOD:
                  consumeToken();
                  _loc1_ = exprFactory.createMulDivModExpr(_loc1_,unaryExpr(),_loc2_);
                  _loc2_ = peekToken();
                  continue;
               default:
                  break loop0;
            }
         }
         return _loc1_;
      }
      
      protected function mustMatchToken(param1:int, param2:String, param3:String) : void
      {
         if(!matchToken(param1))
         {
            reportError(param2,param3);
         }
      }
      
      protected function peekToken() : int
      {
         if(lookaheadName)
         {
            return NAME;
         }
         var _loc1_:* = int(currentFlaggedToken);
         if(_loc1_ == EOF)
         {
            _loc1_ = int(ts.getToken());
            if(_loc1_ == EOL)
            {
               do
               {
                  _loc1_ = int(ts.getToken());
               }
               while(_loc1_ == EOL);
               
               _loc1_ = _loc1_ | TI_AFTER_EOL;
            }
            currentFlaggedToken = _loc1_;
         }
         return _loc1_ & CLEAR_TI_MASK;
      }
      
      private function attributeAccess(param1:IExpr = null, param2:Boolean = false) : IExpr
      {
         var _loc3_:int = nextToken();
         switch(_loc3_)
         {
            case NAME:
               return propertyName(param1,ts.getString(),true,param2);
            case MUL:
               return propertyName(param1,"*",true,param2);
            case LB:
               param1 = exprFactory.createAccessor(param1,expression(),null,true,param2);
               mustMatchToken(RB,"msg.no.bracket.index","k68");
               return param1;
            default:
               reportError("msg.no.name.after.xmlAttr","K69");
               return null;
         }
      }
      
      protected function peekTokenOrEOL() : int
      {
         var _loc1_:int = peekToken();
         if((currentFlaggedToken & TI_AFTER_EOL) != 0)
         {
            _loc1_ = EOL;
         }
         return _loc1_;
      }
      
      private function bitXorExpr() : IExpr
      {
         var _loc1_:IExpr = bitAndExpr();
         var _loc2_:int = peekToken();
         while(_loc2_ == BITXOR)
         {
            consumeToken();
            _loc1_ = exprFactory.createBitExpr(_loc1_,bitAndExpr(),BITXOR);
            _loc2_ = peekToken();
         }
         return _loc1_;
      }
      
      protected function consumeToken() : void
      {
         if(lookaheadName)
         {
            lookaheadName = false;
            currentFlaggedToken = next_currentFlaggedToken;
            return;
         }
         currentFlaggedToken = EOF;
      }
      
      private function bitOrExpr() : IExpr
      {
         var _loc1_:IExpr = bitXorExpr();
         var _loc2_:int = peekToken();
         while(_loc2_ == BITOR)
         {
            consumeToken();
            _loc1_ = exprFactory.createBitExpr(_loc1_,bitXorExpr(),BITOR);
            _loc2_ = peekToken();
         }
         return _loc1_;
      }
      
      private function bitAndExpr() : IExpr
      {
         var _loc1_:IExpr = eqExpr();
         var _loc2_:int = peekToken();
         while(_loc2_ == BITAND)
         {
            consumeToken();
            _loc1_ = exprFactory.createBitExpr(_loc1_,eqExpr(),BITAND);
            _loc2_ = peekToken();
         }
         return _loc1_;
      }
      
      protected function expression() : IExpr
      {
         var _loc1_:IExpr = assignExpr();
         while(matchToken(COMMA))
         {
            _loc1_ = exprFactory.createExprList(_loc1_,assignExpr());
         }
         return _loc1_;
      }
      
      protected function parseFunction(param1:Boolean = false) : FunctionDef
      {
         reportError("msg.function.expr.not.supported","K09");
         return null;
      }
      
      private function andExpr() : IExpr
      {
         var _loc3_:int = 0;
         var _loc4_:* = false;
         var _loc1_:IExpr = bitOrExpr();
         var _loc2_:int = peekToken();
         if(_loc2_ == AND || _loc2_ == NAND)
         {
            _loc3_ = _loc2_;
            _loc4_ = _loc2_ == NAND;
            while(_loc2_ == _loc3_)
            {
               consumeToken();
               _loc1_ = exprFactory.createAndOrExpr(_loc1_,andExpr(),true,_loc4_);
               _loc2_ = peekToken();
            }
         }
         return _loc1_;
      }
      
      private function relExpr() : IExpr
      {
         var _loc1_:IExpr = shiftExpr();
         var _loc2_:int = peekToken();
         loop0:
         while(true)
         {
            switch(_loc2_)
            {
               case IS:
               case INSTANCEOF:
               case IN:
               case AS:
                  break loop0;
               case LE:
               case LT:
               case GE:
               case GT:
                  consumeToken();
                  _loc1_ = exprFactory.createEqRelExpr(_loc1_,shiftExpr(),_loc2_);
                  _loc2_ = peekToken();
                  continue;
               default:
                  addr93:
                  return _loc1_;
            }
         }
         consumeToken();
         _loc1_ = exprFactory.createIsInAsExpr(_loc1_,shiftExpr(),_loc2_);
         return _loc1_;
      }
      
      private function memberExpr(param1:Boolean) : IExpr
      {
         var _loc2_:IExpr = null;
         if(peekToken() == NEW)
         {
            consumeToken();
            _loc2_ = exprFactory.createNewExpr(memberExpr(false));
            if(matchToken(LP))
            {
               argumentList(_loc2_ as CallExpr);
            }
         }
         else
         {
            _loc2_ = primaryExpr();
         }
         return memberExprTail(param1,_loc2_);
      }
      
      private function checkAssignable(param1:*) : void
      {
         if(!(param1 is ISettable))
         {
            reportError("msg.not.assignable","K03");
         }
      }
      
      public function reportError(param1:String, param2:String, param3:String = null, param4:String = null, param5:String = null) : void
      {
         var v:int;
         throw new ParseError(Env.getMessage(param1,param3,param4,param5),param2,(v=ts.getLineno()),ts.getLineFromNo(v));
      }
      
      private function memberExprTail(param1:Boolean, param2:IExpr) : IExpr
      {
         var _loc3_:int = 0;
         var _loc4_:* = false;
         loop0:
         while(true)
         {
            _loc3_ = peekToken();
            switch(_loc3_)
            {
               case DOT:
               case DOTDOT:
                  consumeToken();
                  _loc4_ = _loc3_ == DOTDOT;
                  _loc3_ = nextToken();
                  switch(_loc3_)
                  {
                     case NAME:
                        param2 = propertyName(param2,ts.getString(),_loc4_);
                        break;
                     case MUL:
                        param2 = propertyName(param2,"*",_loc4_);
                        break;
                     case XMLATTR:
                        param2 = attributeAccess(param2,_loc4_);
                        break;
                     default:
                        reportError("msg.no.name.after.dot","K06");
                  }
                  continue;
               case DOTQUERY:
                  consumeToken();
                  param2 = exprFactory.createDotQuery(param2,expression());
                  mustMatchToken(RP,"msg.no.paren","k05");
                  continue;
               case LB:
                  consumeToken();
                  param2 = exprFactory.createAccessor(param2,expression());
                  mustMatchToken(RB,"msg.no.bracket.index","k06");
                  continue;
               case LP:
                  if(!param1)
                  {
                     addr168:
                     return param2;
                  }
                  consumeToken();
                  param2 = exprFactory.createCallExpr(param2);
                  argumentList(param2 as CallExpr);
                  continue;
               default:
                  break loop0;
            }
         }
         return param2;
      }
      
      private function addExpr() : IExpr
      {
         var _loc1_:IExpr = mulExpr();
         var _loc2_:int = peekToken();
         while(_loc2_ == ADD || _loc2_ == SUB)
         {
            consumeToken();
            _loc1_ = exprFactory.createAddSubExpr(_loc1_,mulExpr(),_loc2_ == ADD);
            _loc2_ = peekToken();
         }
         return _loc1_;
      }
      
      private function condExpr() : IExpr
      {
         var _loc2_:IExpr = null;
         var _loc1_:IExpr = orExpr();
         if(matchToken(HOOK))
         {
            _loc2_ = assignExpr();
            mustMatchToken(COLON,"msg.no.colon.cond","k01");
            _loc1_ = exprFactory.createCondExpr(_loc1_,_loc2_,assignExpr());
         }
         return _loc1_;
      }
      
      private function orExpr() : IExpr
      {
         var _loc3_:int = 0;
         var _loc4_:* = false;
         var _loc5_:* = false;
         var _loc1_:IExpr = andExpr();
         var _loc2_:int = peekToken();
         if(_loc2_ == OR || _loc2_ == NOR || _loc2_ == XOR)
         {
            _loc3_ = _loc2_;
            _loc4_ = _loc2_ == NOR;
            _loc5_ = _loc2_ == XOR;
            while(_loc2_ == _loc3_)
            {
               consumeToken();
               _loc1_ = exprFactory.createAndOrExpr(_loc1_,orExpr(),false,_loc4_,_loc5_);
               _loc2_ = peekToken();
            }
         }
         return _loc1_;
      }
      
      private function primaryExpr() : IExpr
      {
         var _loc2_:IExpr = null;
         var _loc3_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:* = undefined;
         var _loc1_:Boolean = true;
         var _loc4_:int = nextFlaggedToken();
         var _loc5_:* = _loc4_ & CLEAR_TI_MASK;
         switch(_loc5_)
         {
            case FUNCTION:
               return parseFunction(true);
            case LB:
               _loc3_ = [];
               _loc6_ = true;
               while(true)
               {
                  _loc5_ = int(peekToken());
                  if(_loc5_ == COMMA)
                  {
                     consumeToken();
                     if(!_loc6_)
                     {
                        _loc6_ = true;
                     }
                     else
                     {
                        _loc3_.push(Constant.NULL);
                     }
                  }
                  else
                  {
                     if(_loc5_ == RB)
                     {
                        break;
                     }
                     if(!_loc6_)
                     {
                        reportError("msg.no.bracket.arg","K10");
                     }
                     _loc6_ = false;
                     _loc2_ = assignExpr();
                     if(_loc2_ is Constant)
                     {
                        _loc3_.push((_loc2_ as Constant).getAny());
                     }
                     else
                     {
                        _loc3_.push(_loc2_);
                        _loc1_ = false;
                     }
                  }
               }
               consumeToken();
               return exprFactory.createObjectInit(_loc3_,_loc1_);
            case LC:
               _loc7_ = {};
               _loc3_ = [];
               if(!matchToken(LC))
               {
                  loop1:
                  do
                  {
                     _loc5_ = int(peekToken());
                     switch(_loc5_)
                     {
                        case NAME:
                        case STRING:
                           consumeToken();
                           _loc10_ = ts.getString();
                           _loc3_.push(_loc10_);
                           break;
                        case NUMBER:
                           consumeToken();
                           _loc10_ = ts.getNumber();
                           _loc3_.push(_loc10_);
                           break;
                        case RC:
                           break loop1;
                        default:
                           reportError("msg.bad.prop","K11");
                           break loop1;
                     }
                     mustMatchToken(COLON,"msg.no.colon.prop","k08");
                     _loc2_ = assignExpr();
                     if(_loc2_ is Constant)
                     {
                        _loc7_[_loc10_] = (_loc2_ as Constant).getAny();
                     }
                     else
                     {
                        _loc7_[_loc10_] = _loc2_;
                        _loc1_ = false;
                     }
                  }
                  while(matchToken(COMMA));
                  
                  mustMatchToken(RC,"msg.no.brace.prop","k09");
               }
               return exprFactory.createObjectInit(_loc7_,_loc1_,_loc3_);
            case LP:
               _loc2_ = expression();
               mustMatchToken(RP,"msg.no.paren","k10");
               return _loc2_;
            case XMLATTR:
               return attributeAccess();
            case NAME:
               _loc8_ = ts.getString();
               if((_loc4_ & TI_CHECK_LABEL) != 0 && peekToken() == COLON)
               {
                  consumeToken();
                  return new Label(_loc8_);
               }
               return propertyName(null,_loc8_);
            case THIS:
               consumeToken();
               return exprFactory.thisExpr();
            case NULL:
               return exprFactory.literal(null);
            case FALSE:
               return exprFactory.literal(false);
            case TRUE:
               return exprFactory.literal(true);
            case NUMBER:
               return exprFactory.literal(ts.getNumber());
            case STRING:
               return exprFactory.literal(ts.getString());
            case DIV:
            case ASSIGN_DIV:
               ts.readRegExp(_loc5_);
               _loc9_ = ts.regExpFlags;
               ts.regExpFlags = null;
               return exprFactory.regExp(ts.getString(),_loc9_);
            case RESERVED:
               reportError("msg.reserved.id","K12");
               break;
            case EOF:
               reportError("msg.unexpected.eof","K13");
               break;
            case ERROR:
            default:
               reportError("msg.syntax","K14");
         }
         return null;
      }
      
      protected function peekFlaggedToken() : int
      {
         peekToken();
         return currentFlaggedToken;
      }
      
      protected function matchToken(param1:int) : Boolean
      {
         var _loc2_:int = peekToken();
         if(_loc2_ != param1)
         {
            return false;
         }
         consumeToken();
         return true;
      }
      
      protected function eof() : Boolean
      {
         return ts.eof();
      }
   }
}
