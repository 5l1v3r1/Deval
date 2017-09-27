package r1.deval.parser
{
   import r1.deval.rt.Env;
   import r1.deval.util.StringBuffer;
   
   public class TokenStream extends ParserConsts
   {
       
      
      private var xmlIsTagContent:Boolean;
      
      private var sourceString:String;
      
      private var string:String = "";
      
      var regExpFlags:String;
      
      private var stringBuffer:StringBuffer;
      
      private var lineno:int;

      private var linenostart:int;
      
      private var lineEndChar:int = -1;
      
      private var sourceEnd:int;
      
      private var ungetBuffer:Array;
      
      private var number:Number;
      
      private var lineStart:int = 0;
      
      private var sourceCursor:int;
      
      private var ungetCursor:int;
      
      private var dirtyLine:Boolean;
      
      private var hitEOF:Boolean = false;
      
      private var line:String;
      
      private var xmlOpenTagsCount:int;
      
      private var xmlIsAttribute:Boolean;

      private var lines:Array;
      
      public function TokenStream(param1:String, param2:int = 1)
      {
         super();
         this.lineno = param2;
         this.linenostart=param2;
         this.stringBuffer = new StringBuffer();
         this.ungetBuffer = new Array(3);
         this.sourceString = param1;
         this.sourceEnd = param1.length;
         this.sourceCursor = 0;
         this.lines=new Array();
      }
      
      private static function isDigit(param1:int) : Boolean
      {
         return CHAR_0 <= param1 && param1 <= CHAR_9;
      }
      
      private static function isIdentifierPart(param1:int) : Boolean
      {
         return isIdentifierStart(param1) || param1 >= CHAR_0 && param1 <= CHAR_9;
      }
      
      private static function codeBug() : void
      {
         Env.reportError(ParseError.codeBugMessage,"KT");
      }
      
      private static function reportWarning(param1:String, param2:* = null, param3:* = null, param4:* = null) : void
      {
         Env.reportWarning(param1,param2,param3,param4);
      }
      
      private static function isJSLineTerminator(param1:int) : Boolean
      {
         if((param1 & 57296) != 0)
         {
            return false;
         }
         return param1 == CHAR_NL || param1 == CHAR_CR || param1 == 8232 || param1 == 8233;
      }
      
      private static function isIdentifierStart(param1:int) : Boolean
      {
         return param1 >= CHAR_a && param1 <= CHAR_z || param1 >= CHAR_A && param1 <= CHAR_Z || param1 == CHAR_UNDERSCORE;
      }
      
      private static function isJSSpace(param1:int) : Boolean
      {
         return param1 == 32 || param1 == 9 || param1 == 12 || param1 == 11 || param1 == 160;
      }
      
      private static function isAlpha(param1:int) : Boolean
      {
         if(param1 <= CHAR_Z)
         {
            return CHAR_A <= param1;
         }
         return CHAR_a <= param1 && param1 <= CHAR_z;
      }
      
      private static function oDigitToInt(param1:int, param2:int) : int
      {
         return param2 << 3 | param1 - CHAR_0;
      }
      
      private static function xDigitToInt(param1:int, param2:int) : int
      {
         if(param1 <= CHAR_9)
         {
            param1 = param1 - CHAR_0;
            if(0 <= param1)
            {
               addr46:
               return param2 << 4 | param1;
            }
         }
         else if(param1 <= CHAR_F)
         {
            if(CHAR_A <= param1)
            {
               param1 = param1 - (CHAR_A - 10);
               return param2 << 4 | param1;
            }
         }
         else if(param1 <= CHAR_f)
         {
            if(CHAR_a <= param1)
            {
               param1 = param1 - (CHAR_a - 10);
               return param2 << 4 | param1;
            }
         }
         return -1;
      }
      
      private static function reportError(param1:String) : void
      {
         Env.reportError(param1,"KT");
      }
      
      private static function stringToKeyword(param1:String) : int
      {
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = param1.length;
         if(_loc4_ >= 2)
         {
            _loc5_ = param1.charCodeAt(0);
            _loc6_ = param1.charCodeAt(1);
            loop0:
            switch(_loc4_)
            {
               case 2:
                  switch(_loc5_)
                  {
                     case CHAR_a:
                        if(_loc6_ == CHAR_s)
                        {
                           return AS;
                        }
                        break loop0;
                     case CHAR_i:
                        switch(_loc6_)
                        {
                           case CHAR_f:
                              return IF;
                           case CHAR_n:
                              return IN;
                           case CHAR_s:
                              return IS;
                           default:
                              break loop0;
                        }
                     case CHAR_d:
                        if(param1.charCodeAt(1) == CHAR_o)
                        {
                           return DO;
                        }
                        break loop0;
                     case CHAR_o:
                        if(param1.charCodeAt(1) == CHAR_r)
                        {
                           return OR;
                        }
                        break loop0;
                     default:
                        break loop0;
                  }
               case 3:
                  switch(_loc5_)
                  {
                     case CHAR_a:
                        _loc3_ = "and";
                        _loc2_ = AND;
                        break loop0;
                     case CHAR_f:
                        _loc3_ = "for";
                        _loc2_ = FOR;
                        break loop0;
                     case CHAR_n:
                        if(param1 == "new")
                        {
                           return NEW;
                        }
                        if(param1 == "nor")
                        {
                           return NOR;
                        }
                        if(param1 == "not")
                        {
                           return NOT;
                        }
                        break loop0;
                     case CHAR_t:
                        _loc3_ = "try";
                        _loc2_ = TRY;
                        break loop0;
                     case CHAR_v:
                        _loc3_ = "var";
                        _loc2_ = VAR;
                        break loop0;
                     case CHAR_x:
                        _loc3_ = "xor";
                        _loc2_ = XOR;
                        break loop0;
                     default:
                        break loop0;
                  }
               case 4:
                  switch(_loc5_)
                  {
                     case CHAR_c:
                        _loc3_ = "case";
                        _loc2_ = CASE;
                        break loop0;
                     case CHAR_e:
                        _loc3_ = "else";
                        _loc2_ = ELSE;
                        break loop0;
                     case CHAR_n:
                        if(param1 == "null")
                        {
                           return NULL;
                        }
                        if(param1 == "nand")
                        {
                           return NAND;
                        }
                        break loop0;
                     case CHAR_t:
                        if(param1 == "true")
                        {
                           return TRUE;
                        }
                        if(param1 == "this")
                        {
                           return THIS;
                        }
                        break loop0;
                     case CHAR_v:
                        _loc3_ = "void";
                        _loc2_ = VOID;
                        break loop0;
                     case CHAR_w:
                        _loc3_ = "with";
                        _loc2_ = WITH;
                        break loop0;
                     default:
                        break loop0;
                  }
               case 5:
                  switch(param1.charCodeAt(2))
                  {
                     case CHAR_a:
                        _loc3_ = "class";
                        _loc2_ = CLASS;
                        break loop0;
                     case CHAR_e:
                        _loc3_ = "break";
                        _loc2_ = BREAK;
                        break loop0;
                     case CHAR_i:
                        _loc3_ = "while";
                        _loc2_ = WHILE;
                        break loop0;
                     case CHAR_l:
                        _loc3_ = "false";
                        _loc2_ = FALSE;
                        break loop0;
                     case CHAR_r:
                        _loc3_ = "throw";
                        _loc2_ = THROW;
                        break loop0;
                     case CHAR_t:
                        _loc3_ = "catch";
                        _loc2_ = CATCH;
                        break loop0;
                     default:
                        break loop0;
                  }
               case 6:
                  switch(param1.charCodeAt(5))
                  {
                     case CHAR_e:
                        _loc3_ = "delete";
                        _loc2_ = DELETE;
                        break loop0;
                     case CHAR_n:
                        _loc3_ = "return";
                        _loc2_ = RETURN;
                        break loop0;
                     case CHAR_t:
                        _loc3_ = "import";
                        _loc2_ = IMPORT;
                        break loop0;
                     case CHAR_h:
                        _loc3_ = "switch";
                        _loc2_ = SWITCH;
                        break loop0;
                     case CHAR_f:
                        _loc3_ = "typeof";
                        _loc2_ = TYPEOF;
                        break loop0;
					 case CHAR_c:
						 _loc3_ = "static";
						 _loc2_ = STATIC;
						 break loop0;
                     default:
                        break loop0;
                  }
               case 7:
                  switch(_loc6_)
                  {
                     case CHAR_e:
                        _loc3_ = "default";
                        _loc2_ = DEFAULT;
                        break loop0;
                     case CHAR_i:
                        _loc3_ = "finally";
                        _loc2_ = FINALLY;
                        break loop0;
                     default:
                        break loop0;
                  }
               case 8:
                  switch(_loc5_)
                  {
                     case CHAR_c:
                        _loc3_ = "continue";
                        _loc2_ = CONTINUE;
                        break loop0;
                     case CHAR_f:
                        _loc3_ = "function";
                        _loc2_ = FUNCTION;
                        break loop0;
                     default:
                        break loop0;
                  }
               case 10:
                  if(param1 == "instanceof")
                  {
                     return INSTANCEOF;
                  }
            }
            if(_loc3_ != null && _loc3_ != param1)
            {
               _loc2_ = 0;
            }
         }
         return _loc2_ == 0?int(EOF):_loc2_ & 255;
      }
      
      private static function isKeyword(param1:String) : Boolean
      {
         return EOF != stringToKeyword(param1);
      }
      
      public final function getOffset() : int
      {
         var _loc1_:int = sourceCursor - lineStart;
         if(lineEndChar >= 0)
         {
            _loc1_--;
         }
         return _loc1_;
      }
      
      public final function getString() : String
      {
         return string;
      }
      
      public function isXMLAttribute() : Boolean
      {
         return xmlIsAttribute;
      }
      
      public function ungetChar(param1:int) : void
      {
         if(ungetCursor != 0 && ungetBuffer[ungetCursor - 1] == CHAR_NL)
         {
            codeBug();
         }
         var _loc2_:* = ungetCursor++;
         ungetBuffer[_loc2_] = param1;
      }
      
      public function readPI() : Boolean
      {
         var _loc1_:int = getChar();
         while(_loc1_ != CHAR_EOF)
         {
            addToString(_loc1_);
            if(_loc1_ == CHAR_QUESTION && peekChar() == CHAR_GT)
            {
               _loc1_ = getChar();
               addToString(_loc1_);
               return true;
            }
            _loc1_ = getChar();
         }
         stringBuffer.clear();
         this.string = null;
         reportError("msg.XML.bad.form");
         return false;
      }
      
      private function readCDATA() : Boolean
      {
         var _loc1_:int = getChar();
         while(_loc1_ != CHAR_EOF)
         {
            addToString(_loc1_);
            if(_loc1_ == CHAR_RBRACKET && peekChar() == CHAR_RBRACKET)
            {
               _loc1_ = getChar();
               addToString(_loc1_);
               if(peekChar() == CHAR_GT)
               {
                  _loc1_ = getChar();
                  addToString(_loc1_);
                  return true;
               }
            }
            else
            {
               _loc1_ = getChar();
            }
         }
         stringBuffer.clear();
         this.string = null;
         reportError("msg.XML.bad.form");
         return false;
      }
      
      private function readEntity() : Boolean
      {
         var _loc1_:int = 1;
         var _loc2_:int = getChar();
         while(_loc2_ != CHAR_EOF)
         {
            addToString(_loc2_);
            switch(_loc2_)
            {
               case CHAR_LT:
                  _loc1_++;
                  break;
               case CHAR_GT:
                  _loc1_--;
                  if(_loc1_ == 0)
                  {
                     return true;
                  }
                  break;
            }
            _loc2_ = getChar();
         }
         stringBuffer.clear();
         this.string = null;
         reportError("msg.XML.bad.form");
         return false;
      }
      
      public function skipLine() : void
      {
         var _loc1_:int = 0;
         while((_loc1_ = getChar()) != CHAR_EOF && _loc1_ != CHAR_NL)
         {
         }
         ungetChar(_loc1_);
      }
      
      public function readRegExp(param1:int) : void
      {
         var _loc2_:int = 0;
         stringBuffer.clear();
         if(param1 == ASSIGN_DIV)
         {
            addToString(CHAR_EQUAL);
         }
         else if(param1 != DIV)
         {
            codeBug();
         }
         while((_loc2_ = getChar()) != CHAR_SLASH)
         {
            if(_loc2_ == CHAR_NL || _loc2_ == CHAR_EOF)
            {
               ungetChar(_loc2_);
               reportError("msg.unterminated.re.lit");
            }
            if(_loc2_ == CHAR_BACKSLASH)
            {
               addToString(_loc2_);
               _loc2_ = getChar();
            }
            addToString(_loc2_);
         }
         var _loc3_:int = stringBuffer.length;
         while(true)
         {
            if(matchChar(CHAR_g))
            {
               addToString(CHAR_g);
               continue;
            }
            if(matchChar(CHAR_i))
            {
               addToString(CHAR_i);
               continue;
            }
            if(matchChar(CHAR_m))
            {
               addToString(CHAR_m);
               continue;
            }
            break;
         }
         if(isAlpha(peekChar()))
         {
            reportError("msg.invalid.re.flag");
         }
         this.string = stringBuffer.substring(0,_loc3_);
         this.regExpFlags = stringBuffer.substr(_loc3_,stringBuffer.length - _loc3_);
      }
      
      public final function getLineno() : int
      {
         return lineno;
      }
      
      public final function getLineFromNo(x:int):String {
         var v:int=x-linenostart;
         if (lines.length>v) return lines[v];
         return sourceString.substring(lineStart,sourceCursor);
      }
      public function getNextXMLToken() : int
      {
         stringBuffer.clear();
         var _loc1_:int = getChar();
         while(true)
         {
            if(_loc1_ == CHAR_EOF)
            {
               stringBuffer.clear();
               this.string = null;
               reportError("msg.XML.bad.form");
               return ERROR;
            }
            if(xmlIsTagContent)
            {
               switch(_loc1_)
               {
                  case CHAR_GT:
                     addToString(_loc1_);
                     xmlIsTagContent = false;
                     xmlIsAttribute = false;
                     break;
                  case CHAR_SLASH:
                     addToString(_loc1_);
                     if(peekChar() == CHAR_GT)
                     {
                        _loc1_ = getChar();
                        addToString(_loc1_);
                        xmlIsTagContent = false;
                        xmlOpenTagsCount--;
                     }
                     break;
                  case CHAR_LBRACE:
                     ungetChar(_loc1_);
                     this.string = getStringFromBuffer();
                     return XML;
                  case CHAR_QUOTE:
                  case CHAR_DOUBLEQUOTE:
                     addToString(_loc1_);
                     if(!readQuotedString(_loc1_))
                     {
                        return ERROR;
                     }
                     break;
                  case CHAR_EQUAL:
                     addToString(_loc1_);
                     xmlIsAttribute = true;
                     break;
                  case CHAR_SPACE:
                  case CHAR_TAB:
                  case CHAR_CR:
                  case CHAR_NL:
                     addToString(_loc1_);
                     break;
                  default:
                     addToString(_loc1_);
                     xmlIsAttribute = false;
               }
               if(!xmlIsTagContent && xmlOpenTagsCount == 0)
               {
                  break;
               }
            }
            else
            {
               switch(_loc1_)
               {
                  case CHAR_LT:
                     addToString(_loc1_);
                     _loc1_ = peekChar();
                     switch(_loc1_)
                     {
                        case CHAR_BAN:
                           _loc1_ = getChar();
                           addToString(_loc1_);
                           _loc1_ = peekChar();
                           switch(_loc1_)
                           {
                              case CHAR_DASH:
                                 _loc1_ = getChar();
                                 addToString(_loc1_);
                                 _loc1_ = getChar();
                                 if(_loc1_ == CHAR_DASH)
                                 {
                                    addToString(_loc1_);
                                    if(!readXmlComment())
                                    {
                                       return ERROR;
                                    }
                                    break;
                                 }
                                 stringBuffer.clear();
                                 this.string = null;
                                 reportError("msg.XML.bad.form");
                                 return ERROR;
                              case CHAR_LBRACKET:
                                 _loc1_ = getChar();
                                 addToString(_loc1_);
                                 if(getChar() == CHAR_C && getChar() == CHAR_D && getChar() == CHAR_A && getChar() == CHAR_T && getChar() == CHAR_A && getChar() == CHAR_LBRACKET)
                                 {
                                    addToString("CDATA[");
                                    if(!readCDATA())
                                    {
                                       return ERROR;
                                    }
                                    break;
                                 }
                                 stringBuffer.clear();
                                 this.string = null;
                                 reportError("msg.XML.bad.form");
                                 return ERROR;
                              default:
                                 if(!readEntity())
                                 {
                                    return ERROR;
                                 }
                                 break;
                           }
                           break;
                        case CHAR_QUESTION:
                           _loc1_ = getChar();
                           addToString(_loc1_);
                           if(!readPI())
                           {
                              return ERROR;
                           }
                           break;
                        case CHAR_SLASH:
                           _loc1_ = getChar();
                           addToString(_loc1_);
                           if(xmlOpenTagsCount == 0)
                           {
                              stringBuffer.clear();
                              this.string = null;
                              reportError("msg.XML.bad.form");
                              return ERROR;
                           }
                           xmlIsTagContent = true;
                           xmlOpenTagsCount--;
                           break;
                        default:
                           xmlIsTagContent = true;
                           xmlOpenTagsCount++;
                     }
                     break;
                  case CHAR_LBRACE:
                     ungetChar(_loc1_);
                     this.string = getStringFromBuffer();
                     return XML;
                  default:
                     addToString(_loc1_);
               }
            }
            _loc1_ = getChar();
         }
         this.string = getStringFromBuffer();
         return XMLEND;
      }
      
      public function addToString(param1:*) : void
      {
         if(param1 is String)
         {
            stringBuffer.append(param1);
         }
         else
         {
            stringBuffer.append(String.fromCharCode(int(param1)));
         }
      }
      
      public function matchChar(...param1) : Boolean
      {
         var x:Array=new Array();
         var j:int,k:int;
         var res:Boolean=true;
         for (var i:int=0;i<param1.length;i++) {
            k=getChar();
            if (k==CHAR_EOF) break;
            x.push(k);
            j=param1[i];
            if (j!=k) {
               res=false;
               break;
            }
         }
         if (res) return true;
         for each (k in x) {
            ungetChar(k);
         }
         return false;
      }
      
      public function getFirstXMLToken() : int
      {
         xmlOpenTagsCount = 0;
         xmlIsAttribute = false;
         xmlIsTagContent = false;
         ungetChar(CHAR_LT);
         return getNextXMLToken();
      }
      
      public final function getNumber() : Number
      {
         return number;
      }
      
      public final function getToken() : int
      {
         var c:int = 0;
         var identifierStart:Boolean = false;
         var isUnicodeEscapeStart:Boolean = false;
         var containsEscape:Boolean = false;
         var str:String = null;
         var escapeVal:int = 0;
         var i:int = 0;
         var result:int = 0;
         var base:int = 0;
         var isInteger:Boolean = false;
         var numString:String = null;
         var dval:Number = NaN;
         var lookForSlash:Boolean = false;
         loop0:
         while(true)
         {
            while(true)
            {
               c = getChar();
               if(c == CHAR_EOF)
               {
                  break;
               }
               if(c == CHAR_NL)
               {
                  dirtyLine = false;
                  return EOL;
               }
               if(!isJSSpace(c))
               {
                  if(c != CHAR_DASH)
                  {
                     dirtyLine = true;
                  }
                  if(c == CHAR_AT)
                  {
                     return XMLATTR;
                  }
                  isUnicodeEscapeStart = false;
                  if(c == CHAR_BACKSLASH)
                  {
                     c = getChar();
                     if(c == CHAR_u)
                     {
                        identifierStart = true;
                        isUnicodeEscapeStart = true;
                        stringBuffer.clear();
                     }
                     else
                     {
                        identifierStart = false;
                        ungetChar(c);
                        c = CHAR_BACKSLASH;
                     }
                  }
                  else
                  {
                     identifierStart = isIdentifierStart(c);
                     if(identifierStart)
                     {
                        stringBuffer.clear();
                        addToString(c);
                     }
                  }
                  if(identifierStart)
                  {
                     containsEscape = isUnicodeEscapeStart;
                     while(true)
                     {
                        if(isUnicodeEscapeStart)
                        {
                           escapeVal = 0;
                           i = 0;
                           while(i != 4)
                           {
                              c = getChar();
                              escapeVal = xDigitToInt(c,escapeVal);
                              if(escapeVal < 0)
                              {
                                 break;
                              }
                              i++;
                           }
                           if(escapeVal < 0)
                           {
                              break;
                           }
                           addToString(escapeVal);
                           isUnicodeEscapeStart = false;
                        }
                        else
                        {
                           c = getChar();
                           if(c == CHAR_BACKSLASH)
                           {
                              c = getChar();
                              if(c == CHAR_u)
                              {
                                 isUnicodeEscapeStart = true;
                                 containsEscape = true;
                                 continue;
                              }
                              reportError("msg.illegal.character");
                              return ERROR;
                           }
                           if(c == CHAR_EOF || !isIdentifierPart(c))
                           {
                              ungetChar(c);
                              str = getStringFromBuffer();
                              if(!containsEscape)
                              {
                                 result = stringToKeyword(str);
                                 if(result != EOF)
                                 {
                                    if(result != RESERVED)
                                    {
                                       return result;
                                    }
                                    reportWarning("msg.reserved.keyword",str);
                                 }
                              }
                              this.string = str;
                              return NAME;
                           }
                           addToString(c);
                        }
                     }
                     reportError("msg.invalid.escape");
                     return ERROR;
                  }
                  if(isDigit(c) || c == CHAR_DOT && isDigit(peekChar()))
                  {
                     stringBuffer.clear();
                     base = 10;
                     if(c == CHAR_0)
                     {
                        c = getChar();
                        if(c == CHAR_x || c == CHAR_X)
                        {
                           base = 16;
                           c = getChar();
                        }
                        else if(isDigit(c))
                        {
                           base = 8;
                        }
                        else
                        {
                           addToString(CHAR_0);
                        }
                     }
                     if(base == 16)
                     {
                        while(0 <= xDigitToInt(c,0))
                        {
                           addToString(c);
                           c = getChar();
                        }
                     }
                     else
                     {
                        while(CHAR_0 <= c && c <= CHAR_9)
                        {
                           if(base == 8 && c >= CHAR_8)
                           {
                              reportWarning("msg.bad.octal.literal",c == CHAR_8?"8":"9");
                              base = 10;
                           }
                           addToString(c);
                           c = getChar();
                        }
                     }
                     isInteger = true;
                     if(base == 10 && (c == CHAR_DOT || c == CHAR_e || c == CHAR_E))
                     {
                        isInteger = false;
                        if(c == CHAR_DOT)
                        {
                           do
                           {
                              addToString(c);
                              c = getChar();
                           }
                           while(isDigit(c));
                           
                        }
                        if(c == CHAR_e || c == CHAR_E)
                        {
                           addToString(c);
                           c = getChar();
                           if(c == CHAR_PLUS || c == CHAR_DASH)
                           {
                              addToString(c);
                              c = getChar();
                           }
                           if(!isDigit(c))
                           {
                              reportError("msg.missing.exponent");
                              return ERROR;
                           }
                           do
                           {
                              addToString(c);
                              c = getChar();
                           }
                           while(isDigit(c));
                           
                        }
                     }
                     ungetChar(c);
                     numString = getStringFromBuffer();
                     if(base == 10 && !isInteger)
                     {
                        try
                        {
                           dval = Number(numString);
                        }
                        catch(error:Error)
                        {
                           reportError("msg.caught.nfe");
                           return ERROR;
                        }
                     }
                     else
                     {
                        dval = stringToNumber(numString,base);
                     }
                     this.number = dval;
                     return NUMBER;
                  }
                  switch(c)
                  {
                     case CHAR_DOUBLEQUOTE:
                     case CHAR_QUOTE:
                        break loop0;
                     case CHAR_SEMICOLON:
                        return SEMI;
                     case CHAR_LBRACKET:
                        return LB;
                     case CHAR_RBRACKET:
                        return RB;
                     case CHAR_LBRACE:
                        return LC;
                     case CHAR_RBRACE:
                        return RC;
                     case CHAR_LPAREN:
                        return LP;
                     case CHAR_RPAREN:
                        return RP;
                     case CHAR_COMMA:
                        return COMMA;
                     case CHAR_QUESTION:
                        return HOOK;
                     case CHAR_TILDA:
                        return BITNOT;
                     case CHAR_COLON:
                        return !!matchChar(CHAR_COLON)?int(COLONCOLON):int(COLON);
                     case CHAR_DOT:
                        if(matchChar(CHAR_DOT,CHAR_DOT))
                        {
                           return DOTDOTDOT;
                        }
                        if(matchChar(CHAR_DOT))
                        {
                           return DOTDOT;
                        }
                        return !!matchChar(CHAR_LPAREN)?int(DOTQUERY):int(DOT);
                     case CHAR_PIPE:
                        if(matchChar(CHAR_PIPE))
                        {
                           return !!matchChar(CHAR_EQUAL)?int(ASSIGN_OR):int(OR);
                        }
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_BITOR):int(BITOR);
                     case CHAR_CARET:
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_BITXOR):int(BITXOR);
                     case CHAR_AMPERSAND:
                        if(matchChar(CHAR_AMPERSAND))
                        {
                           return !!matchChar(CHAR_EQUAL)?int(ASSIGN_AND):int(AND);
                        }
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_BITAND):int(BITAND);
                     case CHAR_EQUAL:
                        if(matchChar(CHAR_EQUAL))
                        {
                           return !!matchChar(CHAR_EQUAL)?int(SHEQ):int(EQ);
                        }
                        return ASSIGN;
                     case CHAR_BAN:
                        if(matchChar(CHAR_EQUAL))
                        {
                           return !!matchChar(CHAR_EQUAL)?int(SHNE):int(NE);
                        }
                        return NOT;
                     case CHAR_LT:
                        if(matchChar(CHAR_BAN))
                        {
                           if(matchChar(CHAR_DASH))
                           {
                              if(matchChar(CHAR_DASH))
                              {
                                 skipLine();
                                 continue loop0;
                              }
                              ungetChar(CHAR_DASH);
                           }
                           ungetChar(CHAR_BAN);
                        }
                        if(matchChar(CHAR_LT))
                        {
                           return !!matchChar(CHAR_EQUAL)?int(ASSIGN_LSH):int(LSH);
                        }
                        return !!matchChar(CHAR_EQUAL)?int(LE):int(LT);
                     case CHAR_GT:
                        if(matchChar(CHAR_GT))
                        {
                           if(matchChar(CHAR_GT))
                           {
                              return !!matchChar(CHAR_EQUAL)?int(ASSIGN_URSH):int(URSH);
                           }
                           return !!matchChar(CHAR_EQUAL)?int(ASSIGN_RSH):int(RSH);
                        }
                        return !!matchChar(CHAR_EQUAL)?int(GE):int(GT);
                     case CHAR_STAR:
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_MUL):int(MUL);
                     case CHAR_SLASH:
                        if(matchChar(CHAR_SLASH))
                        {
                           skipLine();
                           continue loop0;
                        }
                        if(matchChar(CHAR_STAR))
                        {
                           lookForSlash = false;
                           while(true)
                           {
                              c = getChar();
                              if(c == CHAR_EOF)
                              {
                                 break;
                              }
                              if(c == CHAR_STAR)
                              {
                                 lookForSlash = true;
                              }
                              else if(c == CHAR_SLASH)
                              {
                                 if(lookForSlash)
                                 {
                                    continue loop0;
                                 }
                              }
                              else
                              {
                                 lookForSlash = false;
                              }
                           }
                           reportError("msg.unterminated.comment");
                           return ERROR;
                        }
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_DIV):int(DIV);
                     case CHAR_PERCENT:
                        return !!matchChar(CHAR_EQUAL)?int(ASSIGN_MOD):int(MOD);
                     case CHAR_PLUS:
                        if(matchChar(CHAR_EQUAL))
                        {
                           return ASSIGN_ADD;
                        }
                        return !!matchChar(CHAR_PLUS)?int(INC):int(ADD);
                     case CHAR_DASH:
                        if(matchChar(CHAR_EQUAL))
                        {
                           c = ASSIGN_SUB;
                        }
                        else if(matchChar(CHAR_DASH))
                        {
                           if(!dirtyLine)
                           {
                              if(matchChar(CHAR_GT))
                              {
                                 skipLine();
                                 continue loop0;
                              }
                           }
                           c = DEC;
                        }
                        else
                        {
                           c = SUB;
                        }
                        dirtyLine = true;
                        return c;
                     default:
                        reportError("msg.illegal.character");
                        return ERROR;
                  }
               }
               else
               {
                  continue;
               }
            }
            return EOF;
         }
         return readString(c);
      }
      
      private function readString(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         stringBuffer.clear();
         var _loc3_:int = getChar();
         loop0:
         while(_loc3_ != param1)
         {
            if(_loc3_ == CHAR_NL || _loc3_ == CHAR_EOF)
            {
               ungetChar(_loc3_);
               reportError("msg.unterminated.string.lit");
               return ERROR;
            }
            if(_loc3_ == CHAR_BACKSLASH)
            {
               _loc3_ = getChar();
               switch(_loc3_)
               {
                  case CHAR_b:
                     _loc3_ = CHAR_BACKSLASH;
                     break;
                  case CHAR_f:
                     _loc3_ = CHAR_FEED;
                     break;
                  case CHAR_n:
                     _loc3_ = CHAR_NL;
                     break;
                  case CHAR_r:
                     _loc3_ = CHAR_CR;
                     break;
                  case CHAR_t:
                     _loc3_ = CHAR_TAB;
                     break;
                  case CHAR_v:
                     _loc3_ = 11;
                     break;
                  case CHAR_u:
                     _loc4_ = stringBuffer.length;
                     _loc5_ = "u";
                     _loc2_ = 0;
                     _loc6_ = 0;
                     while(_loc6_ != 4)
                     {
                        _loc3_ = getChar();
                        _loc2_ = xDigitToInt(_loc3_,_loc2_);
                        if(_loc2_ < 0)
                        {
                           addToString(_loc5_);
                           continue loop0;
                        }
                        _loc5_ = _loc5_ + String.fromCharCode(_loc3_);
                        _loc6_++;
                     }
                     _loc3_ = _loc2_;
                     break;
                  case CHAR_x:
                     _loc3_ = getChar();
                     _loc2_ = xDigitToInt(_loc3_,0);
                     if(_loc2_ < 0)
                     {
                        addToString(CHAR_x);
                        continue;
                     }
                     _loc7_ = _loc3_;
                     _loc3_ = getChar();
                     _loc2_ = xDigitToInt(_loc3_,_loc2_);
                     if(_loc2_ < 0)
                     {
                        addToString(CHAR_x);
                        addToString(_loc7_);
                        continue;
                     }
                     _loc3_ = _loc2_;
                     break;
                  case CHAR_NL:
                     _loc3_ = getChar();
                     continue;
                  default:
                     if(CHAR_0 <= _loc3_ && _loc3_ < CHAR_8)
                     {
                        _loc8_ = _loc3_ - CHAR_0;
                        _loc3_ = getChar();
                        if(CHAR_0 <= _loc3_ && _loc3_ < CHAR_8)
                        {
                           _loc8_ = 8 * _loc8_ + _loc3_ - CHAR_0;
                           _loc3_ = getChar();
                           if(CHAR_0 <= _loc3_ && _loc3_ < CHAR_8 && _loc8_ <= 37)
                           {
                              _loc8_ = 8 * _loc8_ + _loc3_ - CHAR_0;
                              _loc3_ = getChar();
                           }
                        }
                        ungetChar(_loc3_);
                        _loc3_ = _loc8_;
                     }
               }
            }
            addToString(_loc3_);
            _loc3_ = getChar();
         }
         this.string = getStringFromBuffer();
         return STRING;
      }
      
      private function readQuotedString(param1:int) : Boolean
      {
         var _loc2_:int = getChar();
         while(_loc2_ != CHAR_EOF)
         {
            addToString(_loc2_);
            if(_loc2_ == param1)
            {
               return true;
            }
            _loc2_ = getChar();
         }
         stringBuffer.clear();
         this.string = null;
         reportError("msg.XML.bad.form");
         return false;
      }
      
      private function stringToNumber(param1:String, param2:Number) : Number
      {
         var _loc4_:int = 0;
         var _loc3_:Number = 0;
         if(param2 == 10)
         {
            return Number(param1);
         }
         if(param2 == 16)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc3_ = xDigitToInt(param1.charCodeAt(_loc4_),_loc3_);
               _loc4_++;
            }
         }
         else if(param2 == 8)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc3_ = oDigitToInt(param1.charCodeAt(_loc4_),_loc3_);
               _loc4_++;
            }
         }
         else
         {
            Env.reportError("msg.bad.number.base",param2);
         }
         return _loc3_;
      }
      
      public function peekChar() : int
      {
         var _loc1_:int = getChar();
         ungetChar(_loc1_);
         return _loc1_;
      }
      
      public function getChar() : int
      {
         var _loc1_:int = 0;
         if(ungetCursor != 0)
         {
            return ungetBuffer[--ungetCursor];
         }
         while(sourceCursor != sourceEnd)
         {
            _loc1_ = sourceString.charCodeAt(sourceCursor++);
            if(lineEndChar >= 0)
            {
               if(lineEndChar == CHAR_CR && _loc1_ == CHAR_NL)
               {
                  lineEndChar = CHAR_NL;
                  continue;
               }
               lineEndChar = -1;
               lines.push(sourceString.substring(lineStart,lineStart=sourceCursor-1));
               lineno++;
            }
            if(_loc1_ <= 127)
            {
               if(_loc1_ == CHAR_NL || _loc1_ == CHAR_CR)
               {
                  lineEndChar = _loc1_;
                  _loc1_ = CHAR_NL;
               }
            }
            else if(isJSLineTerminator(_loc1_))
            {
               lineEndChar = _loc1_;
               _loc1_ = CHAR_NL;
            }
            return _loc1_;
         }
         hitEOF = true;
         return CHAR_EOF;
      }
      
      public function getStringFromBuffer() : String
      {
         return stringBuffer.toString();
      }
      
      public final function getLine() : String
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(sourceString != null)
         {
            _loc1_ = sourceCursor;
            if(lineEndChar >= 0)
            {
               _loc1_--;
            }
            else
            {
               while(_loc1_ != sourceEnd)
               {
                  _loc2_ = sourceString.charCodeAt(_loc1_);
                  if(isJSLineTerminator(_loc2_))
                  {
                     break;
                  }
                  _loc1_++;
               }
            }
            return sourceString.substring(lineStart,_loc1_);
         }
         _loc3_ = sourceCursor - lineStart;
         if(lineEndChar >= 0)
         {
            _loc3_--;
         }
         else
         {
            while(true)
            {
               _loc4_ = lineStart + _loc3_;
               if(_loc4_ == sourceEnd)
               {
                  break;
               }
               _loc2_ = sourceString.charCodeAt(_loc4_);
               if(isJSLineTerminator(_loc2_))
               {
                  break;
               }
               _loc3_++;
            }
         }
         return sourceString.substring(lineStart,_loc3_);
      }
      
      public final function eof() : Boolean
      {
         return hitEOF;
      }
      
      private function readXmlComment() : Boolean
      {
         var _loc1_:int = getChar();
         while(_loc1_ != CHAR_EOF)
         {
            addToString(_loc1_);
            if(_loc1_ == CHAR_DASH && peekChar() == CHAR_DASH)
            {
               _loc1_ = getChar();
               addToString(_loc1_);
               if(peekChar() == CHAR_GT)
               {
                  _loc1_ = getChar();
                  addToString(_loc1_);
                  return true;
               }
            }
            else
            {
               _loc1_ = getChar();
            }
         }
         stringBuffer.clear();
         this.string = null;
         reportError("msg.XML.bad.form");
         return false;
      }
   }
}
