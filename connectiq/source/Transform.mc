using Toybox.Math;
using Toybox.System;

module Transform {

    const EARTH_RADIUS = 6371000;
    const PI2_3 = 0.6666667*Math.PI;
    const ANGLE_R =0.5*Math.PI+Math.atan2(3, 2);
    const ANGLE_L =1.5*Math.PI-Math.atan2(3, 2);

    var refScale = 2.0;
    const SCALE_PIXEL = 0.1;
    const DEFAULT_ZOOM_LEVEL = 5;

    var zoomLevel;
    var scaleFactor;

    var x_pos;
    var y_pos;
    var last_x_pos;
    var last_y_pos;

    var lat_view_center;
    var lon_view_center;
    var cos_lat_view_center;
    var sin_lat_view_center;
    var xs_center;
    var ys_center;
    var isTrackCentered;

    var x_d;
    var y_d;

    var northHeading=true;
    var centerMap=false;
    var sin_heading;
    var cos_heading;
    var heading_smooth=-1;
    var cos_heading_smooth;
    var sin_heading_smooth;
    const SMOOTH_FACTOR=0.3;


    var pixelHeight;
    var pixelWidth;
    var pixelWidth2;
    var pixelHeight2;
    var pixelHeight3;

    var scale_x1;
    var scale_y1;
    var scale_x2;
    var scale_y2;
    var compass_x;
    var compass_y;
    var compass_size;

    function setPixelDimensions(width, height) {
        pixelWidth = width;
        pixelWidth2 = 0.5*pixelWidth;
        pixelHeight = height;
        pixelHeight2 = 0.5 * pixelHeight;
        pixelHeight3 = 0.6666667*pixelHeight;
        scale_x1 = pixelWidth*(0.5-SCALE_PIXEL);
        scale_y1 = (1.0-0.45*SCALE_PIXEL)*pixelHeight;
        scale_y2 = (1.0-0.2*SCALE_PIXEL)*pixelHeight;
        scale_x2 = pixelWidth*(0.5+SCALE_PIXEL);
        compass_size = 0.25*(scale_x2-scale_x1);
        compass_x = scale_x2 + 2*compass_size;
        compass_y = scale_y2 - compass_size;
    }

    function setViewCenter(lat, lon) {
        if(!centerMap) {
            var ll = lon-track.lon_center;
            var cos_lat = Math.cos(lat);
            x_d = cos_lat*Math.sin(ll);
            y_d = cos_lat_view_center*Math.sin(lat)-sin_lat_view_center*cos_lat*Math.cos(ll);
            xs_center = pixelWidth2;
            if(northHeading || isTrackCentered) {
                ys_center = pixelHeight2;
            }
            else {
                ys_center = pixelHeight3;
            }
        }
        else {
           x_d=0;
           y_d=0;
           xs_center = pixelWidth2;
           ys_center = pixelHeight2;
        }
    }

    function setHeading(info) {
        /*
        var heading = info.heading;
        cos_heading = Math.cos(heading);
        sin_heading = Math.sin(heading);
        if(heading_smooth==-1) {
            heading_smooth = heading;
        }
        else {
            heading_smooth = (1-SMOOTH_FACTOR)*heading + SMOOTH_FACTOR*heading_smooth;
        }
        */
        if(last_x_pos != null) {
            heading_smooth = Math.atan2(x_pos-last_x_pos, y_pos-last_y_pos);
        }
        else {
            heading_smooth = 0;
        }
        if(heading_smooth < 0) {
            heading_smooth = 2*Math.PI+heading_smooth;
        }
        cos_heading_smooth = Math.cos(heading_smooth);
        sin_heading_smooth = Math.sin(heading_smooth);
    }

    function resetHeading(info) {
        heading_smooth = 0.0;
        cos_heading_smooth = 1.0;
        sin_heading_smooth = 0.0;
    }

    function newTrack() {
        System.println("newTrack()");
        cos_lat_view_center = Math.cos(track.lat_center);
        sin_lat_view_center = Math.sin(track.lat_center);
        isTrackCentered = true;
        calcZoomToFitLevel();
        setViewCenter(track.lat_center, track.lon_center);
        Transform.setHeading(0);
    }

    function setPosition(info) {
        if(x_pos != null) {
            last_x_pos = x_pos;
            last_y_pos = y_pos;
        }
        var xy = ll_2_xy(info.position.toRadians()[0], info.position.toRadians()[1]);
        x_pos = xy[0];
        y_pos = xy[1];
        setViewCenter(info.position.toRadians()[0],info.position.toRadians()[1]);
        setHeading(info);
    }

    function xy_2_screen(x, y) {
        return [xs_center+scaleFactor*(x-x_d), ys_center-scaleFactor*(y-y_d)];
    }

    function ll_2_screen(lat, lon) {
        var ll = lon-track.lon_center;
        var cos_lat = Math.cos(lat);
        var x = cos_lat*Math.sin(ll);
        var y = cos_lat_view_center*Math.sin(lat)-sin_lat_view_center*cos_lat*Math.cos(ll);
        return xy_2_screen(x, y);
    }

    function xy_2_rot_screen(x, y) {
        var xr = scaleFactor*(x-x_d);
        var yr = scaleFactor*(y-y_d);
        return [xs_center+xr*cos_heading_smooth - yr*sin_heading_smooth,
                ys_center-xr*sin_heading_smooth - yr*cos_heading_smooth];
    }

    function ll_2_xy(lat, lon) {
        var ll = lon-track.lon_center;
        var cos_lat = Math.cos(lat);
        return [cos_lat*Math.sin(ll), cos_lat_view_center*Math.sin(lat)-sin_lat_view_center*cos_lat*Math.cos(ll)];
    }

    function refScaleFromLevel(level) {
        var levelrange = Math.floor(level/5);
        var sublevel = level % 5;
        var offset = 0;
        switch ( sublevel ) {
           case 1:
               offset= 8;
               break;
           case 2:
               offset= 18;
               break;
           case 3:
               offset= 38;
               break;
           case 4:
               offset= 68;
               break;
        }
        return (Math.pow(10, levelrange)*(12+offset));
    }

    function calcZoomToFitLevel() {

        // trackDiameter must fit into minimum of spans in x and y direction
        var minPixels = pixelHeight;
        if (pixelWidth <  pixelHeight) {
            minPixels = pixelWidth;
        }
        zoomLevel = 0;
        for(zoomLevel= 0; zoomLevel < 25; zoomLevel+=1 ) {
            refScale = refScaleFromLevel(zoomLevel);
            if(minPixels/(0.2*pixelWidth)*refScaleFromLevel(zoomLevel)*0.95>track.diagonal) {
                break;
            }
        }
        scaleFactor = 0.2*pixelWidth/refScale*EARTH_RADIUS;
        return;
    }

    function setZoomLevel(l) {
        if(l>=0 && l <= 25) {
            zoomLevel = l;
        }
        else {
            zoomLevel=DEFAULT_ZOOM_LEVEL;
        }
        refScale = refScaleFromLevel(zoomLevel);
        scaleFactor = 0.2*pixelWidth/refScale*EARTH_RADIUS;
        return zoomLevel;
    }

    function zoomIn() {
        if(zoomLevel > 0) {
            zoomLevel-=1;
        }
        refScale = refScaleFromLevel(zoomLevel);
        scaleFactor = 0.2*pixelWidth/refScale*EARTH_RADIUS;
        return;
    }

    function zoomOut() {
        if(zoomLevel < 24) {
            zoomLevel+=1;

        }
        refScale = refScaleFromLevel(zoomLevel);
        scaleFactor = 0.2*pixelWidth/refScale*EARTH_RADIUS;
        return;
    }

    function formatScale(scale) {
        if(scale < 1000) {
            return scale.format("%d") + "m";
        }
        var scalekm = scale/1000;
        return scalekm.format("%.1f") + "k";
    }

    function distance(lat1, lon1, lat2, lon2) {
        var dphi = (lat2-lat1);
        var dlambda = (lon2-lon1);
        var a = Math.sin(0.5*dphi)*Math.sin(0.5*dphi) +
            Math.cos(lat1)*Math.cos(lat2) *
            Math.sin(0.5*dlambda)*Math.sin(0.5*dlambda);
        return EARTH_RADIUS*2*Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    }
}