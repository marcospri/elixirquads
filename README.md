Elixirquads
===========
An attemp to recreate the very cool https://github.com/fogleman/Quads in Elixir.

The implementation is more naive and way slower but it was a fun experiment.

![alt tag](https://raw.githubusercontent.com/marcospri/elixirquads/master/sample.png)

Dependencies are just my fork of mogrify: https://github.com/marcospri/mogrify with few 
new functions to crop, handle histograms and draw rectangles.

To run it:

Install dependencies: ```mix deps.get```

Compile and run: ```mix deps.compile && mix run quads.exs```
