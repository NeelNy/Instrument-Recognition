using Rsvg
using Cairo

 function build_logo(newsize::Int64)
    r = Rsvg.handle_new_from_file("/Users/dev/Projects/Uni_Code/ENGR100/p3/media/src/logo.svg")
    d = Rsvg.handle_get_dimensions(r)
    scalingfactor = newsize / d.height
    cs = Cairo.CairoImageSurface(round(Int, d.width * scalingfactor), round(Int, d.height * scalingfactor), Cairo.FORMAT_ARGB32)
    c = Cairo.CairoContext(cs)
    Cairo.scale(c, scalingfactor, scalingfactor)
    Rsvg.handle_render_cairo(c, r)
    Cairo.write_to_png(cs, "/Users/dev/Projects/Uni_Code/ENGR100/p3/media/logo.png")
end
build_logo(200)