# bumper core spec

describe 'bumper-core', ->
  bumperCore = new window.Bumper.Core

  it 'should create global object', ->
    expect(window.Bumper.Core).to.not.equal undefined

  describe '#combineParams', ->
    it 'should combine params', ->
      expect(bumperCore.combineParams('foo=bar', 'bar=baz')).to.equal '?foo=bar&bar=baz'

  describe '#interpolateElementAttrs', ->
    before ->
      sized_element = $('<div/>')
        .attr 'id', 'sized_element'
        .attr 'class', 'foo'
        .css
          borderStyle: 'solid'
          borderWidth: 1
          margin: 10
          width: 200

      $('body').append sized_element

    it 'should interpolate params from element attributes', ->
      expect(bumperCore.interpolateElementAttrs('wid={#sized_element:outerWidth,true}&class={#sized_element:attr,class}')).to.equal 'wid=222&class=foo'

describe 'bumper-responsive-image', ->
  @$img = null

  context 'with breakpoint url', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-image-url-breaka': '/spec/bike-small.jpg'

      @$img.on 'bumper.responsive.image.loaded', -> done()

      window.Bumper.Responsive.Image.resize @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.attr('src')).to.include('/spec/bike-small.jpg')

  context 'with default params', ->
    context 'with breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'
          'data-bumper-responsive-image-url-params': 'wid=100'
          'data-bumper-responsive-image-url-params-breaka': 'hei=100'

        @$img.on 'bumper.responsive.image.loaded', -> done()

        window.Bumper.Responsive.Image.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.attr('src')).to.include('/spec/bike.jpg?wid=100&hei=100')

    context 'without breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'
          'data-bumper-responsive-image-url-params': 'wid=100'

        @$img.on 'bumper.responsive.image.loaded', -> done()

        window.Bumper.Responsive.Image.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.attr('src')).to.include('/spec/bike.jpg?wid=100')

  context 'without default params', ->
    context 'with breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'
          'data-bumper-responsive-image-url-params-breaka': 'hei=100'

        @$img.on 'bumper.responsive.image.loaded', -> done()

        window.Bumper.Responsive.Image.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.attr('src')).to.include('/spec/bike.jpg?hei=100')

    context 'without breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'

        @$img.on 'bumper.responsive.image.loaded', -> done()

        window.Bumper.Responsive.Image.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.attr('src')).to.include('/spec/bike.jpg')


describe 'bumper-responsive-backgroundimage', ->
  @$img = null

  context 'with breakpoint url', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url-breaka': '/spec/bike-small.jpg'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resize @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike-small.jpg')

  context 'with default params', ->
    context 'with breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
          'data-bumper-responsive-backgroundimage-url-params': 'wid=100'
          'data-bumper-responsive-backgroundimage-url-params-breaka': 'hei=100'

        @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

        window.Bumper.Responsive.BackgroundImage.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100&hei=100')

    context 'without breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
          'data-bumper-responsive-backgroundimage-url-params': 'wid=100'

        @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

        window.Bumper.Responsive.BackgroundImage.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100')

  context 'without default params', ->
    context 'with breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
          'data-bumper-responsive-backgroundimage-url-params-breaka': 'hei=100'

        @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

        window.Bumper.Responsive.BackgroundImage.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.css('background-image')).to.include('/spec/bike.jpg?hei=100')

    context 'without breakpoint params', ->
      before (done) ->
        @$img = $('<img/>').attr
          'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'

        @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

        window.Bumper.Responsive.BackgroundImage.resize @$img, 'breaka'

      it 'should have build the correct background image url', ->
        expect(@$img.css('background-image')).to.include('/spec/bike.jpg')
