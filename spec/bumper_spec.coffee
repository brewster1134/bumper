# bumper core spec

describe 'bumper-core', ->
  it 'should create global object', ->
    expect(window.Bumper.Responsive.BackgroundImage).to.not.equal undefined


describe 'bumper-responsive-backgroundimage', ->
  @$img = null

  context 'with default and breakpoint params', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
        'data-bumper-responsive-backgroundimage-url-params': 'wid=100'
        'data-bumper-responsive-backgroundimage-url-params-breaka': 'hei=100'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100&hei=100')


  context 'with default but no breakpoint params', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
        'data-bumper-responsive-backgroundimage-url-params': 'wid=100'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?wid=100')

  context 'with no default but with breakpoint params', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'
        'data-bumper-responsive-backgroundimage-url-params-breaka': 'hei=100'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg?hei=100')

  context 'with no default or breakpoint params', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url': '/spec/bike.jpg'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike.jpg')

  context 'with breakpoint url', ->
    before (done) ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-backgroundimage-url-breaka': '/spec/bike-small.jpg'

      @$img.on 'bumper.responsive.backgroundimage.loaded', -> done()

      window.Bumper.Responsive.BackgroundImage.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.include('/spec/bike-small.jpg')
