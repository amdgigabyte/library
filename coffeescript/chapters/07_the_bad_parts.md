<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#糟粕部分

JavaScript的特性很奇特, 你在了解你要遵循的部分的同时,还要避免容易产生问题的另一部分. 正如孙子所说:"知己知彼", 我们本章正是要讨论这些, 发现JavaScript的黑暗的那一部分,并揭示这些隐含的问题.从而成为一个让人信任的开发工程师.

正如我在介绍中说过的,CoffeeScript的优势不仅仅在于它的语法, 同时它也修复了很多JavaScript的累赘部分.然而,由于CoffeeScript的语句是直接被转换成JavaScript的, 而不是经过虚拟机或者编译器, CoffeeScript并不能作为挽救JavaScript易出bug的一颗银弹, 并且你还是要注意很多问题.
there's still some issues you need to be aware about.

那么首先, 我们先来看看这门语言解决了哪些问题.

##一个JavaScript的子集

CoffeeScript的语法是覆盖了JavaScript的一个子集, 即*Good Parts*(精粹部分), 因此, 要做修复的部分就少了很多.我们以`with`语句为例. 这个语句长期以来就被认为是"有害的",而避免使用. 而实际`with`的初衷是在查找对象的属性是提供一个捷径. 举例来说, 原始的代码如下:

    dataObj.users.alex.email = "info@eribium.org";

使用`with`,就是这样:    

    with(dataObj.users.alex) {
      email = "info@eribium.org";
    }

先抛开我们不该创建一个层级如此之深的对象不说, 这个语法本身是相当简单清晰的. 除了一个问题 - `with`的使用对于JavaScript翻译器来说是困惑的. 他并不确定你在`with`的上下文中会做什么, 并且会强制这个特殊的对象在所有的名称查找中首先被查找.

这非常的影响性能,并且意味着解释器会关闭所有的JIT优化项目. 并且`with`语句不能被类似[uglify-js](https://github.com/mishoo/UglifyJS)的工具压缩. 这样一来, 他们也就在将来的JavaScript版本中被废弃了. 考虑所有的一切,避免使用 `with` 会更好一些, 而在CoffeeScript中, 从语法上面更进一步地防止了对这些的使用. 换句话说, 在CoffeeScript中使用`with`语句会抛错误.

##全局变量

通常来说,JavaScript程序都是运行在全局作用域中的, 并且默认情况下, 任何的变量都是创建在全局作用域中的. 如果你要创建一个本地作用域的变量, JavaScript需要你显式的使用`var`关键字声明变量.

    usersCount = 1;        // Global
    var groupsCount = 2;   // Global
                          
    (function(){              
      pagesCount = 3;      // Global
      var postsCount = 4;  // Local
    })()

这似乎很没有必要这样, 因为大多数时候的你都是在创建本地变量而非全局变量, 因此, 为什么不让创建本地变量是默认的? 因为JavaScript的语法本身, 开发者们都要在变量初始化时在声明语句之前加上`var`, 否则就有可能产生变量冲突或者变量覆盖等奇怪的问题.

幸运的是,CoffeeScript完全消除全局变量的声明来避免各种问题. 换句话说, `var`关键词是CoffeeScript的保留字, 如果使用的话就会引发语法错误.本地变量是被默认创建的, 如果不显式的把变量作为`window`的属性, 要创建全局变量是非常困难的.

让我们来看一个CoffeeScript变量赋值的例子:

<span class="csscript"></span>

    outerScope = true
    do ->
      innerScope = true
      
会被编译成:

    var outerScope;
    outerScope = true;
    (function() {
      var innerScope;
      return innerScope = true;
    })();
    
注意CoffeeScript如何在他们被使用的上下文中自动(使用 `var`)初始化变量. 虽然要覆盖外部变量成为了不可能, 但你依然可以引用并获取它们. 你要注意的是, 如果你是在写一个深层嵌套的函数或类的时候, 你不能重用外部变量的名字. 举例来说, 这里我们在类函数中意外重写了`package`变量:

<span class="csscript"></span>

    package = require('./package')
    
    class Hem
      build: ->
        # Overwrites outer variable!
        package = @hemPackage.compile()
        
      hemPackage: ->
        package.create()
        
全局变量总会有需要使用的时候, 这时候你需要把这些变量设置为 `window` 的属性:

<span class="csscript"></span>

      class window.Asset
        constructor: ->

在全局变量的声明确定为显式的, 而不是隐式的之后, CoffeeScript排除了JavaScript程序中主要的一个bug来源.

##分号

JavaScript在源码中没有强制要求使用分号, 因此使用时你可以省略他们. 但是, JavaScript编译器还是需要分号的, 解析器在遇到由于缺少分号而解析错误时,就会自动的填入分号. 换句话说, 
JavaScript does not enforce the use of semicolons in source code, so it's possible to omit them. However, behind the scenes the JavaScript compiler still needs them, so the parser automatically inserts them whenever it encounters a parse error due to a missing semicolon. In other words, it'll try to evaluate a statement without semicolons and, if that fails, tries again using semicolons.

Unfortunately this is a tremendously bad idea, and can actually change the behavior of your code. Take the following example, seems valid JavaScript, right?

    function() {}
    (window.options || {}).property
    
Wrong, well at least according to the parser; it raises a syntax error. In case of a leading parenthesis, the parser will not insert a semicolon. The code gets transformed onto one line:

    function() {}(window.options || {}).property

Now you can see the issue, and why the parser is complaining. When you're writing JavaScript, you should always include semicolons after statements. Fortunately CoffeeScript gets round all this hassle by not having semicolons in its syntax. Rather the semicolons are inserted automatically (at the right places) when the CoffeeScript is compiled down to JavaScript.

##Reserved words

Certain keywords in JavaScript are reserved for future versions of JavaScript, such as `const`, `enum` and `class`. Using these as variable names in your JavaScript programs can unpredictable results; some browsers will cope with them just fine, and others will choke. CoffeeScript neatly sidesteps this issue, by detecting if you're using a reserved keyword, and escaping it if necessary.

For example, let's say you were to use the reserved keyword `class` as a property on an object, your CoffeeScript might look like this:

<span class="csscript"></span>

    myObj = {
      delete: "I am a keyword!"
    }
    myObj.class = ->
    

The CoffeeScript parser notices you're using a reserved keyword, and quotes it for you:

    var myObj;
    myObj = {
      "delete": "I am a keyword!"
    };
    myObj["class"] = function() {};
    
##Equality comparisons

The weak equality comparison in JavaScript has some confusing behavior and is often the source of confusing bugs. The example below is taken from [JavaScript Garden's equality section](http://bonsaiden.github.com/JavaScript-Garden/#types.equality) which delves into the issue in some depth. 

<span class="csscript"></span>

    ""           ==   "0"           // false
    0            ==   ""            // true
    0            ==   "0"           // true
    false        ==   "false"       // false
    false        ==   "0"           // true
    false        ==   undefined     // false
    false        ==   null          // false
    null         ==   undefined     // true
    " \t\r\n"    ==   0             // true

The reason behind this behavior is that the weak equality coerces types automatically. I'm sure you'll agree this is all pretty ambiguous, and can lead to unexpected results and bugs. 

The solution is to instead use the strict equality operator, which consists of three equal signs: `===`. It works exactly like the normal equality operator, but without any type coercion. It's recommended to always use the strict equality operator, and explicitly convert types if needs be.
    
CoffeeScript solves this by simply replacing all weak comparisons with strict ones, in other words converting all `==` comparators into `===`. You can't do a a weak equality comparison in CoffeeScript, and you should explicitly convert types before comparing them if necessary.

This doesn't mean you can ignore type coercion in CoffeeScript completely though, especially when it comes to checking the 'truthfulness' of variables during flow control. Blank strings, `null`, `undefined` and the number `0` are all coerced to `false`

<span class="csscript"></span>

    alert("Empty Array")  unless [].length
    alert("Empty String") unless ""
    alert("Number 0")     unless 0
    
If you want to explicitly check for `null` and `undefined`, then you can use CoffeeScript's existential operator:

<span class="csscript"></span>

    alert("This is not called") unless ""?
    
The `alert()` in the previous example won't be called, as the empty string isn't equal to `null`.

##Function definition

Oddly enough in JavaScript, functions can be defined after they're used. For example, the following runs absolutely fine, even though `wem` is defined after it's called:

    wem();
    function wem() {}

The is because of function scope. Functions get hoisted before the programs execution and as such are available everywhere in the scope they were defined in, even if called before the actual definition in the source. The trouble is, hoisting behavior differs between browser; for example:
    
    if (true) {
      function declaration() {
        return "first";
      }
    } else {
      function declaration() {
        return "second";
      }
    }
    declaration();
    
In some browsers such as Firefox, `declaration()` will return `"first"`, and in other browsers like Chrome it'll return `"second"`, even though it looks like the `else` statement is never run.

If you want to know more about declarative functions, then you should read [Juriy Zaytsev's guide](http://kangax.github.com/nfe/), where he delves into the specifics. Suffice to say, they have fairly ambiguous behavior, and can lead to problems later down the road. All things considered, It's best to steer clear of them by using function expressions instead:

    var wem = function(){};
    wem();

CoffeeScript's approach to this is to remove declarative functions entirely, using only function expressions. 

##Number property lookups

A flaw in JavaScript's parser means that the *dot notation* on numbers is interpreted as a floating point literal, rather than a property lookup. For example, the following JavaScript will cause a syntax error:

    5.toString();
    
JavaScript's parser is looking for another Number after the dot, and so raises an `Unexpected token` error when it encounters `toString()`. The solution to this is to either use parenthesis, or add an additional dot.
    
    (5).toString();
    5..toString();
    
Fortunately CoffeeScript's parsers is clever enough to deal with this issue by using double dot notations automatically (as in the example above) whenever you access properties on Numbers.

#The un-fixed parts

Whilst CoffeeScript goes some length to solving some of JavaScript's design flaws, it can only go so far. As I mentioned previously, CoffeeScript's strictly limited to static analysis by design, and doesn't do any runtime checking for performance reasons. CoffeeScript uses a straight source-to-source compiler, the idea being that every CoffeeScript statement results in a equivalent JavaScript statement. CoffeeScript doesn't provide an abstraction over any of JavaScript's keywords, such as `typeof`, and as such some design flaws in JavaScript's design also apply to CoffeeScript.

In the previous sections we covered some design flaws in JavaScript that CoffeeScript fixes. Now let's talk about some of JavaScript's flaws that CoffeeScript can't fix.

##Using eval

Whilst CoffeeScript removes some of JavaScript's foibles, other features are a necessary evil, you just need to be aware of their shortcomings. A case in point, is the `eval()` function. Whilst undoubtedly it has its uses, you should know about its drawbacks, and avoid it if possible. The `eval()` function will execute a string of JavaScript code in the local scope, and functions like `setTimeout()` and `setInterval()` can also both take a string as their first argument to be evaluated. 

However, like `with`, `eval()` throws the compiler off track, and is a major performance hog. As the compiler has no idea what's inside until runtime, it can't perform any optimizations like inlining. Another concern is with security. If you give it dirty input, `eval` can easily open up your code for injection attacks. 99% of the time when you're using `eval`, there are better & safer alternatives (such as square brackets).

<span class="csscript"></span>

    # Don't do this
    model = eval(modelName)
    
    # Use square brackets instead
    model = window[modelName]
    
##Using typeof

The `typeof` operator is probably the biggest design flaw of JavaScript, simply because it's basically completely broken. In fact, it really has only one use, checking to see if a value is `undefined`.

<span class="csscript"></span>

    typeof undefinedVar is "undefined"

For all other types of type checking, `typeof` fails rather miserably, returning inconsistent results depending on the browser and how instances were instantiated. This isn't something that CoffeeScript can help you either, since the language uses static analysis and has no runtime type checking. You're on your own here.

To illustrate the problem, here's a table taken from [JavaScript Garden](http://bonsaiden.github.com/JavaScript-Garden/) which shows some of the major inconstancies in the keyword's type checking. 
  
    Value               Class      Type
    -------------------------------------
    "foo"               String     string
    new String("foo")   String     object
    1.2                 Number     number
    new Number(1.2)     Number     object
    true                Boolean    boolean
    new Boolean(true)   Boolean    object
    new Date()          Date       object
    new Error()         Error      object
    [1,2,3]             Array      object
    new Array(1, 2, 3)  Array      object
    new Function("")    Function   function
    /abc/g              RegExp     object
    new RegExp("meow")  RegExp     object
    {}                  Object     object
    new Object()        Object     object
    
As you can see, depending on if you define a string with quotes or with the `String` class affects the result of `typeof`. Logically `typeof` should return `"string"` for both checks, but for the latter it returns `"object"`. Unfortunately the inconstancies only get worse from there. 

So what can we use for type checking in JavaScript? Well, luckily `Object.prototype.toString()` comes to the rescue here. If we invoke that function in the context of a particular object, it'll return the correct type. All we need to do is massage the string it returns, so we end up with the sort of string `typeof` should be returning. Here's an example implementation ported from jQuery's `$.type`:

<span class="csscript"></span>

    type = do ->
      classToType = {}
      for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
        classToType["[object " + name + "]"] = name.toLowerCase()
      
      (obj) ->
        strType = Object::toString.call(obj)
        classToType[strType] or "object"
    
    # Returns the sort of types we'd expect:
    type("")         # "string"
    type(new String) # "string"
    type([])         # "array"
    type(/\d/)       # "regexp"
    type(new Date)   # "date"
    type(true)       # "boolean"
    type(null)       # "null"
    type({})         # "object"
    
If you're checking to see if an variable has been defined, you'll still need to use `typeof` otherwise you'll get a `ReferenceError`.

<span class="csscript"></span>

    if typeof aVar isnt "undefined"
      objectType = type(aVar)
      
Or more succinctly with the existential operator:

    objectType = type(aVar?)
    
As an alternative to type checking, you can often use duck typing and the CoffeeScript existential operator together to eliminating the need to resolve an object's type. For example, let's say we're pushing a value onto an array. We could say that, as long as the 'array like' object implements `push()`, we should treat it like an array:

<span class="csscript"></span>

    anArray?.push? aValue
    
If `anArray` is an object other than an array than the existential operator will ensure that `push()` is never called.
    
##Using instanceof

JavaScript's `instanceof` keyword is nearly as broken as `typeof`. Ideally `instanceof` would compare the constructor of two object, returning a boolean if one was an instance of the other. However, in reality `instanceof` only works when comparing custom made objects. When it comes to comparing built-in types, it's as useless as `typeof`. 

<span class="csscript"></span>

    new String("foo") instanceof String # true
    "foo" instanceof String             # false
    
Additionally, `instanceof` also doesn't work when comparing object from different frames in the browser. In fact, `instanceof` only returns a correct result for custom made objects, such as CoffeeScript classes.

<span class="csscript"></span>

    class Parent
    class Child extends Parent
    
    child = new Child
    child instanceof Child  # true
    child instanceof Parent # true
    
Make sure you only use it for your own objects or, even better, stick clear of it.

##Using delete

The `delete` keyword can only safely be used for removing properties inside objects. 

<span class="csscript"></span>

    anObject = {one: 1, two: 2}
    delete anObject.one
    anObject.hasOwnProperty("one") # false

Any other use, such as deleting variables or function's won't work.

<span class="csscript"></span>

    aVar = 1
    delete aVar
    typeof Var # "integer"

It's rather peculiar behavior, but there you have it. If you want to remove a reference to a variable, just assign it to `null` instead.

<span class="csscript"></span>

    aVar = 1
    aVar = null

##Using parseInt

JavaScript's `parseInt()` function can return unexpected results if you pass a string to it without informing it of the proper base. For example:

    # Returns 8, not 10!
    parseInt('010') is 8
    
Always pass a base to the function to make it work correctly:

    # Use base 10 for the correct result
    parseInt('010', 10) is 10

This isn't something CoffeeScript can do for you; you'll just have to remember to always specify a base when using `parseInt()`.
    
##Strict mode

Strict mode is a new feature of ECMAScript 5 that allows you to run a JavaScript program or function in a *strict* context. This strict context throws more exceptions and warnings than the normal context, giving developers some indication when they're straying from best practices, writing un-optimizable code or making common mistakes. In other words, strict mode reduces bugs, increases security, improves performance and eliminates some difficult to use language features. What's not to like?

Strict mode is currently supported in the following browsers:

* Chrome >= 13.0
* Safari >= 5.0
* Opera >= 12.0
* Firefox >= 4.0
* IE >= 10.0

Having said that, strict mode is completely backwards compatible with older browsers. Programs using it should run fine in either a strict or normal context. 

###Strict mode changes

Most of the changes strict mode introduces pertain to JavaScript's syntax:

* Errors on duplicate property and function argument names
* Errors on incorrect use of the `delete` operator
* Access to `arguments.caller` & `arguments.callee` throws an error (for performance reasons)
* Using the `with` operator will raise a syntax error
* Certain variables such as `undefined` are no longer writeable 
* Introduces additional reserved keywords, such as `implements`, `interface`, `let`, `package`, `private`, `protected`, `public`, `static`, and `yield`

However, strict mode also changes some runtime behavior:

* Global variables are explicit (`var` always required). The global value of `this` is `undefined`.
* `eval` can't introduce new variables into the local context
* Function statements have to be defined before they're used (previously functions could be [defined anywhere](http://whereswalden.com/2011/01/24/new-es5-strict-mode-requirement-function-statements-not-at-top-level-of-a-program-or-function-are-prohibited/)).
* `arguments` is immutable

CoffeeScript already abides by a lot of strict mode's requirements, such as always using `var` when defining variables, but it's still very useful to enable strict mode in your CoffeeScript programs. Indeed, CoffeeScript is taking this a step further and in [future versions](https://github.com/jashkenas/coffee-script/issues/1547) will check a program's compliance to strict mode at compile time.

###Strict mode usage

All you need to do to enable strict checking is start your script or function with the following string:

<span class="csscript"></span>
    
    ->
      "use strict"
    
      # ... your code ...
      
That's it, just the `'use strict'` string. Couldn't be simpler and it's completely backwards compatible. Let's take a look at strict mode in action. The following function will raise a syntax error in strict mode, but run fine in the usual mode:

<span class="csscript"></span>

    do ->
      "use strict"
      console.log(arguments.callee)
      
Strict mode has removed access to `arguments.caller` & `arguments.callee` as they're major performance hogs, and is now throwing syntax errors whenever they're used.

There's a particular gotcha you should look out for when using strict mode, namely creating global variables with `this`. The following example will throw a `TypeError` in strict mode, but run fine in a normal context, creating a global variable:

<span class="csscript"></span>

    do ->
      "use strict"
      class @Spine
      
The reason behind this disparity is that in strict mode `this` is `undefined`, whereas normally it refers to the `window` object. The solution to this is to explicitly set global variables on the `window` object.

<span class="csscript"></span>

    do ->
      "use strict"
      class window.Spine
      
Whilst I recommend enabling strict mode, but it's worth noting that strict mode doesn't enable any new features that aren't ready possible in JavaScript, and will actually slow down your code a bit by having the VM do more checks at runtime. You may want to develop with strict mode, and deploy to production without it.

##JavaScript Lint

[JavaScript Lint](http://www.javascriptlint.com/) is a JavaScript code quality tool, and running your programs through it is a great way of improving code quality and best practices. The project was based on a similar tool called [JSLint](http://www.jslint.com). Check out JSLint's site for a [great list](http://www.jslint.com/lint.html) of issues that it checks for, including global variables, missing semicolons and weak equality comparisons.

The good news is that CoffeeScript already 'lints' all of its output, so CoffeeScript generated JavaScript is already JavaScript Lint compatible. In fact, the `coffee` tool has support for a `--lint` option:

    coffee --lint index.coffee
      index.coffee:	0 error(s), 0 warning(s)
