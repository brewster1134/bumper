# Bumper
Bumper is a growing collection of front end tools and opinionated best practices.

## Modules
### Core `bumper-core.js`
You will always want to include core before all other modules.  It holds common helper functions and meta data other bumper modules use.

### Responsive Breakpoint `bumper-responsive-breakpoint.js`
Responsive Breakpoint allows you to manage your supported breakpoints, or configure to use other tools like jRespond

#### Methods
##### `setBreakpoints` Sets your custom breakpoints
> _Arguments_
```yaml
object: Reference the example for the object structure
```
---
> _example_
```coffee
Bumper.Responsive.Breakpoint.setBreakpoints
  'break-a':
    'min': 1024   # the minimum width in pixels
    'max': 1279   # the maximum width in pixels of the breakpoint
```

##### `getCurrent` Gets the current breakpoint
> _example_
```coffee
Bumper.Responsive.Breakpoint.getCurrent()
```

##### `setCurrentFunction` Overwrite the function used to get the current breakpoint.
If you would rather use a different tool for managing your breakpoints (eg jRespond), set the function that bumper uses to get the current breakpoint.

> _Arguments_
```yaml
function: An alternative function for return the current breakpoint
```
---
> _example_
```coffee
Bumper.Responsive.Breakpoint.setCurrentFunction jRespond.getBreakpoint
```

#### Events
##### `bumper-responsive-breakpoint-change` fires on the window when a breakpoint changes
##### `bumper-responsive-breakpoint-change-increase` fires on the window when a breakpoint changes to a larger breakpoint
##### `bumper-responsive-breakpoint-change-decrease` fires on the window when a breakpoint changes to a smaller breakpoint

### Responsive Image `bumper-responsive-image.js`
Allows you to request appropriate image sizes for different breakpoints with data attributes.

* If an `img` is used, it will set the img src attributes.
* If a `div` is used, the background-image css attribute will be set

For the best performance, you want to include this script in the <head> and above most all other scripts.  This lets bumper start requesting your images as soon as possible.

##### `resizeAll` Resizes all elements on the page
All elements must have the class `bumper-repsonsive-image`

##### `resize` Request a single image's source

_data attribute markup_
* `data-bumper-responsive-image-url`
  * Default image url
* `data-bumper-responsive-image-url-[BREAKPOINT]`
  * Breakpoint specific image url

```html
<img
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="bike.jpg"
  data-bumper-responsive-image-url-mobile="bike_mobile.jpg"
/>
```

###### For paramater based image services...
* `data-bumper-responsive-image-url-params`
  * Default params applied to all breakpoints
* `data-bumper-responsive-image-url-params-[BREAKPOINT]`
  * Breakpoint specific paramaters

```html
<div
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="http://s7d1.scene7.com/is/image/DanaCo/all_bike_colors"
  data-bumper-responsive-image-url-params="wid=400"
  data-bumper-responsive-image-url-params-mobile="wid=200"
/>
```

> _Arguments_
```yaml
el: An html element
breakpoint (optional): A breakpoint name to request an image for
```

#### Events
##### `bumper-responsive-image-loaded` fires on the img/div element when an image is loaded
> passes the img/div in the event details

### DOM Handlers
DOM Handlers allow for more complex handling of bumper modules and are AMD compatible

###### jQuery `bumper-dom-jquery.js`
##### `interpolateElementAttrs
Sometimes you may need details about the context of an element to request the correct image.  The responsive image modules support a string convention for finding, and getting attribute values from an element.

`{cssSelector:attribute,arg1,arg2,...}`

> _Arguments_
```yaml
cssSelector: any css selector of an element on the DOM
attribute: A jquery function that will return usable data
args: A comma delimited list of arguments to pass to the jquery function
```
---
> _example_
```html
<!-- bike_foo.jpg -->
<div id="foo"></div>
<img
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="bike_{#foo:attr,class}.jpg"
/>

<!-- http://s7d1.scene7.com/is/image/DanaCo/all_bike_colors?wid=100&hei=100 -->
<div id="bar" style="width: 100px; height: 100px"></div>
<img
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="http://s7d1.scene7.com/is/image/DanaCo/all_bike_colors"
  data-bumper-responsive-image-url-params="wid={#bar:innerWidth}&hei={#bar:innerHeight}.jpg"
/>
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

Do **NOT** modify any `.js` files!  Modify their `.coffee` counterparts.  They are watched for changes and compiled on demand when Testem is running.

### Compiling & Testing
Run `testem`
