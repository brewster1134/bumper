[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/brewster1134/bumper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

# Bumper
Bumper is a growing collection of front end tools and opinionated best practices.

## Modules
### Core `bumper-core.js`
You will always want to include core before all other modules. It holds common helper functions and meta data that other Bumper modules depend on.

### Responsive Breakpoint `bumper-responsive-breakpoint.js`
Responsive Breakpoint provides tools to define and manage breakpoints for a responsive site solution.

#### Methods
---
###### `setBreakpoints` Define your custom breakpoints
> _Arguments_
> ```yaml
object: [Object] required
  A properly formatted object of breakpoint names and min/max values
```

```coffee
Bumper.Responsive.Breakpoint.setBreakpoints
  'small':    # unique breakpoint name
    min: 0        # the minimum width in pixels
    max: 1023     # the maximum width in pixels of the breakpoint
  'large':
    min: 1024
    max: 4000
```
---
###### `getCurrent` Returns the current breakpoint name
```coffee
Bumper.Responsive.Breakpoint.getCurrent()
```
---
###### `setCurrentFunction` Overwrite the function used to get the current breakpoint
> If you want to use a different breakpoint tool (e.g. jRespond), you can tell Bumper what function to call. This will allow you to still use other Bumper modules with the breakpoint solution of your choice.

> _Arguments_
```yaml
function: [Function] required
  An alternative function for return the current breakpoint
```

```coffee
Bumper.Responsive.Breakpoint.setCurrentFunction jRespond.getBreakpoint
```
---
#### Events
Responsive Breakpoint events pass the new breakpoint data as an argument
```yaml
bumper-responsive-breakpoint-change: fires on the window when a breakpoint changes
bumper-responsive-breakpoint-change-increase: fires on the window when a breakpoint changes to a larger breakpoint
bumper-responsive-breakpoint-change-decrease: fires on the window when a breakpoint changes to a smaller breakpoint
```
---
### Responsive Image `bumper-responsive-image.js`
Responsive Image provides tools to request custom image sizes based on current breakpoint size, orientation, or any other conditions you need
* If an `img` is used, it will set the img src attributes
* If a `div` is used, the background-image css attribute will be set
* All responsive image data attributes support Bumper string interpolation _(see DOM Handler docs below)_

Responsive Image relies on certain data attributes to be set to request the correct image

> _Attributes_
> ```yaml
data-bumper-responsive-image-url: required
data-bumper-responsive-image-url-[BREAKPOINT NAME]: optional
  Valid url to an image resource
data-bumper-responsive-image-url-params: optional
data-bumper-responsive-image-url-params-[BREAKPOINT NAME]: optional
  Optional url parameters for parameter based image services
```
> _Example_ with breakpoint specific urls
```html
<img
  id="foo"
  data-bumper-responsive-image-url="bike.jpg"
  data-bumper-responsive-image-url-large="bike_desktop.jpg"
/>
<!-- if at the `small` breakpoint, `bike.jpg` is requested -->
<!-- if at the `large` breakpoint, `bike_desktop.jpg` is requested -->
```
> _Example_ with breakpoint specific url parameters
```html
<img
  id="foo"
  data-bumper-responsive-image-url="bike.jpg"
  data-bumper-responsive-image-url-small="bike_mobile.jpg"
  data-bumper-responsive-image-url-params="wid=200"
  data-bumper-responsive-image-url-params-large="wid=400"
/>
<!-- if at the `small` breakpoint, `bike_mobile.jpg?wid=200` is requested -->
<!-- if at the `large` breakpoint, `bike.jpg?wid=400` is requested -->
```

#### Methods
---
###### `resizeAll` Resizes all responsive image elements on the page
Elements are detected by looking for the class `bumper-repsonsive-image`
```coffee
Bumper.Responsive.Image.resizeAll()
```
---
###### `resize` Resize a single responsive image element
Responsive image elements are resized based on various data attributes
> _Arguments_
> ```yaml
el: [HTML Element] required
  An html element that has the neccessary data attributes
breakpoint: [String] optional
  Name of a breakpoint.  If not passed, `getCurrent` will be called from the responsive breakpoint module
force: [Boolean] optional
  default: false
  When `false`, if the url is the same, no changes are made to the image, and no events are fired
  When `true`, even if the url is the same, the source will be set and events will be fired
```

```coffee
Bumper.Responsive.Image.resize document.getElementById('foo')
```
---
#### Events
Responsive Image events pass the image element as an argument
```yaml
bumper-responsive-image-loaded: fires on the image element after an image is loaded
```
---
### DOM Handlers
DOM Handlers provide additional functionality to Bumper modules. Only one DOM handler can be loaded at a time. The following examples use the jQuery dom handler

###### String Interpolation
Sometimes a Bumper module may need data from another element on the page. Bumper supports this by simply declaring a specific convention within any supported Bumper data attribute string. The convention is:

`{selector:function,arg1,arg2:option=value,foo=bar}`

> _Arguments_
```yaml
selector: required
  A css selector of an element on the DOM
function: optional
  Any function name allowed by your DOM handler
args: optional
  A comma delimited list of arguments to pass to the function
  If the function/args are left out, only the custom function will be run (see docs below)
options: optional
  A comma delimited list of key value pairs of options (separated by an `=`)
  parents: [Boolean]
    default: false
    When `true`, only the elements in the parent chain will be searched
    When `false`, elements anywhere on the page will be searched
```

The following examples use the responsive image module

> _Example_ with function & arguments for url
```html
<div id="foo" class="bar"></div>
<img
  data-bumper-responsive-image-url="bike_{#foo:attr,class}.jpg"
/>
<!-- will request `bike_bar.jpg` -->
```

> _Example_ with function & arguments for url params
```html
<div id="bar" style="width: 100px"></div>
<img
  data-bumper-responsive-image-url="bike.jpg"
  data-bumper-responsive-image-url-params="wid={#bar:width}"
/>
<!-- will request bike.jpg?wid=100 -->
```

Additionally, we can further customize the value by using a custom function that can be attached to a root element, or the target element's data attributes. Say we want to do some additional processing on the width to make sure its an integer.

> _Example_ setting a function on the target element
```coffee
$('#bar').data 'bumper-dom-function', (value) ->
  value * 2
```
> _Example_ setting a function on the root element
```coffee
$('.bumper-responsive-image').data 'bumper-dom-function', (value) ->
  parseInt(value)
```
> _Example_
```html
<div id="bar" style="width: 123.456px"></div>
<img
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="bike.jpg"
  data-bumper-responsive-image-url-params="wid={#bar:width}"
/>
<!-- will request bike.jpg?wid=246 -->
```

* The width returns: `123.456`
* The target element function runs and we double it: `246.912`
* The root element function runs and we parse it for an integer: `246`
* A request is made for `bike.jpg?wid=246`

A 2nd argument is passed to your custom function with additional data if you need it

```coffee
$('.bumper-responsive-image').data 'bumper-dom-function', (value, data) ->
  # data includes...
  #   element
  #   selector
  #   method
  #   arguments
  #   options
```

## Development
### Dependencies
```shell
gem install yuyi
yuyi -m https://raw.githubusercontent.com/brewster1134/bumper/master/yuyi_menu
bundle install
npm install
bower install
```

Do **NOT** modify any `.js` files!  Modify their `.coffee` counterparts. They are watched for changes and compiled on demand when Testem is running.

### Compiling & Testing
Run `testem`
