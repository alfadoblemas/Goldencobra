// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//

$(document).ready(function() {
	Response.create({
	  prop: "width",  // "width" "device-width" "height" "device-height" or "device-pixel-ratio"
	  prefix: "min-width-",  // the prefix(es) for your data attributes (aliases are optional)
	  breakpoints: [1281,1025,961,641,481,320,0], // min breakpoints (defaults for width/device-width)
	  lazy: true // optional param - data attr contents lazyload rather than whole page at once
	});
});