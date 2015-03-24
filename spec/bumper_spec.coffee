#
# CORE
#
describe 'Bumper.Core', ->
  it 'should create global object', ->
    expect(window.Bumper.Core).to.not.equal undefined

  it 'should return a version', ->
    expect(window.Bumper.Core.version).to.be.a 'string'

  describe '#castType', ->
    it 'should detect type from string', ->
      expect(window.Bumper.Core.castType('true')).to.eq true
      expect(window.Bumper.Core.castType('false')).to.eq false

    it 'should convert booleans', ->
      expect(window.Bumper.Core.castType('true', 'boolean')).to.eq true
      expect(window.Bumper.Core.castType('false', 'boolean')).to.eq false

    it 'should convert integers', ->
      expect(window.Bumper.Core.castType('2.1', 'integer')).to.eq 2
      expect(window.Bumper.Core.castType('2', 'float')).to.eq 2.0

  describe 'Module', ->
    before ->
      class BumperFooBar extends window.Bumper.Core.Module
        options:
          foo: 'module init'
      window.Bumper.Foo ||= {}
      window.Bumper.Foo.Bar ||= new BumperFooBar

    it 'should register a global options object', ->
      expect(window.Bumper.Core.Options.Foo.Bar.foo).to.equal 'module init'

    describe 'setOption', ->
      before ->
        window.Bumper.Foo.Bar.setOption 'baz', 'module setOption'

      it 'should set options on the module', ->
        expect(window.Bumper.Foo.Bar.options.baz).to.eq 'module setOption'

      it 'should make module options available globally', ->
        expect(window.Bumper.Core.Options.Foo.Bar.baz).to.eq 'module setOption'



#
# DOM
#
describe 'Bumper.Dom', ->
  describe '#getElementData', ->
    context 'with custom function', ->
      before ->
        $interpolate_element_function = $('<div/>')
          .attr 'id', 'interpolate_element_function'
          .css
            width: 12.34
            padding: 12.34
          .data 'bumper-dom-function', (value) ->
            parseInt(value)

        $('body').append $interpolate_element_function

      it 'should pass the value to the custom function', ->
        url = window.Bumper.Dom.getElementData('wid={#interpolate_element_function:width}')
        expect(url).to.equal 'wid=12'

    context 'with method arguments', ->
      before ->
        $interpolate_element_args = $('<div/>')
          .attr 'id', 'interpolate_element_args'
          .attr 'class', 'foo'
          .css
            borderStyle: 'solid'
            borderWidth: 1
            margin: 10
            width: 200

        $('body').append $interpolate_element_args

      it 'should interpolate params from element attributes', ->
        url = window.Bumper.Dom.getElementData('wid={#interpolate_element_args:outerWidth,true}&class={#interpolate_element_args:attr,class}')
        expect(url).to.equal 'wid=222&class=foo'

    context 'with options defined', ->
      before ->
        window.Bumper.Dom.options['foo'] = 'bar'

        $interpolate_element_options = $('<div/>')
          .attr 'id', 'interpolate_element_options'

        $('body').append $interpolate_element_options

      it 'should not overwrite module options', ->
        window.Bumper.Dom.getElementData('wid={#interpolate_element_options:width:foo=baz}')
        expect(window.Bumper.Dom.options.foo).to.eq 'bar'

    context 'with `parents`', ->
      $interpolate_element_parents_root = null

      before ->
        $interpolate_element_parents_target = $('<div/>')
          .attr 'id', 'interpolate_element_parents_target'
          .css
            width: 321

        # nested div with a parent
        $interpolate_element_parents_root_parent = $('<div/>')
          .css
            width: 123
        $interpolate_element_parents_root = $('<div/>')
          .attr 'id', 'interpolate_element_parents_root'

        $interpolate_element_parents_root_parent.append($interpolate_element_parents_root)
        $('body').append $interpolate_element_parents_target
        $('body').append $interpolate_element_parents_root_parent

      after ->
        window.Bumper.Dom.setOption 'parents', false

      context 'enabled', ->
        it 'should not match outside elements', ->
          url = window.Bumper.Dom.getElementData('wid={#interpolate_element_parents_target:width:type=string,parents=true}', $interpolate_element_parents_root)
          expect(url).to.equal 'wid=123'

      context 'disabled', ->
        it 'should match outside elements', ->
          url = window.Bumper.Dom.getElementData('wid={#interpolate_element_parents_target:width:type=string,parents=false}', $interpolate_element_parents_root)
          expect(url).to.equal 'wid=321'



#
# RESPONSIVE BREAKPOINT
#
describe 'Bumper.Responsive.Breakpoint', ->
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

    context 'when increasing breakpoints', ->
      before (done) ->
        $(window).on 'bumper-responsive-breakpoint-change-increase', (e) ->
          expect(e.originalEvent.detail.newbreakpointBar.min).to.equal 0
          done()

        window.Bumper.Responsive.Breakpoint.current = 'newbreakpointFoo'
        window.Bumper.Responsive.Breakpoint.setBreakpoints
          newbreakpointFoo:
            min: -4000
            max: 0
          newbreakpointBar:
            min: 0
            max: 4000

        window.Bumper.Responsive.Breakpoint.checkBreakpointChange()

      it 'should fire an event with breakpoint data', ->
        expect(window.Bumper.Responsive.Breakpoint.current).to.equal 'newbreakpointBar'

    context 'when decreasing breakpoints', ->
      before (done) ->
        $(window).on 'bumper-responsive-breakpoint-change-decrease', (e) ->
          expect(e.originalEvent.detail.newbreakpointBar.min).to.equal 0
          done()

        window.Bumper.Responsive.Breakpoint.current = 'newbreakpointFoo'
        window.Bumper.Responsive.Breakpoint.setBreakpoints
          newbreakpointFoo:
            min: 4001
            max: 8000
          newbreakpointBar:
            min: 0
            max: 4000

        window.Bumper.Responsive.Breakpoint.checkBreakpointChange()

      it 'should fire an event with breakpoint data', ->
        expect(window.Bumper.Responsive.Breakpoint.current).to.equal 'newbreakpointBar'



#
# RESPONSIVE IMAGE
#
describe 'Bumper.Responsive.Image', ->
  describe '#resize', ->
    context 'with an img element', ->
      $img = null

      before (done) ->
        $img = $('<img/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'

        $img.on 'bumper-responsive-image-loaded', -> done()
        window.Bumper.Responsive.Image.resize $img[0]

      it 'should add a url to the image src', ->
        expect($img.attr('src')).to.include('/spec/bike.jpg')

    context 'with a div element', ->
      $div = null

      before (done) ->
        $div = $('<div/>').attr
          'data-bumper-responsive-image-url': '/spec/bike.jpg'

        $div.on 'bumper-responsive-image-loaded', -> done()
        window.Bumper.Responsive.Image.resize $div[0]

      it 'should add a url to the background image', ->
        expect($div.css('backgroundImage')).to.include('/spec/bike.jpg')

  describe '#getUrl', ->
    url = null

    context 'with a breakpoint', ->
      before ->
        $element = $('<div/>')
          .attr 'data-bumper-responsive-image-url', '/spec/bike.jpg'
          .attr 'data-bumper-responsive-image-url-small', '/spec/bike-small.jpg'
          .attr 'data-bumper-responsive-image-url-params', 'wid=200'
          .attr 'data-bumper-responsive-image-url-params-small', 'wid=100'
        url = window.Bumper.Responsive.Image.getUrl $element[0], 'small'

      it 'should create a full url from bumper attributes', ->
        expect(url).to.equal '/spec/bike-small.jpg?wid=100'

    context 'without a breakpoint', ->
      before ->
        $element = $('<div/>')
          .attr 'data-bumper-responsive-image-url', '/spec/bike.jpg'
          .attr 'data-bumper-responsive-image-url-params', 'wid=200'
        url = window.Bumper.Responsive.Image.getUrl $element[0]

      it 'should create a full url from bumper attributes', ->
        expect(url).to.equal '/spec/bike.jpg?wid=200'
