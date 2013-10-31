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
//= require bootstrap
//= require masonry.pkgd.min


$(function(){

  // Slider
  $('.carousel').carousel({
    interval: 5000
  });

  // Timeline
  // *********************************
  // *********************************

  // for timeline the right position for items
  var $container = $('.timeline-list');
  
  // initialize
  $container.masonry({
    itemSelector: '.tmi'
  });
  timelineLeftRight($container);

  // activates tooltips for social links
  $('.tooltip-social').tooltip({
    selector: 'a[data-toggle=tooltip]'
  });

});

function timelineLeftRight($container) {
  $.when($container.masonry()).done(function(x) { 
    $.each($(x).children(), function() {
      if($(this).css('left').split('px')[0] == 0) {
        $(this).addClass('tmi-left');
      } else {
        $(this).addClass('tmi-right');
      }
    });
  });
}