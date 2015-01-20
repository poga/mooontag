V =
  * [179, 0]
  * [358, 105]
  * [358, 312]
  * [179, 416]
  * [0, 312]
  * [0, 105]

S = 0

C1 = \#a84344
C2 = \#ce6666

draw-poly = (canvas, vs, color) ->
  ctx = canvas.get-context \2d
  ctx.fill-style = color
  ctx.begin-path!
  for v, i in vs
    switch i
    | 0         => ctx.move-to v[0], v[1]
    | otherwise => ctx.line-to v[0], v[1]
  ctx.fill!

draw-canvas = (canvas, shape, color1, color2) ->
  canvas.get-context \2d .clear-rect 0, 0 358, 416
  switch shape
  case 0
    draw-poly canvas, [V[2], V[3], V[4], V[5]], color1
    draw-poly canvas, [V[5], V[0], V[1], V[2]], color2
  case 1
    draw-poly canvas, [V[3], V[4], V[5], V[0]], color1
    draw-poly canvas, [V[0], V[1], V[2], V[3]], color2
  case 2
    draw-poly canvas, [V[0], V[1], V[4], V[5]], color1
    draw-poly canvas, [V[1], V[2], V[3], V[4]], color2
  case 3
    draw-poly canvas, [V[0], V[1], V[2], V[3], V[4], V[5]], color1
  img2canvas document.getElementById(\img-buffer), canvas

render-bg = ->
  c1 = tinycolor(C1)
  c2 = tinycolor(C2)
  b1 = c1.getBrightness!
  b2 = c2.getBrightness!
  if Math.abs(127 - b1) < 50 && Math.abs(127 - b2) < 50
    tc = tinycolor( r: 200, g: 200, b: 200)
  else if Math.abs(127 - b1) > 90 && Math.abs(127 - b2) > 90 && (127-b1) * (127-b2) < 1
    tc = tinycolor( r: 127, g: 127, b: 127)
  else if b1 > b2
    tc = tinycolor( r: 255-b1, g: 255-b1, b: 255-b1)
  else
    tc = tinycolor( r: 255-b2, g: 255-b2, b: 255-b2)
  $ \body .stop!
  $ \body .animate('background-color': tc.lighten!toHexString!, 500)

change-color = (id, c) ->
  $ "#{id}-color-label" 
    ..text c
    ..css \color c
  $ "#{id}-deco" .css \border-color c
  render-bg!

img2canvas = (img, canvas) ->
  ctx = canvas.get-context \2d
  dx = (canvas.width - img.width) / 2
  dy = (canvas.height - img.height) / 2
  ctx.draw-image img, dx, dy

handle-file = (canvas, file) ->
  if file.type.match /image.*/
    reader = new FileReader!
    reader.onload = (e) ->
      $ '#img-buffer' .attr \src, e.target.result
      img = document.getElementById \img-buffer
      draw-canvas canvas, S, C1, C2
      img2canvas img, canvas
    reader.readAsDataURL file
  else
    console.log \not-img

canvas = document.getElementById \canvas
draw-canvas canvas, S, C1, C2
cp1 = \#left-cp
cp2 = \#right-cp

$ cp1 .colpick do
  submit: no
  flat: yes
  layout: \hex
  colorScheme: \dark
  onChange: (hsb, hex, rgb, el) ->
    C1 := "##hex"
    change-color \#left, C1
    draw-canvas canvas, S, C1, C2
$ cp2 .colpick do
  submit: no
  flat: yes
  layout: \hex
  colorScheme: \dark
  onChange: (hsb, hex, rgb, el) ->
    C2 := "##hex"
    change-color \#right, C2
    draw-canvas canvas, S, C1, C2

$ cp1 .colpickSetColor C1
$ cp2 .colpickSetColor C2

$ \#shape-select .on \click ->
  S := (S+1) % 4
  draw-canvas canvas, S, C1, C2
  if S == 3
    $ cp2 .add-class \disabled
  else
    $ cp2 .remove-class \disabled

$ '#image-select' .on \click -> $ \#upload-image .trigger \click

$ \#upload-image .on \change ->
  file = $(\#upload-image).0.files.0
  handle-file canvas, file

$ \#save-select .on \click ->
  #window.open document.getElementById(\canvas).toDataURL!, "title", "width=520px, height=600px"
  $ \#temp-link
    ..attr \href, "data:application#{canvas.toDataURL!}"
    ..attr \download, "badge.png"
  $ \#temp-link .0.click!
