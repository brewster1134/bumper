# bumper core spec

describe 'bumper-core', ->
  it 'should create global object', ->
    expect(window.Bumper.Responsive.Image.Background).to.not.equal undefined


describe 'bumper-responsive-image-background', ->
  @$img = null

  context 'with default and breakpoint params', ->
    before ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': 'http://foo.com/bar.jpg'
        'data-bumper-responsive-image-background-url-params': 'wid=100'
        'data-bumper-responsive-image-background-url-params-breaka': 'hei=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.equal('url("http://foo.com/bar.jpg?wid=100&hei=100")')


  context 'with default but no breakpoint params', ->
    before ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': 'http://foo.com/bar.jpg'
        'data-bumper-responsive-image-background-url-params': 'wid=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.equal('url("http://foo.com/bar.jpg?wid=100")')

  context 'with no default but with breakpoint params', ->
    before ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': 'http://foo.com/bar.jpg'
        'data-bumper-responsive-image-background-url-params-breaka': 'hei=100'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.equal('url("http://foo.com/bar.jpg?hei=100")')

  context 'with no default or breakpoint params', ->
    before ->
      @$img = $('<img/>').attr
        'data-bumper-responsive-image-background-url': 'http://foo.com/bar.jpg'

      window.Bumper.Responsive.Image.Background.resizeEl @$img, 'breaka'

    it 'should have build the correct background image url', ->
      expect(@$img.css('background-image')).to.equal('url("http://foo.com/bar.jpg")')
