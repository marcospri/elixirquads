import Mogrify

defmodule Quads do
    def draw_rectangles({w,h}, rectangles) do
        quaded_image = Mogrify.new("RBG", w, h) 

        quaded_image = 
            rectangles
            |> Enum.reduce(quaded_image,
                fn({rect, color}, quaded_image) -> 
                    {x1, y1, x2, y2} = rect
                    Mogrify.rectangle(quaded_image, x1, y1, x2, y2, color)
            end)

        draw(quaded_image, "quaded.png")
    end

    def get_quads({w,h, x, y}) do
        [
            {w/2, h/2, 0 + x, 0 + y},
            {w/2, h/2, w/2 + x, 0 + y},
            {w/2, h/2, 0 + x, h/2 + y},
            {w/2, h/2, w/2 + x, h/2 + y},
        ]
    end

    def get_size(image) do
        info = image |> verbose 
        w = Map.get(info, :width)
        h =  Map.get(info, :height)
        
        {String.to_integer(w), String.to_integer(h)}
    end

    def crop(image, {w,h, x, y}) do
        image
        |> Mogrify.crop("#{w}x#{h}+#{x}+#{y}\!")
    end

    def get_quad_color(im, quad) do
        {_, color} = Quads.crop(im |> copy, quad) |> histogram |> max_color
        color
    end

    def same_color?(color1, color2) when color1 == color2 do 1 end
    def same_color?(color1, color2) when color1 != color2 do 0 end

    def gen_rectangles(_, _, depth, _, _, rectangles) when depth == 0 do rectangles end
    def gen_rectangles(_, _, _, _, color_rep, rectangles) when color_rep == 0 do rectangles end

    def gen_rectangles(im, parent_quad, depth, color, color_times, _) do
        [q1, q2, q3, q4] = Quads.get_quads(parent_quad)

        c1 = get_quad_color(im, q1)
        c2 = get_quad_color(im, q2)
        c3 = get_quad_color(im, q3)
        c4 = get_quad_color(im, q4)
        
        # There has to be a better way to do this, it's a bit ugly
        gen_rectangles(im, q1, depth - 1, c1, color_times + same_color?(c1, color), [{q1, c1}]) ++ 
            gen_rectangles(im, q2, depth - 1, c2, color_times + same_color?(c2, color), [{q2, c2}]) ++
            gen_rectangles(im, q3, depth - 1, c3, color_times + same_color?(c3, color), [{q3, c3}]) ++
            gen_rectangles(im, q4, depth - 1, 4, color_times + same_color?(c4, color), [{q4, c4}])
    end

    def gen_rectangles(im, m_depth, m_color) do
        {w, h} = Quads.get_size(im)
        gen_rectangles(im, {w, h, 0, 0}, m_depth, {0,0,0}, m_color, [])
    end
end

max_depth = 5
max_color_rep = 2

im = open("owl.jpg") 
im_size = Quads.get_size(im)

rectangles = Quads.gen_rectangles(im, max_depth, max_color_rep) 
Quads.draw_rectangles(im_size, rectangles)
