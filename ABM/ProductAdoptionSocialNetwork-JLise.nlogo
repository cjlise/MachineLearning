globals [color-mode pop] ;; 0 = default, 1 = source, 2 = times heard, 3 = popularity

turtles-own [ adopted? seed? net-adopted?]
;; adopted?: indicates if the product has been adopted
;; seed?: Initial adoption flag
;; net-adopted?: indicates if the adoption has been reached by network effect



;; Create people and links.



to setup
  ca
  set color-mode 0 ;; default
  set-default-shape turtles "person"
  make-node nobody ;; first node, unattached
  make-node turtle 0 ;; second node, attached to first node
  reset-ticks
end

to setup-nodes
  ask turtles[
    set adopted? false
    set seed? false
    set net-adopted? false

   ;; setxy random-xcor random-ycor

    set color  blue ;; white

    ;;set size 0.5
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;
;;;Network Procedures;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Network and layout procedures incorporated from Preferential Attachment example model

to create-network
  make-node find-partner ;; find partner and use it as attachment
  tick
  if layout? [layout]
  if count turtles = population [ ;; We want the network to have POPULATION turtles, as set by the slider
    setup-nodes
    ask n-of num-seed-adopters turtles [
         set adopted? true
         set color lime
         set seed? true
    ]

    ;;repeat 30 [layout-spring turtles links 0.2 5 1]
    reset-ticks ;; reset the ticks at 0 so we can observe them for the product diffusion section
    stop
  ]
end

;; used for creating a new node

to make-node [old-node]
  crt 1
  [
    set color blue ;; default "no-trend" color is blue
   ;; set interest-category random 10 ;; an "interest type" category corresponding to one of 0-9
   ;; set trend-category -1 ;; -1 corresponds with "no trend"
   ;; set times-heard 0
    set adopted? false
    set seed? false
    set net-adopted? false
    if old-node != nobody
      [ create-link-with old-node
        ;; position new node near its partner
        move-to old-node
        fd 8
      ]
  ]
end

;; Main preferential attachment mechanism. The more connections a node already has, the more likely
;; it is to gain another connection.

to-report find-partner
  report [one-of both-ends] of one-of links
end

;;;;;;;;;;;;;;;;;;;;;;;
;;;Layout Procedures;;;
;;;;;;;;;;;;;;;;;;;;;;;

;; resize nodes, change back and forth from size based on degree to a size of 1

to resize-nodes
  ifelse all? turtles [size <= 1]
  [
    ;; a node is a circle with diameter determined by
    ;; the SIZE variable; using SQRT makes the circle's
    ;; area proportional to its degree
    ask turtles [set size sqrt count link-neighbors ]
  ]
  [
    ask turtles [set size 1]
  ]
end

to layout
  ;; the number 3 here is arbitrary; more repetitions slows down the
  ;; model, but too few gives poor layouts
  repeat 6 [
    ;; the more turtles we have to fit into the same amount of space,
    ;; the smaller the inputs to layout-spring we'll need to use
    let factor sqrt count turtles
    ;; numbers here are arbitrarily chosen for pleasing appearance
    layout-spring turtles links (1 / factor) (7 / factor) (1 / factor)
    display  ;; for smooth animation
  ]
  ;; don't bump the edges of the world
  let x-offset max [xcor] of turtles + min [xcor] of turtles
  let y-offset max [ycor] of turtles + min [ycor] of turtles
  ;; big jumps look funny, so only adjust a little each time
  set x-offset limit-magnitude x-offset 0.1
  set y-offset limit-magnitude y-offset 0.1
  ask turtles [ setxy (xcor - x-offset / 2) (ycor - y-offset / 2) ]
end

to-report limit-magnitude [number limit]
  if number > limit [ report limit ]
  if number < (- limit) [ report (- limit) ]
  report number
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;    Method to run the model.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go

  ;; ask the turles to adopt or not randomly.
  if (not any? turtles with [not adopted?]) [
    stop
  ]
  ask turtles with [not adopted?] [
    adopt
  ]

  tick
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;    Bass Model
;;;    Method to cause an unadopted agent to adopt, based on their immediate neighborhood,
;;;    social-influence, and broadcast-influence
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to adopt
  ifelse random-float 1.0 < broadcast-influence [
    set adopted? true
    set color red
  ][
  let neighbors-adopted link-neighbors with [adopted?]
  let total-neighbors link-neighbors

  if count total-neighbors > 0[
  if not adopted? and random-float 1.0 <  (social-influence * (count neighbors-adopted / count total-neighbors)) [
    set adopted? true
    set net-adopted? true
    set color yellow
  ]
  ]
  ]
  ;; color the link in yellow if both ends have been adopted by network influence
  ask links [
    if all? both-ends [adopted? = true]
    [ ifelse all? both-ends [ net-adopted? = true]
          [set color yellow]
    [ set color red]
    ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
445
10
1138
479
-1
-1
11.24
1
10
1
1
1
0
1
1
1
-30
30
-20
20
1
1
1
ticks
30.0

SLIDER
10
10
200
43
population
population
0
1000
300.0
1
1
NIL
HORIZONTAL

BUTTON
10
105
72
138
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
85
105
202
138
create network
create-network
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
20
165
123
198
layout?
layout?
0
1
-1000

SLIDER
220
10
392
43
num-seed-adopters
num-seed-adopters
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
15
60
192
93
broadcast-influence
broadcast-influence
0
1
0.001
0.0001
1
NIL
HORIZONTAL

SLIDER
220
60
392
93
social-influence
social-influence
0
1
0.01
0.005
1
NIL
HORIZONTAL

BUTTON
235
105
298
138
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
40
275
415
565
Adoptions over time
Time
Adoptions
0.0
1000.0
0.0
500.0
true
true
"let ymax population\n\nset-plot-y-range 0 ymax" ""
PENS
"Total adoption" 1.0 0 -16777216 true "" "plot count turtles with [adopted?]"
"From network" 1.0 0 -1184463 true "" "plot count turtles with [color = yellow]"
"From broadcast" 1.0 0 -2674135 true "" "plot count turtles with [color = red]"

MONITOR
90
215
162
260
%Adopted
100 * (count turtles with [adopted? = true]) / (count turtles)
3
1
11

MONITOR
180
215
252
260
%Network
100 * count turtles with [color = yellow] / count turtles
3
1
11

MONITOR
275
215
352
260
%Broadcast
100 * count turtles with [color = red] / count turtles
3
1
11

@#$#@#$#@
## WHAT IS IT?

The purpose of this model is to evaluate the adoption of a new product accross a social network.

## HOW IT WORKS

First, a social network must be created. To do this, we use the “Preferential Attachment” method. In this method, we start with two nodes connected by an edge. Then, at each step, a node is added. The new node chooses to connect to an existing node randomly, but with a bias based on the number of connections, or “degree”, the existing node already has. So the higher the degree of an existing node, the more likely a new node will connect to it. A new node “prefers” to connect to an existing node with a higher number of connections. (See the “Preferential Attachment” Sample Model.) 

We use the Bass Model to simulate the new product adoption. This model uses two parameters:
     
* The marketing effect, which is the marketing effect: Broadcast-influence variable   
* The Network or word-of-mouth effect: social-influence variable  

Moreover The word-of-mouth effect only works through immediate neighbors in a network.

At each step, a member of the network will have the following choice:
    
* Adopt from advertising with a probability p controlled by the Broadcast-influence variable  
* Adopt from social influence with the coefficient social-influence * ((number of adopted neighbors)/(total number of neighbors))

## HOW TO USE IT

I. Setting Up the Network 
Use the POPULATION slider to select the number of people you want to exist in the social network. 
The SETUP button provides a starting point for the network (two people connected by a link). 
Click the CREATE-NETWORK button to allow the preferential attachment network to fully form. It will stop when the POPULATION number of people is reached, resetting ticks to 0 and releasing the button. 
The LAYOUT? switch controls whether or not the layout procedure is run. This procedure intends to make the network structure easier to see by moving the nodes around.

Use the NUM-SEED-ADOPTERS slider to define the number of initial adopters. The social adoption will spread from those initial adopters. The initial adopters are displayed in green. 


II. Spread the product adoption 
The product adoption diffusion is controlled by the broadcast-influence and social-influence sliders. 
You can start or stop the process by clicking on the go button. The process automatically stops when the product is adopted by the whole population. 


## THINGS TO NOTICE

While the model runs, check the monitors and the chart in the interface tab. The chart displays 3 curves: 
  
- Total adoption in black 
- Network in yellow 
- Broadcast adoption in red 

The monitors display the percentage of network and broadcast adoptions. 
Check how the pace of adoption in influenced by the parameters broadcast-influence and network-influence. 
You can also use those parameters to change the rate between network an broadcast adoptions.


## THINGS TO TRY

Increase/decrease the population size to create different networks. 
Is there an impact on the network shape? 
Change the broadcast-influence and network-influence parameters and check their impact on the diffusion process. 

## EXTENDING THE MODEL

Here we use Bass model for the product adoption diffusion. Additionnal models like  the linear Threshold model or the independant cascade model could be added. And the results from the different models could be analyzed. 
Other network structures (e.g. Erdos-Renyi, Watts-Strogatz, ...) could also be built and studied. 
 

## NETLOGO FEATURES

People are turtle agents and the relationships between people are link agents. The model uses the ONE-OF primitive to choose a random link, as well as the BOTH-ENDS primitive to select the two people attached to that link. It also uses BOTH-ENDS to color the link between the people. The link color is yellow if adoption occured by network influence and red otherwise.Therefore the yellow link allows to visualize the network driven adoptions. 
The LAYOUT method, incorporated from the “Preferential Attachment” sample NetLogo model, uses the layout-spring primitive to place the nodes as if the links are springs and the people are repelling each other. This makes the network much easier to visualize and examine. 


## RELATED MODELS

This model uses the network-building technique found in the “Preferential Attachment” example in the “Networks” folder of the “Sample Models”, and also uses the implementation done by Kristen Amaddio in "The Spread of a Meme Across a Social Network". 
 
This model also use the Bass network diffusion model presented by David Darmon. 

## CREDITS AND REFERENCES
To reference this model: 
Lise, José (2020). The diffusion of a product adoption accross a social network.

Amaddio, Kristen (2015). The Spread of a Meme Across a Social Network: http://modelingcommons.org/browse/one_model/4424 

Darmon, David (2017). Modeling Network Diffusion with NetLogo: https://github.com/ddarmon/sfinsc-day2

Wilensky, U. (2005). NetLogo Preferential Attachment model. http://ccl.northwestern.edu/netlogo/models/PreferentialAttachment. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. 

Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL. 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
