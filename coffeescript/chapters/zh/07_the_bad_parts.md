<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#糟粕部分

JavaScript的特性很古怪, 你在了解你要遵循的部分的同时,还要避免容易产生问题的另一部分. 正如孙子所说:"知己知彼", 我们本章正是要讨论这些, 发现JavaScript黑暗的那一部分,并揭示这些隐含的问题.从而让你成为一个让人信任的开发工程师.

正如我在介绍中说过的,CoffeeScript的优势不仅仅在于它的语法, 同时它也修复了很多JavaScript的问题.然而,由于CoffeeScript的语句是直接被转换成JavaScript的, 而不是经过虚拟机或者编译器, CoffeeScript并不能作为挽救JavaScript所有问题的一颗银弹, 你还是有很多问题要注意.

那么首先, 我们先来看看这门语言解决了哪些问题.

##一个JavaScript的子集

CoffeeScript的语法是覆盖了JavaScript的一个子集, 即*Good Parts*(精粹部分), 因此, 要做修复的部分就少了很多.我们以`with`语句为例. 这个语句长期以来就被认为是"有害的",而避免使用. 而实际`with`的初衷是在查找对象的属性是提供一个捷径. 举例来说, 原始的代码如下:

    dataObj.users.alex.email = "info@eribium.org";

使用`with`,就是这样:    

    with(dataObj.users.alex) {
      email = "info@eribium.org";
    }

先抛开我们不该创建一个层级如此之深的对象不说, 这个语法本身是相当简单清晰的. 除了一个问题 - `with`的使用对于JavaScript翻译器来说是困惑的. 他并不确定你在`with`的上下文中会做什么, 并且会强制这个特殊的对象在所有的名称查找中首先被查找.

这非常的影响性能,并且意味着解释器会关闭所有的JIT优化项. 并且`with`语句不能被类似[uglify-js](https://github.com/mishoo/UglifyJS)的工具压缩. 这样一来, 他们也就在将来的JavaScript版本中被废弃了. 考虑所有的一切,避免使用 `with` 会更好一些, 而在CoffeeScript中, 从语法上面更进一步地防止了对这些的使用. 换句话说, 在CoffeeScript中使用`with`语句会抛错误.

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

JavaScript在源码中没有强制要求使用分号, 因此使用时你可以省略他们. 但是, JavaScript编译器还是需要分号的, 解析器在遇到由于缺少分号而解析错误时,就会自动的填入分号. 换句话说, 解析器会尝试评估没有分号的语句, 如果执行失败, 解析器就会加上分号重新执行一遍.

不幸的是, 这个方式有一个巨大的问题, 甚至会改变你的代码的本意.看看下面的例子, 看着似乎是正确的JavaScript.

    function() {}
    (window.options || {}).property
    
错了, 至少在解释器加上分号之后, 它产生了一个语法错误. 在括号运算优先的情况下, 解释器并不会加上分号, 最终的代码会被转化成一行:

    function() {}(window.options || {}).property

现在你明白这个问题了吧, 为什么解释器会产生这样的错. 当你在写JavaScript的时候, 你应该一直记得在语句后面加上分号.幸好CoffeeScript的语法中没有分号,也就不会有这样的麻烦. 分号只是在CoffeeScript编译成JavaScript的时候才被自动加上.

##保留字

大多数JavaScript中的保留字都是为未来版本的JavaScript而保留,例如`const`,`enum`和`class`.如果在JavaScript程序中使用他们会出现不可预期的结果;有些浏览器可能会正常处理,但是有些浏览器可能不会.CoffeeScript会监测你是否是在使用保留字, 并在必要时做转义, 从而避免了这一问题的发生.

举个例子, 我们把`class`作为一个对象的属性, CoffeeScript的代码应该如下:

<span class="csscript"></span>

    myObj = {
      delete: "I am a keyword!"
    }
    myObj.class = ->
    
CoffeeScript的解释器会发现你在使用保留字, 从而给他们多加上了引号:

    var myObj;
    myObj = {
      "delete": "I am a keyword!"
    };
    myObj["class"] = function() {};
    
##相同值比较

JavaScript中的值比较总会让人困惑, 并且它往往是一些bug的来源. 下面的例子来自[JavaScript秘密花园-等值部分](http://bonsaiden.github.com/JavaScript-Garden/#types.equality), 深入的阐述了这一问题.

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

问题的源头主要是等值比较时的强制的自动类型转换. 我相信你也一定认为这是很含糊的, 并会引发预计不到的结果和bug.

问题的解决方法是使用全等运算符`===`. 它会像普通的等价运算符一样, 但是不会做类型的强制转换. 我们建议总是使用全等运算符, 并在必要时显式的转换类型.

CoffeeScript把所有的弱类型比较都变成了强类型的比较, 换句话说, 所有的`==` 都会被转化为`===`. 在CoffeeScript中你不能使用弱类型比较, 并且在比较值之前, 你应该对比较对象做明确的类型转换.

尽管如此, 这并不意味着你在CoffeeScript中可以忽略累赘强制转换, 尤其是在流控制中判断真值的时候. 空字符串,`null`,`undefined`和数字`0`都会被转换为`false`.

<span class="csscript"></span>

    alert("Empty Array")  unless [].length
    alert("Empty String") unless ""
    alert("Number 0")     unless 0

如果你明确只要检查一个值是否是`null`或者`undefined`, 那么你就要使用CoffeeScript的存在操作符:

<span class="csscript"></span>

    alert("This is not called") unless ""?
    
这里的`alert()`不会被执行, 因为空字符串不等于`null`.

##函数定义

函数在JavaScript真是够奇特的, 函数的定义可以放在函数调用之后. 下面的例子, 尽管`wem`在调用后才被定义, 但这也完全可以正常运行

    wem();
    function wem() {}

这都是因为函数作用域的问题. 函数在程序执行前会被预载, 并在它们被定义的作用域中都可以调用, 即便是在源码的函数定义之前也可以被调用. 问题在于, 预载的行为在不同的浏览器中是有区别的; 举例来说:
    
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
    
在例如Firefox的一些浏览器中`declaration()`会返回`"first"`, 但在Chrome中, 则会返回`"second"`, 即便`else`看着怎么也不会执行.

如果你想知道更多函数函数声明的知识, 你应该看看[Juriy Zaytsev的手册](http://kangax.github.com/nfe/), 里面说的很深入. 我想说的是, 函数的定义真的是非常模糊的一行为, 并会经常引发一些问题.综合这一切考虑, 使用函数表达式来定义函数是最好的方式.

    var wem = function(){};
    wem();

CoffeeScript中完全去掉了函数的定义,而只保留了函数表达式.

##数字属性查找

JavaScript解析器的一大缺陷在于数字上的*点*, 会被翻译为一个浮点数, 而不会被认为是属性查找.例如, 下面的JavaScript会产生错误:

    5.toString();

JavaScript会在点之后寻找一个数字, 但是却出现了`toString()`于是就引起了`Unexpected token`的错误.解决办法是,用括号把数字包起来,或者多加一个点. 

    (5).toString();
    5..toString();

幸运的是, CoffeeScript解析器能够自动判断这一场景, 并自动的加上双点.

#未修正的部分

虽然CoffeeScript已经解决了很多JavaScript的设计缺陷, 但还有很多没有得到修复. 正如我之前提及的, CoffeeScript通过设计来严格限制静态分析的过程, 但由于性能的原因没有做运行期的检查.CoffeeScript 使用的是简单的源到源的编译器, 这样编译的结果就是一句CoffeeScript会编译成一句对应的JavaScript.此外CoffeeScript对于JavaScript的关键字的使用, 例如`typeof`, 也没有做任何抽象, 这样一些JavaScript的设计缺陷同样存在于CoffeeScript中.

在上一章节, 我们介绍了CoffeeScript对JavaScript部分设计缺陷的修补, 现在我们再来看看CoffeeScript所不能修复的那些缺陷.

##使用Eval

虽然CoffeeScript去掉了JavaScript的一些问题, 还是遗留了一些引起问题的特性, 你要了解他们的不足所在. 一个典型的例子是, `eval`函数.虽然毫无疑问, 它有它的用途, 你还是要知道它的缺点, 并尽可能的避免这些缺点. `eval`
函数可以在本地作用域中执行一个字符串的JavaScript代码. `setTimeout()`和`setInterval()` 同样也具有这样的特性.

然而, 就像`with`一样,`eval`也把编译器抛在了一边,并且它也存在着严重的性能问题.由于编译器在运行期之外并不知道`eval`里面到底会执行什么, `eval`并不能做任何的优化,例如内联.另一方面是安全的问题.如果你输入了一个恶意字串, `eval`很容易使你的代码受到引起注入的攻击.99%的时候, 当你觉得需要使用`eval`, 其实会有更好的选择(例如方括号).

<span class="csscript"></span>

    # Don't do this
    model = eval(modelName)
    
    # Use square brackets instead
    model = window[modelName]
    
##使用typeof

`typeof`操作符或许是JavaScript设计上的最大的缺陷, 简单说来它是完全的残缺不齐的. 事实上, 它的用处只有一个, 就是检查一个值是否是`undefined`.

<span class="csscript"></span>

    typeof undefinedVar is "undefined"

对于其他所有的类型监测, `typeof`的检查都很不靠谱, 所返回的结果有时也会根据浏览器以及实例初始化的方式而变化. 当然,CoffeeScript在这方面也改变不了什么, 因为语言只是做了静态的分析,而没有做运行期的检测. 因此你只能靠自己了.

为了描述这个问题, 这里我们援引了[JavaScript秘密花园](http://bonsaiden.github.com/JavaScript-Garden/)的一张表. 里面罗列了`typeof`关键词的检查的大多数情况.
  
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
    
你可以看到, 使用引号定义的字符串和`String`类定义的字符串返回的结果是不一样的. 按理说,`typeof`应该返回的是`"string"`, 但是后者却返回了`"object"`.

那么我们在JavaScript中应该如何检查类型呢? 幸好在JavaScript中我们可以使用`Object.prototype.toString()`来解决这个问题. 如果我们在普通的对象上下文中运行这个函数, 它就能返回正确的类型. 我们要做的是封装这个函数的返回值, 我们要返回`typeof`应该返回的值.这里是jQuery的`$.type`的实现的例子:

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
    
如果你要检查一个变量是否被定义, 你依然应该使用`typeof`否则你可能会得到`ReferenceError`.

<span class="csscript"></span>

    if typeof aVar isnt "undefined"
      objectType = type(aVar)
      
或者更简洁一些,我们使用存在操作符:

    objectType = type(aVar?)

作为类型检查的一个替代方案, 你可以使用[鸭子类型](http://zh.wikipedia.org/wiki/Duck_typing) 以及CoffeeScript的存在操作符来解决对象类型判断的需求.例如, 我们把一个值推入数组. 我们可以说, 如果这个'类数组'的对象具有`push()`方法, 那我们就认为它是一个数组:

<span class="csscript"></span>

    anArray?.push? aValue

如果`anArray`是一个对象而非一个数组, 那么由于存在操作符的原因, `push()`永远不会被调用. 

##使用instanceof

JavaScript的`instanceof`关键字的功能残缺程度和`typeof`有的一拼. 原则上说, `instanceof`应该对比的是两个对象的构造器, 并返回一个布尔值以表示其中一个是另一个的实例. 然而, 实际使用中, `instanceof`只能对比用户创建的对象. 对于JavaScript内建的类型则没有什么实际作用.

<span class="csscript"></span>

    new String("foo") instanceof String # true
    "foo" instanceof String             # false
    
并且, `instanceof` 在对于浏览器中来自不同frame框的对象时也没有作用. 事实上, `instanceof` 只对创建的对象返回正确的值, 例如CoffeeScript的类.

<span class="csscript"></span>

    class Parent
    class Child extends Parent
    
    child = new Child
    child instanceof Child  # true
    child instanceof Parent # true
    
确保你只针对你自己创建的对象使用`instanceof`, 或者更好的是, 干脆不用它.

##使用delete

`delete`关键字只在删除对象的属性时是安全的.

<span class="csscript"></span>

    anObject = {one: 1, two: 2}
    delete anObject.one
    anObject.hasOwnProperty("one") # false

其他的时候, 例如删除变量或函数则是无效的.

<span class="csscript"></span>

    aVar = 1
    delete aVar
    typeof Var # "integer"

这真是很奇怪的一种行为!如果你要删除一个变量的引用, 你只能对它赋值`null`.

<span class="csscript"></span>

    aVar = 1
    aVar = null

##使用parseInt

如果你在JavaScript的`parseInt()`函数时只传递一个字符串而没有同时指定转换的位数, 那么很可能会产生预期不到的结果.

    # Returns 8, not 10!
    parseInt('010') is 8

保证传位数可以保证函数正常的工作:

    # Use base 10 for the correct result
    parseInt('010', 10) is 10

这在CoffeeScript中也没有做什么特殊处理, 你还是要记得在使用`parseInt()`时多加一个位数的参数.
    
##严格模式

严格模式是ECMAScript 5的一个新特性, 它允许你在一个*严格*的上下文中执行你的JavaScript程序或者函数.这个严格的上下文会比普通的上下文抛出更多的异常和警告, 并开发者偏离最佳实践、编写未优化的代码以及出现常见错误的时侯给与一些提示. 换句话说, 严格模式可以减少bug的数量,增加安全性,并提升性能以消除一些难用的语言特性.有什么理由不喜欢它呢？

严格模式现在呗一下的浏览器支持:

* Chrome >= 13.0
* Safari >= 5.0
* Opera >= 12.0
* Firefox >= 4.0
* IE >= 10.0

并且严格模式是完全向前兼容旧浏览器的. 使用严格模式的程序不管是在严格模式还是在正常模式下面都可以正常的运行.

###严格模式的变化

严格模式涉及到的JavaScript语法的变化如下:

* 属性重复或者函数参数重名会产生错误
* 错误的使用`delete`操作符会产生错误
* 使用`arguments.caller`和`arguments.callee`会产生错误(主要由于性能的原因)
* 使用`with`操作符会导致语法错误
* 某些变量例如`undefined`不能被写入
* 加入了新的保留字, 例如 `implements`, `interface`,`let`,`package`,`private`,`protected`,`public`,`static` 和`yield`

并且, 严格模式也带来运行期行为的变化:

* 全局变量是显示声明的(必须使用`var`), 全局的`this`值是`undefined`
* `eval` 无法在本地上下文中引进新的变量
* 函数必须在使用之前被申明(之前函数可以在[任何地方](http://whereswalden.com/2011/01/24/new-es5-strict-mode-requirement-function-statements-not-at-top-level-of-a-program-or-function-are-prohibited/)定义)
* `arguments` 是不能被改写的

CoffeeScript已经遵循了大多数的严格模式, 例如定义变量时总是使用var,不过在你的CoffeeScript程序中开启严格模式还是会很有用.事实上,CoffeeScript已经多考虑了一步,并在[未来版本](https://github.com/jashkenas/coffee-script/issues/1547)中会在编译时对一个程序进行严格模式的检查.

###使用严格模式

要开启严格模式, 你只需在你的脚本或函数开始时加入下面这句:

<span class="csscript"></span>
    
    ->
      "use strict"
    
      # ... your code ...
      
就是这个`'use strict'`字符串. 没有比这更简单的了,并且这是完全向前兼容的. 让我们实际使用一下严格模式. 下面的这个函数会在严格模式下产生一个语法错误,但在普通模式下面运行正常:

<span class="csscript"></span>

    do ->
      "use strict"
      console.log(arguments.callee)
      
严格模式中禁止你使用`arguments.caller` 以及 `arguments.callee`因为它们可能会带来性能问题, 严格模式会在它们被使用时抛出语法错误.

你可能注意到在使用严格模式时还有一个特别问题, 即使用`this`创建全局变量. 下面的例子中会在严格模式中产生一个`TypeError`, 而在普通模式中则能正常的创建一个全局变量:

<span class="csscript"></span>

    do ->
      "use strict"
      class @Spine
      
区别的原因在于严格模式中`this`被赋予了`undefined`, 而通常情况它会指向`window`对象.解决办法是把全局的变量显式的放到`window`对象上面.

<span class="csscript"></span>

    do ->
      "use strict"
      class window.Spine
      
虽然我推荐使用严格模式, 但是值得一提的是, 严格模式并不会开启任何在JavaScript尚未支持的新特性, 并且严格模式会在运行期由于虚拟机要做更多的检查而减慢你的代码执行. 所以你可以在开发阶段使用严格模式, 而在部署阶段去掉.

##JavaScript Lint

[JavaScript Lint](http://www.javascriptlint.com/) 是一个 JavaScript 代码质量工具, 将你的代码通过它来检查是提升代码质量的很好的方式,甚至是最佳实践.这个项目是基于一个类似的叫做[JSLint](http://www.jslint.com)的工具.可以看到JSLint站点上有一个它检查范围的[列表](http://www.jslint.com/lint.html), 包括 全局变量, 丢失分号以及弱类型的对比.

好消息是CoffeeScript已经对它的输出都做了全部的校验, 因此由CoffeeScript生成的JavaScript是已经经过JavaScript校验的.事实上, `coffee`命令行已经支持一个`--lint` 选项:

    coffee --lint index.coffee
      index.coffee:	0 error(s), 0 warning(s)
