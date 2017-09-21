# D.eval source code(modified)

## Changes

* Added support for importing package level functions like flash.net.navigateToURL
* Changed error message to print stack trace instead of just the error
* Fixed the problem with variable scopes so that statements like `var x:int;` can be used to define variables in the local scope
* Added support for `...rest` parameter in function definition
* Added support for try...catch...finally statements
* Added the option to use import statements like `import flash.net.*;`
