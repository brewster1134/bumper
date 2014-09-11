# bumper

## Dependencies
* jquery

### Basics
For calling methods, all bumper modules are AMD compatible...

```coffee
define [
  'bumper/lib/bumper-responsive-image'
], (BumperResponsiveImage) ->
  BumperResponsiveImage.resize $('img#foo'), 'breakFoo'
```

Or include the javascripts statically...
```html
<script src="/lib/bumper-core.js"></script>
<script src="/lib/bumper-responsive-image.js"></script>
```
And call nested methods off the window
```coffee
window.Bumper.Responsive.Image.resize $('img#foo'), 'breakFoo'
```

### Responsive | Image
##### Markup
* `data-bumper-responsive-image-url`
  * Default image url
* `data-bumper-responsive-image-url-[BREAKPOINT]`
  * Breakpoint specific image url

###### For paramater based image services...
* `data-bumper-responsive-image-url-params`
  * Default params applied to all breakpoints
* `data-bumper-responsive-image-url-params-[BREAKPOINT]`
  * Breakpoint specific paramaters

```html
<img
  class="bumper-responsive-image"
  data-bumper-responsive-image-url="http://s7d1.scene7.com/is/image/DanaCo/all_bike_colors"
  data-bumper-responsive-image-url-params="opac=50"
  data-bumper-responsive-image-url-params-mobile="bgc=255,0,0&wid=200"
  data-bumper-responsive-image-url-params-desktop="bgc=0,255,0&wid=400"
/>
```

###### Interpolation
You can use dynamic data from the within dom with the convention `{cssSelector:attribute}`

* `cssSelector`
  * A css selector for an element on the dom to get attributes from
* `attribute`
  * Any jquery method with comma separated , and returns a value needed for your image url

```html
<div class="foo" id="sized_element" style="width: 100px; margin: 10px"/>
<img data-bumper-responsive-image-url="http://image_{sized_element:attr,class}.jpg?wid={sized_element:outerWidth,true}"
```

The example above will request an image with a src of `http://image_foo.jpg?wid=120`

Interpolation can be applied to any of the `data-bumper-responsive-` attributes.

##### Events
When an image is loaded, the event `bumper.responsive.image.loaded` is fired on the image element.

##### Methods
###### `resize`
resizes based on the current environment context for a singe image
> _Arguments_
```yaml
$img: A jquery img element
breakpoint: An arbitrary breakpoint name
```
---
> _example_
```coffee
Bumper.Responsive.Image.resize $('img#foo'), 'breakFoo'
```

###### `resizeAll`
resizes based on the current environment context for all matching images in the dom
> _Arguments_
```yaml
breakpoint: An arbitrary breakpoint name
```
---
> _example_
```coffee
Bumper.Responsive.Image.resizeAll 'breakFoo'
```

### Responsive | Background Image
##### Markup
* `data-bumper-responsive-backgroundimage-url`
  * Default image url
* `data-bumper-responsive-backgroundimage-url-[BREAKPOINT]`
  * Breakpoint specific image url

###### For paramater based image services...
* `data-bumper-responsive-backgroundimage-url-params`
  * Default params applied to all breakpoints
* `data-bumper-responsive-backgroundimage-url-params-[BREAKPOINT]`
  * Breakpoint specific paramaters

```html
<div
  class="bumper-responsive-backgroundimage"
  data-bumper-responsive-backgroundimage-url="http://s7d1.scene7.com/is/image/DanaCo/all_bike_colors"
  data-bumper-responsive-backgroundimage-url-params="opac=50"
  data-bumper-responsive-backgroundimage-url-params-mobile="bgc=255,0,0&wid=200"
  data-bumper-responsive-backgroundimage-url-params-desktop="bgc=0,255,0&wid=400"
/>
```

###### Interpolation
_same as Responsive Image, but with the markup attributes above_

##### Events
When an image is loaded, the event `bumper.responsive.backgroundimage.loaded` is fired on the image element.

##### Methods
###### `resize`
resizes based on the current environment context for a singe image
> _Arguments_
```yaml
$el: A jquery element
breakpoint: An arbitrary breakpoint name
```
---
> _example_
```coffee
Bumper.Responsive.Image.resize $('img#foo'), 'breakFoo'
```

###### `resizeAll`
resizes based on the current environment context for all matching images in the dom
> _Arguments_
```yaml
breakpoint: An arbitrary breakpoint name
```
---
> _example_
```coffee
Bumper.Responsive.Image.resizeAll 'breakFoo'
```

## Development
### Dependencies
```shell
gem install yuyi
yuyi https://raw.githubusercontent.com/brewster1134/bumper/master/yuyi_menu
bundle install
npm install
bower install
```

Do **NOT** modify any `.js` files!  Modify the coffee files in the `src` directory.  Guard will watch for changes and compile them to the `lib` directory.

### Compiling & Testing
Run `testem`
