fdev = window.fdev =
    sayHello: -> "hello"

    sayGoodby: ->"good-by"

    layoutSlides: (col = 5, x = -1100, y = -1100, width = 1060, height = 900) ->
        $slides = $(".step")
        for slide, i in $slides
            slideX = x + width * (i % 5)
            slideY = y + height * Math.floor(i / 5)
            slideX = 1000 if i is $slides.length - 1
            slideY = 1200 if i is $slides.length - 1
            $(slide).attr("data-x", slideX)
            $(slide).attr("data-y", slideY)

fdev.layoutSlides()
