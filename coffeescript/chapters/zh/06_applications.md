<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#创建CoffeeScript应用

现在的你应该对语法已经有大致的了解了, 我们就来实际的构造和创建CoffeeScript应用. 希望对本章的阅读会对所有CoffeeScript开发者有帮助,不论是初学者还是高手,事实上,它与纯JavaScript开发者也是息息相关的.

由于一些原因, 很多人在编写客户端JavaScript应用的时候, 还是会忘记一些惯例和常用模式, 从而导致了意大利面条式耦合的不易维护的JavaScript.在这里我不想重申一个应用的架构是多么重要; 如果你使用CoffeeScript或者JavaScript不仅仅是编写简单的表单验证, 你应当使用一些例如[MVC](http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)的开发模式.

构建可维护的大型应用程序并不仅仅意味着构建大的应用. 换句话说, 你需要构建一系列的相互不耦合的组件. 尽可能的保证应用逻辑的通用, 并进行适当的抽象. 最后,把你的逻辑分到view,model，controller(MVC)三层当中. 本章将不会涉及MVC, 如果你要了解这方面的知识, 我建议你阅读我的另一本书[JavaScript Web Applications](http://oreilly.com/catalog/9781449307530/) 并使用[Backbone](http://documentcloud.github.com/backbone/) 或者 [Spine](https://github.com/maccman/spine)这样的框架. 在这里的话, 我们则会介绍使用CommonJS模块来构建应用.

##架构和CommonJS

那么到底什么是CommonJS模块呢?如果你在之前使用过[NodeJS](http://nodejs.org/), 其实你已经在使用CommonJS了.CommonJS规范最初是用在服务器端的JavaScript库上面, 主要解决的是加载,命名空间,作用域等问题. CommonJS旨在在所用的JavaScript实现里都使用通用的形式. 并且CommonJS旨在使工作于[Rhino](http://www.mozilla.org/rhino/)的库也可以在Node下面运行. 最终,这些想法都被带到了浏览器中,因而就有了我们现在知道的[RequireJS](http://requirejs.org) 和 [Yabble](https://github.com/jbrantly/yabble) 这样的库让我们在客户端使用模块.

老实说, 模块可以确保你的代码在一个本地命名空间下运行(代码封装), 你可以通过`require()`函数来加载别的模块,也可以使用`module.exports`来输出模块.接下来我们再深入一些.

###文件依赖载入

你可以使用`require()`来加载别的模块和库. 只需传一个模块名, 如果此模块名的文件存在于加载的路径下, 那么将会返回一个代表此模块的对象,比如说:

    User = require("models/user")
    
对同步载入的支持一直是一个问题, 好在这个问题基本上被最新的CommonJS[提案](http://wiki.commonjs.org/wiki/Modules/AsynchronousDefinition)和主流的loader库解决了. 如果你要摒弃我下面会提到的Stitch而采用别的方式,那你可能必须了解一下这些实现方式.

###属性的输出

默认情况下, 模块不会输出任何的属性,因此它们对于`require()`的调用是完全不可见的.如果你希望你的模块有部分属性暴露给外部调用,你就要通过`module.exports`来设定.

    # random_module.js
    module.exports.myFineProperty = ->
      # Some shizzle
    
这样,当这个模块被载入时,`myFineProperty`就会暴露出来.

    myFineProperty = require("random_module").myFineProperty

##使用Stitch

把你的代码使用CommonJS的模块来组织固然好, 但是我们如何在客户端来做呢?我选择的是一个闻所未闻的[Stitch](https://github.com/sstephenson/stitch) 库.Stitch是Sam Stephenson写的, 它基于[Prototype.js](http://www.prototypejs.org)并解决了模块的问题,这是我用它的最大动机.
与其他通过动态加载模块的库不同的是,Stitch 简单的把所有的JavaScript捆绑为同一个,并用CommonJS进行封装. 哦, 对了, 它还会编译你的CoffeeScript, JS模板, [LESS CSS](http://lesscss.org) 和 [Sass](http://sass-lang.com) 文件!

首先如果你没有安装[Node.js](http://nodejs.org/) 和 [npm](http://npmjs.org/)你要先进行安装. 它们会在本章的例子中一直被用到.
    
现在, 我们来规划一下整个应用架构. 如果你使用[Spine](https://github.com/maccman/spine), 你可以用[Spine.App](http://github.com/maccman/spine.app)来自动化创建, 否则你就要手动来创建. 我通常会在`app`目录来存放所有的应用代码, 在`lib`中存放通用的库文件.其他的东西, 包括静态资源, 都放在`public`目录中.

    app
    app/controllers
    app/views
    app/models
    app/lib
    lib
    public
    public/index.html

现在我们开启Stitch服务器. 我们来先来创建一个 `index.coffee` 文件,并加入如下的代码:

<span class="csscript"></span>

    require("coffee-script")
    stitch  = require("stitch")
    express = require("express")
    argv    = process.argv.slice(2)
    
    package = stitch.createPackage(
      # Specify the paths you want Stitch to automatically bundle up
      paths: [ __dirname + "/app" ]
      
      # Specify your base libraries
      dependencies: [
        # __dirname + '/lib/jquery.js'
      ]
    )
    app = express.createServer()
    
    app.configure ->
      app.set "views", __dirname + "/views"
      app.use app.router
      app.use express.static(__dirname + "/public")
      app.get "/application.js", package.createServer()

    port = argv[0] or process.env.PORT or 9294
    console.log "Starting server on port: #{port}"
    app.listen port
    
我们的依赖有`coffee-script`, `stitch` and `express`. 我们需要创建一个`package.json`文件, 来罗列这些依赖,这样npm可以来载入这些依赖.我们的`./package.json`文件具体内容如下:

    {
      "name": "app",
      "version": "0.0.1",
      "dependencies": { 
        "coffee-script": "~1.1.2",
        "stitch": "~0.3.2",
        "express": "~2.5.0",
        "eco": "1.1.0-rc-1"
      }
    }
    
让我们通过npm来安装那些依赖:

    npm install .
    npm install -g coffee-script

好的,搞定了coffee-script之后,现在执行: 

    coffee index.coffee
    
这样你的Stitch服务器就运行起来了.我们继续并在`app`目录下面放一个`app.coffee`脚本来进行一下测试. 我们用这个文件来做整个应用的引导文件.

<span class="csscript"></span>

    module.exports = App =
      init: ->
        # Bootstrap the app
        
现在创建我们的主页`index.html`, 如果你是在创建一个单页面的应用程序,那么这将是用户访问唯一的页面. 这是一个静态资源, 因此我们把它放在`public`目录下面.
  
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset=utf-8>
      <title>Application</title>
      <!-- Require the main Stitch file -->
      <script src="/application.js" type="text/javascript" charset="utf-8"></script>
      <script type="text/javascript" charset="utf-8">
        document.addEventListener("DOMContentLoaded", function(){
          var App = require("app");
          App.init();
        }, false);
      </script>
    </head>
    <body>
    </body>
    </html>

当页面载入之后, 我们的 *DOMContentLoaded* 事件回调中会加载`app.coffee`脚本(它已经被自动编译) 并执行`init()`函数. 这就是所有的,我们已经有了CommonJS模块并运行起来,这也包括HTTP服务器和CoffeeScript编译器. 现在假设, 我们想引入一个模块, 只需要调用一下`require()`. 让我们来创建一个新的类 - `User`, 并在`app.coffee`里面来引用它:

<span class="csscript"></span>

    # app/models/user.coffee
    module.exports = class User
      constructor: (@name) ->
      
    # app/app.coffee
    User = require("models/user")

##JavaScript模板

如果你在客户端编写逻辑, 那么你很可能需要一套模板库.JavaScript的模板与服务器端的模板非常类似, 比如Ruby的ERB和Python的文本插值. 目前已经有很多的模板库了, 我建议你使用时做一番对比和调查.默认情况下,Stitch支持[Eco](https://github.com/sstephenson/eco)模板.

JavaScript的模板与服务器端的模板非常类似. 你会在里面使用还有HTML的插值标签, 在渲染时, 这些标签都会被赋值和替换. [Eco](https://github.com/sstephenson/eco) 模板的给力之处在于他们是由CoffeeScript写的.

这里有一个例子:

    <% if @projects.length: %>
      <% for project in @projects: %>
        <a href="<%= project.url %>"><%= project.name %></a>
        <p><%= project.description %></p>
      <% end %>
    <% else: %>
      No projects
    <% end %>

你可以看到, 它的语法非常简单. 只要用`<%`标签来包裹表达式, 使用`<%=`标签来打印表达式结果.模板标签的部分使用规则如下:
    
* `<% expression %>`  
  执行一个CoffeeScript表达式而不输出任何内容.

* `<%= expression %>`  
  执行一个CoffeeScript表达式, 并且对返回值进行转义和输出.

* `<%- expression %>`  
  执行一个CoffeeScript表达式, 对返回值不转义即输出.

你可以在模板的标签中加入任意的CoffeeScript表达式, 但是有一个要注意的. CoffeeScript对于空格是敏感的, 但是Eco模板系统不会. 因此使用Eco模版标签包裹代码块时,要在起始标签中最后以冒号结尾, 在结束标签中显式的使用`<% end %>`,例如:

    <% if @project.isOnHold(): %>
      On Hold
    <% end %>

其实也你用把`if` 和 `end`标签分行写: 

    <% if @project.isOnHold(): %> On Hold <% end %>

甚至你可以使用单行的方式输出这条`if`语句:

    <%= "On Hold" if @project.isOnHold() %>

现在我们基本掌握了语法, 我们就在`views/users/show.eco`文件中定义一个Eco模板:
    
    <label>Name: <%= @name %></label>

Stitch会自动编译我们的模板,并在`application.js`中包含它. 然后, 在我们的应用controller中,我们就可以载入这个模板, 这就好比一个模块, 我们传入了参数并执行它.
    
<span class="csscript"></span>

    require("views/users/show")(new User("Brian"))

我们的`app.coffee`文件现在应该差不多是这样, 渲染模板并在文档加载时,把模板输出到页面中:    

<span class="csscript"></span>

    User = require("models/user")

    App =
      init: ->
        template = require("views/users/show")
        view     = template(new User("Brian"))

        # Obviously this could be spruced up by jQuery
        element = document.createElement("div")
        element.innerHTML = view
        document.body.appendChild(element)
    
    module.exports = App
    
打开[应用](http://localhost:9294/)看看！希望这个教程能够帮你了解如何使用CoffeeScript来构建客户端应用.至于后面的使用, 我建议你检出[Backbone](http://documentcloud.github.com/backbone/) 或者 [Spine](http://spinejs.com)这样的客户端框架, 他们会给你提供基础的MVC架构,让你的工作更充满乐趣.
    
##附 - 30秒学会使用Heroku开发

[Heroku](http://heroku.com/) 是一个非常棒的在线程序托管服务, 它可以提供所有的服务器管理和规模化应用托管服务, 让你能够部署各种各样的JavaScript 应用.在开始这个教程前,你要先注册一个Heroku的账户, 好消息是, Heroku的基础服务是完全免费的. 作为一个传统的Ruby的托管服务, Heroku 最近也提供了Node的支持.

首先我们要创建一个`Procfile`, 用它来把我们应用的信息告知Heroku.

    echo "web: coffee index.coffee" > Procfile

然后如果你应用还没有本地git仓库的话, 我们来创建一个.

    git init
    git add .
    git commit -m "First commit"    

现在就可以通过`heroku`gem包(如果没有的话你需要提前安装)来托管应用了.

    heroku create myAppName --stack cedar
    git push heroku master
    heroku open
    
好了, 准确的说这就是你要做的所有事情, 托管Node应用没有比这更简单的了.

##其他库

[Stitch](https://github.com/sstephenson/stitch) 和 [Eco](https://github.com/sstephenson/eco)并非你构建CoffeeScript和Node应用的唯一选择.

举个例子, 模板你还可以使用[Mustache](http://mustache.github.com), [Jade](http://jade-lang.com),或者使用纯CoffeeScript的方式的[CoffeeKup](http://coffeekup.org)编写你的HTML

而对于应用服务, [Hem](http://github.com/maccman/hem)是一个很好的选择, 它支持CommonJS和NPM模块,并无缝整合了CoffeeScript的MVC框架[Spine](http://spinejs.com). [node-browsify](https://github.com/substack/node-browserify)是另一个类似的项目.或者你想整合[express](http://expressjs.com/), 你可以选择Trevor Burnham的 [connect-assets](https://github.com/TrevorBurnham/connect-assets)

在CoffeeScript的[项目 wiki](https://github.com/jashkenas/coffee-script/wiki/Web-framework-plugins)上面, 你可以找到一个CoffeeScript web框架插件的完整列表.