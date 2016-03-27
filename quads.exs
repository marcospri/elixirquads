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

        w = info.width |> String.to_integer
        h = info.height |> String.to_integer
        
        {w, h}
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
        quads = Quads.get_quads(parent_quad)

        quads
            |> Enum.map(fn(q) -> get_quad_color(im, q) end)
            |> Enum.zip(quads)
            |> Enum.map(fn({c, q}) -> 
              im |> gen_rectangles(q, depth - 1, c, color_times + same_color?(c, color), [{q, c}])
        end)
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

rectangles = Quads.gen_rectangles(im, max_depth, max_color_rep) |> List.flatten
Quads.draw_rectangles(im_size, rectangles)
