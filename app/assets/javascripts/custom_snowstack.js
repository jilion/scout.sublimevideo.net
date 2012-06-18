var CWIDTH;
var CHEIGHT;
var CGAP = 10;
var CXSPACING;
var CYSPACING;

function translate3d(x, y, z)
{
	return "translate3d(" + x + "px, " + y + "px, " + z + "px)";
}

function cameraTransformForCell(n)
{
	var x = Math.floor(n / 1);
	var y = n - x * 1;
	var cx = (x + 0.5) * CXSPACING;
	var cy = (y + 0.5) * CYSPACING;

	if (magnifyMode)
	{
		return translate3d(-cx, -cy, 180);
	}
	else
	{
		return translate3d(-cx, -cy, 0);
	}	
}

var currentCell = -1;

var cells = [];

var currentTimer = null;

var dolly, camera;

var magnifyMode = false;

var zoomTimer = null;

function refreshImage(elem, cell)
{
	if (cell.iszoomed)
	{
		return;
	}

	if (zoomTimer)
	{
		clearTimeout(zoomTimer);
	}
	
	var zoomImage = jQuery('<img class="zoom" />');

	zoomTimer = setTimeout(function ()
	{
		zoomImage.load(function ()
		{
			layoutImageInCell(zoomImage[0], cell.div[0]);
			jQuery(elem).replaceWith(zoomImage);
			cell.iszoomed = true;
		});

		zoomImage.attr("src", cell.info.zoom);

		zoomTimer = null;
	}, 2000);
}

function layoutImageInCell(image, cell)
{
    var iwidth = image.width;
    var iheight = image.height;
    var cwidth = jQuery(cell).width();
    var cheight = jQuery(cell).height();
    var ratio = Math.min(cheight / iheight, cwidth / iwidth);
    console.log(ratio);
    iwidth *= ratio;
    iheight *= ratio;

	image.style.width = Math.round(iwidth) + "px";
	image.style.height = Math.round(iheight) + "px";

	image.style.left = Math.round((cwidth - iwidth) / 2) + "px";
	image.style.top = Math.round((cheight - iheight) / 2) + "px";
}

function updateStack(newIndex, newmagnifymode)
{
	if (currentCell == newIndex && magnifyMode == newmagnifymode)
	{
		return;
	}

	var oldIndex = currentCell;
	newIndex = Math.min(Math.max(newIndex, 0), cells.length - 1);
	currentCell = newIndex;

	if (oldIndex != -1)
	{
		var oldCell = cells[oldIndex];
		oldCell.div.attr("class", "cell fader view original");	
		if (oldCell.reflection)
		{
			oldCell.reflection.attr("class", "cell fader view reflection");
		}
	}
	
	var cell = cells[newIndex];
	cell.div.addClass("selected");
	
	if (cell.reflection)
	{
		cell.reflection.addClass("selected");
	}

	magnifyMode = newmagnifymode;
	
	if (magnifyMode)
	{
		cell.div.addClass("magnify");
		refreshImage(cell.div.find("img")[0], cell);
	}

	dolly.style.webkitTransform = cameraTransformForCell(newIndex);
	
	var currentMatrix = new WebKitCSSMatrix(document.defaultView.getComputedStyle(dolly, null).webkitTransform);
	var targetMatrix = new WebKitCSSMatrix(dolly.style.webkitTransform);
	
	var dx = currentMatrix.e - targetMatrix.e;
	var angle = Math.min(Math.max(dx / (CXSPACING * 1.0), -1), 1);// * 45;

	camera.style.webkitTransform = "rotateY(" + angle + "deg)";
	camera.style.webkitTransitionDuration = "330ms";

	if (currentTimer)
	{
		clearTimeout(currentTimer);
	}
	
	currentTimer = setTimeout(function ()
	{
		camera.style.webkitTransform = "rotateY(0)";
		camera.style.webkitTransitionDuration = "5s";
	}, 330);
}

function snowstack_addimage(info)
{
	var cell = {};
	var realn = cells.length;
	cells.push(cell);

	var x = Math.floor(realn / 1);
	var y = realn - x * 1;

	cell.info = info;

	cell.div = jQuery('<div class="cell fader view original" style="opacity: 0"></div>').width(CWIDTH).height(CHEIGHT);
	cell.div[0].style.webkitTransform = translate3d(x * CXSPACING, y * CYSPACING, 0);

	var img = document.createElement("img");

	jQuery(img).load(function ()
	{
		layoutImageInCell(img, cell.div[0]);
		cell.div.append(jQuery('<a class="mover viewflat" href="' + cell.info.link + '" target="_blank"></a>').append(img));
		cell.div.css("opacity", 1);
	});
	
	img.src = info.thumb;

	jQuery("#stack").append(cell.div);

  // if (y == 2)
  // {
  //   cell.reflection = jQuery('<div class="cell fader view reflection" style="opacity: 0"></div>').width(CWIDTH).height(CHEIGHT);
  //   cell.reflection[0].style.webkitTransform = translate3d(x * CXSPACING, y * CYSPACING, 0);
  // 
  //   var rimg = document.createElement("img");
  // 
  //   jQuery(rimg).load(function ()
  //   {
  //     layoutImageInCell(rimg, cell.reflection[0]);
  //     cell.reflection.append(jQuery('<div class="mover viewflat"></div>').append(rimg));
  //     cell.reflection.css("opacity", 1);
  //   });
  // 
  //   rimg.src = info.thumb;
  // 
  //   jQuery("#rstack").append(cell.reflection);
  // }
}

function snowstack_init()
{
	CHEIGHT = Math.round(window.innerHeight / 3);
	CWIDTH = Math.round(CHEIGHT * 300 / 180);
	CXSPACING = CWIDTH + CGAP;
	CYSPACING = CHEIGHT + CGAP;

	jQuery("#mirror")[0].style.webkitTransform = "scaleY(-1.0) " + translate3d(0, - CYSPACING * 6 - 1, 0);
  
  dolly = jQuery("#dolly")[0];
  camera = jQuery("#camera")[0];
}

$(document).ready(function ()
{
	var page = 1;
	var loading = true;

  // snowstack_init();

    //     flickr(function (images)
    //     {
    // jQuery.each(images, snowstack_addimage);
    // updateStack(1);
    //       loading = false;
    //     }, page);
    
    var keys = { left: false, right: false, up: false, down: false };

    var keymap = { 37: "left", 38: "up", 39: "right", 40: "down" };
    
    var keytimer = null;
    
    function updatekeys()
    {
    	var newcell = currentCell;
		if (keys.left)
		{
			/* Left Arrow */
			if (newcell >= 1)
			{
				newcell -= 1;
			}
		}
		if (keys.right)
		{
			/* Right Arrow */
			if ((newcell + 1) < cells.length)
			{
				newcell += 1;
			}
			else if (!loading)
			{
				/* We hit the right wall, add some more */
        // page = page + 1;
        // loading = true;
        //           flickr(function (images)
        // {
        //   jQuery.each(images, snowstack_addimage);
        //   loading = false;
        // }, page);
			}
		}
		if (keys.up)
		{
			/* Up Arrow */
			newcell -= 1;
		}
		if (keys.down)
		{
			/* Down Arrow */
			newcell += 1;
		}

		updateStack(newcell, magnifyMode);
    }
    
	var delay = 330;

    function keycheck()
    {
    	if (keys.left || keys.right || keys.up || keys.down)
    	{
	    	if (keytimer === null)
	    	{
	    		delay = 330;
	    		var doTimer = function ()
	    		{
	    			updatekeys();
	    			keytimer = setTimeout(doTimer, delay);
	    			delay = 60;
	    		};
	    		doTimer();
	    	}
    	}
    	else
    	{
    		clearTimeout(keytimer);
    		keytimer = null;
    	}
    }
    
	/* Limited keyboard support for now */
	window.addEventListener('keydown', function (e)
	{
		if (e.keyCode == 32)
		{
			/* Magnify toggle with spacebar */
			updateStack(currentCell, !magnifyMode);
		}
		else
		{
			keys[keymap[e.keyCode]] = true;
		}
		
		keycheck();
	});
	
	window.addEventListener('keyup', function (e)
	{
		keys[keymap[e.keyCode]] = false;
		keycheck();
	});
});

// function flickr(callback, page)
// {
//     var url = "http://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=60746a125b4a901f2dbb6fc902d9a716&per_page=21&extras=url_o,url_m,url_s&page=" + page + "&format=json&jsoncallback=?";
//     
//   jQuery.getJSON(url, function(data) 
//   {
//         var images = jQuery.map(data.photos.photo, function (item)
//         {
//             return {
//               thumb: item.url_s,
//               zoom: 'http://farm' + item.farm + '.static.flickr.com/' + item.server + '/' + item.id + '_' + item.secret + '.jpg',
//               link: 'http://www.flickr.com/photos/' + item.owner + '/' + item.id
//             };
//         });
// 
//         callback(images);
//     });
// }
