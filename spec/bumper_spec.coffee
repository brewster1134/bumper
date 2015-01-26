#
# CORE
#
describe 'bumper-core', ->
  it 'should create global object', ->
    expect(window.Bumper.Core).to.not.equal undefined

  describe '#getUrl', ->
    url = null

    context 'with a breakpoint', ->
      before ->
        $element = $('<div/>')
          .attr 'data-bumper-responsive-image-url', '/spec/bike.jpg'
          .attr 'data-bumper-responsive-image-url-small', '/spec/bike-small.jpg'
          .attr 'data-bumper-responsive-image-url-params', 'wid=200'
          .attr 'data-bumper-responsive-image-url-params-small', 'wid=100'
        url = window.Bumper.Core.getUrl $element[0], 'small'

      it 'should create a full url from bumper attributes', ->
        expect(url).to.equal '/spec/bike-small.jpg?wid=100'

    context 'without a breakpoint', ->
      before ->
        $element = $('<div/>')
          .attr 'data-bumper-responsive-image-url', '/spec/bike.jpg'
          .attr 'data-bumper-responsive-image-url-params', 'wid=200'
        url = window.Bumper.Core.getUrl $element[0]

      it 'should create a full url from bumper attributes', ->
        expect(url).to.equal '/spec/bike.jpg?wid=200'


#
# DOM
#
describe 'bumper-dom', ->
  describe '#interpolateElementAttrs', ->
    url = null

    before ->
      $sized_element = $('<div/>')
        .attr 'id', 'sized_element'
        .attr 'class', 'foo'
        .css
          borderStyle: 'solid'
          borderWidth: 1
          margin: 10
          width: 200

      $('body').append $sized_element
      url = window.Bumper.Dom.interpolateElementAttrs('wid={#sized_element:outerWidth,true}&class={#sized_element:attr,class}')

    it 'should interpolate params from element attributes', ->
      expect(url).to.equal 'wid=222&class=foo'


#
# RESPONSIVE BREAKPOINT
#
describe 'bumper-responsive-breakpoint', ->
  describe '#setBreakpoints', ->
    before ->
      window.Bumper.Responsive.Breakpoint.setBreakpoints
        breakfoo:
          min: 10
          max: 20

    it 'should make breakpoint data accessible', ->
      expect(window.Bumper.Responsive.Breakpoint.list.breakfoo.min).to.equal 10
      expect(window.Bumper.Responsive.Breakpoint.list.breakfoo.max).to.equal 20

  describe '#getCurrent', ->
    before ->
      window.Bumper.Responsive.Breakpoint.current = 'oldbreakpoint'
      window.Bumper.Responsive.Breakpoint.setBreakpoints
        onlybreakpoint:
          min: 0
          max: 4000

    it 'should return the breakpoint of the current browser size', ->
      expect(window.Bumper.Responsive.Breakpoint.getCurrent()).to.equal 'onlybreakpoint'

    it 'should update the current breakpoint', ->
      expect(window.Bumper.Responsive.Breakpoint.current).to.equal 'onlybreakpoint'

  describe '#checkBreakpointChange', ->
    before (done) ->
      $(window).on 'bumper-responsive-breakpoint-change', (e) ->
        done()

      window.Bumper.Responsive.Breakpoint.setBreakpoints
        newbreakpoint:
          min: 0
          max: 4000
      window.Bumper.Responsive.Breakpoint.checkBreakpointChange()

    it 'should fire an event with breakpoint data', ->
      expect(window.Bumper.Responsive.Breakpoint.current).to.equal 'newbreakpoint'


#
# RESPONSIVE IMAGE
#
describe 'bumper-responsive-image', ->
  context 'with an img element', ->
    $img = null

    context '#resize', ->
      before (done) ->
        $img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'

        $img.on 'bumper-responsive-image-loaded', -> done()
        window.Bumper.Responsive.Image.resize $img[0]

      it 'should add a url to the image src', ->
        expect($img.attr('src')).to.include('/spec/bike.jpg')

  context 'with a div element', ->
    $div = null

    context '#resize', ->
      before (done) ->
        $div = $('<div/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'

        $div.on 'bumper-responsive-image-loaded', -> done()
        window.Bumper.Responsive.Image.resize $div[0]

      it 'should add a url to the background image', ->
        expect($div.css('backgroundImage')).to.include('/spec/bike.jpg')
