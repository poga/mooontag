$PP =
  * p1: "258,0 519,150 519,450 0,150"
    p2: "519,450 258,600 0,450 0,150"
  * p1: "258,0 519,150 519,450 258,600"
    p2: "258,0 258,600 0,450 0,150"
  * p1: "519,150 519,450 258,600 0,450"
    p2: "258,0 519,150 0,450 0,150"
  * p1: ""
    p2: "258,0 519,150 519,450 258,600 0,450 0,150"

$SHAPE = 0

render-shape = ->
  $ \#p1 .attr \points, $PP[$SHAPE].p1
  $ \#p2 .attr \points, $PP[$SHAPE].p2

render-bg = ->
  c1 = tinycolor($ \#p1 .css \fill)
  c2 = tinycolor($ \#p2 .css \fill)
  b1 = c1.getBrightness!
  b2 = c2.getBrightness!
  if b1 > b2
    tc = tinycolor( r: 255-b1, g: 255-b1, b: 255-b1)
  else
    tc = tinycolor( r: 255-b2, g: 255-b2, b: 255-b2)
  $ \body .stop!
  $ \body .animate('background-color': tc.darken!toHexString!, 500)

fill = (poly-id, hex) ->
  $ "\##poly-id" .attr \fill, "##hex"
  $ "\##poly-id" .attr \stroke, "##hex"
  $ "\#c#{poly-id}" .css \border-color, "##hex"
  $ "\#c#{poly-id}" .css \color, "##hex"
  $ "\#c#{poly-id}" .css \background-color "##hex"
  render-bg!

handle-file = (file) ->
  if file.type.match /image.*/
    img = $ '#image-select img' .0
    img.file = file
    reader = new FileReader!
    reader.onload = (e) ->
      img.src = e.target.result
      $ '#canvas image' .attr \xlink:href, e.target.result
    reader.readAsDataURL file
  else
    console.log \not-img


$ ->
  color-picker1 = \#cp1
  color-picker2 = \#cp2

  $ color-picker1 .colpick do
    submit: no
    layout: \hex
    colorScheme: \dark
    onChange: (hsb, hex, rgb, el) -> fill \p1, hex
  $ color-picker2 .colpick do
    submit: no
    layout: \hex
    colorScheme: \dark
    onChange: (hsb, hex, rgb, el) -> fill \p2 hex

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

  $ '#image-select' .on \click -> $ \#upload-image .trigger \click

  $ \#upload-image .on \change ->
    file = $(\#upload-image).0.files.0
    console.log file
    handle-file file

  $ \#download .on \click ->
    svg = "<svg>#{$(\#canvas).html!}</svg>"
    canvg document.getElementById(\buffer), svg, useCORS: true, log: true, renderCallback: !->
      window.open document.getElementById(\buffer).toDataURL!, "title", "width=520px, height=600px"
