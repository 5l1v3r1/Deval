package r1.deval.rt
{
   import flash.system.ApplicationDomain;
   
   import r1.deval.parser.TokenStream;
   public class ImportStmt extends EmptyStmt
   {
       
      
      private var classes:Array;

      public function ImportStmt(param1:Array, param2:int,param3:TokenStream)
      {
         super(param2,param3);
         this.classes = param1;
      }

      override public function exec() : void
      {
         var cls:String = null;
         var x:* = undefined;
         var ad:ApplicationDomain = ApplicationDomain.currentDomain;
         var p:Array;
         for each(cls in classes)
         {
            try
            {
               p=cls.split(/\./g);
               if (p[p.length-1]=="*") {
                  p.pop();
                  Env.importStar(p.join("."));
                  continue;
               }
               x = ad.getDefinition(cls);
               if(x != null)
               {
                  if (x is Class)
                  {
                     Env.importClass(x as Class,cls);
                  }
                  else if (x is Function)
                  {
                     Env.importFunction(cls,x as Function);
                  }
               }
               else
               {
                  throw new RTError("msg.rt.no.class");
               }
            }
            catch(e:Error)
            {
               throw new RTError("msg.rt.no.class");
            }
         }
      }
   }
}
