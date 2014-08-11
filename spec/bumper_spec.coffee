# bumper core spec

describe 'bumper-core', ->
  it 'should create global object', ->
    expect(window.Bumper.Responsive.Image.Background).to.not.equal undefined


describe 'bumper-responsive-image-background', ->
  @$img = null

  context 'with default and breakpoint params', ->
    before (done) ->
      $(window).on 'bumper.responsive.image.background.loaded', -> done()

      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': '/spec/bike.jpg'
        'data-bumper-responsive-image-background-url-params': 'wid=100'
        'data-bumper-responsive-image-background-url-params-breaka': 'hei=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100&hei=100')


  context 'with default but no breakpoint params', ->
    before (done) ->
      $(window).on 'bumper.responsive.image.background.loaded', -> done()

      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': '/spec/bike.jpg'
        'data-bumper-responsive-image-background-url-params': 'wid=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100')

  context 'with no default but with breakpoint params', ->
    before (done) ->
      $(window).on 'bumper.responsive.image.background.loaded', -> done()

      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': '/spec/bike.jpg'
        'data-bumper-responsive-image-background-url-params-breaka': 'hei=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?hei=100')

  context 'with no default or breakpoint params', ->
    before (done) ->
      $(window).on 'bumper.responsive.image.background.loaded', -> done()

      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': '/spec/bike.jpg'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg')

  context 'with breakpoint url', ->
    before (done) ->
      $(window).on 'bumper.responsive.image.background.loaded', -> done()

      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url-breaka': '/spec/bike-small.jpg'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike-small.jpg')
