<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#CoffeeScript常用编程模式

每一种语言都有自己的惯用语法和编程的模式, CoffeeScript也不例外. 这一章就会涉及这些内容, 并且会对比JavaScript和CoffeeScript之间的区别，以便你能对CoffeeScript有更好的理解.

##遍历

在JavaScript中遍历一个数组的每一项, 我们可以使用新增加的 [`forEach()`](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/array/foreach) 函数, 或者是用一个 C 风格的 `for` 循环. 如果你计划使用一些最新的JavaScript特性，我建议你在页面中引入 [shim](https://github.com/kriskowal/es5-shim) 来支持旧的浏览器.
    
    for (var i=0; i < array.length; i++)
      myFunction(array[i]);
      
    array.forEach(function(item, i){
      myFunction(item)
    });

尽管 `forEach()` 在语法上面更加的简介和可读, 但是它也受限于它的通过回调来执行的缺陷, 相比 `for` 循环就要慢许多. 让我们来看看在CoffeeScript里面是怎么样的.

<span class="csscript"></span>
      
    myFunction(item) for item in array
    
这样的语法更加可读，并且更加简洁， 我想你也会这么认为，并且所有的这一切都是在后台被编译为 `for` 循环. 换句话说 CoffeeScript 的语法提供了 `forEach()` 般的表现力, 并且解决了速度和低浏览器模拟的问题. 

##图

和 `forEach()` 类似, ES5 同样提供了一个原生的[`map()`](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Array/map)函数来代替 `for` 循环 . 不幸的是它的情况和 `forEach()` 类似, 因为调用方式的问题，它的速度也打了折扣.

    var result = []
    for (var i=0; i < array.length; i++)
      result.push(array[i].name)

    var result = array.map(function(item, i){
      return item.name;
    });

As we covered in the syntax chapter, CoffeeScript's comprehensions can be used to get the same behavior as `map()`. Notice we're surrounding the comprehension with parens, which is **absolutely critical** in ensuring the comprehension returns what you'd expect, the mapped array. 

我们之前的语法部分介绍了, CoffeeScript的语句同样可以构造出类似 `map()` 的行为. 要注意的是我们在语句外面包了一层括号, 这非常**关键**,它确保语句返回的是我们想要的键值化数组. 

<span class="csscript"></span>

    result = (item.name for item in array)

##筛选

ES5 有一个功能函数 [`filter()`](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/array/filter) 用来筛选数组:
    
    var result = []
    for (var i=0; i < array.length; i++)
      if (array[i].name == "test")
        result.push(array[i])

    result = array.filter(function(item, i){
      return item.name == "test"
    });

CoffeeScript的基础语法则提供了 `when` 通过比较来进行数组条目的筛选. 这同样会生成一个 `for` 循环. 整个执行的过程会在一个匿名函数中进行，以避免作用域泄漏以及变量冲突. 

<span class="csscript"></span>

    result = (item for item in array when item.name is "test")

别忘了加上括号, 否则 `result` 的值会是最后一个被筛选出来的条目. 
CoffeeScript的语法非常的灵活, 下面的这个例子很好的展示了CoffeeScript强大的筛选功能.
<span class="csscript"></span>

    passed = []
    failed = []
    (if score > 60 then passed else failed).push score for score in [49, 58, 76, 82, 88, 90]
    
    # Or
    passed = (score for score in scores when score > 60)
    
如果这样理解过于麻烦, 你可以把他们分成多行.

<span class="csscript"></span>

    passed = []
    failed = []
    for score in [49, 58, 76, 82, 88, 90]
      (if score > 60 then passed else failed).push score

##包含

我们常常会使用`indexOf()`方法来判断一个值是不是属于一个数组, 但由于IE还没有支持, 我们还是需要做一些兼容性的处理.

    var included = (array.indexOf("test") != -1)

许多Python开发者可能已经发现, 在CoffeeScript中使用了 `in` 来完美替代这个处理过程.

<span class="csscript"></span>
    
    included = "test" in array

在实际实现中, CoffeeScript使用了 `Array.prototype.indexOf()` 来检测一个值是否存在于一个数组中, 如果不支持这个, 就做降级处理.不幸的是, 这样做意味着`in`的语法不能对字符串无效.所以对于字串我们还得用回`indexOf()`, 并同时判断结果是否为-1:

<span class="csscript"></span>

    included = "a long test string".indexOf("test") isnt -1

或者我们改进一下, 使用位运算符这样就避免了和 `-1` 做对比.

<span class="csscript"></span>
    
    string   = "a long test string"
    included = !!~ string.indexOf "test"
    
##属性遍历

要在JavaScript中遍历一堆属性的话, 你需要使用`in`操作符, 举个例子:

    var object = {one: 1, two: 2}
    for(var key in object) alert(key + " = " + object[key])
    
然而,正如你之前看到的,CoffeeScript已经把 `in` 关键字运用在了数组中. 这样一来,我们在CoffeeScript中使用 `of` 这个关键字来代替

<span class="csscript"></span>
    
    object = {one: 1, two: 2}
    alert("#{key} = #{value}") for key, value of object
    
As you can see, you can specify variables for both the property name, and its value; rather convenient.
你可以看到,你可以同时获取属性名和属性值,相当的方便.
    
##最大值/最小值

这个技术或许在CoffeeScript中并不算特别, 但是我想说说它的特别之处. `Math.max` 和 `Math.min` 可以接受多个参数,你可以使用 `...` 来传递一个数组给它们, 从而得到这个数组中的最大值和最小值.

<span class="csscript"></span>

    Math.max [14, 35, -7, 46, 98]... # 98
    Math.min [14, 35, -7, 46, 98]... # -7
    
由于浏览器对函数参数的数量的限制问题,这个技巧在传递一个很大的数组的时候是没有什么意义的.
    
##多个参数

在`Math.max`的例子中, 我们使用了 `...` 来构建一个数组并把它作为多个参数传递给 `max`.
实际实现中, CoffeeScript通过`apply()`调用的方式来进行函数的调用, 以保证数组作为一个参数传递给`max`, 我们可以换种方式来运用这一特性, 譬如说,proxying function calls:

<span class="csscript"></span>

    Log =
      log: ->
        console?.log(arguments...)

或者你可一在参数被传入之前做一下修改.

<span class="csscript"></span>

    Log =
      logPrefix: "(App)"

      log: (args...) ->
        args.unshift(@logPrefix) if @logPrefix
        console?.log(args...)
        
虽然你会感觉有些担心，但是CoffeeScript是会自动设置函数的执行上下文为函数触发时所属的对象.上面的例子中,上下文应该是 `console`. 如果你要设定特定的上下文,那么你就要手动的使用`apply()`的调用方式.

##与/非

CoffeeScript 风格指南推荐用 `or` 代替 `||`, 用 `and` 代替 `&&`. 我说说为什么, 因为前者可读性更佳. 除此之外, 这两种方式的结果是一致的.  

这种更接近英语的风格还有,如使用`is` 优于 `==` , `isnt` 优于 `!=`.
    
<span class="csscript"></span>

    string = "migrating coconuts"
    string == string # true
    string is string # true

CoffeeScript还添加了一个很棒的'或等于'的判断符,Ruby的程序员可能能很快认出来这和`||=`很相近.

<span class="csscript"></span>

    hash or= {}
    
如果hash等于`false`, 那么它就会被赋一个空对象的值. 需要注意的是, 这个表达式也会把`0`,`""`,`null`认成非值.如果你并不想这样,那就使用CoffeeScript的“存在”操作符, 它可以保证只在hash为`undefined`或是`null`的时候才被赋值:

<span class="csscript"></span>

    hash ?= {}

##析构赋值

析构赋值可以被用来获取数组或者对象的深度属性. 

<span class="csscript"></span>

    someObject = { a: 'value for a', b: 'value for b' }
    { a, b } = someObject
    console.log "a is '#{a}', b is '#{b}'"
    
这在Node应用中引用模块的时候非常的有用:

<span class="csscript"></span>

    {join, resolve} = require('path')
    
    join('/Users', 'Alex')

##外部库

使用外部库和调用CoffeeScript的库的函数的方式基本一样, 因为最终所有的东西都会编译为JavaScript. 由于Jquery本身API设计包含了很多的回调, 在CoffeeScript中使用[jQuery](http://jquery.com)会显得很顺其自然。 

<span class="csscript"></span>

    # Use local alias
    $ = jQuery

    $ ->
      # DOMContentLoaded
      $(".el").click ->
        alert("Clicked!")
    
由于所有的CoffeeScript产物都会被一个匿名函数所包裹, 我们可以设定一个本地变量 `$` 指向 `jQuery`.这可以保证即便jQuery冲突模式没有被开启,并且`$`被别的框架重写,我们的脚本依旧能工作正常.

##私有变量

`do` 关键字可以让我们在CoffeeScript中立即执行函数, 这是一种很好的封装作用域保护变量的方式.下面的例子中, 我们在一个使用`do`立即执行的匿名函数中定义了一个`classToType`变量.这个匿名函数返回了另一个匿名函数, 它会返回`type`的最终值.由于`classToType`被定义的上下文没有任何引用,外部作用域就无法访问它.

<span class="csscript"></span>

    # Execute function immediately
    type = do ->
      classToType = {}
      for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
        classToType["[object " + name + "]"] = name.toLowerCase()
      
      # Return a function
      (obj) ->
        strType = Object::toString.call(obj)
        classToType[strType] or "object"

换句话说, `classToType` 的作用域是完全私有的, 并且不再会被匿名函数外部所引用.这种方式可以很好的封装作用域和隐藏变量.