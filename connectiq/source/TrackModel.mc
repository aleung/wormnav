class TrackModel {

    var lat_center;
    var lon_center;
    var diagonal;
    var name;
    var length;
    var nPoints;
    var xyArray;

    hidden var data;
    hidden var boundingBox;

    // lat lon values must be in radians!
    function initialize(msg) {
        data = msg;
        boundingBox = data[0];
        lat_center = boundingBox[4];
        lon_center = boundingBox[5];
        diagonal = boundingBox[6];
        name = data[1];
        length = data[2];
        nPoints = data[3];
        xyArray = data[4];
    }
}
