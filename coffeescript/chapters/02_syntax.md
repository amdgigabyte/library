<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#CoffeeScript 语法

首先,在我们开始本章学习前,我还是要重申一下,CoffeeScript 和 JavaScript在语法上面是相对独立的，CoffeeScript不是JavaScript的子集, 因此一些JavaScript的关键字，如`function`、`var` 不是合法的,直接使用会导致抛错.如果你是在写CoffeeScript,那么它就应该是纯CoffeeScript,而不应该是两种语言的混合体. 

为什么CoffeeScript不是一个子集合？一个很好的事实是在CoffeeScript中空格是有重要含义的. And, once that decision's been made, the team decided you might as well go the full hog and deprecate some JavaScript keywords and features in the name of simplicity and in an effort to reduce many commonly occurring bugs. 为了达到简洁并能够减少一些常见bug的出现，CoffeeScript的维护团队决定摒弃一些JavaScript的关键字和特性.（这句话感觉有些问题还）

让我兴奋的是，通过元排序的方式, CoffeeScript的编译器本身就是由CoffeeScript编写的. 这仿佛解决了一个鸡生蛋还是蛋生鸡的问题.

好, 我们首先来说明一下最基本的问题. 在CoffeeScript中没有分号,分号都会在编译后被自动的加上.分号的可以引起很多奇怪的[行为](http://bonsaiden.github.com/JavaScript-Garden/#core.semicolon)，这些旺旺会在JavaScript社区引起了很多的争论.不管怎么说, CoffeeScript 在它的语法中去掉了分号而是在需要时再加上从而解决了这一系列问题.

CoffeeScript的注释是和Ruby的注释形式一样的, 在行首加上一个井号即可. 

    # A comment
    
多行的注释同样支持, 并且这些注释也会被带到编译后的js中. 注释的代码被三个井号的对所包围.

<span class="csscript"></span>

    ###
      A multiline comment, perhaps a LICENSE.
    ###

正如我之前提到的, 空白在 CoffeeScript 中作用显著. 实际运用中, 你可以用一个制表符来代替块结构 (`{}`) . 这一点沿袭了Python的语法, 这样能够确保你的代码是以一种优良的方式被格式化显示, 否则，代码可能不能被编译!

##变量 和 作用域

CoffeeScript 修正了 JavaScript 中最容易产生问题的一点, 全局变量. 在 JavaScript 中, 在申明变量是往往很容易遗漏 `var` 从而产生了全局变量. CoffeeScript 去掉了全局变量从而解决了这一问题. 事实上, CoffeeScript 通过一个匿名函数来包裹脚本, 保证了本地作用域, 并且会默认对所有的变量申明都加上 `var`. 举个例子, 就像这样一个 CoffeeScript 中的变量赋值:

<span class="csscript"></span>

    myVariable = "test"

注意到代码部分右上角的深灰色按钮了么？ 点击它, 代码会在CoffeeScript和编译后的JavaScript之间切换. 这些都是在页面中实时生成的, 你可以放心这些编译结果都是正确的. 

可以看到, 赋值的变量作用域保持在了本地, 这也杜绝了产生全局变量的可能. CoffeeScript 还做了更进一步处理, 使得要覆盖高级别的变量变得更为困难. 这很好的避免了一些常见的JavaScript开发的错误=.

然而, 有时候创建全局变量是很有用的. 这时你可以在全局对象(如浏览器中的`window`)上面挂载变量或者使用以下的形式:

<span class="csscript"></span>

    exports = this
    exports.MyVariable = "foo-bar"
    
在底层的上下文中，`this` 指向了全局对象, 通过创建一个叫 `exports` 的本地变量，你可以很明确的告诉别人脚本中的哪些变量是全局创建的. 并且, 他为 CommonJS 模块铺平了道路, 关于CommonJS我们将在后面讲述. 

##函数

CoffeeScript 相当累赘的 `function` 语句, 而用一个 `->` 来代替它. 函数申明可以是一行或者是多行. 最后的一个表达式会作为函数的返回结果. 换句话说, 你根本不需要 `return` 语句除非你是想在函数内更早的地方返回函数. 
    
了解了这些, 我们来看一个例子:
    
<span class="csscript"></span>

    func = -> "bar"

你可以发现在编译的结果中, `->` 被转化成了 `function` 语句, 并且字符串 `"bar"` 被自动作为结果返回了.

之前已经提到, 我们肯定会用到多行的函数申明, 只要我们正确地缩进.

<span class="csscript"></span>

    func = ->
      # An extra line
      "bar"
      
###函数参数

那么如何指定函数的参数呢? CoffeeScript 允许你在函数的箭头前面指定函数的参数.

<span class="csscript"></span>

    times = (a, b) -> a * b

CoffeeScript 还支持参数的默认值, 例子:

<span class="csscript"></span>

    times = (a = 1, b = 2) -> a * b
    
你也可以使用省略号 `...` 来允许接受多个参数 

<span class="csscript"></span>

    sum = (nums...) -> 
      result = 0
      nums.forEach (n) -> result += n
      result

在上面的例子中, `nums` 作为一个包含所有参数的参数数组传递给函数. 它不是一个 `arguments` 对象, 而是一个真正的数组, 因此当你要操作它时, 你不需要 `Array.prototype.splice` 或是 `jQuery.makeArray()` 多做一次处理. 

<span class="csscript"></span>

    trigger = (events...) ->
      events.splice(1, 0, this)
      this.constructor.trigger.apply(events)

###函数调用

在JavaScript中通过`()`, `apply()` 或者 `call()`可以调用函数. 而在CoffeeScript中, 则类似 Ruby, CoffeeScript 中如果函数传递了至少一个参数,那么他就会执行.

<span class="csscript"></span>

    a = "Howdy!"
    
    alert a
    # Equivalent to:
    alert(a)

    alert inspect a
    # Equivalent to:
    alert(inspect(a))
    
虽然括号在调用是可选的, 但我还是强烈建议加上，这样可以明显的区分哪些是函数以及他们的参数. 在最后的这个例子中, 对于函数 `inspect`, 我建议至少要在 `inspect` 外面包上括号.

<span class="csscript"></span>

    alert inspect(a)

如果在调用时你不传递任何的参数, CoffeeScript将没有办法区分你是要立即调用这个函数还是说把它作为一个变量. 在这方面, CoffeeScript的行为与 Ruby 就不一样了, Ruby总是会调用函数的引用, 而这更像是 Python 的语法. 这样子做确保了在 CoffeeScript 程序中不会轻易产生错误, 因此当你需要调用一个函数而不打算传参给它的时候记得要保留括号.

###函数上下文

上下文的变化在JavaScript中是很频繁的一件事情, 尤其是在事件回调的时候,因此COffeeScript提供了一些辅助功能特性来解决这类问题. 一个特性是`->` 的变种 `=>`

使用 `=>` 代替 `->` 可以保证函数的上下文会始终指向本地的上下文. 例如:

<span class="csscript"></span>

    this.clickHandler = -> alert "clicked"
    element.addEventListener "click", (e) => this.clickHandler(e)

你需要这么做的原因是,`addEventListener()` 的回调是在 `element` 的上下文中执行的, 即 `this` 指向 `element` . 如果你要保持 `this` 始终等于本地上下文, 并省略类似 `self = this` 这样的步骤, `=>` 正好满足你的需求. 

这种绑定的思想借鉴自jQuery的 [`proxy()`](http://api.jquery.com/jQuery.proxy/) 以及 [ES5's](https://developer.mozilla.org/en/JavaScript/Reference/Global_Objects/Function/bind) `bind()` 函数. 

##对象字面量 & 数组定义

在JavaScript中，可以通过一对包裹key/value的大括号来申明对象字面量. 然而, 正如对函数声明的改进, CoffeeScript 把大括号作为了可选的. 事实上, 你甚至可以使用缩进和换行的方式来替代逗号分隔.  

<span class="csscript"></span>

    object1 = {one: 1, two: 2}

    # Without braces
    object2 = one: 1, two: 2
    
    # Using new lines instead of commas
    object3 = 
      one: 1
      two: 2
    
    User.create(name: "John Smith")

类似地, 数组的逗号也可以用空格来替代, 不过中括号 (`[]`) 还是要保留的.

<span class="csscript"></span>

    array1 = [1, 2, 3]

    array2 = [
      1
      2
      3
    ]

    array3 = [1,2,3,]
    
从上面的例子你可以看到, CoffeeScript 会去掉 `array3`的最后一个逗号, 这也是经常会引起跨浏览器问题的一个原因. 

##流控制

在流控制语句中, CoffeeScript 把括号作为了可选, 但还是保留了`if` 和 `else`关键字.

<span class="csscript"></span>

    if true == true
      "We're ok"
      
    if true != true then "Panic"
    
    # Equivalent to:
    #  (1 > 0) ? "Ok" : "Y2K!"
    if 1 > 0 then "Ok" else "Y2K!"
    
从上面你可以发现, 如果 `if` 语句是单行的, 你还需要加上一个 `then` 关键字, 这样CoffeeScript可以知道语句块从何处开始. 要指出的是条件操作符 (`?:`) 并不被CoffeeScrit支持, 你可以使用单行 `if/else` 代替.

CoffeeScript 还在`if`语句中引入了一个Ruby的语法特性.

<span class="csscript"></span>

    alert "It's cold!" if heat < 5

除了使用`!`来表示非, 你还可以使用`not` 关键字. 这也在某种程度上面增加了程序的可读性.

<span class="csscript"></span>

    if not true then "Panic"
    
在上面的例子中, 我们还可以使用 CoffeeScript的 `unless` 语句, 他的逻辑与 `if` 正好相反.

<span class="csscript"></span>

    unless true
      "Panic"

类似 `not`, CoffeeScript 还加上了 `is` 语句, 它等同于 `===`.

<span class="csscript"></span>

    if true is 1
      "Type coercion fail!"
      
此外, 如果要替代 `is not`, 你还可以使用 `isnt`.

    if true isnt true
      alert "Opposite day!"

你可能已经注意到上面的例子中, CoffeeScript 把 `==` 操作符转化为 `===` 同样把 `!=` 转化为 `!==`. 这是我个人最喜欢也是最简单的语言特性之一. 为什么要这么做呢? 老实说 JavaScript 的类型转换有点古怪, 要对比不同的变量必须要先经过类型转换, 这就可能会引起一些奇怪的问题或是bug. 这一块在第7章会有重点讨论.
    
##字符串插值

CoffeeScript 把 Ruby 风格的字符串插值带到了 JavaScript中. 在双引号中可以包含 `#{}` 标签, 里面可以包含一些表达式的值被插入到字符串中. 

<span class="csscript"></span>

    favourite_color = "Blue. No, yel..."
    question = "Bridgekeeper: What... is your favourite color?
                Galahad: #{favourite_color}
                Bridgekeeper: Wrong!
                "

从上面的例子中你可以看出, 即使不加 `+` 号, 多行文本也是支持的.

##循环 和 Comprehensions（内含？）

JavaScript中的数组的迭代使用了一套非常古老的语法, 这让人联想到了C语言而不是一门面向对象的语言. ES5引入了 `forEach()` 函数以改变这一现状,但是对于每次的迭代依旧需要一次函数调用,这也导致了执行速度的降低. 针对这一点, CoffeeScript 通过一种美妙的语法做了对应的处理:

<span class="csscript"></span>

    for name in ["Roger", "Roderick", "Brian"]
      alert "Release #{name}"
      
如果你要得到当前的循环index, 只需要再多传递一个参数:
      
<span class="csscript"></span>

    for name, i in ["Roger the pickpocket", "Roderick the robber"]
      alert "#{i} - Release #{name}"

你也可以使用后缀的形式在一行内做循环. 

<span class="csscript"></span>

    release prisoner for prisoner in ["Roger", "Roderick", "Brian"]
    
如果你熟悉Python的语法, 你可以过滤这些结果:

<span class="csscript"></span>

    prisoners = ["Roger", "Roderick", "Brian"]
    release prisoner for prisoner in prisoners when prisoner[0] is "R" 

你也可以利用自己遍历对象属性的知识来遍历对象, 遍历时要把`in` 换成`of`.

<span class="csscript"></span>

    names = sam: seaborn, donna: moss
    alert("#{first} #{last}") for first, last of names

CoffeeScript提供的唯一一个低级别的循环是 `while` 循环.这和JavaScript中的很相似.不过在CoffeeScript中while多提供了一个返回值, 包含了一个结果的数组.这就类似于`Array.prototype.map()`函数的功能.

<span class="csscript"></span>

    num = 6
    minstrel = while num -= 1
      num + " Brave Sir Robin ran away"

##数组

CoffeeScript 在处理数组切割时借鉴了Ruby使用区间的思想. 一个区间的创建需要两个数值, 分别代表区间的初始位置和最终位置, 他们被 `..` 或是 `...`所分隔. 如果一个区间没有任何的前缀, CoffeeScript会把它扩充成一个数组.

<span class="csscript"></span>

    range = [1..5]
    
然而,如果区间指定后立即被赋予一个变量, CoffeeScript会使用`slice()` 方法对数组进行转换.
    
<span class="csscript"></span>

    firstTwo = ["one", "two", "three"][0..1]
    
在上面的例子中, 通过区间返回了一个新的数组,它包含了原数组的前两个元素. 你也可以利用这种语法来用另一个数组替换当前数组的一部分.

<span class="csscript"></span>

    numbers = [0..9]
    numbers[3..5] = [-3, -4, -5]

灵活的是,JavaScript允许你使用`slice`方法来切割字符串, 因此你可以使用字符串的区间来返回一个子字符串.
    
<span class="csscript"></span>

    my = "my string"[0..2]

在JavaScript中要检查一个值是否存在于一个数组总是一件麻烦事,我想部分原因是 `indexOf()` 在全浏览器中的并不是支持的很完美(我想说的是IE).
CoffeeScript通过 `in` 运算符解决了这一问题.以下是例子.

<span class="csscript"></span>

    words = ["rattled", "roudy", "rebbles", "ranks"]
    alert "Stop wagging me" if "ranks" in words 

##别名 & “存在”操作符

CoffeeScript 的语法中包含了一些实用的别名,他们节省了你的输入. 其中一个是 `@`, 他表示的是 `this`.

<span class="csscript"></span>

    @saviour = true
    
另一个是 `::`, 他是 `prototype` 的别名

<span class="csscript"></span>

    User::first = -> @records[0]

在JavaScript通过 `if` 来检查 `null` 是很普遍的事情, 但是空字符串和 0 也会被转换成`false`, 这使得检查往往出现一些疏漏. CoffeeScript 的"存在"操作符 `?` 只会在一个变量是`null` 或者是`undefined` 返回true, 这有点类似于 Ruby的 `nil`. 

<span class="csscript"></span>

    praise if brian?
    
你也可以用它来替代 `||` 操作符:

<span class="csscript"></span>

    velocity = southern ? 40
    
如果你是要在获取属性之前做一个 `null` 的检查. 你可以把"存在"操作符放在属性的访问之前. 这有点类似于Active Support的[`try`](http://guides.rubyonrails.org/active_support_core_extensions.html#try) 方法.

<span class="csscript"></span>

    blackKnight.getLegs()?.kick()
    
类似的你可以把`?`放在括号的前面来检查一个属性是否是一个方法并且可被调用.如果这个属性不存在或者并非是一个方法,那么他将不会被执行.
Similarly you can check that a property is actually a function, and callable, by placing the existential operator right before the parens. If the property doesn't exist, or isn't a function, it simply won't get called. 

<span class="csscript"></span>

    blackKnight.getLegs().kick?()
