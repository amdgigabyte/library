<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8>
<meta name="description" content="The Little Book on CoffeeScript">
<meta name="keywords" content="coffeescript,javascript,book,tutorials">
<title>CoffeeScript袖珍手册</title>
<link rel="stylesheet" href="site/site.css" type="text/css" charset="utf-8">
<script src="site/jquery.js" type="text/javascript" charset="utf-8"></script>      
<meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<div id="container">
  <header>
    <h1><a href="index.html">CoffeeScript袖珍手册</a></h1>
  </header>
  <div id="notice">
  <p>An <a href="http://shop.oreilly.com/product/0636920024309.do">updated version of the book</a> is now available in Paperback, PDF and Kindle versions from O'Reilly.</p>
  
  <a href="http://shop.oreilly.com/product/0636920024309.do"><img src="site/covers.gif"></a>
  </div>
  <div id="content">
    <ol class="pages">
    {{#pages}}
      <li><a href="{{href}}">{{name}}</a></li>
    {{/pages}}
    </ol>
  </div>
</div>
</body>
</html>
