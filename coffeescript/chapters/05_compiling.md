<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#自动编译CoffeeScript

CoffeeScript的一个问题在它在你和JavaScript之间又放置入了一层，并且你需要在CoffeeScript文件变化时重新手动编译. 幸运的是,CoffeeScript的有可选的编译方式, 使得你可以在修改和编译之间顺利的进行开发.

我们在第一章已经说过, 我们可以使用`coffee`命令进行CoffeeScript文件的编译:
    
    coffee --compile --output lib src
    
事实上, 在上面的例子中, 所有在`src`文件夹中的`.coffee`文件都会被编译成JavaScript并被存放到`lib`目录下面.不过一直的这样运行有一些没效率,那我们就来看看自动化编译吧.

##Cake

[Cake](http://jashkenas.github.com/coffee-script/#cake)是一个通过[Make](http://www.gnu.org/software/make/)和[Rake](http://rake.rubyforge.org/)实现的非常简单的构建系统. 它是捆绑在`coffeee-script`包上面的一个库，我们可以通过`cake`命令来使用它.

你可以创建	`cakefile`来定义构建的任务.通过`cake [task] [option]`的方式,Cake可以在会在当前目录自动寻找配置,并执行构建任务. 要列出所有的任务和选项, 只需输入`cake`即可.

我们可以通过`task()`函数来定义任务, 它接受一个名称参数,一个可选描述和一个回调函数.举一个例子, 我们创建一个`Cakefile`和两个目录, `lib`和`src`. 并把下面的这些添加到`Cakefile`中:

<span class="csscript"></span>

    fs = require 'fs'

    {print} = require 'sys'
    {spawn} = require 'child_process'

    build = (callback) ->
      coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
      coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      coffee.stdout.on 'data', (data) ->
        print data.toString()
      coffee.on 'exit', (code) ->
        callback?() if code is 0
    
    task 'build', 'Build lib/ from src/', ->
      build()
      
在上面的例子中,我们定义了一个任务叫`build`,只要通过`cake build`的命令就可以执行了.这个例子的运行效果和之前的例子一样,它会把所有`src`中的CoffeeScript文件都编译成`lib`目录中的JavaScript文件.你可以在HTML文件中引用`lib`目录下面的JavaScript文件.

<span class="csscript"></span>

    <!DOCTYPE html>
    <html>
    <head>
    <meta charset=utf-8>
    <script src="lib/app.js" type="text/javascript" charset="utf-8"></script>      
    </head>
    <body>
    </body>
    </html>

当我们的CoffeeScript代码变化的时候,我们还是要手动调用`cake build`命令,这和理想的情况还有差距.幸运的是, `coffee` 命令支持一个 `--watch`选项, 它会监听目录的变化并会实时的做重编译.让我们再定义另一个任务:

<span class="csscript"></span>

     task 'watch', 'Watch src/ for changes', ->
        coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
        coffee.stderr.on 'data', (data) ->
          process.stderr.write data.toString()
        coffee.stdout.on 'data', (data) ->
          print data.toString()

如果一个任务依赖于另一个任务, 你可以使用`invoke(name)`的方式来运行另一个任务. 让我们在我们的`Cakefile`中添加一条任务,它可以打开`index.html`并开始监听他引用的源文件的变化.

<span class="csscript"></span>

    task 'open', 'Open index.html', ->
      # First open, then watch
      spawn 'open', 'index.html'
      invoke 'watch'

你也可以使用`option()`函数来定义任务的选项,一个选项包含一个短名称, 一个长名称和描述.

<span class="csscript"></span>

    option '-o', '--output [DIR]', 'output dir'

    task 'build', 'Build lib/ from src/', ->
      # Now we have access to a `options` object
      coffee = spawn 'coffee', ['-c', '-o', options.output or 'lib', 'src']
      coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
      coffee.stdout.on 'data', (data) ->
        print data.toString()

你可以发现, 任务的上下文获取了一个包含用户数据的`options`对象.如果你直接使用`cake`命令而没有加上其他的参数, 所有的任务和选项都会被列出了.

Cake的伟大之处在于它可以编写各种自动化任务,例如自动编译CoffeeScript而不经过bash命令或者Makefile. [Cake的源文件](http://jashkenas.github.com/coffee-script/documentation/docs/cake.html)也很值得一读, 它本身就是包含CoffeeScript的表现力, 并且它的注释也写得很漂亮.

##服务器端的编译支持

使用Cake的方式来编译对于静态站点来说很合适,但是对于动态站点,我们可能就需要把CoffeeScript的编译过程整合在请求\响应的过程中.目前在一些框架中已经出现了一些整合方案,例如[Rails](http://rubyonrails.org/) 和 [Django](https://www.djangoproject.com/). 

在Rails 3.1中, 可以通过[Sprockets & the asset pipeline](https://github.com/sstephenson/sprockets)来支持CoffeeScript.在`app/assets/javascripts`目录下面存放你的CoffeeScript文件, Rails可以很智能的在文件请求前预处理. JavaScript文件和CoffeeScript文件都通过特殊的注释指令被串联和打包在一起, 这意味着你可以在一次请求中获取所有的的JavaScript文件. 而对于生产代码，Rails会把编译后的文件输出在硬盘中, 保证它可以被缓存并被快速的访问.

如果你的应用不需要其他的 Rails 特性以及相关的功能, 那么对于Ruby来说,像内置了Rack服务的37signal的[Pow](http://pow.cx/)和Joshua Peek的[Nack](http://josh.github.com/nack/)都是很好的选择.

Django通过特殊的模块标签也对CoffeeScript提供了[支持](http://pypi.python.org/pypi/django-coffeescript/),它同时支持行内脚本和外部脚本.

不管是Ruby还是Python,都会输出到 Node 中,然后通过CoffeeScript库来进行编译,因此在开发时要确保这些都已经安装了. 如果你的网站直接是用Node搭建的, 整合Coffeescript就更简单了,你也可以在前后端同时使用CoffeeScript.我们会在下一章详细介绍这个, 并使用[Stitch](https://github.com/sstephenson/stitch)来提供客户端的CoffeeScript服务.
