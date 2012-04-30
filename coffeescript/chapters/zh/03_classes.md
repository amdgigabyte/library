<div class="back"><a href="index.html">&laquo; 返回章节列表</a></div>

#类

类在javascript中发挥的功效很大，就像对付吸血鬼的大蒜头一样，不过话说回来，如果你有这种想法，你很可能不会去看一本Coffeescript的书。然而，类在javascript无非只是表现的和它在别的语言里面一样的能力，而在这方面Coffeescript提供了更好的抽象.

CoffeeScript使用了Javascript原生的原形来创建类，并且添加了一些静态属性和保持作用域上的语法糖。而这一切都通过 `class` 关键字提供给开发者.

<span class="csscript"></span>

    class Animal
    
在上面的例子中, `Animal` 是类名,我们可以用这个类目来创建变量.CoffeeScript支持构造函数，这意味着你可以通过`new`操作符来生成实例.

<span class="csscript"></span>

    animal = new Animal

定义构造函数非常简单，只需定义一个 `constructor` 函数.这就像我们使用Ruby的 `initialize` 或者 Python 的 `__init__`.

<span class="csscript"></span>

    class Animal
      constructor: (name) ->
        @name = name

事实上，CoffeeScript提供了一种设定实例属性的缩写方式。只需要在参数前加上`@`, CoffeeScript会自动的在构造函数中设定实例的属性,事实上，这个缩写方式也适用于普通的类之外的函数。下面的这个例子和我们之前手动设定实例属性的例子是等价的.

<span class="csscript"></span>

    class Animal
      constructor: (@name) ->

正如你期望的，任何在初始化过程中传入的参数都会被传入构造函数.

<span class="csscript"></span>

    animal = new Animal("Parrot")
    alert "Animal is a #{animal.name}"

##实例属性

给一个类添加额外的实例方法非常的简单. 它与对一个对象添加属性的语法一样. 只是把方法添加在class之上. 

<span class="csscript"></span>

    class Animal
      price: 5

      sell: (customer) ->
        
    animal = new Animal
    animal.sell(new Customer)

作用域的改变在JavaScript中非常普遍，在之前的语法章节，我们谈及了CoffeeScript可以通过 `=>` 锁定 `this` 的值到一个固定的执行上下文上面。这就确保了不论函数在什么作用域下运行，它总会在它创建时的执行上下文下执行.
    
<span class="csscript"></span>

    class Animal
      price: 5

      sell: =>
        alert "Give me #{@price} shillings!"
        
    animal = new Animal
    $("#sell").click(animal.sell)

上面的例子已经说明，this在事件回调中非常有用。通常来说, `sell()`函数只会在 `#sell` 的元素的作用域下面执行。不过通过对`sell()`函数使用`=>` 符，我们可以保证它的作用域一直不变。并且 `this.price` 始终等于 `5`.

##静态属性

那么如何定义类的方法(静态方法)呢？很简单，在一个类的定义体中，`this`指向这个类对象.换句话说,你可以直接在`this`上面设置静态属性(类属性).

<span class="csscript"></span>

    class Animal
      this.find = (name) ->      

    Animal.find("Parrot")
    
你可能还记得，CoffeeScript通过`@`符来引用 `this`，这样你能更简洁的编写静态方法: 
    
<span class="csscript"></span>

    class Animal
      @find: (name) ->
      
    Animal.find("Parrot")

##继承和超类

如果没有继承的机制,类的存在也就没有真正的意义, CoffeeScript自然也提供了这方面的语法.你可以使用 `extends`关键词从一个类继承自另一个类. 在下面的这个例子中, `Parrot` 类就继承自 `Animal` 类, 包括了所有的实例方法, 例如 `alive()` 方法。

<span class="csscript"></span>

    class Animal
      constructor: (@name) ->
      
      alive: ->
        false

    class Parrot extends Animal
      constructor: ->
        super("Parrot")
      
      dead: ->
        not @alive()

从上一个例子中你可以看到，我们还使用了 `super()` 关键字. 如此做, this就指向了当前类“父类”的原型, 并且使用当前的作用域来执行. 在对应的js中, 就会生成 `Parrot.__super__.constructor.call(this, "Parrot");` 这样的一段申明. 实际运用中, 这样就好比是在 Ruby 或者 Python中使用 `super`, 执行被继承的函数.

通常来说当实例被创建的时候CoffeeScript会执行父类的 `constructor` 构造函数，除非你自己修改了构造函数.

CoffeeScript使用原形继承来继承一个类的所有实例方法.这保证了所有的类都是动态的; 即便是一个子类被创建后，在父类添加了实例方法，继承于它的子类依然能够使用这个方法.

<span class="csscript"></span>

    class Animal
      constructor: (@name) ->
      
    class Parrot extends Animal
    
    Animal::rip = true
    
    parrot = new Parrot("Macaw")
    alert("This parrot is no more") if parrot.rip

值得指出的是静态的属性都被拷贝到子类中, 而不是像实例属性那样通过原形来继承. 这主要源于Javascript原型架构的原因.

##混合(Mixins)

[混合(Mixins)](http://en.wikipedia.org/wiki/Mixin) 并非CoffeeScript原生支持的特性, 但基于他们的好处，你可以自己写一个. 举例来说，混合包含两个函数, `extend()` 和 `include()` 分别可以向一个类中添加类属性和实例属性.

<span class="csscript"></span>

    extend = (obj, mixin) ->
      obj[name] = method for name, method of mixin        
      obj

    include = (klass, mixin) ->
      extend klass.prototype, mixin
    
    # Usage
    include Parrot,
      isDeceased: true
      
    (new Parrot).isDeceased

当继承的方式并不适用，但又需要在模块之间共享一些常用的逻辑的时候，混合就是很好的方式。混合的优势在于, 相比于继承的来源只有一个父类，你可以对自己的类加入很多的不同的特性或属性。

##扩展类

混合(Mixin)非常的简洁优雅, 但是他们的写法并没有面向对象. 我们就把Mixin整合进CoffeeScript的类之中. 我们先定义一个叫 `Module` 的类,通过这个类我们可以继承Mixin的特性. `Module` 拥有两个静态的方法, `@extend()` 和 `@include()`, 通过这两个方法,我们可以分别扩展一个类的静态和实例属性.

<span class="csscript"></span>

    moduleKeywords = ['extended', 'included']

    class Module
      @extend: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @[key] = value

        obj.extended?.apply(@)
        this
        
      @include: (obj) ->
        for key, value of obj when key not in moduleKeywords
          # Assign properties to the prototype
          @::[key] = value

        obj.included?.apply(@)
        this

moduleKeywords变量所做的工作是确保我们在mixin继承了一个类之后能支持回调.
让我们看看 `Module` 类如何实际的使用:

<span class="csscript"></span>

    classProperties = 
      find: (id) ->
      create: (attrs) ->
      
    instanceProperties =
      save: -> 

    class User extends Module
      @extend classProperties
      @include instanceProperties
    
    # Usage:
    user = User.find(1)
    
    user = new User
    user.save()

你可以看到, 我们添加了静态方法 `find()` 和 `create()` 到 `User` 这个类, 另外添加了实例方法 `save()`. 因为我们有模块扩展的回调, 我们可以通过接受静态和动态的属性来简化这一过程:

<span class="csscript"></span>

    ORM = 
      find: (id) ->
      create: (attrs) ->
      extended: ->
        @include
          save: -> 

    class User extends Module
      @extend ORM

非常简单和高效吧！