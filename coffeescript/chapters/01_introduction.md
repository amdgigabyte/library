<div class="back"><a href="index.html">&laquo; 回到章节列表</a></div>

#神马是CoffeeScript?

[CoffeeScript](http://coffeescript.org) 是一门可以被编译成JavaScript的小型语言. 它借鉴了Ruby和Python的语法, 并借鉴了它们的一些特性. 本书致力于帮你学习CoffeeScript, 理解他的最佳实践并能够制作优质的客户端程序. 这本书很短小,只有五章, 但这也正好映衬了CoffeeScript这门短小的语言. 

本书是完全开源的, 由 [Alex MacCaw](http://alexmaccaw.co.uk) (or [@maccman](http://twitter.com/maccman)) 编写并得到了 [David Griffiths](https://github.com/dxgriffiths), [Satoshi Murakami](http://github.com/satyr)和 [Jeremy Ashkenas](https://github.com/jashkenas)的支持.

如果你有建议或者发现书写错误, 别犹豫，在本书的[GitHub page](https://github.com/arcturo/library)发起一个issue. 读者们可以也会对[JavaScript Web Applications by O'Reilly](http://oreilly.com/catalog/9781449307530/)这本书比较感兴趣, 这是我写的一本介绍JavaScript富应用和客户端状态管理的书.

那我们现在就开始吧; 为什么写CoffeeScript会优于写纯JavaScript? 首先, 你可一些更少的代码 - CoffeeScript语法非常的精简明了, 并且把空格也当作了语法的一部分. 从我自己的经验来说，它相比纯JavaScript至少减少了三分之一到一半的代码. 并且, CoffeeScript拥有一些整洁的特性, 例如array comprehensions, prototype aliases 以及 减少了你代码量的类编写. 

更重要的是, JavaScript的一些[古怪的特性](http://bonsaiden.github.com/JavaScript-Garden/)经常会困扰一些经验不足的程序员. CoffeeScript巧妙的避开了这些问题，而只暴露JavaScript中发挥真正作用的那部分, 如此解决了这门语言中许多的问题. 

CoffeeScript *不是* JavaScript 的子集, 因此虽然你可以在CoffeeScript中使用外部库而没有做对应的转换, 你在把它编译成JavaScript的时候还是会报错. 编译器会静态的把CoffeeScript的代码翻译成它自己对应的JavaScript副本, 而不是在代码运行期进行转换. 

学习前我们先来看看一些常见的谬误. 在写 CoffeeScript 之前你需要了解 JavaScript, 因为运行期的错误需要你的JavaScript知识. 然而, 话说回来, 运行期的错误是非常明显的, 到目前为止我还没有觉得把JavaScript报错对应到CoffeeScript是一大麻烦事. 我听说过的第二个关于CoffeeScript的问题是运行速度; 举个例子. 通过 CoffeeScript 编译器生成的代码会比使用纯 JavaScript 编写的代码慢. 但是在实践中, 这并不是一个问题. CoffeeScript tends to run as fast, or faster than hand-written JavaScript.

What are the disadvantages of using CoffeeScript? Well, it introduces another compile step between you and your JavaScript. CoffeeScript tries to mitigate the issue as best it can by producing clean and readable JavaScript, and with its server integrations which automate compilation. The other disadvantage, as with any new language, is the fact that the community is still small at this point, and you'll have a hard time finding fellow collaborators who already know the language. CoffeeScript is quickly gaining momentum though, and its IRC list is well staffed; any questions you have are usually answered promptly. 

CoffeeScript is not limited to the browser, and can be used to great effect in server side JavaScript implementations, such as [Node.js](http://nodejs.org/).   Additionally, CoffeeScript is getting much wider use and integration, such as being a default in Rails 3.1. Now is definitely the time to jump on the CoffeeScript train. The time you invest in learning about the language now will be repaid by major time savings later.

##Initial setup

One of the easiest ways to initially play around with the library is to use it right inside the browser. Navigate to [http://coffeescript.org](http://coffeescript.org) and click on the *Try CoffeeScript* tab. The site uses a browser version of the CoffeeScript compiler, converting any CoffeeScript typed inside the left panel to JavaScript in the right panel. 

You can also convert JavaScript back to CoffeeScript using the [js2coffee](http://js2coffee.org/) project, especially useful when migrating JavaScript projects to CoffeeScript.

In fact, you can use the browser-based CoffeeScript compiler yourself, by including [this script](http://jashkenas.github.com/coffee-script/extras/coffee-script.js) in a page, marking up any CoffeeScript script tags with the correct `type`.

    <script src="http://jashkenas.github.com/coffee-script/extras/coffee-script.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/coffeescript">
      # Some CoffeeScript
    </script>
    
Obviously, in production, you don't want to be interpreting CoffeeScript at runtime as it'll slow things up for your clients. Instead CoffeeScript offers a [Node.js](http://nodejs.org) compiler to pre-process CoffeeScript files.

To install it, first make sure you have a working copy of the latest stable version of [Node.js](http://nodejs.org), and [npm](http://npmjs.org/) (the Node Package Manager). You can then install CoffeeScript with npm:

    npm install -g coffee-script
    
This will give you a `coffee` executable. If you execute it without any command line options, it'll give you the CoffeeScript console, which you can use to quickly execute CoffeeScript statements. To pre-process files, pass the `--compile` option.

    coffee --compile my-script.coffee
    
If `--output` is not specified, CoffeeScript will write to a JavaScript file with the same name, in this case `my-script.js`. This will overwrite any existing files, so be careful you're not overwriting any JavaScript files unintentionally. For a full list of the command line options available, pass `--help`.

As you can see above, the default extension of CoffeeScript files is `.coffee`. Amongst other things, this will allow text editors like [TextMate](http://macromates.com/) to work out which language the file contains, giving it the appropriate syntax highlighting. By default, TextMate doesn't include support for CoffeeScript, but you can easily install the [bundle to do so](https://github.com/jashkenas/coffee-script-tmbundle).

If all this compilation seems like a bit of an inconvenience and bother, that's because it is. We'll be getting onto ways to solve this by automatically compiling CoffeeScript files, but first lets take a look at the language's syntax. 