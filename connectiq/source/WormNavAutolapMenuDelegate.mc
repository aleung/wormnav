using Toybox.WatchUi;
using Toybox.System;
using Trace;

class WormNavAutolapMenuDelegate extends WatchUi.MenuInputDelegate {

    private var activity;

    function initialize(lapTrackerArg) {
        MenuInputDelegate.initialize();
        activity = lapTrackerArg;
    }

    function onMenuItem(item) {
        switch ( item ) {
            case :aloff:
                setAutolap(0);
                break;
            case :al100:
                setAutolap(100);
                break;
            case :al200:
                setAutolap(200);
                break;
            case :al400:
                setAutolap(400);
                break;
            case :al500:
                setAutolap(500);
                break;
            case :al1000:
                setAutolap(1000);
                break;
            case :al2000:
                setAutolap(2000);
                break;
            case :al5000:
                setAutolap(5000);
                break;
            default:
                return false;
        }
        return true;
    }

    private function setAutolap(distance) {
        activity.setAutoLapDistance(distance);
    }

}