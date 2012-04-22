<div class="back"><a href="index.html">&laquo; 回到章节列表</a></div>

#什么是CoffeeScript?

[CoffeeScript](http://coffeescript.org) 是一门可以被编译成JavaScript的小型语言. 它借鉴了Ruby和Python的语法, 并借鉴了它们的一些特性. 本书致力于帮你学习CoffeeScript, 理解他的最佳实践并能够制作优质的客户端程序. 这本书很短小,只有五章, 但这也正好映衬了CoffeeScript这门短小的语言. 

本书是完全开源的, 由 [Alex MacCaw](http://alexmaccaw.co.uk) (or [@maccman](http://twitter.com/maccman)) 编写并得到了 [David Griffiths](https://github.com/dxgriffiths), [Satoshi Murakami](http://github.com/satyr)和 [Jeremy Ashkenas](https://github.com/jashkenas)的支持.

如果你有建议或者发现书写错误, 别犹豫，在本书的[GitHub page](https://github.com/arcturo/library)发起一个issue. 读者们可以也会对[JavaScript Web Applications by O'Reilly](http://oreilly.com/catalog/9781449307530/)这本书比较感兴趣, 这是我写的一本介绍JavaScript富应用和客户端状态管理的书.

那我们现在就开始吧; 为什么写CoffeeScript会优于写纯JavaScript? 首先, 你可一些更少的代码 - CoffeeScript语法非常的精简明了, 并且把空格也当作了语法的一部分. 从我自己的经验来说，它相比纯JavaScript至少减少了三分之一到一半的代码. 并且, CoffeeScript拥有一些整洁的特性, 例如array comprehensions, prototype aliases 以及 减少了你代码量的类编写. 

更重要的是, JavaScript的一些[古怪的特性](http://bonsaiden.github.com/JavaScript-Garden/)经常会困扰一些经验不足的程序员. CoffeeScript巧妙的避开了这些问题，而只暴露JavaScript中发挥真正作用的那部分, 如此解决了这门语言中许多的问题. 

CoffeeScript *不是* JavaScript 的子集, 因此虽然你可以在CoffeeScript中使用外部库而没有做对应的转换, 你在把它编译成JavaScript的时候还是会报错. 编译器会静态的把CoffeeScript的代码翻译成它自己对应的JavaScript副本, 而不是在代码运行期进行转换. 

学习前我们先来看看一些常见的谬误. 在写 CoffeeScript 之前你需要了解 JavaScript, 因为运行期的错误需要你的JavaScript知识. 话说回来, 运行期的错误是非常明显的, 到目前为止我还没有觉得把JavaScript报错对应到CoffeeScript是一大麻烦事. 我听说过的第二个关于CoffeeScript的问题是运行速度; 举个例子. 通过 CoffeeScript 编译器生成的代码会比使用纯 JavaScript 编写的代码慢. 但是在实践中, 这并不是一个问题. CoffeeScript 跑得并不慢, 甚至于相比手写的 JavaScript 会更快.

那么使用 CoffeeScript 的劣势有哪些呢? 我想主要的就是它在你和JavaScript之间又增加一步编译. CoffeeScript 通过生成清晰可读的JavaScript代码以及通过服务端自动编译来尽可能的解决这个问题. 另一个劣势, 和别的新新语言一样, CoffeeScript的社区还是很小, 并且目前为止要找一个熟悉这么语言的同伴可能会很困难. 虽然如此CoffeeScript 还是在快速扩张并且它的IRC列表维护的很好; 你有任何的问题都可以得到及时的回应. 

CoffeeScript 并不仅仅限于浏览器端的开发, 它在服务器端的JavaScript实现, 例如 [Node.js](http://nodejs.org/)上面也有优异的表现. 此外, CoffeeScript正被广泛的使用和积累, 例如在 Rails 3.1 已经默认支持. 现在绝对是跳上CoffeeScript这趟快车的最佳时机. 现在学习这门语言投入的时间都将会在以后被偿还.

##初始化安装

开始使用CoffeeScript最简单的方式就是在浏览器中使用它. 访问 [http://coffeescript.org](http://coffeescript.org) 然后点击 *Try CoffeeScript* tab. 该站点使用了一个浏览器版本的CoffeeScript编译器，并且可以转换你在左侧面板输入的CoffeeScript到右侧的JavaScript面板中. 

你也可以使用[js2coffee](http://js2coffee.org/) 项目把JavaScript反转回CoffeeScript, 这在把JavaScript项目迁移至Coffee时非常有用.

事实上, 你可以通过引入[此脚本](http://jashkenas.github.com/coffee-script/extras/coffee-script.js) 来使用这个工作于浏览器的CoffeeScript编译器, 并使用对应的 `type` 来标识 CoffeeScript脚本.

    <script src="http://jashkenas.github.com/coffee-script/extras/coffee-script.js" type="text/javascript" charset="utf-8"></script>
    <script type="text/coffeescript">
      # Some CoffeeScript
    </script>
    
不过，在实际的应用中，你显然不期望在运行期把CoffeeScript在客户端进行实时的解析.而CoffeeScript也正好提供了一个[Node.js](http://nodejs.org)的编译器来预处理CoffeeScript文件.

要安装这个编译器, 首先要确保你安装了最新版本的 [Node.js](http://nodejs.org), 以及 [npm](http://npmjs.org/) (Node包管理). 然后就可以使用npm来安装CoffeeScript:

    npm install -g coffee-script
    
通过加上 -g 可以是你直接使用`coffee`命令. 当你直接在命令行敲入这个命令，你将进入一个CoffeeScript的命令行模式,在里面可以输入并执行一些CoffeeScript语句. 如果要预处理CoffeeScript文件的话, 要在命令后面再加上 `--compile` 的选项.

    coffee --compile my-script.coffee
    
如果没有指定 `--output` 选项, CoffeeScript 编译器会生成一个和coffee文件同名的 JavaScript 文件, 在这个例子中就是 `my-script.js`. 如果有同名的js存在,则这个js会被覆盖, 因此要小心无意中覆盖了你原有的JavaScript文件. 如果要完整的了解命令行的各个选项，你需要加上一个 `--help` 选项.

正如你已经看到的，CoffeeScript文件默认的扩展名是`.coffee`. 这将可以使像[TextMate](http://macromates.com/) 这样的编辑器使用合适的语法高亮来显示代码. 默认, TextMate 并不支持 CoffeeScript 语法, 但是你可以安装 [插件](https://github.com/jashkenas/coffee-script-tmbundle) 来解决.

如果你觉得所有的编译过程看起来有些不方便, 那是因为它的确是这样的. 我们将通过自动编译CoffeeScript文件来解决这些问题, 不过首先让我们来看看CoffeeScript的语法.