(function() {
  var fdev;

  fdev = window.fdev = {
    sayHello: function() {
      return "hello";
    },
    sayGoodby: function() {
      return "good-by";
    },
    layoutSlides: function(col, x, y, width, height) {
      var $slides, i, slide, slideX, slideY, _i, _len, _results;
      if (col == null) {
        col = 5;
      }
      if (x == null) {
        x = -1100;
      }
      if (y == null) {
        y = -1100;
      }
      if (width == null) {
        width = 1060;
      }
      if (height == null) {
        height = 900;
      }
      $slides = $(".step");
      _results = [];
      for (i = _i = 0, _len = $slides.length; _i < _len; i = ++_i) {
        slide = $slides[i];
        slideX = x + width * (i % 5);
        slideY = y + height * Math.floor(i / 5);
        if (i === $slides.length - 1) {
          slideX = 1000;
        }
        if (i === $slides.length - 1) {
          slideY = 1200;
        }
        $(slide).attr("data-x", slideX);
        _results.push($(slide).attr("data-y", slideY));
      }
      return _results;
    }
  };

  fdev.layoutSlides();

}).call(this);
