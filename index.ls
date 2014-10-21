$PP =
  * pp1: "90,0 188,45, 188,135, 0,45"
    pp2: "M187 133 L90 180 L3 135 L3 45"
    p1: "258,0 519,150 519,450 0,150"
    p2: "519,450 258,600 0,450 0,150"
  * pp1: "95,0 188,45, 188,135, 95,188"
    pp2: "M98 186 L3 135 L3 45 L98 2"
    p1: "258,0 519,150 519,450 258,600"
    p2: "258,0 258,600 0,450 0,150"
  * pp1: "188,45, 188,135, 95,188 0,135"
    pp2: "M3 135 L3 45 L98 2 L188 45"
    p1: "519,150 519,450 258,600 0,450"
    p2: "258,0 519,150 0,450 0,150"
  * pp1: "95,0 188,47 188,133 95,188 0,133 0,47"
    pp2: ""
    p1: ""
    p2: "258,0 519,150 519,450 258,600 0,450 0,150"

$SHAPE = 0

render-shape = ->
  $ \#p1 .attr \points, $PP[$SHAPE].p1
  $ \#p2 .attr \points, $PP[$SHAPE].p2
  $ \#pp1 .attr \points, $PP[$SHAPE].pp1
  $ \#pp2 .attr \d, $PP[$SHAPE].pp2

render-bg = ->
  c1 = tinycolor($ \#p1 .css \fill)
  c2 = tinycolor($ \#p2 .css \fill)
  b1 = c1.getBrightness!
  b2 = c2.getBrightness!
  if b1 > b2
    tc = tinycolor( r: 255-b1, g: 255-b1, b: 255-b1)
  else
    tc = tinycolor( r: 255-b2, g: 255-b2, b: 255-b2)
  $ \body .animate('background-color': tc.toHexString!, 500)
  $ \#background .animate 'background-color': tc.darken!.toHexString!, 500
  $ \#pp1 .attr \fill, "##{tc.toHexString!}"
  $ \#pp1 .attr \stroke,  "##{tc.toHexString!}"
  $ \#pp2 .attr \stroke, "##{tc.toHexString!}"

fill = (selector, hex) ->
  $ selector .attr \fill, "##{hex}"
  $ selector .attr \stroke, "##{hex}"
  $ "#{selector}-label" .css \border-color, "##{hex}"
  $ "#{selector}-label .text" .css \color, "##{hex}"
  $ "#{selector}-label .text" .text "##{hex}"
  render-bg!

handle-file = (file) ->
  if file.type.match /image.*/
    img = $ '#image img' .0
    img.file = file
    reader = new FileReader!
    reader.onload = (e) ->
      img.src = e.target.result
      $ '#canvas image' .attr \xlink:href, e.target.result
    reader.readAsDataURL file
  else
    console.log \not-img


$ ->
  color-picker1 = '#cp1 .block'
  color-picker2 = '#cp2 .block'

  $ color-picker1 .colpick do
    submit: no
    layout: \hex
    colorScheme: \dark
    onChange: (hsb, hex, rgb, el) -> fill \#p1, hex
  $ color-picker2 .colpick do
    submit: no
    layout: \hex
    colorScheme: \dark
    onChange: (hsb, hex, rgb, el) -> fill \#p2 hex

  $ color-picker1 .colpickSetColor \fec605
  $ color-picker2 .colpickSetColor \fea66c
  render-shape!

  $ \#shape-select .on \click ->
    $SHAPE := ($SHAPE+1) %% $PP.length
    render-shape!
    if $SHAPE == 3
      $ \#cp1 .add-class \disabled
    else
      $ \#cp1 .remove-class \disabled

  $ '#image img' .on \click -> $ \#upload .trigger \click

  $ \#upload .on \change ->
    file = $(\#upload).0.files.0
    console.log file
    handle-file file

  $ \#download .on \click ->
    svg = "<svg>#{$(\#canvas).html!}</svg>"
    canvg document.getElementById(\buffer), svg, useCORS: true, log: true, renderCallback: !->
      window.open document.getElementById(\buffer).toDataURL!, "title", "width=520px, height=600px"
