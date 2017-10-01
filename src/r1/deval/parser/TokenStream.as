package r1.deval.parser
{
  import r1.deval.rt.Env;
  import r1.deval.util.StringBuffer;

  public class TokenStream extends ParserConsts
  {
	private var xmlIsTagContent:Boolean;
	private var sourceString:String;
	private var string:String = "";
	internal var regExpFlags:String;
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

	public function TokenStream(source:String, lineno:int=1)
	{
	  super();
	  this.lineno = lineno;
	  this.linenostart=lineno;
	  this.stringBuffer = new StringBuffer();
	  this.ungetBuffer = new Array(3);
	  this.sourceString = source;
	  this.sourceEnd = source.length;
	  this.sourceCursor = 0;
	  this.lines=new Array();
	}

	private static function isDigit(c:int):Boolean { return CHAR_0 <= c && c <= CHAR_9; }

	private static function isIdentifierPart(c:int):Boolean { return isIdentifierStart(c) || c >= CHAR_0 && c <= CHAR_9; }

	private static function codeBug():void { Env.reportError(ParseError.codeBugMessage, "KT"); }

	private static function reportWarning(msgId:String, p1:*=null, p2:*=null, p3:*=null):void { Env.reportWarning(msgId, p1, p2, p3); }

	private static function isJSLineTerminator(c:int):Boolean
	{
	  if ((c & 57296) != 0) return false;
	  return c == CHAR_NL || c == CHAR_CR || c == 8232 || c == 8233;
	}

	private static function isIdentifierStart(c:int):Boolean { return c >= CHAR_a && c <= CHAR_z || c >= CHAR_A && c <= CHAR_Z || c == CHAR_UNDERSCORE; }

	private static function isJSSpace(c:int):Boolean { return c == 32 || c == 9 || c == 12 || c == 11 || c == 160; }

	private static function isAlpha(c:int):Boolean
	{
	  if (c <= CHAR_Z) return CHAR_A <= c;
	  return CHAR_a <= c && c <= CHAR_z;
	}

	private static function oDigitToInt(c:int, accumulator:int):int { return accumulator << 3 | c - CHAR_0; }

	private static function xDigitToInt(c:int, accumulator:int):int
	{
	  if (c <= CHAR_9)
	  {
		c = c - CHAR_0;
		if (0 <= c)
		{
		  addr46:
		  return accumulator << 4 | c;
		}
	  }
	  else if (c <= CHAR_F)
	  {
		if (CHAR_A <= c)
		{
		  c = c - (CHAR_A - 10);
		  return accumulator << 4 | c;
		}
	  }
	  else if (c <= CHAR_f)
	  {
		if (CHAR_a <= c)
		{
		  c = c - (CHAR_a - 10);
		  return accumulator << 4 | c;
		}
	  }
	  return -1;
	}

	private static function reportError(msgId:String):void { Env.reportError(msgId, "KT"); }

	private static function stringToKeyword(s:String):int
	{
	  var x:String = null;
	  var c0:int = 0;
	  var c1:int = 0;
	  var id:int = 0;
	  var len:int = s.length;
	  if (len >= 2)
	  {
		c0 = s.charCodeAt(0);
		c1 = s.charCodeAt(1);
		switch (len)
		{
		  case 2:
			if (c0 == CHAR_a)
			{
			  if (c1 == CHAR_s) return AS;
			  break;
			}
			else if (c0 == CHAR_i)
			{
			  if (c1 == CHAR_f) return IF;
			  else if (c1 == CHAR_n) return IN;
			  else if (c1 == CHAR_s) return IS;
			  else break;
			}
			else if (c0 == CHAR_d)
			{
			  if (s.charCodeAt(1) == CHAR_o) return DO;
			  break;
			}
			else if (c0 == CHAR_o)
			{
			  if (s.charCodeAt(1) == CHAR_r) return OR;
			  break;
			}
			else
			{
			  break;
			}
		  case 3:
			if (c0 == CHAR_a)
			{
			  x = "and";
			  id = AND;
			  break;
			}
			else if (c0 == CHAR_f)
			{
			  x = "for";
			  id = FOR;
			  break;
			}
			else if (c0 == CHAR_n)
			{
			  if (s == "new") return NEW;
			  if (s == "nor") return NOR;
			  if (s == "not") return NOT;
			  break;
			}
			else if (c0 == CHAR_t)
			{
			  x = "try";
			  id = TRY;
			  break;
			}
			else if (c0 == CHAR_v)
			{
			  x = "var";
			  id = VAR;
			  break;
			}
			else if (c0 == CHAR_x)
			{
			  x = "xor";
			  id = XOR;
			  break;
			}
			else if (c0 == CHAR_g)
			{
			  x = "get";
			  id = GET;
			  break;
			}
			else if (c0 == CHAR_s)
			{
			  x = "set";
			  id = SET;
			  break;
			}
			else
			{
			  break;
			}
		  case 4:
			if (c0 == CHAR_c)
			{
			  x = "case";
			  id = CASE;
			  break;
			}
			else if (c0 == CHAR_e)
			{
			  x = "else";
			  id = ELSE;
			  break;
			}
			else if (c0 == CHAR_n)
			{
			  if (s == "null") return NULL;
			  if (s == "nand") return NAND;
			  break;
			}
			else if (c0 == CHAR_t)
			{
			  if (s == "true") return TRUE;
			  if (s == "this") return THIS;
			  break;
			}
			else if (c0 == CHAR_v)
			{
			  x = "void";
			  id = VOID;
			  break;
			}
			else if (c0 == CHAR_w)
			{
			  x = "with";
			  id = WITH;
			  break;
			}
			else
			{
			  break;
			}
		  case 5:
			var c2:int = s.charCodeAt(2);
			if (c2 == CHAR_a)
			{
			  x = "class";
			  id = CLASS;
			  break;
			}
			else if (c2 == CHAR_e)
			{
			  x = "break";
			  id = BREAK;
			  break;
			}
			else if (c2 == CHAR_i)
			{
			  x = "while";
			  id = WHILE;
			  break;
			}
			else if (c2 == CHAR_l)
			{
			  x = "false";
			  id = FALSE;
			  break;
			}
			else if (c2 == CHAR_r)
			{
			  x = "throw";
			  id = THROW;
			  break;
			}
			else if (c2 == CHAR_t)
			{
			  x = "catch";
			  id = CATCH;
			  break;
			}
			else
			{
			  break;
			}
		  case 6:
			var c5:int = s.charCodeAt(5);
			if (c5 == CHAR_e)
			{
			  x = "delete";
			  id = DELETE;
			  break;
			}
			else if (c5 == CHAR_n)
			{
			  x = "return";
			  id = RETURN;
			  break;
			}
			else if (c5 == CHAR_t)
			{
			  x = "import";
			  id = IMPORT;
			  break;
			}
			else if (c5 == CHAR_h)
			{
			  x = "switch";
			  id = SWITCH;
			  break;
			}
			else if (c5 == CHAR_f)
			{
			  x = "typeof";
			  id = TYPEOF;
			  break;
			}
			else if (c5 == CHAR_c)
			{
			  x = "static";
			  id = STATIC;
			  break;
			}
			else
			{
			  break;
			}
		  case 7:
			if (c1 == CHAR_e)
			{
			  x = "default";
			  id = DEFAULT;
			  break;
			}
			else if (c1 == CHAR_i)
			{
			  x = "finally";
			  id = FINALLY;
			  break;
			}
			else
			{
			  break;
			}
		  case 8:
			if (c0 == CHAR_c)
			{
			  x = "continue";
			  id = CONTINUE;
			  break;
			}
			else if (c0 == CHAR_f)
			{
			  x = "function";
			  id = FUNCTION;
			  break;
			}
			else
			{
			  break;
			}
		  case 10:
			if (s == "instanceof") return INSTANCEOF;
		}
		if (x != null && x != s) id = 0;
	  }
	  return id == 0 ? int(EOF) : id & 255;
	}

	private static function isKeyword(s:String):Boolean { return EOF != stringToKeyword(s); }

	public final function getOffset():int
	{
	  var n:int = sourceCursor - lineStart;
	  if (lineEndChar >= 0) n--;
	  return n;
	}

	public final function getString():String { return string; }

	public function isXMLAttribute():Boolean { return xmlIsAttribute; }

	public function ungetChar(c:int):void
	{
	  if (ungetCursor != 0 && ungetBuffer[ungetCursor - 1] == CHAR_NL) codeBug();
	  ungetBuffer[ungetCursor++] = c;
	}

	public function readPI():Boolean
	{
	  for (var c:int = getChar(); c != CHAR_EOF; c = getChar())
	  {
		addToString(c);
		if (c == CHAR_QUESTION && peekChar() == CHAR_GT)
		{
		  c = getChar();
		  addToString(c);
		  return true;
		}
	  }
	  stringBuffer.clear();
	  this.string = null;
	  reportError("msg.XML.bad.form");
	  return false;
	}

	private function readCDATA():Boolean
	{
	  for(var c:int = getChar(); c != CHAR_EOF; )
	  {
		addToString(c);
		if (c == CHAR_RBRACKET && peekChar() == CHAR_RBRACKET)
		{
		  c = getChar();
		  addToString(c);
		  if (peekChar() == CHAR_GT)
		  {
			c = getChar();
			addToString(c);
			return true;
		  }
		}
		else
		{
		  c = getChar();
		}
	  }
	  stringBuffer.clear();
	  this.string = null;
	  reportError("msg.XML.bad.form");
	  return false;
	}

	private function readEntity():Boolean
	{
	  var declTags:int = 1;
	  for (var c:int = getChar(); c != CHAR_EOF; c = getChar())
	  {
		addToString(c);
		switch( c)
		{
		  case CHAR_LT:
			declTags++;
			break;
		  case CHAR_GT:
			declTags--;
			if (declTags == 0) return true;
			break;
		}
	  }
	  stringBuffer.clear();
	  this.string = null;
	  reportError("msg.XML.bad.form");
	  return false;
	}

	public function skipLine():void
	{
	  for (var c:int = 0; (c = getChar()) != CHAR_EOF && c != CHAR_NL; )
	  { }
	  ungetChar(c);
	}

	public function readRegExp(startToken:int) : void
	{
	  var c:int = 0;
	  stringBuffer.clear();
	  if (startToken == ASSIGN_DIV) addToString(CHAR_EQUAL);
	  else if (startToken != DIV) codeBug();
	  while ((c = getChar()) != CHAR_SLASH)
	  {
		if (c == CHAR_NL || c == CHAR_EOF)
		{
		  ungetChar(c);
		  reportError("msg.unterminated.re.lit");
		}
		if (c == CHAR_BACKSLASH)
		{
		  addToString(c);
		  c = getChar();
		}
		addToString(c);
	  }
	  var reEnd:int = stringBuffer.length;
	  while (true)
	  {
		if (matchChar(CHAR_g))
		{
		  addToString(CHAR_g);
		  continue;
		}
		if (matchChar(CHAR_i))
		{
		  addToString(CHAR_i);
		  continue;
		}
		if (matchChar(CHAR_m))
		{
		  addToString(CHAR_m);
		  continue;
		}
		break;
	  }
	  if (isAlpha(peekChar())) reportError("msg.invalid.re.flag");
	  this.string = stringBuffer.substring(0, reEnd);
	  this.regExpFlags = stringBuffer.substr(reEnd, stringBuffer.length - reEnd);
	}

	public final function getLineno():int { return lineno; }

	public final function getLineFromNo(x:int):String
	{
	  var v:int = x - linenostart;
	  if (lines.length > v) return lines[v];
	  return sourceString.substring(lineStart, sourceCursor);
	}

	public function getNextXMLToken():int
	{
	  stringBuffer.clear();
	  var c:int = getChar();
	  while (true)
	  {
		if (c == CHAR_EOF)
		{
		  stringBuffer.clear();
		  this.string = null;
		  reportError("msg.XML.bad.form");
		  return ERROR;
		}
		if (xmlIsTagContent)
		{
		  switch (c)
		  {
			case CHAR_GT:
			  addToString(c);
			  xmlIsTagContent = false;
			  xmlIsAttribute = false;
			  break;
			case CHAR_SLASH:
			  addToString(c);
			  if (peekChar() == CHAR_GT)
			  {
				c = getChar();
				addToString(c);
				xmlIsTagContent = false;
				xmlOpenTagsCount--;
			  }
			  break;
			case CHAR_LBRACE:
			  ungetChar(c);
			  this.string = getStringFromBuffer();
			  return XML;
			case CHAR_QUOTE:
			case CHAR_DOUBLEQUOTE:
			  addToString(c);
			  if (!readQuotedString(c)) return ERROR;
			  break;
			case CHAR_EQUAL:
			  addToString(c);
			  xmlIsAttribute = true;
			  break;
			case CHAR_SPACE:
			case CHAR_TAB:
			case CHAR_CR:
			case CHAR_NL:
			  addToString(c);
			  break;
			default:
			  addToString(c);
			  xmlIsAttribute = false;
		  }
		  if (!xmlIsTagContent && xmlOpenTagsCount == 0) break;
		}
		else
		{
		  switch (c)
		  {
			case CHAR_LT:
			  addToString(c);
			  c = peekChar();
			  switch (c)
			  {
				case CHAR_BAN:
				  c = getChar();
				  addToString(c);
				  c = peekChar();
				  switch (c)
				  {
					case CHAR_DASH:
					  c = getChar();
					  addToString(c);
					  c = getChar();
					  if (c == CHAR_DASH)
					  {
						addToString(c);
						if (!readXmlComment()) return ERROR;
						break;
					  }
					  stringBuffer.clear();
					  this.string = null;
					  reportError("msg.XML.bad.form");
					  return ERROR;
					case CHAR_LBRACKET:
					  c = getChar();
					  addToString(c);
					  if (getChar() == CHAR_C && getChar() == CHAR_D && getChar() == CHAR_A && getChar() == CHAR_T && getChar() == CHAR_A && getChar() == CHAR_LBRACKET)
					  {
						addToString("CDATA[");
						if (!readCDATA()) return ERROR;
						break;
					  }
					  stringBuffer.clear();
					  this.string = null;
					  reportError("msg.XML.bad.form");
					  return ERROR;
					default:
					  if (!readEntity()) return ERROR;
					  break;
				  }
				  break;
				case CHAR_QUESTION:
				  c = getChar();
				  addToString(c);
				  if (!readPI()) return ERROR;
				  break;
				case CHAR_SLASH:
				  c = getChar();
				  addToString(c);
				  if (xmlOpenTagsCount == 0)
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
			  ungetChar(c);
			  this.string = getStringFromBuffer();
			  return XML;
			default:
			  addToString(c);
		  }
		}
		c = getChar();
	  }
	  this.string = getStringFromBuffer();
	  return XMLEND;
	}

	public function addToString(c:*):void
	{
	  if (c is String) stringBuffer.append(c);
	  else stringBuffer.append(String.fromCharCode(int(c)));
	}

	public function matchChar(...testArgs):Boolean
	{
	  var arr:Array = new Array();
	  var j:int, c:int;
	  var res:Boolean = true;
	  for (var i:int = 0; i < testArgs.length; i++)
	  {
		c = getChar();
		if (c == CHAR_EOF) break;
		arr.push(c);
		j = testArgs[i];
		if (j != c)
		{
		  res = false;
		  break;
		}
	  }
	  if (res) return true;
	  for each (c in arr)
	  {
		ungetChar(c);
	  }
	  return false;
	}

	public function getFirstXMLToken():int
	{
	  xmlOpenTagsCount = 0;
	  xmlIsAttribute = false;
	  xmlIsTagContent = false;
	  ungetChar(CHAR_LT);
	  return getNextXMLToken();
	}

	public final function getNumber():Number { return number; }

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
	  while (true)
	  {
		while (true)
		{
		  c = getChar();
		  if (c == CHAR_EOF) break;
		  if (c == CHAR_NL)
		  {
			dirtyLine = false;
			return EOL;
		  }
		  if (!isJSSpace(c))
		  {
			if (c != CHAR_DASH) dirtyLine = true;
			if (c == CHAR_AT) return XMLATTR;
			isUnicodeEscapeStart = false;
			if (c == CHAR_BACKSLASH)
			{
			  c = getChar();
			  if (c == CHAR_u)
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
			  if (identifierStart)
			  {
				stringBuffer.clear();
				addToString(c);
			  }
			}
			if (identifierStart)
			{
			  containsEscape = isUnicodeEscapeStart;
			  while (true)
			  {
				if (isUnicodeEscapeStart)
				{
				  escapeVal = 0;
				  i = 0;
				  while (i != 4)
				  {
					c = getChar();
					escapeVal = xDigitToInt(c, escapeVal);
					if (escapeVal < 0) break;
					i++;
				  }
				  if (escapeVal < 0) break;
				  addToString(escapeVal);
				  isUnicodeEscapeStart = false;
				}
				else
				{
				  c = getChar();
				  if (c == CHAR_BACKSLASH)
				  {
					c = getChar();
					if (c == CHAR_u)
					{
					  isUnicodeEscapeStart = true;
					  containsEscape = true;
					  continue;
					}
					reportError("msg.illegal.character");
					return ERROR;
				  }
				  if (c == CHAR_EOF || !isIdentifierPart(c))
				  {
					ungetChar(c);
					str = getStringFromBuffer();
					if (!containsEscape)
					{
					  result = stringToKeyword(str);
					  if (result != EOF)
					  {
						if (result != RESERVED) return result;
						reportWarning("msg.reserved.keyword", str);
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
			if (isDigit(c) || c == CHAR_DOT && isDigit(peekChar()))
			{
			  stringBuffer.clear();
			  base = 10;
			  if (c == CHAR_0)
			  {
				c = getChar();
				if (c == CHAR_x || c == CHAR_X)
				{
				  base = 16;
				  c = getChar();
				}
				else if (isDigit(c))
				{
				  base = 8;
				}
				else
				{
				  addToString(CHAR_0);
				}
			  }
			  if (base == 16)
			  {
				while (0 <= xDigitToInt(c, 0))
				{
				  addToString(c);
				  c = getChar();
				}
			  }
			  else
			  {
				while (CHAR_0 <= c && c <= CHAR_9)
				{
				  if (base == 8 && c >= CHAR_8)
				  {
					reportWarning("msg.bad.octal.literal", c == CHAR_8 ? "8": "9");
					base = 10;
				  }
				  addToString(c);
				  c = getChar();
				}
			  }
			  isInteger = true;
			  if (base == 10 && (c == CHAR_DOT || c == CHAR_e || c == CHAR_E))
			  {
				isInteger = false;
				if (c == CHAR_DOT)
				{
				  do
				  {
					addToString(c);
					c = getChar();
				  }
				  while (isDigit(c));
				}
				if (c == CHAR_e || c == CHAR_E)
				{
				  addToString(c);
				  c = getChar();
				  if (c == CHAR_PLUS || c == CHAR_DASH)
				  {
					addToString(c);
					c = getChar();
				  }
				  if (!isDigit(c))
				  {
					reportError("msg.missing.exponent");
					return ERROR;
				  }
				  do
				  {
					addToString(c);
					c = getChar();
				  }
				  while (isDigit(c));
				}
			  }
			  ungetChar(c);
			  numString = getStringFromBuffer();
			  if (base == 10 && !isInteger)
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
				dval = stringToNumber(numString, base);
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
				return !!matchChar(CHAR_COLON) ? int(COLONCOLON): int(COLON);
			  case CHAR_DOT:
				if (matchChar(CHAR_DOT,CHAR_DOT)) return DOTDOTDOT;
				if (matchChar(CHAR_DOT)) return DOTDOT;
				return !!matchChar(CHAR_LPAREN) ? int(DOTQUERY) : int(DOT);
			  case CHAR_PIPE:
				if (matchChar(CHAR_PIPE)) return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_OR) : int(OR);
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_BITOR) : int(BITOR);
			  case CHAR_CARET:
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_BITXOR) : int(BITXOR);
			  case CHAR_AMPERSAND:
				if (matchChar(CHAR_AMPERSAND)) return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_AND) : int(AND);
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_BITAND) : int(BITAND);
			  case CHAR_EQUAL:
				if (matchChar(CHAR_EQUAL)) return !!matchChar(CHAR_EQUAL) ? int(SHEQ) : int(EQ);
				return ASSIGN;
			  case CHAR_BAN:
				if (matchChar(CHAR_EQUAL)) return !!matchChar(CHAR_EQUAL) ? int(SHNE) : int(NE);
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
				if (matchChar(CHAR_LT)) return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_LSH) : int(LSH);
				return !!matchChar(CHAR_EQUAL) ? int(LE) : int(LT);
			  case CHAR_GT:
				if(matchChar(CHAR_GT))
				{
				  if (matchChar(CHAR_GT)) return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_URSH) : int(URSH);
				  return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_RSH) : int(RSH);
				}
				return !!matchChar(CHAR_EQUAL) ? int(GE) : int(GT);
			  case CHAR_STAR:
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_MUL) : int(MUL);
			  case CHAR_SLASH:
				if (matchChar(CHAR_SLASH))
				{
				  skipLine();
				  continue loop0;
				}
				if (matchChar(CHAR_STAR))
				{
				  lookForSlash = false;
				  while (true)
				  {
					c = getChar();
					if (c == CHAR_EOF) break;
					if (c == CHAR_STAR)
					{
					  lookForSlash = true;
					}
					else if (c == CHAR_SLASH)
					{
					  if (lookForSlash) continue loop0;
					}
					else
					{
					  lookForSlash = false;
					}
				  }
				  reportError("msg.unterminated.comment");
				  return ERROR;
				}
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_DIV) : int(DIV);
			  case CHAR_PERCENT:
				return !!matchChar(CHAR_EQUAL) ? int(ASSIGN_MOD) : int(MOD);
			  case CHAR_PLUS:
				if (matchChar(CHAR_EQUAL)) return ASSIGN_ADD;
				return !!matchChar(CHAR_PLUS) ? int(INC) : int(ADD);
			  case CHAR_DASH:
				if (matchChar(CHAR_EQUAL))
				{
				  c = ASSIGN_SUB;
				}
				else if (matchChar(CHAR_DASH))
				{
				  if (!dirtyLine)
				  {
					if (matchChar(CHAR_GT))
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

	private function readString(quoteChar:int):int
	{
	  var escapeVal:int = 0;
	  var escapeStart:int = 0;
	  var temp:String = null;
	  var i:int = 0;
	  var c1:int = 0;
	  var val:int = 0;
	  stringBuffer.clear();
	  var c:int = getChar();
	  loop0:
	  while (c != quoteChar)
	  {
		if (c == CHAR_NL || c == CHAR_EOF)
		{
		  ungetChar(c);
		  reportError("msg.unterminated.string.lit");
		  return ERROR;
		}
		if (c == CHAR_BACKSLASH)
		{
		  c = getChar();
		  switch (c)
		  {
			case CHAR_b:
			  c = CHAR_BACKSLASH;
			  break;
			case CHAR_f:
			  c = CHAR_FEED;
			  break;
			case CHAR_n:
			  c = CHAR_NL;
			  break;
			case CHAR_r:
			  c = CHAR_CR;
			  break;
			case CHAR_t:
			  c = CHAR_TAB;
			  break;
			case CHAR_v:
			  c = 11;
			  break;
			case CHAR_u:
			  escapeStart = stringBuffer.length;
			  temp = "u";
			  escapeVal = 0;
			  i = 0;
			  while (i != 4)
			  {
				c = getChar();
				escapeVal = xDigitToInt(c,escapeVal);
				if (escapeVal < 0)
				{
				  addToString(temp);
				  continue loop0;
				}
				temp = temp + String.fromCharCode(c);
				i++;
			  }
			  c = escapeVal;
			  break;
			case CHAR_x:
			  c = getChar();
			  escapeVal = xDigitToInt(c,0);
			  if (escapeVal < 0)
			  {
				addToString(CHAR_x);
				continue;
			  }
			  c1 = c;
			  c = getChar();
			  escapeVal = xDigitToInt(c,escapeVal);
			  if (escapeVal < 0)
			  {
				addToString(CHAR_x);
				addToString(c1);
				continue;
			  }
			  c = escapeVal;
			  break;
			case CHAR_NL:
			  c = getChar();
			  continue;
			default:
			  if (CHAR_0 <= c && c < CHAR_8)
			  {
				val = c - CHAR_0;
				c = getChar();
				if (CHAR_0 <= c && c < CHAR_8)
				{
				  val = 8 * val + c - CHAR_0;
				  c = getChar();
				  if (CHAR_0 <= c && c < CHAR_8 && val <= 37)
				  {
					val = 8 * val + c - CHAR_0;
					c = getChar();
				  }
				}
				ungetChar(c);
				c = val;
			  }
		  }
		}
		addToString(c);
		c = getChar();
	  }
	  this.string = getStringFromBuffer();
	  return STRING;
	}

	private function readQuotedString(quote:int):Boolean
	{
	  for (var c:int = getChar(); c != CHAR_EOF; c = getChar())
	  {
		addToString(c);
		if (c == quote) return true;
	  }
	  stringBuffer.clear();
	  this.string = null;
	  reportError("msg.XML.bad.form");
	  return false;
	}

	private function stringToNumber(numString:String, base:Number):Number
	{
	  var i:int = 0;
	  var result:Number = 0;
	  if (base == 10) return Number(numString);
	  if (base == 16)
	  {
		i = 0;
		while (i < numString.length)
		{
		  result = xDigitToInt(numString.charCodeAt(i), result);
		  i++;
		}
	  }
	  else if (base == 8)
	  {
		i = 0;
		while (i < numString.length)
		{
		  result = oDigitToInt(numString.charCodeAt(i), result);
		  i++;
		}
	  }
	  else
	  {
		Env.reportError("msg.bad.number.base",base);
	  }
	  return result;
	}

	public function peekChar():int
	{
	  var c:int = getChar();
	  ungetChar(c);
	  return c;
	}

	public function getChar():int
	{
	  var c:int = 0;
	  if (ungetCursor != 0) return ungetBuffer[--ungetCursor];
	  while (sourceCursor != sourceEnd)
	  {
		c = sourceString.charCodeAt(sourceCursor++);
		if (lineEndChar >= 0)
		{
		  if (lineEndChar == CHAR_CR && c == CHAR_NL)
		  {
			lineEndChar = CHAR_NL;
			continue;
		  }
		  lineEndChar = -1;
		  lines.push(sourceString.substring(lineStart,lineStart=sourceCursor-1));
		  lineno++;
		}
		if (c <= 127)
		{
		  if (c == CHAR_NL || c == CHAR_CR)
		  {
			lineEndChar = c;
			c = CHAR_NL;
		  }
		}
		else if (isJSLineTerminator(c))
		{
		  lineEndChar = c;
		  c = CHAR_NL;
		}
		return c;
	  }
	  hitEOF = true;
	  return CHAR_EOF;
	}

	public function getStringFromBuffer():String { return stringBuffer.toString(); }

	public final function getLine():String
	{
	  var lineEnd:int = 0;
	  var c:int = 0;
	  var lineLen:int = 0;
	  var i:int = 0;
	  if (sourceString != null)
	  {
		lineEnd = sourceCursor;
		if (lineEndChar >= 0)
		{
		  lineEnd--;
		}
		else
		{
		  while (lineEnd != sourceEnd)
		  {
			c = sourceString.charCodeAt(lineEnd);
			if (isJSLineTerminator(c)) break;
			lineEnd++;
		  }
		}
		return sourceString.substring(lineStart, lineEnd);
	  }
	  lineLen = sourceCursor - lineStart;
	  if (lineEndChar >= 0)
	  {
		lineLen--;
	  }
	  else
	  {
		while (true)
		{
		  i = lineStart + lineLen;
		  if (i == sourceEnd) break;
		  c = sourceString.charCodeAt(i);
		  if (isJSLineTerminator(c)) break;
		  lineLen++;
		}
	  }
	  return sourceString.substring(lineStart,lineLen);
	}

	public final function eof():Boolean { return hitEOF; }

	private function readXmlComment():Boolean
	{
	  for (var c:int = getChar(); c != CHAR_EOF; )
	  {
		addToString(c);
		if (c == CHAR_DASH && peekChar() == CHAR_DASH)
		{
		  c = getChar();
		  addToString(c);
		  if (peekChar() == CHAR_GT)
		  {
			c = getChar();
			addToString(c);
			return true;
		  }
		}
		else
		{
		  c = getChar();
		}
	  }
	  stringBuffer.clear();
	  this.string = null;
	  reportError("msg.XML.bad.form");
	  return false;
	}
  }
}