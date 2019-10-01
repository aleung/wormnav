using Toybox.Activity;

module Trace {

    const BUFFER_SIZE = 10;

    // public

    var x_array = new [BUFFER_SIZE];
    var y_array = new [BUFFER_SIZE];
    var pos_start_index = 0;
    var pos_nelements = 0;
    var breadCrumbDist = 100;
    var cumDistance = breadCrumbDist;

    // internal

    var lat_last_pos;
    var lon_last_pos;

    function reset() {
        pos_nelements = 0;
        pos_start_index = 0;
        cumDistance=breadCrumbDist;
        lat_last_pos=null;
        lon_last_pos=null;
    }

    function getBreadCrumbDistStr() {
        if (breadCrumbDist == 0) {
            return "off";
        } else if (breadCrumbDist < 1000) {
            return breadCrumbDist + "m";
        } else {
            return breadCrumbDist/1000 + "km";
        }
    }

    // internal
    function put_pos(lat,lon) {
        var xy = Transform.ll_2_xy(lat,lon);

        if(pos_nelements<BUFFER_SIZE) {
            x_array[pos_nelements] = xy[0];
            y_array[pos_nelements] = xy[1];
            pos_nelements += 1;
        }
        else {
            x_array[pos_start_index] = xy[0];
            y_array[pos_start_index] = xy[1];
            pos_start_index = (pos_start_index +1) % BUFFER_SIZE;
        }

    }

    function new_pos(lat_pos,lon_pos) {
        if(lat_last_pos!=null) {
            cumDistance += Transform.distance(lat_last_pos, lon_last_pos, lat_pos, lon_pos);
        }

        lat_last_pos=lat_pos;
        lon_last_pos=lon_pos;

        if((cumDistance >= breadCrumbDist) && (breadCrumbDist > 0)) {
            put_pos(lat_last_pos,lon_last_pos);
            cumDistance -=breadCrumbDist;
        }
    }
}
