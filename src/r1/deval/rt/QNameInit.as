package r1.deval.rt
{
   class QNameInit extends ObjectExprBase
   {
       
      
      var ns:IExpr;
      
      var name:IExpr;
      
      function QNameInit(param1:IExpr, param2:IExpr)
      {
         super();
         this.ns = param1;
         this.name = param2;
      }
      
      override public function getAny() : Object
      {
         return new QName(ns.getAny() as Namespace,name.getString());
      }
   }
}
