package r1.deval.rt
{
  public class Accessor extends ObjectExprBase implements ISettable
  {
	internal var host:IExpr, index:*;

	private static var xmlMethods:Object;

	private static var topLevelTypes:Object = {
	  "Array":function(...args):Array
	  {
		var x:* = undefined;
		var ret:* = [];
		for each(x in args)
		{
		  ret.push(x);
		}
		return ret;
	  },
	  "Boolean":function(o:*):Boolean
	  {
		return Boolean(o);
	  },
	  "int":function(o:*):int
	  {
		return int(o);
	  },
	  "Number":function(o:*):Number
	  {
		return Number(o);
	  },
	  "Object":function(o:*):Object
	  {
		return o;
	  },
	  "String":function(o:*):String
	  {
		return String(o);
	  },
	  "uint":function(o:*):uint
	  {
		return uint(o);
	  },
	  "XML":function(o:*):XML
	  {
		return XML(o);
	  },
	  "XMLList":function(o:*):XMLList
	  {
		return XMLList(o);
	  }
	};

	public function Accessor(_host:IExpr, _idx:*)
	{
	  super();
	  this.host = _host;
	  this.index = _idx;
	}

	private static function _initXmlMethods():void
	{
	  xmlMethods = {
		"hasOwnProperty":function(x:Object, p:String):Boolean
		{
		  return x.hasOwnProperty(p);
		},
		"isPrototypeOf":function(x:Object, theClass:Object):Boolean
		{
		  return x.isPrototypeOf(theClass);
		},
		"toString":function(x:Object):String
		{
		  return x.toString();
		},
		"valueOf":function(x:Object):XML
		{
		  return x.valueOf();
		},
		"propertyIsEnumerable":function(x:Object, p:String):Boolean
		{
		  return x.propertyIsEnumerable(p);
		},
		"setPropertyIsEnumerable":function(x:Object, name:String, isEnum:Boolean=true):void
		{
		  x.setPropertyIsEnumerable(name, isEnum);
		},
		"addNamespace":function(xml:XML, ns:Object):XML
		{
		  return xml.addNamespace(ns);
		},
		"appendChild":function(xml:XML, param2:Object):XML
		{
		  return xml.appendChild(param2);
		},
		"childIndex":function(xml:XML):int
		{
		  return xml.childIndex();
		},
		"inScopeNamespaces":function(xml:XML):Array
		{
		  return xml.inScopeNamespaces();
		},
		"insertChildAfter":function(xml:XML, child1:Object, child2:Object):*
		{
		  return xml.insertChildAfter(child1, child2);
		},
		"insertChildBefore":function(xml:XML, child1:Object, child2:Object):*
		{
		  return xml.insertChildBefore(child1, child2);
		},
		"localName":function(xml:XML):Object
		{
		  return xml.localName();
		},
		"name":function(xml:XML):Object
		{
		  return xml.name();
		},
		"namespace":function(xml:XML, prefix:String=null):*
		{
		  return xml.namespace(prefix);
		},
		"namespaceDeclarations":function(xml:XML):Array
		{
		  return xml.namespaceDeclarations();
		},
		"nodeKind":function(xml:XML):String
		{
		  return xml.nodeKind();
		},
		"prependChild":function(xml:XML, value:Object):XML
		{
		  return xml.prependChild(value);
		},
		"removeNamespace":function(xml:XML, ns:Namespace):XML
		{
		  return xml.removeNamespace(ns);
		},
		"replace":function(xml:XML, propName:Object, value:XML):XML
		{
		  return xml.replace(propName, value);
		},
		"setChildren":function(xml:XML, value:Object):XML
		{
		  return xml.setChildren(value);
		},
		"setLocalName":function(xml:XML, name:String):void
		{
			xml.setLocalName(name);
		},
		"setName":function(xml:XML, name:String):void
		{
			xml.setName(name);
		},
		"setNamespace":function(xml:XML, ns:Namespace):void
		{
			xml.setNamespace(ns);
		},
		"attribute":function(x:*, attributeName:*):XMLList
		{
		  if (x is XML) return (x as XML).attribute(attributeName);
		  return (x as XMLList).attribute(attributeName);
		},
		"attributes":function(x:*):XMLList
		{
		  if (x is XML) return (x as XML).attributes();
		  return (x as XMLList).attributes();
		},
		"child":function(x:*, propertyName:Object):XMLList
		{
		  if (x is XML) return (x as XML).child(propertyName);
		  return (x as XMLList).child(propertyName);
		},
		"children":function(x:*):XMLList
		{
		  if (x is XML) return (x as XML).children();
		  return (x as XMLList).children();
		},
		"comments":function(x:*):XMLList
		{
		  if (x is XML) return (x as XML).comments();
		  return (x as XMLList).comments();
		},
		"contains":function(x:*, param2:XML):Boolean
		{
		  if (x is XML) return (x as XML).contains(param2);
		  return (x as XMLList).contains(param2);
		},
		"copy":function(x:*):*
		{
		  if (x is XML) return (x as XML).copy();
		  return (x as XMLList).copy();
		},
		"descendants":function(x:*, name:Object="*"):XMLList
		{
		  if (x is XML) return (x as XML).descendants();
		  return (x as XMLList).descendants();
		},
		"elements":function(x:*, name:Object="*"):XMLList
		{
		  if (x is XML) return (x as XML).elements();
		  return (x as XMLList).elements();
		},
		"hasComplexContent":function(x:*):Boolean
		{
		  if (x is XML) return (x as XML).hasComplexContent();
		  return (x as XMLList).hasComplexContent();
		},
		"hasSimpleContent":function(x:*):Boolean
		{
		  if (x is XML) return (x as XML).hasSimpleContent();
		  return (x as XMLList).hasSimpleContent();
		},
		"length":function(x:*):int
		{
		  if (x is XML) return (x as XML).length();
		  return (x as XMLList).length();
		},
		"normalize":function(x:*):*
		{
		  if (x is XML) return (x as XML).normalize();
		  return (x as XMLList).normalize();
		},
		"parent":function(x:*):*
		{
		  if (x is XML) return (x as XML).parent();
		  return (x as XMLList).parent();
		},
		"processingInstructions":function(x:*, name:String="*"):XMLList
		{
		  if (x is XML) return (x as XML).processingInstructions(name);
		  return (x as XMLList).processingInstructions(name);
		},
		"text":function(x:*):XMLList
		{
		  if (x is XML) return (x as XML).text();
		  return (x as XMLList).text();
		},
		"toXMLString":function(x:*):String
		{
		  if (x is XML) return (x as XML).toXMLString();
		  return (x as XMLList).toXMLString();
		}
	  };
	}

	internal function resolveMethod(mthdInfo:Array):void
	{
	  var o:* = undefined;
	  var thisObj:* = undefined;
	  mthdInfo[0] = null;
	  var idx:Object = getIndex();
	  if (host != null)
	  {
		thisObj = host.getAny();
		if (thisObj == null) throw new RTError("msg.call.on.null");
		mthdInfo[0] = thisObj;
		if(thisObj is XML || thisObj is XMLList)
		{
		  mthdInfo[2] = true;
		  if (xmlMethods == null) _initXmlMethods();
		  o = xmlMethods[idx];
		}
		else
		{
		  o = thisObj[idx];
		}
	  }
	  else
	  {
		if(Env.isInDocQuery())
		{
		  if (xmlMethods == null) _initXmlMethods();
		  o = xmlMethods[idx] as Function;
		  if (o != null)
		  {
			mthdInfo[0] = Env.peekObject();
			mthdInfo[2] = true;
		  }
		}
		if (o == null) o = topLevelTypes[idx];
		if(o == null) o = Env.getProperty(idx);
	  }
	  if (o == null) throw new RTError("msg.rt.no.method");
	  mthdInfo[1] = o;
	}

	public function delProp():Boolean { return delete host.getAny()[getIndex()]; }

	override public function getAny():Object
	{
	  var o:Object = null;
	  var idx:Object = getIndex();
	  if (host == null) return Env.getProperty(idx);
	  o = host.getAny();
	  return o[idx];
	}

	internal function getIndexAsBoolean():Boolean { return index is IExpr ? Boolean(index.getBoolean()) : Boolean(Boolean(index)); }

	internal function getIndex():Object { return index is IExpr ? index.getAny() : index; }

	public function setValue(param1:Object):void
	{
	  var o:Object = null;
	  var idx:Object = getIndex();
	  if (host == null)
	  {
		Env.setProperty(idx,param1);
	  }
	  else
	  {
		o = host.getAny();
		if (o != null) o[idx] = param1;
		else throw new RTError("msg.rt.set.to.null");
	  }
	}
  }
}